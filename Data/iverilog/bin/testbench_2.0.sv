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
    parameter MemStart = 16'd65535 - 15'd256;
    //'Interrupts'    
    parameter BinPrint = 16'h02;
    parameter CharPrint = 16'h08;
    parameter DecPrint = 16'h0A;
    parameter HexPrint = 16'h10;

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
            BinPrint:begin
                mem_sel = MemStart;
                $write("%b", mem_out);
            end
            HexPrint:begin
                mem_sel = MemStart;
                $write("%x", mem_out);
            end
            DecPrint:begin
                mem_sel = MemStart;
                $write("%d", mem_out);
            end
            CharPrint:begin
                mem_sel = MemStart;
                $write("%c", mem_out[7:0]);
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
