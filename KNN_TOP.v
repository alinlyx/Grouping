module KNN_TOP
#(	
	parameter DN = 1024,	//数据个数
	parameter addr_W = 24,	//坐标总位宽x+y+z
	parameter DW = 18,	//dist数据位宽
    parameter K = 3,//输出最邻近点数
    parameter stage_num = 8 
)
(
	input clk,
	input rst_n,

	input [addr_W-1:0] CP,
    input CP_vld, //类似于整个系统对某个CP点进行操作的启动信号
    output reg CP_ready,

    input [addr_W-1:0] LP,
    input LP_vld,
    output reg LP_ready,

	input [DN-1:0] mask,
	input mask_vld,
	output reg mask_ready,

	output reg [addr_W-1:0] out_0,
	output reg [addr_W-1:0] out_1,
	output reg [addr_W-1:0] out_2,

	output wire output_flag,
	output reg KNN_CP_finish


	//data_unsort,
	//iready,
	//sequence_sorted,
	//sequence_sorted_temp,
	//sort_finish
);

parameter DN_WIDTH= $clog2(DN);
parameter stage_num_WIDTH= $clog2(stage_num);

parameter IDLE = 3'b000;
parameter CP_state = 3'b001;
parameter LP_state = 3'b010;
parameter stage0 = 3'b011;
parameter stageN = 3'b100;

reg [2:0] FSM_state;
reg [addr_W-1:0] CP_reg;
wire [addr_W-1:0] CP_reg_wire;
//wire [23:0] CP_reg_wire;
reg [(DN*addr_W)-1 : 0] LP_reg;
reg [addr_W-1:0] LPSort_reg;
wire [addr_W-1:0] LPSort_reg_wire;
reg [DN_WIDTH-1 : 0] LP_cnt;

wire [DW-1 : 0] dist;
reg dist_vld;
reg [(DW*DN)-1:0] dist_reg;
wire [(DW*DN)-1:0] dist_reg_wire;
reg [DN_WIDTH-1 : 0] LP_cnt_1pi;

reg EDC_end_flag;
reg sort_sig_TOPKNN;

wire sort_sig_TOPKNN_wire;
wire iready;
wire sort_finish;
wire [DN_WIDTH*DN-1:0] sequence_sorted_wire;
reg  [DN_WIDTH*DN-1:0] sequence_sorted;

reg out_flag;
reg convert_flag;
reg [stage_num_WIDTH-1 : 0] stage_level;
reg [DN_WIDTH:0] DN_reg;//记录每一stage的mask宽度
reg [DN_WIDTH-1:0] DN_cnt;
reg mask_valid;
reg sequence_sorted_flag;
reg [DN_WIDTH-1:0] sequence_sorted_cnt;
reg [DN_WIDTH-2:0] masked_seq_cnt;

//reg KNN_CP_finish;



