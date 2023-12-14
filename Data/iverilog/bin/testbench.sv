module SimpleProcessor_tb;

    // Inputs
    reg clk;
    reg rst;
    reg [31:0] data_in;

    // Outputs
    wire [31:0] data_out;

    // Instantiate the SimpleProcessor module
    SimpleProcessor dut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock generation
    always begin
        #1 clk = ~clk;
        //$display("Time %t | Result: %h",$time, data_out);
        data_in = $time;
    end

    // Monitor the result
    initial begin
        clk = 0;
        $monitor("Time %t | Result: %h", $time, data_out);
        #3000 $finish; // Finish the simulation
    end
endmodule