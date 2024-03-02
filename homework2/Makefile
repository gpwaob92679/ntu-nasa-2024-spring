SHELL = /bin/bash

test_files = dir1/link1 dir1/link2 dir1/link3 dir1/code/a.out dir1/code/output1.txt dir1/code/output2.txt dir1/hello.txt dir2/link1 dir2/link2 dir2/link3 dir2/code/a.out dir2/code/output1.txt dir2/code/output2.txt dir2/hi.txt
test_files_dir = dir1/.code.backup dir2/.code.backup

test: $(test_files) $(test_files_dir)
	@if [[ ! -e output ]]; then \
	  mkdir output; \
	fi

	./sample.sh

# Exit after first difference.
	@set -e; \
	for f in output_expected/*.txt; do \
	  echo "Testing "$$(basename "$${f}")""; \
		diff -s "$${f}" "$${f/_expected/}"; \
	done

.PHONY: test clean gen_test clean_test

clean: clean_test
	rm -rf output

gen_test $(test_files) $(test_files_dir) &:
	cd dir1; ./run.sh
	cd dir2; ./run.sh

clean_test:
	rm -f $(test_files)
	rm -rf $(test_files_dir)
