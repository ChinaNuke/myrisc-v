`include "defines.v"

module ifu (
	input wire 					rst,
	input wire					flush,
	input wire[`InstAddrBus]	pc_i,
    input wire[`InstBus]       	inst_i,

    // input wire[`RegBus]        	reg1_data_i,	// JALR指令要从寄存器端口1读数

    // 执行阶段指令的运算结果
    input wire                 	ex_wreg_i,
    input wire[`RegBus]        	ex_wdata_i,
    input wire[`RegAddrBus]    	ex_wd_i,

    // 访存阶段指令的运算结果
    input wire                 	mem_wreg_i,
    input wire[`RegBus]        	mem_wdata_i,
    input wire[`RegAddrBus]    	mem_wd_i,

    // 这里暂时忽略IF段和ID段同时从1端口读取寄存器的情况
    // output reg                 	reg1_read_o,
    // output reg[`RegAddrBus]    	reg1_addr_o,

    output reg					prdt_taken_o,
    output reg[`InstAddrBus]	prdt_target_address_o,

    output reg[`InstAddrBus]	pc_o,
    output reg[`InstBus]		inst_o
);

	wire[6:0] opcode = inst_i[6:0];
	// wire[4:0] rs1 = inst_i[19:15];
	wire[11:0] branch_offset_12 = {inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8]};
	// wire[11:0] jmp_offset_12 = inst_i[31:20];
	wire[19:0] offset_20 = {inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21]};

	// 偏移量为负数（符号位为1），表示方向为向后跳转，预测跳
	wire prdt_taken = branch_offset_12[11];

	// reg reg1;

	always @(*) begin 
		if (opcode == `RV_OP_BRANCH) begin
			prdt_taken_o			<= prdt_taken;
			prdt_target_address_o 	<= {{19{branch_offset_12[11]}}, branch_offset_12, 1'b0} + pc_i;
		// JAL 和 JALR 直接跳走
		end else if (opcode == `RV_OP_JAL) begin
			prdt_taken_o			<= 1'b1;
			prdt_target_address_o   <= {{11{offset_20[19]}}, offset_20, 1'b0} + pc_i;
		// 暂时没想好怎么解决JALR指令读寄存器的冲突
		// end else if (opcode == `RV_OP_JALR) begin
		// 	reg1_read_o				<= 1'b1;
		// 	reg1_addr_o				<= rs1;
		// 	prdt_taken_o			<= 1'b1;
		// 	prdt_target_address_o   <= {{20{jmp_offset_12[11]}}, jmp_offset_12} + reg1;
		end else begin 
			prdt_taken_o			<= `NotBranch;
			prdt_target_address_o	<= `ZeroWord;
		end
	end

	always @(*) begin 
		if (rst == `RstEnable || flush == 1'b1) begin
			pc_o	<= `ZeroWord;
			inst_o	<= `ZeroWord;
		end else begin 
			pc_o	<= pc_i;
			inst_o	<= inst_i;
		end
	end

	// always @(*) begin 
	// 	if (rst == `RstEnable) begin 
	// 		reg1 	<= `ZeroWord;
	// 	end else if (ex_wreg_i == 1'b1 && ex_wd_i == rs1) begin
	// 		reg1 	<= ex_wdata_i;
	// 	end else if (mem_wreg_i == 1'b1 && mem_wd_i == rs1) begin
	// 		reg1 	<= mem_wdata_i;
	// 	end else begin 
	// 		reg1 	<= reg1_data_i;
	// 	end
	// end

endmodule