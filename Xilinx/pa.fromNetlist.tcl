
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name FPGAPSG -dir "/home/moffitt/Development/FPGAPSG/Xilinx/planAhead_run_1" -part xc6slx4cpg196-2
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/moffitt/Development/FPGAPSG/Xilinx/fpgapsg.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/moffitt/Development/FPGAPSG/Xilinx} }
set_property target_constrs_file "fpgapsg.ucf" [current_fileset -constrset]
add_files [list {fpgapsg.ucf}] -fileset [get_property constrset [current_run]]
link_design
