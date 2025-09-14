`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/07/14 08:02:28
// Design Name:
// Module Name: MEM
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

module mem_stage(
           // input
           input wire clk,
           input wire rst_n,
           input wire [31: 0] dram_rdo,
           input wire [`EX_TO_MEM_BUS_WIDTH - 1: 0] ex_to_mem_bus,
           // from controller
           input wire hold_flag_mem,
           input wire ex_to_mem_valid,
           input wire wb_allow_in,

           // output
           output wire [`MEM_TO_ID_BUS_WIDTH - 1: 0] mem_to_id_bus,
           output wire [`MEM_TO_WB_BUS_WIDTH - 1: 0] mem_to_wb_bus,
           output wire mem_allow_in,
           output wire mem_to_wb_valid
       );

wire [31: 0] mem_dout;

// input bus
reg [`EX_TO_MEM_BUS_WIDTH - 1: 0] mem_regs;
always @(posedge clk)
begin
    if (mem_allow_in && ex_to_mem_valid)
    begin
        mem_regs <= ex_to_mem_bus;
    end
end

wire [`MEM_EXT_OP_WIDTH - 1: 0] mem_ext_op;
wire rf_we;
wire [`RF_WSEL_WIDTH - 1: 0] rf_wsel;
wire [31: 0] pc4;
wire [31: 0] ext;
wire [4: 0] wb_reg;
wire [31: 0] alu_c;
wire [31: 0] csr_rdata;
assign {
        mem_ext_op,
        rf_we,
        rf_wsel,
        pc4,
        ext,
        wb_reg,
        alu_c,
        // csr
        csr_rdata
    } = mem_regs;

// output bus
reg [31: 0] wb_data;
assign mem_to_wb_bus = {  // 38 bits
           rf_we,         // 1 bit
           wb_reg,        // 5 bits
           wb_data      // 32 bits
       };

// pipeline control
reg mem_valid;
wire mem_ready_go;

assign mem_ready_go = !hold_flag_mem;
assign mem_allow_in = !mem_valid || (mem_ready_go && wb_allow_in);
assign mem_to_wb_valid = mem_valid && mem_ready_go;

always @(posedge clk)
begin
    if (~rst_n)
    begin
        mem_valid <= 1'b0;
    end
    else if (mem_allow_in)
    begin
        mem_valid <= ex_to_mem_valid;
    end
end

mem_ext mem_ext_inst (
            .op(mem_ext_op),
            .din(dram_rdo),

            .ext(mem_dout)
        );

// RF
always @( * )
begin
    case (rf_wsel)
        `WB_ALU:
            wb_data = alu_c;
        `WB_EXT:
            wb_data = ext;
        `WB_PC4:
            wb_data = pc4;
        `WB_MEM:
            wb_data = mem_dout;
        `WB_CSR:
            wb_data = csr_rdata;
        default:
            wb_data = 32'b0;
    endcase
end

// bypass
assign mem_to_id_bus = {  // 39 bits
           mem_valid,                  // 1 bit
           rf_we,                     // 1 bit
           wb_reg,                 // 5 bits
           wb_data      // 32 bits
       };

endmodule
