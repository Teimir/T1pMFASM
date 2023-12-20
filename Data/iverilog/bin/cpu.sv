module SimpleProcessor(
	input wire clk,
	input wire rst,
	input wire [15:0] data_in,
	output wire [15:0] data_out
);

integer i;
reg [15:0] RF [0:7]; 				//Регистры

//Регистры ввода и вывода, потом поменяю
reg [15:0] rout = 8'b0;
reg [15:0] rin = 8'b0;

//Регистры для работы с памятью
reg [7:0] mem [0:65535];	//Сама память
reg [15:0] ip = 8'b0;     	//Указатель инструкции
reg [7:0] ins = 8'b0;    	//Сама инструкция
reg [15:0] data = 8'b0;   //Доп поле данных

reg [2:0] state = IDLE;
reg stop = 0;
reg incip = 1;

reg [2:0] rflags = 4'b00;
	parameter ZF = 2'b00;
	parameter AF = 2'b01;
 
parameter IDLE = 3'b00;
parameter FTHOP = 3'b01;
parameter FTHD1 = 3'b10;
parameter FTHD2 = 3'b100;
parameter EXEC = 3'b11;

//ins[4:3] == 01 Однобайтовые
parameter OUT_R = 5'b000;
parameter OUT_RM = 5'b0001;
parameter JMP_R = 5'b100;
parameter JMP_RM =  5'b101;
parameter INC = 5'b010;
parameter DEC = 5'b011;
parameter IN_R = 5'b110;
parameter IN_RM = 5'b111;

//ins[4:3] == 11 Еще набор однобайтовых
parameter NOT_R = 3'b000;
parameter SPECIAL = 3'b001;		//здесь номер инструкции определяется по ins[7:5]
	parameter HLT = 3'b000;
	parameter STFZ = 3'b001;
	//3'b10 - зарезервировано
	parameter LDFZ = 3'b011;
	parameter NOP = 3'b100;

//ins[4:3] == 10 Двухбайтовые
parameter FIRST = 5'b000;		//Первый набор инструкций
	parameter MOV_R_R = 5'h00;
	parameter MOV_R_RM = 5'h01;
	parameter MOV_RM_R = 5'h02;
	parameter ADD_R_R = 5'h03;
	parameter ADD_R_RM = 5'h04;
	parameter ADD_RM_R = 5'h05; 
	parameter SUB_R_R = 5'h06;
	parameter SUB_R_RM = 5'h07;
	parameter SUB_RM_R = 5'h08; 
	parameter CMP_R_R = 5'h09;
	parameter CMP_R_RM = 5'h0A;
	parameter CMP_RM_R = 5'h0B;
	parameter AND_R_R = 5'h0C;
	parameter AND_R_RM = 5'h0D;
	parameter AND_RM_R = 5'h0E;
	parameter OR_R_R = 5'h0D;
	parameter OR_R_RM = 5'h0F;
	parameter OR_RM_R = 5'h10;
	parameter XOR_R_R = 5'h11;
	parameter XOR_R_RM = 5'h12;
	parameter XOR_RM_R = 5'h13;
	parameter SHR_R_R = 5'h14;
	parameter SHR_R_RM = 5'h15;
	parameter SHR_RM_R = 5'h16;
	parameter SHL_R_R = 5'h17;
	parameter SHL_R_RM = 5'h18;
	parameter SHL_RM_R = 5'h19;
//значения для возможных дальнейших расширений
parameter JF_R = 5'b100;
parameter JF_RM = 5'b101;

//ins[4:3] == 00 Трёхбайтовые
parameter MOV_R_C = 5'b000;
parameter ADD_R_C = 5'b001;
parameter MOV_RM_C = 5'b010;
parameter CMP_R_C = 5'b011;
parameter JF_C = 5'b100;
parameter JMP_C = 5'b101;
parameter MOV_R_CM = 5'b110;
parameter MOV_CM_R = 5'b111;




