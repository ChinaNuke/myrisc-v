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
    output reg                 wreg_o,
    output wire                stallreq     // 占坑
);

    wire[6:0] opcode = inst_i[6:0];
    wire[2:0] funct3 = inst_i[14:12];
    wire[6:0] funct7 = inst_i[31:25];

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
            wd_o            <= inst_i[11:7];    // RISC-V 固定的 rd 位置
            wreg_o          <= `WriteDisable;
            instvalid       <= `InstValid;
            reg1_read_o     <= 1'b0;
            reg2_read_o     <= 1'b0;
            reg1_addr_o     <= inst_i[19:15];   // rs1
            reg2_addr_o     <= inst_i[24:20];   // rs2
            imm             <= `ZeroWord;

            case (opcode)
                `RV_OP_IMM: begin // I 类指令
                    wreg_o      <=  `WriteEnable;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b0;
                    case (funct3)
                        `RV_OR: begin 
                            aluop_o     <=  `EXE_OR_OP;
                            alusel_o    <=  `EXE_RES_LOGIC;
                            imm         <=  {{20{inst_i[31]}}, inst_i[31:20]}; // RISC-V 规定立即数最高位总是符号位
                        end
                        `RV_AND: begin 
                            aluop_o     <=  `EXE_AND_OP;
                            alusel_o    <=  `EXE_RES_LOGIC;
                            imm         <=  {{20{inst_i[31]}}, inst_i[31:20]}; // RISC-V 规定立即数最高位总是符号位
                        end
                        `RV_XOR: begin 
                            aluop_o     <=  `EXE_XOR_OP;
                            alusel_o    <=  `EXE_RES_LOGIC;
                            imm         <=  {{20{inst_i[31]}}, inst_i[31:20]}; // RISC-V 规定立即数最高位总是符号位
                        end
                        `RV_SLT: begin 
                            aluop_o     <=  `EXE_SLT_OP;
                            alusel_o    <=  `EXE_RES_ARITHMETIC;
                            imm         <=  {{20{inst_i[31]}}, inst_i[31:20]}; // RISC-V 规定立即数最高位总是符号位
                        end
                        `RV_SLTU: begin 
                            aluop_o     <=  `EXE_SLTU_OP;
                            alusel_o    <=  `EXE_RES_ARITHMETIC;
                            imm         <=  {{20{inst_i[31]}}, inst_i[31:20]}; // RISC-V 规定立即数最高位总是符号位
                        end
                        `RV_SLL: begin 
                            aluop_o     <=  `EXE_SLL_OP;
                            alusel_o    <=  `EXE_RES_SHIFT;
                            imm[4:0]    <=  inst_i[24:20];  // shamt 字段
                        end
                        `RV_SRL_OR_SRA: begin           // SRL 和 SRA 的 opcode 是相同的
                            if (inst_i[30] == 0) begin  // imm[10] == 0，为 SRL 指令
                                aluop_o     <=  `EXE_SRL_OP;
                                alusel_o    <=  `EXE_RES_SHIFT;
                                imm[4:0]    <=  inst_i[24:20];  // shamt 字段
                            end else if (inst_i[30] == 1) begin // SRA 指令
                                aluop_o     <=  `EXE_SRA_OP;
                                alusel_o    <=  `EXE_RES_SHIFT;
                                imm[4:0]    <=  inst_i[24:20];  // shamt 字段
                            end
                        end
                        `RV_ADD_OR_SUB: begin 
                            aluop_o     <=  `EXE_ADD_OP;
                            alusel_o    <=  `EXE_RES_ARITHMETIC;
                            imm         <=  {{20{inst_i[31]}}, inst_i[31:20]}; // RISC-V 规定立即数最高位总是符号位
                        end
                        default : /* default */;
                    endcase
                end
                `RV_OP: begin // R 类指令
                    wreg_o      <= `WriteEnable;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    case (funct3)
                        `RV_OR: begin 
                            aluop_o     <= `EXE_OR_OP;
                            alusel_o    <= `EXE_RES_LOGIC;
                        end
                        `RV_AND: begin 
                            aluop_o     <= `EXE_AND_OP;
                            alusel_o    <= `EXE_RES_LOGIC;
                        end
                        `RV_XOR: begin 
                            aluop_o     <=  `EXE_XOR_OP;
                            alusel_o    <=  `EXE_RES_LOGIC;
                        end
                        `RV_SLT: begin 
                            aluop_o     <=  `EXE_SLT_OP;
                            alusel_o    <=  `EXE_RES_ARITHMETIC;
                        end
                        `RV_SLTU: begin 
                            aluop_o     <=  `EXE_SLTU_OP;
                            alusel_o    <=  `EXE_RES_ARITHMETIC;
                        end
                        `RV_SLL: begin 
                            aluop_o     <=  `EXE_SLL_OP;
                            alusel_o    <=  `EXE_RES_SHIFT;
                        end
                        `RV_SRL_OR_SRA: begin           // SRL 和 SRA 的 opcode 是相同的
                            if (inst_i[30] == 0) begin  // imm[10] == 0，为 SRL 指令
                                aluop_o     <=  `EXE_SRL_OP;
                                alusel_o    <=  `EXE_RES_SHIFT;
                            end else if (inst_i[30] == 1) begin // SRA 指令
                                aluop_o     <=  `EXE_SRA_OP;
                                alusel_o    <=  `EXE_RES_SHIFT;
                            end
                        end
                        `RV_ADD_OR_SUB: begin 
                            if (funct7 == 7'b0000000) begin // ADD
                                aluop_o     <=  `EXE_ADD_OP;
                                alusel_o    <=  `EXE_RES_ARITHMETIC;
                            end else if (funct7 == 7'b0100000) begin // SUB
                                aluop_o     <=  `EXE_SUB_OP;
                                alusel_o    <=  `EXE_RES_ARITHMETIC;
                            end
                        end
                        default : /* default */;
                    endcase // case funct3
                    if (funct7 == 7'b0000001) begin      // RV32M 扩展：乘法指令
                        if (funct3 == 3'b000) begin
                            aluop_o     <= `EXE_MUL_OP;
                            alusel_o    <= `EXE_RES_MUL;
                        end else if (funct3 == 3'b001) begin
                            aluop_o     <= `EXE_MULH_OP;
                            alusel_o    <= `EXE_RES_MULH;
                        end else if (funct3 == 3'b010) begin
                            /* code */
                        end
                    end
                end
                `RV_OP_LUI: begin // LUI 指令
                    wreg_o      <=  `WriteEnable;
                    aluop_o     <=  `EXE_LUI_OP;
                    alusel_o    <=  `EXE_RES_LOGIC;
                    reg1_read_o <=  1'b0;
                    reg2_read_o <=  1'b0;
                    imm         <=  {inst_i[31:12], 12'h0}; // 立即数作为高20位，低12位补0
                end
            endcase // case opcode
        end
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