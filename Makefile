bindir = /usr/local/bin

build:
	swift build -c release -Xswiftc -static-stdlib --disable-sandbox

install: build
	install ".build/release/XCSnippets" "$(bindir)"

uninstall:
	rm -rf "$(bindir)/XCSnippets"

clean:
	rm -rf .build

.PHONY: build install uninstall clean
