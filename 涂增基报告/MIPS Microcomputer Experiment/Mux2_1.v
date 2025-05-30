`timescale 1ns / 1ps
module Mux2_1 (In1, In2, sel, Out);  //��·������ Mux2_1
parameter n=32;
input [n-1:0] In1, In2;   //���룺In1��n λ����In2��n λ����sel
input sel;
output [n-1:0] Out;    //�����Out��n λ��
//������ n λ�������ͨ�����õ�һ�����ͬλ��ͨ������ sel Ϊ 0 ʱ��ѡ�� In1 ���������ѡ�� In2 ���
assign Out = sel?In2:In1;
endmodule