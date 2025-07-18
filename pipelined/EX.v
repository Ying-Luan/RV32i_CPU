`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/06/03 15:59:20
// Design Name:
// Module Name: EX
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

module EX (
           input wire clk,
           input wire rst_n,
           input wire [`ID_TO_EX_BUS_WIDTH - 1: 0] id_to_ex_bus,
           input wire id_to_ex_valid,
           input wire mem_allow_in,

           output wire [31: 0] dram_adr,
           output wire [1: 0] dram_w_op,
           output wire dram_we,
           output wire [31: 0] dram_wdin,
           output wire [ `EX_TO_IF_BUS_WIDTH - 1: 0] ex_to_if_bus,
           output wire [ `EX_TO_ID_BUS_WIDTH - 1: 0] ex_to_id_bus,
           output wire [`EX_TO_MEM_BUS_WIDTH - 1: 0] ex_to_mem_bus,
           output wire ex_allow_in,
           output wire ex_to_mem_valid
       );

// ALU
wire alu_f;

// input bus
reg [`ID_TO_EX_BUS_WIDTH - 1: 0] ex_regs;
always @(posedge clk)
begin
    if (ex_allow_in && id_to_ex_valid)
    begin
        ex_regs <= id_to_ex_bus;
    end
end

wire [ 1: 0] npc_op;
wire ram_we;
wire [ 1: 0] ram_w_op;
wire [ 2: 0] mem_ext_op;
wire [ 3: 0] alu_op;
wire [ 2: 0] alu_f_op;
wire rf_we;
wire [ 1: 0] rf_wsel;
wire [31: 0] pc4;
wire [31: 0] pc;
wire [31: 0] ext;
wire [31: 0] rD1;
wire [ 4: 0] wb_reg;
wire [31: 0] alu_a;
wire [31: 0] alu_b;
wire [31: 0] rD2;
wire is_load;
assign {
        npc_op,
        ram_we,
        ram_w_op,
        mem_ext_op,
        alu_op,
        alu_f_op,
        rf_we,
        rf_wsel,
        pc4,
        pc,
        ext,
        rD1,
        wb_reg,
        alu_a,
        alu_b,
        rD2,
        is_load
    } = ex_regs;

// output bus
reg [31: 0] br_target;
wire br_taken;
assign ex_to_if_bus = {br_target, br_taken};  // 33 bits

wire [31: 0] alu_c;
assign ex_to_mem_bus = {  // 107 bits
           mem_ext_op,                                                       // 3 bits
           rf_we,                                                            // 1 bit
           rf_wsel,                                                          // 2 bits
           pc4,                                                              // 32 bits
           ext,                                                              // 32 bits
           wb_reg,                                                           // 5 bits
           alu_c                          // 32 bits
       };

// pipeline control
reg ex_valid;
wire ex_ready_go;

assign ex_ready_go = 1;
assign ex_allow_in = !ex_valid || (ex_ready_go && mem_allow_in);
assign ex_to_mem_valid = ex_valid && ex_ready_go;

wire br_cancel;
assign br_cancel = br_taken;
always @(posedge clk)
begin
    if (~rst_n)
    begin
        ex_valid <= 1'b0;
    end
    else if (br_cancel)
    begin
        ex_valid <= 1'b0;
    end
    else if (ex_allow_in)
    begin
        ex_valid <= id_to_ex_valid;
    end
end

always @( * )
begin
    case (npc_op)
        `NPC_PC4:
            br_target = pc4;
        `NPC_BRA:
            br_target = alu_f ? pc + ext : pc4;
        `NPC_JAL:
            br_target = pc + ext;
        `NPC_JALR:
            br_target = rD1 + ext;
    endcase
end

ALU alu_inst (
        .op(alu_op),
        .f_op(alu_f_op),
        .A(alu_a),
        .B(alu_b),

        .C(alu_c),
        .f(alu_f)
    );

// DRAM
assign dram_adr = alu_c;
assign dram_w_op = ram_w_op;
assign dram_we = ex_valid && ram_we;
assign dram_wdin = rD2;

// hazard detection and bypass
reg [31: 0] rf_wdata;
always @( * )
begin
    case (rf_wsel)
        `WB_ALU:
            rf_wdata = alu_c;
        `WB_EXT:
            rf_wdata = ext;
        `WB_PC4:
            rf_wdata = pc4;
        `WB_MEM:
            rf_wdata = 32'b0;
    endcase
end
assign ex_to_id_bus = {  // 41 bits
           ex_valid,                                   // 1 bit
           rf_we,                                      // 1 bit
           wb_reg,                                     // 5 bits
           rf_wdata,                                   // 32 bits
           is_load,                                    // 1 bit
           br_taken                             // 1 bit
       };

// branch
assign br_taken = ex_valid && (
           ((npc_op == `NPC_BRA) && alu_f) ||
           (npc_op == `NPC_JAL) ||
           (npc_op == `NPC_JALR)
       );

endmodule
