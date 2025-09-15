`timescale 1ns / 1ps

`include "defines.v"

module clint (
           // input
           input wire clk,
           input wire rst_n,
           // from id_stage
           input wire [`EXC_STATUS_WIDTH - 1: 0] exc_status,
           input wire [31: 0] inst_addr_i,
           input wire int_flag,
           // from ex_stage
           input wire br_taken,
           input wire [31: 0] br_target,
           // from csr
           input wire [31: 0] csr_mtvec,
           input wire [31: 0] csr_mepc,
           input wire [31: 0] csr_mstatus,
           input wire global_interrupt_enable,

           // output
           output wire hold_flag,
           // to csr
           output reg csr_we,
           output reg [11: 0] csr_waddr,
           output reg [31: 0] csr_wdata,
           // to ex_stage
           output reg int_assert,
           output reg [31: 0] int_addr
       );

// int_state
localparam INT_STATE_WIDTH = 2;
localparam INT_STATE_IDLE = 2'b00;
localparam INT_STATE_SYNC_ASSERT = 2'b01;
localparam INT_STATE_ASYNC_ASSERT = 2'b10;
localparam INT_STATE_MRET = 2'b11;

// csr_state
localparam CSR_STATE_WIDTH = 3;
localparam CSR_STATE_IDLE = 3'b000;
localparam CSR_STATE_MEPC = 3'b001;
localparam CSR_STATE_MSTATUS = 3'b010;
localparam CSR_STATE_MCAUSE = 3'b011;
localparam CSR_STATE_MRET = 3'b100;

reg [INT_STATE_WIDTH - 1: 0] int_state;
reg [CSR_STATE_WIDTH - 1: 0] csr_state;
reg [31: 0] cause;
reg [31: 0] inst_addr;

assign hold_flag = ((int_state != INT_STATE_IDLE) | (csr_state != CSR_STATE_IDLE)) ? `TRUE : `FALSE;

// int_state
always @( * )
begin
    if (~rst_n)
        int_state = INT_STATE_IDLE;
    else
    begin
        if (exc_status == `EXC_STATUS_ECALL || exc_status == `EXC_STATUS_EBREAK)
            int_state = INT_STATE_SYNC_ASSERT;
        else if (int_flag != `INT_NONE && global_interrupt_enable == `TRUE)
            int_state = INT_STATE_ASYNC_ASSERT;
        else if (exc_status == `EXC_STATUS_MRET)
            int_state = INT_STATE_MRET;
        else
            int_state = INT_STATE_IDLE;
    end
end

// csr_state
// CSR_STATE_ IDLE -> MEPC -> MSTATUS -> MCAUSE -> IDLE
//                 -> MRET -> IDLE
always @(posedge clk)
begin
    if (~rst_n)
    begin
        csr_state <= CSR_STATE_IDLE;
        cause <= 32'b0;
        inst_addr <= 32'b0;
    end
    else
    begin
        case (csr_state)
            CSR_STATE_IDLE:
            begin  // initialize
                // sync int
                if (int_state == INT_STATE_SYNC_ASSERT)
                begin
                    csr_state <= CSR_STATE_MEPC;
                    case (exc_status)
                        `EXC_STATUS_ECALL:
                            cause <= {1'b0, 31'd11};
                        `EXC_STATUS_EBREAK:
                            cause <= {1'b0, 31'd3};
                        default:
                            cause <= {1'b0, 31'd10};
                    endcase
                    if (br_taken == `TRUE)
                        inst_addr <= br_target - 32'd4;
                    else
                        inst_addr <= inst_addr_i;
                end
                // async int
                else if (int_state == INT_STATE_ASYNC_ASSERT)
                begin
                    cause <= {1'b1, 31'd7};
                    csr_state <= CSR_STATE_MEPC;
                    if (br_taken == `TRUE)
                        inst_addr <= br_target;
                    else
                        inst_addr <= inst_addr_i;
                end
                // mret
                else if (int_state == INT_STATE_MRET)
                begin
                    csr_state <= CSR_STATE_MRET;
                end
            end
            CSR_STATE_MEPC:
                csr_state <= CSR_STATE_MSTATUS;
            CSR_STATE_MSTATUS:
                csr_state <= CSR_STATE_MCAUSE;
            CSR_STATE_MCAUSE:
                csr_state <= CSR_STATE_IDLE;
            CSR_STATE_MRET:
                csr_state <= CSR_STATE_IDLE;
            default :
                csr_state <= CSR_STATE_IDLE;
        endcase
    end
end

// csr write
always @(posedge clk)
begin
    if (~rst_n)
    begin
        csr_we <= `FALSE;
        csr_waddr <= 12'b0;
        csr_wdata <= 32'b0;
    end
    else
    begin
        case (csr_state)
            CSR_STATE_MEPC:
            begin
                csr_we <= `TRUE;
                csr_waddr <= `CSR_MEPC;
                csr_wdata <= inst_addr;
            end
            CSR_STATE_MSTATUS:
            begin
                csr_we <= `TRUE;
                csr_waddr <= `CSR_MSTATUS;
                csr_wdata <= {csr_mstatus[31: 8], csr_mstatus[3], csr_mstatus[6: 4], 1'b0, csr_mstatus[2: 0]};  // mstatus.MIE(mastatus[3]) = 0
            end
            CSR_STATE_MCAUSE:
            begin
                csr_we <= `TRUE;
                csr_waddr <= `CSR_MCAUSE;
                csr_wdata <= cause;
            end
            CSR_STATE_MRET:
            begin
                csr_we <= `TRUE;
                csr_waddr <= `CSR_MSTATUS;
                csr_wdata <= {csr_mstatus[31: 8], 1'b1, csr_mstatus[6: 4], csr_mstatus[7], csr_mstatus[2: 0]};  // mstatus.MIE(mstatus[3]) = mstatus.MPIE(mstatus[7])
            end
            default:
            begin
                csr_we <= `FALSE;
                csr_waddr <= 12'b0;
                csr_wdata <= 32'b0;
            end
        endcase
    end
end

// int_assert int_addr
always @(posedge clk)
begin
    if (~rst_n)
    begin
        int_assert <= `FALSE;
        int_addr <= 32'b0;
    end
    else
    begin
        case (csr_state)
            CSR_STATE_MCAUSE:
            begin
                int_assert <= `TRUE;
                int_addr <= csr_mtvec;
            end
            CSR_STATE_MRET:
            begin
                int_assert <= `TRUE;
                int_addr <= csr_mepc;
            end
            default:
            begin
                int_assert <= `FALSE;
                int_addr <= 32'b0;
            end
        endcase
    end
end

endmodule
