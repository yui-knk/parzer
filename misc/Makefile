BISON?=bison
TRACE?=none
REPORT?=none

parse.c: parse.y
	$(BISON) --trace=$(TRACE) --report=$(REPORT) -o parse.c parse.y

parse2.c: parse2.y
	$(BISON) --trace=$(TRACE) --report=$(REPORT) -o parse2.c parse2.y

parse3.c: parse3.y
	$(BISON) --trace=$(TRACE) --report=$(REPORT) -o parse3.c parse3.y
