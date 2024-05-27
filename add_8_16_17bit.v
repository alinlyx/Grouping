

 
 
module adder_1(operand1,operand2,cin,sum,cout);
    input operand1;    
    input operand2;    
    input cin;          
    output sum;      
    output cout;        

    assign cout = (operand1 & operand2) | (operand1 & cin) | (operand2 & cin);
    assign sum = operand1 ^ operand2 ^ cin;

endmodule


//module adder_subtract_8(operand1,operand2,add_or_sub,sum,overflow);
module adder_8(operand1,operand2,add_or_sub,sum,overflow);
    input [7:0]operand1;   
    input [7:0]operand2;    
    input add_or_sub;      
    output [7:0]sum;     
    output overflow;
    wire [8:0] c;           
    wire [8:0] op2;          
    
    assign op2[0] = add_or_sub ^ operand2[0];
    assign op2[1] = add_or_sub ^ operand2[1];
    assign op2[2] = add_or_sub ^ operand2[2];
    assign op2[3] = add_or_sub ^ operand2[3];
    assign op2[4] = add_or_sub ^ operand2[4];
    assign op2[5] = add_or_sub ^ operand2[5];
    assign op2[6] = add_or_sub ^ operand2[6];
    assign op2[7] = add_or_sub ^ operand2[7];
    assign op2[8] = add_or_sub ^ (1'b0) ;

    wire [8:0] operand1_bu0;
    assign operand1_bu0 = {1'b0,operand1};
    wire [8:0] sum1;

    adder_1 a0(operand1_bu0[0],op2[0],add_or_sub,sum[0],c[0]);
    adder_1 a1(operand1_bu0[1],op2[1],c[0],sum1[1],c[1]);
    adder_1 a2(operand1_bu0[2],op2[2],c[1],sum1[2],c[2]);
    adder_1 a3(operand1_bu0[3],op2[3],c[2],sum1[3],c[3]);
    adder_1 a4(operand1_bu0[4],op2[4],c[3],sum1[4],c[4]);
    adder_1 a5(operand1_bu0[5],op2[5],c[4],sum1[5],c[5]);
    adder_1 a6(operand1_bu0[6],op2[6],c[5],sum1[6],c[6]);
    adder_1 a7(operand1_bu0[7],op2[7],c[6],sum1[7],c[7]);
    adder_1 a8(operand1_bu0[8],op2[8],c[7],sum1[8],c[8]);

    assign overflow = sum1[8];
    assign sum [7:0] = sum1[7:0];
endmodule

module adder_16(operand1,operand2,add_or_sub,sum,overflow);
    input [15:0]operand1;    
    input [15:0]operand2;    
    input add_or_sub;       
    output [15:0]sum;    
    output overflow;       
    wire [15:0] c;          
    wire [15:0] op2;           
 
    assign op2[0] = add_or_sub ^ operand2[0];
    assign op2[1] = add_or_sub ^ operand2[1];
    assign op2[2] = add_or_sub ^ operand2[2];
    assign op2[3] = add_or_sub ^ operand2[3];
    assign op2[4] = add_or_sub ^ operand2[4];
    assign op2[5] = add_or_sub ^ operand2[5];
    assign op2[6] = add_or_sub ^ operand2[6];
    assign op2[7] = add_or_sub ^ operand2[7];
    assign op2[8] = add_or_sub ^ operand2[8];
    assign op2[9] = add_or_sub ^ operand2[9];
    assign op2[10] = add_or_sub ^ operand2[10];
    assign op2[11] = add_or_sub ^ operand2[11];
    assign op2[12] = add_or_sub ^ operand2[12];
    assign op2[13] = add_or_sub ^ operand2[13];
    assign op2[14] = add_or_sub ^ operand2[14];
    assign op2[15] = add_or_sub ^ operand2[15];
    
    wire overflow2;
    adder_1 b0(operand1[0],op2[0],add_or_sub,sum[0],c[0]);
    adder_1 b1(operand1[1],op2[1],c[0],sum[1],c[1]);
    adder_1 b2(operand1[2],op2[2],c[1],sum[2],c[2]);
    adder_1 b3(operand1[3],op2[3],c[2],sum[3],c[3]);
    adder_1 b4(operand1[4],op2[4],c[3],sum[4],c[4]);
    adder_1 b5(operand1[5],op2[5],c[4],sum[5],c[5]);
    adder_1 b6(operand1[6],op2[6],c[5],sum[6],c[6]);
    adder_1 b7(operand1[7],op2[7],c[6],sum[7],c[7]);
    adder_1 b8(operand1[8],op2[8],c[7],sum[8],c[8]);
    adder_1 b9(operand1[9],op2[9],c[8],sum[9],c[9]);
    adder_1 b10(operand1[10],op2[10],c[9],sum[10],c[10]);
    adder_1 b11(operand1[11],op2[11],c[10],sum[11],c[11]);
    adder_1 b12(operand1[12],op2[12],c[11],sum[12],c[12]);
    adder_1 b13(operand1[13],op2[13],c[12],sum[13],c[13]);
    adder_1 b14(operand1[14],op2[14],c[13],sum[14],c[14]);
    adder_1 b15(operand1[15],op2[15],c[14],sum[15],c[15]);
    xor x16(overflow2,c[14],c[15]);
    assign overflow = (add_or_sub == 1'b0) ? c[15] : overflow2;
endmodule

module adder_17(operand1,operand2,add_or_sub,sum,overflow);

    input [16:0]operand1;    
    input [16:0]operand2;    
    input add_or_sub;       
    output [16:0]sum;     
    output overflow;        
    wire [16:0] c;          
    wire [16:0] op2;          

    assign op2[0] = add_or_sub ^ operand2[0];
    assign op2[1] = add_or_sub ^ operand2[1];
    assign op2[2] = add_or_sub ^ operand2[2];
    assign op2[3] = add_or_sub ^ operand2[3];
    assign op2[4] = add_or_sub ^ operand2[4];
    assign op2[5] = add_or_sub ^ operand2[5];
    assign op2[6] = add_or_sub ^ operand2[6];
    assign op2[7] = add_or_sub ^ operand2[7];
    assign op2[8] = add_or_sub ^ operand2[8];
    assign op2[9] = add_or_sub ^ operand2[9];
    assign op2[10] = add_or_sub ^ operand2[10];
    assign op2[11] = add_or_sub ^ operand2[11];
    assign op2[12] = add_or_sub ^ operand2[12];
    assign op2[13] = add_or_sub ^ operand2[13];
    assign op2[14] = add_or_sub ^ operand2[14];
    assign op2[15] = add_or_sub ^ operand2[15];
    assign op2[16] = add_or_sub ^ operand2[16];

    wire overflow3;
    adder_1 c0(operand1[0],op2[0],add_or_sub,sum[0],c[0]);
    adder_1 c1(operand1[1],op2[1],c[0],sum[1],c[1]);
    adder_1 c2(operand1[2],op2[2],c[1],sum[2],c[2]);
    adder_1 c3(operand1[3],op2[3],c[2],sum[3],c[3]);
    adder_1 c4(operand1[4],op2[4],c[3],sum[4],c[4]);
    adder_1 c5(operand1[5],op2[5],c[4],sum[5],c[5]);
    adder_1 c6(operand1[6],op2[6],c[5],sum[6],c[6]);
    adder_1 c7(operand1[7],op2[7],c[6],sum[7],c[7]);
    adder_1 c8(operand1[8],op2[8],c[7],sum[8],c[8]);
    adder_1 c9(operand1[9],op2[9],c[8],sum[9],c[9]);
    adder_1 c10(operand1[10],op2[10],c[9],sum[10],c[10]);
    adder_1 c11(operand1[11],op2[11],c[10],sum[11],c[11]);
    adder_1 c12(operand1[12],op2[12],c[11],sum[12],c[12]);
    adder_1 c13(operand1[13],op2[13],c[12],sum[13],c[13]);
    adder_1 c14(operand1[14],op2[14],c[13],sum[14],c[14]);
    adder_1 c15(operand1[15],op2[15],c[14],sum[15],c[15]);
    adder_1 c16(operand1[16],op2[16],c[15],sum[16],c[16]);
    xor x17(overflow3,c[15],c[16]);
    assign overflow = (add_or_sub == 1'b0) ? c[16] :overflow3;
endmodule