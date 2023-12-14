module SimpleProcessor(
	input wire clk,
	input wire rst,
	input wire [31:0] data_in,
	output wire [31:0] data_out
);

integer i;
reg [7:0] RF [0:7]; //Регистры

//Регистры ввода и вывода, потом поменяю
reg [7:0] rout = 8'b0; 
reg [7:0] rin = 8'b0;

//Регистры для работы с памятью
reg [7:0] mem [0:65535]; //Сама память
reg [15:0] ip = 8'b0;    //Указатель инструкции
reg [7:0] ins = 8'b0;    //Сама инструкция
reg [7:0] data = 8'b0;   //Доп поле данных
reg [7:0] exdata = 8'b0; //Расширенные данные, возможно не используются

//Конечный автомат
reg [2:0] state = IDLE; //Текущее состояние
reg stop = 0;           //Флаг остановки
reg incip = 1;          //Флаг инкремента

//Флаги
reg [2:0] rflags = 4'b00; //Сам Регистр
	parameter ZF = 2'b00; //адрес флага равенство
	parameter AF = 2'b01; //адрес флага больше
 
//Описание состояний конечного автомата
parameter IDLE = 3'b00;  //Айдл
parameter FTHOP = 3'b01; //Получение операции 
parameter FTHD = 3'b10;  //Получение данных
parameter EXEC = 3'b11;  //Выполнение

parameter OUT_R = 8'h00;
parameter OUT_RM = 8'h01;
parameter JMP_R = 8'h2;
parameter JMP_RM = 8'h3;
parameter INC = 8'h04;
parameter DEC = 8'h05;
parameter IN_R = 8'h06;
parameter IN_RM = 8'h07;
parameter ZOI = 8'h08;
	parameter NOP = 3'b000;		//05
	parameter HLT = 3'b001;		//25
	parameter STFZ = 3'b010;
	parameter LDFZ = 3'b011;
parameter INS_C = 8'h09;
	parameter OUT_C = 3'b000;
	parameter OUT_CM = 3'b001;
	parameter JMP_C = 3'b010;
	parameter JMP_CM = 3'b011;
	parameter IN_CM = 3'b100;
parameter INS_R_R = 8'h0A;
	parameter MOV_R_R = 8'h01;
	parameter MOV_R_RM = 8'h02;
	parameter MOV_RM_R = 8'h03;
	parameter ADD_R_R = 8'h04;
	parameter ADD_R_RM = 8'h05;
	parameter ADD_RM_R = 8'h06;
	parameter SUB_R_R = 8'h07;
	parameter SUB_R_RM = 8'h08;
	parameter SUB_RM_R = 8'h09;
	parameter CMP_R_R = 8'h0A;
	parameter CMP_R_RM = 8'h0B;
	parameter CMP_RM_R = 8'h0C;
	parameter JF_R = 8'h0D;
	parameter JF_RM = 8'h0E;
parameter MOV_R_C = 8'h0B;
parameter MOV_R_CM = 8'h0C;
parameter MOV_CM_R = 8'h0D;
parameter ADD_R_C = 8'h0E;
parameter ADD_R_CM = 8'h0F;
parameter ADD_CM_R = 8'h10;
parameter SUB_R_C = 8'h11;
parameter SUB_R_CM = 8'h12;
parameter SUB_CM_R = 8'h13;
parameter CMP_R_C = 8'h14;
parameter CMP_R_CM = 8'h15;
parameter CMP_CM_R = 8'h16;
parameter JF_C = 8'h17;
parameter JF_CM = 8'h18;


