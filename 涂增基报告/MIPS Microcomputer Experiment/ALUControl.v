`timescale 1ns / 1ps
module ALUControl (ALUOp, Funct, ALUCtr);// ALU ������ ALUControl
input [1:0] ALUOp;
input [5:0] Funct;
output reg [3:0] ALUCtr;

always @(*)    //�Թ�����Funct[5:0]��ALUOp[1��0]��������
casex({ALUOp, Funct})
8'b00xxxxxx:ALUCtr=4'b0010; 
8'b00xxxxxx:ALUCtr=4'b0010; 
8'b01xxxxxx:ALUCtr=4'b0110; 
8'b10100000:ALUCtr=4'b0010;
8'b10100010:ALUCtr=4'b0110; 
8'b10100100:ALUCtr=4'b0000;
8'b10100101:ALUCtr=4'b0001;
8'b10101010:ALUCtr=4'b0111;
endcase
endmodule