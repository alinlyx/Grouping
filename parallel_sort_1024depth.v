module parallel_sort
#(	
	parameter	DN = 1024,	//閺佺増宓佹稉顏呮殶
	parameter	DW = 18	//閺佺増宓佹担宥咁啍
)
(
	clk,
	rst_n,
	sort_sig,
	
	data_unsort,
	iready,
	sequence_sorted,
	//sequence_sorted_temp,
	sort_finish
);
//------------------------------------------------
//parameter
//parameter	DW_sequence = $clog2(DN); //鐠侊紕鐣诲В蹇庨嚋閺佺増宓乮dx閻ㄥ嫪缍呴敓锟�?
parameter DN_WIDTH= $clog2(DN);
//parameter DW_WIDTH= $clog2(DW);

//------------------------------------------------
// Input Port
input					clk; //閺冨爼鎸撴穱鈥冲娇
input					rst_n; //婢跺秳缍呮穱鈥冲娇
input					sort_sig; //閹烘帒绨敓锟�?婵淇婇敓锟�?
input	[DW*DN-1:0]		data_unsort; //閺堫亝甯撴惔蹇旀殶閿燂拷?

//------------------------------------------------
// Output Port
output reg iready;
//wire	[DN_WIDTH*DN-1:0]	sequence_sorted_wire;//濞夈劍鍓伴弰顖欓嚋reg
output	reg	[DN_WIDTH*DN-1:0]	sequence_sorted; //閺嶈宓佹潏鎾冲弳閺佺増宓侀幒鎺戠碍閸氬骸顕惔鏃傛畱鎼村繐褰�
output	reg							sort_finish; //閹烘帒绨紒鎾存将娣団€冲娇

//reg		[DN_WIDTH*DN-1:0]	sequence_sorted_temp; //閸氬嫪閲滄惔蹇撳娇鐎电懓绨查惃鍕笓鎼村骏鎷�??
//wire	[DN_WIDTH*DN-1:0]	sequence_sorted_temp_wire;
reg 	[DN_WIDTH-1 : 0]	sequence_sorted_stored;
wire 	[DN_WIDTH-1 : 0]	sequence_sorted_stored_wire;
//------------------------------------------------
// Internal Variables
integer i,j,m;

reg [DN_WIDTH-1:0] temp_i; //鐠佲剝鏆熼崳锟�
wire [DN_WIDTH-1:0] temp_i_wire; //鐠佲剝鏆熼崳锟�
//reg [DN_WIDTH-1:0] temp_i_1pi;
//reg [DN_WIDTH-1:0] temp_i_2pi;
//reg [DN_WIDTH-1:0] temp_i_3pi;
reg [DN_WIDTH-1:0] temp_i_DNpi;
reg [DN_WIDTH-1:0] temp_i_DN1pi;
wire [DN_WIDTH-1:0] temp_i_DN1pi_wire;

//reg		[DN-1:0]	temp1	[(DN/4)-1:0]; //閹烘帒绨潻鍥┾柤閸欐﹢鍣�
//reg		[DN-1:0]	temp2	[(DN/4)-1:0]; //閹烘帒绨潻鍥┾柤閸欐﹢鍣�
//reg		[DN-1:0]	temp3	[(DN/4)-1:0]; //閹烘帒绨潻鍥┾柤閸欐﹢鍣�

reg cnt_sig; //temp_i鐠佲剝鏆熼弽鍥х箶
//reg cnt_sig_1pi;

//reg [DN-1 : 0] temp;//閹烘帒绨潻鍥┾柤閸欐﹢鍣�
wire [DN-1 : 0] temp;//閹烘帒绨潻鍥┾柤閸欐﹢鍣�
reg [DN-1 : 0] temp_1pi;//閹烘帒绨潻鍥┾柤閸欐﹢鍣�
reg [DN-1 : 0] temp_2pi;//閹烘帒绨潻鍥┾柤閸欐﹢鍣�
wire [DN-1 : 0] temp_2pi_wire;//閹烘帒绨潻鍥┾柤閸欐﹢鍣�
//wire [DN-1 : 0] temp_1pi_wire;//閹烘帒绨潻鍥┾柤閸欐﹢鍣�
//reg [DN_WIDTH*DN-1:0] temp_cnt;

