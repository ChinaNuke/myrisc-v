onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/clk
add wave -noupdate /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/rst
add wave -noupdate /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/rom_ce_o
add wave -noupdate -expand -group Fetch /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/if_id0/if_inst
add wave -noupdate -expand -group Decode /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/if_id0/id_pc
add wave -noupdate -expand -group Decode /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/if_id0/id_inst
add wave -noupdate -expand -group Decode -radix binary /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/id0/alusel_o
add wave -noupdate -expand -group Decode -radix binary /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/id0/aluop_o
add wave -noupdate -expand -group Decode /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/id0/reg1_o
add wave -noupdate -expand -group Decode /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/id0/reg2_o
add wave -noupdate -expand -group Decode -radix binary /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/id0/wd_o
add wave -noupdate -expand -group Decode /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/id0/wreg_o
add wave -noupdate -expand -group Excute /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/ex0/wdata_o
add wave -noupdate -expand -group Excute -radix binary -childformat {{{/myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/ex0/wd_o[4]} -radix binary} {{/myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/ex0/wd_o[3]} -radix binary} {{/myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/ex0/wd_o[2]} -radix binary} {{/myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/ex0/wd_o[1]} -radix binary} {{/myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/ex0/wd_o[0]} -radix binary}} -subitemconfig {{/myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/ex0/wd_o[4]} {-height 21 -radix binary} {/myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/ex0/wd_o[3]} {-height 21 -radix binary} {/myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/ex0/wd_o[2]} {-height 21 -radix binary} {/myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/ex0/wd_o[1]} {-height 21 -radix binary} {/myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/ex0/wd_o[0]} {-height 21 -radix binary}} /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/ex0/wd_o
add wave -noupdate -expand -group Excute /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/ex0/wreg_o
add wave -noupdate -expand -group Memory /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/mem0/wdata_o
add wave -noupdate -expand -group Memory /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/mem0/wd_o
add wave -noupdate -expand -group Memory /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/mem0/wreg_o
add wave -noupdate -expand -group {Write Back} /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/mem_wb0/wb_wdata
add wave -noupdate -expand -group {Write Back} /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/mem_wb0/wb_wd
add wave -noupdate -expand -group {Write Back} /myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/mem_wb0/wb_wreg
add wave -noupdate -radix decimal {/myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/regfile1/regs[1]}
add wave -noupdate -radix decimal {/myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/regfile1/regs[2]}
add wave -noupdate -radix decimal {/myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/regfile1/regs[3]}
add wave -noupdate -radix decimal {/myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/regfile1/regs[4]}
add wave -noupdate {/myriscv_min_sopc_tb/myriscv_min_sopc0/mymips0/regfile1/regs[5]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1217618 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 215
configure wave -valuecolwidth 114
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {1144374 ps} {1262571 ps}
bookmark add wave bookmark2 {{0 ps} {138806 ps}} 8
