import Foundation

public final class DocumentBuilder {
    private var out = WireWriter()
    private var texts: [(id: Int, text: String)] = []
    private var idLists: [DataListIdsOperation] = []
    private var preludeOperations: [RemoteOperation] = []
    private var nextTextId = 1
    private var nextComponentId = 1
    private let width: Int
    private let height: Int
    private let wrapChildrenInContent: Bool
    
    public init(width: Int = 400, height: Int = 800, wrapChildrenInContent: Bool = true) {
        self.width = width
        self.height = height
        self.wrapChildrenInContent = wrapChildrenInContent
    }
    
    // MARK: Containers
    
    public func root(_ children: () -> Void) {
        RootLayoutOperation(componentId: newComponentId()).write(to: &out)
        wrapped(children)
        out.start(OpCode.containerEnd)
    }
    
    public func row(
        horizontal: Int = Positioning.start,
        vertical: Int = Positioning.top,
        spacedBy: Float = 0,
        modifiers: [RemoteModifier] = [],
        _ children: () -> Void = {}
    ) {
        RowLayoutOperation(
            componentId: newComponentId(),
            animationId: -1,
            horizontalPositioning: horizontal,
            verticalPositioning: vertical,
            spacedBy: spacedBy
        ).write(to: &out)
        write(modifiers)
        wrapped(children)
        out.start(OpCode.containerEnd)
    }
    
    public func column(
        horizontal: Int = Positioning.start,
        vertical: Int = Positioning.top,
        spacedBy: Float = 0,
        modifiers: [RemoteModifier] = [],
        _ children: () -> Void = {}
    ) {
        ColumnLayoutOperation(
            componentId: newComponentId(),
            animationId: -1,
            horizontalPositioning: horizontal,
            verticalPositioning: vertical,
            spacedBy: spacedBy
        ).write(to: &out)
        write(modifiers)
        wrapped(children)
        out.start(OpCode.containerEnd)
    }
    
    public func canvas(
        modifiers: [RemoteModifier] = [],
        _ children: () -> Void = {}
    ) {
        CanvasLayoutOperation(componentId: newComponentId()).write(to: &out)
        write(modifiers)
        wrapped(children)
        out.start(OpCode.containerEnd)
    }
    
    // MARK: Leaves
    
    public func text(
        _ string: String,
        color: UInt32 = 0xFF00_0000,
        colorId: Int? = nil,
        fontSize: Float = 16,
        fontWeight: Float = 400,
        italic: Bool = false,
        fontFamily: String? = nil,
        align: Int = TextAlign.start,
        overflow: Int = TextOverflow.clip,
        maxLines: Int = Int(Int32.max),
        modifiers: [RemoteModifier] = []
    ) {
        let textId = registerText(string)
        let familyId = fontFamily.map { registerText($0) } ?? -1
        let flags = colorId == nil ? 0 : TextLayoutOperation.flagIsDynamicColor
        let colorValue = colorId ?? Int(Int32(bitPattern: color))
        TextLayoutOperation(
            componentId: newComponentId(),
            animationId: -1,
            textId: textId,
            color: colorValue,
            fontSize: RemoteFloat(fontSize),
            fontStyle: italic ? 1 : 0,
            fontWeight: RemoteFloat(fontWeight),
            fontFamilyId: familyId,
            textAlign: (flags << 16) | align,
            overflow: overflow,
            maxLines: maxLines
        ).write(to: &out)
        write(modifiers)
        out.start(OpCode.containerEnd)
    }
    
    // MARK: Data
    
    public func dataListIds(id: Int, values: [Int]) {
        idLists.append(DataListIdsOperation(id: id, ids: values))
    }
    
    public func floatExpression(id: Int, expression: [RemoteFloat], animationSpec: [RemoteFloat]? = nil) {
        preludeOperations.append(.floatExpression(
            FloatExpressionOperation(id: id, expression: expression, animationSpec: animationSpec)
        ))
    }
    
