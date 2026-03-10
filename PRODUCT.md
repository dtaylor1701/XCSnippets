I will read the `README.md` and `DESIGN.md` files to gather more context about the project's current functionality and vision before generating the `PRODUCT.md`.
# XCSnippets Product Manifesto

## Product Vision
To become the industry-standard tool for Xcode snippet management, enabling developers to seamlessly version-control, share, and synchronize their coding patterns across teams and machines.

## Core Objectives
*   **Decentralized Sharing:** Leverage Git as the primary distribution mechanism for code snippets.
*   **Zero Friction:** Provide a lightweight, dependency-free CLI that integrates directly into the developer's existing workflow.
*   **Organization at Scale:** Transform obscure UUID-based snippet files into a human-readable, searchable library.
*   **Consistency:** Ensure that every member of a development team has access to the same high-quality code patterns.

## The Problem
Xcode's native snippet management is localized and opaque. Snippets are stored in a deep Library folder with UUID filenames, making them nearly impossible to:
1.  Version control with Git.
2.  Share with teammates without manual file copying.
3.  Keep synchronized across multiple development machines.
4.  Identify or search for outside of the Xcode UI.

## Target Audience & User Personas

### 1. The Solo Indie Developer
*   **Persona:** Manages multiple Mac minis and MacBooks; wants their "boilerplate" to follow them everywhere.
*   **Need:** A simple way to "sync" snippets without relying on fragile cloud solutions.

### 2. The Engineering Lead
*   **Persona:** Responsible for code quality and consistency across a team of 10+ iOS engineers.
*   **Need:** A way to distribute "Official Team Snippets" (e.g., standard Unit Test templates, VIPER/Clean architecture boilerplate) to all onboarding developers.

### 3. The Open Source Contributor
*   **Persona:** Maintains a library or framework and wants to provide helper snippets to users.
*   **Need:** A standardized "install" command they can put in their project's README.

## Feature Roadmap

### Short-Term (The Foundation)
*   **Enhanced Error Feedback:** Improved diagnostics for network failures or Git permission issues.
*   **Private Repository Support:** Seamless integration with SSH keys and Personal Access Tokens (PATs) for internal team repos.
*   **Validation Suite:** A "lint" command to verify that `.codesnippet` files are valid XML before installation.

### Medium-Term (The Experience)
*   **Interactive Mode:** A TUI (Terminal User Interface) to browse and selectively install snippets from a repository.
*   **Snippet Export:** One-command export of local Xcode snippets into a Git-ready folder structure.
*   **Backup/Restore:** Automatic local backups of the `CodeSnippets` directory before any "Replace" (`-r`) operation.

### Long-Term (The Ecosystem)
*   **XCSnippets Registry:** A community-driven index of popular snippet collections (XCUITest, SwiftUI, Combine, etc.).
*   **GUI Companion:** A lightweight macOS Menu Bar app for developers who prefer a visual interface over the CLI.
*   **Xcode Extension:** Deep integration to allow "Save to XCSnippets" directly from the Xcode editor.

## Feature Prioritization
Our North Star is **Reliability**. Because XCSnippets modifies files in the `~/Library`, the core value lies in the safety of its operations. 
1.  **Safety First:** Features like "Replace" must be idempotent and non-destructive to unrelated snippets.
2.  **Speed:** The tool must remain a single, fast binary with zero external dependencies.
3.  **Readability:** The `rename` feature is core to the product's value, as it makes the filesystem reflect the developer's intent.

## Iteration Strategy
We follow a **"Developer-First"** feedback loop:
*   **Dogfooding:** Every feature is first used by the maintainers to manage their own production snippets.
*   **Issue-Driven Growth:** New flags and commands are prioritized based on common friction points reported in the GitHub community.
*   **CLI UX Research:** We observe how developers use other tools (like Homebrew or SwiftLint) to ensure XCSnippets feels "native" to the macOS terminal.

## Release & Onboarding
*   **The "One-Liner":** Our goal is a single-command installation (`curl | sh` or `brew install`).
*   **Discoverability:** The `-l` (list) flag acts as the primary onboarding tool, showing new users what is possible immediately after installation.
*   **Documentation:** Every release includes an updated `man` page to ensure offline-first support.

## Success Metrics (KPIs)
*   **Adoption Rate:** Number of unique GitHub repositories containing a "Snippets" folder that reference XCSnippets.
*   **Workflow Efficiency:** Reduction in time spent on manual snippet organization (measured qualitatively via user surveys).
*   **Binary Footprint:** Keeping the compiled tool under 5MB to ensure it remains a "utility," not a "dependency."

## Future Opportunities
*   **Cross-IDE Support:** Potential to bridge the gap between Xcode snippets and VS Code snippets for KMP (Kotlin Multiplatform) developers.
*   **AI Integration:** A "suggest" engine that can analyze a codebase and automatically generate a shared snippet library for common patterns.
