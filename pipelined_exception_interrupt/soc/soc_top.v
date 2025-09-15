`timescale 1ns / 1ps

`include "../core/defines.v"

module soc_top #(
           parameter IROM_FILE = "IROM.hex"
       )(
           // input
           input wire clk,
           input wire rst_n
       );

// cpu master0
wire int_flag;
wire master0_request;
wire master0_we;
wire [31: 0] master0_adr;
wire [31: 0] master0_wdata;
wire [`RAM_W_OP_WIDTH - 1: 0] dram_w_op;

// dram slave0
wire [31: 0] slave0_rdata;

// timer slave1
wire [31: 0] slave1_rdata;
wire int_flag_timer;

// sys_bus
wire [31: 0] master0_rdata;
wire slave0_we;
wire [31: 0] slave0_adr;
wire [31: 0] slave0_wdata;
wire slave1_we;
wire [31: 0] slave1_adr;
wire [31: 0] slave1_wdata;

assign int_flag = int_flag_timer;

cpu #(
        .IROM_FILE(IROM_FILE)
    ) cpu_inst(
        // input
        .clk(clk),
        .rst_n(rst_n),
        // from sys_bus
        .sys_bus_rdata(master0_rdata),
        .int_flag_i(int_flag),

        // output
        // to sys_bus
        .sys_bus_request(master0_request),
        .sys_bus_we(master0_we),
        .sys_bus_adr(master0_adr),
        .sys_bus_wdata(master0_wdata),
        .dram_w_op(dram_w_op)
    );

dram dram_inst(
         // input
         .clk(clk),
         .rst_n(rst_n),
         .adr(slave0_adr),
         .op(dram_w_op),
         .we(slave0_we),
         .wdin(slave0_wdata),

         // output
         .rdo(slave0_rdata)
     );

timer timer_inst(
          // input
          .clk(clk),
          .rst_n(rst_n),
          // from sys_bus
          .timer_we(slave1_we),
          .timer_adr(slave1_adr),
          .timer_wdata(slave1_wdata),

          // output
          // to sys_bus
          .timer_rdata(slave1_rdata),
          .int_sig_o(int_flag_timer)
      );

sys_bus sys_bus_inst(
            // input
            .clk(clk),
            .rst_n(rst_n),
            // from master0
            .master0_request(master0_request),
            .master0_we(master0_we),
            .master0_adr(master0_adr),
            .master0_wdata(master0_wdata),
            // from master1
            .master1_request(),
            .master1_we(),
            .master1_adr(),
            .master1_wdata(),
            // from slave0
            .slave0_rdata(slave0_rdata),
            // from slave1
            .slave1_rdata(slave1_rdata),

            // output
            // to master0
            .master0_rdata(master0_rdata),
            // to master1
            .master1_rdata(),
            // to slave0
            .slave0_we(slave0_we),
            .slave0_adr(slave0_adr),
            .slave0_wdata(slave0_wdata),
            // to slave1
            .slave1_we(slave1_we),
            .slave1_adr(slave1_adr),
            .slave1_wdata(slave1_wdata),
            .hold_flag()  // TODO: not used
        );

endmodule
