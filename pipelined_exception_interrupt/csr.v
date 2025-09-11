`timescale 1ns / 1ps

`include "defines.v"

module csr (
           // input
           input wire clk,
           input wire rst_n,
           // from id_stage
           input wire [`CSR_ADDRESS_WIDTH - 1: 0] csr_raddr,
           // from ex_stage
           input wire csr_we,
           input wire [`CSR_ADDRESS_WIDTH - 1: 0] csr_waddr,
           input wire [31: 0] csr_wdata,
           // from clint
           input wire csr_we_clint,
           input wire [`CSR_ADDRESS_WIDTH - 1: 0] csr_waddr_clint,
           input wire [31: 0] csr_wdata_clint,

           // output
           // to id_stage
           output reg [31: 0] csr_rdata,
           // to clint
           output wire [31: 0] csr_mtvec,
           output wire [31: 0] csr_mepc,
           output wire [31: 0] csr_mstatus,
           output wire global_interrupt_enable
       );

reg [31: 0] mstatus;
reg [31: 0] mie;
reg [31: 0] mtvec;
reg [31: 0] mepc;
reg [31: 0] mcause;
reg [31: 0] mtval;
reg [31: 0] mip;

assign csr_mtvec = mtvec;
assign csr_mepc = mepc;
assign csr_mstatus = mstatus;

assign global_interrupt_enable = (mstatus[3] == `TRUE) ? `TRUE : `FALSE;

// read
always @( * )
begin
    if (csr_we == `TRUE && csr_raddr == csr_waddr)
    begin
        csr_rdata = csr_wdata;
    end
    else
    begin
        case (csr_raddr)
            `CSR_MSTATUS:
                csr_rdata = mstatus;
            `CSR_MIE:
                csr_rdata = mie;
            `CSR_MTVEC:
                csr_rdata = mtvec;
            `CSR_MEPC:
                csr_rdata = mepc;
            `CSR_MCAUSE:
                csr_rdata = mcause;
            `CSR_MTVAL:
                csr_rdata = mtval;
            `CSR_MIP:
                csr_rdata = mip;
            default:
                csr_rdata = 32'b0;
        endcase
    end
end

// write
always @(posedge clk)
begin
    if (~rst_n)
    begin
        mstatus <= 32'b0;
        mie <= 32'b0;
        mtvec <= 32'b0;
        mepc <= 32'b0;
        mcause <= 32'b0;
        mtval <= 32'b0;
        mip <= 32'b0;
    end
    else
    begin
        if (csr_we)  // TODO: priority
        begin
            case (csr_waddr)
                `CSR_MSTATUS:
                    mstatus <= csr_wdata;
                `CSR_MIE:
                    mie <= csr_wdata;
                `CSR_MTVEC:
                    mtvec <= csr_wdata;
                `CSR_MEPC:
                    mepc <= csr_wdata;
                `CSR_MCAUSE:
                    mcause <= csr_wdata;
                `CSR_MTVAL:
                    mtval <= csr_wdata;
                `CSR_MIP:
                    mip <= csr_wdata;
            endcase
        end
        else if (csr_we_clint)
        begin
            case (csr_waddr_clint)
                `CSR_MSTATUS:
                    mstatus <= csr_wdata_clint;
                `CSR_MIE:
                    mie <= csr_wdata_clint;
                `CSR_MTVEC:
                    mtvec <= csr_wdata_clint;
                `CSR_MEPC:
                    mepc <= csr_wdata_clint;
                `CSR_MCAUSE:
                    mcause <= csr_wdata_clint;
                `CSR_MTVAL:
                    mtval <= csr_wdata_clint;
                `CSR_MIP:
                    mip <= csr_wdata_clint;
            endcase
        end
    end
end

endmodule
