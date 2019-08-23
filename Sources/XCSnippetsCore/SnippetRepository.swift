 struct SnippetRepository: Codable {
    var title: String
    var path: String

    func display() -> String {
        return "\(path): \(title)"
    }
 }
