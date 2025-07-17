`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/03 15:59:20
// Design Name: 
// Module Name: EX
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

module EX(
    input wire [3:0] alu_op,
    input wire [2:0] alu_f_op,
    input wire alu_a_sel,
    input wire alu_b_sel,
    input wire [1:0] npc_op,
    input wire [31:0] rD1,
    input wire [31:0] rD2,
    input wire [31:0] ext,
    input wire [31:0] pc,
    input wire [31:0] pc4,

    output wire [31:0] alu_c,
    output reg [31:0] npc
    );

    reg [31:0] alu_a;
    reg [31:0] alu_b;
    wire alu_f;

    always @(*) begin
        case (npc_op)
            `NPC_PC4:  npc = pc4;
            `NPC_BRA:  npc = alu_f ? pc + ext : pc4;
            `NPC_JAL:  npc = pc + ext;
            `NPC_JALR: npc = rD1 + ext;
        endcase
    end

    always @(*) begin
        case (alu_a_sel)
            `ALU_A_RS1: alu_a = rD1;
            `ALU_A_PC:  alu_a = pc;
            default:    alu_a = 32'b0;
        endcase
    end

    always @(*) begin
        case (alu_b_sel)
            `ALU_B_RS2: alu_b = rD2;
            `ALU_B_EXT: alu_b = ext;
            default:    alu_b = 32'b0;
        endcase
    end

    ALU alu_inst(
        .op(alu_op),
        .f_op(alu_f_op),
        .A(alu_a),
        .B(alu_b),

        .C(alu_c),
        .f(alu_f)
    );    
endmodule
