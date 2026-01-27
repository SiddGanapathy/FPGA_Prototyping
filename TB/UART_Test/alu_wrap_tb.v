`timescale 1ns / 1ps

module tb_alu_wrapper;

    // Clock and reset
    reg        clk;
    reg        rst_n;
    
    // Control inputs
    reg        start;
    reg        op_sel;
    reg [7:0]  a_data;
    reg [7:0]  b_data;
    
    // Outputs
    wire       done;
    wire [6:0] seg;
    wire [3:0] an;

    // Instantiate DUT
    alu_wrapper dut (
        .i_clk    (clk),
        .i_rst_n  (rst_n),
        .start    (start),
        .op_sel   (op_sel),
        .a_data   (a_data),
        .b_data   (b_data),
        .done     (done),
        .seg      (seg),
        .an       (an)
    );

    // Clock generation - 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Task to perform an ALU operation
    task alu_operation;
        input [7:0] a;
        input [7:0] b;
        input       op;
        input [31:0] test_num;
        begin
            $display("\n====== Test %0d: %s %0d %s %0d ======", 
                     test_num, 
                     op ? "SUB:" : "ADD:",
                     a, 
                     op ? "-" : "+", 
                     b);
            a_data = a;
            b_data = b;
            op_sel = op;
            start  = 1;
            #10;
            start  = 0;
            wait(done);
            $display("Operation completed at time %0t", $time);
            // Wait longer to observe seven segment display
            #100;
            $display("Seg=%b An=%b", seg, an);
        end
    endtask

    // Test stimulus
    initial begin
        // Initialize signals
        rst_n   = 0;
        start   = 0;
        op_sel  = 0;
        a_data  = 8'h00;
        b_data  = 8'h00;
        
        // Apply reset
        #20;
        rst_n = 1;
        #20;
        
        // Run test cases using task
        alu_operation(8'd5,    8'd3,   0, 1);  // 5 + 3 = 8
        alu_operation(8'd10,   8'd4,   1, 2);  // 10 - 4 = 6
        alu_operation(8'd255,  8'd1,   0, 3);  // 255 + 1 = 256 (0x100)
        alu_operation(8'd0,    8'd1,   1, 4);  // 0 - 1 = -1 (underflow)
        alu_operation(8'd100,  8'd50,  0, 5);  // 100 + 50 = 150
        alu_operation(8'd200,  8'd75,  1, 6);  // 200 - 75 = 125
        alu_operation(8'd127,  8'd127, 0, 7);  // 127 + 127 = 254
        alu_operation(8'd50,   8'd50,  1, 8);  // 50 - 50 = 0
        
        $display("\n====== All tests completed! ======");
        #100;
        $finish;
    end
    
    // Waveform dump for viewing in simulator
    initial begin
        $dumpfile("alu_wrapper_tb.vcd");
        $dumpvars(0, tb_alu_wrapper);
    end

endmodule