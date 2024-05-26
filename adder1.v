//实现4个1bit输入相加得到3bit数据的加法器
module adder1(
    input [3:0] data_unsort, //未排序数�?
    input [2:0] FSM_state_sort, //状�?�机

    output wire [2:0] sum3
);

localparam	Sort	= 3'b010; //排序、计算和�?

assign sum3 =(FSM_state_sort == Sort) ? (data_unsort[3] + data_unsort[2] + data_unsort[1] + data_unsort[0]) : 0;

endmodule

