build:
	fennel --compile-binary vquery.fnl vquery /opt/homebrew/lib/liblua.a /opt/homebrew/include/lua5.4

install: build
	cp vquery ~/Library/bin
