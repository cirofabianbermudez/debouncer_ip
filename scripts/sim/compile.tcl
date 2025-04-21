##=============================================================================
## [Filename]       compile.tcl
## [Project]        -
## [Author]         Ciro Bermudez - cirofabian.bermudez@gmail.com
## [Language]       GNU Makefile
## [Created]        Nov 2024
## [Modified]       -
## [Description]    Custom Tcl script for COMPILE step using Vivado tools
## [Notes]          -
## [Status]         stable
## [Revisions]      -
##=============================================================================

# ============================ COMPILE PROCEDURE ============================= #

proc compile {} {

  # Profiling
  set tclStart [clock seconds]

  # Files
  set vlogSources {}
  set vhdlSources {}
  set ipsSources  {}

  # Defines for Verilog compilation
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

  set logFile ${logDir}/compile.log

  if { [file exists ${logFile} ] } {
    file delete ${logFile}
  }

  # ==================== COMPILE HDL SOURCES (xvlog/xvhdl) ===================== #

  puts "\[INFO\]:"
  puts "        ====== Compiling source files ======"

  # Compile Verilog/SystemVerilog sources (xvlog)
  if { [llength ${vlogSources}] != 0 } {

    foreach src ${vlogSources} {

      if { [file exist ${src}] } {

        if { [file extension ${src}]  == ".sv"} {
          puts "\[INFO\]: Compiling SystemVerilog source file ${src}"

          # Launch xvlog executable from Tcl for SystemVerilog
          catch {eval exec xvlog -sv ${vlogDefines} -relax -i [file normalize [pwd]/../..] -work work ${src} -nolog | tee -a ${logFile}}

        } else {
          puts "\[INFO\]: Compiling Verilog source file ${src}"

          # Launch xvlog executable from Tcl for Verilog
          catch {eval exec xvlog ${vlogDefines} -relax -i [file normalize [pwd]/../..] -work work ${src} -nolog | tee -a ${logFile}}
        }

      } else {

        puts "\[ERROR\]: ${src} not found!"

        # Script failure
        exit 1
      }
    }
  }

  # Compile VHDL sources (xvhdl)
  if { [llength ${vhdlSources}] != 0 } {

    foreach src ${vhdlSources} {

      if { [file exist ${src}] } {

        puts "\[INFO\]: Compiling VHDL source file ${src}"

        # Launch xvhdl executable from Tcl
        catch {eval exec xvhdl -2008 -relax -work work ${src} -nolog | tee -a ${logFile}}

      } else {

        puts "\[ERROR\]: ${src} not found!"

        # Script failure
        exit 1
      }
    }
  }

  # Compile IP sources (assume to use Verilog netlists) (xvlog)
  if { [llength ${ipsSources}] != 0 } {

    foreach src ${ipsSources} {

      if { [file exist ${src}] } {

        puts "\[INFO\]: Compiling IP Verilog netlist file ${src}"

        # Launch xvlog executable from Tcl
        catch {eval exec xvlog -relax -work work ${src} -nolog | tee -a ${logFile}}

      } else {

        puts "\[ERROR\]: ${src} not found!"

        # Script failure
        exit 1
      }
    }
  }

  # ============================= CPU REPORT TIME ============================== #

  set tclStop [clock seconds]
  set seconds [expr ${tclStop} - ${tclStart} ]
  puts "\[INFO\]: Total elapsed-time for COMPILATION: [format "%6.2f" [expr $seconds/1.0]] seconds"

  # ========================= CHECK FOR SYNTAX ERRORS ========================== #

  puts "\[INFO\]: Checking for syntax errors ..."
  if { [catch {exec grep --color ERROR ${logFile} >@stdout 2>@stdout } ] } {

    puts "\[INFO\]:"
    puts "        ============================="
    puts "           No Syntax Errors Found!"
    puts "        ============================="

    return 0
  } else {

    puts "\[ERROR\]: "
    puts "        ============================="
    puts "         Compilation Errors Detected!"
    puts "        ============================="
    puts "\[ERROR\]: Please, fix all syntax errors and recompile sources"

    return 1
  }
}

# =================================== MAIN =================================== #

# Run the Tcl procedure when the script is executed by tclsh from Makefile
if { ${argc} == 1 } {

  if { [lindex ${argv} 0] eq "compile" } {

    puts "\[INFO\]: running [file normalize [info script]]"

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
