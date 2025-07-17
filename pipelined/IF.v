`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/06/02 22:16:31
// Design Name:
// Module Name: IF
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

module IF(
           input wire clk,
           input wire rst_n,
           input wire [`EX_TO_IF_BUS_WIDTH - 1: 0] ex_to_if_bus,
           input wire id_allow_in,

           output wire [31: 0] irom_adr,
           output wire irom_en,
           output wire [`IF_TO_ID_BUS_WIDTH - 1: 0] if_to_id_bus,
           output wire if_to_id_valid
       );

// input bus
wire [31: 0] br_target;
wire br_taken;
assign {br_target, br_taken} = ex_to_if_bus;

// output bus
wire [31: 0] pc;
wire [31: 0] pc4;
assign if_to_id_bus = {pc4, pc};  // 64 bits

assign pc4 = pc + 4;

// pipeline control
reg if_valid;
wire pre_if_valid;
wire if_allow_in;
wire if_ready_go;

assign pre_if_valid = rst_n;

assign if_ready_go = 1;
assign if_allow_in = !if_valid || (if_ready_go && id_allow_in);
assign if_to_id_valid = if_valid && if_ready_go;

always @(posedge clk)
begin
    if (~rst_n)
    begin
        if_valid <= 1'b0;
    end
    else if (if_allow_in)
    begin
        if_valid <= pre_if_valid;
    end
end

wire [31: 0] pc_din;
assign pc_din = br_taken ? br_target : pc4;

PC pc_inst(
       .clk(clk),
       .rst_n(rst_n),
       .din(pc_din),
       .if_allow_in(if_allow_in),
       .pre_if_valid(pre_if_valid),

       .pc(pc)
   );

// IROM
assign irom_adr = pc;
assign irom_en = pre_if_valid && if_allow_in;

endmodule
