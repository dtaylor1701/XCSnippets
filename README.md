# XCSnippets
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdtaylor1701%2FXCSnippets%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/dtaylor1701/XCSnippets)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdtaylor1701%2FXCSnippets%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/dtaylor1701/XCSnippets)

XCSnippets is a command line utility for installing XCode snippets from git repositories.

## Brew installation

```
brew tap dtaylor1701/formulae
brew install xcsnippets
```

## Usage
```
xcsnippets username/repo
```

The above will get all codesnippets in the root of the github repository given and install them into the current user's xcode data.

Any git respository can be used by supplying the full path.
```
xcsnippets "https://github.com/dtaylor1701/XCUISnippets.git"
```

Use the -r flag to replace existing snippets of the same name. This is useful for installing updates to snippets that have already been downloaded.
```
xcsnippets -r "https://github.com/dtaylor1701/XCUISnippets.git"
```

### Other Functions

The `-n ` option will use the title of each snippet to name any unnamed files in the xcode snippets folder.
```
xcsnippets -n
```

To open the snippets folder, use `-o`
```
xcsnippets -o
```

A list of snippets is maintained [here](Collections/main.json). Take a look with `-l`. Please open a PR if you'd like to add a repo!
```
xcsnippets -l
```

