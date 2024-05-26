`timescale 1ns/1ps
 
module tb_EDC();
 
 
//module EDC (
//    input [7:0] x1,
//    input [7:0] y1,
//    input [7:0] z1,
//    input [7:0] CP_x,
//    input [7:0] CP_y,
//    input [7:0] CP_z,
//    output [17:0] distsquare
//
//);

    reg [7:0] x1;
    reg [7:0] y1;
    reg [7:0] z1;
    reg [7:0] CP_x;
    reg [7:0] CP_y;
    reg [7:0] CP_z;
    wire [17:0] distsquare;
   
    initial
        begin	
            x1 <= 0;
            y1 <= 0;
            z1 <= 0;
            CP_x <= 0;
            CP_y <= 0;
            CP_z <= 0;
            #100
            x1 <= 8'b1111_1111;
            y1 <= 8'b1111_1111;
            z1 <= 8'b1111_1111;
            CP_x <= 0;
            CP_y <= 0;
            CP_z <= 0;
            #100
            x1 <= 0;
            y1 <= 0;
            z1 <= 0;
            CP_x <= 8'b1111_1111;
            CP_y <= 8'b1111_1111;
            CP_z <= 8'b1111_1111;
            #100
            x1 <= 8'b1100_0011; //195
            y1 <= 8'b1011_1111; //191
            z1 <= 8'b0111_1111; //127
            CP_x <= 8'b0000_1011; //11
            CP_y <= 8'b0011_1111; //63
            CP_z <= 8'b1111_1111; //255
            #100
            x1 <= 8'b0011_0011; //51
            y1 <= 8'b0000_1111; //15
            z1 <= 8'b0001_0001; //17
            CP_x <= 8'b1111_1111; //255 
            CP_y <= 8'b1011_1111; //191
            CP_z <= 8'b1101_1111; //223
        end

 
    EDC U0_EDC(
        .x1(x1),
        .y1(y1),
        .z1(z1),
        .CP_x(CP_x),
        .CP_y(CP_y),
        .CP_z(CP_z),
        .distsquare(distsquare)
    ); 
endmodule