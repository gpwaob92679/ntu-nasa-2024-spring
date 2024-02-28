SHELL=/bin/bash

all: debugger.sh.base64 debugger.sh.sha1sum
.PHONY: test clean

debugger.sh:
debugger.sh.base64: debugger.sh
	base64 debugger.sh | tee debugger.sh.base64
debugger.sh.sha1sum: debugger.sh
	sha1sum debugger.sh | tee debugger.sh.sha1sum

test:
	diff -s <(./debugger.sh gen.c sol.c wa.c 10) expected.txt
clean:
	rm -f gen a b in.txt debugger.sh.base64 debugger.sh.sha1sum
