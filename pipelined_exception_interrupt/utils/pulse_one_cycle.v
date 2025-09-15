`timescale 1ns / 1ps

`include "../core/defines.v"

module pulse_one_cycle #(
           parameter WIDTH = 8,
           parameter IDLE_VALUE = {WIDTH{1'b0}}
       )(
           input wire clk,
           input wire rst_n,
           input wire enable,
           input wire [WIDTH - 1: 0] data,
           output wire [WIDTH - 1: 0] data_o
       );

reg en_reg;
always @(posedge clk)
begin
    if (~rst_n)
        en_reg <= `FALSE;
    else if (enable)
        en_reg <= `FALSE;
    else
        en_reg <= `TRUE;
end

assign data_o = (en_reg == `TRUE) ? data : IDLE_VALUE;

endmodule
