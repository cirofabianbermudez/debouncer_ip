
SRCS = rtl/debouncer.sv \
       tb/debouncer_if.sv \
       tb/tb.sv \
       tb/test.sv

all: format

format:
	verible-verilog-format --inplace $(SRCS)
