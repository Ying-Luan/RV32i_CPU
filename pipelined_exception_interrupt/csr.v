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

           // output
           // to id_stage
           output reg [31: 0] csr_rdata
       );

reg [31: 0] mstatus;
reg [31: 0] mie;
reg [31: 0] mtvec;
reg [31: 0] mepc;
reg [31: 0] mcause;
reg [31: 0] mtval;
reg [31: 0] mip;

// read
always @( * )
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

// write
always @(posedge clk)
begin
    if (csr_we)
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
end

endmodule
