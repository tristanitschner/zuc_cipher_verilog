# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2025 Tristan Itschner
SRC += zuc_eia3_tb.v

SRC += ../../rtl/zuc_eia3.v
SRC += ../../rtl/zuc.v
SRC += ../../rtl/zuc_ctl.v
SRC += ../../rtl/zuc_dw.v
SRC += ../../rtl/zuc_s0.v
SRC += ../../rtl/zuc_s1.v
SRC += ../../rtl/zuc_regslice.v
SRC += ../../rtl/zuc_regslice_chain.v

IFLAGS += -g2005-sv

VFLAGS += -fst

all: regression

%.ran: %.iv
	vvp $< $(VFLAGS)
	touch $@

zuc_eia3_tb.iv: $(SRC)
	iverilog $(IFLAGS) $(SRC) -o $@

define REGRESSION_TEMPLATE = 
REGRESSION_TARGETS += zuc_eia3_tb_t$(1)_ts$(2)_tr$(3)_s$(4).ran
zuc_eia3_tb_t$(1)_ts$(2)_tr$(3)_s$(4).iv: $$(SRC)
	iverilog $$(IFLAGS) $$(SRC) \
		-Pzuc_eia3_tb.testcase=$(1) \
		-Pzuc_eia3_tb.debug_trace=0 \
		-Pzuc_eia3_tb.debug_output=0 \
		-Pzuc_eia3_tb.toggle_sending=$(2) \
		-Pzuc_eia3_tb.toggle_reception=$(3) \
		-Pzuc_eia3_tb.sync=$(4) \
		-o $$@
endef

TESTCASES = 1 2 3 4 5
TOGGLES_TX = 0 1
TOGGLES_RX = 0 1
SYNC = 0 1

$(foreach testcase,$(TESTCASES), \
	$(foreach toggle_tx,$(TOGGLES_TX), \
		$(foreach toggle_rx,$(TOGGLES_RX), \
			$(foreach sync,$(SYNC), \
				$(eval $(call REGRESSION_TEMPLATE,$(testcase),$(toggle_tx),$(toggle_rx),$(sync))) \
			) \
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
