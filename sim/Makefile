# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2025 Tristan Itschner
.PHONY: regression

regression: regression_zuc regression_zuc_eea3 regression_zuc_eia3

.PHONY: regression_zuc
regression_zuc:
	make -C zuc regression

.PHONY: regression_zuc_eea3
regression_zuc_eea3:
	make -C zuc_eea3 regression

.PHONY: regression_zuc_eia3
regression_zuc_eia3:
	make -C zuc_eia3 regression

.PHONY: clean
clean:
	make -C zuc clean
	make -C zuc_eea3 clean
	make -C zuc_eia3 clean
