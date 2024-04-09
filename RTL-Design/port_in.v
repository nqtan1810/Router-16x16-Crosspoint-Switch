module port_in(
	//input
	clock, reset_n,
	busy_in, grant,
	frame_n, valid_n, din,
	//output 
	request,
	frameo_n, valido_n, dout
);
	parameter START = 2'b00;
	parameter ADDRESS = 2'b01;
	parameter PADDING = 2'b10;
	parameter PAYLOAD = 2'b11;
	input clock;
	input reset_n;
	input [15:0] busy_in;
	input [15:0] grant;
	input frame_n;
	input valid_n;
	input din;
	output reg [15:0] request;
	output reg [15:0] frameo_n;
	output reg [15:0] valido_n;
	output reg [15:0] dout;
	reg [1:0] current_state, next_state;
    reg [3:0] addr_out;
    reg [2:0] cnt_addr;
	always @(*) begin
		case(current_state)
			START: next_state = (!frame_n) ? ADDRESS : START;
			ADDRESS: next_state = (frame_n) ? START : ((cnt_addr >= 4) ? PADDING : ADDRESS); 
			PADDING: next_state = (frame_n) ? START : (((!busy_in[addr_out]) && grant[addr_out]) ? PAYLOAD : PADDING);
			PAYLOAD: next_state = (frame_n) ? START : PAYLOAD;
			default: next_state = START;
		endcase
	end
	always @(posedge clock or negedge reset_n) begin
		if(!reset_n) begin
			current_state <= START;
			cnt_addr <= 0;
			addr_out <= 0;
		end
		else begin
			current_state <= next_state;
			if(next_state == START) begin
				cnt_addr <= 0;
				addr_out <= 0;
			end else
			if(next_state == ADDRESS) begin
				cnt_addr <= cnt_addr + 1'b1;
				addr_out <= {din, addr_out[3:1]};
			end else begin
				cnt_addr <= 0;
			end
		end
	end
	always @(*) begin
		request = 16'b0;
		if(current_state >= PADDING) begin
			request[addr_out] = 1'b1;	
		end
		case (addr_out)
			4'b000: begin
						dout = {15'bzzzzzzzzzzzzzzz, din};
						frameo_n = {15'bzzzzzzzzzzzzzzz, frame_n};
						valido_n = {15'bzzzzzzzzzzzzzzz, valid_n};
			end
			4'b0001: begin
						dout = {14'bzzzzzzzzzzzzzz, din, 1'bz};
						frameo_n = {14'bzzzzzzzzzzzzzz, frame_n, 1'bz};
						valido_n = {14'bzzzzzzzzzzzzzz, valid_n, 1'bz};
			end
			4'b0010: begin
						dout = {13'bzzzzzzzzzzzzz, din, 2'bzz};
						frameo_n = {13'bzzzzzzzzzzzzz, frame_n, 2'bzz};
						valido_n = {13'bzzzzzzzzzzzzz, valid_n, 2'bzz};
			end
			4'b0011: begin
						dout = {12'bzzzzzzzzzzzz, din, 3'bzzz};
						frameo_n = {12'bzzzzzzzzzzzz, frame_n, 3'bzzz};
						valido_n = {12'bzzzzzzzzzzzz, valid_n, 3'bzzz};
			end
			4'b0100: begin
						dout = {11'bzzzzzzzzzzz, din, 4'bzzzz};
						frameo_n = {11'bzzzzzzzzzzz, frame_n, 4'bzzzz};
						valido_n = {11'bzzzzzzzzzzz, valid_n, 4'bzzzz};
			end
			4'b0101: begin
						dout = {10'bzzzzzzzzzz, din, 5'bzzzzz};
						frameo_n = {10'bzzzzzzzzzz, frame_n, 5'bzzzzz};
						valido_n = {10'bzzzzzzzzzz, valid_n, 5'bzzzzz};
			end
			4'b0110: begin
						dout = {9'bzzzzzzzzz, din, 6'bzzzzzz};
						frameo_n = {9'bzzzzzzzzz, frame_n, 6'bzzzzzz};
						valido_n = {9'bzzzzzzzzz, valid_n, 6'bzzzzzz};
			end
			4'b0111: begin
						dout = {8'bzzzzzzzz, din, 7'bzzzzzzz};
						frameo_n = {8'bzzzzzzzz, frame_n, 7'bzzzzzzz};
						valido_n = {8'bzzzzzzzz, valid_n, 7'bzzzzzzz};
			end
			4'b1000: begin
						dout = {7'bzzzzzzz, din, 8'bzzzzzzzz};
						frameo_n = {7'bzzzzzzz, frame_n, 8'bzzzzzzzz};
						valido_n = {7'bzzzzzzz, valid_n, 8'bzzzzzzzz};
			end
			4'b1001: begin
						dout = {6'bzzzzzz, din, 9'bzzzzzzzzz};
						frameo_n = {6'bzzzzzz, frame_n, 9'bzzzzzzzzz};
						valido_n = {6'bzzzzzz, valid_n, 9'bzzzzzzzzz};
			end
			4'b1010: begin
						dout = {5'bzzzzz, din, 10'bzzzzzzzzzz};
						frameo_n = {5'bzzzzz, frame_n, 10'bzzzzzzzzzz};
						valido_n = {5'bzzzzz, valid_n, 10'bzzzzzzzzzz};
			end
			4'b1011: begin
						dout = {4'bzzzz, din, 11'bzzzzzzzzzzz};
						frameo_n = {4'bzzzz, frame_n, 11'bzzzzzzzzzzz};
						valido_n = {4'bzzzz, valid_n, 11'bzzzzzzzzzzz};
			end
			4'b1100: begin
						dout = {3'bzzz, din, 12'bzzzzzzzzzzzz};
						frameo_n = {3'bzzz, frame_n, 12'bzzzzzzzzzzzz};
						valido_n = {3'bzzz, valid_n, 12'bzzzzzzzzzzzz};
			end
			4'b1101: begin
						dout = {2'bzz, din, 13'bzzzzzzzzzzzzz};
						frameo_n = {2'bzz, frame_n, 13'bzzzzzzzzzzzzz};
						valido_n = {2'bzz, valid_n, 13'bzzzzzzzzzzzzz};
			end
			4'b1110: begin
						dout = {1'bz, din, 14'bzzzzzzzzzzzzzz};
						frameo_n = {1'bz, frame_n, 14'bzzzzzzzzzzzzzz};
						valido_n = {1'bz, valid_n, 14'bzzzzzzzzzzzzzz};
			end
			4'b1111: begin
						dout = {din, 15'bzzzzzzzzzzzzzzz};
						frameo_n = {frame_n, 15'bzzzzzzzzzzzzzzz};
						valido_n = {valid_n, 15'bzzzzzzzzzzzzzzz};
			end
		endcase
	end
endmodule 