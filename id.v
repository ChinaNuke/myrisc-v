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

    input wire                 is_in_delayslot_i,

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
    output wire                stallreq,

    output reg                 next_inst_in_delayslot_o,

    output reg                 branch_flag_o,
    output reg[`RegBus]        branch_target_address_o,
    output reg[`RegBus]        link_addr_o,
    output reg                 is_in_delayslot_o
);

    wire[6:0] opcode = inst_i[6:0];
    wire[2:0] funct3 = inst_i[14:12];
    wire[6:0] funct7 = inst_i[31:25];

    reg[`RegBus] imm;

    reg instvalid;

    wire[`RegBus] pc_plus_8;
    wire[`RegBus] pc_plus_4;

    wire[`RegBus] imm_sll2_signedext;
    wire[19:0] offset_20;
    wire[11:0] offset_12;
    assign stallreq = `NoStop;

    assign pc_plus_8 = pc_i + 8;
    assign pc_plus_4 = pc_i + 4;

    assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};

    assign offset_20 = inst_i[31:12]; // 实际的 RISC-V 指令要变换位置，这里简化便于调试
    assign offset_12 = inst_i[31:20];

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
            imm             <= `ZeroWord;
            link_addr_o     <= `ZeroWord;
            branch_target_address_o     <= `ZeroWord;
            branch_flag_o               <= `NotBranch;
            next_inst_in_delayslot_o    <= `NotInDelaySlot;
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
            link_addr_o     <= `ZeroWord;
            branch_target_address_o     <= `ZeroWord;
            branch_flag_o               <= `NotBranch;
            next_inst_in_delayslot_o    <= `NotInDelaySlot;

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
                `RV_OP_JAL: begin 
                    wreg_o          <= `WriteEnable;
                    aluop_o         <= `EXE_JAL_OP;
                    alusel_o        <= `EXE_RES_JUMP_BRANCH;
                    reg1_read_o     <= 1'b0;
                    reg2_read_o     <= 1'b0;
                    link_addr_o     <= pc_plus_8;
                    branch_flag_o   <= `Branch;
                    next_inst_in_delayslot_o    <= `InDelaySlot;
                    branch_target_address_o     <= {{11{offset_20[19]}}, offset_20, 1'b0} + pc_i;
                end
                `RV_OP_JALR: begin 
                    wreg_o          <= `WriteEnable;
                    aluop_o         <= `EXE_JALR_OP;
                    alusel_o        <= `EXE_RES_JUMP_BRANCH;
                    reg1_read_o     <= 1'b1;
                    reg2_read_o     <= 1'b0;
                    link_addr_o     <= pc_plus_8;
                    branch_flag_o   <= `Branch;
                    next_inst_in_delayslot_o <= `InDelaySlot;
                    branch_target_address_o     <= {{20{offset_12[11]}}, offset_12} + reg1_o;
                end
                `RV_OP_BRANCH: begin 
                    case (funct3)
                        3'b000: begin   // BEQ
                            wreg_o      <= `WriteDisable;
                            aluop_o     <= `EXE_BEQ_OP;
                            alusel_o    <= `EXE_RES_JUMP_BRANCH;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            if (reg1_o == reg2_o) begin 
                                branch_target_address_o     <= pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o               <= `Branch;
                                next_inst_in_delayslot_o    <= `InDelaySlot;
                            end
                        end
                        3'b001: begin   // BNE

                        end
                        3'b100: begin   // BLT

                        end
                        3'b101: begin   // BGE

                        end
                        3'b110: begin   // BLTU

                        end
                        3'b111: begin   // BGEU

                        end
                        default : /* default */;
                    endcase
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

    always @(*) begin 
        if (rst == `RstEnable) begin 
            is_in_delayslot_o <= `NotInDelaySlot;
        end else begin 
            is_in_delayslot_o <= is_in_delayslot_i;
        end
    end

endmodule