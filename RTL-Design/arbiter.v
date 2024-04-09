module arbiter( clock, reset_n,
                request, grant
                );
    input clock, reset_n;
    input [15:0] request;
    output reg [15:0] grant;
    wire not_grant;
    assign not_grant = ~|grant[15:0];
    generate
        genvar i;
        always @ (posedge clock, negedge reset_n) begin //For request[0]
            if (!reset_n) begin
                grant[0] <= 1'b0;
            end else if (not_grant) begin
                grant[0] <= request[0]; //highest priority
            end else begin
                grant[0] <= request[0] & grant[0];
            end
        end
        for (i = 1; i < 16; i=i+1) begin: fixed_priority_grant //For request[15:1]
            always @ (posedge clock, negedge reset_n) begin
                if (!reset_n)
                grant[i] <= 1'b0;
            else if (not_grant)
                grant[i] <= request[i] & ~|request[i-1:0]; // higher priority --> lower priority
            else
                grant[i] <= request[i] & grant[i];
            end
        end
    endgenerate
endmodule
