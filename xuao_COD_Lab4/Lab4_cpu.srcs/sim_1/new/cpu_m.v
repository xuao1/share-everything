`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/10 10:42:48
// Design Name: 
// Module Name: cpu_m
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


module cpu_m();

reg clk;
reg rstn;
wire [31:0] a,b,alu_a,alu_b;
wire [31:0] ir;
wire c;

cpu cpu0(
    // 本模块既有 cpu，也有mem
    // 一定要记住的是，在CPU模块
    // output是从cpu到pdu,而input是从pdu到cpu
    .clk(clk),
    .rstn(rstn),

    //IO BUS
    .io_addr(),// 外设的地址
    .io_dout(),// 向外设输出的数据
    .io_we(),// 向外设输出数据时的写使能信号
    .io_rd(),// 从外设输入数据时的都使能信号
    .io_din(32'b0),// 来自外设的输入数据

    // 仿真
    .out0(a),
    .out1(b),
    .outa(alu_a),
    .outb(alu_b),
    .blt_tmp(c),
    .ir_tmp(ir)
);


initial begin
    rstn <= 0;
    clk <= 0;
end

always #1 clk = ~clk; 
      
initial begin
    #2 rstn = 1;
    #500 $finish;
end

endmodule
