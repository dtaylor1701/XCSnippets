import Foundation

public struct ShellResult {
    var status: Int32
    var output: String?
    
    func printOutput() {
        print("Output: \(output ?? "no output")")
    }
}

public class Shell {
    @discardableResult
    static func execute(_ args: String...) -> ShellResult {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        task.launch()
        
        let outData = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outData, encoding: String.Encoding.utf8)
        task.waitUntilExit()
        return ShellResult(status: task.terminationStatus, output: output)
    }
}

