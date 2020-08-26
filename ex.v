`include "defines.v"

module ex (
    input wire  rst,

    input wire[`AluOpBus]       aluop_i,
    input wire[`AluSelBus]      alusel_i,
    input wire[`RegBus]         reg1_i,
    input wire[`RegBus]         reg2_i,
    input wire[`RegAddrBus]     wd_i,
    input wire                  wreg_i,
    input wire[`InstAddrBus]    pc_i,

    input wire[`RegBus]         link_address_i,
    input wire[11:0]            branch_offset_12_i,

    input wire                  prdt_taken,

    output reg[`RegAddrBus]     wd_o,
    output reg                  wreg_o,
    output reg[`RegBus]         wdata_o,

    output reg                  stallreq,

    output reg                  flush_o,
    output reg[`RegBus]         flush_target_address_o
);

    reg[`RegBus] logicout;      // 逻辑运算结果
    reg[`RegBus] shiftres;      // 移位运算结果
    reg[`RegBus] arithmeticres; // 算术运算结果

    wire                reg1_eq_reg2;
    wire                reg1_lt_reg2;
    wire[`RegBus]       reg2_i_mux;     // reg2 的补码
    wire[`RegBus]       reg1_i_not;     // reg1 的反码
    wire[`RegBus]       result_sum;     // 加法结果
    wire[`RegBus]       opdata1_mult;   // 乘法中的被乘数
    wire[`RegBus]       opdata2_mult;   // 乘法中的乘数
    wire[`DoubleRegBus] mulres_temp;    // 临时保存乘法结果
    reg[`DoubleRegBus]  mulres;         // 保存乘法结果

    wire                branch_taken;
    // wire[`RegBus]       branch_offset = {{19{branch_offset_12_i[11]}}, branch_offset_12_i[11:0], 1'b0};

    // 进行逻辑运算
    always @(*) begin 
        if (rst == `RstEnable) begin 
            logicout <= `ZeroWord;
        end else begin 
            case (aluop_i)
                `EXE_OR_OP: begin 
                    logicout <= reg1_i | reg2_i;
                end
                `EXE_AND_OP: begin 
                    logicout <= reg1_i & reg2_i;
                end
                `EXE_NOR_OP: begin 
                    logicout <= ~(reg1_i | reg2_i);
                end
                `EXE_XOR_OP: begin 
                    logicout <= reg1_i ^ reg2_i;
                end
                `EXE_LUI_OP: begin 
                    logicout <= reg1_i;
                end
                default : begin 
                    logicout <= `ZeroWord;
                end
            endcase
        end
    end

    // 进行移位运算
    always @(*) begin 
        if (rst == `RstEnable) begin 
            shiftres    <= `ZeroWord;
        end else begin 
            case (aluop_i)
                `EXE_SLL_OP: begin 
                    shiftres    <= reg1_i << reg2_i[4:0];
                end
                `EXE_SRL_OP: begin 
                    shiftres    <= reg1_i >> reg2_i[4:0];
                end
                `EXE_SRA_OP: begin 
                    shiftres    <= ({32{reg1_i[31]}} << (6'd32-{1'b0, reg2_i[4:0]})) | reg1_i >> reg2_i[4:0];
                end
                default : begin 
                    shiftres    <= `ZeroWord;
                end
            endcase
        end
    end

    // 加减法处理

    // 注意：只有减法需要考虑补码，加法不需要考虑什么补码不补码的
    assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SLT_OP) || (aluop_i == `EXE_BLT_OP) || (aluop_i == `EXE_BGE_OP)) ? 
                        (~reg2_i) + 1 : reg2_i;

    // 一步到位，实现了加、减以及比较运算
    assign result_sum = reg1_i + reg2_i_mux;

    assign reg1_lt_reg2 = (aluop_i == `EXE_SLT_OP || aluop_i == `EXE_BLT_OP || aluop_i == `EXE_BGE_OP) ? 
                                    ((reg1_i[31] && !reg2_i[31]) || 
                                    (!reg1_i[31] && !reg2_i[31] && result_sum[31]) || 
                                    (reg1_i[31] && reg2_i[31] && result_sum[31])) : (reg1_i < reg2_i);

    assign reg1_eq_reg2 = (reg1_i == reg2_i);

    assign reg1_i_not = ~reg1_i;

    always @(*) begin 
        if (rst == `RstEnable) begin
            arithmeticres <= `ZeroWord;
        end else begin 
            case (aluop_i)
                `EXE_SLT_OP, `EXE_SLTU_OP: begin 
                    arithmeticres <= reg1_lt_reg2;
                end
                `EXE_ADD_OP: begin 
                    arithmeticres <= result_sum;
                end
                `EXE_SUB_OP: begin
                    arithmeticres <= result_sum;
                end
                default : begin 
                    arithmeticres <= `ZeroWord;
                end
            endcase
        end
    end

    // 乘法处理

    assign opdata1_mult = ((aluop_i == `EXE_MUL_OP || aluop_i == `EXE_MULH_OP) && reg1_i[31]) ? (~reg1_i + 1) : reg1_i;
    assign opdata2_mult = ((aluop_i == `EXE_MUL_OP || aluop_i == `EXE_MULH_OP) && reg2_i[31]) ? (~reg2_i + 1) : reg2_i;

    assign mulres_temp = opdata1_mult * opdata2_mult;

    // 对乘法结果进行修正
    always @(*) begin 
        if (rst == `RstEnable) begin
            mulres <= {`ZeroWord, `ZeroWord};
        end else if (aluop_i == `EXE_MULH_OP) begin
            // 有符号乘法，正负得负
            if (reg1_i[31] ^ reg2_i[31] == 1'b1) begin
                mulres <= ~mulres_temp + 1;
            // 有符号乘法同号的情况
            end else begin 
                mulres <= mulres_temp;
            end
        end else begin 
            // 无符号乘法
            mulres <= mulres_temp;
        end
    end

    // 此处判断分支是否真正taken
    assign branch_taken = (aluop_i == `EXE_BEQ_OP && reg1_eq_reg2) || (aluop_i == `EXE_BNE_OP && !reg1_eq_reg2) ||
                          ((aluop_i == `EXE_BLT_OP || aluop_i == `EXE_BLTU_OP) && reg1_lt_reg2) || 
                          ((aluop_i == `EXE_BGE_OP || aluop_i == `EXE_BGEU_OP) && !reg1_lt_reg2);

    // 此处有两种需要冲刷流水线的情况：
    // 1. IF段预测不跳但是实际要跳，这种情况要把分支目标地址送入PC
    // 2. IF段预测跳但是实际不跳，这种情况要把链接地址送入PC
    always @(*) begin 
        if (alusel_i == `EXE_RES_JUMP_BRANCH && prdt_taken && !branch_taken) begin
            flush_o             <= 1'b1;
            flush_target_address_o    <= link_address_i;
        end else if (alusel_i == `EXE_RES_JUMP_BRANCH && !prdt_taken && branch_taken) begin
            flush_o             <= 1'b1;
            flush_target_address_o    <= {{19{branch_offset_12_i[11]}}, branch_offset_12_i[11:0], 1'b0} + pc_i;
            // flush_target_address_o  <= pc_i + branch_offset;
        end else begin 
            flush_o             <= 1'b0;
            flush_target_address_o    <= `ZeroWord;
        end
    end

    // 根据 alusel_i 选择最终运算结果
    always @(*) begin 
        wd_o    <= wd_i;
        // RISC-V 不判断溢出
        wreg_o  <= wreg_i;
        
        case (alusel_i)
            `EXE_RES_LOGIC: begin 
                wdata_o <= logicout;
            end
            `EXE_RES_SHIFT: begin 
                wdata_o <= shiftres;
            end
            `EXE_RES_ARITHMETIC: begin 
                wdata_o <= arithmeticres;
            end
            `EXE_RES_MUL: begin 
                wdata_o <= mulres[31:0];
            end
            `EXE_RES_MULH: begin 
                wdata_o <= mulres[63:32];
            end
            `EXE_RES_JUMP_BRANCH: begin 
                wdata_o <= link_address_i;
            end
            default : begin 
                wdata_o <= `ZeroWord;
            end
        endcase
    end

endmodule
