import Foundation

@available(OSX 10.12, *)
public class SnippetManager {
    
    private let xcodeSnippetsPath = "/Library/Developer/Xcode/UserData/CodeSnippets"
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
            if (next.first == "-") { return res + next.trimmingCharacters(in: ["-"])}
            else { return res }
        }

        guard let options = optionsFor(flags: optionsString) else {
            throw Error.incorrectArguments
        }
        
        if options.contains(.help) {
            printHelp()
            return
        }
        
        if options.contains(.name) {
            try nameSnippets()
        }
        
        if let repoString = arguments[1...].last(where: { !$0.contains("-")}) {
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
        printLine("Moving Snippets to XCode User Data")
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
        printLine("Restart XCode to apply changes")
    }
    
    private func nameSnippets() throws {
        printLine("Named snippets")
        
        for file in try fileManager.contentsOfDirectory(at: snippetDir, includingPropertiesForKeys: nil) {
            let parser = SnippetParser(file: file)
            let snippet = parser.snippet
            if snippet.title != "" && snippet.id == file.deletingPathExtension().lastPathComponent {
                let name = snippet.title.split(separator: " ").reduce("", { $0 + $1.capitalized })
                let originPath = file
                let destinationPath = file.deletingLastPathComponent().appendingPathComponent(name).appendingPathExtension(snippetExtension)
               try FileManager.default.moveItem(at: originPath, to: destinationPath)
            }
        }
    }
    
    private func printHelp() {
        printLine("HELP")
        print("xcsnippets [-hnr] [repo]\n")
        print("-h   Help\n")
        print("-n   Name the snippets currently in the user data\n")
        print("-r   Replace existing snippets with the same name\n")
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
        print("--------------------\(text)")
    }
}

@available(OSX 10.12, *)
public extension SnippetManager {
    enum Error: Swift.Error {
        case incorrectArguments
        case fileSystemFailure
        case repoNotFound
    }
}

@available(OSX 10.12, *)
public extension SnippetManager {
    enum Option: Character {
        case replace = "r"
        case help = "h"
        case name = "n"
    }
}

