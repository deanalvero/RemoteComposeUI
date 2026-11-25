import Foundation
import RemoteComposeUI

enum SampleCatalog {
    static var items: [DemoItem] {
        [
            DemoItem(id: "sample.card", title: "Card", load: { card() }),
            DemoItem(id: "sample.text", title: "Text styles", load: { textStyles() }),
            DemoItem(id: "sample.rows", title: "Row arrangements", load: { rowArrangements() }),
            DemoItem(id: "sample.columns", title: "Column alignment", load: { columnAlignment() }),
            DemoItem(id: "sample.shapes", title: "Background shapes", load: { shapes() }),
        ]
    }

    private static func card() -> Data {
        let b = DocumentBuilder(width: 360, height: 480)
        b.root {
            b.column(spacedBy: 12, modifiers: [
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
        return b.build()
    }

    private static func textStyles() -> Data {
        let weights: [Float] = [100, 300, 400, 500, 700, 900]
        let b = DocumentBuilder(width: 360, height: 560)
        b.root {
            b.column(spacedBy: 6, modifiers: [
                .background(BackgroundModifierOperation(red: 0.97, green: 0.97, blue: 0.97)),
            ]) {
                for weight in weights {
                    b.text("Weight \(Int(weight))", fontSize: 20, fontWeight: weight)
                }
                b.text("Italic", fontSize: 20, italic: true)
                b.text("Serif", fontSize: 20, fontFamily: "serif")
                b.text("Monospace", fontSize: 20, fontFamily: "monospace")
                b.text("Colored text", color: 0xFFD81B60, fontSize: 20)
                b.text("Two lines at most: this sentence is deliberately long so that it has to be truncated with an ellipsis at the end.",
                       fontSize: 16, overflow: TextOverflow.ellipsis, maxLines: 2)
                b.text("One line, middle ellipsis: a very long single line of text that cannot possibly fit",
                       fontSize: 16, overflow: TextOverflow.middleEllipsis, maxLines: 1)
            }
        }
        return b.build()
    }

    private static func rowArrangements() -> Data {
        let chip = BackgroundModifierOperation(red: 0.2, green: 0.5, blue: 0.9)
        let dot = BackgroundModifierOperation(red: 0.9, green: 0.3, blue: 0.3, shapeType: ShapeType.circle)
        let track = BackgroundModifierOperation(red: 0.9, green: 0.9, blue: 0.9)
        let arrangements: [(String, Int)] = [
            ("start", Positioning.start),
            ("center", Positioning.center),
            ("end", Positioning.end),
            ("spaceBetween", Positioning.spaceBetween),
            ("spaceEvenly", Positioning.spaceEvenly),
            ("spaceAround", Positioning.spaceAround),
        ]
        let b = DocumentBuilder(width: 360, height: 640)
        b.root {
            b.column(spacedBy: 16) {
                for (title, positioning) in arrangements {
                    b.text(title, fontSize: 11, fontWeight: 600)
                    b.row(horizontal: positioning, vertical: Positioning.center, spacedBy: 4,
                          modifiers: [.background(track)]) {
                        b.text(" A ", color: 0xFFFFFFFF, modifiers: [.background(chip)])
                        b.text(" B ", color: 0xFFFFFFFF, fontSize: 22, modifiers: [.background(dot)])
                        b.text(" C ", color: 0xFFFFFFFF, modifiers: [.background(chip)])
                    }
                }
            }
        }
        return b.build()
    }

    private static func columnAlignment() -> Data {
        let alignments: [(String, Int)] = [
            ("start", Positioning.start),
            ("center", Positioning.center),
            ("end", Positioning.end),
        ]
        let b = DocumentBuilder(width: 360, height: 240)
        b.root {
            b.row(spacedBy: 12) {
                for (title, positioning) in alignments {
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
        return b.build()
    }

    private static func shapes() -> Data {
        let b = DocumentBuilder(width: 360, height: 240)
        b.root {
            b.column(spacedBy: 16, modifiers: [
                .background(BackgroundModifierOperation(red: 0.98, green: 0.96, blue: 0.9)),
            ]) {
                b.row(spacedBy: 12) {
                    b.text("  Rectangle  ", color: 0xFFFFFFFF, fontSize: 18,
                           modifiers: [
                            .background(BackgroundModifierOperation(red: 0.1, green: 0.5, blue: 0.9))
                           ]
                    )
                    b.text("  Circle  ", color: 0xFFFFFFFF, fontSize: 18,
                           modifiers: [
                            .background(
                                BackgroundModifierOperation(
                                    red: 0.9, green: 0.3, blue: 0.3,shapeType: ShapeType.circle
                                )
                            )
                           ]
                    )
                }
                b.row(spacedBy: 8) {
                    for i in 0..<5 {
                        let t = Float(i) / 4
                        b.text(" \(i + 1) ", color: 0xFFFFFFFF, fontSize: 20, fontWeight: 700,
                               modifiers: [
                                .background(
                                    BackgroundModifierOperation(
                                        red: t, green: 0.4, blue: 1 - t, shapeType: ShapeType.circle
                                    )
                                )
                               ]
                        )
                    }
                }
            }
        }
        return b.build()
    }
}
