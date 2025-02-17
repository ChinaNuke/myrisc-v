`include "defines.v"

module ctrl (
	input wire		rst,
	input wire		stallreq_from_id,
	input wire		stallreq_from_ex,

	output reg[5:0]	stall
);

	always @(*) begin 
		if (rst == `RstEnable) begin
			stall <= 6'b000000;
		end else if (stallreq_from_ex == `Stop) begin
			stall <= 6'b001111;	// 取指、译码、执行阶段暂停
		end else if (stallreq_from_id == `Stop) begin
			stall <= 6'b000111;	// 取指、译码阶段暂停
		end else begin 
			stall <= 6'b000000;
		end
	end

endmodule
