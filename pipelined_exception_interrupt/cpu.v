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

// if_stage
wire [31: 0] irom_adr;
wire irom_en;
wire [`IF_TO_ID_BUS_WIDTH - 1: 0] if_to_id_bus;
wire if_to_id_valid;

// id_stage
wire [`ID_TO_EX_BUS_WIDTH - 1: 0] id_to_ex_bus;
wire [11: 0] csr_raddr;
wire id_allow_in;
wire id_to_ex_valid;

// ex_stage
wire [31: 0] dram_adr;
wire [1: 0] dram_w_op;
wire dram_we;
wire [31: 0] dram_wdin;
wire [`EX_TO_ID_BUS_WIDTH - 1: 0] ex_to_id_bus;
wire [`EX_TO_MEM_BUS_WIDTH - 1: 0] ex_to_mem_bus;
wire csr_we;
wire [11: 0] csr_waddr;
wire [31: 0] csr_wdata;
wire br_taken_to_controller;
wire [31: 0] br_target_to_controller;
wire ex_allow_in;
wire ex_to_mem_valid;

// mem_stage
wire [`MEM_TO_ID_BUS_WIDTH - 1: 0] mem_to_id_bus;
wire [`MEM_TO_WB_BUS_WIDTH - 1: 0] mem_to_wb_bus;
wire mem_allow_in;
wire mem_to_wb_valid;

// wb_stage
wire [`WB_TO_ID_BUS_WIDTH - 1: 0] wb_to_id_bus;
wire wb_allow_in;

// controller
wire br_taken_from_controller;
wire [31: 0] br_target_from_controller;

// csr
wire [31: 0] csr_rdata;

// irom
wire [31: 0] irom_inst;

// dram
wire [31: 0] dram_rdo;

if_stage if_stage_inst (
             // input
             .clk(clk),
             .rst_n(rst_n),
             // from controller
             .br_taken(br_taken_from_controller),
             .br_target(br_target_from_controller),
             .id_allow_in(id_allow_in),

             // output
             .irom_adr(irom_adr),
             .irom_en(irom_en),
             .if_to_id_bus(if_to_id_bus),
             .if_to_id_valid(if_to_id_valid)
         );

id_stage id_stage_inst(
             // input
             .clk(clk),
             .rst_n(rst_n),
             .irom_inst(irom_inst),
             .if_to_id_bus(if_to_id_bus),
             .ex_to_id_bus(ex_to_id_bus),
             .mem_to_id_bus(mem_to_id_bus),
             .wb_to_id_bus(wb_to_id_bus),
             .csr_rdata(csr_rdata),
             // from controller
             .br_taken(br_taken_from_controller),
             .if_to_id_valid(if_to_id_valid),
             .ex_allow_in(ex_allow_in),

             // output
             .id_to_ex_bus(id_to_ex_bus),
             .csr_raddr(csr_raddr),
             .id_allow_in(id_allow_in),
             .id_to_ex_valid(id_to_ex_valid)
         );

ex_stage ex_stage_inst(
             // input
             .clk(clk),
             .rst_n(rst_n),
             .id_to_ex_bus(id_to_ex_bus),
             // from csr
             .id_to_ex_valid(id_to_ex_valid),
             .mem_allow_in(mem_allow_in),

             // output
             .dram_adr(dram_adr),
             .dram_w_op(dram_w_op),
             .dram_we(dram_we),
             .dram_wdin(dram_wdin),
             .ex_to_id_bus(ex_to_id_bus),
             .ex_to_mem_bus(ex_to_mem_bus),
             // to csr
             .csr_we(csr_we),
             .csr_waddr(csr_waddr),
             .csr_wdata_o(csr_wdata),
             // to controller
             .br_taken(br_taken_to_controller),
             .br_target(br_target_to_controller),
             .ex_allow_in(ex_allow_in),
             .ex_to_mem_valid(ex_to_mem_valid)
         );

mem_stage mem_stage_inst(
              // input
              .clk(clk),
              .rst_n(rst_n),
              .dram_rdo(dram_rdo),
              .ex_to_mem_bus(ex_to_mem_bus),
              .ex_to_mem_valid(ex_to_mem_valid),
              .wb_allow_in(wb_allow_in),

              // output
              .mem_to_id_bus(mem_to_id_bus),
              .mem_to_wb_bus(mem_to_wb_bus),
              .mem_allow_in(mem_allow_in),
              .mem_to_wb_valid(mem_to_wb_valid)
          );

wb_stage wb_stage_inst(
             // input
             .clk(clk),
             .rst_n(rst_n),
             .mem_to_wb_bus(mem_to_wb_bus),
             .mem_to_wb_valid(mem_to_wb_valid),

             // output
             .wb_to_id_bus(wb_to_id_bus),
             .wb_allow_in(wb_allow_in)
         );

controller controller_inst(
               // input
               // from ex_stage
               .br_taken_i(br_taken_to_controller),
               .br_target_i(br_target_to_controller),
               .hold_flag_clint_i(),

               // output
               .br_taken_o(br_taken_from_controller),
               .br_target_o(br_target_from_controller),
               .hold_flag()
           );

csr csr_inst(
        // input
        .clk(clk),
        .rst_n(rst_n),
        // from id_stage
        .csr_raddr(csr_raddr),
        // from ex_stage
        .csr_we(csr_we),
        .csr_waddr(csr_waddr),
        .csr_wdata(csr_wdata),

        // output
        // to id_stage
        .csr_rdata(csr_rdata)
    );

irom #(
         .IROM_FILE(IROM_FILE)
     ) irom_instance(
         // input
         .clk(clk),
         .irom_en(irom_en),
         .adr(irom_adr),

         // output
         .inst(irom_inst)
     );

dram dram_inst(
         // input
         .clk(clk),
         .adr(dram_adr),
         .op(dram_w_op),
         .we(dram_we),
         .wdin(dram_wdin),

         // output
         .rdo(dram_rdo)
     );

endmodule
