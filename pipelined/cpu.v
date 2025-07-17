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

`include "defines.v"

module cpu #(
           parameter IROM_FILE = "IROM.hex"
       )(
           input wire clk,
           input wire rst_n
       );

// IF
wire [31: 0] irom_adr;
wire irom_en;
wire [`IF_TO_ID_BUS_WIDTH - 1: 0] if_to_id_bus;
wire if_to_id_valid;

// ID
wire [`ID_TO_EX_BUS_WIDTH - 1: 0] id_to_ex_bus;
wire id_allow_in;
wire id_to_ex_valid;

// EX
wire [31: 0] dram_adr;
wire [1: 0] dram_w_op;
wire dram_we;
wire [31: 0] dram_wdin;
wire [`EX_TO_IF_BUS_WIDTH - 1: 0] ex_to_if_bus;
wire [`EX_TO_ID_BUS_WIDTH - 1: 0] ex_to_id_bus;
wire [`EX_TO_MEM_BUS_WIDTH - 1: 0] ex_to_mem_bus;
wire ex_allow_in;
wire ex_to_mem_valid;

// MEM
wire [`MEM_TO_ID_BUS_WIDTH - 1: 0] mem_to_id_bus;
wire [`MEM_TO_WB_BUS_WIDTH - 1: 0] mem_to_wb_bus;
wire mem_allow_in;
wire mem_to_wb_valid;

// WB
wire [`WB_TO_ID_BUS_WIDTH - 1: 0] wb_to_id_bus;
wire wb_allow_in;

// IROM
wire [31: 0] inst;

// DRAM
wire [31: 0] dram_rdo;

IF if_inst (
       .clk(clk),
       .rst_n(rst_n),
       .ex_to_if_bus(ex_to_if_bus),
       .id_allow_in(id_allow_in),

       .irom_adr(irom_adr),
       .irom_en(irom_en),
       .if_to_id_bus(if_to_id_bus),
       .if_to_id_valid(if_to_id_valid)
   );

ID id_inst(
       .clk(clk),
       .rst_n(rst_n),
       .irom_inst(inst),
       .if_to_id_bus(if_to_id_bus),
       .ex_to_id_bus(ex_to_id_bus),
       .mem_to_id_bus(mem_to_id_bus),
       .wb_to_id_bus(wb_to_id_bus),
       .if_to_id_valid(if_to_id_valid),
       .ex_allow_in(ex_allow_in),

       .id_to_ex_bus(id_to_ex_bus),
       .id_allow_in(id_allow_in),
       .id_to_ex_valid(id_to_ex_valid)
   );

EX ex_inst(
       .clk(clk),
       .rst_n(rst_n),
       .id_to_ex_bus(id_to_ex_bus),
       .id_to_ex_valid(id_to_ex_valid),
       .mem_allow_in(mem_allow_in),

       .dram_adr(dram_adr),
       .dram_w_op(dram_w_op),
       .dram_we(dram_we),
       .dram_wdin(dram_wdin),
       .ex_to_if_bus(ex_to_if_bus),
       .ex_to_id_bus(ex_to_id_bus),
       .ex_to_mem_bus(ex_to_mem_bus),
       .ex_allow_in(ex_allow_in),
       .ex_to_mem_valid(ex_to_mem_valid)
   );

MEM mem_inst(
        .clk(clk),
        .rst_n(rst_n),
        .dram_rdo(dram_rdo),
        .ex_to_mem_bus(ex_to_mem_bus),
        .ex_to_mem_valid(ex_to_mem_valid),
        .wb_allow_in(wb_allow_in),

        .mem_to_id_bus(mem_to_id_bus),
        .mem_to_wb_bus(mem_to_wb_bus),
        .mem_allow_in(mem_allow_in),
        .mem_to_wb_valid(mem_to_wb_valid)
    );

WB wb_inst(
       .clk(clk),
       .rst_n(rst_n),
       .mem_to_wb_bus(mem_to_wb_bus),
       .mem_to_wb_valid(mem_to_wb_valid),

       .wb_to_id_bus(wb_to_id_bus),
       .wb_allow_in(wb_allow_in)
   );

IROM #(
         .IROM_FILE(IROM_FILE)
     ) irom_inst(
         .clk(clk),
         .irom_en(irom_en),
         .adr(irom_adr),

         .inst(inst)
     );

DRAM dram_inst(
         .clk(clk),
         .adr(dram_adr),
         .op(dram_w_op),
         .we(dram_we),
         .wdin(dram_wdin),

         .rdo(dram_rdo)
     );

endmodule