//Описание работы
always @(posedge clk) begin
	incip = 1; //Установка флага инкремента в 1

	//Конечный автомат
	case(state)
		IDLE: begin //Состояние покоя
			if (stop == 0)  //Если остановки нет, то работаем
				state <= FTHOP;
		end
		FTHOP: begin
			ins <= mem[ip]; //Получение инструкции
			if (mem[ip][4:0] > ZOI[4:0] || mem[ip] == JMP_RM || mem[ip] == JMP_R) begin
				ip <= ip + 16'b1;
				state <= FTHD;
			end
			else begin
				state <= EXEC;
			end
		end
		FTHD: begin
			data <= mem[ip];
			state <= EXEC;
		end
		EXEC: begin
			case(ins[4:0])
				ZOI: begin
					case(ins[7:5])
						NOP: 
							state <= IDLE;
						HLT:
							stop <= 1;
							state <= IDLE;
						STFZ:
							RF[0] <= rflags;
						LDFZ:
							rflags <= RF[0];
					endcase
				end
				OUT_R: 
					rout <= RF[ins[7:5]];
				OUT_RM: 
					rout <= mem[RF[ins[7:5]]];
				INC: 
					RF[ins[7:5]] <= RF[ins[7:5]] + 8'b1;
				DEC: 
					RF[ins[7:5]] <= RF[ins[7:5]] - 8'b1;
				MOV_R_C: 
					RF[ins[7:5]] <= data;
				MOV_R_CM: 
					RF[ins[7:5]] <= mem[data];
				MOV_CM_R: 
					mem[data] <= RF[ins[7:5]];
				ADD_R_C: 
					RF[ins[7:5]] <= RF[ins[7:5]] + data;
				ADD_R_CM: 
					RF[ins[7:5]] <= RF[ins[7:5]] + mem[data];
				ADD_CM_R: 
					mem[data] <= mem[data] + RF[ins[7:5]];
				SUB_R_C: 
					RF[ins[7:5]] <= RF[ins[7:5]] - data;
				SUB_R_CM: 
					RF[ins[7:5]] <= RF[ins[7:5]] - mem[data];
				SUB_CM_R: 
					mem[data] <= mem[data] - RF[ins[7:5]];
				CMP_R_C:begin
					rflags[ZF] <= RF[ins[7:5]] == data;
					rflags[AF] <= RF[ins[7:5]] > data;
				end
				CMP_R_CM:begin
					rflags[ZF] <= RF[ins[7:5]] == mem[data];
					rflags[AF] <= RF[ins[7:5]] > mem[data];
				end
				CMP_CM_R:begin
					rflags[ZF] <= mem[data] == RF[ins[7:5]];
					rflags[AF] <= mem[data] > RF[ins[7:5]];
				end
				JMP_R:begin
					incip = 0;
					ip <= {RF[0], RF[ins[7:5]]}; //Добавил переход по шине из регистра ноль и по выбору
				end
				JMP_RM:begin
					incip = 0;
					ip <= {RF[0], mem[RF[ins[7:5]]]}; //Добавил переход по шине из регистра ноль и памяти
				end
				INC:
					RF[ins[7:5]] <= RF[ins[7:5]] + 8'b1;
				DEC:
					RF[ins[7:5]] <= RF[ins[7:5]] - 8'b1;
				JF_C: begin
					ip <= {RF[0], data}; //Добавил переход по шине из регистра ноль и доп данных
					incip = !(rflags[ins[6:5]] == ins[7]);
				end
				JF_CM: begin
					ip <= {RF[0], mem[data]}; //Добавил переход по шине из регистра ноль и памяти по адр. доп данных
					incip = !(rflags[ins[6:5]] == ins[7]);
				end
				IN_R:begin
					RF[ins[7:5]] <= data_in;
					rin <= 8'hFF;
				end
				IN_RM:begin
					mem[RF[ins[7:5]]] <= data_in;
					rin <= 8'hFF;
				end
				INS_C: 
					case(ins[7:5])
						OUT_C:
							rout <= data;
						OUT_CM: 
							rout <= mem[data];
						JMP_CM:begin
							incip = 0;
							ip <= {RF[0], mem[data]}; //Аналогично
						end
						JMP_C:begin
							incip = 0;
							ip <= {RF[0], data}; //Аналогично
						end
						IN_CM:begin
							mem[data] <= data_in;
							rin <= 8'hFF;
						end
					endcase
				INS_R_R:begin
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
						JF_R: begin
							ip <= {RF[0], RF[data[7:5]]};
							incip = !(rflags[ins[6:5]] == ins[7]);
						end
						JF_RM: begin
							ip <= {RF[0], mem[RF[data[7:5]]]};
							incip = !(rflags[ins[6:5]] == ins[7]);
						end
					endcase
				end
			endcase
			if(incip == 1) 
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
