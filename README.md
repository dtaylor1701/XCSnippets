I will read the `Package.swift` file to identify the project's dependencies and structure.

I will read the `Sources/XCSnippets/main.swift` file to understand the CLI's interface and usage.

I will read the `Sources/XCSnippetsCore/SnippetManager.swift` file to understand the core functionality and commands of the `SnippetManager`.

I will read the `Makefile` to determine the installation instructions for the project.

I will read the `Collections/main.json` file to see the sample snippet repository list.

I will read the `xcsnippets.1` man page to see if it provides any additional details for the documentation.

# XCSnippets

**XCSnippets** is a command-line tool designed to help iOS and macOS developers manage their Xcode code snippets using Git repositories. It allows you to easily install, update, and organize snippets across multiple machines.

## Features

- **Fetch from Git:** Download and install snippets directly from any Git repository (defaults to GitHub if only a handle/repo is provided).
- **Update/Replace:** Use the `-r` flag to overwrite existing snippets with updated versions from a repository.
- **Auto-Naming:** Automatically rename snippet files in your local directory from their default UUID-based names to human-readable titles.
- **Quick Access:** Quickly open the Xcode `CodeSnippets` directory in Finder.
- **Sample Collections:** Access a curated list of sample snippet repositories.

## Installation

### Prerequisites

- macOS 10.14 or later
- Xcode and Swift (built using Swift Package Manager)
- Git

### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/dtaylor1701/XCSnippets.git
   cd XCSnippets
   ```

2. Build and install using the included Makefile:
   ```bash
   make install
   ```
   This will install the `xcsnippets` binary to `/usr/local/bin/` and its man page to `/usr/local/share/man/man1/`.

## Usage

### Basic Commands

- **Install snippets from a GitHub repository:**
  ```bash
  xcsnippets dtaylor1701/XCUISnippets
  ```

- **Install snippets from any Git repository:**
  ```bash
  xcsnippets https://github.com/user/my-snippets.git
  ```

- **Replace existing snippets with the same name:**
  ```bash
  xcsnippets -r dtaylor1701/XCUISnippets
  ```

### Options

| Option | Description |
| :--- | :--- |
| `-h` | Show help information. |
| `-l` | List a sample of available snippet repositories. |
| `-n` | Rename current snippets in the Xcode folder based on their titles. |
| `-o` | Open the Xcode snippets folder in Finder. |
| `-r` | Replace existing snippets with the same name when fetching. |

## Project Structure

- **Sources/XCSnippets**: The CLI entry point and argument parsing.
- **Sources/XCSnippetsCore**: The core logic for managing snippets, interacting with the file system, and executing shell commands.
- **Collections**: A local reference for sample snippet repositories.
- **Tests**: Unit tests for the core functionality.

## Dependencies

XCSnippets is built using the Swift Package Manager and has no external library dependencies, keeping it lightweight and fast.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author

**David Taylor**  
[dktaylor1701@gmail.com](mailto:dktaylor1701@gmail.com)
