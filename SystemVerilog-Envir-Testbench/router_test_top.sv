//`timescale 1ns / 1ps

module router_test_top(
    output clock,
    output reset_n,
    output [15:0] frame_n,
    output [15:0] valid_n,
    output [15:0] din,
    output [15:0] frameo_n,
    output [15:0] valido_n,
    output [15:0] dout,
    output [15:0] busy_n
);
    
    // for debug
    assign clock = top_io.clock;
    assign reset_n = top_io.reset_n;
    assign frame_n = top_io.frame_n;
    assign valid_n = top_io.valid_n;
    assign din = top_io.din;
    assign frameo_n = top_io.frameo_n;
    assign dout = top_io.dout;
    assign busy_n = top_io.busy_n;
    
    parameter simulation_cycle = 10;
    bit SystemClock;
    router_io top_io(SystemClock);
    test router_test(top_io);
    router dut(.reset_n (top_io.reset_n),
               .clock(top_io.clock),
               .frame_n(top_io.frame_n),
               .valid_n(top_io.valid_n),
               .din(top_io.din),
               .dout(top_io.dout),
               .busy_n(top_io.busy_n),
               .valido_n(top_io.valido_n),
               .frameo_n(top_io.frameo_n)
               );
    initial begin
        SystemClock = 0;
        forever begin
            #(simulation_cycle/2)
            SystemClock = ~SystemClock;
        end
    end
    
endmodule
