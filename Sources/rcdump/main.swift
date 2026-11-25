import Foundation
import RemoteComposeUI

func printError(_ message: String) {
    FileHandle.standardError.write(Data((message + "\n").utf8))
}

func hex(_ data: Data, from start: Int, count: Int) -> String {
    let lo = max(0, start)
    let hi = min(data.count, start + count)
    guard lo < hi else { return "(none)" }
    return data[lo..<hi].map { String(format: "%02X", $0) }.joined(separator: " ")
}

func offset(of error: RemoteComposeError) -> Int? {
    switch error {
    case let .truncated(offset, _), let .unsupportedOperation(_, offset), let .invalidLength(offset, _):
        return offset
    case .compressedDocumentUnsupported:
        return nil
    }
}

let arguments = CommandLine.arguments
guard arguments.count == 2 else {
    printError("usage: rcdump <file.rc>")
    exit(64)
}

let url = URL(fileURLWithPath: NSString(string: arguments[1]).expandingTildeInPath)
let data: Data
do {
    data = try Data(contentsOf: url)
} catch {
    printError("cannot read \(url.path): \(error.localizedDescription)")
    exit(66)
}

print("file:        \(url.lastPathComponent) (\(data.count) bytes)")
print("first bytes: \(hex(data, from: 0, count: 48))")

let document = RemoteDocument.parseLenient(data)

if let header = document.header {
    print("header:      v\(header.majorVersion).\(header.minorVersion).\(header.patchVersion), "
          + "\(header.width) x \(header.height), capabilities \(header.capabilities)")
} else {
    print("header:      (none decoded)")
}
print("operations:  \(document.operations.count) decoded, \(document.texts.count) string(s)")

print("\n--- operations ---")
print(document.dumpOperations())
print("\n--- tree ---")
print(document.dumpTree())

if let problem = document.diagnostics.first {
    print("\nSTOPPED EARLY: \(problem)")
    if let at = offset(of: problem) {
        let before = min(at, 16)
        print("bytes \(at - before)..<\(at + 32) (the failing operation starts at the ◆ marker):")
        print("  \(hex(data, from: at - before, count: before)) ◆ \(hex(data, from: at, count: 32))")
    }
    exit(1)
}
print("\nOK: the whole file was decoded.")
