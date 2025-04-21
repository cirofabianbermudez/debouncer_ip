##=============================================================================
## [Filename]       probe.tcl
## [Project]        -
## [Author]         Ciro Bermudez - cirofabian.bermudez@gmail.com
## [Language]       GNU Makefile
## [Created]        Nov 2024
## [Modified]       -
## [Description]    Custom Tcl script to PROBE simulation
## [Notes]          -
## [Status]         stable
## [Revisions]      -
##=============================================================================

# ============================ WAVEFORMS PROBING ============================= #

# Dump all HDL signals and objects to binary Waveform Database (WDB) for later restore
log_wave -r /*

# Create new Wave Window
create_wave_config "Testbench Waveforms"
create_wave_config "DUT Waveforms"

# Add all top-level signals to Testbench Waveform
add_wave [current_scope]/vif/* -into [lindex [get_wave_config] 0]

# Add all top-level signals to DUT Waveform
add_wave [current_scope]/dut/*_o -into [lindex [get_wave_config] 1]
add_wave [current_scope]/dut/*_i -into [lindex [get_wave_config] 1]
add_wave [current_scope]/dut/ff* -into [lindex [get_wave_config] 1]
add_wave [current_scope]/dut/*_cnt -into [lindex [get_wave_config] 1]
add_wave [current_scope]/dut/cnt -into [lindex [get_wave_config] 1]
