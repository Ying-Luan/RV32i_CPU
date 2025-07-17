`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/06/06 16:37:22
// Design Name:
// Module Name: MEM_EXT
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

module MEM_EXT(
           input wire [2: 0] op,
           input wire [31: 0] din,

           output reg [31: 0] ext
       );

always @( * )
begin
    case (op)
        `MEM_EXT_B:
            ext = {{24{din[7]}}, din[7: 0]};
        `MEM_EXT_BU:
            ext = {{24{1'b0}}, din[7: 0]};
        `MEM_EXT_H:
            ext = {{16{din[15]}}, din[15: 0]};
        `MEM_EXT_HU:
            ext = {{16{1'b0}}, din[15: 0]};
        `MEM_EXT_W:
            ext = din;
        default:
            ext = 32'b0;
    endcase
end

endmodule
