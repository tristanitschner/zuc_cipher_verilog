# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2025 Tristan Itschner
SRC += zuc_tb.v

SRC += ../../rtl/zuc.v
SRC += ../../rtl/zuc_s0.v
SRC += ../../rtl/zuc_s1.v

IFLAGS += -g2005-sv

VFLAGS += -fst

all: regression

%.ran: %.iv
	vvp $< $(VFLAGS)
	touch $@

zuc_tb.iv: $(SRC)
	iverilog $(IFLAGS) $(SRC) -o $@

define REGRESSION_TEMPLATE = 
REGRESSION_TARGETS += zuc_tb_t$(1)_tr$(2)_s$(3).ran
zuc_tb_t$(1)_tr$(2)_s$(3).iv: $$(SRC)
	iverilog $$(IFLAGS) $$(SRC) \
		-Pzuc_tb.testcase=$(1) \
		-Pzuc_tb.debug_trace=0 \
		-Pzuc_tb.toggle_reception=$(2) \
		-Pzuc_tb.sync=$(3) \
		-o $$@
endef

TESTCASES = 1 2 3 4
TOGGLES   = 0 1
SYNC      = 0 1

$(foreach testcase,$(TESTCASES), \
	$(foreach toggle,$(TOGGLES), \
		$(foreach sync,$(SYNC), \
			$(eval $(call REGRESSION_TEMPLATE,$(testcase),$(toggle),$(sync))) \
		) \
	) \
)

.PHONY: regression
regression: $(REGRESSION_TARGETS)

.PHONY: list
list:
	@echo $(REGRESSION_TARGETS)

.PHONY: clean
clean:
	$(RM) *.vcd
	$(RM) *.iv
	$(RM) *.ran
