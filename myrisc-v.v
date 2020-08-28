`include "defines.v"

module myriscv (
    input wire clk,
    input wire rst,

    input wire[`RegBus]     rom_data_i,
    output wire[`RegBus]    rom_addr_o,
    output wire             rom_ce_o,

    input wire[`RegBus]     ram_data_i,
    output wire[`RegBus]    ram_addr_o,
    output wire[`RegBus]    ram_data_o,
    output wire             ram_we_o,
    output wire[3:0]        ram_sel_o,
    output wire             ram_ce_o
);
    
    wire[`InstAddrBus]      pc;

    // IF --- IF/ID
    wire[`InstAddrBus]      if_pc_o;
    wire[`InstBus]          if_inst_o;
    wire                    if_prdt_taken_o;
    wire[`InstAddrBus]      if_prdt_target_address_o;

    // IF/ID --- ID
    wire[`InstAddrBus]      id_pc_i;
    wire[`InstBus]          id_inst_i;
    wire                    id_prdt_taken_i;

    // ID --- ID/EX
    wire[`AluOpBus]         id_aluop_o;
    wire[`AluSelBus]        id_alusel_o;
    wire[`RegBus]           id_reg1_o;
    wire[`RegBus]           id_reg2_o;
    wire                    id_wreg_o;
    wire[`RegAddrBus]       id_wd_o;
    wire                    id_stall_o;
    wire[`RegBus]           id_link_address_o;
    wire[11:0]              id_branch_offset_12_o;
    wire                    id_prdt_taken_o;
    wire[`InstAddrBus]      id_pc_o;
    wire[`InstBus]          id_inst_o;

    // ID/EX --- EX
    wire[`AluOpBus]         ex_aluop_i;
    wire[`AluSelBus]        ex_alusel_i;
    wire[`RegBus]           ex_reg1_i;
    wire[`RegBus]           ex_reg2_i;
    wire                    ex_wreg_i;
    wire[`RegAddrBus]       ex_wd_i;
    wire[`RegBus]           ex_link_address_i;
    wire[11:0]              ex_branch_offset_12_i;
    wire                    ex_prdt_taken_i;
    wire[`InstAddrBus]      ex_pc_i;
    wire[`InstBus]          ex_inst_i;

    // EX --- EX/MEM
    wire                    ex_wreg_o;
    wire[`RegAddrBus]       ex_wd_o;
    wire[`RegBus]           ex_wdata_o;

    wire                    ex_flush_o;
    wire[`RegBus]           ex_flush_target_address_o;

    wire[`AluOpBus]         ex_aluop_o;
    wire[`RegBus]           ex_mem_addr_o;
    wire[`RegBus]           ex_reg2_o;

    // EX/MEM -- MEM
    wire                    mem_wreg_i;
    wire[`RegAddrBus]       mem_wd_i;
    wire[`RegBus]           mem_wdata_i;
    wire[`AluOpBus]         mem_aluop_i;
    wire[`RegBus]           mem_mem_addr_i;
    wire[`RegBus]           mem_reg2_i;

    // MEM -- MEM/WB
    wire                    mem_wreg_o;
    wire[`RegAddrBus]       mem_wd_o;
    wire[`RegBus]           mem_wdata_o;

    // MEM/WB -- WB
    wire                    wb_wreg_i;
    wire[`RegAddrBus]       wb_wd_i;
    wire[`RegBus]           wb_wdata_i;

    // ID --- RegFile
    wire                    reg1_read;
    wire                    reg2_read;
    wire[`RegBus]           reg1_data;
    wire[`RegBus]           reg2_data;
    wire[`RegAddrBus]       reg1_addr;
    wire[`RegAddrBus]       reg2_addr;

    wire[5:0]               stall;
    wire                    stallreq_from_id;
    wire                    stallreq_from_ex;

    wire is_in_delayslot_i;
    wire is_in_delayslot_o;
    wire next_inst_in_delayslot_o;
    wire id_branch_flag_o;
    wire[`RegBus] branch_target_address;

    pc_reg pc_reg0(
        .clk(clk), .rst(rst), 
        .stall(stall),

        .prdt_taken_i(if_prdt_taken_o),
        .prdt_target_address_i(if_prdt_target_address_o),
        
        .flush_i(ex_flush_o), 
        .flush_target_address_i(ex_flush_target_address_o),

        .pc(pc), .ce(rom_ce_o)
    );

    assign rom_addr_o = pc;

    ifu ifu0(
        .rst(rst),
        .pc_i(pc), .inst_i(rom_data_i),
        .flush(ex_flush_o),

        // 执行阶段数据前推
        .ex_wreg_i(ex_wreg_o), .ex_wdata_i(ex_wdata_o), .ex_wd_i(ex_wd_o),

        // 访存阶段数据前推
        .mem_wreg_i(mem_wreg_o), .mem_wdata_i(mem_wdata_o), .mem_wd_i(mem_wd_o),

        .prdt_taken_o(if_prdt_taken_o), .prdt_target_address_o(if_prdt_target_address_o),

        .pc_o(if_pc_o), .inst_o(if_inst_o)
    );

    if_id if_id0(
        .clk(clk), .rst(rst), 
        .stall(stall),
        .flush(ex_flush_o),
        .if_prdt_taken(if_prdt_taken_o),
        .if_pc(if_pc_o), .if_inst(if_inst_o),

        .id_pc(id_pc_i), .id_inst(id_inst_i),
        .id_prdt_taken(id_prdt_taken_i)
    );

    id id0(
        .rst(rst), .pc_i(id_pc_i), .inst_i(id_inst_i),

        .reg1_data_i(reg1_data), .reg2_data_i(reg2_data),

        // 执行阶段数据前推
        .ex_wreg_i(ex_wreg_o), .ex_wdata_i(ex_wdata_o), .ex_wd_i(ex_wd_o),

        // 访存阶段数据前推
        .mem_wreg_i(mem_wreg_o), .mem_wdata_i(mem_wdata_o), .mem_wd_i(mem_wd_o),

        .prdt_taken_i(id_prdt_taken_i),

        .reg1_addr_o(reg1_addr), .reg2_addr_o(reg2_addr),
        .reg1_read_o(reg1_read), .reg2_read_o(reg2_read),

        .aluop_o(id_aluop_o), .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o), .reg2_o(id_reg2_o),
        .wd_o(id_wd_o), .wreg_o(id_wreg_o),

        .stallreq(stallreq_from_id),

        .link_addr_o(id_link_address_o),
        .branch_offset_12_o(id_branch_offset_12_o),
        .prdt_taken_o(id_prdt_taken_o),

        .pc_o(id_pc_o), .inst_o(id_inst_o)

    );

    regfile regfile1(
        .clk(clk), .rst(rst),
        .re1(reg1_read), .re2(reg2_read),
        .raddr1(reg1_addr), .raddr2(reg2_addr),
        .rdata1(reg1_data), .rdata2(reg2_data),
        .we(wb_wreg_i),
        .waddr(wb_wd_i), .wdata(wb_wdata_i)
    );

    id_ex id_ex0(
        .clk(clk), .rst(rst),
        .flush(ex_flush_o),
        .stall(stall),
        .id_aluop(id_aluop_o), .id_alusel(id_alusel_o),
        .id_reg1(id_reg1_o), .id_reg2(id_reg2_o),
        .id_wd(id_wd_o), .id_wreg(id_wreg_o),
        .id_link_address(id_link_address_o),
        .id_prdt_taken(id_prdt_taken_o),
        .id_branch_offset_12(id_branch_offset_12_o),
        .id_pc(id_pc_o), .id_inst(id_inst_o),

        .ex_aluop(ex_aluop_i), .ex_alusel(ex_alusel_i),
        .ex_reg1(ex_reg1_i), .ex_reg2(ex_reg2_i),
        .ex_wd(ex_wd_i), .ex_wreg(ex_wreg_i),
        .ex_link_address(ex_link_address_i),
        .ex_prdt_taken(ex_prdt_taken_i),
        .ex_branch_offset_12(ex_branch_offset_12_i),
        .ex_pc(ex_pc_i), .ex_inst(ex_inst_i)
    );

    ex ex0(
        .rst(rst),

        .aluop_i(ex_aluop_i), .alusel_i(ex_alusel_i),
        .reg1_i(ex_reg1_i), .reg2_i(ex_reg2_i),
        .wd_i(ex_wd_i), .wreg_i(ex_wreg_i),
        .link_address_i(ex_link_address_i),
        .prdt_taken(ex_prdt_taken_i),
        .branch_offset_12_i(ex_branch_offset_12_i),
        .pc_i(ex_pc_i), .inst_i(ex_inst_i),

        .wd_o(ex_wd_o), .wreg_o(ex_wreg_o), .wdata_o(ex_wdata_o),

        .stallreq(stallreq_from_ex),

        .flush_o(ex_flush_o), .flush_target_address_o(ex_flush_target_address_o),

        .aluop_o(ex_aluop_o), .mem_addr_o(ex_mem_addr_o), .reg2_o(ex_reg2_o)
    );

    ex_mem ex_mem0(
        .clk(clk), .rst(rst),

        .stall(stall),

        .ex_wdata(ex_wdata_o), .ex_wd(ex_wd_o), .ex_wreg(ex_wreg_o),
        .ex_aluop(ex_aluop_o), .ex_mem_addr(ex_mem_addr_o), .ex_reg2(ex_reg2_o),

        .mem_wdata(mem_wdata_i), .mem_wd(mem_wd_i), .mem_wreg(mem_wreg_i),
        .mem_aluop(mem_aluop_i), .mem_mem_addr(mem_mem_addr_i), .mem_reg2(mem_reg2_i)
    );

    mem mem0(
        .rst(rst),

        .wdata_i(mem_wdata_i), .wd_i(mem_wd_i), .wreg_i(mem_wreg_i),

        .aluop_i(mem_aluop_i), .mem_addr_i(mem_mem_addr_i), .reg2_i(mem_reg2_i),

        .mem_data_i(ram_data_i),

        .wdata_o(mem_wdata_o), .wd_o(mem_wd_o), .wreg_o(mem_wreg_o),

        .mem_addr_o(ram_addr_o), .mem_we_o(ram_we_o), .mem_sel_o(ram_sel_o),
        .mem_data_o(ram_data_o), .mem_ce_o(ram_ce_o)
    );

    mem_wb mem_wb0(
        .clk(clk), .rst(rst),

        .stall(stall),

        .mem_wdata(mem_wdata_o), .mem_wd(mem_wd_o), .mem_wreg(mem_wreg_o),

        .wb_wdata(wb_wdata_i), .wb_wd(wb_wd_i), .wb_wreg(wb_wreg_i)
    );

    ctrl ctrl0(
        .rst(rst),

        .stallreq_from_id(stallreq_from_id), .stallreq_from_ex(stallreq_from_ex),

        .stall(stall)
    );
    
endmodule
