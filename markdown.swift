// `@testable` needed to access `_data`
@testable import Markdown // This package: https://github.com/apple/swift-markdown

extension Markdown.Document {
    var html: String {
        var htmlFormatter = HTMLFormatter()
		htmlFormatter.visit(self)
        return htmlFormatter.output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var plainText: String {
        var plainTextFormatter = PlainTextFormatter()
		plainTextFormatter.visit(self)
        return plainTextFormatter.output
    }
}

/// Writes a Markdown document to HTML.
///
/// The primary goal is for output to match the output of Markdown.pl 1.0.1 as closely as possible.
/// <https://daringfireball.net/projects/markdown/>
///
/// Usage:
///
/// ```swift
/// let document = Document(parsing: "Convert *Markdown* to **HTML**.", options: [.disableSmartOpts])
/// var htmlFormatter = HTMLFormatter()
/// htmlFormatter.visit(document)
/// print(htmlFormatter.output) // <p>Convert <em>Markdown</em> to <strong>HTML</strong>.</p>
/// ```
///
/// Swift Markdown makes all quotation marks curly, but they shouldn’t be for foot and inch marks
/// so parse the document using the `.disableSmartOpts` option.
/// See <https://practicaltypography.com/foot-and-inch-marks.html>
///
/// Known discrepancies from Markdown.pl:
///
/// - All instances of > will be replaced with &gt instead of only some.
/// - Nested lists won’t include as many line breaks.
/// - There won’t be empty lines between multiple paragraphs in a list item.
struct HTMLFormatter: MarkupVisitor {
    var output = ""

    mutating func defaultVisit(_ markup: Markup) -> Void {
        let tag: String
        var attributes: [(name: String, value: String)] = []
        if markup is Strong {
            tag = "strong"
        } else if markup is Emphasis {
            tag = "em"
        } else if markup is Paragraph {
            tag = "p"
        } else if markup is Document {
            tag = "body"
        } else if markup is BlockQuote {
            tag = "blockquote"
        } else if markup is ListItem {
            tag = "li"
        } else if markup is OrderedList {
            tag = "ol"
        } else if markup is UnorderedList {
            tag = "ul"
        } else if let heading = markup as? Heading {
            precondition((1...6).contains(heading.level))
            tag = "h\(heading.level)"
        } else if let link = markup as? Link {
            if let destination = link.destination {
                attributes.append((name: "href", value: destination))
            }
            tag = "a"
        } else {
            fatalError("Unknown node: \(String(describing: type(of: markup)))")
        }

        let skipTag = markup is Paragraph && markup.parent is ListItem && (markup.parent!.parent! as! ListItemContainer).skipParagraphsInItems

        if !skipTag {
            output += "<\(tag)"
            for attribute in attributes {
                output += " \(attribute.name)=\"\(attribute.value.replacingWithHTMLEntities())\""
            }
            output += ">"

            if markup is ListItemContainer {
                output += "\n"
            }
            if markup is BlockQuote {
                // Indent only the first child of a blockquote to match Markdown.pl.
                output += "\n  "
            }
        }

        for child in markup.children {
            visit(child)
        }

        if markup is BlockQuote && output.last == "\n" {
            output.removeLast()
        }

        if !skipTag {
            output += "</\(tag)>"
            if markup is ListItem {
                output += "\n"
            } else if markup is BlockMarkup && !(markup is Paragraph && markup.parent is ListItem) {
                output += "\n\n"
            }
        }
    }

    mutating func visitDocument(_ document: Document) -> () {
        // Adding a <body> tag is usually not useful.
        for child in document.children {
            visit(child)
        }
    }

    mutating func visitImage(_ image: Image) -> () {
        var altText: String?
        for child in image.children {
            precondition(altText == nil, "Image node has too many children. Should just be one Text node.")
            altText = (child as! Text).string
        }

        output += "<img src=\"\(image.source ?? "")\" alt=\"\(altText ?? "")\" title=\"\(image.title ?? "")\" />"
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) -> () {
        for _ in inlineCode.children {
            fatalError("Inline code node should not have any children.")
        }

        output += "<code>\(inlineCode.code.replacingWithHTMLEntities())</code>"
    }

