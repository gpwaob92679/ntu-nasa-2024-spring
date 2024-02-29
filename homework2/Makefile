SHELL = /bin/bash

all: gen_test
.PHONY: all gen_test clean_test

gen_test:
	cd dir1; ./run.sh
	cd dir2; ./run.sh

clean_test:
	rm -f dir{1,2}/{link*,code/{a.out,output*.txt}}
	rm -r dir1/hello.txt
	rm -r dir2/hi.txt
	rm -rf dir{1,2}/.code.backup
