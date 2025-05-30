module ALU( //32 λ�������߼����㵥Ԫ ALU
    input signed [31:0] In1,
    input signed [31:0] In2,
    input [3:0] ALUCtr,
    //�������ţ���������Դ 1-In1��32 λ������������Դ 2-In2��32 λ�����������Ϳ���-ALUCtr��3 λ��
    output reg [31:0] ALURes,
    output  Zero
    //������ţ������� Res��32 λ��
    );
//���������־ Zero��1 λ����� Res ��Ϊ�� Zero Ϊ 0������ Zero Ϊ 1
assign Zero=(ALURes==0)?1:0;
    
always @(In1 or In2 or ALUCtr)
begin
     case(ALUCtr)
        4'b0110://sub
           begin
           ALURes = In1-In2;
           
           end
         4'b0010://add
           begin
           ALURes = In1+In2;
           
           end
         4'b0000://and
           begin
           ALURes = In1 & In2;
           
           end
          4'b0001://or
           begin
           ALURes = In1 | In2;
          
           end
          4'b0111://slt
           begin
           ALURes = (In1<In2)?1:0;
           
           end
          default:
            begin
            ALURes=0;
            
            end
       endcase
end
endmodule