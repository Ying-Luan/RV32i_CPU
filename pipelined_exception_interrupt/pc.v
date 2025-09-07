`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/06/02 19:25:24
// Design Name:
// Module Name: PC
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


module pc(
           input wire clk,
           input wire rst_n,
           input wire [31: 0] din,
           input wire if_allow_in,
           input wire pre_if_valid,

           output reg [31: 0] pc
       );

always @(posedge clk)
begin
    if (~rst_n)
    begin
        pc <= 32'hFFFF_FFFC;  // -4，这样第一次+4后就是0
    end
    else if (if_allow_in && pre_if_valid)
    begin
        pc <= din;
    end
end
endmodule
