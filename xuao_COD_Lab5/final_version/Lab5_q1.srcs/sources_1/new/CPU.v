`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/23 10:36:46
// Design Name: 
// Module Name: CPU
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


module CPU(
    // 本模块既有 cpu，也有mem
    // 一定要记住的是，在CPU模块
    // output是从cpu到pdu,而input是从pdu到cpu
    input clk,
    input rstn,

    // IO BUS
    output reg [7:0] io_addr,// 外设的地址
    output reg [31:0] io_dout,// 向外设输出的数据
    output reg io_we,// 向外设输出数据时的写使能信号
    output reg io_rd,// 从外设输入数据时的读使能信号
    input [31:0] io_din,// 来自外设的输入数据

/*  // 仿真
    output [31:0] out0,out1,outa,outb,
    output blt_tmp,
    output [31:0] ir_tmp
*/

    // Debug BUS
    output [31:0] pc,
    input [15:0] chk_addr,
    output reg [31:0] chk_data
);

// 控制指令
wire [31:0] ID_ctrl;
reg [31:0] EX_ctrl,Mem_ctrl,WB_ctrl;
// 下标从0开始，分别为：
// RegWrite, ALUSrc, MemWrite, MemRead, MemtoReg, PCSrc, Branch,
// ALUop, ALU_equal, ALU_lessthan, ALU_auipc, PC_jal 
wire PCSrc;

// PC,IR
reg [31:0] IF_pc,ID_pc,EX_pc,Mem_pc,WB_pc;
wire [31:0] IF_IR;
reg [31:0] ID_IR, EX_IR, Mem_IR, WB_IR;

// 寄存器堆
reg [31:0] Registers[0:31];

//===========================================================================================
//===========================================================================================

// IF
// 更新pc, 取IR

// pc
wire [31:0] n_pc,nxt_pc,pc_add4,pc_branch;
wire [31:0] pc_jal;

assign pc = WB_pc;
// 这里我设置为了最后一个流水段对应的pc值，方便设置连续运行时的断点地址
assign pc_add4 = (rstn==0) ? 32'h3000 : IF_pc + 32'h4;
assign n_pc = (PCSrc == 1) ? pc_branch : pc_add4;
assign nxt_pc = (EX_ctrl[11] == 1) ? pc_jal : n_pc;

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        IF_pc <= 32'h3000;
    end
    else if(PCSrc) begin
        // 这里很重要，当分支指令的下一条是lw指令，并且应该跳转时，那就直接跳转
        // 如果没有这一步，那么lw指令就会讲原本的跳转给冲掉
        IF_pc <= nxt_pc;
    end
    else if(ID_IR[6:0]==7'b0000011) begin
        // lw, 需要停一个周期
        IF_pc <= IF_pc;
    end
    else begin
        IF_pc <= nxt_pc;
    end
end

// instruction
wire [7:0] real_IR_addr;
assign real_IR_addr = (IF_pc-32'h3000)>>2;
instruction IR0(.a(real_IR_addr),.spo(IF_IR));

// 传PC、IR到下一流水段
always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        ID_pc <= 0;
        ID_IR <= 0;
    end
    else if(PCSrc == 1 || EX_ctrl[11] == 1) begin
        ID_pc <= 0;
        ID_IR <= 0;
    end
    else if(ID_IR[6:0]==7'b0000011) begin
        ID_pc <= 0;
        ID_IR <= 0;
    end
    else begin
        ID_pc <= IF_pc;
        ID_IR <= IF_IR;
    end
end

//===========================================================================================
//===========================================================================================

// ID
// 寄存器读, 算imm_gen, 求出 control 

// 寄存器堆的读操作
wire [4:0] RegReadAddr1,RegReadAddr2;
wire [31:0] RegReadData1,RegReadData2;

assign RegReadAddr1 = ID_IR[19:15];
assign RegReadAddr2 = ID_IR[24:20];
assign RegReadData1 = Registers[RegReadAddr1];
assign RegReadData2 = Registers[RegReadAddr2];

// 算imm_gen
wire [31:0] imm_num;
Imm_Gen Imm0(.IR(ID_IR),.imm_num(imm_num));

// 算 control
Ctrl Ctrl0(.IR(ID_IR),.control(ID_ctrl));

// 传PC、IR、A、B、Imm、control 到下一流水段
reg [31:0] EX_A,EX_B;
reg [31:0] EX_Imm;
always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        EX_pc <= 0;
        EX_IR <= 0;
        EX_A <= 0; EX_B <= 0;
        EX_Imm <= 0;
        EX_ctrl <= 0;
    end
    else if(PCSrc == 1 || EX_ctrl[11] == 1) begin
        EX_pc <= 0;
        EX_IR <= 0;
        EX_A <= 0; EX_B <= 0;
        EX_Imm <= 0;
        EX_ctrl <= 0;
    end
    else begin
        EX_pc <= ID_pc;
        EX_IR <= ID_IR;
        EX_A <= RegReadData1;
        EX_B <= RegReadData2;
        EX_Imm <= imm_num;
        EX_ctrl <= ID_ctrl;
    end
end

//===========================================================================================
//===========================================================================================

// EX
// ALU,pc条件跳转、无条件跳转
// 如果真的发生了跳转，那么在其后的已经进入流水线指令须清除

// ALU
wire [31:0] ALU_a,ALU_b;
assign ALU_a = (EX_ctrl[10]==1) ? EX_pc : EX_A;
assign ALU_b = (EX_ctrl[1]==0) ? EX_B : ((EX_ctrl[10]==1) ? {EX_Imm[19:0],12'b0} : EX_Imm);

// 再考虑数据相关
reg [31:0] ALU_A,ALU_B;
always @(*) begin
    // 0010011,0110011 addi,add,sub 
    // 0010111 auipc
    // 0000011 lw
    // ALU第一个操作数
    if((Mem_IR[6:0]==7'b0010011 || Mem_IR[6:0]==7'b0110011 || Mem_IR[6:0]==7'b0010111 || Mem_IR[6:0]==7'b0000011) && (EX_IR[19:15]==Mem_IR[11:7])) begin
        ALU_A = Mem_ALU_result;
    end
    else if((WB_IR[6:0]==7'b0010011 || WB_IR[6:0]==7'b0110011 || WB_IR[6:0]==7'b0010111 || WB_IR[6:0]==7'b0000011) && EX_IR[19:15]==WB_IR[11:7]) begin
        ALU_A = WB_ALU_result;
    end
    else begin
        ALU_A = ALU_a;
    end
    // ALU第二个操作数
    if((Mem_IR[6:0]==7'b0010011 || Mem_IR[6:0]==7'b0110011 || Mem_IR[6:0]==7'b0010111 || Mem_IR[6:0]==7'b0000011) && EX_IR[24:20]==Mem_IR[11:7]) begin
        ALU_B = Mem_ALU_result;
    end
    else if((WB_IR[6:0]==7'b0010011 || WB_IR[6:0]==7'b0110011 || WB_IR[6:0]==7'b0010111 || WB_IR[6:0]==7'b0000011) && EX_IR[24:20]==WB_IR[11:7]) begin
        ALU_B = WB_ALU_result;
    end
    else begin
        ALU_B = ALU_b;
    end
end 


wire [31:0] ALU_result;
wire ALU_equal,ALU_lessthan;
ALU ALU0(.a(ALU_A),.b(ALU_B),.op(EX_ctrl[7]),.result(ALU_result),.alu_equal(ALU_equal),.alu_lessthan(ALU_lessthan));

// 更新控制信号
assign PCSrc = EX_ctrl[6] & ((EX_IR[14:12]==3'b000) ? ALU_equal : ALU_lessthan);
wire MemWrite;
assign MemWrite = (EX_IR[6:0]==7'b0100011 && ALU_result[8]==0) ? 1 : 0; // sw,并且要写入存储器的地址小于256，也即不是IO地址

// beq,blt
wire [31:0] imm_shift;
assign imm_shift = EX_Imm << 1;
assign pc_branch = EX_pc + imm_shift;

// jal,jalr
wire jalr;
assign jalr = (EX_IR[6:0]==7'b1100111) ? 1 : 0;
assign pc_jal = (jalr==1) ? (ALU_A+EX_Imm)&~1 : (EX_pc+{EX_Imm[30:0],1'b0});

// 传control、ALU_result、B、IR、
reg [31:0] Mem_ALU_result,Mem_B;
always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        Mem_ALU_result <= 0;
        Mem_B <= 0;
        Mem_ctrl <= 0;
        Mem_IR <= 0;
        Mem_pc <= 0;
    end    
    else begin
        Mem_ALU_result <= ALU_result;
        Mem_B <= EX_B;
        Mem_ctrl <= {EX_ctrl[31:10],ALU_lessthan,ALU_equal,EX_ctrl[7:6],PCSrc,EX_ctrl[4:3],MemWrite,EX_ctrl[1:0]};
        Mem_IR <= EX_IR;
        Mem_pc <= EX_pc;
    end
end

//===========================================================================================
//===========================================================================================

// Mem
// memory的读写操作

//Memory
//一个读写地址，一个写数据，一个读数据，读使能（好像没什么用），写使能
wire [31:0] MemReadData;
wire [31:0] Chk_Data;
memory memory0(
  .a(Mem_ALU_result[7:0]>>2),        // input wire [7 : 0] a
  .d(Mem_B),        // input wire [31 : 0] d
  .dpra(chk_addr[7:0]),  // input wire [7 : 0] dpra
  .clk(clk),    // input wire clk
  .we(Mem_ctrl[2]),      // input wire we
  .spo(MemReadData),    // output wire [31 : 0] spo
  .dpo(Chk_Data)    // output wire [31 : 0] dpo
);

// 传control,MemReadData,ALU_result,IR
reg [31:0] WB_MemReadData,WB_ALU_result;
always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        WB_ALU_result <= 0;
        WB_ctrl <= 0;
        WB_IR <= 0;
        WB_MemReadData <= 0;
        WB_pc <= 0;
    end
    else begin
        WB_ALU_result <= Mem_ALU_result;
        WB_ctrl <= Mem_ctrl;
        WB_IR <= Mem_IR;
        WB_MemReadData <= MemReadData;
        WB_pc <= Mem_pc;
    end
end

//===========================================================================================
//===========================================================================================

// WB
// Reg 的写入操作
// 但实际上数据准备工作是在Mem阶段完成，写入是在Mem结束时的时钟上升沿

wire [31:0] RegWriteData;
wire [31:0] WB_pc_add4;
assign WB_pc_add4 = Mem_pc + 32'h4;
assign RegWriteData = (Mem_ctrl[11]==1) ? (WB_pc_add4) : ((Mem_ctrl[4] == 1) ? Mem_ALU_result : MemReadData); 

wire [4:0] RegWriteAddr;
assign RegWriteAddr = Mem_IR[11:7]; 

wire [31:0] Reg_io;
assign Reg_io = (Mem_IR[6:0]==7'b0000011 && Mem_ALU_result[8]==1) ? io_din : Reg_io;

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
    // 寄存器堆清零
        Registers[0] <= 0; Registers[1] <= 0; Registers[2] <= 0; Registers[3] <= 0; Registers[4] <= 0; Registers[5] <= 0; Registers[6] <= 0; Registers[7] <= 0;
        Registers[8] <= 0; Registers[9] <= 0; Registers[10] <= 0; Registers[11] <= 0; Registers[12] <= 0; Registers[13] <= 0; Registers[14] <= 0; Registers[15] <= 0;
        Registers[16] <= 0; Registers[17] <= 0; Registers[18] <= 0; Registers[19] <= 0; Registers[20] <= 0; Registers[21] <= 0; Registers[22] <= 0; Registers[23] <= 0;
        Registers[24] <= 0; Registers[25] <= 0; Registers[26] <= 0; Registers[27] <= 0; Registers[28] <= 0; Registers[29] <= 0; Registers[30] <= 0; Registers[31] <= 0;
    end
    else begin
        if(Mem_ctrl[0]==1) begin
            if(RegWriteAddr==0) Registers[0] <= 0;
            else if(Mem_IR[6:0]==7'b0000011 && Mem_ALU_result[8]==1) begin
                Registers[RegWriteAddr] <= Reg_io;
            end
            else begin
                Registers[RegWriteAddr] <= RegWriteData;
            end
        end
    end
end

//===========================================================================================
//===========================================================================================

// IO
// MMIO 的起始地址是 32'h0100，这样的好处就在于可以避免地址太大，而需要额外加指令
// 00:输出数据到 led;  0c:输出数据到 seg  
always @(*) begin
    // 如果是向外设 store 数据，那么输出数据应该是在 Mem 流水段发生
    if(Mem_IR[6:0]==7'b0100011) begin
    // sw
        if(Mem_ALU_result==32'h0100) begin 
            // led
            io_addr = 8'h00;
            io_we = 1;
            io_dout = Mem_B;
        end 
        else if(Mem_ALU_result==32'h010C) begin
            // seg
            io_addr = 8'h0C;
            io_we = 1;
            io_dout = Mem_B;
        end
        else begin
            io_addr = 0;
            io_we = 0;
            io_dout = 0;
        end
    end
    // 如果是从外设load，那么读入数据应该是在WB流水段
    else if(WB_IR[6:0]==7'b0000011) begin
    // lw
        if(Mem_ALU_result==32'h0114) begin
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

//===========================================================================================
//===========================================================================================

// Debug Bus

always @(*) begin
    case(chk_addr[13:12])
    2'b00: begin
        case(chk_addr[4:0])
            5'b00000: chk_data = nxt_pc;
            5'b00001: chk_data = IF_pc;
            5'b00010: chk_data = ID_pc;
            5'b00011: chk_data = EX_pc;
            5'b00100: chk_data = Mem_pc;
            5'b00101: chk_data = WB_pc;
//            5'b00011: chk_data = IF_IR;
//            5'b00100: chk_data = ID_ctrl;
//            5'b00101: chk_data = EX_pc;
            5'b00110: chk_data = EX_A;
            5'b00111: chk_data = EX_B;
//            5'b01000: chk_data = imm_num;
            5'b01000: chk_data = pc_branch;
            5'b01001: chk_data = EX_IR;
            5'b01010: chk_data = Mem_ctrl;
            5'b01011: chk_data = Mem_ALU_result;
            5'b01100: chk_data = Mem_B;
            5'b01101: chk_data = Mem_IR;
            5'b01110: chk_data = WB_ctrl;
            5'b01111: chk_data = WB_MemReadData;
            5'b10000: chk_data = WB_ALU_result;
            5'b10001: chk_data = WB_IR;
            5'b10010: chk_data = WB_pc;
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
