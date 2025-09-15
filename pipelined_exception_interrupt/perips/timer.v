`timescale 1ns / 1ps

`include "../core/defines.v"

module timer (
           // input
           input wire clk,
           input wire rst_n,
           // from sys_bus
           input wire timer_we,
           input wire [31: 0] timer_adr,
           input wire [31: 0] timer_wdata,

           // output
           // to sys_bus
           output reg [31: 0] timer_rdata,
           output wire int_sig_o
       );

// [0]: timer enable
// [1]: timer interrupt enable
// [2]: timer interrupt pending, wirite 1 to clear
reg [31: 0] timer_ctrl;
// timer current count
reg [31: 0] timer_count;
reg [31: 0] timer_value;

wire int_sig;
assign int_sig = ((timer_ctrl[2] == `TRUE) && (timer_ctrl[1] == `TRUE)) ? `TRUE : `FALSE;
pulse_one_cycle #(
                    .WIDTH(1),
                    .IDLE_VALUE(`FALSE)
                ) pulse_one_cycle_inst (
                    .clk(clk),
                    .rst_n(rst_n),
                    .enable((timer_ctrl[2] == `TRUE) && (timer_ctrl[1] == `TRUE)),
                    .data(int_sig),
                    .data_o(int_sig_o)
                );

// counter
always @(posedge clk)
begin
    if (~rst_n)
    begin
        timer_count <= 32'b0;
    end
    else
    begin
        if (timer_ctrl[0] == `TRUE)
        begin
            timer_count <= timer_count + 1'b1;
            if (timer_count >= timer_value)
                timer_count <= 32'b0;
        end
        else
            timer_count <= 32'b0;
    end
end

// read
always @( * )
begin
    if (~rst_n)
    begin
        timer_rdata <= 32'b0;
    end
    else
    begin
        case (timer_adr[3: 0])
            `TIMER_CTRL:
                timer_rdata <= timer_ctrl;
            `TIMER_COUNT:
                timer_rdata <= timer_count;
            `TIMER_VALUE:
                timer_rdata <= timer_value;
            default:
                timer_rdata <= 32'b0;
        endcase
    end
end

// write
always @(posedge clk)
begin
    if (~rst_n)
    begin
        timer_ctrl <= 32'b0;
        timer_value <= 32'b0;
    end
    else
    begin
        if (timer_we == `TRUE)
        begin
            case (timer_adr[3: 0])
                `TIMER_CTRL:
                    timer_ctrl <= {timer_wdata[31: 3], (timer_ctrl[2] & (~timer_wdata[2])), timer_wdata[1: 0]};
                `TIMER_VALUE:
                    timer_value <= timer_wdata;
            endcase
        end
        else
        begin
            if ((timer_ctrl[0] == `TRUE) && (timer_count >= timer_value))
            begin
                timer_ctrl[0] <= `FALSE;
                timer_ctrl[2] <= `TRUE;
            end
        end
    end
end

endmodule
