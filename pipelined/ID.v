`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/06/02 22:17:29
// Design Name:
// Module Name: ID
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

module ID(
           input wire clk,
           input wire rst_n,
           input wire [31: 0] irom_inst,
           input wire [ `IF_TO_ID_BUS_WIDTH - 1: 0] if_to_id_bus,
           input wire [ `EX_TO_ID_BUS_WIDTH - 1: 0] ex_to_id_bus,
           input wire [`MEM_TO_ID_BUS_WIDTH - 1: 0] mem_to_id_bus,
           input wire [ `WB_TO_ID_BUS_WIDTH - 1: 0] wb_to_id_bus,
           input wire if_to_id_valid,
           input wire ex_allow_in,

           output wire [`ID_TO_EX_BUS_WIDTH - 1: 0] id_to_ex_bus,
           output wire id_allow_in,
           output wire id_to_ex_valid
       );

reg [31: 0] wD;
wire [31: 0] inst;
assign inst = irom_inst;

// Controller signals
wire [2: 0] sext_op;
wire [1: 0] npc_op;
wire ram_we;
wire [1: 0] ram_w_op;
wire [2: 0] mem_ext_op;
wire [3: 0] alu_op;
wire [2: 0] alu_f_op;
wire alu_a_sel;
wire alu_b_sel;
wire rd1_en;
wire rd2_en;
wire rf_we_first;
wire [1: 0] rf_wsel;
wire is_load;

