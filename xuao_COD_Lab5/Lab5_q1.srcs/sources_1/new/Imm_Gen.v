`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/23 18:12:24
// Design Name: 
// Module Name: Imm_Gen
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

module Imm_Gen(
    input [31:0] IR,
    output reg [31:0] imm_num
);
parameter one32 = 32'hffff_f000;
parameter one32_auipc = 32'hfff0_0000;


always @(*) begin
    if(IR[6:0]==7'b0010011) begin
    // addi
        if(IR[31]==1) imm_num = one32 | IR[31:20];
        else imm_num = IR[31:20];
    end
    else if(IR[6:0]==7'b0000011) begin
    // lw
        if(IR[31]==1) imm_num = one32 | IR[31:20];
        else imm_num = IR[31:20];
    end
    else if(IR[6:0]==7'b0100011) begin
    // sw
        if(IR[31]==1) imm_num = one32 | {IR[31:25],IR[11:7]};
        else imm_num = {IR[31:25],IR[11:7]};
    end
    else if(IR[6:0]==7'b1100011) begin
    // beq,blt
        if(IR[31]==1) imm_num = one32 | {IR[31],IR[7],IR[30:25],IR[11:8]};
        else imm_num = {IR[31],IR[7],IR[30:25],IR[11:8]}; 
    end
    else if(IR[6:0]==7'b0010111) begin
    // auipc
        if(IR[31]==1) imm_num = one32_auipc | IR[31:12];
        else imm_num = IR[31:12];    
    end
    else if(IR[6:0]==7'b1101111) begin
    // jal
        if(IR[31]==1) imm_num = one32_auipc | {IR[31],IR[19:12],IR[20],IR[30:21]};
        else imm_num = {IR[31],IR[19:12],IR[20],IR[30:21]};
    end
    else if(IR[6:0]==7'b1100111) begin
    // jalr
        if(IR[31]==1) imm_num = one32 | IR[31:20];
        else imm_num = IR[31:20];    
    end
end    
endmodule