    mutating func visitText(_ markup: Text) -> Void {
        for _ in markup.children {
            fatalError("Text node should not have any children.")
        }

        output += markup.string.replacingWithHTMLEntities()
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> () {
        output += "<pre><code>\(codeBlock.code.replacingWithHTMLEntities())</code></pre>\n\n"
    }

    mutating func visitHTMLBlock(_ html: HTMLBlock) -> () {
        precondition(html.rawHTML.hasSuffix("\n"))

        // List taken from _HashHTMLBlocks in Markdown.pl
        let blockElements = [
            "p",
            "div",
            "h1",
            "h2",
            "h3",
            "h4",
            "h5",
            "h6",
            "blockquote",
            "pre",
            "table",
            "dl",
            "ol",
            "ul",
            "script",
            "noscript",
            "form",
            "fieldset",
            "iframe",
            "math",
        ]
        for blockElement in blockElements {
            if html.rawHTML.hasPrefix("<\(blockElement)") {
                output += "\(html.rawHTML.replacingOccurrences(of: "\t", with: "    "))\n"
                return
            }
        }

        // Otherwise it’s an inline element, so wrap it in a paragraph.
        var editableHTML = html.rawHTML
        editableHTML.removeLast()
        output += "<p>\(editableHTML.replacingOccurrences(of: "\t", with: "    "))</p>\n\n"
    }

    mutating func visitInlineHTML(_ html: InlineHTML) -> () {
        output += html.rawHTML
    }

    mutating func visitSoftBreak(_ softBreak: SoftBreak) -> () {
        // This seems to come up when there’s no empty line.
        output += "\n"
    }

    mutating func visitLineBreak(_ lineBreak: LineBreak) -> () {
        output += " <br />\n"
    }

    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> () {
        output += "<hr />\n\n"
    }
}

private extension String {
    func replacingWithHTMLEntities() -> String {
        self.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
        // With inputs that look very similar, Markdown.pl will usually replace > with the entity but sometimes won’t.
        // I don’t understand the implementation.
        // Mostly this entity should not be needed, but replace it anyway to be more similar to Markdown.pl.
            .replacingOccurrences(of: ">", with: "&gt;")
        // Like _Detab in Markdown.pl
            .replacingOccurrences(of: "\t", with: "    ")
    }
}

private extension ListItemContainer {

    /// Whether to ignore the `Paragraph` children of the `ListItem` children of this list.
    ///
    /// Swift Markdown always puts a `Paragraph` inside a `ListItem` even when there shouldn’t be one. Have to use internals to distinguish this case.
    ///
    /// This is not very robust.
    var skipParagraphsInItems: Bool {
        var lastStartLine: Int?
        var lineDifference: Int?
        // Enumerating all children results in quadratic complexity because this property will be read for each child.
        for child in children {
            let currentStartLine = child._data.range!.lowerBound.line
            if let lastStartLine {
                let currentLineDifference = currentStartLine - lastStartLine
                if let lineDifference {
                    if lineDifference != currentLineDifference {
                        return true
                    }
                } else {
                    lineDifference = currentLineDifference
                }
            }
            lastStartLine = currentStartLine
        }

        guard let lineDifference else {
            // Single item lists. Don’t include paragraph to match Markdown.pl.
            return true
        }

        return lineDifference == 1
    }
}

struct PlainTextFormatter: MarkupVisitor {
    var output = ""

    mutating func defaultVisit(_ markup: Markup) -> Void {
        for child in markup.children {
            visit(child)
        }
    }

    mutating func visitImage(_ image: Image) -> () {
        // Alt text is included as a Text child node. We don’t want to include this.
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) -> () {
        for _ in inlineCode.children {
            fatalError("Inline code node should not have any children.")
        }

        output += "\(inlineCode.code)"
    }

    mutating func visitText(_ markup: Text) -> Void {
        for _ in markup.children {
            fatalError("Text node should not have any children.")
        }

        output += markup.string
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> () {
        output += "\(codeBlock.code)"
    }

    mutating func visitHTMLBlock(_ html: HTMLBlock) -> () {
        fatalError("HTML blocks are not supported for plain text formatting.")
    }

    mutating func visitInlineHTML(_ html: InlineHTML) -> () {
        fatalError("Inline HTML is not supported for plain text formatting.")
    }

    mutating func visitLineBreak(_ lineBreak: LineBreak) -> () {
        output += "\n"
    }

    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> () {
        fatalError("Horizontal rules are not supported for plain text formatting.")
    }
}
