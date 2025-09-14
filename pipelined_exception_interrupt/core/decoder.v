`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/06/06 17:04:14
// Design Name:
// Module Name: Controller
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

module decoder(
           input wire [31: 0] inst,

           // sext
           output reg [`SEXT_OP_WIDTH - 1: 0] sext_op,
           // npc
           output reg [`NPC_OP_WIDTH - 1: 0] npc_op,
           // ram
           output reg ram_request,
           output reg ram_we,
           output reg [`RAM_W_OP_WIDTH - 1: 0] ram_w_op,
           output reg [`MEM_EXT_OP_WIDTH - 1: 0] mem_ext_op,
           // alu
           output reg [`ALU_OP_WIDTH - 1: 0] alu_op,
           output reg [`ALU_F_OP_WIDTH - 1: 0] alu_f_op,
           output reg alu_a_sel,
           output reg alu_b_sel,
           output reg rd1_en,
           output reg rd2_en,
           // rf
           output reg rf_we,
           output reg [ `RF_WSEL_WIDTH - 1: 0] rf_wsel,
           output reg is_load,
           // csr
           output reg csr_we,
           output reg csr_wdata_sel,
           output reg [`CSR_WDATA_OP_WIDTH - 1: 0] csr_wdata_op,
           // clint
           output reg [`EXC_STATUS_WIDTH - 1: 0] exc_status,
           // exception
           output reg invalid_instruction
       );


wire [ 6: 0] opcode;
wire [ 2: 0] funct3;
wire [ 6: 0] funct7;
wire [11: 0] funct12;

assign opcode = inst[6: 0];
assign funct3 = inst[14: 12];
assign funct7 = inst[31: 25];
assign funct12 = inst[31: 20];

