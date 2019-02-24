prefix ?= /usr/local
bindir = $(prefix)/bin/

build:
	swift build -c release -Xswiftc -static-stdlib --disable-sandbox

install: build
	install ".build/release/xcsnippets" "$(bindir)"

uninstall:
	rm -rf "$(bindir)/xcsnippets"

clean:
	rm -rf .build

.PHONY: build install uninstall clean
