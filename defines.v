//全局
`define RstEnable 1'b1
`define RstDisable 1'b0
`define ZeroWord 32'h00000000
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define AluOpBus 7:0
`define AluSelBus 2:0
`define InstValid 1'b0
`define InstInvalid 1'b1
`define Stop 1'b1
`define NoStop 1'b0
`define InDelaySlot 1'b1
`define NotInDelaySlot 1'b0
`define Branch 1'b1
`define NotBranch 1'b0
`define InterruptAssert 1'b1
`define InterruptNotAssert 1'b0
`define TrapAssert 1'b1
`define TrapNotAssert 1'b0
`define True_v 1'b1
`define False_v 1'b0
`define ChipEnable 1'b1
`define ChipDisable 1'b0

// RISC-V
`define RV_OP_IMM 7'b0010011
`define RV_OP 7'b0110011
`define RV_OP_LUI 7'b0110111
`define RV_OP_AUIPC 7'b0010111
`define RV_OP_BRANCH 7'b1100011
`define RV_OP_JAL 7'b1101111
`define RV_OP_JALR 7'b1100111
`define RV_OP_LOAD 7'b0000011
`define RV_OP_STORE 7'b0100011
`define RV_ADD_OR_SUB 3'b000
`define RV_SLL 3'b001
`define RV_SLT 3'b010
`define RV_SLTU 3'b011
`define RV_XOR 3'b100
`define RV_SRL_OR_SRA 3'b101
`define RV_OR 3'b110
`define RV_AND 3'b111

//AluOp
`define EXE_AND_OP   8'b00100100
`define EXE_OR_OP    8'b00100101
`define EXE_XOR_OP  8'b00100110
`define EXE_NOR_OP  8'b00100111
`define EXE_ANDI_OP  8'b01011001
`define EXE_ORI_OP  8'b01011010
`define EXE_XORI_OP  8'b01011011
`define EXE_LUI_OP  8'b01011100   

`define EXE_SLL_OP  8'b01111100
`define EXE_SRL_OP  8'b00000010
`define EXE_SRA_OP  8'b00000011

`define EXE_SLT_OP  8'b00101010
`define EXE_SLTU_OP  8'b00101011
`define EXE_ADD_OP  8'b00100000
`define EXE_SUB_OP  8'b00100010

`define EXE_MUL_OP  8'b10101001
`define EXE_MULH_OP  8'b00011000
`define EXE_MULTU_OP  8'b00011001
`define EXE_MADD_OP  8'b10100110
`define EXE_MADDU_OP  8'b10101000
`define EXE_MSUB_OP  8'b10101010
`define EXE_MSUBU_OP  8'b10101011

// `define EXE_J_OP  8'b01001111
`define EXE_JAL_OP  8'b01010000
`define EXE_JALR_OP  8'b00001001
// `define EXE_JR_OP  8'b00001000
`define EXE_BEQ_OP  8'b01010001
`define EXE_BNE_OP  8'b01010010
// `define EXE_BNE_OP  8'b01000001
`define EXE_BGE_OP  8'b01001011
`define EXE_BGEU_OP  8'b01010100
// `define EXE_BLEZ_OP  8'b01010011
`define EXE_BLT_OP  8'b01000000
`define EXE_BLTU_OP  8'b01001010

`define EXE_LB_OP  8'b11100000
`define EXE_LBU_OP  8'b11100100
`define EXE_LH_OP  8'b11100001
`define EXE_LHU_OP  8'b11100101
`define EXE_LW_OP  8'b11100011
`define EXE_SB_OP  8'b11101000
`define EXE_SH_OP  8'b11101001
`define EXE_SW_OP  8'b11101011

`define EXE_NOP_OP    8'b00000000

//AluSel
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_SHIFT 3'b010
`define EXE_RES_ARITHMETIC 3'b100	
`define EXE_RES_MUL 3'b101
`define EXE_RES_MULH 3'b011
`define EXE_RES_JUMP_BRANCH 3'b110
`define EXE_RES_LOAD_STORE 3'b111

`define EXE_RES_NOP 3'b000


//指令存储器inst_rom
`define InstAddrBus 31:0
`define InstBus 31:0
`define InstMemNum 131071
`define InstMemNumLog2 17

//数据存储器data_ram
`define DataAddrBus 31:0
`define DataBus 31:0
`define DataMemNum 131071
`define DataMemNumLog2 17
`define ByteWidth 7:0

//通用寄存器regfile
`define RegAddrBus 4:0
`define RegBus 31:0
`define RegWidth 32
`define DoubleRegWidth 64
`define DoubleRegBus 63:0
`define RegNum 32
`define RegNumLog2 5
`define NOPRegAddr 5'b00000