always @( * )
begin
    // default
    sext_op = `EXT_I;
    npc_op = `NPC_PC4;
    ram_request = `FALSE;
    ram_we = `CLOSE;
    ram_w_op = `W_B;
    mem_ext_op = `MEM_EXT_B;
    alu_op = `ALU_ADD;
    alu_f_op = `F_BEQ;
    alu_a_sel = `ALU_A_RS1;
    alu_b_sel = `ALU_B_RS2;
    rd1_en = `DISABLE;
    rd2_en = `DISABLE;
    rf_we = `CLOSE;
    rf_wsel = `WB_ALU;
    is_load = `CLOSE;
    csr_we = `FALSE;
    csr_wdata_sel = `CSR_WDATA_SEL_RS1;
    csr_wdata_op = `CSR_WDATA_OP_NOP;
    exc_status = `EXC_STATUS_IDLE;
    invalid_instruction = `FALSE;

    case (opcode)
        7'b0110011:
        begin  // R-type
            npc_op = `NPC_PC4;
            rf_we = `OPEN;
            rf_wsel = `WB_ALU;
            alu_a_sel = `ALU_A_RS1;
            alu_b_sel = `ALU_B_RS2;
            rd1_en = `ENABLE;
            rd2_en = `ENABLE;
            ram_we = `CLOSE;

            case (funct3)
                3'b000:
                begin
                    case (funct7)
                        7'b0000000:
                            alu_op = `ALU_ADD;
                        7'b0100000:
                            alu_op = `ALU_SUB;
                    endcase
                end
                3'b111:
                    alu_op = `ALU_AND;
                3'b110:
                    alu_op = `ALU_OR;
                3'b100:
                    alu_op = `ALU_XOR;
                3'b001:
                    alu_op = `ALU_SLL;
                3'b101:
                begin
                    case (funct7)
                        7'b0000000:
                            alu_op = `ALU_SRL;
                        7'b0100000:
                            alu_op = `ALU_SRA;
                    endcase
                end
                3'b010:
                    alu_op = `ALU_SLT;
                3'b011:
                    alu_op = `ALU_SLTU;
                default:
                begin
                    npc_op = `NPC_PC4;
                    rf_we = `CLOSE;
                    rf_wsel = `WB_ALU;
                    alu_a_sel = `ALU_A_RS1;
                    alu_b_sel = `ALU_B_RS2;
                    rd1_en = `DISABLE;
                    rd2_en = `DISABLE;
                    ram_we = `CLOSE;

                    invalid_instruction = `TRUE;
                end
            endcase
        end
        7'b0010011:
        begin  // I-type computer
            npc_op = `NPC_PC4;
            rf_we = `OPEN;
            rf_wsel = `WB_ALU;
            sext_op = `EXT_I;
            alu_a_sel = `ALU_A_RS1;
            alu_b_sel = `ALU_B_EXT;
            rd1_en = `ENABLE;
            rd2_en = `DISABLE;
            ram_we = `CLOSE;

            case (funct3)
                3'b000:
                    alu_op = `ALU_ADD;
                3'b111:
                    alu_op = `ALU_AND;
                3'b110:
                    alu_op = `ALU_OR;
                3'b100:
                    alu_op = `ALU_XOR;
                3'b001:
                    alu_op = `ALU_SLL;
                3'b101:
                begin
                    case (funct7)
                        7'b0000000:
                            alu_op = `ALU_SRL;
                        7'b0100000:
                            alu_op = `ALU_SRA;
                    endcase
                end
                3'b010:
                    alu_op = `ALU_SLT;
                3'b011:
                    alu_op = `ALU_SLTU;
                default:
                begin
                    npc_op = `NPC_PC4;
                    rf_we = `CLOSE;
                    rf_wsel = `WB_ALU;
                    sext_op = `EXT_I;
                    alu_a_sel = `ALU_A_RS1;
                    alu_b_sel = `ALU_B_EXT;
                    rd1_en = `DISABLE;
                    rd2_en = `DISABLE;
                    ram_we = `CLOSE;

                    invalid_instruction = `TRUE;
                end
            endcase
        end
        7'b0000011:
        begin  // I-type load
            npc_op = `NPC_PC4;
            rf_we = `OPEN;
            rf_wsel = `WB_MEM;
            sext_op = `EXT_I;
            alu_op = `ALU_ADD;
            alu_a_sel = `ALU_A_RS1;
            alu_b_sel = `ALU_B_EXT;
            rd1_en = `ENABLE;
            rd2_en = `DISABLE;
            ram_request = `TRUE;
            ram_we = `CLOSE;
            is_load = `OPEN;

            case (funct3)
                3'b000:
                    mem_ext_op = `MEM_EXT_B;
                3'b100:
                    mem_ext_op = `MEM_EXT_BU;
                3'b001:
                    mem_ext_op = `MEM_EXT_H;
                3'b101:
                    mem_ext_op = `MEM_EXT_HU;
                3'b010:                      // lw
                    mem_ext_op = `MEM_EXT_W;
                default:
                begin
                    npc_op = `NPC_PC4;
                    rf_we = `CLOSE;
                    rf_wsel = `WB_ALU;
                    sext_op = `EXT_I;
                    alu_op = `ALU_ADD;
                    alu_a_sel = `ALU_A_RS1;
                    alu_b_sel = `ALU_B_RS2;
                    rd1_en = `DISABLE;
                    rd2_en = `DISABLE;
                    ram_request = `FALSE;
                    ram_we = `CLOSE;
                    is_load = `CLOSE;

                    invalid_instruction = `TRUE;
                end
            endcase
        end
        7'b1100111:
        begin  // I-type jalr
            npc_op = `NPC_JALR;
            rf_we = `OPEN;
            rf_wsel = `WB_PC4;
            sext_op = `EXT_I;
            rd1_en = `ENABLE;
            rd2_en = `DISABLE;
            ram_we = `CLOSE;
        end
        7'b1110011:
        begin  // I-type ecall ebreak csr
            if (funct3 == 3'b000)  // ecall ebreak
            begin
                case (funct12)
                    12'b000000000000:
                        exc_status = `EXC_STATUS_ECALL;  // ecall
                    12'b000000000001:
                        exc_status = `EXC_STATUS_EBREAK;  // ebreak
                    12'b001100000010:
                        exc_status = `EXC_STATUS_MRET;  // mret
                    default:
                    begin
                        exc_status = `EXC_STATUS_IDLE;

                        invalid_instruction = `TRUE;
                    end
                endcase
            end
            else  // csr
            begin
                rf_we = `OPEN;
                rf_wsel = `WB_CSR;
                csr_we = `TRUE;
                case (funct3)
                    3'b001:
                    begin
                        csr_wdata_sel = `CSR_WDATA_SEL_RS1;
                        csr_wdata_op = `CSR_WDATA_OP_NOP;
                    end
                    3'b010:
                    begin
                        csr_wdata_sel = `CSR_WDATA_SEL_RS1;
                        csr_wdata_op = `CSR_WDATA_OP_OR;
                    end
                    3'b011:
                    begin
                        csr_wdata_sel = `CSR_WDATA_SEL_RS1;
                        csr_wdata_op = `CSR_WDATA_OP_ANDN;
                    end
                    3'b101:
                    begin
                        csr_wdata_sel = `CSR_WDATA_SEL_IMM;
                        csr_wdata_op = `CSR_WDATA_OP_NOP;
                    end
                    3'b110:
                    begin
                        csr_wdata_sel = `CSR_WDATA_SEL_IMM;
                        csr_wdata_op = `CSR_WDATA_OP_OR;
                    end
                    3'b111:
                    begin
                        csr_wdata_sel = `CSR_WDATA_SEL_IMM;
                        csr_wdata_op = `CSR_WDATA_OP_ANDN;
                    end
                    default:
                    begin
                        rf_we = `CLOSE;
                        rf_wsel = `WB_ALU;
                        csr_we = `FALSE;

                        invalid_instruction = `TRUE;
                    end
                endcase
            end
        end
        7'b0100011:
        begin  // S-type
            npc_op = `NPC_PC4;
            rf_we = `CLOSE;
            sext_op = `EXT_S;
            alu_op = `ALU_ADD;
            alu_a_sel = `ALU_A_RS1;
            alu_b_sel = `ALU_B_EXT;
            rd1_en = `ENABLE;
            rd2_en = `ENABLE;
            ram_request = `TRUE;
            ram_we = `OPEN;

            case (funct3)
                3'b000:
                    ram_w_op = `W_B;
                3'b001:
                    ram_w_op = `W_H;
                3'b010:
                    ram_w_op = `W_W;
                default:
                begin
                    npc_op = `NPC_PC4;
                    rf_we = `CLOSE;
                    sext_op = `EXT_I;
                    alu_op = `ALU_ADD;
                    alu_a_sel = `ALU_A_RS1;
                    alu_b_sel = `ALU_B_RS2;
                    rd1_en = `DISABLE;
                    rd2_en = `DISABLE;
                    ram_request = `FALSE;
                    ram_we = `CLOSE;

                    invalid_instruction = `TRUE;
                end
            endcase
        end
        7'b1100011:
        begin  // B-type
            npc_op = `NPC_BRA;
            rf_we = `CLOSE;
            sext_op = `EXT_B;
            alu_a_sel = `ALU_A_RS1;
            alu_b_sel = `ALU_B_RS2;
            rd1_en = `ENABLE;
            rd2_en = `ENABLE;
            ram_we = `CLOSE;

            case (funct3)
                3'b000:
                    alu_f_op = `F_BEQ;
                3'b001:
                    alu_f_op = `F_BNE;
                3'b100:
                    alu_f_op = `F_BLT;
                3'b110:
                    alu_f_op = `F_BLTU;
                3'b101:
                    alu_f_op = `F_BGE;
                3'b111:
                    alu_f_op = `F_BGEU;
                default:
                begin
                    npc_op = `NPC_PC4;
                    rf_we = `CLOSE;
                    sext_op = `EXT_I;
                    alu_a_sel = `ALU_A_RS1;
                    alu_b_sel = `ALU_B_RS2;
                    rd1_en = `DISABLE;
                    rd2_en = `DISABLE;
                    ram_we = `CLOSE;

                    invalid_instruction = `TRUE;
                end
            endcase
        end
        7'b0110111:
        begin  // U-type lui
            npc_op = `NPC_PC4;
            rf_we = `OPEN;
            rf_wsel = `WB_EXT;
            sext_op = `EXT_U;
            ram_we = `CLOSE;
        end
        7'b0010111:
        begin  // U-type auipc
            npc_op = `NPC_PC4;
            rf_we = `OPEN;
            rf_wsel = `WB_ALU;
            sext_op = `EXT_U;
            alu_op = `ALU_ADD;
            alu_a_sel = `ALU_A_PC;
            alu_b_sel = `ALU_B_EXT;
            ram_we = `CLOSE;
        end
        7'b1101111:
        begin  // J-type jal
            npc_op = `NPC_JAL;
            rf_we = `OPEN;
            rf_wsel = `WB_PC4;
            sext_op = `EXT_J;
            ram_we = `CLOSE;
        end
        default:
            invalid_instruction = `TRUE;
    endcase
end
endmodule
