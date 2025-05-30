`timescale 1ns / 1ps
module LeftShift (In, Out);
//���������� LeftShift �� n λ�������� x λ(��λ���� 0����λ�Ƴ�)��� m λ����
    parameter n=32,m=32,x=2;
input  [n-1:0] In;
output [m-1:0] Out;
assign Out =In << x;
endmodule