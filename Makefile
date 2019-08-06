prefix ?= /usr/local
bindir = $(prefix)/bin/
mandir = $(prefix)/share/man/man1/

build:
	swift build -c release --disable-sandbox

install: build
	mkdir -p "$(bindir)" && install ".build/release/xcsnippets" "$(bindir)"
	mkdir -p "$(mandir)" && install "xcsnippets.1" "$(mandir)"

uninstall:
	rm -rf "$(bindir)xcsnippets"
	rm -rf "$(mandir)xcsnippets.1"

clean:
	rm -rf .build

.PHONY: build install uninstall clean
