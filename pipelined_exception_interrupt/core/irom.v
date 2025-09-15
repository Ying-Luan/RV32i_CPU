`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/06/02 19:48:58
// Design Name:
// Module Name: IROM
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


module irom #(
           parameter IROM_FILE = "IROM.hex"
       )(
           input wire clk,
           input wire irom_en,
           input wire [31: 0] adr,

           output reg [31: 0] inst
       );

localparam ROM_DEPTH = 10;
localparam ROM_SIZE = 1 << ROM_DEPTH;
reg [31: 0] rom [0: ROM_SIZE - 1];

integer i;
initial
begin
    for (i = 0; i < ROM_SIZE; i = i + 1)
    begin
        rom[i] = 32'h0000_0000;
    end
end

initial
begin
    $readmemh(IROM_FILE, rom);
end

always @(posedge clk)
begin
    if (irom_en)
    begin
        inst <= rom[adr[31: 2]];
    end
end

endmodule
