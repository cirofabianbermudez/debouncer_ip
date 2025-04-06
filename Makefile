ROOT_DIR := $(CURDIR)
RTL_DIR := $(ROOT_DIR)/hw/rtl
TB_DIR := $(ROOT_DIR)/hw/tb
FMT_DIR := $(ROOT_DIR)/fmt_log
RUN_DIR := $(ROOT_DIR)/work
CUR_DATE := $(shell date +%Y-%m-%d_%H-%M-%S)

RTL_FILES := $(shell find $(RTL_DIR) -name "*.sv" -or -name "*.v")
TB_FILES  := $(shell find $(TB_DIR) -name "*.sv" -or -name "*.v")

# Synopsys VCS/SIMV/VERDI
VCS := vcs -full64 -sverilog \
			-lca -debug_access+all+reverse -kdb +vcs+vcdpluson \
			-timescale=1ns/100ps $(TB_FILES) $(RTL_FILES) -l comp_$(CUR_DATE).log

SEED := 1

.PHONY: all check lint format format-check help vivado

all: help

# Linting and formatting
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

lint-verilator:
	@echo "Running Verilator linting tool"
	verilator --lint-only -Wall -sv $(RTL_FILES) || true

format-rtl: check
	@echo "Running Verible formatting tool for RTL [Inplace mode]"
	@cp -r $(RTL_DIR) $(FMT_DIR)/rtl_backup_$(CUR_DATE)
	@for file in $(RTL_FILES); do \
		echo " - Formatting $$file"; \
		verible-verilog-format --inplace $$file; \
	done

format-rtl-check: check
	@echo "Running Verible formatting tool for RTL [Check mode]"
	@cp -r $(RTL_DIR) $(FMT_DIR)/rtl_check_$(CUR_DATE)
	@files=$$(find $(FMT_DIR)/rtl_check_$(CUR_DATE) -name "*.sv" -or -name "*.v"); \
	for file in $$files; do \
		echo " - Formatting $$file"; \
		verible-verilog-format --inplace $$file; \
	done

format-tb: check
	@echo "Running Verible formatting tool for TB [Inplace mode]"
	@cp -r $(TB_DIR) $(FMT_DIR)/tb_backup_$(CUR_DATE)
	@for file in $(TB_FILES); do \
		echo " - Formatting $$file"; \
		verible-verilog-format --inplace $$file; \
	done

format-tb-check: check
	@echo "Running Verible formatting tool for TB [Check mode]"
	@cp -r $(TB_DIR) $(FMT_DIR)/tb_check_$(CUR_DATE)
	@files=$$(find $(FMT_DIR)/tb_check_$(CUR_DATE) -name "*.sv" -or -name "*.v"); \
	for file in $$files; do \
		echo " - Formatting $$file"; \
		verible-verilog-format --inplace $$file; \
	done
	
format: format-rtl format-tb

format-check: format-rtl-check format-tb-check

# Synopsys VCS/SIMV/VERDI
compile:
	@mkdir -p $(RUN_DIR)/sim
	cd $(RUN_DIR)/sim && $(VCS)

sim:
	cd $(RUN_DIR)/sim && ./simv +ntb_random_seed=$(SEED) -l simv_$(CUR_DATE).log

random:
	cd $(RUN_DIR)/sim && ./simv +ntb_random_seed_automatic -l simv_$(CUR_DATE).log

verdi:
	cd $(RUN_DIR)/sim && verdi -dbdir ./simv.daidir -ssf ./novas.fsdb -nologo &

clean:
	rm -rf $(RUN_DIR)

# Setup Vivado environment variables
vivado-run:
	#vivado -mode batch -source vivado/sim_script.tcl
	vivado -mode batch -source scripts/sim_script.tcl

vivado-create:
	vivado -mode batch -source scripts/vivado.tcl

vivado-clean:
	rm -rf *.log *.jou .Xil/ vivado/

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
