`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/02 22:16:31
// Design Name: 
// Module Name: IF
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

`include "defines.v"

module IF #(
    parameter ROM_FILE = "IROM.hex"
)(
    input wire clk,
    input wire reset,
    input wire [31:0] npc,

    output wire [31:0] pc,
    output wire [31:0] pc4,
    output wire [31:0] inst
    );

    assign pc4 = pc + 4;

    PC pc_inst(
        .clk(clk),
        .rst(reset),
        .din(npc),

        .pc(pc)
    );

    IROM #(
        .ROM_FILE(ROM_FILE)
    ) irom_inst (
        .adr(pc),

        .inst(inst)
    );

endmodule
