# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set C_S00_AXIS_TDATA_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXIS_TDATA_WIDTH" -parent ${Page_0} -widget comboBox]
  set_property tooltip {AXI4Stream sink: Data Width} ${C_S00_AXIS_TDATA_WIDTH}


}

proc update_PARAM_VALUE.ACC_BRAM_DATA_WIDTH { PARAM_VALUE.ACC_BRAM_DATA_WIDTH } {
	# Procedure called to update ACC_BRAM_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ACC_BRAM_DATA_WIDTH { PARAM_VALUE.ACC_BRAM_DATA_WIDTH } {
	# Procedure called to validate ACC_BRAM_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.BRAM_DEPTH { PARAM_VALUE.BRAM_DEPTH } {
	# Procedure called to update BRAM_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BRAM_DEPTH { PARAM_VALUE.BRAM_DEPTH } {
	# Procedure called to validate BRAM_DEPTH
	return true
}

proc update_PARAM_VALUE.RES_BRAM_DATA_WIDTH { PARAM_VALUE.RES_BRAM_DATA_WIDTH } {
	# Procedure called to update RES_BRAM_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RES_BRAM_DATA_WIDTH { PARAM_VALUE.RES_BRAM_DATA_WIDTH } {
	# Procedure called to validate RES_BRAM_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH } {
	# Procedure called to update C_S00_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_S00_AXIS_TDATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_S00_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_S00_AXIS_TDATA_WIDTH PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.BRAM_DEPTH { MODELPARAM_VALUE.BRAM_DEPTH PARAM_VALUE.BRAM_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BRAM_DEPTH}] ${MODELPARAM_VALUE.BRAM_DEPTH}
}

proc update_MODELPARAM_VALUE.ACC_BRAM_DATA_WIDTH { MODELPARAM_VALUE.ACC_BRAM_DATA_WIDTH PARAM_VALUE.ACC_BRAM_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ACC_BRAM_DATA_WIDTH}] ${MODELPARAM_VALUE.ACC_BRAM_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.RES_BRAM_DATA_WIDTH { MODELPARAM_VALUE.RES_BRAM_DATA_WIDTH PARAM_VALUE.RES_BRAM_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RES_BRAM_DATA_WIDTH}] ${MODELPARAM_VALUE.RES_BRAM_DATA_WIDTH}
}

