#!/bin/tcsh

# From /cds/env/setenv_synopsys_2022_23.csh
setenv SYNOPSYS_ROOT /eda/synopsys/2022-23/RHELx86

# Run the corresponding script for each tool
foreach script ( `ls -1 $SYNOPSYS_ROOT/../scripts/*.csh` )
	if ("$script" != "/eda/synopsys/2022-23/RHELx86/../scripts/VIRT-PROTO_2022.06-2_RHELx86.csh") then
		source $script
	endif
end

# Synopsys License
setenv SNPSLMD_LICENSE_FILE 5280@sunba2
setenv SNPS_LICENSE_FILE 5280@sunba2

# TSMC library
setenv TSMC_PATH /cds/TSMC/28nm/HEP_DesignKit_TSMC28_HPCplusRF_v1.1
setenv TSMC_OPTION 1P9M_5X1Y1Z1U_UT_AlRDL
setenv TSMC_PDK ${TSMC_PATH}/pdk/${TSMC_OPTION}/cdsPDK_synopsys
setenv TSMC_HOME ${TSMC_PATH}/TSMCHOME
setenv TSMC_DIG_LIBS ${TSMC_HOME}/digital
