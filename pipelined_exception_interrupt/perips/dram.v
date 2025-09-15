`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/06/03 16:08:16
// Design Name:
// Module Name: DRAM
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

`include "../core/defines.v" 
// TODO: op
module dram(
           // input
           input wire clk,
           input wire rst_n,
           input wire [31: 0] adr,
           input wire [1: 0] op,
           input wire we,
           input wire [31: 0] wdin,

           // output
           output reg [31: 0] rdo
       );
localparam MEM_DEPTH = 10;
localparam MEM_SIZE = 1 << MEM_DEPTH;
reg [7: 0] mem [0: MEM_SIZE - 1];

integer i;
initial
begin
    for (i = 0; i < MEM_SIZE; i = i + 1)
    begin
        mem[i] = 8'h00;
    end
end

// write
always @(posedge clk)
begin
    if (we)
    begin
        case (op)
            `W_B:
            begin
                mem[adr[9: 0]] <= wdin[7: 0];
            end
            `W_H:
            begin
                mem[adr[9: 0]] <= wdin[7: 0];
                mem[adr[9: 0] + 1] <= wdin[15: 8];
            end
            `W_W:
            begin
                mem[adr[9: 0]] <= wdin[7: 0];
                mem[adr[9: 0] + 1] <= wdin[15: 8];
                mem[adr[9: 0] + 2] <= wdin[23: 16];
                mem[adr[9: 0] + 3] <= wdin[31: 24];
            end
        endcase
    end
end

// read
// sync
// always @(posedge clk)
// begin
//     rdo <= {mem[adr + 3], mem[adr + 2], mem[adr + 1], mem[adr]};
// end

// read
// async
always @( * )
begin
    if (~rst_n)
        rdo <= 32'b0;
    else
        rdo <= {mem[adr + 3], mem[adr + 2], mem[adr + 1], mem[adr]};
end

endmodule
