import Foundation

@available(OSX 10.12, *)
public class SnippetManager {
    
    private let xcodeSnippetsPath = "Library/Developer/Xcode/UserData/CodeSnippets"
    private let tempDirName = "TEMP_SNIPPETS"
    private let snippetExtension = "codesnippet"
    
    private let fileManager = FileManager.default
    
    private let arguments: [String]
    
    private var snippetDir: URL {
        return fileManager.homeDirectoryForCurrentUser.appendingPathComponent(xcodeSnippetsPath)
    }
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        guard arguments.count > 1 else {
            printHelp()
            throw Error.incorrectArguments
        }
        
        let optionsString = arguments[1...].reduce("") { (res, next) -> String in
            if (next.first == "-") { return res + next.trimmingCharacters(in: ["-"]) }
            else { return res }
        }

        guard let options = optionsFor(flags: optionsString) else {
            throw Error.incorrectArguments
        }
        
        if options.contains(.help) {
            printHelp()
            return
        }

        if options.contains(.list) {
            printList()
            return
        }
        
        if !fileManager.fileExists(atPath: snippetDir.path) {
            do {
               try fileManager.createDirectory(at: snippetDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw Error.fileSystemFailure
            }
        }

        if options.contains(.open) {
            Shell.execute("open", snippetDir.absoluteString)
            return
        }
        
        if options.contains(.name) {
            try nameSnippets()
        }
        
        if let repoString = arguments[1...].last(where: { $0.first != "-" }) {
            let repo = getRepoForArgument(arg: repoString)
            try getSnippets(from: repo, with: options)
            return
        }
        
        if options.isEmpty {
            printHelp()
        }
    }
    
    private func getSnippets(from repo: String, with options: [Option]) throws {
        var tempDir = URL(fileURLWithPath: "")
        do {
            tempDir = try prepareTempDir()
        } catch {
            throw Error.fileSystemFailure
        }
        
        defer {
            printLine("Cleaning Up")
            try? fileManager.removeItem(at: tempDir)
        }
        printLine("Getting Snippets from \(repo)")
        let clone = Shell.execute("git", "clone", repo, tempDir.path)
        if clone.status != 0 {
            try fileManager.removeItem(at: tempDir)
            throw Error.repoNotFound
        }
        printLine("Moving Snippets to Xcode User Data")
        do {
            let files = try fileManager.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            let snippets = files.filter { (file) -> Bool in
                return file.pathExtension == snippetExtension
            }
            
            for snippet in snippets {
                let toPath = snippetDir.appendingPathComponent(snippet.lastPathComponent).path
                if fileManager.fileExists(atPath: toPath) {
                    if options.contains(.replace) {
                        try fileManager.removeItem(atPath: toPath)
                    } else {
                        continue
                    }
                }
                try fileManager.copyItem(atPath: snippet.path, toPath: toPath)
            }
        } catch {
            throw Error.fileSystemFailure
        }
        printLine("Restart Xcode to apply changes")
    }
    
    private func nameSnippets() throws {
        for file in try fileManager.contentsOfDirectory(at: snippetDir, includingPropertiesForKeys: nil) {
            let parser = SnippetParser(file: file)
            let snippet = parser.snippet

            if snippet.title != "" && snippet.id == file.deletingPathExtension().lastPathComponent {
                let name = snippet.title.split(separator: " ").reduce("", { $0 + $1.capitalized })
                let originPath = file
                var destinationPath = file.deletingLastPathComponent().appendingPathComponent(name).appendingPathExtension(snippetExtension)
                var suffix = 1
                while fileManager.fileExists(atPath: destinationPath.path) {
                    destinationPath = file.deletingLastPathComponent().appendingPathComponent(name + "\(suffix)").appendingPathExtension(snippetExtension)
                    suffix = suffix + 1
                }
                try fileManager.moveItem(at: originPath, to: destinationPath)
            }
        }
        printLine("Named snippets")
    }
    
    private func printHelp() {
        printLine("HELP")
        print("xcsnippets [-r] [repo]\n")
        print("xcsnippets [-hnlo]\n")
        for option in Option.allCases {
            print("\(option.description)\n")
        }
        print("\n Snippets are stored in \(snippetDir.path)\n")
    }
    
    private func prepareTempDir() throws -> URL  {
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(tempDirName + "\(UUID().uuidString)")
        try fileManager.createDirectory(atPath: tempDir.path, withIntermediateDirectories: true, attributes: nil)
        return tempDir
    }
    
    private func getRepoForArgument(arg: String) -> String {
        var gitRepo = arg
        
        if !gitRepo.contains("https://") {
            gitRepo = "https://github.com/" + gitRepo
        }
        
        if !gitRepo.contains(".git") {
            gitRepo = gitRepo + ".git"
        }
        
        return gitRepo
    }
    
    private func optionsFor(flags: String) -> [Option]? {
        var options: [Option] = []
        for item in flags {
            if let option = Option(rawValue: item){
                options.append(option)
            } else {
                return nil
            }
        }
        return options
    }
    
    private func printLine(_ text: String) {
        print("----------\(text)")
    }

    private func printList() {
        var finished = false
        let session = URLSession.shared
        let url = URL(string: "https://dtaylor1701.github.io/XCSnippets/Collections/main.json")!
        let task = session.dataTask(with: url) { (data, _, error) in
            if error == nil, let data = data, let list = try? JSONDecoder().decode([SnippetRepository].self, from: data) {
                self.printLine("Available Snippets \n")
                for item in list {
                    print(item.display())
                }
                print("\n")
            } else {
                self.printLine("Could not access snippet repository list")
            }
            finished = true
        }
        task.resume()
        while !finished {}
    }
}

@available(OSX 10.14, *)
public extension SnippetManager {
    enum Error: Swift.Error {
        case incorrectArguments
        case fileSystemFailure
        case repoNotFound
    }
}

@available(OSX 10.14, *)
public extension SnippetManager {
    enum Option: Character, CaseIterable {
        case replace = "r"
        case help = "h"
        case name = "n"
        case list = "l"
        case open = "o"

        var description: String {
            switch self {
            case .replace:
                return "-r   Replace existing snippets with the same name"
            case .help:
                return "-h   Help"
            case .name:
                return "-n   Name the snippets currently in the user data"
            case .list:
                return "-l   List a sample of available snippet repositories"
            case .open:
                return "-o   Open the snippets folder"
            }
        }
    }
}

