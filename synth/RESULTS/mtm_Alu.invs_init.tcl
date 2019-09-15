#####################################################################
#
# Init setup file
# Created by Genus(TM) Synthesis Solution on 09/15/2019 22:40:01
#
#####################################################################


read_mmmc /student/ptokarczyk/PPCU_VLSI/VLSI_2019_project-master/synth/RESULTS/mtm_Alu.mmmc.tcl

read_physical -lef {/cad/dk/umc180/SUS/SUSLIB_UCL_tech.lef /cad/dk/umc180/SUS/SUSLIB_UCL.lef}

read_netlist /student/ptokarczyk/PPCU_VLSI/VLSI_2019_project-master/synth/RESULTS/mtm_Alu.v

init_design
