.PHONY: test
test:
	#TESTS=($$(find  ./test -name "*_tc.vhd" 2>/dev/null))
	for tb in $$(find  ./test -name "*_tc.vhd"); do python3 -m vhdeps -i vhlib -i component -i test ghdl $$(basename -s .vhd $${tb}); done
	
	
	#find  ./test -name "*_tc.vhd" -exec echo {} \;
	#for tb in test/* ; do echo $${tb%%.*}; python3 -m vhdeps -i vhlib -i component -i test ghdl $${tb%%.*} -w .; done
	#for tb in test/schems/* ; do echo $${tb%%.*}; python3 -m vhdeps -i vhlib -i component -i test ghdl $${tb%%.*} -w .; done
