import Foundation

class SnippetParser: NSObject {
    var snippet: Snippet = Snippet(title: "", id: "")
    
    var currentProperty: SnippetProperty?
    
    var currentElement: String = ""
    
    var currentTag: TagType?
    
    init(file: URL) {
        super.init()
        if let parser = XMLParser(contentsOf: file) {
            parser.delegate = self
            parser.parse()
        }
    }
}

extension SnippetParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "key" {
            currentTag = .key
        } else if elementName == "string" {
            currentTag = .value
        }
        currentElement = ""
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if currentTag == .key {
            if let property = SnippetProperty(rawValue: currentElement) {
                currentProperty = property
            } else {
                currentProperty = nil
            }
        } else if currentTag == .value, let property = currentProperty {
            snippet.set(property: property, with: currentElement)
        }
        currentElement = ""
        currentTag = nil
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (!data.isEmpty) {
            currentElement = currentElement + data
        }
    }
}

extension SnippetParser {
    enum TagType {
        case key
        case value
    }
}

enum SnippetProperty: String {
    case title = "IDECodeSnippetSummary"
    case id = "IDECodeSnippetIdentifier"
}

struct Snippet {
    var title: String
    var id: String
    
    mutating func set(property: SnippetProperty, with value: String) {
        switch property {
        case .id:
            id = value
        case .title:
            title = value
        }
    }
}
