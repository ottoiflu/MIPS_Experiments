`timescale 1ns / 1ps
module Controller (OpCode, Funct, J, B, RegDst, RegWr, ALUSrc, MemWr, Mem2Reg, ALUCtr); //������
input [5:0] OpCode, Funct;
output J, B, RegDst, RegWr, ALUSrc, MemWr, Mem2Reg;
output [3:0] ALUCtr;
wire [1:0] ALUOp;

//������������ Mainctr �Լ� ALU ������ ALUControl ʵ�ֶ�ָ��Ĳ�����͹�����������������ź�
MainCtr U0(OpCode,J, B, RegDst, RegWr, ALUSrc, MemWr, Mem2Reg, ALUOp);//����������һ������,�õ�ALUOp[1:0]
ALUControl U1(ALUOp, Funct, ALUCtr);  //ALU�������ڶ������룬����ALUCtr[3:0]
endmodule