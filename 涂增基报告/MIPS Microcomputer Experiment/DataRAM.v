`timescale 1ns / 1ps
module DataRAM(Addr,DataIn,MemWR,Clk,DataOut);
//ͬ����ʱ�������أ�����\�첽������ݴ洢�� DataRAM������Ϊ 2n*m
parameter n=5,m=32;
reg [m-1:0] regs[2**n-1:0];
input [n-1:0] Addr;
input [m-1:0] DataIn;
input MemWR,Clk;
output [m-1:0] DataOut;
//��ַ�� Addr (λ�� n)������������ DataIn��λ�� m����д�����ź� MemWR(�ߵ�ƽ��Ч)��ͬ��ʱ�� Clk
//������� DataOut��λ�� m�����б��ֹ��ܣ�

assign DataOut = regs[Addr];
always @ (posedge Clk)
begin
   if(MemWR)
   regs[Addr] <= DataIn;
end
endmodule