`include "defines.v"

module id_ex (
    input wire      clk,
    input wire      rst,
    input wire      flush,

    input wire[`AluOpBus]   id_aluop,
    input wire[`AluSelBus]  id_alusel,
    input wire[`RegBus]     id_reg1,
    input wire[`RegBus]     id_reg2,
    input wire[`RegAddrBus] id_wd,
    input wire              id_wreg,
    input wire[5:0]         stall,

    input wire[`RegBus]     id_link_address,
    input wire              id_prdt_taken,

    input wire[11:0]        id_branch_offset_12,

    input wire[`InstAddrBus]    id_pc,

    output reg[`AluOpBus]   ex_aluop,
    output reg[`AluSelBus]  ex_alusel,
    output reg[`RegBus]     ex_reg1,
    output reg[`RegBus]     ex_reg2,
    output reg[`RegAddrBus] ex_wd,
    output reg              ex_wreg,

    output reg[`RegBus]     ex_link_address,
    output reg              ex_prdt_taken,

    output reg[11:0]        ex_branch_offset_12,

    output reg[`InstAddrBus]    ex_pc
);

    always @(posedge clk) begin 
        if (rst == `RstEnable || flush == 1'b1) begin 
            ex_aluop    <=  `EXE_NOP_OP;
            ex_alusel   <=  `EXE_RES_NOP;
            ex_reg1     <=  `ZeroWord;
            ex_reg2     <=  `ZeroWord;
            ex_wd       <=  `NOPRegAddr;
            ex_wreg     <=  `WriteDisable;
            ex_link_address     <= `ZeroWord;
            ex_prdt_taken       <= 1'b0;
            ex_branch_offset_12 <= 12'b0;
            ex_pc       <= `ZeroWord;
        end else if (stall[2] == `Stop && stall[3] == `NoStop) begin
            // ID暂停，EX不暂停
            ex_aluop    <=  `EXE_NOP_OP;
            ex_alusel   <=  `EXE_RES_NOP;
            ex_reg1     <=  `ZeroWord;
            ex_reg2     <=  `ZeroWord;
            ex_wd       <=  `NOPRegAddr;
            ex_wreg     <=  `WriteDisable;
            ex_link_address     <= `ZeroWord;
            ex_prdt_taken       <= 1'b0;
            ex_branch_offset_12 <= 12'b0;
            ex_pc       <= `ZeroWord;
        end else if(stall[2] == `NoStop) begin 
            // ID不暂停
            ex_aluop    <=  id_aluop;
            ex_alusel   <=  id_alusel;
            ex_reg1     <=  id_reg1;
            ex_reg2     <=  id_reg2;
            ex_wd       <=  id_wd;
            ex_wreg     <=  id_wreg;
            ex_link_address     <= id_link_address;
            ex_prdt_taken       <= id_prdt_taken;
            ex_branch_offset_12 <= id_branch_offset_12;
            ex_pc       <= id_pc;
        end
    end

endmodule
