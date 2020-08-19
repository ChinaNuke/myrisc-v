`include "defines.v"

module id (
    input wire rst,
    input wire[`InstAddrBus]   pc_i,
    input wire[`InstBus]       inst_i,

    input wire[`RegBus]        reg1_data_i,
    input wire[`RegBus]        reg2_data_i,

    // 执行阶段指令的运算结果
    input wire                 ex_wreg_i,
    input wire[`RegBus]        ex_wdata_i,
    input wire[`RegAddrBus]    ex_wd_i,

    // 访存阶段指令的运算结果
    input wire                 mem_wreg_i,
    input wire[`RegBus]        mem_wdata_i,
    input wire[`RegAddrBus]    mem_wd_i,

    output reg                 reg1_read_o,
    output reg                 reg2_read_o,
    output reg[`RegAddrBus]    reg1_addr_o,
    output reg[`RegAddrBus]    reg2_addr_o,

    output reg[`AluOpBus]      aluop_o,
    output reg[`AluSelBus]     alusel_o,
    output reg[`RegBus]        reg1_o,
    output reg[`RegBus]        reg2_o,
    output reg[`RegAddrBus]    wd_o,
    output reg                 wreg_o
);

    wire[5:0] op = inst_i[31:26];
    wire[4:0] op2 = inst_i[10:6];
    wire[5:0] op3 = inst_i[5:0];
    wire[4:0] op4 = inst_i[20:16];

    reg[`RegBus] imm;

    reg instvalid;

    always @(*) begin
        if (rst == `RstEnable) begin
            aluop_o         <= `EXE_NOP_OP;
            alusel_o        <= `EXE_RES_NOP;
            wd_o            <= `NOPRegAddr;
            wreg_o          <= `WriteDisable;
            instvalid       <= `InstInvalid;
            reg1_read_o     <= 1'b0;
            reg2_read_o     <= 1'b0;
            reg1_addr_o     <= `NOPRegAddr;
            reg2_addr_o     <= `NOPRegAddr;
            imm             <= 32'h0;
        end else begin 
            aluop_o         <= `EXE_NOP_OP;
            alusel_o        <= `EXE_RES_NOP;
            wd_o            <= inst_i[15:11];
            wreg_o          <= `WriteDisable;
            instvalid       <= `InstValid;
            reg1_read_o     <= 1'b0;
            reg2_read_o     <= 1'b0;
            reg1_addr_o     <= inst_i[25:21];
            reg2_addr_o     <= inst_i[20:16];
            imm             <= `ZeroWord;

            case (op)
                `EXE_SPECIAL_INST: begin // SPECIAL 指令
                    case (op2)
                        5'b00000: begin 
                            case (op3)
                                `EXE_OR: begin 
                                    wreg_o      <= `WriteEnable;
                                    aluop_o     <= `EXE_OR_OP;
                                    alusel_o    <= `EXE_RES_LOGIC;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    instvalid   <= `InstValid;
                                end
                                `EXE_AND: begin 
                                    wreg_o      <= `WriteEnable;
                                    aluop_o     <= `EXE_AND_OP;
                                    alusel_o    <= `EXE_RES_LOGIC;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    instvalid   <= `InstValid;
                                end
                                `EXE_XOR: begin 
                                    wreg_o      <= `WriteEnable;
                                    aluop_o     <= `EXE_XOR_OP;
                                    alusel_o    <= `EXE_RES_LOGIC;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    instvalid   <= `InstValid;
                                end
                                `EXE_NOR: begin 
                                    wreg_o      <= `WriteEnable;
                                    aluop_o     <= `EXE_NOR_OP;
                                    alusel_o    <= `EXE_RES_LOGIC;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    instvalid   <= `InstValid;
                                end
                                `EXE_SLLV: begin 
                                    wreg_o      <= `WriteEnable;
                                    aluop_o     <= `EXE_SLL_OP;
                                    alusel_o    <= `EXE_RES_SHIFT;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    instvalid   <= `InstValid;
                                end
                                `EXE_SRLV: begin 
                                    wreg_o      <= `WriteEnable;
                                    aluop_o     <= `EXE_SRL_OP;
                                    alusel_o    <= `EXE_RES_SHIFT;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    instvalid   <= `InstValid;
                                end
                                `EXE_SRAV: begin 
                                    wreg_o      <= `WriteEnable;
                                    aluop_o     <= `EXE_SRA_OP;
                                    alusel_o    <= `EXE_RES_SHIFT;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    instvalid   <= `InstValid;
                                end
                                `EXE_SYNC: begin 
                                    wreg_o      <= `WriteEnable;
                                    aluop_o     <= `EXE_NOP_OP;
                                    alusel_o    <= `EXE_RES_NOP;
                                    reg1_read_o <= 1'b0;
                                    reg2_read_o <= 1'b1;
                                    instvalid   <= `InstValid;
                                end
                                default: begin 
                                end
                            endcase // case op3
                        end
                        default: begin 
                        end
                    endcase // case op2
                end
                `EXE_ORI: begin 
                    wreg_o      <=  `WriteEnable;
                    aluop_o     <=  `EXE_OR_OP;
                    alusel_o    <=  `EXE_RES_LOGIC;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b0;
                    imm         <=  {16'h0, inst_i[15:0]};
                    wd_o        <=  inst_i[20:16];
                    instvalid   <=  `InstValid;
                end
                `EXE_ANDI: begin 
                    wreg_o      <=  `WriteEnable;
                    aluop_o     <=  `EXE_AND_OP;
                    alusel_o    <=  `EXE_RES_LOGIC;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b0;
                    imm         <=  {16'h0, inst_i[15:0]};
                    wd_o        <=  inst_i[20:16];
                    instvalid   <=  `InstValid;
                end
                `EXE_XORI: begin 
                    wreg_o      <=  `WriteEnable;
                    aluop_o     <=  `EXE_XOR_OP;
                    alusel_o    <=  `EXE_RES_LOGIC;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b0;
                    imm         <=  {16'h0, inst_i[15:0]};
                    wd_o        <=  inst_i[20:16];
                    instvalid   <=  `InstValid;
                end
                `EXE_LUI: begin 
                    wreg_o      <=  `WriteEnable;
                    aluop_o     <=  `EXE_OR_OP;
                    alusel_o    <=  `EXE_RES_LOGIC;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b0;
                    imm         <=  {inst_i[15:0], 16'h0}; // 跟 ORI 差在这
                    wd_o        <=  inst_i[20:16];
                    instvalid   <=  `InstValid;
                end
                `EXE_PREF: begin 
                    wreg_o      <=  `WriteEnable;
                    aluop_o     <=  `EXE_NOP_OP;
                    alusel_o    <=  `EXE_RES_NOP;
                    reg1_read_o <=  1'b0;
                    reg2_read_o <=  1'b0;
                    instvalid   <=  `InstValid;
                end
                default : begin 
                end
            endcase // case op

            if (inst_i[31:21] == 11'b000_0000_0000) begin
                if (op3 == `EXE_SLL) begin
                    wreg_o      <= `WriteEnable;
                    aluop_o     <= `EXE_SLL_OP;
                    alusel_o    <= `EXE_RES_SHIFT;
                    reg1_read_o <= 1'b0;
                    reg2_read_o <= 1'b1;
                    imm[4:0]    <= inst_i[10:6];
                    wd_o        <= inst_i[15:11]; // 是否有必要在这里赋值？
                    instvalid   <= `InstValid;
                end else if (op3 == `EXE_SRL) begin
                    wreg_o      <= `WriteEnable;
                    aluop_o     <= `EXE_SRL_OP;
                    alusel_o    <= `EXE_RES_SHIFT;
                    reg1_read_o <= 1'b0;
                    reg2_read_o <= 1'b1;
                    imm[4:0]    <= inst_i[10:6];
                    wd_o        <= inst_i[15:11];
                    instvalid   <= `InstValid;
                end else if (op3 == `EXE_SRA) begin
                    wreg_o      <= `WriteEnable;
                    aluop_o     <= `EXE_SRA_OP;
                    alusel_o    <= `EXE_RES_SHIFT;
                    reg1_read_o <= 1'b0;
                    reg2_read_o <= 1'b1;
                    imm[4:0]    <= inst_i[10:6];
                    wd_o        <= inst_i[15:11];
                    instvalid   <= `InstValid;
                end
            end // if
        end // if
    end // always

    always @(*) begin
        if (rst == `RstEnable) begin 
            reg1_o  <= `ZeroWord;
        end else if ((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o)) begin
            reg1_o  <= ex_wdata_i;
        end else if ((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o)) begin
            reg1_o  <= mem_wdata_i;
        end else if (reg1_read_o == 1'b1) begin
            reg1_o  <= reg1_data_i;
        end else if (reg1_read_o == 1'b0) begin
            reg1_o  <= imm;
        end else begin 
            reg1_o  <= `ZeroWord;
        end
    end

    always @(*) begin
        if (rst == `RstEnable) begin 
            reg2_o  <= `ZeroWord;
        end else if ((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o)) begin
            reg2_o  <= ex_wdata_i;
        end else if ((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o)) begin
            reg2_o  <= mem_wdata_i;
        end else if (reg2_read_o == 1'b1) begin
            reg2_o  <= reg2_data_i;
        end else if (reg2_read_o == 1'b0) begin
            reg2_o  <= imm;
        end else begin 
            reg2_o  <= `ZeroWord;
        end
    end

endmodule