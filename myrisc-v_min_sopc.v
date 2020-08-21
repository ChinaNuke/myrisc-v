`include "defines.v"

module mymips_min_sopc (
    input wire clk,
    input wire rst
);

    wire[`InstAddrBus]  inst_addr;
    wire[`InstBus]      inst;
    wire                rom_ce;

    mymips mymips0(
        .clk(clk), .rst(rst),
        .rom_addr_o(inst_addr), .rom_data_i(inst),
        .rom_ce_o(rom_ce)
    );

    inst_rom inst_rom0(
        .ce(rom_ce),
        .addr(inst_addr), .inst(inst)
    );

endmodule