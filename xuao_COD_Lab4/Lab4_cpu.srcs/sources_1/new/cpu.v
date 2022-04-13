`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/09 19:50:19
// Design Name: 
// Module Name: cpu
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


module cpu(
    // 本模块既有 cpu，也有mem
    // 一定要记住的是，在CPU模块
    // output是从cpu到pdu,而input是从pdu到cpu
    input clk,
    input rstn,

    //IO BUS
    output reg [7:0] io_addr,// 外设的地址
    output reg [31:0] io_dout,// 向外设输出的数据
    output reg io_we,// 向外设输出数据时的写使能信号
    output reg io_rd,// 从外设输入数据时的读使能信号
    input [31:0] io_din,// 来自外设的输入数据

/*    // 仿真
    output [31:0] out0,out1,outa,outb,
    output blt_tmp,
    output [31:0] ir_tmp
*/
    // Debug BUS
    output [31:0] pc,
    input [15:0] chk_addr,
    output reg [31:0] chk_data
);

/*
assign out0 = cur_pc;
assign out1 = mmio0;
assign ir_tmp = IR;
assign blt_tmp = ALUSrc;
assign outa = RegReadData1;
assign outb = RegReadData2;
*/


// 控制指令
wire [31:0] IR; //当前指令的内容
wire RegWrite,ALUSrc,MemWrite,MemRead,MemtoReg,PCSrc,Branch;
wire ALUop; // 1:+;0:-
wire ALU_equal,ALU_lessthan; // 分支指令的条件是否得到满足
wire ALU_auipc;
wire PC_jal; // 当前指令是否为 jal 或者 jalr

// pc
// pc在RARS中是逐条+4的，这里需要特殊判定
// 实际的pc值就是逐条+4，但是指令寄存器是逐条存储的
// 所以，用 pc 取指令时，需要先 -32'h3000,再除以4，才是指令在指令寄存器的物理地址
reg     [31:0] cur_pc;
wire    [31:0] nxt_pc,pc_add4,pc_branch; 
wire    [31:0] pc_jal; // jal 和 jalr 的目标地址

assign pc = cur_pc;

// 当前 pc,下一个 pc,pc+4，跳转的目标pc地址,pc选择信号
always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        cur_pc <= 32'h3000;
    end
    else begin
        cur_pc <= nxt_pc;
    end
end

assign pc_add4 = (rstn==0) ? 32'h3000 : cur_pc + 32'h4;
assign PCSrc = Branch & ((IR[14:12]==3'b000) ? ALU_equal : ALU_lessthan);
wire [31:0] n_pc;
assign n_pc = (PCSrc == 1) ? pc_branch : pc_add4;
assign nxt_pc = (PC_jal==1) ? pc_jal : n_pc; 
// PCSrc == 1,则跳转


// instruction
wire [7:0] real_IR_addr;
assign real_IR_addr = (cur_pc-32'h3000)>>2;
// 指令寄存器只涉及读操作，所以采用ROM
instrcution IR0(.a(real_IR_addr),.spo(IR));


// 寄存器堆
reg [31:0] Registers[0:31];
// 寄存器堆有两个读地址，两个读端口，一个写地址，一个写端口，和写使能
wire [4:0] RegReadAddr1, RegReadAddr2,RegWriteAddr;
wire [31:0] RegReadData1,RegReadData2,RegWriteData;

assign RegReadAddr1 = IR[19:15];
assign RegReadAddr2 = IR[24:20];
assign RegWriteAddr = IR[11:7];
assign RegReadData1 = Registers[RegReadAddr1];
assign RegReadData2 = Registers[RegReadAddr2];

wire [31:0] ALU_result;
wire [31:0] MemReadData;
assign RegWriteData = (PC_jal==1) ? pc_add4 : ((MemtoReg == 1) ? ALU_result : MemReadData); 
wire [31:0] reg_io;
assign reg_io = (IR[6:0]==7'b0000011 && ALU_result[8]==1) ? io_din : reg_io;

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
    // 寄存器堆清零
        Registers[0] <= 0; Registers[1] <= 0; Registers[2] <= 0; Registers[3] <= 0; Registers[4] <= 0; Registers[5] <= 0; Registers[6] <= 0; Registers[7] <= 0;
        Registers[8] <= 0; Registers[9] <= 0; Registers[10] <= 0; Registers[11] <= 0; Registers[12] <= 0; Registers[13] <= 0; Registers[14] <= 0; Registers[15] <= 0;
        Registers[16] <= 0; Registers[17] <= 0; Registers[18] <= 0; Registers[19] <= 0; Registers[20] <= 0; Registers[21] <= 0; Registers[22] <= 0; Registers[23] <= 0;
        Registers[24] <= 0; Registers[25] <= 0; Registers[26] <= 0; Registers[27] <= 0; Registers[28] <= 0; Registers[29] <= 0; Registers[30] <= 0; Registers[31] <= 0;
      
    end
    else begin
        if(RegWrite==1) begin
            if(RegWriteAddr==0) Registers[0] <= 0;
            else begin
                if(IR[6:0]==7'b0000011 && ALU_result[8]==1) begin
                    Registers[RegWriteAddr] <= reg_io;
                end
                else Registers[RegWriteAddr] <= RegWriteData;
            end
        end
    end
end


//Memory
//一个读写地址，一个写数据，一个读数据，读使能（好像没什么用），写使能

wire [31:0] Chk_Data;

Memory memory0(
  .a(ALU_result[7:0]),        // input wire [7 : 0] a
  .d(RegReadData2),        // input wire [31 : 0] d
  .dpra(chk_addr[7:0]),  // input wire [7 : 0] dpra
  .clk(clk),    // input wire clk
  .we(MemWrite),      // input wire we
  .spo(MemReadData),    // output wire [31 : 0] spo
  .dpo(Chk_Data)    // output wire [31 : 0] dpo
);



// 控制指令
assign Branch = (IR[6:0]==7'b1100011) ? 1 : 0; // beq blt
assign MemRead = (IR[6:0]==7'b0000011) ? 1 : 0; // lw
assign MemtoReg = (IR[6:0]==7'b0000011) ? 0 : 1; // lw:0; add,addi,auipc,sub:1
assign ALUop = ((IR[6:0]==7'b0110011)&&(IR[31:25]==7'b0100000)) ? 0 : 1;
assign MemWrite = (IR[6:0]==7'b0100011 && ALU_result[8]==0) ? 1 : 0; // sw,并且要写入存储器的地址小于256，也即不是IO地址
assign ALUSrc = (IR[6:0]==7'b0110011 || IR[6:0]==7'b1100011) ? 0 : 1;
// add,sub,beq,blt:0     addi,auipc,lw,sw:1
assign RegWrite = (IR[6:0]==7'b0110011 || IR[6:0]==7'b0010011 || IR[6:0]==7'b0010111 || IR[6:0]==7'b0000011 || IR[6:0]==7'b1101111 || IR[6:0]==7'b1100111) ? 1 : 0;
// add,sub,addi,auipc,lw,jal,jalr: 1
assign ALU_auipc = (IR[6:0]==7'b0010111) ? 1 : 0; 
assign PC_jal = (IR[6:0]==7'b1101111 || IR[6:0]==7'b1100111) ? 1 : 0;



//Imm Gen
wire [31:0] imm_num;
Imm_Gen Imm0(.IR(IR),.imm_num(imm_num));


// ALU
wire [31:0] ALU_a,ALU_b;
assign ALU_a = (ALU_auipc==1) ? cur_pc : RegReadData1;
assign ALU_b = (ALUSrc == 0) ? RegReadData2 : ((ALU_auipc==1) ? {imm_num[19:0],12'b0} : imm_num) ;
wire [31:0] ALUresult;
ALU ALU0(.a(ALU_a),.b(ALU_b),.op(ALUop),.result(ALU_result),.alu_equal(ALU_equal),.alu_lessthan(ALU_lessthan));



// beq,blt
wire [31:0] imm_shift;
assign imm_shift = imm_num<<1;
assign pc_branch = cur_pc + imm_shift;


// jal
wire jalr;
assign jalr = (IR[6:0]==7'b1100111) ? 1 : 0;
assign pc_jal = (jalr==1) ? (RegReadData1+imm_num)&~1 : (cur_pc+{imm_num[30:0],1'b0});


// IO
// MMIO 的起始地址是 32'h0100，这样的好处就在于可以避免地址太大，而需要额外加指令
// 00:输出数据到 led;  0c:输出数据到 seg  
always @(*) begin
    if(IR[6:0]==7'b0100011) begin
    // sw
        if(ALU_result==32'h0100) begin 
            // led
            io_addr = 8'h00;
            io_we = 1;
            io_dout = RegReadData2;
        end 
        else if(ALU_result==32'h010C) begin
            // seg
//            io_addr = 8'h08;// 读取数码管输出有效的标志位
//            if(io_din[0]==1) begin
                io_addr = 8'h0C;
                io_we = 1;
                io_dout = RegReadData2;
//            end
        end
        else begin
            io_addr = 0;
            io_we = 0;
            io_dout = 0;
        end
    end
    else if(IR[6:0]==7'b0000011) begin
    // lw
        if(ALU_result==32'h0114) begin
            // 开关
//            io_addr = 8'h10;
//            if(io_din[0]==1) begin
            io_addr = 8'h14;
            io_rd = 1;
//            end
        end
        else begin
            io_addr = 0;
            io_rd = 0;
        end
    end
    else begin
        io_addr = 0;
        io_we = 0;
        io_dout = 0;
        io_rd = 0;
    end
end

always @(*) begin
    case(chk_addr[13:12])
    2'b00: begin
        case(chk_addr[3:0])
            4'b0000: chk_data = nxt_pc;
            4'b0001: chk_data = cur_pc;
            4'b0010: chk_data = IR;
            4'b0011: chk_data = {20'b0,RegWrite,ALUSrc,MemWrite,MemRead,MemtoReg,PCSrc,Branch,ALUop,ALU_equal,ALU_lessthan,ALU_auipc,PC_jal};
            4'b0100: chk_data = RegReadData1;
            4'b0101: chk_data = RegReadData2;
            4'b0110: chk_data = imm_num;
            4'b0111: chk_data = ALU_result;
            4'b1000: chk_data = MemReadData;
            default: chk_data = 0;
        endcase
    end
    2'b01: begin
        chk_data = Registers[chk_addr[7:0]];
    end 
    2'b10: begin
        chk_data = Chk_Data;
    end
    endcase
end

endmodule
