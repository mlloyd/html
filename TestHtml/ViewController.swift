//
//  ViewController.swift
//  TestHtml
//
//  Created by Martin Lloyd on 11/12/2024.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        view.addSubview(label)

        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20).isActive = true
        view.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true

        let html = """
        hello <b>world</b> \nmartin \n\nhello <b>world</b> 
        """

        label.attributedText = HTMLToAttributedStringParser.parse(html: html)
    }
}

class HTMLToAttributedStringParser {

    // Supported HTML tags and their corresponding attributes
    enum HTMLTag: String {
        case bold = "b"
        case italic = "i"
        case underline = "u"

        func attribute(for font: UIFont) -> [NSAttributedString.Key: Any] {
            switch self {
            case .bold:
                return [.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
            case .italic:
                return [.font: UIFont.italicSystemFont(ofSize: font.pointSize)]
            case .underline:
                return [.underlineStyle: NSUnderlineStyle.single.rawValue]
            }
        }
    }

    static func parse(html: String, baseFont: UIFont = UIFont.systemFont(ofSize: 20)) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(string: html)

        // Process tags with a regular expression
        let regex = try! NSRegularExpression(pattern: "<(/?\\w+)>", options: [])
        let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))

        // Process matches in reverse to maintain string integrity
        for match in matches.reversed() {
            guard let tagRange = Range(match.range(at: 1), in: html) else { continue }
            let tag = String(html[tagRange])

            // Find corresponding start and end tags
            if let htmlTag = HTMLTag(rawValue: tag.replacingOccurrences(of: "/", with: "")),
               tag.hasPrefix("/") { // Closing tag
                guard let startTagRange = findOpeningTag(html: html, closingTagRange: match.range, tag: htmlTag.rawValue) else { continue }

                let startIndex = html.index(html.startIndex, offsetBy: startTagRange.lowerBound)
                let endIndex = html.index(html.startIndex, offsetBy: match.range.lowerBound)
                let contentRange = NSRange(startIndex..<endIndex, in: html)

                // Apply attributes
                let attributes = htmlTag.attribute(for: baseFont)
                mutableAttributedString.addAttributes(attributes, range: contentRange)

                // Remove start and end tags
                mutableAttributedString.replaceCharacters(in:match.range , with: "")

                mutableAttributedString.replaceCharacters(in: startTagRange, with: "")
            }
        }

        return mutableAttributedString
    }

    // Find the corresponding opening tag for a closing tag
    private static func findOpeningTag(html: String, closingTagRange: NSRange, tag: String) -> NSRange? {
        let regex = try! NSRegularExpression(pattern: "<\(tag)>", options: [])
        let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: closingTagRange.lowerBound))
        return matches.last?.range
    }
}
