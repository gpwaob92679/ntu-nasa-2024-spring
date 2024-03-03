SHELL = /bin/bash

test_files = dir1/.code.backup dir1/link1 dir1/link2 dir1/link3 dir1/link4 dir1/code/a.out dir1/code/output1.txt dir1/code/output2.txt dir1/code/output3.txt dir1/code/output4.txt dir1/hello.txt dir2/.code.backup dir2/link1 dir2/link2 dir2/link3 dir2/link4 dir2/code/a.out dir2/code/output1.txt dir2/code/output2.txt dir2/code/output3.txt dir2/code/output4.txt dir2/hi.txt

check: $(test_files)
	@if [[ ! -e output ]]; then \
	  mkdir output; \
	fi
	./check.sh

.PHONY: check clean gen_test clean_test

clean: clean_test
	rm -rf output

gen_test $(test_files) &:
	cd dir1; ./run.sh
	cd dir2; ./run.sh

clean_test:
	rm -rf $(test_files)
