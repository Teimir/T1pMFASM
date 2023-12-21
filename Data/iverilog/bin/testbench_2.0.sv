module SimpleProcessor_tb;

    // Inputs
    reg clk;
    reg rst;
    reg [15:0] data_in;
    reg [15:0] mem_sel;

    // Outputs
    wire [15:0] data_out;
    wire [15:0] mem_out;

    //VidMem
    reg [15:0] vidmem [3:0];

    //MemStart
    parameter MemStart = 15'h00;
    //'Interrupts'
    parameter HexPrint = 15'h01;
    parameter DecPrint = 15'h02;
    parameter CharPrint = 15'h03;

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

    always @(data_out) begin
        case (data_out)
            HexPrint:begin
                mem_sel = MemStart;
                $write("%x", mem_out);
            end
            DecPrint:begin
                mem_sel = MemStart;
                $write("%d", mem_out[15:0]);
            end
            CharPrint:begin
                mem_sel = MemStart;
                $write("%c", mem_out[15:0]);
            end
        endcase
    end

    // Monitor the result
    initial begin
        clk = 0;
        //$monitor("Time %t | Result: %h", $time, data_out);
        #100000 $finish; // Finish the simulation
    end
endmodule
