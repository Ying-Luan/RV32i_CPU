`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/06/02 21:54:35
// Design Name:
// Module Name: RF
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


module rf(
           input wire clk,
           input wire [4: 0] rR1,
           input wire [4: 0] rR2,
           input wire [4: 0] wR,
           input wire we,
           input wire [31: 0] wD,

           output wire [31: 0] rD1,
           output wire [31: 0] rD2
       );

reg [31: 0] regs [0: 31];
integer i;
initial
begin
    for (i = 0; i < 32; i = i + 1)
    begin
        regs[i] = 32'h0000_0000;
    end
end

always @(posedge clk)
begin
    if (we && wR != 5'b0)
    begin
        regs[wR] <= wD;
    end
end

assign rD1 = regs[rR1];
assign rD2 = regs[rR2];
endmodule
