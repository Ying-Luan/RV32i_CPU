`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/02 22:17:29
// Design Name: 
// Module Name: ID
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

module ID(
    input wire clk,
    input wire [2:0] sext_op,
    input wire rf_we,
    input wire [1:0] rf_wsel,
    input wire [31:0] inst,
    input wire [31:0] aluc,
    input wire [31:0] pc,
    input wire [31:0] pc4,
    input wire [31:0] mem_data,

    output wire [31:0] rD1,
    output wire [31:0] rD2,
    output wire [31:0] ext,
    output wire [31:0] pc_out,
    output wire [31:0] pc4_out
    );

    reg [31:0] wD;

    assign pc_out = pc;
    assign pc4_out = pc4;

    always @(*) begin
        case (rf_wsel)
            `WB_ALU: wD = aluc;
            `WB_EXT: wD = ext;
            `WB_PC4: wD = pc4;
            `WB_MEM: wD = mem_data;
            default: wD = 32'b0;
        endcase
    end

    SEXT sext_inst(
        .op(sext_op),
        .din(inst),

        .ext(ext)
    );

    RF rf_inst(
        .clk(clk),
        .rR1(inst[19:15]),
        .rR2(inst[24:20]),
        .wR(inst[11:7]),
        .we(rf_we),
        .wD(wD),

        .rD1(rD1),
        .rD2(rD2)
    );
endmodule
