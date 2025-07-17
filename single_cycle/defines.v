`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/04 21:53:21
// Design Name: 
// Module Name: defines
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

// common
`define OPEN  1'b1
`define CLOSE 1'b0

// npc_op
`define NPC_PC4  2'b00
`define NPC_BRA  2'b01
`define NPC_JAL  2'b10
`define NPC_JALR 2'b11

// // npc_base_sel
// `define BASE_RS1 1'b0
// `define BASE_PC  1'b1

// rf_wsel
`define WB_ALU 2'b00
`define WB_EXT 2'b01
`define WB_PC4 2'b10
`define WB_MEM 2'b11

// sext_op
`define EXT_I 3'b000
`define EXT_S 3'b001
`define EXT_B 3'b010
`define EXT_U 3'b011    
`define EXT_J 3'b100

// alu_op
`define ALU_ADD  4'b0000
`define ALU_SUB  4'b0001
`define ALU_AND  4'b0010
`define ALU_OR   4'b0011
`define ALU_XOR  4'b0100
`define ALU_SLL  4'b0101
`define ALU_SRL  4'b0110
`define ALU_SRA  4'b0111
`define ALU_SLT  4'b1000
`define ALU_SLTU 4'b1001

// alu_f_op
`define F_BEQ  3'b000
`define F_BNE  3'b001
`define F_BLT  3'b010
`define F_BLTU 3'b011
`define F_BGE  3'b100
`define F_BGEU 3'b101

// alu_a_sel
`define ALU_A_RS1 1'b0
`define ALU_A_PC  1'b1

// alu_b_sel
`define ALU_B_RS2  1'b0
`define ALU_B_EXT  1'b1

// ram_w_op
`define W_B  2'b00
`define W_H  2'b01
`define W_W  2'b10

// mem_ext_op
`define MEM_EXT_B  3'b000
`define MEM_EXT_BU 3'b001
`define MEM_EXT_H  3'b010
`define MEM_EXT_HU 3'b011
`define MEM_EXT_W  3'b100
