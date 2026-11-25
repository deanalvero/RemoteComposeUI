import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selection: DemoItem.ID?
    @State private var opened: [DemoItem] = []
    @State private var showImporter = false
    @State private var errorMessage: String?

    private let builtIn = SampleCatalog.items
    private let bundled = BundledFiles.items()

    private var selectedItem: DemoItem? {
        (builtIn + bundled + opened).first { $0.id == selection }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section("Built-in samples") {
                    ForEach(builtIn) { item in
                        Label(item.title, systemImage: "square.grid.2x2")
                    }
                }
                if !bundled.isEmpty {
                    Section("Bundled .rc files") {
                        ForEach(bundled) { item in
                            Label(item.title, systemImage: "doc")
                        }
                    }
                }
                Section("Opened files") {
                    if opened.isEmpty {
                        Text("Use Open… or drop a .rc file here")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(opened) { item in
                            Label(item.title, systemImage: "doc")
                        }
                    }
                }
            }
            .navigationTitle("Remote Compose")
            .toolbar {
                ToolbarItem {
                    Button {
                        showImporter = true
                    } label: {
                        Label("Open .rc…", systemImage: "folder")
                    }
                }
            }
        } detail: {
            if let item = selectedItem {
                DocumentDetailView(item: item)
            } else {
                Text("Select a document")
                    .foregroundStyle(.secondary)
            }
        }
        .fileImporter(isPresented: $showImporter,
                      allowedContentTypes: [.data],
                      allowsMultipleSelection: true) { result in
            switch result {
            case let .success(urls): open(urls)
            case let .failure(error): errorMessage = error.localizedDescription
            }
        }
        .dropDestination(for: URL.self) { urls, _ in
            open(urls)
            return !urls.isEmpty
        }
        .alert("Couldn’t open file",
               isPresented: Binding(get: { errorMessage != nil },
                                    set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
        #if os(macOS)
        .onAppear {
            if selection == nil { selection = builtIn.first?.id }
        }
        #endif
    }

    private func open(_ urls: [URL]) {
        for url in urls {
            let scoped = url.startAccessingSecurityScopedResource()
            defer { if scoped { url.stopAccessingSecurityScopedResource() } }
            do {
                let data = try Data(contentsOf: url)
                let item = DemoItem(
                    id: "opened.\(UUID().uuidString)",
                    title: url.lastPathComponent,
                    load: { data }
                )
                opened.append(item)
                selection = item.id
            } catch {
                errorMessage = "\(url.lastPathComponent): \(error.localizedDescription)"
            }
        }
    }
}
