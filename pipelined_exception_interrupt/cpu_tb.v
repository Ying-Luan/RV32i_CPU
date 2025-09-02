`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/06/07 18:14:01
// Design Name:
// Module Name: cpu_tb
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


module cpu_tb();
// 时钟和复位信号定义
reg clk;
reg rst_n;

// 时钟生成，周期为10ns
initial
begin
    clk = 0;
    forever
        #5 clk = ~clk;
end

// 实例化CPU，指定使用 test.hex 作为指令文件
cpu #(
        .IROM_FILE("test.hex")
    ) cpu_inst (
        .clk(clk),
        .rst_n(rst_n)
    );

// 测试流程
initial
begin
    // 初始复位
    rst_n = 0;
    #20;
    rst_n = 1;

    // 运行足够长的时间执行指令
    #2000;

    // 结束仿真
    $finish;
end

// 可选：监视寄存器状态
// 每100个时间单位输出一次寄存器堆的值
initial
begin
    // 监控每个指令的执行情况
    forever
        @(posedge clk)
     begin
         #1; // 等待信号稳定
         $display("[指令] PC=%h, Inst=%h, adr=%h",
                  cpu_inst.if_inst.pc,
                  cpu_inst.irom_instance.inst,
                  cpu_inst.irom_instance.adr);
         $display("[控制] rf_we=%b, rd=%d",
                  cpu_inst.id_inst.wb_rf_we,
                  cpu_inst.id_inst.wb_wb_reg);
         $display("[数据] ALU结果=%h, wD=%h",
                  cpu_inst.ex_inst.alu_c,
                  cpu_inst.id_inst.wb_data);
         $display("[流水线] IF_VALID=%b,    ID_VALID=%b,    EX_VALID=%b,    MEM_VALID=%b,    WB_VALID=%b",
                  cpu_inst.if_inst.if_valid,
                  cpu_inst.id_inst.id_valid,
                  cpu_inst.ex_inst.ex_valid,
                  cpu_inst.mem_inst.mem_valid,
                  cpu_inst.wb_inst.wb_valid);
         $display("[流水线] IF_READY_GO=%b, ID_READY_GO=%b, EX_READY_GO=%b, MEM_READY_GO=%b, WB_READY_GO=%b",
                  cpu_inst.if_inst.if_ready_go,
                  cpu_inst.id_inst.id_ready_go,
                  cpu_inst.ex_inst.ex_ready_go,
                  cpu_inst.mem_inst.mem_ready_go,
                  cpu_inst.wb_inst.wb_ready_go);
         $display("[数据冒险] rf_rd1_hazard=%b, rf_rd2_hazard=%b",
                  cpu_inst.id_inst.rf_rd1_hazard,
                  cpu_inst.id_inst.rf_rd2_hazard);
         $display("[数据冒险] use_rf_rd1=%b,    use_rf_rd2=%b",
                  cpu_inst.id_inst.use_rf_rd1,
                  cpu_inst.id_inst.use_rf_rd2);
         $display("[数据冒险] rd1_en=%b,        rd2_en=%b",
                  cpu_inst.id_inst.rd1_en,
                  cpu_inst.id_inst.rd2_en);
         $display("[数据冒险] ex_rf_we=%b,  mem_rf_we=%b,  wb_rf_we=%b",
                  cpu_inst.id_inst.ex_rf_we,
                  cpu_inst.id_inst.mem_rf_we,
                  cpu_inst.id_inst.wb_rf_we);
         $display("[数据冒险] ex_wb_reg=%d, mem_wb_reg=%d, wb_wb_reg=%d",
                  cpu_inst.id_inst.ex_wb_reg,
                  cpu_inst.id_inst.mem_wb_reg,
                  cpu_inst.id_inst.wb_wb_reg);
         $display("[数据冒险] rf_we_first=%b, EX.rf_we=%b",
                  cpu_inst.id_inst.rf_we_first,
                  cpu_inst.ex_inst.rf_we);

         $display("[寄存器] x0 =%h, x1 =%h, x2 =%h, x3 =%h, x4 =%h, x5 =%h, x6 =%h, x7 =%h",
                  cpu_inst.id_inst.rf_inst.regs[0],
                  cpu_inst.id_inst.rf_inst.regs[1],
                  cpu_inst.id_inst.rf_inst.regs[2],
                  cpu_inst.id_inst.rf_inst.regs[3],
                  cpu_inst.id_inst.rf_inst.regs[4],
                  cpu_inst.id_inst.rf_inst.regs[5],
                  cpu_inst.id_inst.rf_inst.regs[6],
                  cpu_inst.id_inst.rf_inst.regs[7]
                 );
         $display("[寄存器] x8 =%h, x9 =%h, x10=%h, x11=%h, x12=%h, x13=%h, x14=%h, x15=%h",
                  cpu_inst.id_inst.rf_inst.regs[8],
                  cpu_inst.id_inst.rf_inst.regs[9],
                  cpu_inst.id_inst.rf_inst.regs[10],
                  cpu_inst.id_inst.rf_inst.regs[11],
                  cpu_inst.id_inst.rf_inst.regs[12],
                  cpu_inst.id_inst.rf_inst.regs[13],
                  cpu_inst.id_inst.rf_inst.regs[14],
                  cpu_inst.id_inst.rf_inst.regs[15]
                 );
         $display("[寄存器] x16=%h, x17=%h, x18=%h, x19=%h, x20=%h, x21=%h, x22=%h, x23=%h",
                  cpu_inst.id_inst.rf_inst.regs[16],
                  cpu_inst.id_inst.rf_inst.regs[17],
                  cpu_inst.id_inst.rf_inst.regs[18],
                  cpu_inst.id_inst.rf_inst.regs[19],
                  cpu_inst.id_inst.rf_inst.regs[20],
                  cpu_inst.id_inst.rf_inst.regs[21],
                  cpu_inst.id_inst.rf_inst.regs[22],
                  cpu_inst.id_inst.rf_inst.regs[23]
                 );
         $display("[寄存器] x24=%h, x25=%h, x26=%h, x27=%h, x28=%h, x29=%h, x30=%h, x31=%h",
                  cpu_inst.id_inst.rf_inst.regs[24],
                  cpu_inst.id_inst.rf_inst.regs[25],
                  cpu_inst.id_inst.rf_inst.regs[26],
                  cpu_inst.id_inst.rf_inst.regs[27],
                  cpu_inst.id_inst.rf_inst.regs[28],
                  cpu_inst.id_inst.rf_inst.regs[29],
                  cpu_inst.id_inst.rf_inst.regs[30],
                  cpu_inst.id_inst.rf_inst.regs[31]
                 );
         $display("---------------------------");
     end
 end

 // 保存波形文件，如果仿真器支持
 initial
 begin
     $dumpfile("cpu_test.vcd");
     $dumpvars(0, cpu_tb);
 end

 endmodule
