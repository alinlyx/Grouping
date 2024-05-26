module multi(input [7:0] din, output reg [15:0] dout);
reg[3:0] i;
 
always@(*)
begin
	dout = 0 ;
	for(i = 0 ; i <8 ; i = i + 1)
	begin
		if(din[i] == 1)
		begin
			dout = (din <<i) + dout;
		end
		else dout = dout;
	end
	i = 0;
end
 
 
endmodule