`include "defines.v"

module ex (
    input wire  rst,

    input wire[`AluOpBus]       aluop_i,
    input wire[`AluSelBus]      alusel_i,
    input wire[`RegBus]         reg1_i,
    input wire[`RegBus]         reg2_i,
    input wire[`RegAddrBus]     wd_i,
    input wire                  wreg_i,

    input wire[`RegBus]         hi_i,
    input wire[`RegBus]         lo_i,

    // 写回阶段数据前推
    input wire[`RegBus]         wb_hi_i,
    input wire[`RegBus]         wb_lo_i,
    input wire                  wb_whilo_i,

    // 访存阶段数据前推
    input wire[`RegBus]         mem_hi_i,
    input wire[`RegBus]         mem_lo_i,
    input wire                  mem_whilo_i,

    output reg[`RegAddrBus]     wd_o,
    output reg                  wreg_o,
    output reg[`RegBus]         wdata_o,

    output reg[`RegBus]         hi_o,
    output reg[`RegBus]         lo_o,
    output reg                  whilo_o
);

    reg[`RegBus] logicout;      // 逻辑运算结果
    reg[`RegBus] shiftres;      // 移位运算结果
    reg[`RegBus] moveres;       // 移动操作结果
    reg[`RegBus] arithmeticres; // 算术运算结果
    reg[`RegBus] HI;            // 保存HI寄存器最新值
    reg[`RegBus] LO;            // 保存LO寄存器最新值

    wire                ov_sum;         // 溢出标志
    wire                reg1_eq_reg2;
    wire                reg1_lt_reg2;
    wire[`RegBus]       reg2_i_mux;     // reg2 的补码
    wire[`RegBus]       reg1_i_not;     // reg1 的反码
    wire[`RegBus]       result_sum;     // 加法结果
    wire[`RegBus]       opdata1_mult;   // 乘法中的被乘数
    wire[`RegBus]       opdata2_mult;   // 乘法中的乘数
    wire[`DoubleRegBus] hilo_temp;      // 临时保存乘法结果
    reg[`DoubleRegBus]  mulres;         // 保存乘法结果

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

    // 实现数据前推，解决数据相关
    always @(*) begin 
        if (rst == `RstEnable) begin 
            {HI, LO} <= {`ZeroWord, `ZeroWord};
        end else if (mem_whilo_i == `WriteEnable) begin
            {HI, LO} <= {mem_hi_i, mem_lo_i};
        end else if (wb_whilo_i == `WriteEnable) begin
            {HI, LO} <= {wb_hi_i, wb_lo_i};
        end else begin 
            {HI, LO} <= {hi_i, lo_i};
        end
    end

    // MFHI / MFLO / MOVN / MOVZ
    always @(*) begin 
        if (rst == `RstEnable) begin
            moveres <= `ZeroWord;
        end else begin
            // moveres <= `ZeroWord;
            case (aluop_i)
                `EXE_MFHI_OP: begin 
                    moveres <= HI;
                end
                `EXE_MFLO_OP: begin 
                    moveres <= LO;
                end
                `EXE_MOVZ_OP: begin 
                    moveres <= reg1_i;
                end
                `EXE_MOVN_OP: begin 
                    moveres <= reg1_i;
                end
                default : begin
                end
            endcase
            
        end
    end

    // 加减法处理

    // 注意：只有减法需要考虑补码，加法不需要考虑什么补码不补码的
    assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SUBU_OP) || (aluop_i == `EXE_SLT_OP)) ? 
                        (~reg2_i) + 1 : reg2_i;

    // 一步到位，实现了加、减以及比较运算，妙啊！
    assign result_sum = reg1_i + reg2_i_mux;

    // 判断溢出
    // 溢出情况两种：1 正数之和结果为负数；2 负数之和结果为正数
    assign ov_sum = (reg1_i[31] && reg2_i_mux[31] && !result_sum[31]) || (!reg1_i[31] && !reg2_i_mux[31] && result_sum[31]);

    // little than??? 这个地方是不是不对（质疑）
    assign reg1_lt_reg2 = (aluop_i == `EXE_SLT_OP) ? 
                                    ((reg1_i[31] && !reg2_i[31]) || 
                                    (!reg1_i[31] && !reg2_i[31] && result_sum[31]) || 
                                    (reg1_i[31] && reg2_i[31] && result_sum[31])) : (reg1_i < reg2_i);

    assign reg1_i_not = ~reg1_i;

    always @(*) begin 
        if (rst == `RstEnable) begin
            arithmeticres <= `ZeroWord;
        end else begin 
            case (aluop_i)
                `EXE_SLT_OP, `EXE_SLTU_OP: begin 
                    arithmeticres <= reg1_lt_reg2;
                end
                `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP: begin 
                    arithmeticres <= result_sum;
                end
                `EXE_SUB_OP, `EXE_SUBU_OP: begin  // 为什么没有 SUBI
                    arithmeticres <= result_sum;
                end
                `EXE_CLZ_OP: begin 
                    // 太傻了这个写法
                    arithmeticres <= reg1_i[31] ? 0 : 
                                     reg1_i[30] ? 1 : 
                                     reg1_i[29] ? 2 :
                                     reg1_i[28] ? 3 :
                                     reg1_i[27] ? 4 : 
                                     reg1_i[26] ? 5 :
                                     reg1_i[25] ? 6 : 
                                     reg1_i[24] ? 7 : 
                                     reg1_i[23] ? 8 : 
                                     reg1_i[22] ? 9 : 
                                     reg1_i[21] ? 10 : 
                                     reg1_i[20] ? 11 :
                                     reg1_i[19] ? 12 : 
                                     reg1_i[18] ? 13 : 
                                     reg1_i[17] ? 14 : 
                                     reg1_i[16] ? 15 : 
                                     reg1_i[15] ? 16 : 
                                     reg1_i[14] ? 17 : 
                                     reg1_i[13] ? 18 : 
                                     reg1_i[12] ? 19 : 
                                     reg1_i[11] ? 20 :
                                     reg1_i[10] ? 21 : 
                                     reg1_i[9] ? 22 : 
                                     reg1_i[8] ? 23 : 
                                     reg1_i[7] ? 24 : 
                                     reg1_i[6] ? 25 : 
                                     reg1_i[5] ? 26 : 
                                     reg1_i[4] ? 27 : 
                                     reg1_i[3] ? 28 : 
                                     reg1_i[2] ? 29 : 
                                     reg1_i[1] ? 30 : 
                                     reg1_i[0] ? 31 : 32;
                end
                `EXE_CLO_OP: begin 
                    arithmeticres <= reg1_i_not[31] ? 0 : 
                                     reg1_i_not[30] ? 1 : 
                                     reg1_i_not[29] ? 2 :
                                     reg1_i_not[28] ? 3 :
                                     reg1_i_not[27] ? 4 : 
                                     reg1_i_not[26] ? 5 :
                                     reg1_i_not[25] ? 6 : 
                                     reg1_i_not[24] ? 7 : 
                                     reg1_i_not[23] ? 8 : 
                                     reg1_i_not[22] ? 9 : 
                                     reg1_i_not[21] ? 10 : 
                                     reg1_i_not[20] ? 11 :
                                     reg1_i_not[19] ? 12 : 
                                     reg1_i_not[18] ? 13 : 
                                     reg1_i_not[17] ? 14 : 
                                     reg1_i_not[16] ? 15 : 
                                     reg1_i_not[15] ? 16 : 
                                     reg1_i_not[14] ? 17 : 
                                     reg1_i_not[13] ? 18 : 
                                     reg1_i_not[12] ? 19 : 
                                     reg1_i_not[11] ? 20 :
                                     reg1_i_not[10] ? 21 : 
                                     reg1_i_not[9] ? 22 : 
                                     reg1_i_not[8] ? 23 : 
                                     reg1_i_not[7] ? 24 : 
                                     reg1_i_not[6] ? 25 : 
                                     reg1_i_not[5] ? 26 : 
                                     reg1_i_not[4] ? 27 : 
                                     reg1_i_not[3] ? 28 : 
                                     reg1_i_not[2] ? 29 : 
                                     reg1_i_not[1] ? 30 : 
                                     reg1_i_not[0] ? 31 : 32;
                end
                default : begin 
                    arithmeticres <= `ZeroWord;
                end
            endcase
        end
    end

    // 乘法处理

    assign opdata1_mult = ((aluop_i == `EXE_MUL_OP || aluop_i == `EXE_MULT_OP) && reg1_i[31]) ? (~reg1_i + 1) : reg1_i;
    assign opdata2_mult = ((aluop_i == `EXE_MUL_OP || aluop_i == `EXE_MULT_OP) && reg2_i[31]) ? (~reg2_i + 1) : reg2_i;

    assign hilo_temp = opdata1_mult * opdata2_mult;

    // 对除法结果进行修正
    always @(*) begin 
        if (rst == `RstEnable) begin
            mulres <= {`ZeroWord, `ZeroWord};
        end else if (aluop_i == `EXE_MULT_OP || aluop_i == `EXE_MUL_OP) begin
            // 有符号乘法，正负得负
            if (reg1_i[31] ^ reg2_i[31] == 1'b1) begin
                mulres <= ~hilo_temp + 1;
            // 有符号乘法同号的情况
            end else begin 
                mulres <= hilo_temp;
            end
        end else begin 
            // 无符号乘法
            mulres <= hilo_temp;
        end
    end

    // 根据 alusel_i 选择最终运算结果
    always @(*) begin 
        wd_o    <= wd_i;

        // 溢出则不写入寄存器
        if ((aluop_i == `EXE_ADD_OP || aluop_i == `EXE_ADDI_OP || aluop_i == `EXE_SUB_OP) && ov_sum == 1'b1) begin
            wreg_o <= `WriteDisable;
        end else begin 
            wreg_o  <= wreg_i;
        end
        
        case (alusel_i)
            `EXE_RES_LOGIC: begin 
                wdata_o <= logicout;
            end
            `EXE_RES_SHIFT: begin 
                wdata_o <= shiftres;
            end
            `EXE_RES_MOVE: begin 
                wdata_o <= moveres;
            end
            `EXE_RES_ARITHMETIC: begin 
                wdata_o <= arithmeticres;
            end
            `EXE_RES_MUL: begin 
                wdata_o <= mulres[31:0];
            end
            default : begin 
                wdata_o <= `ZeroWord;
            end
        endcase
    end

    // 针对 MTHI / MTHO
    always @(*) begin 
        if (rst == `RstEnable) begin
            whilo_o <= `WriteDisable;
            hi_o    <= `ZeroWord;
            lo_o    <= `ZeroWord;
        end else if (aluop_i == `EXE_MTHI_OP) begin
            whilo_o <= `WriteEnable;
            hi_o    <= reg1_i;
            lo_o    <= LO;
        end else if (aluop_i == `EXE_MTLO_OP) begin
            whilo_o <= `WriteEnable;
            hi_o    <= HI;
            lo_o    <= reg1_i;
        end else begin 
            whilo_o <= `WriteDisable;
            hi_o    <= `ZeroWord;
            lo_o    <= `ZeroWord;
        end
    end

endmodule
