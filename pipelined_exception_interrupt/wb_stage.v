`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/07/14 08:02:48
// Design Name:
// Module Name: WB
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

module wb_stage(
           input wire clk,
           input wire rst_n,
           input wire [`MEM_TO_WB_BUS_WIDTH - 1: 0] mem_to_wb_bus,
           input wire mem_to_wb_valid,

           output wire [`WB_TO_ID_BUS_WIDTH - 1: 0] wb_to_id_bus,
           output wire wb_allow_in
       );

// input bus
reg [`MEM_TO_WB_BUS_WIDTH - 1: 0] mem_regs;
always @(posedge clk)
begin
    if (wb_allow_in && mem_to_wb_valid)
    begin
        mem_regs <= mem_to_wb_bus;
    end
end

wire rf_we;
wire [4: 0] wb_reg;
wire [31: 0] wb_data;
assign {
        rf_we,
        wb_reg,
        wb_data
    } = mem_regs;

// output bus
reg wb_valid;
wire rf_en;
assign wb_to_id_bus = {wb_valid, rf_en, wb_reg, wb_data};  // 39 bits

// pipeline control
// reg wb_valid;
wire wb_ready_go;

assign wb_ready_go = 1;
assign wb_allow_in = !wb_valid || wb_ready_go;

always @(posedge clk)
begin
    if (~rst_n)
    begin
        wb_valid <= 1'b0;
    end
    else if (wb_ready_go)
    begin
        wb_valid <= mem_to_wb_valid;
    end
end

assign rf_en = wb_valid && rf_we;

endmodule
