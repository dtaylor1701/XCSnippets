import Foundation

@available(OSX 10.12, *)
public class SnippetManager {
    
    private let xcodeSnippetsPath = "/Library/Developer/Xcode/UserData/CodeSnippets"
    private let tempDirName = "TEMP_SNIPPETS"
    
    private let fileManager = FileManager.default
    
    private let arguments: [String]
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        guard arguments.count > 1 else {
            throw Error.incorrectArguments
        }
        
        guard let options = optionsFor(flags: arguments[1]) else {
            throw Error.incorrectArguments
        }
        
        let repoIndex = options.isEmpty ? 1 : 2
        let gitRepo = getRepoForArgument(arg: arguments[repoIndex])
        
        let snippetDir = fileManager.homeDirectoryForCurrentUser.appendingPathComponent(xcodeSnippetsPath)
        
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
        printLine("Getting Snippets from \(gitRepo)")
        let clone = Shell.execute("git", "clone", gitRepo, tempDir.path)
        if clone.status != 0 {
            try fileManager.removeItem(at: tempDir)
            throw Error.repoNotFound
        }
        printLine("Moving Snippets to XCode User Data")
        do {
            let files = try fileManager.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            let snippets = files.filter { (file) -> Bool in
                return file.pathExtension == "codesnippet"
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
        if !flags.contains("-") { return [] }
        for item in flags.filter({ $0 != "-" }) {
            if let option = Option(rawValue: item){
                options.append(option)
            } else {
                return nil
            }
        }
        return options
    }
    
    private func printLine(_ text: String) {
        print("~~~~~~~~~~\(text)")
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
    }
}
