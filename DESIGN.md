I will begin by reading the `Package.swift` and `README.md` files to understand the project's technical stack and intended purpose.
I will read `SnippetParser.swift` and `SnippetManager.swift` to better understand the data models and core logic for the design documentation.
I will read `SnippetRepository.swift` to confirm the data model for the snippet collection before finalizing the `DESIGN.md`.
# XCSnippets Design Documentation

## Overview
**XCSnippets** is a macOS command-line tool designed to streamline the management of Xcode code snippets. It allows developers to synchronize, update, and organize snippets using Git repositories, addressing the challenge of sharing and version-controlling snippets across different development environments.

## Architecture & System Design
The project follows a modular architecture, separating the command-line interface from the core business logic to ensure testability and maintainability.

### High-Level Architecture
- **XCSnippets (CLI Layer):** The entry point of the application. It handles process arguments and delegates execution to the core layer.
- **XCSnippetsCore (Logic Layer):** Contains the engine for snippet management, including filesystem interactions, Git operations, and snippet metadata parsing.
- **Data Layer:** Handles the representation of snippets and remote repositories.

### Design Principles
- **Minimalism:** The tool is built with zero external dependencies, leveraging only Apple's Foundation framework.
- **Surgical Operations:** File operations (cloning, moving, renaming) are performed with careful consideration of existing user data, providing options for replacement or preservation.
- **Convention over Configuration:** Sensible defaults are provided (e.g., GitHub as the default Git host) to reduce user friction.

## Technical Stack
- **Language:** Swift 5.0+
- **Platform:** macOS 10.14+
- **Build System:** Swift Package Manager (SPM)
- **Dependency Management:** None (Native Foundation only)
- **Tooling:** `Makefile` for automated building, testing, and system-wide installation.

## Data Models
### Snippet
Represents a single Xcode snippet file (`.codesnippet`).
- `title`: The human-readable name of the snippet (extracted from `IDECodeSnippetSummary`).
- `id`: The unique identifier (extracted from `IDECodeSnippetIdentifier`).

### SnippetRepository
Represents a collection of snippets hosted in a Git repository.
- `title`: A descriptive name for the collection.
- `path`: The Git URL or GitHub repository handle.

## Key Components & Interactions
### SnippetManager
The central orchestrator of the system.
- **Responsibilities:** Argument parsing, directory validation, Git cloning management, and coordinating snippet transfers.
- **Workflow:**
    1. Parse CLI flags and arguments.
    2. Prepare the local Xcode snippet directory (`~/Library/Developer/Xcode/UserData/CodeSnippets`).
    3. Clone remote repositories into a temporary directory using `Shell`.
    4. Filter and copy `.codesnippet` files to the target directory.
    5. Clean up temporary artifacts.

### SnippetParser
A specialized parser for Xcode's snippet format.
- **Mechanism:** Implements `XMLParserDelegate` to extract metadata from the Plist-based `.codesnippet` XML structure.
- **Usage:** Primarily used during the "renaming" operation to map obscure UUID filenames back to human-readable titles.

### Shell
A lightweight wrapper around `Process`.
- **Functionality:** Executes system commands like `git clone` and `open`.
- **Impact:** Decouples the core logic from the specific CLI commands used for system interaction.

## Technical Specifications
### Error Handling
XCSnippets uses a custom `Error` enum to categorize failures:
- `incorrectArguments`: Validation failure for CLI input.
- `fileSystemFailure`: Permission or IO issues during file manipulation.
- `repoNotFound`: Failure during Git operations.

### Concurrency Model
- **CLI Execution:** Primarily synchronous to ensure predictable command-line behavior.
- **Remote Fetching:** Uses `URLSession` for network requests (e.g., fetching the sample repository list), synchronized via `DispatchSemaphore` to maintain the synchronous CLI execution flow.

### State Management
The tool is stateless between executions. It relies on the current state of the filesystem (Xcode's UserData directory) and the provided CLI arguments.

## Testing Strategy
The project employs a comprehensive testing strategy focused on the core logic:
- **Unit Testing:** Validates `SnippetParser` accuracy and `SnippetManager` logic using `XCTest`.
- **Integration Testing:** Tests the interaction between the tool and the local filesystem (mocked or sandboxed where possible).
- **Manual Verification:** Ensured via the `Makefile` which includes build and install checks.

## Security & Performance
- **Security:** Git operations are delegated to the system's `git` binary, inheriting the user's existing SSH/HTTPS credentials and security configurations.
- **Performance:**
    - Minimal binary size due to lack of external dependencies.
    - Efficient file operations using `FileManager`'s native copy/move APIs.
    - Temporary directories are used for all staging operations to prevent data corruption.
- **Persistence:** Direct integration with Xcode's native storage path ensures immediate availability of snippets upon Xcode restart.
