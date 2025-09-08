module controller (
           // input
           input wire br_taken_i,
           input wire [31: 0] br_target_i,
           input wire hold_flag_clint_i,

           // output
           output wire br_taken_o,
           output wire [31: 0] br_target_o,
           output wire hold_flag
       );

assign br_taken_o = br_taken_i;
assign br_target_o = br_target_i;

endmodule