// input bus
reg [`IF_TO_ID_BUS_WIDTH - 1: 0] id_regs;
always @(posedge clk)
begin
    if (id_allow_in && if_to_id_valid)
    begin
        id_regs <= if_to_id_bus;
    end
end

wire [31: 0] pc;
wire [31: 0] pc4;
assign {pc4, pc} = id_regs;

wire wb_valid;
wire wb_rf_we;
wire [4: 0] wb_wb_reg;
wire [31: 0] wb_data;
assign {wb_valid, wb_rf_we, wb_wb_reg, wb_data} = wb_to_id_bus;

// output bus
wire [31: 0] ext;
wire [31: 0] rD1_final;
wire [4: 0] wb_reg_first;
reg [31: 0] alu_a;
reg [31: 0] alu_b;
wire [31: 0] rD2_final;
assign id_to_ex_bus = {  // 248 bits
           npc_op,                                              // 2 bits
           ram_we,                                              // 1 bit
           ram_w_op,                                            // 2 bits
           mem_ext_op,                                          // 3 bits
           alu_op,                                              // 4 bits
           alu_f_op,                                            // 3 bits
           rf_we_first,                                         // 1 bit
           rf_wsel,                                             // 2 bits
           pc4,                                                 // 32 bits
           pc,                                                  // 32 bits
           ext,                                                 // 32 bits
           rD1_final,                                                 // 32 bits
           wb_reg_first,                                        // 5 bits
           alu_a,                                               // 32 bits
           alu_b,                                               // 32 bits
           rD2_final,                                           // 32 bits
           is_load           // 1 bit
       };

// pipeline control
reg id_valid;
wire id_ready_go;

// assign id_ready_go = 1;
assign id_allow_in = !id_valid || (id_ready_go && ex_allow_in);
assign id_to_ex_valid = id_valid && id_ready_go;

wire br_taken;
wire br_cancel;
assign br_cancel = br_taken;
always @(posedge clk)
begin
    if (~rst_n)
    begin
        id_valid <= 1'b0;
    end
    else if (br_cancel)
    begin
        id_valid <= 1'b0;
    end
    else if (id_allow_in)
    begin
        id_valid <= if_to_id_valid;
    end
end

assign wb_reg_first = inst[11: 7];

// Controller
Controller controller_inst(
               .opcode(inst[6: 0]),
               .funct3(inst[14: 12]),
               .funct7(inst[31: 25]),

               .sext_op(sext_op),
               .npc_op(npc_op),
               .ram_we(ram_we),
               .ram_w_op(ram_w_op),
               .mem_ext_op(mem_ext_op),
               .alu_op(alu_op),
               .alu_f_op(alu_f_op),
               .alu_a_sel(alu_a_sel),
               .alu_b_sel(alu_b_sel),
               .rd1_en(rd1_en),
               .rd2_en(rd2_en),
               .rf_we(rf_we_first),
               .rf_wsel(rf_wsel),
               .is_load(is_load)
           );

// RF
wire [4: 0] rR1;
wire [4: 0] rR2;
assign rR1 = inst[19: 15];
assign rR2 = inst[24: 20];
wire [31: 0] rD1;
wire [31: 0] rD2;
RF rf_inst(
       .clk(clk),
       .rR1(rR1),
       .rR2(rR2),
       .wR(wb_wb_reg),
       .we(wb_rf_we),
       .wD(wb_data),

       .rD1(rD1),
       .rD2(rD2)
   );

// SEXT
SEXT sext_inst(
         .op(sext_op),
         .din(inst),

         .ext(ext)
     );

// ALU_a
always @( * )
begin
    case (alu_a_sel)
        `ALU_A_RS1:
            alu_a = rD1_final;
        `ALU_A_PC:
            alu_a = pc;
        default:
            alu_a = 32'b0;
    endcase
end

// ALU_b
always @( * )
begin
    case (alu_b_sel)
        `ALU_B_RS2:
            alu_b = rD2_final;
        `ALU_B_EXT:
            alu_b = ext;
        default:
            alu_b = 32'b0;
    endcase
end

// hazard detection
wire ex_valid;
wire ex_rf_we;
wire [4: 0] ex_wb_reg;
wire [31: 0] ex_rf_data;
wire ex_is_load;
assign {ex_valid, ex_rf_we, ex_wb_reg, ex_rf_data, ex_is_load, br_taken} = ex_to_id_bus;
wire mem_valid;
wire mem_rf_we;
wire [4: 0] mem_wb_reg;
wire [31: 0] mem_rf_data;
assign {mem_valid, mem_rf_we, mem_wb_reg, mem_rf_data} = mem_to_id_bus;
// ... wb_to_id_bus

wire use_rf_rd1;
wire use_rf_rd2;
assign use_rf_rd1 = id_valid && rd1_en;
assign use_rf_rd2 = id_valid && rd2_en;

wire rf_rd1_hazard;
wire rf_rd2_hazard;
assign rf_rd1_hazard = use_rf_rd1 && (
           (ex_valid && ex_rf_we && ex_is_load && (ex_wb_reg != 5'b0) && (ex_wb_reg == rR1))
       );
assign rf_rd2_hazard = use_rf_rd2 && (
           (ex_valid && ex_rf_we && ex_is_load && (ex_wb_reg != 5'b0) && (ex_wb_reg == rR2))
       );

assign id_ready_go = !(rf_rd1_hazard || rf_rd2_hazard);

// bypass
assign rD1_final =
       (ex_valid && ex_rf_we && (ex_wb_reg != 5'b0) && (ex_wb_reg == rR1)) ? ex_rf_data :
       (mem_valid && mem_rf_we && (mem_wb_reg != 5'b0) && (mem_wb_reg == rR1)) ? mem_rf_data :
       (wb_valid && wb_rf_we && (wb_wb_reg != 5'b0) && (wb_wb_reg == rR1)) ? wb_data :
       rD1;

assign rD2_final =
       (ex_valid && ex_rf_we && (ex_wb_reg != 5'b0) && (ex_wb_reg == rR2)) ? ex_rf_data :
       (mem_valid && mem_rf_we && (mem_wb_reg != 5'b0) && (mem_wb_reg == rR2)) ? mem_rf_data :
       (wb_valid && wb_rf_we && (wb_wb_reg != 5'b0) && (wb_wb_reg == rR2)) ? wb_data :
       rD2;

endmodule
