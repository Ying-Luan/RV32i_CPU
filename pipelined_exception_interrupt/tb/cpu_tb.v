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
// ʱ�Ӻ͸�λ�źŶ���
reg clk;
reg rst_n;

// ʱ�����ɣ�����Ϊ10ns
initial
begin
    clk = 0;
    forever
        #5 clk = ~clk;
end

// ʵ����CPU��ָ��ʹ�� test.hex ��Ϊָ���ļ�
soc_top #(
            .IROM_FILE("E:/Computer_study/Verilog/RV32i_CPU/test/assembly/test_timer.hex")  // �滻Ϊ��� hex �ļ�·��
        ) soc_top_inst (
            .clk(clk),
            .rst_n(rst_n)
        );

// ��������
initial
begin
    // ��ʼ��λ
    rst_n = 0;
    #20;
    rst_n = 1;

    // �����㹻����ʱ��ִ��ָ��
    #40000;  // 40us

    // ��������
    $finish;
end

// ��ѡ�����ӼĴ���״̬
// ÿ100��ʱ�䵥λ���һ�μĴ����ѵ�ֵ
initial
begin
    // ���ÿ��ָ���ִ�����
    forever
        @(posedge clk)
     begin
         #1; // �ȴ��ź��ȶ�
         $display("[ָ��] PC=%h, Inst=%h, adr=%h",
                  soc_top_inst.cpu_inst.if_stage_inst.pc,
                  soc_top_inst.cpu_inst.irom_instance.inst,
                  soc_top_inst.cpu_inst.irom_instance.adr);
         $display("[����] rf_we=%b, rd=%d",
                  soc_top_inst.cpu_inst.id_stage_inst.wb_rf_we,
                  soc_top_inst.cpu_inst.id_stage_inst.wb_wb_reg);
         $display("[����] ALU���=%h, wb_wb_reg=%h, wb_rf_we=%b, wD=%h",
                  soc_top_inst.cpu_inst.ex_stage_inst.alu_c,
                  soc_top_inst.cpu_inst.id_stage_inst.wb_wb_reg,
                  soc_top_inst.cpu_inst.id_stage_inst.wb_rf_we,
                  soc_top_inst.cpu_inst.id_stage_inst.wb_data);
         $display("[csr] csr_raddr=%h, csr_rdata=%h, csr_we=%b, csr_waddr=%h, csr_wdata=%h",
                  soc_top_inst.cpu_inst.csr_inst.csr_raddr,
                  soc_top_inst.cpu_inst.csr_inst.csr_rdata,
                  soc_top_inst.cpu_inst.csr_inst.csr_we,
                  soc_top_inst.cpu_inst.csr_inst.csr_waddr,
                  soc_top_inst.cpu_inst.csr_inst.csr_wdata);
         $display("[csr] mstatus=%h, mie=%h, mtvec=%h, mepc=%h, mcause=%h, mtval=%h, mip=%h",
                  soc_top_inst.cpu_inst.csr_inst.mstatus,
                  soc_top_inst.cpu_inst.csr_inst.mie,
                  soc_top_inst.cpu_inst.csr_inst.mtvec,
                  soc_top_inst.cpu_inst.csr_inst.mepc,
                  soc_top_inst.cpu_inst.csr_inst.mcause,
                  soc_top_inst.cpu_inst.csr_inst.mtval,
                  soc_top_inst.cpu_inst.csr_inst.mip
                 );
         $display("[clint] int_state=%b, csr_state=%b",
                  soc_top_inst.cpu_inst.clint_inst.int_state,
                  soc_top_inst.cpu_inst.clint_inst.csr_state
                 );
         $display("[timer] timer_ctrl=%h, timer_count=%h, timer_value=%h, int_sig=%b",
                  soc_top_inst.timer_inst.timer_ctrl,
                  soc_top_inst.timer_inst.timer_count,
                  soc_top_inst.timer_inst.timer_value,
                  soc_top_inst.timer_inst.int_sig
                 );
         $display("[dram] sys_bus_we=%b, sys_bus_adr=%h, sys_bus_wdata=%h, sys_bus_rdata=%h",
                  soc_top_inst.cpu_inst.sys_bus_we,
                  soc_top_inst.cpu_inst.sys_bus_adr,
                  soc_top_inst.cpu_inst.sys_bus_wdata,
                  soc_top_inst.cpu_inst.sys_bus_rdata
                 );
         $display("[dram] adr=%h, op=%h, we=%b, wdin=%h, rdo=%h",
                  soc_top_inst.dram_inst.adr,
                  soc_top_inst.dram_inst.op,
                  soc_top_inst.dram_inst.we,
                  soc_top_inst.dram_inst.wdin,
                  soc_top_inst.dram_inst.rdo
                 );
         //  $display("[timer_ctrl] timer_wdata=%h, timer_we=%b, alu.A=%h, alu.B=%h, id_stage.rD1_final=%h, id_stage.mem_rf_data=%h, mem_stage.wb_data=%h, cpu.mem_rdata=%h, cpu.sys_bus_rdata=%h, cpu.sys_bus_request=%b",
         //           soc_top_inst.timer_inst.timer_wdata,
         //           soc_top_inst.timer_inst.timer_we,
         //           soc_top_inst.cpu_inst.ex_stage_inst.alu_inst.A,
         //           soc_top_inst.cpu_inst.ex_stage_inst.alu_inst.B,
         //           soc_top_inst.cpu_inst.id_stage_inst.rD1_final,
         //           soc_top_inst.cpu_inst.id_stage_inst.mem_rf_data,
         //           soc_top_inst.cpu_inst.mem_stage_inst.wb_data,
         //           soc_top_inst.cpu_inst.mem_rdata,
         //           soc_top_inst.cpu_inst.sys_bus_rdata,
         //           soc_top_inst.cpu_inst.sys_bus_request
         //          );
         //  $display("[timer_ctrl] timer.rdata=%h, mem_stage.dram_rdo=%h",
         //           soc_top_inst.timer_inst.timer_rdata,
         //           soc_top_inst.cpu_inst.mem_stage_inst.dram_rdo
         //          );
         //  $display("[x5] wb_stage.wb_data=%h, wb_stage.wb_reg=%d, wb_stage.rf_en=%b",
         //           soc_top_inst.cpu_inst.wb_stage_inst.wb_data,
         //           soc_top_inst.cpu_inst.wb_stage_inst.wb_reg,
         //           soc_top_inst.cpu_inst.wb_stage_inst.rf_en
         //          );
         //  $display("[��ˮ��] IF_VALID=%b,    ID_VALID=%b,    EX_VALID=%b,    MEM_VALID=%b,    WB_VALID=%b",
         //           soc_top_inst.cpu_inst.if_stage_inst.if_valid,
         //           soc_top_inst.cpu_inst.id_stage_inst.id_valid,
         //           soc_top_inst.cpu_inst.ex_stage_inst.ex_valid,
         //           soc_top_inst.cpu_inst.mem_stage_inst.mem_valid,
         //           soc_top_inst.cpu_inst.wb_stage_inst.wb_valid);
         //  $display("[��ˮ��] IF_READY_GO=%b, ID_READY_GO=%b, EX_READY_GO=%b, MEM_READY_GO=%b, WB_READY_GO=%b",
         //           soc_top_inst.cpu_inst.if_stage_inst.if_ready_go,
         //           soc_top_inst.cpu_inst.id_stage_inst.id_ready_go,
         //           soc_top_inst.cpu_inst.ex_stage_inst.ex_ready_go,
         //           soc_top_inst.cpu_inst.mem_stage_inst.mem_ready_go,
         //           soc_top_inst.cpu_inst.wb_stage_inst.wb_ready_go);
         //  $display("[����ð��] rf_rd1_hazard=%b, rf_rd2_hazard=%b",
         //           soc_top_inst.cpu_inst.id_stage_inst.rf_rd1_hazard,
         //           soc_top_inst.cpu_inst.id_stage_inst.rf_rd2_hazard);
         //  $display("[����ð��] use_rf_rd1=%b,    use_rf_rd2=%b",
         //           soc_top_inst.cpu_inst.id_stage_inst.use_rf_rd1,
         //           soc_top_inst.cpu_inst.id_stage_inst.use_rf_rd2);
         //  $display("[����ð��] rd1_en=%b,        rd2_en=%b",
         //           soc_top_inst.cpu_inst.id_stage_inst.rd1_en,
         //           soc_top_inst.cpu_inst.id_stage_inst.rd2_en);
         //  $display("[����ð��] ex_rf_we=%b,  mem_rf_we=%b,  wb_rf_we=%b",
         //           soc_top_inst.cpu_inst.id_stage_inst.ex_rf_we,
         //           soc_top_inst.cpu_inst.id_stage_inst.mem_rf_we,
         //           soc_top_inst.cpu_inst.id_stage_inst.wb_rf_we);
         //  $display("[����ð��] ex_wb_reg=%d, mem_wb_reg=%d, wb_wb_reg=%d",
         //           soc_top_inst.cpu_inst.id_stage_inst.ex_wb_reg,
         //           soc_top_inst.cpu_inst.id_stage_inst.mem_wb_reg,
         //           soc_top_inst.cpu_inst.id_stage_inst.wb_wb_reg);
         //  $display("[����ð��] id_rf_we=%b, EX.rf_we=%b",
         //           soc_top_inst.cpu_inst.id_stage_inst.id_rf_we,
         //           soc_top_inst.cpu_inst.ex_stage_inst.rf_we);
         $display("[�Ĵ���] x0 =%h, x1 =%h, x2 =%h, x3 =%h, x4 =%h, x5 =%h, x6 =%h, x7 =%h",
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[0],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[1],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[2],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[3],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[4],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[5],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[6],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[7]
                 );
         $display("[�Ĵ���] x8 =%h, x9 =%h, x10=%h, x11=%h, x12=%h, x13=%h, x14=%h, x15=%h",
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[8],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[9],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[10],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[11],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[12],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[13],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[14],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[15]
                 );
         $display("[�Ĵ���] x16=%h, x17=%h, x18=%h, x19=%h, x20=%h, x21=%h, x22=%h, x23=%h",
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[16],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[17],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[18],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[19],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[20],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[21],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[22],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[23]
                 );
         $display("[�Ĵ���] x24=%h, x25=%h, x26=%h, x27=%h, x28=%h, x29=%h, x30=%h, x31=%h",
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[24],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[25],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[26],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[27],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[28],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[29],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[30],
                  soc_top_inst.cpu_inst.id_stage_inst.rf_inst.regs[31]
                 );
         $display("---------------------------");
     end
 end

 // ���沨���ļ������������֧��
 initial
 begin
     $dumpfile("cpu_test.vcd");
     $dumpvars(0, cpu_tb);
 end

 endmodule
