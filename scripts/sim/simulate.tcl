##=============================================================================
## [Filename]       simulate.tcl
## [Project]        -
## [Author]         Ciro Bermudez - cirofabian.bermudez@gmail.com
## [Language]       GNU Makefile
## [Created]        Nov 2024
## [Modified]       -
## [Description]    Custom Tcl script for SIMULATE step using Vivado tools
## [Notes]          -
## [Status]         stable
## [Revisions]      -
##=============================================================================

# ============================ SIMULATE PROCEDURE ============================ #

proc simulate { {mode "batch"} } {

  # Profiling
  set tclStart [clock seconds]

  # ============================== PARSING FILES =============================== #

  if { [info exist ::env(SIM_TOP_MODULE) ] } {

    set xelabTop ${::env(SIM_TOP_MODULE)}

    puts "\[INFO\]: Top-level testbench module: ${xelabTop}"

  } else {

    puts "\[ERROR\]: Unknown top-level module for design simulation!"

    # Script failure
    exit 1

  }

  # ============================ SETUP WORKING AREA ============================ #

  if { [info exists ::env(WORK_DIR)] } {

    puts "\[INFO\]: WORK_DIR environment variable detected: ${::env(WORK_DIR)}"
    cd ${::env(WORK_DIR)}/sim

  } else {

    puts "\[WARN\]: WORK_DIR environment variable not defined!"
    puts "\[INFO\]: Assuming ./work/sim to run simulation flow"

    if { ![file exists work] } {
      file mkdir work/sim
    }

    cd work/sim

  }

  # Create VCD and WDB directories
  file mkdir vcd
  file mkdir wdb

  # ============================== CONFIGURE LOGS ============================== #

  set logDir [pwd]/../logs

  if { ![file exists ${logDir} ] } {
    file mkdir ${logDir}
  }

  set logFile ${logDir}/simulate.log

  if { [file exists ${logFile} ] } {
    file delete ${logFile}
  }

  # ======================== DESIGN ELABORATION (xsim) ========================= #

  puts "\[INFO\]:"
  puts "        ====== Simulating the design ======"

  if { ${mode} == "gui" } {
    puts "\[INFO\]: Running simulation in GUI mode"

    exec xsim ${xelabTop} \
    -gui \
    -wdb [pwd]/wdb/${xelabTop}.wdb \
    -tclbatch [pwd]/../../scripts/sim/run.tcl \
    -stats -onerror stop \
    -log ${logFile} &

  } elseif { ${mode} == "tcl" } {
    puts "\[INFO\]: Running simulation in TCL mode"

    exec xsim ${xelabTop} \
    -wdb [pwd]/wdb/${xelabTop}.wdb \
    -tclbatch [pwd]/../../scripts/sim/run.tcl \
    -stats -onerror stop \
    -log ${logFile} >@stdout 2>@stdout

  } elseif { ${mode} == "batch" } {
    puts "\[INFO\]: Running simulation in BATCH mode"

    exec xsim ${xelabTop} \
    -wdb [pwd]/wdb/${xelabTop}.wdb \
    -tclbatch [pwd]/../../scripts/sim/run.tcl \
    -stats -onerror stop -onfinish quit \
    -log ${logFile} >@stdout 2>@stdout

  } else {

    puts "\[ERROR\]: Invalid option ${mode}"
    puts "\[INFO\]: Please use 'mode=gui|tcl|batch' when invoking 'make simulate' at the command line"

    # Script failure
    exit 1
  }

  # ============================= CPU REPORT TIME ============================== #

  set tclStop [clock seconds]
  set seconds [expr ${tclStop} - ${tclStart} ]
  puts "\[INFO\]: Total elapsed-time for SIMULATION: [format "%6.2f" [expr $seconds/1.0]] seconds"

}

# =================================== MAIN =================================== #

# Run the Tcl procedure when the script is executed by tclsh from Makefile
if { ${argc} > 0 } {

  if { [lindex ${argv} 0] eq "simulate" } {

    puts "\[INFO\]: running [file normalize [info script]]"

    if { [llength ${argv}] == 2 } {

      # Run selecting the simulation mode
      set mode [lindex ${argv} 1];
      simulate ${mode}

    } else {

      # Run in GUI otherwise (default)
      simulate

    }

  } else {

    # Invalid script argument, exit with non-zero error code
    puts "\[ERROR\]: Unknown option [lindex ${argv} 0]"

    # Script failure
    exit 1

  }

}
