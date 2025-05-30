`timescale 1ns / 1ps
module RegFile (RsAddr, RtAddr, WrAddr, DataIn, RegWr,Clk, RsData, RtData);
//ͬ������\�첽����Ĵ����ļ� RegFile������Ϊ 32*32���ұ��Ϊ 0 �ļĴ���ȡֵ��Ϊ 0
//�������ţ�Rs �Ĵ������ RsAddr (λ�� 5)��Rt �Ĵ������ RtAddr (λ�� 5)��д�Ĵ������ WrAddr��(λ�� 5)������������ DataIn��λ��
//32����д�����ź� RegWr���ߵ�ƽ��Ч����ͬ��ʱ�� Clk
input [4:0] RsAddr,RtAddr, WrAddr;
input [31:0] DataIn;
input RegWr,Clk;
//������ţ�Rs �Ĵ������� RsData��λ�� 32����Rt �Ĵ������� RtData��λ�� 32��
output [31:0] RsData, RtData;
reg [31:0] regs[31:0];

//R��ָ��ִ��ʱ�����ȸ���ָ���ֶ�Instr[25...21],Instr[20...16]��ȡ$Rs,$Rt��ֵ
assign RsData=RsAddr?regs[RsAddr]:0;
assign RtData=RtAddr?regs[RtAddr]:0;

always @(posedge Clk)
    if(RegWr)
    regs[WrAddr]=DataIn;
    
endmodule