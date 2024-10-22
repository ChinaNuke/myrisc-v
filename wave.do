onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/clk
add wave -noupdate /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/rst
add wave -noupdate /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/rom_ce_o
add wave -noupdate -expand -group Fetch /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/if_id0/if_inst
add wave -noupdate -expand -group Decode /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/if_id0/id_pc
add wave -noupdate -expand -group Decode /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/if_id0/id_inst
add wave -noupdate -expand -group Decode -radix binary /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/id0/alusel_o
add wave -noupdate -expand -group Decode -radix binary /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/id0/aluop_o
add wave -noupdate -expand -group Decode /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/id0/reg1_o
add wave -noupdate -expand -group Decode /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/id0/reg2_o
add wave -noupdate -expand -group Decode -radix binary /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/id0/wd_o
add wave -noupdate -expand -group Decode /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/id0/wreg_o
add wave -noupdate -expand -group Excute /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/ex0/wdata_o
add wave -noupdate -expand -group Excute -radix binary -childformat {{{/myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/ex0/wd_o[4]} -radix binary} {{/myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/ex0/wd_o[3]} -radix binary} {{/myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/ex0/wd_o[2]} -radix binary} {{/myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/ex0/wd_o[1]} -radix binary} {{/myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/ex0/wd_o[0]} -radix binary}} -subitemconfig {{/myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/ex0/wd_o[4]} {-height 21 -radix binary} {/myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/ex0/wd_o[3]} {-height 21 -radix binary} {/myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/ex0/wd_o[2]} {-height 21 -radix binary} {/myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/ex0/wd_o[1]} {-height 21 -radix binary} {/myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/ex0/wd_o[0]} {-height 21 -radix binary}} /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/ex0/wd_o
add wave -noupdate -expand -group Excute /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/ex0/wreg_o
add wave -noupdate -expand -group Excute -radix binary /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/ex0/aluop_o
add wave -noupdate -expand -group Excute /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/ex0/mem_addr_o
add wave -noupdate -expand -group Excute /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/ex0/reg2_o
add wave -noupdate -expand -group Memory /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/mem0/wdata_o
add wave -noupdate -expand -group Memory /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/mem0/wd_o
add wave -noupdate -expand -group Memory /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/mem0/wreg_o
add wave -noupdate -expand -group Memory /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/mem0/mem_addr_o
add wave -noupdate -expand -group Memory /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/mem0/mem_we_o
add wave -noupdate -expand -group Memory -radix binary /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/mem0/mem_sel_o
add wave -noupdate -expand -group Memory /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/mem0/mem_data_o
add wave -noupdate -expand -group Memory /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/mem0/mem_ce_o
add wave -noupdate -expand -group Memory /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/mem0/mem_we
add wave -noupdate -expand -group Memory /myriscv_min_sopc_tb/myriscv_min_sopc0/data_ram0/we
add wave -noupdate -expand -group Memory /myriscv_min_sopc_tb/myriscv_min_sopc0/data_ram0/addr
add wave -noupdate -expand -group Memory /myriscv_min_sopc_tb/myriscv_min_sopc0/data_ram0/sel
add wave -noupdate -expand -group {Write Back} /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/mem_wb0/wb_wdata
add wave -noupdate -expand -group {Write Back} /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/mem_wb0/wb_wd
add wave -noupdate -expand -group {Write Back} /myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/mem_wb0/wb_wreg
add wave -noupdate -radix hexadecimal {/myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/regfile1/regs[1]}
add wave -noupdate -radix hexadecimal {/myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/regfile1/regs[2]}
add wave -noupdate -radix hexadecimal {/myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/regfile1/regs[3]}
add wave -noupdate -radix hexadecimal {/myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/regfile1/regs[4]}
add wave -noupdate -radix hexadecimal {/myriscv_min_sopc_tb/myriscv_min_sopc0/myriscv0/regfile1/regs[5]}
add wave -noupdate {/myriscv_min_sopc_tb/myriscv_min_sopc0/data_ram0/data_mem0[0]}
add wave -noupdate {/myriscv_min_sopc_tb/myriscv_min_sopc0/data_ram0/data_mem1[0]}
add wave -noupdate {/myriscv_min_sopc_tb/myriscv_min_sopc0/data_ram0/data_mem2[0]}
add wave -noupdate {/myriscv_min_sopc_tb/myriscv_min_sopc0/data_ram0/data_mem3[0]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {616628 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 234
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
WaveRestoreZoom {327611 ps} {481663 ps}
bookmark add wave bookmark2 {{0 ps} {138806 ps}} 8
