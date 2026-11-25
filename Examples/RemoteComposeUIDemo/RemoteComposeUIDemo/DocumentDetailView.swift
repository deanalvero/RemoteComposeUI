import SwiftUI
import RemoteComposeUI

struct DocumentDetailView: View {
    private enum Tab: String, CaseIterable, Identifiable {
        case preview = "Preview"
        case operations = "Operations"
        case tree = "Tree"
        var id: String { rawValue }
    }

    private enum LoadState {
        case loading
        case failed(String)
        case loaded(size: Int, document: RemoteDocument, firstBytes: String)
    }

    let item: DemoItem
    @State private var tab: Tab = .preview
    @State private var state: LoadState = .loading

    var body: some View {
        VStack(spacing: 0) {
            switch state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case let .failed(message):
                Text(message)
                    .foregroundStyle(.red)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case let .loaded(size, document, firstBytes):
                summary(size: size, document: document)
                if let problem = document.diagnostics.first {
                    banner(problem: problem, firstBytes: firstBytes)
                }
                Picker("View", selection: $tab) {
                    ForEach(Tab.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .padding(.horizontal)
                .padding(.bottom, 8)
                Divider()
                content(for: document)
            }
        }
        .navigationTitle(item.title)
        .task(id: item.id) { state = load() }
    }

    // MARK: Loading

    private func load() -> LoadState {
        do {
            let data = try item.load()
            let firstBytes = data.prefix(32).map { String(format: "%02X", $0) }.joined(separator: " ")
            return .loaded(size: data.count,
                           document: RemoteDocument.parseLenient(data),
                           firstBytes: firstBytes)
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    // MARK: Pieces

    private func summary(size: Int, document: RemoteDocument) -> some View {
        var parts = ["\(size) bytes"]
        if let h = document.header {
            parts.append("v\(h.majorVersion).\(h.minorVersion).\(h.patchVersion)")
            parts.append("\(h.width)×\(h.height)")
        } else {
            parts.append("no header decoded")
        }
        parts.append("\(document.operations.count) operations")
        parts.append("\(document.texts.count) strings")
        return Text(parts.joined(separator: " · "))
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .top])
            .padding(.bottom, 8)
    }

    private func banner(problem: RemoteComposeError, firstBytes: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Parsing stopped early")
                .font(.subheadline.weight(.semibold))
            Text("\(problem)")
                .font(.footnote)
            Text("First bytes: \(firstBytes)")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .textSelection(.enabled)
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.12))
    }

    @ViewBuilder
    private func content(for document: RemoteDocument) -> some View {
        switch tab {
        case .preview:
            preview(of: document)
        case .operations:
            monospaced(document.dumpOperations())
        case .tree:
            monospaced(document.dumpTree())
        }
    }

    private func preview(of document: RemoteDocument) -> some View {
        let width = CGFloat(document.header?.width ?? 0)
        let height = CGFloat(document.header?.height ?? 0)
        return ScrollView([.horizontal, .vertical]) {
            RemoteComposeView(document: document)
                .frame(width: width > 0 ? width : nil, height: height > 0 ? height : nil)
                .frame(minWidth: 280, minHeight: 200)
                .background(Color.white)
                .environment(\.colorScheme, .light)
                .overlay(Rectangle().stroke(Color.gray.opacity(0.4)))
                .padding()
        }
    }

    private func monospaced(_ text: String) -> some View {
        ScrollView {
            Text(text)
                .font(.system(.footnote, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
}