    public func componentValue(type: Int, componentId: Int, valueId: Int) {
        preludeOperations.append(.componentValue(
            ComponentValueOperation(type: type, componentId: componentId, valueId: valueId)
        ))
    }
    
    public func textFromFloat(
        textId: Int,
        value: RemoteFloat,
        digitsBefore: Int = 0,
        digitsAfter: Int = 2,
        flags: Int = 0
    ) {
        preludeOperations.append(.textFromFloat(TextFromFloatOperation(
            textId: textId, value: value, digitsBefore: digitsBefore, digitsAfter: digitsAfter, flags: flags
        )))
    }
    
    public func textMerge(textId: Int, sourceId1: Int, sourceId2: Int) {
        preludeOperations.append(.textMerge(
            TextMergeOperation(textId: textId, sourceId1: sourceId1, sourceId2: sourceId2)
        ))
    }
    
    public func textLookup(textId: Int, dataSetId: Int, index: RemoteFloat) {
        preludeOperations.append(.textLookup(
            TextLookupOperation(textId: textId, dataSetId: dataSetId, index: index)
        ))
    }
    
    public func paintData(_ paintBundle: [Int]) {
        PaintDataOperation(paintBundle: paintBundle).write(to: &out)
    }
    
    public func drawTextAnchored(
        textId: Int,
        x: RemoteFloat,
        y: RemoteFloat,
        panX: RemoteFloat = RemoteFloat(0),
        panY: RemoteFloat = RemoteFloat(0),
        flags: Int = 0
    ) {
        DrawTextAnchoredOperation(
            textId: textId, x: x, y: y, panX: panX, panY: panY, flags: flags
        ).write(to: &out)
    }
    
    @discardableResult
    public func drawTextAnchored(
        _ string: String,
        x: RemoteFloat,
        y: RemoteFloat,
        panX: RemoteFloat = RemoteFloat(0),
        panY: RemoteFloat = RemoteFloat(0),
        flags: Int = 0
    ) -> Int {
        let textId = registerText(string)
        drawTextAnchored(textId: textId, x: x, y: y, panX: panX, panY: panY, flags: flags)
        return textId
    }
    
    // MARK: Output
    
    public func build() -> Data {
        var w = WireWriter()
        HeaderOperation(width: width, height: height).write(to: &w)
        for entry in texts {
            TextDataOperation(textId: entry.id, text: entry.text).write(to: &w)
        }
        for list in idLists {
            list.write(to: &w)
        }
        for operation in preludeOperations {
            write(operation, to: &w)
        }
        let header = w.bytes
        return Data(header + out.bytes)
    }
    
    // MARK: Helpers
    
    private func newComponentId() -> Int {
        defer { nextComponentId += 1 }
        return nextComponentId
    }
    
    private func registerText(_ string: String) -> Int {
        let id = nextTextId
        nextTextId += 1
        texts.append((id: id, text: string))
        return id
    }
    
    private func write(_ operation: RemoteOperation, to writer: inout WireWriter) {
        switch operation {
        case .floatExpression(let value): value.write(to: &writer)
        case .componentValue(let value): value.write(to: &writer)
        case .textFromFloat(let value): value.write(to: &writer)
        case .textMerge(let value): value.write(to: &writer)
        case .textLookup(let value): value.write(to: &writer)
        default: break
        }
    }
    
    private func write(_ modifiers: [RemoteModifier]) {
        for modifier in modifiers {
            switch modifier {
            case .background(let op): op.write(to: &out)
            case .width(let op): op.write(to: &out)
            case .height(let op): op.write(to: &out)
            }
        }
    }
    
    private func wrapped(_ children: () -> Void) {
        if wrapChildrenInContent {
            LayoutContentOperation(componentId: newComponentId()).write(to: &out)
            children()
            out.start(OpCode.containerEnd)
        } else {
            children()
        }
    }
}
