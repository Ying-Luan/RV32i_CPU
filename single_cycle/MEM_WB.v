`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/06 16:49:48
// Design Name: 
// Module Name: MEM_WB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MEM_WB(
    input wire clk,
    input wire [31:0] adr,
    input wire [1:0] ram_w_op,
    input wire ram_we,
    input wire [31:0] ram_wdin,
    input wire [2:0] mem_ext_op,

    output wire [31:0] mem_dout
    );

    wire [31:0] dram_rdo;

    DRAM dram_inst (
        .clk(clk),
        .adr(adr),
        .op(ram_w_op),
        .we(ram_we),
        .wdin(ram_wdin),

        .rdo(dram_rdo)
    );

    MEM_EXT mem_ext_inst (
        .op(mem_ext_op),
        .din(dram_rdo),
        
        .ext(mem_dout)
    );

endmodule
