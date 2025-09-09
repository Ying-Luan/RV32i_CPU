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

// from if_stage
wire [31: 0] irom_adr;
wire irom_en;
wire [`IF_TO_ID_BUS_WIDTH - 1: 0] if_to_id_bus;
wire if_to_id_valid;

// from id_stage
wire [`ID_TO_EX_BUS_WIDTH - 1: 0] id_to_ex_bus;
wire [11: 0] csr_raddr;
wire [`EXC_STATUS_WIDTH - 1: 0] exc_status;
wire [31: 0] inst_addr;
wire id_allow_in;
wire id_to_ex_valid;

// from ex_stage
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

// from mem_stage
wire [`MEM_TO_ID_BUS_WIDTH - 1: 0] mem_to_id_bus;
wire [`MEM_TO_WB_BUS_WIDTH - 1: 0] mem_to_wb_bus;
wire mem_allow_in;
wire mem_to_wb_valid;

// from wb_stage
wire [`WB_TO_ID_BUS_WIDTH - 1: 0] wb_to_id_bus;
wire wb_allow_in;

// from controller
wire br_taken_from_controller;
wire [31: 0] br_target_from_controller;
wire hold_flag_if;
wire hold_flag_id;
wire hold_flag_ex;
wire hold_flag_mem;
wire hold_flag_wb;

// from csr
wire [31: 0] csr_rdata;
wire [31: 0] csr_mtvec;
wire [31: 0] csr_mepc;
wire [31: 0] csr_mstatus;

// from clint
wire hold_flag_clint;
wire csr_we_clint;
wire [`CSR_ADDRESS_WIDTH - 1: 0] csr_waddr_clint;
wire [31: 0] csr_wdata_clint;
wire int_assert;
wire [31: 0] int_addr;

// from irom
wire [31: 0] irom_inst;

// from dram
wire [31: 0] dram_rdo;

if_stage if_stage_inst (
             // input
             .clk(clk),
             .rst_n(rst_n),
             // from controller
             .br_taken(br_taken_from_controller),
             .br_target(br_target_from_controller),
             .hold_flag_if(hold_flag_if),
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
             .hold_flag_id(hold_flag_id),
             .if_to_id_valid(if_to_id_valid),
             .ex_allow_in(ex_allow_in),

             // output
             .id_to_ex_bus(id_to_ex_bus),
             .csr_raddr(csr_raddr),
             // to clint
             .exc_status(exc_status),
             .inst_addr(inst_addr),
             .id_allow_in(id_allow_in),
             .id_to_ex_valid(id_to_ex_valid)
         );

ex_stage ex_stage_inst(
             // input
             .clk(clk),
             .rst_n(rst_n),
             .id_to_ex_bus(id_to_ex_bus),
             // from controller
             .hold_flag_ex(hold_flag_ex),
             .id_to_ex_valid(id_to_ex_valid),
             .mem_allow_in(mem_allow_in),
             // from clint
             .int_assert(int_assert),
             .int_addr(int_addr),

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
             .br_taken_o(br_taken_to_controller),
             .br_target_o(br_target_to_controller),
             .ex_allow_in(ex_allow_in),
             .ex_to_mem_valid(ex_to_mem_valid)
         );

mem_stage mem_stage_inst(
              // input
              .clk(clk),
              .rst_n(rst_n),
              .dram_rdo(dram_rdo),
              .ex_to_mem_bus(ex_to_mem_bus),
              // from controller
              .hold_flag_mem(hold_flag_mem),
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
             // from controller
             .hold_flag_wb(hold_flag_wb),
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
               .hold_flag_clint_i(hold_flag_clint),

               // output
               .br_taken_o(br_taken_from_controller),
               .br_target_o(br_target_from_controller),
               .hold_flag_if(hold_flag_if),
               .hold_flag_id(hold_flag_id),
               .hold_flag_ex(hold_flag_ex),
               .hold_flag_mem(hold_flag_mem),
               .hold_flag_wb(hold_flag_wb)
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
        // from clint
        .csr_we_clint(csr_we_clint),
        .csr_waddr_clint(csr_waddr_clint),
        .csr_wdata_clint(csr_wdata_clint),

        // output
        // to id_stage
        .csr_rdata(csr_rdata),
        // to clint
        .csr_mtvec(csr_mtvec),
        .csr_mepc(csr_mepc),
        .csr_mstatus(csr_mstatus)
    );

clint clint_inst(
          // input
          .clk(clk),
          .rst_n(rst_n),
          // from id_stage
          .exc_status(exc_status),
          .inst_addr_i(inst_addr),
          .br_taken(br_taken_to_controller),
          .br_target(br_target_to_controller),
          // from csr
          .csr_mtvec(csr_mtvec),
          .csr_mepc(csr_mepc),
          .csr_mstatus(csr_mstatus),

          // output
          .hold_flag(hold_flag_clint),
          // to csr
          .csr_we(csr_we_clint),
          .csr_waddr(csr_waddr_clint),
          .csr_wdata(csr_wdata_clint),
          .int_assert(int_assert),
          .int_addr(int_addr)
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
