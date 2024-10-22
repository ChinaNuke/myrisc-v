`include "defines.v"

module pc_reg(
    input wire clk,
    input wire rst,

    input wire[5:0] stall,

    input wire                  flush_i,
    input wire[`RegBus]         flush_target_address_i,

    input wire                  prdt_taken_i,
    input wire[`RegBus]         prdt_target_address_i,

    output reg[`InstAddrBus]    pc,
    output reg                  ce
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ce <= `ChipDisable;
        end else begin
            ce <= `ChipEnable;
        end
    end

    always @ (posedge clk) begin
        if (ce == `ChipDisable) begin
            pc <= 32'h00000000;
        end else if (stall[0] == `NoStop)begin  // stall[0]为Stop时PC保持不变
            if (flush_i == 1'b1) begin 
                pc <= flush_target_address_i;
            end else if (prdt_taken_i == `Branch) begin
                pc <= prdt_target_address_i;
            end else begin 
                pc <= pc + 4'h4;
            end
        end
    end
    
endmodule