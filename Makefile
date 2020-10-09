.PHONY: test
test:
	for tb in test/* ; do echo $${tb%%.*}; python3 -m vhdeps -i vhlib -i component -i test ghdl $${tb%%.*} -w .; done
	for tb in test/schems/* ; do echo $${tb%%.*}; python3 -m vhdeps -i vhlib -i component -i test ghdl $${tb%%.*} -w .; done
