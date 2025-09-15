`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/06/03 15:47:23
// Design Name:
// Module Name: ALU
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

`include "../defines.v"

module alu(
           input wire [3: 0] op,
           input wire [2: 0] f_op,
           input wire [31: 0] A,
           input wire [31: 0] B,

           output reg [31: 0] C,
           output reg f
       );

always @( * )
begin
    case (f_op)
        `F_BEQ:
            f = (A == B) ? 1'b1 : 1'b0;
        `F_BNE:
            f = (A != B) ? 1'b1 : 1'b0;
        `F_BLT:
            f = ($signed(A) < $signed(B)) ? 1'b1 : 1'b0;
        `F_BLTU:
            f = (A < B) ? 1'b1 : 1'b0;
        `F_BGE:
            f = ($signed(A) >= $signed(B)) ? 1'b1 : 1'b0;
        `F_BGEU:
            f = (A >= B) ? 1'b1 : 1'b0;
        default:
            f = 1'b0;
    endcase
end

always @( * )
begin
    case (op)
        `ALU_ADD:
            C = $signed(A) + $signed(B);  // signed can be removed
        `ALU_SUB:
            C = $signed(A) - $signed(B);  // signed can be removed
        `ALU_AND:
            C = A & B;
        `ALU_OR:
            C = A | B;
        `ALU_XOR:
            C = A ^ B;
        `ALU_SLL:
            C = A << B[4: 0];
        `ALU_SRL:
            C = A >> B[4: 0];
        `ALU_SRA:
            C = $signed(A) >>> B[4: 0];
        `ALU_SLT:
            C = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
        `ALU_SLTU:
            C = (A < B) ? 32'b1 : 32'b0;
        default:
            C = 32'b0;
    endcase
end
endmodule
