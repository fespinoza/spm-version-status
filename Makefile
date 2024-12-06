prefix ?= /usr/local
bindir = $(prefix)/bin

build:
	swift build -c release --disable-sandbox

install: build
	install -d "$(bindir)"
	install ".build/release/spm-version-status" "$(bindir)"

uninstall:
	rm -rf "$(bindir)/spm-version-status"

clean:
	rm -rf .build

.PHONY: build install uninstall clean
