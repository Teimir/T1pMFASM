module T1 (
  input wire clk,
  input wire reset,
  output wire [3:0] led_out,
  output [3:0] DIG,
  output [7:0] SEG
);

  // Параметры конечного автомата
  localparam IDLE = 2'b00;
  localparam FETCH = 2'b01;
  localparam EXECUTE = 2'b10;
  localparam INTERRUPT = 2'b11;

  // Внутренние регистры процессора и сигналы управления
  reg [7:0] regs [3:0];
  reg [7:0] Acc;
  reg [1:0] state;
  reg [7:0] instruction_p;
  reg [7:0] instruction_reg;
  
  reg [25:0] cnt = 26'd0;
  
  reg [15:0] cnt2 = 16'd0;
  wire [6:0] segments;
  wire [3:0] code;
  enum reg [1:0] {SHN, FHN, SMN, FMN} state2 = FMN;

  wire [7:0] Address;
  wire [7:0] Data;
  wire [7:0] RData;
  wire WE, RE, SB;
  
  reg [7:0] memory [255:0];
  
  
  
  indicator16 dec(
			.code(code),
			.segments(segments)
		);
	
	
	ram mem( 
			.Address(Address),
			.Data(Data),
			.datao(RData),
			.WE(WE),
			.RE(RE),
			.SB(SB),
			.clk(clk)
		);

  
  // Присваивание начальных значений
  initial begin
    state <= IDLE;
    regs[2'd0] <= 8'b0;
	 regs[2'd1] <= 8'b0;
	 regs[2'd2] <= 8'b0;
	 regs[2'd3] <= 8'b0;
	 // Загрузка программы из файла в память
    $readmemh("E:\\Quatrus\\T1.hex", memory);
  end

  

  always @(posedge clk) begin
  if (~reset) begin
	state <= IDLE;
	instruction_p <= 7'd0;
	Acc <= 7'd0;
	regs[2'd0] <= 8'b0;
	regs[2'd1] <= 8'b0;
	regs[2'd2] <= 8'b0;
	regs[2'd3] <= 8'b0;
	end
  else begin
		cnt <= cnt + 26'b1;
		//if(cnt == 26'd5000000) begin
		if(cnt == 26'd5000) begin
			cnt <= 26'd0;
			case (state)
				IDLE: begin
						state <= FETCH;
						// Ничего не делаем в состоянии IDLE
				end
				FETCH: begin
						instruction_reg <= memory[instruction_p]; // Чтение инструкции из памяти
						instruction_p <= instruction_p + 7'b01;
						state <= EXECUTE;
				end
				EXECUTE: begin
						// Логика выполнения команд
						case (instruction_reg[7:4])
							4'b0001: begin 
									instruction_p <= instruction_p + 7'd1;
									Acc <= memory[instruction_p];
							end
							4'b0010: Acc <= Acc + regs[instruction_reg[1:0]]; // ADD
						//	4'b110: data_out <= regs[instruction_reg[1:0]]; // OUTPUT
							4'b0011: Acc <= regs[instruction_reg[1:0]];
							4'b0100: Acc <= Acc - regs[instruction_reg[1:0]]; // SUB
							4'b0101: regs[instruction_reg[1:0]] <= regs[instruction_reg[3:2]];
							4'b0111: regs[instruction_reg[1:0]] <= Acc;
							4'b1001: instruction_p <= regs[instruction_reg[1:0]];
							4'b1010: begin
											if (regs[instruction_reg[3:2]] == 7'b0) instruction_p <= regs[instruction_reg[1:0]];
										end
							4'b1011: begin
											if (regs[instruction_reg[3:2]] != 7'b0) instruction_p <= regs[instruction_reg[1:0]];
										end
 						endcase
						state <= INTERRUPT;
				end
				INTERRUPT: begin
						
						state <= IDLE;
				end
			endcase
	   end
	end
  end
  
  
  
  
  always @(posedge clk) begin
  cnt2 <= cnt2 + 16'b1;
	if(cnt2 == 16'd5000) begin
		cnt2 <= 16'd0;
			case(state2)
				FMN: begin
					DIG <= 4'b1110;
					code <= Acc[3:0];
					state2 <= SMN;
					SEG[7] <= 1;
				end
				SMN: begin
					DIG <= 4'b1101;
					code <= Acc[7:4];
					state2 <= FHN;
					SEG[7] <= 1;
				end
				FHN: begin
					DIG <= 4'b1011;
					code <= instruction_p[3:0];
					state2 <= SHN;
					SEG[7] <= 0;
				end
				SHN: begin
					DIG <= 4'b0111;
					code <= instruction_p[7:4];
					state2 <= FMN;
					SEG[7] <= 1;
				end
			endcase
		end
	end
  
  
  
  

	
	assign SEG[6:0] = ~segments[6:0];
   assign led_out[1:0] = ~state;
	assign led_out[2] = ~0;
	assign led_out[3] = reset;
  
  
endmodule





