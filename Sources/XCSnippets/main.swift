import XCSnippetsCore

if #available(OSX 10.14, *) {
    let manager = SnippetManager(arguments: ["","-l"])
    
    do {
        try manager.run()
    } catch {
        print("Hmm, something went wrong: \(error)")
    }
} else {
    print("macOS 10.14 or above is required.")
}


