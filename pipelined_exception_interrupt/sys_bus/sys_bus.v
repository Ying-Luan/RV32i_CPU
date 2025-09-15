`timescale 1ns / 1ps

`include "../core/defines.v"

module sys_bus (
           // input
           input wire clk,
           input wire rst_n,
           // from master0
           input wire master0_request,
           input wire master0_we,
           input wire [31: 0] master0_adr,
           input wire [31: 0] master0_wdata,
           // from master1
           input wire master1_request,
           input wire master1_we,
           input wire [31: 0] master1_adr,
           input wire [31: 0] master1_wdata,
           // from slave0
           input wire [31: 0] slave0_rdata,
           // from slave1
           input wire [31: 0] slave1_rdata,

           // output
           // to master0
           output reg [31: 0] master0_rdata,
           // to master1
           output reg [31: 0] master1_rdata,
           // to slave0
           output reg slave0_we,
           output reg [31: 0] slave0_adr,
           output reg [31: 0] slave0_wdata,
           // to slave1
           output reg slave1_we,
           output reg [31: 0] slave1_adr,
           output reg [31: 0] slave1_wdata,
           output reg hold_flag
       );

localparam REQUEST_WIDTH = 4;
localparam REQUEST0 = 4'b0001;
localparam REQUEST1 = 4'b0010;

localparam GRANT_WIDTH = 1;
localparam GRANT0 = 1'b0;
localparam GRANT1 = 1'b1;

wire request;  // TODO: not used
reg grant;

// master0 > master1
always @( * )
begin
    if (master0_request)
    begin
        grant = GRANT0;
        hold_flag = `TRUE;
    end
    else
    begin
        grant = GRANT1;
        hold_flag = `TRUE;
    end
end

always @( * )
begin
    master0_rdata = 32'b0;
    master1_rdata = 32'b0;
    slave0_we = `FALSE;
    slave0_adr = 32'b0;
    slave0_wdata = 32'b0;
    slave1_we = `FALSE;
    slave1_adr = 32'b0;
    slave1_wdata = 32'b0;
    case (grant)
        GRANT0:
        begin
            case (master0_adr[31: 28])
                REQUEST0:
                begin
                    slave0_we = master0_we;
                    slave0_adr = master0_adr;
                    slave0_wdata = master0_wdata;
                    master0_rdata = slave0_rdata;
                end
                REQUEST1:
                begin
                    slave1_we = master0_we;
                    slave1_adr = master0_adr;
                    slave1_wdata = master0_wdata;
                    master0_rdata = slave1_rdata;
                end
            endcase
        end
        GRANT1:
        begin
            case (master1_adr[31: 28])
                REQUEST0:
                begin
                    slave0_we = master1_we;
                    slave0_adr = master1_adr;
                    slave0_wdata = master1_wdata;
                    master1_rdata = slave0_rdata;
                end
                REQUEST1:
                begin
                    slave1_we = master1_we;
                    slave1_adr = master1_adr;
                    slave1_wdata = master1_wdata;
                    master1_rdata = slave1_rdata;
                end
            endcase
        end
    endcase
end

endmodule
