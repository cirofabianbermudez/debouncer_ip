##=============================================================================
## [Filename]       relaunch.tcl
## [Project]        -
## [Author]         Ciro Bermudez - cirofabian.bermudez@gmail.com
## [Language]       GNU Makefile
## [Created]        Nov 2024
## [Modified]       -
## [Description]    Custom Tcl script to relauch simulation
## [Notes]          -
## [Status]         stable
## [Revisions]      -
##=============================================================================

# Load custom Tcl procedures for compilation/elaboration
if { [info procs compile] eq "" } {
   source -notrace -quiet [pwd]/../../scripts/sim/compile.tcl
}

if { [info procs elaborate] eq "" } {
   source -notrace -quiet [pwd]/../../scripts/sim/elaborate.tcl
}

# ============================ RELAUNCH PROCEDURE ============================ #

proc relaunch {} {

  # ====== SAVE CURRENT WAVEFORM CONFIGURATION FOR LATER RESTORE (IF ANY) ====== #

  set tempDir wcfg.tmp
  exec mkdir -p ${tempDir}

  if { [llength [get_wave_configs]] != 0 } {

    foreach waveConfig [get_wave_configs] {

      # Save Waveform Configuration to XML file
      save_wave_config -object ${waveConfig} ${tempDir}/${waveConfig}

      # Close Waveform Configuration
      close_wave_config -force ${waveConfig}

    }

  }

  # ======= UNLOAD THE CURRENT SIMULATION SNAPSHOT WITHOUT EXITING XSIM ======== #

  # Unload the current simulation snapshot
  close_sim -force -quiet

  # Ensure to start from scratch
  catch {exec rm -rf xsim.dir .Xil [glob -nocomplain *.pb] [glob -nocomplain *.wdb]}

  # =================== RE-RUN COMPILATION/ELABORATION FLOWS =================== #

  # Makefile flow assume to start from the top directory
  cd [pwd]/../../

  # Try to re-compile sources (compile returns 0 if OK)
  if { [compile] } {

    puts "\[ERROR\]: Compilation failed!"
    exec grep ERROR [pwd]/../../work/logs/compile.log

  } else {

    cd [pwd]/../../

    #  Re-compile OK, try to re-elaborate the design
    if { [elaborate] } {

      puts "\[ERROR\]: Elaboration failed! Exiting..."
      exec grep ERROR [pwd]/../../work/logs/elaborate.log

    } else {

      # Re-elaboration OK, reload the simulation snapshot
      xsim ${::env(SIM_TOP_MODULE)}

      # Restore also old Waveform Configuration files
      if { [llength [glob -nocomplain ${tempDir}/* ]] != 0 } {

        foreach oldWaveConfig [glob -nocomplain ${tempDir}/* ] {

          open_wave_config ${oldWaveConfig}

        }

        # Everything is OK, remove temporary directory
        exec rm -rf ${tempDir}

      }

    }

  }

}
