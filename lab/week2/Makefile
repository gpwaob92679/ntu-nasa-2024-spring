all: debugger.sh.base64 debugger.sh.sha1sum
.PHONY: test clean

debugger.sh:
debugger.sh.base64: debugger.sh
	base64 debugger.sh | tee debugger.sh.base64
debugger.sh.sha1sum: debugger.sh
	sha1sum debugger.sh | tee debugger.sh.sha1sum

test:
	time ./debugger.sh gen.c sol.c wa.c 1000
clean:
	rm gen a b debugger.sh.base64 debugger.sh.sha1sum
