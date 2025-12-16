##=============================================================================
## [Filename]       Makefile.vcs
## [Project]        matt_protocol_uvc
## [Author]         Ciro Bermudez - cirofabian.bermudezmarquez@ba.infn.it
## [Language]       GNU Makefile
## [Created]        Nov 2024
## [Modified]       -
## [Description]    gpio_uvc Makefile for testing the UVC
## [Notes]          -
## [Status]         stable
## [Revisions]      -
##=============================================================================

# ===============================  VARIABLES  =================================

# Miscellaneous variables
CUR_DATE   := $(shell date +%Y-%m-%d_%H-%M-%S)

# Directories
GIT_DIR     := $(shell git rev-parse --show-toplevel)
ROOT_DIR    := $(CURDIR)
WORK_DIR    := $(ROOT_DIR)/work
RUN_DIR     := $(WORK_DIR)/sim
LOGS_DIR    := $(WORK_DIR)/logs
SCRIPTS_DIR := $(GIT_DIR)/scripts
TCL_DIR     := $(SCRIPTS_DIR)
RTL_DIR     := $(GIT_DIR)/hw/rtl
TB_DIR      := $(GIT_DIR)/hw/tb

# Files
HDL_FILE ?=

# Verilog/SystemVerilog
RTL_VLOG_SOURCES := $(RTL_DIR)/debouncer.sv
SIM_VLOG_SOURCES := $(TB_DIR)/test.sv $(TB_DIR)/debouncer_if.sv $(TB_DIR)/tb.sv
VLOG_DEFINES     :=

# VHDL
RTL_VHDL_SOURCES := 
SIM_VHDL_SOURCES := 

# Group together
VLOG_SOURCES := $(RTL_VLOG_SOURCES) $(SIM_VLOG_SOURCES)
VHDL_SOURCES := $(RTL_VHDL_SOURCES) $(SIM_VHDL_SOURCES)

# Simulation Variables
RTL_TOP_MODULE := debouncer
SIM_TOP_MODULE := tb

# ================================  CONTROL  ==================================

# Simulation mode
MODE ?= batch

# Export Working directory
export WORK_DIR

# Export simulation variables
export RTL_TOP_MODULE
export SIM_TOP_MODULE

# Export single file
ifneq ($(HDL_FILE),)
	export HDL_FILE
endif

# Export Verilog/SystemVerilog defines
ifneq ($(strip $(VLOG_DEFINES)),)
	export VLOG_DEFINES
endif

# Export Verilog/SystemVerilog sources
ifneq ($(strip $(VLOG_SOURCES)),)
	export VLOG_SOURCES
endif

# Export VHDL sources
ifneq ($(strip $(VHDL_SOURCES)),)
	export VHDL_SOURCES
endif

# Export IPS sources
ifneq ($(strip $(IPS_SOURCES)),)
	export IPS_SOURCES
endif

# ==============================  TOOLS SETUP  ================================

# Colors
C_RED := \033[31m
C_GRE := \033[32m
C_BLU := \033[34m
C_YEL := \033[33m
C_ORA := \033[38;5;214m
NC    := \033[0m 

# ================================  TARGETS  ==================================

SHELL := bash
.DEFAULT_GOAL := all

.PHONY: all
all: help
#______________________________________________________________________________

.PHONY: vars
vars: ## Print Makefile variables
	@echo ""
	@echo -e "$(C_ORA)Miscellaneous variables...$(NC)"
	@echo "CUR_DATE    = $(CUR_DATE)"
	@echo ""
	@echo -e "$(C_ORA)Directory variables...$(NC)"
	@echo "GIT_DIR     = $(GIT_DIR)"
	@echo "ROOT_DIR    = $(ROOT_DIR)"
	@echo "RUN_DIR     = $(RUN_DIR)"
	@echo "LOGS_DIR    = $(LOGS_DIR)"
	@echo "SCRIPTS_DIR = $(SCRIPTS_DIR)"
	@echo "RTL_DIR     = $(RTL_DIR)"
	@echo "TB_DIR      = $(TB_DIR)"
	@echo ""
	@echo -e "$(C_ORA)Variables...$(NC)"
	@echo "GUI_MODE    = $(GUI_MODE)"
	@echo "RUN_FLAGS   = $(RUN_FLAGS)"
	@echo ""
#______________________________________________________________________________

.PHONY: compile
compile: ## Parse and compile RTL and simulation sources
	@echo -e "$(C_ORA)Compiling project$(NC)"
	@mkdir -p $(RUN_DIR) $(LOGS_DIR)
	@tclsh $(TCL_DIR)/sim/compile.tcl $@ || true
#______________________________________________________________________________

.PHONY: elaborate
elaborate: ## Elaborate the design
	@echo -e "$(C_ORA)Elaborating the design$(NC)"
	@tclsh $(TCL_DIR)/sim/elaborate.tcl $@ || true
#______________________________________________________________________________

.PHONY: simulate
simulate: ## Simulate the design
	@echo -e "$(C_ORA)Simulating the design$(NC)"
	@tclsh $(TCL_DIR)/sim/simulate.tcl $@ $(MODE) || true
#______________________________________________________________________________

.PHONY: clean
clean: ## Remove all simulation files
	@echo -e "$(C_ORA)Removing all simulation files$(NC)"
	rm -rf $(WORK_DIR)
#______________________________________________________________________________

.PHONY: clean
clean-logs: ## Remove logs
	@echo -e "$(C_ORA)Removing all logs files$(NC)"
	rm -rf $(LOGS_DIR)/*
#______________________________________________________________________________


.PHONY: help
help: ## Displays help message
	@echo ""
	@echo "======================================================================"
	@echo ""
	@echo "Usage: make <target> <variables>"
	@echo ""
	@echo "--------------------------- Targets ----------------------------------"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "- make \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "--------------------------- Variables -------------------------------"
	@echo ""
	@echo "-------------------------- Variable Values --------------------------"
	@echo ""
	@echo "======================================================================"
	@echo ""
