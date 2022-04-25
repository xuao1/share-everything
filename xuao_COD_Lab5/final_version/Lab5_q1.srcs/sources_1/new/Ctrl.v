`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/23 11:34:24
// Design Name: 
// Module Name: Ctrl
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

module Ctrl(
    input [31:0] IR,
    output [31:0] control
);

assign control[6] = (IR[6:0]==7'b1100011) ? 1 : 0; // beq blt
assign control[3] = (IR[6:0]==7'b0000011) ? 1 : 0; // lw
assign control[4] = (IR[6:0]==7'b0000011) ? 0 : 1; // lw:0; add,addi,auipc,sub:1
assign control[7] = ((IR[6:0]==7'b0110011)&&(IR[31:25]==7'b0100000)) ? 0 : 1;
//assign control[2] = (IR[6:0]==7'b0100011 && ALU_result[8]==0) ? 1 : 0; // sw,并且要写入存储器的地址小于256，也即不是IO地址
assign control[1] = (IR[6:0]==7'b0110011 || IR[6:0]==7'b1100011) ? 0 : 1;
// add,sub,beq,blt:0     addi,auipc,lw,sw:1
assign control[0] = (IR[6:0]==7'b0110011 || IR[6:0]==7'b0010011 || IR[6:0]==7'b0010111 || IR[6:0]==7'b0000011 || IR[6:0]==7'b1101111 || IR[6:0]==7'b1100111) ? 1 : 0;
// add,sub,addi,auipc,lw,jal,jalr: 1
assign control[10] = (IR[6:0]==7'b0010111) ? 1 : 0; 
assign control[11] = (IR[6:0]==7'b1101111 || IR[6:0]==7'b1100111) ? 1 : 0;
//assign control[5] = Branch & ((IR[14:12]==3'b000) ? ALU_equal : ALU_lessthan);

assign control[2] = 0;
assign control[5] = 0;
assign control[8] = 0;
assign control[9] = 0;
assign control[31:12] = 0;

endmodule