//Конченый автомат
always @(posedge clk) begin
	case(state)
		IDLE: begin //Состояние айдл
			if (stop == 0) //Стоп опущен - работаем
				state <= FTHOP;
		end
		FTHOP: begin
			ins <= mem[ip]; //Получаем инструкцию
			if (!mem[ip][3]) begin //байт больше чем 1
				ip <= ip + 16'b1;
				state <= FTHD1;
			end
			else //Если однобайтовая - идём выполнять
				state <= EXEC; 
		end
		FTHD1: begin //Получаем второй байт
			data[15:0] <= {mem[ip+1], mem[ip]};
			if (!ins[4]) begin
				ip <= ip + 16'b1;
				state <= FTHD2;
			end
			else
				state <= EXEC;
		end
		FTHD2: begin //Получаем третий байт
			state <= EXEC;
		end
		EXEC: begin
			case(ins[4:3])
				2'b11: begin
					case(ins[2:0])
						NOT_R:
							RF[ins[7:5]] <= ~RF[ins[7:5]];
						SPECIAL:
							case(ins[7:5])
								HLT:
									stop <= 1;
								LDFZ:
									rflags <= RF[0][3:0];
								STFZ:
									RF[0] <= rflags;
							endcase
					endcase
				end
				2'b01: begin
					case(ins[2:0])
						OUT_R:
							rout <= RF[ins[7:5]];
						OUT_RM: 
							rout <= mem[RF[ins[7:5]]];
						JMP_R: begin
							ip <= RF[ins[7:5]];
						end
						JMP_RM: begin
							ip <= mem[RF[ins[7:5]]];
						end
						INC: 
							RF[ins[7:5]] <= RF[ins[7:5]] + 8'b1;
						DEC: 
							RF[ins[7:5]] <= RF[ins[7:5]] - 8'b1;
						IN_R: begin
							RF[ins[7:5]] <= data_in;
							rin <= 16'hFFFF;
						end
						IN_RM: begin
							mem[RF[ins[7:5]]] <= data_in;
							rin <= 16'hFFFF;
						end
					endcase
				end
			    2'b00: begin
			    	case(ins[2:0])
			    		MOV_R_C: 
							RF[ins[7:5]] <= data;
						MOV_R_CM: 
							RF[ins[7:5]] <= {mem[data+1], mem[data]};
						MOV_CM_R: 
							{mem[data+1], mem[data]} <= RF[ins[7:5]];
						ADD_R_C: 
							RF[ins[7:5]] <= RF[ins[7:5]] + data;
						MOV_RM_C: 
							mem[RF[ins[7:5]]] <= data;
						CMP_R_C:  begin
							rflags[ZF] <= RF[ins[7:5]] == data;
							rflags[AF] <= RF[ins[7:5]] > data;
						end
						JF_C: begin
							if (rflags[ins[6:5]]==ins[7])
								ip <= data;
						end
						JMP_C: begin
							ip <= data;
						end
					endcase
			    end
			    2'b10: begin
			    	case(ins[2:0])
			    		FIRST: begin
							case(data[4:0])
								MOV_R_R:
									RF[ins[7:5]] <= RF[data[7:5]];
								MOV_R_RM:
									RF[ins[7:5]] <= mem[RF[data[7:5]]];
								MOV_RM_R:
									mem[RF[ins[7:5]]] <= RF[data[7:5]];
								ADD_R_R:
									RF[ins[7:5]] <= RF[ins[7:5]] + RF[data[7:5]];
								ADD_R_RM:
									RF[ins[7:5]] <= RF[ins[7:5]] + mem[RF[data[7:5]]];
								ADD_RM_R:
									mem[RF[ins[7:5]]] <= mem[RF[ins[7:5]]] + RF[data[7:5]];
								SUB_R_R:
									RF[ins[7:5]] <= RF[ins[7:5]] - RF[data[7:5]];
								SUB_R_RM:
									RF[ins[7:5]] <= RF[ins[7:5]] - mem[RF[data[7:5]]];
								SUB_RM_R:
									mem[RF[ins[7:5]]] <= mem[RF[ins[7:5]]] - RF[data[7:5]];
								CMP_R_R:begin
									rflags[ZF] <= RF[ins[7:5]] == RF[data[7:5]];
									rflags[AF] <= RF[ins[7:5]] > RF[data[7:5]];
								end
								CMP_R_RM:begin
									rflags[ZF] <= RF[ins[7:5]] == mem[RF[data[7:5]]];
									rflags[AF] <= RF[ins[7:5]] > mem[RF[data[7:5]]];
								end
								CMP_RM_R:begin
									rflags[ZF] <= mem[RF[ins[7:5]]] == RF[data[7:5]];
									rflags[AF] <= mem[RF[ins[7:5]]] > RF[data[7:5]];
								end
								AND_R_R:
									RF[ins[7:5]] <= RF[ins[7:5]] & RF[data[7:5]];
								AND_R_RM:
									RF[ins[7:5]] <= RF[ins[7:5]] & mem[RF[data[7:5]]];
								AND_RM_R:
									mem[RF[ins[7:5]]] <= mem[RF[ins[7:5]]] & RF[data[7:5]];
								OR_R_R:
									RF[ins[7:5]] <= RF[ins[7:5]] | RF[data[7:5]];
								OR_R_RM:
									RF[ins[7:5]] <= RF[ins[7:5]] | mem[RF[data[7:5]]];
								OR_RM_R:
									mem[RF[ins[7:5]]] <= mem[RF[ins[7:5]]] | RF[data[7:5]];
								XOR_R_R:
									RF[ins[7:5]] <= RF[ins[7:5]] ^ RF[data[7:5]];
								XOR_R_RM:
									RF[ins[7:5]] <= RF[ins[7:5]] ^ mem[RF[data[7:5]]];
								XOR_RM_R:
									mem[RF[ins[7:5]]] <= mem[RF[ins[7:5]]] ^ RF[data[7:5]];
								SHR_R_R:
									RF[ins[7:5]] <= RF[ins[7:5]] >> RF[data[7:5]];
								SHR_R_RM:
									RF[ins[7:5]] <= RF[ins[7:5]] >> mem[RF[data[7:5]]];
								SHR_RM_R:
									mem[RF[ins[7:5]]] <= mem[RF[ins[7:5]]] >> RF[data[7:5]];
								SHL_R_R:
									RF[ins[7:5]] <= RF[ins[7:5]] << RF[data[7:5]];
								SHL_R_RM:
									RF[ins[7:5]] <= RF[ins[7:5]] << mem[RF[data[7:5]]];
								SHL_RM_R:
									mem[RF[ins[7:5]]] <= mem[RF[ins[7:5]]] << RF[data[7:5]];
							endcase
						end
						JF_R: begin
							if (rflags[ins[6:5]]==ins[7])
								ip <= RF[data[7:5]];
						end
						JF_RM: begin
							if (rflags[ins[6:5]]==ins[7])
								ip <= mem[RF[data[7:5]]];
						end
					endcase
			    end
			endcase
			if((ins[2:0] != 3'd4 && ins[2:0] != 3'd5) || (rflags[ins[6:5]]!=ins[7] && ins[4:0] != JMP_C)) 
				ip <= ip + 8'b1;
			state <= IDLE;
		end
	endcase
end

assign data_out = rout;

initial begin
	for(i = 0; i <= 7; i = i + 1) begin
		RF[i] = 8'b0;
	end
	$readmemh("output.bin", mem);
end

endmodule
