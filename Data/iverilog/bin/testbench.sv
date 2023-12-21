module SimpleProcessor_tb;

    // Inputs
    reg clk;
    reg rst;
    reg [15:0] data_in;
    reg [15:0] mem_sel;

    // Outputs
    wire [15:0] data_out;
    wire [15:0] mem_out;

    // Instantiate the SimpleProcessor module
    SimpleProcessor dut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .mem_sel(mem_sel),
        .data_out(data_out),
        .mem_out(mem_out)
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
        #100000 $finish; // Finish the simulation
    end
endmodule
