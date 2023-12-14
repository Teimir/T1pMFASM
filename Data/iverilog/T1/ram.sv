module ram(
	input [7:0] Address,
	input [7:0] Data,
	input WE,
	input RE,
	input clk,
	input SB,
	output [7:0] datao);
	
enum reg [1:0] {IDLE, ReadData, WriteData, SetBank} state = IDLE;
reg [7:0] addr = 8'b0;
reg [7:0] data = 8'b0;
reg [1:0] bank = 2'b0;

reg [7:0] mem [255:0][1:0];






always @(posedge clk) begin
	case(state)
		IDLE: begin
			addr <= Address;
			data <= Data;
			if (WE) state <= WriteData;
			else if (RE) state <= ReadData;
			else if (SB) state <= SetBank;
			end
		ReadData: begin
			datao <= mem[addr][bank];
			state <= IDLE;
			end
		WriteData: begin
			mem[addr][bank] <= datao;
			state <= IDLE;
			end
		SetBank: begin
			bank <= data[1:0];
			state <= IDLE;
			end
	endcase
end

	
endmodule	