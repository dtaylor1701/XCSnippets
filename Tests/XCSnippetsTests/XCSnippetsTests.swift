import XCTest
import class Foundation.Bundle

final class XCSnippetsTests: XCTestCase {
    func testNoArgumentsShowHelp() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.14, *) else {
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("XCSnippets")

        let process = Process()
        process.executableURL = fooBinary

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        XCTAssertTrue(output.contains("HELP"))
        XCTAssertTrue(output.contains("xcsnippets [-r] [repo]"))
        XCTAssertTrue(output.contains("incorrectArguments"))
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    func testHelpFlag() throws {
        guard #available(macOS 10.14, *) else {
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("XCSnippets")

        let process = Process()
        process.executableURL = fooBinary
        process.arguments = ["-h"]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        XCTAssertTrue(output.contains("HELP"))
        XCTAssertTrue(output.contains("xcsnippets [-r] [repo]"))
        XCTAssertFalse(output.contains("incorrectArguments"))
    }

    static var allTests = [
        ("testNoArgumentsShowHelp", testNoArgumentsShowHelp),
        ("testHelpFlag", testHelpFlag),
    ]
}
