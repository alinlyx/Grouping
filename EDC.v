module EDC (
    input [7:0] x1,
    input [7:0] y1,
    input [7:0] z1,
    input [7:0] CP_x,
    input [7:0] CP_y,
    input [7:0] CP_z,
    output [17:0] distsquare
);

wire [7:0] U0_adder_sum;
wire U0_adder_overflow;
wire [7:0] U1_adder_sum;
wire U1_adder_overflow;
wire [7:0] U2_adder_sum;
wire U2_adder_overflow;

adder_8 U0_adder_8(
    .operand1(x1),
    .operand2(CP_x),
    .add_or_sub(1'b1),
    .sum(U0_adder_sum),
    .overflow(U0_adder_overflow)
);

adder_8 U1_adder_8(
    .operand1(y1),
    .operand2(CP_y),
    .add_or_sub(1'b1),
    .sum(U1_adder_sum),
    .overflow(U1_adder_overflow)
);

adder_8 U2_adder_8(
    .operand1(z1),
    .operand2(CP_z),
    .add_or_sub(1'b1),
    .sum(U2_adder_sum),
    .overflow(U2_adder_overflow)
);

wire [7:0] multi_x;
wire [7:0] multi_y;
wire [7:0] multi_z;

wire [8:0] exchange1;
assign exchange1 = ~{U0_adder_overflow,U0_adder_sum[7:0]} + 9'b1;
assign multi_x [7:0] = (U0_adder_overflow == 1'b0) ? (U0_adder_sum[7:0]) : exchange1[7:0] ;

wire [8:0] exchange2;
assign exchange2 = ~{U1_adder_overflow,U1_adder_sum[7:0]} + 9'b1;
assign multi_y [7:0] = (U1_adder_overflow == 1'b0) ? (U1_adder_sum[7:0]) : exchange2[7:0] ;

wire [8:0] exchange3;
assign exchange3 = ~{U2_adder_overflow,U2_adder_sum[7:0]} + 9'b1;
assign multi_z [7:0] = (U2_adder_overflow == 1'b0) ? (U2_adder_sum[7:0]) : exchange3[7:0] ;

wire [15:0] out_multi_x;
wire [15:0] out_multi_y;
wire [15:0] out_multi_z;

multi U0_multi(
    .din(multi_x),
    .dout(out_multi_x)
);

multi U1_multi(
    .din(multi_y),
    .dout(out_multi_y)
);

multi U2_multi(
    .din(multi_z),
    .dout(out_multi_z)
);

wire [15:0] U0_adde16_sum;
wire U0_adder16_overflow;
adder_16 U0_adder_16(
    .operand1(out_multi_x),
    .operand2(out_multi_y),
    .add_or_sub(1'b0),
    .sum(U0_adde16_sum),
    .overflow(U0_adder16_overflow)
);

wire [16:0] U0_adde17_sum;
wire U0_adder17_overflow;
adder_17 U0_adder_17(
    .operand1({U0_adder16_overflow,U0_adde16_sum}),
    .operand2({1'b0,out_multi_z}),
    .add_or_sub(1'b0),
    .sum(U0_adde17_sum),
    .overflow(U0_adder17_overflow)
);

assign distsquare = {U0_adder17_overflow , U0_adde17_sum};

endmodule