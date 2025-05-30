`timescale 1ns / 1ps
module Mux3_1 (In1, In2,In3, sel, Out);
//n λ 3 ѡ 1 ��·������ Mux3_1 ���� n λ 2 ѡ 1 ��·����������
    parameter n=32;
input [n-1:0] In1, In2,In3;
input [1:0] sel;
output [n-1:0] Out;
wire [n-1:0] OutTemp;
Mux2_1 U0(In1, In2, sel[0], OutTemp);
Mux2_1 U1(OutTemp, In3, sel[1], Out);

endmodule