reg sum_sig;//閹跺﹤濮炲▔鏇炴珤閻ㄥ嫮绮ㄩ弸婊冪摠閸屻劌鍩岀€靛嫬鐡ㄩ崳銊よ厬
reg sum_sig_1pi;

reg		[2:0]		FSM_state_sort; //閻樿鎷�?閿熻姤婧€
wire		[2:0]		FSM_state_sort_wire; //閻樿鎷�?閿熻姤婧€
//reg		[DN_WIDTH*DN-1:0]	sequence_sorted_temp_wire; //閸氬嫪閲滄惔蹇撳娇鐎电懓绨查惃鍕笓鎼村骏鎷�??
//output reg		[DN_WIDTH*DN-1:0]	sequence_sorted_temp; //閸氬嫪閲滄惔蹇撳娇鐎电懓绨查惃鍕笓鎼村骏鎷�??

reg sum_flag;
//wire sum_flag_wire;
reg sum_flag1;
//reg sum_flag2;
//reg sum_flag3;

localparam	Initial = 3'b001; //閸掓繂顫愰敓锟�?
localparam	Sort	= 3'b010; //閹烘帒绨妴浣筋吀缁犳鎷伴敓锟�?
localparam	Convert	= 3'b100; //閸欏秷娴�

//------------------------------------------------
// 閹烘帒绨悩璁规嫹?閿熻姤婧€
always @(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		FSM_state_sort <= Initial;
	else 
		case(FSM_state_sort)
			Initial:
				begin
					if(sort_sig)
						FSM_state_sort <= Sort;
					else
						FSM_state_sort <= Initial;
					end
			Sort:
				begin
					if(sum_flag == 1'b1)
						FSM_state_sort <= Convert;
					else
						FSM_state_sort <= Sort;
				end
			Convert:
				begin
					if (sort_finish == 1'b1)
						FSM_state_sort <= Initial;
					else
						FSM_state_sort <= Convert;
				end
			
			default: FSM_state_sort <= Initial;
		endcase
end
assign FSM_state_sort_wire = FSM_state_sort;

//iready
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		iready <= 1'b1;
	else if (sort_sig == 1'b1)
		iready <= 1'b0;
	else if (sort_finish == 1'b1)
		iready <= 1'b1;
	else
		iready <= iready;
end



genvar temp_j;
generate
    for(temp_j=0 ; temp_j<DN ; temp_j=temp_j+1) 
		begin: compartor
			comp#(
				.DN(DN),
				.DW(DW),
				.DN_WIDTH(DN_WIDTH)
			)u_comp(
				.clk(clk),
				.rst_n(rst_n),
				.temp_i(temp_i_wire),
				.temp_j(temp_j),
				.data_unsort(data_unsort),
				.FSM_state_sort(FSM_state_sort_wire),
				.cnt_sig(cnt_sig),
				//.cnt_sig_1pi(cnt_sig_1pi),
				.temp(temp[temp_j])
			);

		end
endgenerate
/*
genvar temp_j_1pi;
generate
	for (temp_j_1pi=0 ; temp_j_1pi<DN ;temp_j_1pi=temp_j_1pi+1)
		begin:dapai
			always @(posedge clk or negedge rst_n)
				begin
					if (rst_n == 1'b0)
						temp_1pi[temp_j_1pi] <= 0;
					else if ((temp_i >= 1)  || (sum_flag == 1'b1))
						begin
							temp_1pi[temp_j_1pi] <= temp_i[temp_j_1pi];
						end
					else
						temp_1pi[temp_j_1pi] <= 0;
				end
		end
endgenerate
*/

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		temp_1pi <= 0;
	else if ((temp_i >= 1)  || /*(sum_flag == 1'b1)*/ temp_i_DN1pi == 1011)
		begin
			/*
			for (j=0 ; j<DN ;j=j+1)
				begin
					temp_1pi[j] <= temp[j];
				end
			*/
			temp_1pi <= temp;
		end
	else
		temp_1pi <= 0;
end

//assign temp_1pi_wire = temp_1pi;

//temp_2pi
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		temp_2pi <= 0;
	else if (FSM_state_sort == Sort)
		begin
			temp_2pi[DN-1 : 0] <= temp_1pi[DN-1 : 0];
		end
	else
		temp_2pi <= 0;
end

assign temp_2pi_wire = temp_2pi;

//cnt_sig
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		cnt_sig <= 1'b0;
	else if (sort_sig == 1'b1 && iready == 1'b1)
		cnt_sig <= 1'b1;
	else if (temp_i == (DN-1))
		cnt_sig <= 1'b0;
	else 
		cnt_sig <= cnt_sig;
end

//cnt_sig_1pi
/*
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		cnt_sig_1pi <= 1'b0;
	else if (cnt_sig == 1'b1 && temp_i == 7)
		cnt_sig_1pi <= 1'b1;
	else 
		cnt_sig_1pi <= 0;
end
*/

//temp_i
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		temp_i <= 0;
	else if (temp_i == (DN-1))
		temp_i <= 0;
	else if (cnt_sig == 1'b1)
		temp_i <= temp_i + 1;
	else
		temp_i <= 0;
end
assign temp_i_wire = temp_i;

//temp_i_2pi,temp_i閹碉拷2閹凤拷
/*
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		temp_i_2pi <= 0;
	else if (temp_i_2pi == (DN-1))
		temp_i_2pi <= 0;
	else if (FSM_state_sort == Sort && (temp_i >= 2 || sum_flag == 1'b1))
		temp_i_2pi <= temp_i_2pi + 1;
	else	
		temp_i_2pi <= 0;
end
*/

//temp_i_3pi,temp_i閹碉拷3閹凤拷
/*
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		temp_i_3pi <= 0;
	else if (temp_i_3pi == (DN-1))
		temp_i_3pi <= 0;
	else if (FSM_state_sort == Sort && (temp_i >= 3 || sum_flag == 1'b1 || sum_flag1 == 1'b1))
		temp_i_3pi <= temp_i_3pi + 1;
	else	
		temp_i_3pi <= 0;
end
*/

//temp_i_DNpi
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		temp_i_DNpi <= 0;
	else if (temp_i_DNpi == (DN-1))
		temp_i_DNpi <= 0;
	else if (FSM_state_sort == Sort && sum_sig == 1'b1)
		temp_i_DNpi <= temp_i_DNpi + 1;
	else	
		temp_i_DNpi <= 0;
end

//temp_i_DN1pi
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		temp_i_DN1pi <= 0;
	else if (temp_i_DN1pi == (DN-1))
		temp_i_DN1pi <= 0;
	else if (FSM_state_sort == Sort && sum_sig_1pi == 1'b1)
		temp_i_DN1pi <= temp_i_DN1pi + 1;
	else	
		temp_i_DN1pi <= 0;
end

assign temp_i_DN1pi_wire = temp_i_DN1pi;

//sum_sig
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		sum_sig <= 1'b0;
	else if (temp_i == (3 + DN_WIDTH - 2) && FSM_state_sort == Sort)
		sum_sig <= 1'b1;
	else if (temp_i_DNpi == (DN -1))
		sum_sig <= 1'b0;
	else
		sum_sig <= sum_sig;
end

//sum_sig_1pi
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		sum_sig_1pi <= 1'b0;
	else if (FSM_state_sort == Sort)
		sum_sig_1pi <= sum_sig;
	else
		sum_sig_1pi <= 1'b0;
end

//------------------------------------------------
// 鐠侊紕鐣婚崪灞炬殶
reg [3*(DN/4)-1 : 0] adder1_sum;
wire [3*(DN/4)-1 : 0] adder1_sum_wire;
//level0
genvar temp_j_1;
generate
    for(temp_j_1=0 ; temp_j_1<256 ; temp_j_1=temp_j_1+1) 
		begin: adder1
			adder1 u_adder1(
				.data_unsort(temp_2pi_wire[temp_j_1*4+:4]),
				.FSM_state_sort(FSM_state_sort_wire),
				.sum3(adder1_sum_wire[temp_j_1*3+:3])
			);
		end
endgenerate

//adder1_sum
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		adder1_sum <= 0;
	else if (FSM_state_sort == Sort)
		adder1_sum <= adder1_sum_wire;
	else
		adder1_sum <= 0;
end

wire [3*(DN/4)-1 : 0] adder1_sum_wire_1;
assign adder1_sum_wire_1 = adder1_sum;
wire [4*(DN/8)-1 : 0] adder3_sum_wire;
reg [4*(DN/8)-1 : 0] adder3_sum;
//level1
genvar temp_j_2;
generate
    for(temp_j_2=0 ; temp_j_2<128 ; temp_j_2=temp_j_2+1) 
		begin: adder3
			adder3 u_adder3(
				.data_unsort(adder1_sum_wire_1[(temp_j_2*2)*3+:3]),
				.data_unsort_1(adder1_sum_wire_1[((temp_j_2*2) + 1)*3+:3]),
				.FSM_state_sort(FSM_state_sort_wire),
				.sum3(adder3_sum_wire[temp_j_2*4+:4])
			);
		end
endgenerate

//adder3_sum
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		adder3_sum <= 0;
	else if (FSM_state_sort == Sort)
		adder3_sum <= adder3_sum_wire;
	else
		adder3_sum <= 0;
end

wire [4*(DN/8)-1 : 0] adder3_sum_wire_1;
assign adder3_sum_wire_1 = adder3_sum;

wire [5*(DN/16)-1 : 0] adder4_sum_wire;
reg [5*(DN/16)-1 : 0] adder4_sum;
//level2
genvar temp_j_3;
generate
    for(temp_j_3=0 ; temp_j_3<64 ; temp_j_3=temp_j_3+1) 
		begin: adder4
			adder4 u_adder4(
				.data_unsort(adder3_sum_wire_1[(temp_j_3*2)*4+:4]),
				.data_unsort_1(adder3_sum_wire_1[((temp_j_3*2) + 1)*4+:4]),
				.FSM_state_sort(FSM_state_sort_wire),
				.sum5(adder4_sum_wire[temp_j_3*5+:5])
			);
		end
endgenerate

//adder4_sum
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		adder4_sum <= 0;
	else if (FSM_state_sort == Sort)
		adder4_sum <= adder4_sum_wire;
	else
		adder4_sum <= 0;
end

wire [5*(DN/16)-1 : 0] adder4_sum_wire_1;
assign adder4_sum_wire_1 = adder4_sum;

wire [6*(DN/32)-1 : 0] adder5_sum_wire;
reg [6*(DN/32)-1 : 0] adder5_sum;
//level3
genvar temp_j_4;
generate
    for(temp_j_4=0 ; temp_j_4<32 ; temp_j_4=temp_j_4+1) 
		begin: adder5
			adder5 u_adder5(
				.data_unsort(adder4_sum_wire_1[(temp_j_4*2)*5+:5]),
				.data_unsort_1(adder4_sum_wire_1[((temp_j_4*2) + 1)*5+:5]),
				.FSM_state_sort(FSM_state_sort_wire),
				.sum6(adder5_sum_wire[temp_j_4*6+:6])
			);
		end
endgenerate

//adder5_sum
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		adder5_sum <= 0;
	else if (FSM_state_sort == Sort)
		adder5_sum <= adder5_sum_wire;
	else
		adder5_sum <= 0;
end

wire [6*(DN/32)-1 : 0] adder5_sum_wire_1;
assign adder5_sum_wire_1 = adder5_sum;

wire [7*(DN/64)-1 : 0] adder6_sum_wire;
reg [7*(DN/64)-1 : 0] adder6_sum;
//level4
genvar temp_j_5;
generate
    for(temp_j_5=0 ; temp_j_5<16 ; temp_j_5=temp_j_5+1) 
		begin: adder6
			adder6 u_adder6(
				.data_unsort(adder5_sum_wire_1[(temp_j_5*2)*6+:6]),
				.data_unsort_1(adder5_sum_wire_1[((temp_j_5*2) + 1)*6+:6]),
				.FSM_state_sort(FSM_state_sort_wire),
				.sum7(adder6_sum_wire[temp_j_5*7+:7])
			);
		end
endgenerate

//adder6_sum
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		adder6_sum <= 0;
	else if (FSM_state_sort == Sort)
		adder6_sum <= adder6_sum_wire;
	else
		adder6_sum <= 0;
end

wire [7*(DN/64)-1 : 0] adder6_sum_wire_1;
assign adder6_sum_wire_1 = adder6_sum;

wire [8*(DN/128)-1 : 0] adder7_sum_wire;
reg [8*(DN/128)-1 : 0] adder7_sum;
//level5
genvar temp_j_6;
generate
    for(temp_j_6=0 ; temp_j_6<8 ; temp_j_6=temp_j_6+1) 
		begin: adder7
			adder7 u_adder7(
				.data_unsort(adder6_sum_wire_1[(temp_j_6*2)*7+:7]),
				.data_unsort_1(adder6_sum_wire_1[((temp_j_6*2) + 1)*7+:7]),
				.FSM_state_sort(FSM_state_sort_wire),
				.sum8(adder7_sum_wire[temp_j_6*8+:8])
			);
		end
endgenerate

//adder7_sum
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		adder7_sum <= 0;
	else if (FSM_state_sort == Sort)
		adder7_sum <= adder7_sum_wire;
	else
		adder7_sum <= 0;
end

wire [8*(DN/128)-1 : 0] adder7_sum_wire_1;
assign adder7_sum_wire_1 = adder7_sum;

wire [9*(DN/256)-1 : 0] adder8_sum_wire;
reg [9*(DN/256)-1 : 0] adder8_sum;
//level6
genvar temp_j_7;
generate
    for(temp_j_7=0 ; temp_j_7<4 ; temp_j_7=temp_j_7+1) 
		begin: adder8
			adder8 u_adder8(
				.data_unsort(adder7_sum_wire_1[(temp_j_7*2)*8+:8]),
				.data_unsort_1(adder7_sum_wire_1[((temp_j_7*2) + 1)*8+:8]),
				.FSM_state_sort(FSM_state_sort_wire),
				.sum9(adder8_sum_wire[temp_j_7*9+:9])
			);
		end
endgenerate

//adder8_sum
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		adder8_sum <= 0;
	else if (FSM_state_sort == Sort)
		adder8_sum <= adder8_sum_wire;
	else
		adder8_sum <= 0;
end

wire [9*(DN/256)-1 : 0] adder8_sum_wire_1;
assign adder8_sum_wire_1 = adder8_sum;

wire [10*(DN/512)-1 : 0] adder9_sum_wire;
reg [10*(DN/512)-1 : 0] adder9_sum;
//level7
genvar temp_j_8;
generate
    for(temp_j_8=0 ; temp_j_8<2 ; temp_j_8=temp_j_8+1) 
		begin: adder9
			adder9 u_adder9(
				.data_unsort(adder8_sum_wire_1[(temp_j_8*2)*9+:9]),
				.data_unsort_1(adder8_sum_wire_1[((temp_j_8*2) + 1)*9+:9]),
				.FSM_state_sort(FSM_state_sort_wire),
				.sum10(adder9_sum_wire[temp_j_8*10+:10])
			);
		end
endgenerate

//adder9_sum
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		adder9_sum <= 0;
	else if (FSM_state_sort == Sort)
		adder9_sum <= adder9_sum_wire;
	else
		adder9_sum <= 0;
end

wire [10*(DN/512)-1 : 0] adder9_sum_wire_1;
assign adder9_sum_wire_1 = adder9_sum;

wire [11*(DN/1024)-1 : 0] adder10_sum_wire;
reg [9 : 0] adder10_sum;
//level8
genvar temp_j_9;
generate
    for(temp_j_9=0 ; temp_j_9<1 ; temp_j_9=temp_j_9+1) 
		begin: adder10
			adder10 u_adder10(
				.data_unsort(adder9_sum_wire_1[(temp_j_9*2)*10+:10]),
				.data_unsort_1(adder9_sum_wire_1[((temp_j_9*2) + 1)*10+:10]),
				.FSM_state_sort(FSM_state_sort_wire),
				.sum11(adder10_sum_wire[temp_j_9*11+:11])
			);
		end
endgenerate

//adder10_sum
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		adder10_sum <= 0;
	else if (FSM_state_sort == Sort)
		adder10_sum <= adder10_sum_wire[9:0];
	else
		adder10_sum <= 0;
end


//sequence_sorted_temp閿涘矁顩﹂弨锟�
/*
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		sequence_sorted_temp <= 0;
	else if (FSM_state_sort == Initial)
		sequence_sorted_temp <= 0;
	else if (FSM_state_sort == Sort && sum_sig == 1'b1)
		sequence_sorted_temp[temp_i_DNpi*DN_WIDTH+:DN_WIDTH] <= adder10_sum[9:0];
	else
		sequence_sorted_temp <= 0;
end
*/
//assign sequence_sorted_temp_wire = sequence_sorted_temp;

//sequence_sorted_stored
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		sequence_sorted_stored <= 0;
	else if (FSM_state_sort == Initial)
		sequence_sorted_stored <= 0;
	else if (FSM_state_sort == Sort && sum_sig == 1'b1)
		sequence_sorted_stored <= adder10_sum[9:0];
	else
		sequence_sorted_stored <= 0;
end

assign sequence_sorted_stored_wire = sequence_sorted_stored;

//sum_flag
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		sum_flag <= 1'b0;
	else if (FSM_state_sort == Sort && temp_i_DNpi == (DN - 1))
		sum_flag <= 1'b1;
	else
		sum_flag <= 1'b0;
end

//assign sum_flag_wire = sum_flag;

//sum_flag1
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		sum_flag1 <= 1'b0;
	else if (FSM_state_sort == Sort && sum_flag == 1'b1)
		sum_flag1 <= 1'b1;
	else
		sum_flag1 <= 1'b0;
end

//sum_flag1
/*
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		sum_flag1 <= 1'b0;
	else if (FSM_state_sort == Sort)
		sum_flag1 <= sum_flag;
	else
		sum_flag1 <= 1'b0;
end

//sum_flag2
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		sum_flag2 <= 1'b0;
	else if (FSM_state_sort == Sort)
		sum_flag2 <=sum_flag1;
	else
		sum_flag2 <= 1'b0;
end

//sum_flag3
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		sum_flag3 <= 1'b0;
	else if (FSM_state_sort == Sort)
		sum_flag3 <=sum_flag2;
	else
		sum_flag3 <= 1'b0;
end
*/

//------------------------------------------------
// 閹烘帒绨紒鎾存将娣団€冲娇,sort_finish
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		sort_finish <= 1'b0;
	else if ( /*FSM_state_sort == Sort &&*/ sum_flag1 == 1'b1)
		sort_finish <= 1'b1;
	else
		sort_finish <= 1'b0;
end

//------------------------------------------------
// 楠炴儼顢戝В鏃囩窛
/*
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n) 
		begin	//婢跺秳缍呮穱鈥冲娇
			for(i=0 ; i<DN ; i=i+1) 
				begin 
					temp[i] = 0;
				end
		end
	else if(sort_sig) 
		begin	//閹烘帒绨敓锟�?婵淇婇敓锟�?
			for(i=0 ; i<DN ; i=i+1) 
				begin
					for(j=0 ; j<DN ; j=j+1) 
						begin
							if(i>j) 
								begin
									if(data_unsort[i*DW+:DW] >= data_unsort[j*DW+:DW]) 
										temp[i][j] <= 1;
									else	
										temp[i][j] <= 0;
								end
							else 
								begin
									if(data_unsort[i*DW+:DW] > data_unsort[j*DW+:DW])
										temp[i][j] <= 1;
									else
										temp[i][j] <= 0;
								end
						end
				end
		end
end
*/


//------------------------------------------------
/*
always @(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		sequence_sorted <= 0;
	else if(FSM_state_sort == Sort && sum_flag1 == 1'b1)
		begin
			for(i=0 ; i<DN ; i=i+1) 
				begin
					sequence_sorted[sequence_sorted_temp[i*DN_WIDTH+:DN_WIDTH]*DN_WIDTH+:DN_WIDTH] <= i; 
				end
		end 
	else
		sequence_sorted <= sequence_sorted;
end
*/

// 鐠侊紕鐣婚幒鎺戠碍閸氬海娈戦崢鐔奉潗鎼村繐褰�
/*wire [DN_WIDTH*DN-1 : 0] score;
//wire [DN_WIDTH-1 : 0] score_wire;
genvar temp_m;
generate
    for(temp_m=0 ; temp_m<DN ; temp_m=temp_m+1) 
		begin: convertor
			convertor#(
				.DN(DN)
				//.DW(DW),
				//.DN_WIDTH(DN_WIDTH)
			)u_convertor(
				.clk(clk),
				.rst_n(rst_n),

				.sum_flag(sum_flag_wire),
				//.sorted_temp(sequence_sorted_temp_wire[temp_m*DN_WIDTH+:DN_WIDTH]),
				.temp_j(temp_m),
				.FSM_state_sort(FSM_state_sort_wire),
				//.cnt_sig(cnt_sig),
				//.cnt_sig_1pi(cnt_sig_1pi),
				//.score(score[temp_m*DN_WIDTH+:DN_WIDTH])
				.score(sequence_sorted_wire[(sequence_sorted_temp_wire[temp_m*DN_WIDTH+:DN_WIDTH])*DN_WIDTH+:DN_WIDTH])			
			);
			//assign score_wire = score[temp_m*DN_WIDTH+:DN_WIDTH];
			//assign sequence_sorted_wire[(score[temp_m*DN_WIDTH+:DN_WIDTH])*DN_WIDTH+:DN_WIDTH] = temp_m;

		end
endgenerate

wire [DN_WIDTH*DN-1:0] sequence_sorted_wire_wire;
assign sequence_sorted_wire_wire = sequence_sorted_wire;
*/

//sequence_sorted_stored_wire
//temp_i_DN1pi_wire
always @(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		sequence_sorted <= 0;
	else if (FSM_state_sort == Initial)
		sequence_sorted <= 0;
	else if( /*FSM_state_sort == Sort &&*/ sum_sig_1pi == 1'b1)
		begin
			sequence_sorted[sequence_sorted_stored_wire*DN_WIDTH+:DN_WIDTH] <= temp_i_DN1pi_wire;
		end 
	else
		sequence_sorted <= sequence_sorted;
end

endmodule


