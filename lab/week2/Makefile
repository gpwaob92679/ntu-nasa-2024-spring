SHELL=/bin/bash

all: debugger.sh.base64 debugger.sh.sha1sum
.PHONY: run test clean

debugger.sh:
debugger.sh.base64: debugger.sh
	base64 debugger.sh | tee debugger.sh.base64
debugger.sh.sha1sum: debugger.sh
	sha1sum debugger.sh | tee debugger.sh.sha1sum

run:
	./debugger.sh gen.c sol.c wa.c 10
test:
	diff <(./debugger.sh gen.c sol.c wa.c 10) expected.txt
clean:
	rm -f gen a b in.txt out_a.txt out_b.txt debugger.sh.base64 \
	  debugger.sh.sha1sum
