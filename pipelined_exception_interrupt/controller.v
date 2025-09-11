`timescale 1ns / 1ps

`include "defines.v"

module controller (
           // input
           // from ex_stage
           input wire br_taken_i,
           input wire [31: 0] br_target_i,
           // from clint
           input wire hold_flag_clint_i,

           // output
           output wire br_taken_o,
           output wire [31: 0] br_target_o,
           // to if_stage
           output reg hold_flag_if,
           // to id_stage
           output reg hold_flag_id,
           // to ex_stage
           output reg hold_flag_ex,
           // to mem_stage
           output reg hold_flag_mem,
           // to wb_stage
           output reg hold_flag_wb
       );

assign br_taken_o = br_taken_i;
assign br_target_o = br_target_i;

always @( * )
begin
    if (hold_flag_clint_i == `TRUE)
    begin
        hold_flag_if = `TRUE;
        hold_flag_id = `TRUE;
        hold_flag_ex = `TRUE;
        hold_flag_mem = `TRUE;
        hold_flag_wb = `TRUE;
    end
    else
    begin
        hold_flag_if = `FALSE;
        hold_flag_id = `FALSE;
        hold_flag_ex = `FALSE;
        hold_flag_mem = `FALSE;
        hold_flag_wb = `FALSE;
    end

end

endmodule
