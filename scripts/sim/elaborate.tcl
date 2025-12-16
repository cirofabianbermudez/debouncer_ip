##=============================================================================
## [Filename]       elaborate.tcl
## [Project]        -
## [Author]         Ciro Bermudez - cirofabian.bermudez@gmail.com
## [Language]       GNU Makefile
## [Created]        Nov 2024
## [Modified]       -
## [Description]    Custom Tcl script for ELABORATE step using Vivado tools
## [Notes]          -
## [Status]         stable
## [Revisions]      -
##=============================================================================

# =========================== ELABORATE PROCEDURE ============================ #

proc elaborate {} {

  # Profiling
  set tclStart [clock seconds]

  # ============================== PARSING FILES =============================== #

  if { [info exist ::env(SIM_TOP_MODULE) ] } {

    set xelabTop ${::env(SIM_TOP_MODULE)}

    puts "\[INFO\]: Top-level testbench module: ${xelabTop}"

  } else {

    puts "\[ERROR\]: Unknown top-level module for design elaboration!"

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

  # ============================== CONFIGURE LOGS ============================== #

  set logDir [pwd]/../logs

  if { ![file exists ${logDir} ] } {
    file mkdir ${logDir}
  }

  set logFile ${logDir}/elaborate.log

  if { [file exists ${logFile} ] } {
    file delete ${logFile}
  }

  # ======================== DESIGN ELABORATION (xelab) ======================== #

  puts "\[INFO\]:"
  puts "         ====== Elaborating the design ======"

  # Launch xelab executable from Tcl
  catch {eval exec xelab -relax -mt 8 \
  -L work -L xil_defaultlib -L xpm -L uvm -L unisims_ver -L unimacro_ver -L secureip \
  -debug typical work.${xelabTop} -snapshot ${xelabTop} \
  -nolog >@stdout 2>@stdout | tee ${logFile} }

  # xelab --incr --debug typical --relax --mt 8
  # -L xil_defaultlib -L uvm -L unisims_ver -L unimacro_ver -L secureip
  # --snapshot tb_behav xil_defaultlib.tb xil_defaultlib.glbl -log elaborate.log

  # ============================= CPU REPORT TIME ============================== #

  set tclStop [clock seconds]
  set seconds [expr ${tclStop} - ${tclStart} ]
  puts "\[INFO\]: Total elapsed-time for ELABORATION: [format "%6.2f" [expr $seconds/1.0]] seconds"

  # ========================= CHECK FOR SYNTAX ERRORS ========================== #

  puts "\[INFO\]: Checking for syntax errors ..."
  if { [catch {exec grep --color ERROR ${logFile} >@stdout 2>@stdout } ] } {
    puts "\[INFO\]:"
    puts "        ============================="
    puts "         No Elaboration Errors Found!"
    puts "        ============================="
    return 0
  } else {

    puts "\[ERROR\]: "
    puts "        ============================="
    puts "         Elaboration Errors Detected!"
    puts "        ============================="
    puts "\[ERROR\]: Please, fix all errors and recompile sources"
    return 1
  }
}

# =================================== MAIN =================================== #

# Run the Tcl procedure when the script is executed by tclsh from Makefile
if { ${argc} == 1 } {

  if { [lindex ${argv} 0] eq "elaborate" } {

    puts "\[INFO\]: running [file normalize [info script]]"

    if { [elaborate] } {

      # Compilation contains errors, exit with non-zero error code
      puts "\[ERROR\]: Elaboration FAILED"

      # Script failure
      exit 1

    } else {

      # Compilation OK
      exit 0

    }

  } else {

    # Invalid script argument, exit with non-zero error code
    puts "\[ERROR\]: Unknown option [lindex ${argv} 0]"

    # Script failure
    exit 1

  }

}
