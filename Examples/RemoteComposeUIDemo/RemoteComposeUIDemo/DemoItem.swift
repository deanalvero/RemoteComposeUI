import Foundation

struct DemoItem: Identifiable {
    let id: String
    let title: String
    let load: () throws -> Data
}

enum BundledFiles {
    static func items() -> [DemoItem] {
        let urls = Bundle.main.urls(forResourcesWithExtension: "rc", subdirectory: nil) ?? []
        return urls
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .map { url in
                DemoItem(
                    id: "bundled.\(url.lastPathComponent)",
                    title: url.lastPathComponent,
                    load: { try Data(contentsOf: url) }
                )
            }
    }
}
