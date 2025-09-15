`timescale 1ns / 1ps

`include "../core/defines.v"

module gpio (
           // input
           input wire clk,
           input wire rst_n,
           input wire gpio_we,
           input wire [31: 0] gpio_addr,
           input wire [31: 0] gpio_wdata,
           input wire [1: 0] io_pin,

           // output
           output reg [31: 0] gpio_rdata
       );

localparam GPIO_CTRL = 4'h0;
localparam GPIO_DATA = 4'h4;

// 0: high-Z, 1: output, 2: input
reg [31: 0] gpio_ctrl;
reg [31: 0] gpio_data;

// read
always @( * )
begin
    if (~rst_n)
        gpio_rdata = 32'b0;
    else
    begin
        case (gpio_addr[3: 0])
            GPIO_CTRL:
                gpio_rdata = gpio_ctrl;
            GPIO_DATA:
                gpio_rdata = gpio_data;
        endcase
    end
end

// write
always @(posedge clk)
begin
    if (~rst_n)
    begin
        gpio_ctrl <= 32'b0;
        gpio_data <= 32'b0;
    end
    else
    begin
        if (gpio_we == `TRUE)
        begin
            case (gpio_addr[3: 0])
                GPIO_CTRL:
                    gpio_ctrl <= gpio_wdata;
                GPIO_DATA:
                    gpio_data <= gpio_wdata;
            endcase
        end
        else
        begin
            if (gpio_ctrl[1: 0] == 2'b10)
                gpio_data[0] <= io_pin[0];
            if (gpio_ctrl[3: 2] == 2'b10)
                gpio_data[1] <= io_pin[1];
        end
    end
end

endmodule
