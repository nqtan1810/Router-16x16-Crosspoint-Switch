//`timescale 1ns / 1ps

program automatic test(router_io rtr_io);
    bit [3:0] sa;
    bit [3:0] da;
    logic [7:0] payload[$];
    logic [7:0] pkt2cmp_payload[$];
    
    initial begin
        reset();
        gen();
        fork
            send();
            #55 recv();
        join 
        check(); 
    end
    
    task reset();
        $display("reset() starts here");
        rtr_io.reset_n = 1'b0;
        rtr_io.frame_n = 16'hffff;
        rtr_io.valid_n = 16'hffff;
        #10 rtr_io.reset_n = 1'b1;
        #150 
        //repeat(15) @(rtr_io.cb);
        $display("reset() finishes here");
    endtask
    
    task gen();
        $display("gen() starts here");
        sa = 3;
        da = 7;
        payload.delete();
        repeat($urandom_range(21,25))
            payload.push_back($urandom);
        foreach (payload[i]) begin
            $display("[%0t] payload[%0d]: %0d", $time, i, payload[i]);
        end
        $display("gen() finishes here");
    endtask
    
    task send();
        $display("send() starts here");
        // drive frame_n here
        #10 rtr_io.frame_n[sa] = 1'b0;
        
        // drive din here
        send_addrs();
        send_pad();
        send_payload();
        $display("send() finishes here");
    endtask
    
    task send_addrs();
        $display("send_addrs() starts here");
            rtr_io.valid_n[sa] = 1'bx;
            rtr_io.din[sa] = da[0];
        #10 rtr_io.din[sa] = da[1];
        #10 rtr_io.din[sa] = da[2];
        #10 rtr_io.din[sa] = da[3];
        #10
        $display("Source address: %0d", sa);
        $display("Destination address: %0d", da);
        $display("send_addrs() finishes here");
    endtask
    
    task send_pad();
        $display("send_pad() starts here");
        while(!rtr_io.frame_n[da] && !rtr_io.valid_n[da]) begin
            #10 rtr_io.din[sa] = 1'b1;
            rtr_io.frame_n[sa] = 1'b1;
        end
        $display("send_pad() finishes here");
    endtask
    
    task send_payload();
        
        // write loop to send 8 bit payload
        integer i, j;
        $display("send_payload() starts here");
        for(i=0; i<payload.size(); i=i+1) begin
            for(j=0; j<8; j=j+1) begin
                #10 rtr_io.din[sa] = payload[i][j];
                rtr_io.valid_n[sa] = 1'b0;
                //$display("[%0t] payload[%0d][%0d]: %0d", $time, i, j, payload[i][j]);
            end
        end
        $display("send_payload() finishes here");
    endtask
    
    task recv();
        get_payload();
    endtask;
    
    task get_payload();
        // store each 8-bit data into pkt2cmp_payload[$]
        logic [7:0] data_out;
        integer i, j;
        $display("get_payload() starts here");
        for(i=0; i<payload.size(); i=i+1) begin
            for(j=0; j<8; j=j+1) begin
                #10 data_out = {rtr_io.dout[da], data_out[7:1]};
                //$display("[%0t] dout: %0d", $time, rtr_io.dout[da]);
            end
            pkt2cmp_payload.push_back(data_out);
        end
        foreach (payload[i]) begin
            $display("[%0t] pkt2cmp_payload[%0d]: %0d", $time, i, pkt2cmp_payload[i]);
        end
        $display("get_payload() finishes here");
    endtask
    
    function compare();
        // compare data in payload[$] and pkt2cmp_payload[$] to verify that the payload received correctly
        integer i;
        for(i=0; i<payload.size(); i=i+1) begin
            if( payload[i] != pkt2cmp_payload[i]) begin
                return 1;
            end
        end
        return 0;
    endfunction 
    
    task check();
        if(!compare()) begin
            // if error, print error message and finish simulation
            $display("ERROR: Received data are NOT MATCHED with sent data");
        end
        else begin
            // if check is successful, print message indicating number of packets successfully checked
            $display("PASSED: %0d received packets are IDENTICAL with %0d sent packets", pkt2cmp_payload.size(), payload.size());
        end
        
    endtask 

endprogram
