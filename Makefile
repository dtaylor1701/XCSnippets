prefix ?= /usr/local
bindir = $(prefix)/bin/
mandir = $(prefix)/share/man/man1/

build:
	swift build -c release -Xswiftc -static-stdlib --disable-sandbox

install: build
	install ".build/release/xcsnippets" "$(bindir)"
	install "xcsnippets.1" "$(mandir)"

uninstall:
	rm -rf "$(bindir)xcsnippets"
	rm -rf "$(mandir)xcsnippets.1"

clean:
	rm -rf .build

.PHONY: build install uninstall clean
