`include "defines.v"

module mem (
    input wire rst,

    input wire[`RegAddrBus]     wd_i,
    input wire                  wreg_i,
    input wire[`RegBus]         wdata_i,
    input wire[`AluOpBus]       aluop_i,
    input wire[`RegBus]         mem_addr_i,
    input wire[`RegBus]         reg2_i,

    input wire[`RegBus]         mem_data_i,

    output reg[`RegAddrBus]     wd_o,
    output reg                  wreg_o,
    output reg[`RegBus]         wdata_o,
    output reg[`RegBus]         mem_addr_o,
    output wire                 mem_we_o,
    output reg[3:0]             mem_sel_o,
    output reg[`RegBus]         mem_data_o,
    output reg                  mem_ce_o
);
    reg mem_we;
    assign mem_we_o = mem_we;

    always @(*) begin 
        if (rst == `RstEnable) begin 
            wd_o    <= `NOPRegAddr;
            wreg_o  <= `WriteDisable;
            wdata_o <= `ZeroWord;
            mem_addr_o  <= `ZeroWord;
            mem_we      <= `WriteDisable;
            mem_sel_o   <= 4'b0000;
            mem_data_o  <= `ZeroWord;
            mem_ce_o    <= `ChipDisable;
        end else begin 
            wd_o    <= wd_i;
            wreg_o  <= wreg_i;
            wdata_o <= wdata_i;
            mem_addr_o  <= `ZeroWord;
            mem_we      <= `WriteDisable;
            mem_sel_o   <= 4'b0000;
            mem_data_o  <= `ZeroWord;
            mem_ce_o    <= `ChipDisable;
            case (aluop_i)
                `EXE_LB_OP: begin 
                    mem_addr_o  <= mem_addr_i;
                    mem_we      <= `WriteDisable;
                    mem_ce_o    <= `ChipEnable;
                    case (mem_addr_i[1:0])
                        2'b00: begin 
                            wdata_o     <= {{24{mem_data_i[31]}}, mem_data_i[7:0]};
                            mem_sel_o   <= 4'b0001;
                        end
                        2'b01: begin 
                            wdata_o     <= {{24{mem_data_i[23]}}, mem_data_i[15:8]};
                            mem_sel_o   <= 4'b0010;
                        end
                        2'b10: begin 
                            wdata_o     <= {{24{mem_data_i[15]}}, mem_data_i[23:16]};
                            mem_sel_o   <= 4'b0100;
                        end
                        2'b11: begin 
                            wdata_o     <= {{24{mem_data_i[7]}}, mem_data_i[31:24]};
                            mem_sel_o   <= 4'b1000;
                        end
                        default : begin 
                            wdata_o     <= `ZeroWord;
                        end
                    endcase
                end
                `EXE_LBU_OP: begin 
                    mem_addr_o  <= mem_addr_i;
                    mem_we      <= `WriteDisable;
                    mem_ce_o    <= `ChipEnable;
                    case (mem_addr_i[1:0])
                        2'b00: begin 
                            wdata_o     <= {24'b0, mem_data_i[7:0]};
                            mem_sel_o   <= 4'b0001;
                        end
                        2'b01: begin 
                            wdata_o     <= {24'b0, mem_data_i[15:8]};
                            mem_sel_o   <= 4'b0010;
                        end
                        2'b10: begin 
                            wdata_o     <= {24'b0, mem_data_i[23:16]};
                            mem_sel_o   <= 4'b0100;
                        end
                        2'b11: begin 
                            wdata_o     <= {24'b0, mem_data_i[31:24]};
                            mem_sel_o   <= 4'b1000;
                        end
                        default : /* default */;
                    endcase
                end
                `EXE_LH_OP: begin 
                    mem_addr_o  <= mem_addr_i;
                    mem_we      <= `WriteDisable;
                    mem_ce_o    <= `ChipEnable;
                    case (mem_addr_i[1:0])
                        2'b00: begin 
                            wdata_o     <= {{16{mem_data_i[31]}}, mem_data_i[15:0]};
                            mem_sel_o   <= 4'b0011;
                        end
                        2'b10: begin 
                            wdata_o     <= {{16{mem_data_i[15]}}, mem_data_i[31:16]};
                            mem_sel_o   <= 4'b1100;
                        end
                        default : begin 
                            wdata_o     <= `ZeroWord;
                        end
                    endcase
                end
                `EXE_LHU_OP: begin 
                    mem_addr_o  <= mem_addr_i;
                    mem_we      <= `WriteDisable;
                    mem_ce_o    <= `ChipEnable;
                    case (mem_addr_i[1:0])
                        2'b00: begin 
                            wdata_o     <= {16'b0, mem_data_i[15:0]};
                            mem_sel_o   <= 4'b0011;
                        end
                        2'b10: begin 
                            wdata_o     <= {16'b0, mem_data_i[31:16]};
                            mem_sel_o   <= 4'b1100;
                        end
                        default : begin 
                            wdata_o     <= `ZeroWord;
                        end
                    endcase
                end
                `EXE_LW_OP: begin 
                    mem_addr_o  <= mem_addr_i;
                    mem_we      <= `WriteDisable;
                    mem_ce_o    <= `ChipEnable;
                    wdata_o     <= mem_data_i;
                    mem_sel_o   <= 4'b1111;
                end
                `EXE_SB_OP: begin 
                    mem_addr_o  <= mem_addr_i;
                    mem_we      <= `WriteEnable;
                    mem_data_o  <= {reg2_i[7:0], reg2_i[7:0], reg2_i[7:0], reg2_i[7:0]};
                    mem_ce_o    <= `ChipEnable;
                    case (mem_addr_i[1:0])
                        2'b00: begin 
                            mem_sel_o <= 4'b0001;
                        end
                        2'b01: begin 
                            mem_sel_o <= 4'b0010;
                        end
                        2'b10: begin 
                            mem_sel_o <= 4'b0100;
                        end
                        2'b11: begin 
                            mem_sel_o <= 4'b1000;
                        end
                        default : begin 
                            mem_sel_o <= 4'b0000;
                        end
                    endcase
                end
                `EXE_SH_OP: begin 
                    mem_addr_o  <= mem_addr_i;
                    mem_we      <= `WriteEnable;
                    mem_data_o  <= {reg2_i[15:0], reg2_i[15:0]};
                    mem_ce_o    <= `ChipEnable;
                    case (mem_addr_i[1:0])
                        2'b00: begin 
                            mem_sel_o <= 4'b0011;
                        end
                        2'b10: begin 
                            mem_sel_o <= 4'b1100;
                        end
                        default : begin 
                            mem_sel_o <= 4'b0000;
                        end
                    endcase
                end
                `EXE_SW_OP: begin 
                    mem_addr_o  <= mem_addr_i;
                    mem_we      <= `WriteEnable;
                    mem_data_o  <= reg2_i;
                    mem_ce_o    <= `ChipEnable;
                    mem_sel_o   <= 4'b1111;
                end
                default : /* default */;
            endcase
        end
    end

endmodule
