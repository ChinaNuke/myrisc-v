`include "defines.v"

module if_id(
    input wire                  clk,
    input wire                  rst,
    input wire                  flush,
    input wire[5:0]             stall,
    input wire [`InstAddrBus]   if_pc,
    input wire [`InstBus]       if_inst,
    input wire                  if_prdt_taken,

    output reg[`InstAddrBus]    id_pc,
    output reg[`InstBus]        id_inst,
    output reg                  id_prdt_taken
);

    always @(posedge clk) begin
        if (rst == `RstEnable || flush == 1'b1) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
            id_prdt_taken <= 1'b0;
        end else if (stall[1] == `Stop && stall[2] == `NoStop) begin
            // IF段暂停，ID段不暂停
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
            id_prdt_taken <= 1'b0;
        end else if (stall[1] == `NoStop) begin
            id_pc <= if_pc;
            id_inst <= if_inst;
            id_prdt_taken <= if_prdt_taken;
        end
    end
endmodule
