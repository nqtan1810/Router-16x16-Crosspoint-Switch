module port_out(
	// input 
	grant, frame_n, valid_n, din,
	// output
	busy_out, frameo_n, valido_n, dout);
	input [15:0] grant;
	input [15:0] frame_n;
	input [15:0] valid_n;
	input [15:0] din;
	output reg busy_out;
	output reg frameo_n;
	output reg valido_n;
	output reg dout;
	generate
		always @(*) begin: select_port_in
			integer i;
			frameo_n = 1'bz;
			valido_n = 1'b1;
			dout = 1'bx;
			busy_out = 0;
			for (i = 0; i < 16; i = i + 1) begin
				if (grant[i]) begin
					frameo_n = 0;
					valido_n = valid_n[i];
					dout = din[i];
					busy_out = 1;
				end
			end
		end
	endgenerate
endmodule
