#if canImport(SwiftUI) && DEBUG
import SwiftUI

enum SampleDocuments {
    static func card() -> RemoteDocument {
        let b = DocumentBuilder(width: 360, height: 640)
        b.root {
            b.column(horizontal: Positioning.start, spacedBy: 12, modifiers: [
                .background(BackgroundModifierOperation(red: 0.93, green: 0.95, blue: 1.0)),
            ]) {
                b.text("Remote Compose → SwiftUI", color: 0xFF1A237E, fontSize: 24, fontWeight: 700)
                b.text("A long line of body text that should wrap onto several lines when the container is narrow.",
                       color: 0xFF37474F, fontSize: 15)
                b.text("Italic serif, two lines max, ellipsis in the middle of a long string of text",
                       color: 0xFF6A1B9A, fontSize: 14, italic: true, fontFamily: "serif",
                       overflow: TextOverflow.middleEllipsis, maxLines: 2)
                b.text("monospace", fontSize: 13, fontFamily: "monospace")
            }
        }
        return try! RemoteDocument.parse(b.build())
    }
    
    static func rowArrangements() -> RemoteDocument {
        let chip = BackgroundModifierOperation(red: 0.2, green: 0.5, blue: 0.9)
        let dot = BackgroundModifierOperation(red: 0.9, green: 0.3, blue: 0.3, shapeType: ShapeType.circle)
        let b = DocumentBuilder(width: 360, height: 640)
        b.root {
            b.column(spacedBy: 16) {
                for (title, positioning) in [
                    ("start", Positioning.start),
                    ("center", Positioning.center),
                    ("end", Positioning.end),
                    ("spaceBetween", Positioning.spaceBetween),
                    ("spaceEvenly", Positioning.spaceEvenly),
                    ("spaceAround", Positioning.spaceAround),
                ] {
                    b.text(title, fontSize: 11, fontWeight: 600)
                    b.row(horizontal: positioning, vertical: Positioning.center, spacedBy: 4,
                          modifiers: [.background(BackgroundModifierOperation(red: 0.9, green: 0.9, blue: 0.9))]) {
                        b.text(" A ", color: 0xFFFFFFFF, modifiers: [.background(chip)])
                        b.text(" B ", color: 0xFFFFFFFF, fontSize: 22, modifiers: [.background(dot)])
                        b.text(" C ", color: 0xFFFFFFFF, modifiers: [.background(chip)])
                    }
                }
            }
        }
        return try! RemoteDocument.parse(b.build())
    }
    
    static func columnAlignment() -> RemoteDocument {
        let b = DocumentBuilder(width: 360, height: 640)
        b.root {
            b.row(spacedBy: 12) {
                for (title, positioning) in [
                    ("start", Positioning.start), ("center", Positioning.center), ("end", Positioning.end),
                ] {
                    b.column(horizontal: positioning, spacedBy: 6, modifiers: [
                        .background(BackgroundModifierOperation(red: 0.95, green: 0.9, blue: 0.8)),
                    ]) {
                        b.text(title, fontWeight: 700)
                        b.text("short")
                        b.text("a bit longer")
                    }
                }
            }
        }
        return try! RemoteDocument.parse(b.build())
    }
}
#endif
