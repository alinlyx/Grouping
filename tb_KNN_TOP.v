`timescale 1ns / 1ps

module tb_KNN_TOP();

parameter DN = 1024;	//数据个数
parameter addr_W = 24;	//坐标总位宽x+y+z
parameter DW = 18;	//dist数据位宽
parameter K = 3;//输出最邻近点数
parameter stage_num = 8; 
parameter DN_WIDTH= $clog2(DN);
parameter stage_num_WIDTH= $clog2(stage_num);

reg clk;
reg rst_n;

reg CP_cnt;//控制只进行一次CP操作

reg [addr_W-1:0] CP;
wire [addr_W-1:0] CP_wire;
reg CP_vld; //类似于整个系统对某个CP点进行操作的启动信号
wire CP_vld_wire;
wire CP_ready;

reg [DN_WIDTH-1:0] LP_cnt;
wire [addr_W-1:0] LP;
reg LP_vld;
wire LP_vld_wire;
wire LP_ready;

reg [stage_num_WIDTH-1:0] stage_level;
reg [DN-1:0] mask;
wire [DN-1:0] mask_wire;
reg mask_vld;
wire mask_vld_wire;
wire mask_ready;

wire [addr_W-1:0] out_0;
wire [addr_W-1:0] out_1;
wire [addr_W-1:0] out_2;

wire output_flag;
wire KNN_CP_finish;

reg [addr_W-1:0] LP_reg [0:DN-1];
integer file, r, i;
reg [addr_W-1:0] data;

initial //多个initial会并行进行
begin
    // 打开文件，file是文件描述符
    file = $fopen("D:\\Grouping\\c\\LP_addr.txt", "r");
    
    // 检查文件是否成功打开
    if (file == 0) 
        begin
            $display("Error: 无法打开文件");
            $finish;
        end
    
    // 读取文件并将数据写入LP_reg

    for (i = 0; i < DN; i = i + 1) 
        begin
            r = $fscanf(file, "%b\n", data); // 读取一行24位二进制数
            if (r != 1) begin
                $display("Error: 文件读取错误");
                $finish;
            end
            LP_reg[i] = data; // 将数据写入寄存器
        end
    
    $fclose(file); // 关闭文件
end

initial
begin
    clk = 0;
    rst_n = 0;
    #100
    rst_n = 1;
    //#25600
    //$stop;

end

KNN_TOP#(
    .DN(DN),
    .addr_W(addr_W),
    .DW(DW),
    .K(K),
    .stage_num(stage_num)
)u_KNN_TOP(
    .clk(clk),
    .rst_n(rst_n),
    
    .CP(CP_wire),
    .CP_vld(CP_vld_wire),
    .CP_ready(CP_ready),

    .LP(LP),
    .LP_vld(LP_vld_wire),
    .LP_ready(LP_ready),

    .mask(mask_wire),
    .mask_vld(mask_vld_wire),
    .mask_ready(mask_ready),

    .out_0(out_0),
    .out_1(out_1),
    .out_2(out_2),

    .output_flag(output_flag),
    .KNN_CP_finish(KNN_CP_finish)
);

/*
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
*/



always #5 clk = ~clk;

//CP_cnt
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        CP_cnt <= 0;
    else if (CP_vld == 1'b1)
        CP_cnt <= 1;
    else
        CP_cnt <= CP_cnt;
end

//CP,适用于对CP仅进行一次遍历的情况
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        CP <= 0;
    else if (CP_ready == 1'b1)
        CP <= 24'b101111011100011001111001;
    else
        CP <= 0;
end

//CP_wire
assign CP_wire = CP;

//CP_vld,用于对CP仅进行一次遍历的情况
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        CP_vld <= 1'b0;
    else if (CP_ready == 1'b1 && CP_cnt == 0)
        //CP_vld <= 1'b1;
        CP_vld <= CP_vld + 1;
    else
        CP_vld <= 1'b0;
end

//CP_vld_wire
assign CP_vld_wire = CP_vld;

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

//LP
/*
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        LP <= 0;
    else if ()
end
*/
assign LP = (LP_vld == 1'b1) ? LP_reg[LP_cnt] : 0;

//LP_vld
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        LP_vld <= 1'b0;
    else if (CP_vld == 1'b1)
        LP_vld <= 1'b1;
    else if (LP_ready == 1'b0)
        LP_vld <= 1'b0;
    else
        LP_vld <= LP_vld;
end

//LP_vld_wire
assign LP_vld_wire = LP_vld;

//stage_level
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        stage_level <= 0;
    else if (output_flag == 1'b1 && stage_level == (stage_num-1))
        stage_level <= 0;
    else if (output_flag == 1'b1)
        stage_level <= stage_level + 1;
    else
        stage_level <= stage_level;
end

//mask,针对stage_num == 8 的情况
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        mask <= 0;
    else if (stage_level == 0 && output_flag == 1'b1 && mask_ready == 1'b1)
        mask <= 1024'b1100101011010011100111101110111010011110111010101011110111101110111111000110011001011100001011111111101010101100100100000110111000101111010000001011111100000011000001011000100110111000011100101010010011001010000101010011001011110100010001001101010110001110000000100100001101010100101111000110111110110011110110101110111001110100111101101000001100011010000011001101111000101010110111111110101010001010000100001100110101010110000000110010001100100101101001001011010010111000010100100010001101111010011110001000001110000011111001100000111100101110011101001010001011011011000111110000101110010110101111101100011101000000110111010111100111000010011001000010000001101001110110010011000100111100110111010010001011110000011011011111011000111110101110110011111010111010101011101111110100001010000111001001011010100001001110100001010111000101000000111101000101110011100011111110101001001110110101011000100110010000111010110001010111011000110000000101111011001110000001000101111101000110001100001001011010010100010010001101010110010000;
    else if (stage_level == 1 && output_flag == 1'b1 && mask_ready == 1'b1)
        mask <= {{512{1'b0}},512'b10110110010100000110111110110000111111011100011110001111010000111000101000000101000100010101111010111110101010011011000101000110000111100101100111011111001000111110110111110110100000111110111100000101011001011100100101100000110000100011011010010000011001111100010111000010110111101100110111011100001110110000011101110010111110000000011001100001011010000110000011100001001101000101000100010011000101001110011100101011110101111101000110011110011001001001110100111101101011010000000000110110000111101111100010110001};
    else if (stage_level == 2 && output_flag == 1'b1 && mask_ready == 1'b1)
        mask <= {{768{1'b0}},256'b1111110100000001101111101100011101110110011100110001001110001111111010010111010110010111101111000101000000011011101110110000100110110010110100001101000000000111000101010101110111010010101001011011000111100011101001100111110101101100000100010000010000010100};
    else if (stage_level == 3 && output_flag == 1'b1 && mask_ready == 1'b1)
        mask <= {{896{1'b0}},128'b10001100100100011110110101110110110010111011111001100011010110100000010011000100001111000011000011101110001110110001100111001010};
    else if (stage_level == 4 && output_flag == 1'b1 && mask_ready == 1'b1)
        mask <= {{960{1'b0}},64'b0000101000110010001111111010000101010111111011001001010100011011};
    else if (stage_level == 5 && output_flag == 1'b1 && mask_ready == 1'b1)
        mask <= {{992{1'b0}},32'b11011100100100010101011111100000};
    else if (stage_level == 6 && output_flag == 1'b1 && mask_ready == 1'b1)
        mask <= {{1008{1'b0}},16'b0011110110000101};
    else if (stage_level == 7 && output_flag == 1'b1)
        mask <= 0;
    else 
        mask <= mask;
end

//mask_wire
assign mask_wire = mask;

//mask_vld
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        mask_vld <= 1'b0;
    else if (mask_ready == 1'b1)
        mask_vld <= 1'b1;
    else
        mask_vld <= 1'b0;
end

//mask_vld_wire
assign mask_vld_wire = mask_vld;


endmodule