//实现2个9bit输入相加得到10bit数据的加法器
module adder9(
    input [8:0] data_unsort, //未排序数�?
    input [8:0] data_unsort_1, //未排序数�?
    input [2:0] FSM_state_sort, //状�?�机

    output wire [9:0] sum10
);

//wire [2:0] sum4_1;
localparam	Sort	= 3'b010; //排序、计算和�?

assign sum10 =(FSM_state_sort == Sort) ? (data_unsort + data_unsort_1) : 0;
 

endmodule

