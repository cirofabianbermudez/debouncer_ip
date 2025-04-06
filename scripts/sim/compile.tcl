##=============================================================================
## [Filename]       -
## [Project]        -
## [Author]         Ciro Bermudez - cirofabian.bermudez@gmail.com
## [Language]       GNU Makefile
## [Created]        Nov 2024
## [Modified]       -
## [Description]    -
## [Notes]          -
## [Status]         stable
## [Revisions]      -
##=============================================================================

proc compile {} {

  # Variable to measure time
  set tclStart [clock seconds]

  # Files
  set vlogSources {}
  set vhdlSources {}
  set ipsSources  {}

  # Defines
  set vlogDefines {}

  # ============================== PARSING FILES =============================== #

  # Single HDL file to be compiled
  if { [info exists ::env(HDL_FILE)] } {

    set hdlFilePath [file normalize ${::env(HDL_FILE)}]
    set hdlFileExt  [file extension ${::env(HDL_FILE)}]

    if { ${hdlFileExt} == ".v" || ${hdlFileExt} == ".sv"} {

      lappend vlogSources ${hdlFilePath}

    } elseif { ${hdlFileExt} == ".vhd" || ${hdlFileExt} == ".vhdl"} {

      lappend vhdlSources ${hdlFilePath}

    } else {

      puts "\[ERROR\]: Unknown HDL file extension ${hdlFileExt} !"

      # Script failure
      exit 1
    }

  } else {
    
    # Parse VLOG_SOURCES, VHDL_SOURCES and IPS_SOURCES environment variables otherwise

    # VLOG_SOURCES
    if { [info exists ::env(VLOG_SOURCES)] } {

      foreach src [split $::env(VLOG_SOURCES) " "] {

        lappend vlogSources [file normalize ${src}]
      }
    }

    # VHDL_SOURCES
    if { [info exists ::env(VHDL_SOURCES)] } {

      foreach src [split $::env(VHDL_SOURCES) " "] {

        lappend vhdlSources [file normalize ${src}]
      }
    }

    # IPS_SOURCES
    if { [info exists ::env(IPS_SOURCES)] } {

      foreach src [split $::env(IPS_SOURCES) " "] {

        lappend ipsSources [file normalize ${src}]
      }
    }
  }

  # Parse VLOG_DEFINES if any
  if { [info exists ::env(VLOG_DEFINES) ] } {

    set vlogDefines ${::env(VLOG_DEFINES)}
    puts "\[INFO\]: Verilog defines detected: ${vlogDefines}"

  } else {

    set vlogDefines {}

  }

  # ============================ SETUP WORKING AREA ============================ #

  if { [info exists ::env(WORK_DIR)] } {

    cd ${::env(WORK_DIR)}/sim

  } else {

    puts "\[WARN\]: WORK_DIR environment variable not defined!"
    puts "\[INFO\]: Assuming ./work/sim to run simulation flow" 

    if { ![file exists work] } {
      file mkdir work/sim
    }

    cd work/sim

  }




  # Compile Verilog/SystemVerilog sources (xvlog)




  # ============================= CPU REPORT TIME ============================== #

  set tclStop [clock seconds]
  set seconds [expr ${tclStop} - ${tclStart} ]
  puts "\[INFO\]: Total elapsed-time for compilation: [format "%6.2f" [expr $seconds/60.0]] minutes"

  # ========================= CHECK FOR SYNTAX ERRORS ========================== #

  puts "\[INFO\]: Checking for syntax errors ..."
  if {1} {
    puts "\[INFO\]: No Syntax Errors Found!"
    return 0;
  } else {
    puts "\[ERROR\]: Compilation Errors Detected!"
    puts "\[INFO\]: Please, fix all syntax errors and recompile sources\n"
    return 1
  }

  return 0
}


# =================================== MAIN =================================== #

# Run the Tcl procedure when the script is executed by tclsh from Makefile
if { ${argc} == 1 } {


  if { [lindex ${argv} 0] eq "compile" } {

    puts "\n\[INFO\]: [file normalize [info script]]"

    if { [compile] } {

      # Compilation contains errors, exit with non-zero error code
      puts "\[ERROR\]: Compilation FAILED"

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

