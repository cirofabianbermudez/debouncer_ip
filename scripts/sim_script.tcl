# Vivado simulation script

set script_dir [file dirname [file normalize [info script]]]
puts "Script directory (absolute): $script_dir"

set root_dir [file dirname $script_dir]
puts "Root directory (absolute): $root_dir"

set vivado_proj [file join $root_dir "vivado" "vivado.xpr" ]
puts "New path: $vivado_proj"

# Generate a random seed based on the current time
set seed_value [expr {int([clock seconds])}]
puts "Random seed: $seed_value"

# Load Vivado project
#start_gui
open_project $vivado_proj
#update_compile_order -fileset sources_1

# Compile and elaborate the design
launch_simulation
set_property -name {xsim.simulate.xsim.more_options} -value "-sv_seed $seed_value" -objects [get_filesets sim_1]
#relaunch_sim
restart
run all

