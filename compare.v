
module comp#(
    parameter	DN = 8,	//数据个数
	parameter	DW = 8,	//数据位宽
    parameter DN_WIDTH= $clog2(DN)
)(
    input clk,
    input rst_n,
    input [DN_WIDTH-1:0] temp_i, //计数器
    input [DN_WIDTH-1:0] temp_j, //计数器
    input [DW*DN-1:0] data_unsort, //未排序数�?
    input [2:0] FSM_state_sort, //状�?�机
    input cnt_sig,
	//input cnt_sig_1pi,

    output reg temp
);

//integer m;
localparam	Sort	= 3'b010; //排序、计算和�?

always @(posedge clk or negedge rst_n)
	begin
		if (rst_n == 1'b0)
			temp <= 0;
		else if ((cnt_sig == 1'b1 /*|| cnt_sig_1pi == 1'b1*/) && FSM_state_sort == Sort)
			begin
						if  (temp_i > temp_j)
							begin
								if (data_unsort[temp_i*DW+:DW] >= data_unsort[temp_j*DW+:DW])
									temp <= 1;
								else
									temp <= 0;
							end
						else
							begin
								if (data_unsort[temp_i*DW+:DW] > data_unsort[temp_j*DW+:DW])
									temp <= 1;
								else
									temp <= 0;
							end
			end
	end

endmodule