ROOT_DIR := $(CURDIR)
RTL_DIR := $(ROOT_DIR)/hw/rtl
TB_DIR := $(ROOT_DIR)/hw/tb
FMT_DIR := $(ROOT_DIR)/fmt_log

RTL_FILES := $(shell find $(RTL_DIR) -name "*.sv" -or -name "*.v")
TB_FILES  := $(shell find $(TB_DIR) -name "*.sv" -or -name "*.v")

.PHONY: all check lint format format-check help

all: lint

check:
	@echo "RTL files:"
	@for file in $(RTL_FILES); do \
		echo " - $$file"; \
	done
	@echo "Testbench files:"
	@for file in $(TB_FILES); do \
		echo " - $$file"; \
	done
	@echo "Checking fmt_log/ directory"
	@if [ -d "$(FMT_DIR)" ]; then \
		echo " - fmt_log/ directory exists"; \
	else \
		echo " - fmt_log/ directory does not exists"; \
		mkdir -p $(FMT_DIR); \
		echo " - Creating fmt_log/ directory"; \
	fi

lint:
	@echo "Running Verible linting tool"
	@verible-verilog-lint $(RTL_FILES) $(TB_FILES) || true

format-rtl: check
	@echo "Running Verible formatting tool for RTL [Inplace mode]"
	@rm -rf $(FMT_DIR)/rtl_backup
	@cp -r $(RTL_DIR) $(FMT_DIR)/rtl_backup
	@for file in $(RTL_FILES); do \
		echo " - Formatting $$file"; \
		verible-verilog-format --inplace $$file; \
	done

format-rtl-check: check
	@echo "Running Verible formatting tool for RTL [Check mode]"
	@rm -rf $(FMT_DIR)/rtl_check
	@cp -r $(RTL_DIR) $(FMT_DIR)/rtl_check
	@files=$$(find $(FMT_DIR)/rtl_check -name "*.sv" -or -name "*.v"); \
	for file in $$files; do \
		echo " - Formatting $$file"; \
		verible-verilog-format --inplace $$file; \
	done

format-tb: check
	@echo "Running Verible formatting tool for TB [Inplace mode]"
	@rm -rf $(FMT_DIR)/tb_backup
	@cp -r $(TB_DIR) $(FMT_DIR)/tb_backup
	@for file in $(TB_FILES); do \
		echo " - Formatting $$file"; \
		verible-verilog-format --inplace $$file; \
	done

format-tb-check: check
	@echo "Running Verible formatting tool for TB [Check mode]"
	@rm -rf $(FMT_DIR)/tb_check
	@cp -r $(TB_DIR) $(FMT_DIR)/tb_check
	@files=$$(find $(FMT_DIR)/tb_check -name "*.sv" -or -name "*.v"); \
	for file in $$files; do \
		echo " - Formatting $$file"; \
		verible-verilog-format --inplace $$file; \
	done
	
format: format-rtl format-tb

format-check: format-rtl-check format-tb-check

help:
	@echo ""
	@echo "=================================================================="
	@echo "---------------------------- Targets -----------------------------"
	@echo "  all            : Run lint"
	@echo "  check          : Display list of RTL and testbench files"
	@echo "  lint           : Run Verible linter on RTL and TB"
	@echo "  format         : Run Verible formatter on RTL and TB"
	@echo "  format-check   : Run Verible formatter on RTL and TB in check mode"
	@echo "  help           : Display this help message"
	@echo "=================================================================="
	@echo ""	