//------------------------------------------------
// 状态机
always @(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		FSM_state <= IDLE;
	else 
		case(FSM_state)
			IDLE:
				begin
					if(CP_vld == 1'b1)
						FSM_state <= CP_state;
					else
						FSM_state <= IDLE;
					end
			CP_state:
				begin
					if(LP_vld == 1'b1)
						FSM_state <= LP_state;
					else
						FSM_state <= CP_state;
				end
			LP_state:
				begin
					if (sort_finish == 1'b1)
						FSM_state <= stage0;
					else
						FSM_state <= LP_state;
				end
			stage0:
				begin
					if (convert_flag == 1'b1)
						FSM_state <= stageN;
					else
						FSM_state <= stage0;
				end
			stageN:
				begin
					if (stage_level == (stage_num-1) && convert_flag == 1'b1)
						FSM_state <= IDLE;
					else
						FSM_state <= stageN;
				end
			default: FSM_state <= IDLE;
		endcase
end
//assign FSM_state_wire = FSM_state;

//CP_reg
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		CP_reg <= 0;
	else if (CP_vld == 1'b1)
		CP_reg <= CP;
	else if (FSM_state == IDLE)
		CP_reg <= 0;
	else 
		CP_reg <= CP_reg;
end

//CP_reg_wire
assign CP_reg_wire = CP_reg;

//CP_ready
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		CP_ready <= 1'b1;
	else if (FSM_state == stageN && stage_level == (stage_num-1) && convert_flag == 1'b1)
		CP_ready <= 1'b1;
	else if (CP_vld == 1'b1)
		CP_ready <= 1'b0;
	else
		CP_ready <= CP_ready;
end

//LP_ready
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		LP_ready <= 1'b1;
	else if (FSM_state == stageN && stage_level == (stage_num-1) && convert_flag == 1'b1)
		LP_ready <= 1'b1;
	else if (LP_cnt == (DN-2))
		LP_ready <= 1'b0;
	else 
		LP_ready <= LP_ready;
end

//LP_reg
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		LP_reg <= 0;
	else if (FSM_state == IDLE)
		LP_reg <= 0;
	else if (LP_vld == 1'b1)
		LP_reg[(addr_W*LP_cnt)+:addr_W] <= LP;
	else
		LP_reg <= LP_reg;
end

//LPSort_reg
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		LPSort_reg <= 0;
	else if (LP_vld == 1'b1)
		LPSort_reg <= LP;
	else
		LPSort_reg <= 0;
end

//LPSort_reg_wire
assign LPSort_reg_wire = LPSort_reg;

//LP_cnt
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		LP_cnt <= 0;
	else if (LP_cnt == (DN-1))
		LP_cnt <= 0;
	else if (LP_vld == 1'b1)
		LP_cnt <= LP_cnt + 1;
	else
		LP_cnt <= LP_cnt;
end

EDC u_EDC(
	.x1(LPSort_reg_wire[(2*addr_W/3)+:(addr_W/3)]),
	.y1(LPSort_reg_wire[(1*addr_W/3)+:(addr_W/3)]),
	.z1(LPSort_reg_wire[(0*addr_W/3)+:(addr_W/3)]),
	.CP_x(CP_reg_wire[(2*addr_W/3)+:(addr_W/3)]),
	.CP_y(CP_reg_wire[(1*addr_W/3)+:(addr_W/3)]),
	.CP_z(CP_reg_wire[(0*addr_W/3)+:(addr_W/3)]),
	.distsquare(dist)
);

//dist_vld
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		dist_vld <= 0;
	else if (LP_vld == 1'b1)
		dist_vld <= 1'b1;
	else
		dist_vld <= 0;
end

//dist_reg
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		dist_reg <= 0;
	else if (dist_vld == 1'b1)
		dist_reg[(LP_cnt_1pi * DW)+:DW] <= dist;
	else if (sort_finish == 1'b1)
		dist_reg <= 0;
	else
		dist_reg <= dist_reg;
end

//dist_reg_wire
assign dist_reg_wire = dist_reg;

//LP_cnt_1pi
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		LP_cnt_1pi <= 0;
	else if (LP_cnt_1pi == (DN-1))
		LP_cnt_1pi <= 0;
	else if (dist_vld == 1'b1)
		LP_cnt_1pi <= LP_cnt_1pi + 1;
	else
		LP_cnt_1pi <= 0;
end

//EDC_end_flag
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		EDC_end_flag <= 1'b0;
	else if (dist_vld == 1'b1 && LP_cnt_1pi == (DN-1))
		EDC_end_flag <= 1'b1;
	else
		EDC_end_flag <= 1'b0;
end

//sort_sig_TOPKNN
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		sort_sig_TOPKNN <= 1'b0;
	else if (EDC_end_flag == 1'b1)
		sort_sig_TOPKNN <= 1'b1;
	else
		sort_sig_TOPKNN <= 1'b0;
end

//sort_sig_TOPKNN_wire
assign sort_sig_TOPKNN_wire = sort_sig_TOPKNN;

parallel_sort #(
	.DN(DN),
	.DW(DW)
)u_parallel_sort(
	.clk(clk),
	.rst_n(rst_n),
	.sort_sig(sort_sig_TOPKNN_wire),

	.data_unsort(dist_reg_wire),
	.iready(iready),
	.sequence_sorted(sequence_sorted_wire),

	.sort_finish(sort_finish)
);

//sequence_sorted
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		sequence_sorted <= 0;
	else if (FSM_state == stageN && stage_level == (stage_num-1) && convert_flag == 1'b1)
		sequence_sorted <= 0;
	else if (sort_finish == 1'b1 && FSM_state == LP_state)
		sequence_sorted <= sequence_sorted_wire;
	else if (FSM_state == stageN && mask_valid == 1'b1 && sequence_sorted_flag == 1'b1)
		sequence_sorted[(masked_seq_cnt*DN_WIDTH)+:DN_WIDTH] <= sequence_sorted[(sequence_sorted_cnt*DN_WIDTH)+:DN_WIDTH];
	else
		sequence_sorted <= sequence_sorted;
end

//out_0
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		out_0 <= 0;
	else if (out_flag == 1'b1)
		out_0 <= LP_reg[((sequence_sorted[(0*DN_WIDTH)+:DN_WIDTH])*addr_W)+:addr_W];
	else
		out_0 <= 0;
end

//out_1
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		out_1 <= 0;
	else if (out_flag == 1'b1)
		out_1 <= LP_reg[((sequence_sorted[(1*DN_WIDTH)+:DN_WIDTH])*addr_W)+:addr_W];
	else
		out_1 <= 0;
end

//out_2
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		out_2 <= 0;
	else if (out_flag == 1'b1 && stage_num == 10)
		out_2 <= 0;
	else if (out_flag == 1'b1)
		out_2 <= LP_reg[((sequence_sorted[(2*DN_WIDTH)+:DN_WIDTH])*addr_W)+:addr_W];
	else
		out_2 <= 0;
end

//out_flag
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		out_flag <= 1'b0;
	else if ((FSM_state == LP_state && sort_finish == 1'b1) || (FSM_state == stageN && sequence_sorted_cnt == (DN_reg-1)))
		out_flag <= 1'b1;
	else
		out_flag <= 1'b0;
end

//convert_flag
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		convert_flag <= 1'b0;
	else if (out_flag == 1'b1)
		convert_flag <= 1'b1;
	else
		convert_flag <= 'b0;
end

//output_flag
assign output_flag = convert_flag;

//stage_level
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		stage_level <= 0;
	else if (stage_level == (stage_num-1) && convert_flag == 1'b1)
		stage_level <= 0;
	else if (convert_flag == 1'b1)
		stage_level <= stage_level + 1;
	else
		stage_level <= stage_level;
end

//mask_ready
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		mask_ready <= 1'b0;
	else if ((FSM_state == stage0 || FSM_state == stageN) && out_flag == 1'b1)
		mask_ready <= 1'b1;
	else if (DN_cnt == (DN_reg-2))
		mask_ready <= 1'b0;
	else
		mask_ready <= mask_ready;
end

//DN_reg
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		DN_reg <= DN;
	else if (stage_level == (stage_num-1) && out_flag == 1'b1)
		DN_reg <= DN;
	else if (FSM_state == stageN && out_flag == 1'b1)
		DN_reg <= (DN_reg >> 1);
	else
		DN_reg <= DN_reg;
end

//DN_cnt
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		DN_cnt <= 0;
	else if (DN_cnt == (DN_reg-1))
		DN_cnt <= 0;
	else if (FSM_state == stageN && mask_vld == 1'b1 /*&& mask_ready == 1'b1*/)
		DN_cnt <= DN_cnt + 1;
	else
		DN_cnt <= DN_cnt;
end

//mask_valid
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		mask_valid <= 1'b0;
	else if (FSM_state ==stageN && mask_vld == 1'b1)
		mask_valid <= mask[DN_cnt];
	else
		mask_valid <= 1'b0;
end

//sequence_sorted_flag
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		sequence_sorted_flag <= 1'b0;
	else if (FSM_state == stageN && mask_vld == 1'b1)
		sequence_sorted_flag <= 1'b1;
	else
		sequence_sorted_flag <= 1'b0;
end

//sequence_sorted_cnt
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		sequence_sorted_cnt <= 0;
	else if (sequence_sorted_cnt == (DN_reg-1))
		sequence_sorted_cnt <= 0;
 	else if (FSM_state == stageN && sequence_sorted_flag == 1'b1)
		sequence_sorted_cnt <= sequence_sorted_cnt + 1;
	else
		sequence_sorted_cnt <= sequence_sorted_cnt;
end

//masked_seq_cnt
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		masked_seq_cnt <= 0;
	else if (masked_seq_cnt == ((DN_reg/2)-1))
		masked_seq_cnt <= 0;
	else if (sequence_sorted_flag == 1'b1 && mask_valid == 1'b1)
		masked_seq_cnt <= masked_seq_cnt + 1;
	else
		masked_seq_cnt <= masked_seq_cnt;
end

//KNN_CP_finish
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		KNN_CP_finish <= 1'b0;
	else if (FSM_state == stageN && stage_level == (stage_num-1) && convert_flag == 1'b1)
		KNN_CP_finish <= 1'b1;
	else
		KNN_CP_finish <= 1'b0;
end

endmodule


