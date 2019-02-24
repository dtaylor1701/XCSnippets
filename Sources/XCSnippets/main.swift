import XCSnippetsCore

if #available(OSX 10.12, *) {
    let manager = SnippetManager()
    
    do {
        try manager.run()
    } catch {
        print("Hmm, something went wrong: \(error)")
    }
} else {
    print("macOS 10.12 or above is required.")
}


