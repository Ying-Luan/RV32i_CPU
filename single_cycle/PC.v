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


module PC(
    input wire clk,
    input wire rst,
    input wire [31:0] din,
    
    output reg [31:0] pc
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'h0000_0000;
        end else begin
            pc <= din;
        end
    end
endmodule
