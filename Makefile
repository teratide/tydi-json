.PHONY: test
test:
	for tb in $$(find  ./test -name "*_tc.vhd"); do python3 -m vhdeps -i vhlib -i component -i test ghdl $$(basename -s .vhd $${tb}); done
testnest:
	for tb in $$(find  ./test -name "*ested*_tc.vhd"); do python3 -m vhdeps -i vhlib -i component -i test ghdl $$(basename -s .vhd $${tb}); done