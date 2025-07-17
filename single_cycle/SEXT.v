`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/02 22:02:05
// Design Name: 
// Module Name: SEXT
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

module SEXT(
    input wire [2:0] op,
    input wire [31:0] din,

    output reg [31:0] ext
    );

    always @(*) begin
        case (op)
            `EXT_I: ext = {{20{din[31]}}, din[31:20]};
            `EXT_S: ext = {{20{din[31]}}, din[31:25], din[11:7]};
            `EXT_B: ext = {{19{din[31]}}, din[31], din[7], din[30:25], din[11:8], 1'b0};
            `EXT_U: ext = {din[31:12], 12'b0};
            `EXT_J: ext = {{11{din[31]}}, din[31], din[19:12], din[20], din[30:21], 1'b0};
            default: ext = 32'b0;
        endcase
    end
endmodule
