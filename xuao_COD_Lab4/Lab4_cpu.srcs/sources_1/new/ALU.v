`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/09 23:05:36
// Design Name: 
// Module Name: ALU
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

module ALU(
    input [31:0] a,b,
    input op,
    output [31:0] result,
    output alu_equal,
    output alu_lessthan
);

assign result = (op == 0) ? (a-b) : (a+b);
assign alu_equal = (a==b) ? 1 : 0;
assign alu_lessthan = (a<b) ? 1 : 0;

endmodule
