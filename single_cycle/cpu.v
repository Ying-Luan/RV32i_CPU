`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/07 15:40:10
// Design Name: 
// Module Name: cpu
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


module cpu #(
    parameter IROM_FILE = "IROM.hex"
)(
    input wire clk,
    input wire reset
    );

    // Controller signals
    wire [2:0] sext_op;
    wire [1:0] npc_op;
    wire ram_we;
    wire [1:0] ram_w_op;
    wire [2:0] mem_ext_op;
    wire [3:0] alu_op;
    wire [2:0] alu_f_op;
    wire alu_a_sel;
    wire alu_b_sel;
    wire rf_we;
    wire [1:0] rf_wsel;

    // IF
    wire [31:0] pc;
    wire [31:0] pc4;
    wire [31:0] inst;

    // ID
    wire [31:0] rD1;
    wire [31:0] rD2;
    wire [31:0] ext;
    wire [31:0] pc_out;
    wire [31:0] pc4_out;

    // EX
    wire [31:0] alu_c;
    wire [31:0] npc;

    // MEM_WB
    wire [31:0] mem_dout;

    Controller controller_inst(
        .opcode(inst[6:0]),
        .funct3(inst[14:12]),
        .funct7(inst[31:25]),

        .sext_op(sext_op),
        .npc_op(npc_op),
        .ram_we(ram_we),
        .ram_w_op(ram_w_op),
        .mem_ext_op(mem_ext_op),
        .alu_op(alu_op),
        .alu_f_op(alu_f_op),
        .alu_a_sel(alu_a_sel),
        .alu_b_sel(alu_b_sel),
        .rf_we(rf_we),
        .rf_wsel(rf_wsel)
    );

    IF#(
        .ROM_FILE(IROM_FILE)
    ) if_inst (
        .clk(clk),
        .reset(reset),
        .npc(npc),

        .pc(pc),
        .pc4(pc4),
        .inst(inst)
    );

    ID id_inst(
        .clk(~clk),
        .sext_op(sext_op),
        .rf_we(rf_we),
        .rf_wsel(rf_wsel),
        .inst(inst),
        .aluc(alu_c),
        .pc(pc),
        .pc4(pc4),
        .mem_data(mem_dout),

        .rD1(rD1),
        .rD2(rD2),
        .ext(ext),
        .pc_out(pc_out),
        .pc4_out(pc4_out)
    );

    EX ex_inst(
        .alu_op(alu_op),
        .alu_f_op(alu_f_op),
        .alu_a_sel(alu_a_sel),
        .alu_b_sel(alu_b_sel),
        .npc_op(npc_op),
        .rD1(rD1),
        .rD2(rD2),
        .ext(ext),
        .pc(pc_out),
        .pc4(pc4_out),

        .alu_c(alu_c),
        .npc(npc)
    );

    MEM_WB mem_wb_inst(
        .clk(~clk),
        .adr(alu_c),
        .ram_w_op(ram_w_op),
        .ram_we(ram_we),
        .ram_wdin(rD2),
        .mem_ext_op(mem_ext_op),

        .mem_dout(mem_dout)
    );
endmodule
