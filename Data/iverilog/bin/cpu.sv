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

//ins[4:3] == 10 Спец
parameter NOP = 3'b000;		
parameter HLT = 3'b001;		
parameter STFZ = 3'b010;
parameter LDFZ = 3'b011;

//ins[4:3] == 00 Однобайтовые
parameter OUT_R = 5'b000;
parameter OUT_RM = 5'b0001;
parameter JMP_R = 5'b100;
parameter JMP_RM =  5'b101;
parameter INC = 5'b010;
parameter DEC = 5'b011;
parameter IN_R = 5'b110;
parameter IN_RM = 5'b111;

//ins[4:3] == 01 Двухбайтовые
parameter MOV = 5'b000;
	parameter MOV_R_R = 5'b001;
	parameter MOV_R_RM = 5'b010;
	parameter MOV_RM_R = 5'b011;
parameter ADD = 5'b001;
	parameter ADD_R_R = 5'b001;
	parameter ADD_R_RM = 5'b010;
	parameter ADD_RM_R = 5'b011; 
parameter SUB = 5'b010;
	parameter SUB_R_R = 5'b001;
	parameter SUB_R_RM = 5'b010;
	parameter SUB_RM_R = 5'b011; 
parameter CMP = 5'b110;
	parameter CMP_R_R = 5'b001;
	parameter CMP_R_RM = 5'b010;
	parameter CMP_RM_R = 5'b011; 
parameter LOG = 5'b111;
	parameter AND_R_R = 5'b001;
	parameter OR_R_R = 5'b010;
	parameter XOR_R_R = 5'b011;
parameter JF_R = 5'b100;
parameter JF_RM = 5'b101;

//ins[4:3] == 11 Трёхбайтовые
parameter MOV_R_C = 5'b000;
parameter MOV_R_CM = 5'b110;
parameter MOV_CM_R = 5'b111;
parameter ADD_R_C = 5'b001;
parameter SUB_R_C = 5'b010;
parameter CMP_R_C = 5'b011;
parameter JF_C = 5'b100;
parameter JF_CM = 5'b101;




//Конченый автомат
always @(posedge clk) begin
	case(state)
		IDLE: begin //Состояние айдл
			if (stop == 0) //Стоп опущен - работаем
				state <= FTHOP;
		end
		FTHOP: begin
			ins <= mem[ip]; //Получаем инструкцию
			if (mem[ip][3]) begin //байт больше чем 1
				ip <= ip + 16'b1;
				state <= FTHD1;
			end
			else //Если однобайтовая - идём выполнять
				state <= EXEC; 
		end
		FTHD1: begin //Получаем второй байт
			data[7:0] <= mem[ip];
			if (ins[4]) begin
				ip <= ip + 16'b1;
				state <= FTHD2;
			end
			state <= EXEC;
		end
		FTHD2: begin //Получаем третий байт
			data[15:8] <= mem[ip];
			state <= EXEC;
		end
		EXEC: begin
			case(ins[4:3])
				2'b00: begin
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
							rin <= 8'hFF;
						end
						IN_RM: begin
							mem[RF[ins[7:5]]] <= data_in;
							rin <= 8'hFF;
						end
					endcase
				end
			    2'b11: begin
			    	case(ins[2:0])
			    		MOV_R_C: 
							RF[ins[7:5]] <= data;
						MOV_R_CM: 
							RF[ins[7:5]] <= {mem[data+1], mem[data]};
						MOV_CM_R: 
							{mem[data+1], mem[data]} <= RF[ins[7:5]];
						ADD_R_C: 
							RF[ins[7:5]] <= RF[ins[7:5]] + data;
						SUB_R_C: 
							RF[ins[7:5]] <= RF[ins[7:5]] - data;
						CMP_R_C:  begin
							rflags[ZF] <= RF[ins[7:5]] == data;
							rflags[AF] <= RF[ins[7:5]] > data;
						end
						JF_C: begin
							if (rflags[ins[6:5]])
								ip <= data;
						end
						JF_CM: begin
							if (rflags[ins[6:5]])
								ip <= {mem[data+1], mem[data]};
						end
					endcase
			    end
			    2'b01: begin
			    	case(ins[2:0])
			    		MOV: begin
							case(data[2:0])
								MOV_R_R:
									RF[ins[7:5]] <= RF[data[7:5]];
								MOV_R_RM:
									RF[ins[7:5]] <= mem[RF[data[7:5]]];
								MOV_RM_R:
									mem[RF[ins[7:5]]] <= RF[data[7:5]];
							endcase
						end
						ADD: begin
							case(data[2:0])
								ADD_R_R:
									RF[ins[7:5]] <= RF[ins[7:5]] + RF[data[7:5]];
								ADD_R_RM:
									RF[ins[7:5]] <= RF[ins[7:5]] + mem[RF[data[7:5]]];
								ADD_RM_R:
									mem[RF[ins[7:5]]] <= mem[RF[ins[7:5]]] + RF[data[7:5]];
							endcase
						end
						SUB: begin
							case(data[2:0])
								SUB_R_R:
									RF[ins[7:5]] <= RF[ins[7:5]] - RF[data[7:5]];
								SUB_R_RM:
									RF[ins[7:5]] <= RF[ins[7:5]] - mem[RF[data[7:5]]];
								SUB_RM_R:
									mem[RF[ins[7:5]]] <= mem[RF[ins[7:5]]] - RF[data[7:5]];
							endcase
						end
						CMP:  begin
							case(data[2:0])
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
							endcase
						end
						LOG:  begin
							case(data[2:0])
								AND_R_R:
									RF[ins[7:5]] <= RF[ins[7:5]] & RF[data[7:5]];
								OR_R_R:
									RF[ins[7:5]] <= RF[ins[7:5]] | RF[data[7:5]];
								XOR_R_R:
									RF[ins[7:5]] <= RF[ins[7:5]] ^ RF[data[7:5]];
							endcase
						end
						JF_R: begin
							if (rflags[ins[6:5]])
								ip <= RF[data[7:5]];
						end
						JF_RM: begin
							if (rflags[ins[6:5]])
								ip <= mem[RF[data[7:5]]];
						end
					endcase
			    end
			endcase
			if(ins[2:0] != 3'd4 || ins[2:0] != 3'd5) 
				ip <= ip + incip;
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
