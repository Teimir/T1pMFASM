module SimpleProcessor(
	input wire clk,
	input wire rst,
	output wire [7:0] data_out
);

integer i;
reg [7:0] RF [0:7];

reg [7:0] Acc = 8'b0;

reg [7:0] mem [0:255];
reg [7:0] pc = 8'b0;
reg [7:0] ins = 8'b0;
reg [7:0] data = 8'b0;
reg [7:0] exdata = 8'b0;

reg [2:0] state = IDLE;
reg stop = 0;

parameter IDLE = 3'b00;
parameter FTHOP = 3'b01;
parameter FTHD = 3'b10;
parameter FTHED = 3'b100;
parameter EXEC = 3'b11;


parameter NOP = 8'h00;
parameter LDA = 8'h01;
parameter MV = 8'h02;
parameter ADD = 8'h03;
parameter SUB = 8'h04;
parameter IN = 8'h05;
parameter OUT = 8'h06;
parameter INC = 8'h85;
parameter DEC = 8'h86;
parameter JMP = 8'h07;
parameter JFZ = 8'h08;
parameter HLT = 8'hFF;

always @(posedge clk) begin
	  case(state)
		IDLE: begin
				if (stop == 0) state <= FTHOP;
		end
		FTHOP: begin
			ins <= mem[pc];
			if (!mem[pc][7] && mem[pc] != NOP) begin
				pc <= pc + 8'b1;
				state <= FTHD;
			end
			else
				state <= EXEC;
		end
		FTHD: begin
			data <= mem[pc];
			if (mem[pc][7:6] == 2'b11) begin 
				state <= FTHED;
				pc <= pc + 8'b1;
			end
			else 
				state <= EXEC;
		end
		FTHED: begin
			exdata <= mem[pc];
			state <= EXEC;
		end
		EXEC: begin
			case(ins[7:0])
				HLT: stop <= 1;
					LDA: begin
						Acc <= data;
					end
				NOP:
					state <= IDLE;
					MV: begin
						if (data[7:6] == 2'b00)
							RF[data[2:0]] <= Acc;
						else begin
							if (data[7:6] == 2'b10) 
								RF[data[2:0]] <= RF[data[5:3]];
							if (data[7:6] == 2'b11) 
								RF[data[2:0]] <= exdata;
							if (data[7:6] == 2'b01) 
								RF[data[2:0]] <= pc + 1;
						end
					end
					IN: begin
						RF[data[2:0]] <= mem[RF[data[5:3]]];
					end
					OUT: begin
						mem[RF[data[5:3]]] <= RF[data[2:0]];
					end
					ADD: begin
						if (data[7:6] == 2'b00)
							Acc <= Acc + RF[data[2:0]];
						else begin
							if (data[7:6] == 2'b10) 
								RF[data[5:3]] <= RF[data[5:3]] + RF[data[2:0]];
							if (data[7:6] == 2'b11) 
								RF[data[2:0]] <= RF[data[2:0]] + exdata;
						end
					end
					SUB: begin
						if (data[7:6] == 2'b00)
							Acc <= Acc - RF[data[2:0]];
						else begin
							if (data[7:6] == 2'b10) RF[data[5:3]] <= RF[data[5:3]] - RF[data[2:0]];
							if (data[7:6] == 2'b11) RF[data[2:0]] <= RF[data[2:0]] - exdata;
						end
					end
					INC: Acc <= Acc + 8'b1;
					DEC: Acc <= Acc - 8'b1;
					JMP: begin
						if (data[7:6] == 2'b00) 
							pc <= Acc;
						else 
							pc <= RF[data[2:0]];
					end
					JFZ: begin
							if (data[7:6] == 2'b00 && Acc == 8'b0) 
								pc <= RF[data[2:0]];
							else begin
							if (RF[data[5:3]] == 8'b0) 
								pc <= RF[data[2:0]];
						end
					end
			endcase
		if(ins != JMP && ins != JFZ) pc <= pc + 8'b1;
		state <= IDLE;
		end
	  endcase
end


assign data_out = Acc;

initial begin
		for(i = 0; i <= 7; i = i + 1) begin
		RF[i] = 8'b0;
		end
		$readmemh("output.bin", mem);
end

endmodule
