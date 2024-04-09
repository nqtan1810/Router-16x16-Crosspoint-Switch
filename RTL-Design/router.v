module router( clock, reset_n,
                din, frame_n, valid_n,
                dout, frameo_n, valido_n, 
                busy_n );
	input clock, reset_n;
	input [15:0] din, frame_n, valid_n;
	output [15:0] dout, frameo_n, valido_n, busy_n;
	wire [15:0] busy;
	wire [15:0] request[15:0];
	wire [15:0] grant[15:0];
	wire [15:0] frame_n_port_out[15:0];
	wire [15:0] valid_n_port_out[15:0];
	wire [15:0] din_port_out[15:0];
    assign busy_n = busy ~^ 16'h0000;
	genvar i;
	generate
		for (i=0; i < 16; i=i+1) begin: port_in_generate
			port_in port_in_DUT(
                //input
                .clock(clock),
                .reset_n(reset_n),
                .busy_in(busy),
                .grant({grant[15][i], grant[14][i], grant[13][i], grant[12][i],
                        grant[11][i], grant[10][i], grant[9][i], grant[8][i], 
                        grant[7][i], grant[6][i], grant[5][i], grant[4][i],
                        grant[3][i], grant[2][i], grant[1][i], grant[0][i]}),
                .frame_n(frame_n[i]),
                .valid_n(valid_n[i]),
                .din(din[i]),
                //output 
                .request(request[i]),
                .frameo_n(frame_n_port_out[i]),
                .valido_n(valid_n_port_out[i]),
                .dout(din_port_out[i])
            );
		end
	endgenerate
	genvar j;
	generate
		for (j=0; j < 16; j=j+1) begin: arbiter_generate
			arbiter arbiter_DUT(
                 .clock(clock),
                 .reset_n(reset_n),
                 .request({request[15][j], request[14][j], request[13][j], request[12][j],
                           request[11][j], request[10][j], request[9][j], request[8][j], 
                           request[7][j], request[6][j], request[5][j], request[4][j],
                           request[3][j], request[2][j], request[1][j], request[0][j]}),
                 .grant(grant[j])
                 );
		end
	endgenerate
	genvar k;
	generate
		for (k=0; k < 16; k=k+1) begin: port_out_generate
			port_out port_out_DUT(
                 // input 
                .grant(grant[k]),		// xem xet lai
                .frame_n({frame_n_port_out[15][k], frame_n_port_out[14][k], frame_n_port_out[13][k], frame_n_port_out[12][k], 
                             frame_n_port_out[11][k], frame_n_port_out[10][k], frame_n_port_out[9][k], frame_n_port_out[8][k],
                             frame_n_port_out[7][k], frame_n_port_out[6][k], frame_n_port_out[5][k], frame_n_port_out[4][k], 
                             frame_n_port_out[3][k], frame_n_port_out[2][k], frame_n_port_out[1][k], frame_n_port_out[0][k]}), 
                .valid_n({valid_n_port_out[15][k], valid_n_port_out[14][k], valid_n_port_out[13][k], valid_n_port_out[12][k], 
                             valid_n_port_out[11][k], valid_n_port_out[10][k], valid_n_port_out[9][k], valid_n_port_out[8][k],
                             valid_n_port_out[7][k], valid_n_port_out[6][k], valid_n_port_out[5][k], valid_n_port_out[4][k], 
                             valid_n_port_out[3][k], valid_n_port_out[2][k], valid_n_port_out[1][k], valid_n_port_out[0][k]}),    
                .din( 	{din_port_out[15][k], din_port_out[14][k], din_port_out[13][k], din_port_out[12][k], 
                             din_port_out[11][k], din_port_out[10][k], din_port_out[9][k], din_port_out[8][k],
                             din_port_out[7][k], din_port_out[6][k], din_port_out[5][k], din_port_out[4][k], 
                             din_port_out[3][k], din_port_out[2][k], din_port_out[1][k], din_port_out[0][k]}),
                // output
                .busy_out(busy[k]),
                .frameo_n(frameo_n[k]),
                .valido_n(valido_n[k]),
                .dout(dout[k])
            );
		end
	endgenerate
endmodule
