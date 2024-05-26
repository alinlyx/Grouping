//实现2个10bit输入相加得到11bit数据的加法器
module adder10(
    input [9:0] data_unsort, //未排序数�?
    input [9:0] data_unsort_1, //未排序数�?
    input [2:0] FSM_state_sort, //状�?�机

    output wire [10:0] sum11
);

//wire [2:0] sum4_1;
localparam	Sort	= 3'b010; //排序、计算和�?

assign sum11 =(FSM_state_sort == Sort) ? (data_unsort + data_unsort_1) : 0;
 

endmodule

