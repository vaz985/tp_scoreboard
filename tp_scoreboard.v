module tp_scoreboard(

	input			CLOCK_50,// Para a placa
	input[3:0]		   KEY,
	output[8:0]		LEDG, // Para a placa
	output[0:6]		HEX0, // Para a placa
	output[0:6]		HEX1, // Para a placa
	output[0:6]		HEX2, // Para a placa
	output[0:6]		HEX3, // Para a placa
	output[0:6]		HEX4, // Para a placa
	output[0:6]		HEX5, // Para a placa
	output[0:6]		HEX6, // Para a placa
	output[0:6]		HEX7 // Para a placa
);

reg [31:0] clk;

// incrementado o contador clk em função do CLOCK_50 (clock de 50 Mhz interno da placa)
always@(posedge CLOCK_50)begin
	clk = clk + 1;
end

wire clock = clk[24];

reg [9:0] PC; // Contador de programa do MIPS
reg [9:0] PC_decode;
reg [9:0] PC_execute;


reg[31:0] decode_IR;
reg[31:0] execute_IR;
reg[31:0] memory_IR;
reg[31:0] wback_IR;

reg[4:0]  ex_dest;
reg[31:0] ex_immediate;
	
reg[4:0]  mem_dest;
reg[31:0] mem_b;

reg[31:0] mem_saidaULA;
reg[31:0] wb_saidaULA;


// BANCO DE REGISTRADORES 2.0
wire [31:0] dado_lido_1; // dado lido do banco de registardores
wire [31:0] dado_lido_2; // dado lido do banco de registardores

wire[4:0] rs_in;
wire[4:0] rt_in;
wire[4:0] rd_in;

wire[31:0] wb_write;
wire[4:0]  wb_dest;
wire wb_enable;
//////////////////////////////////////////////////

// ULA
wire[31:0] saidaULA;
wire[31:0] ex_a;
wire[31:0] ex_b;
/////////////////////////////////////////////////


reg halt;

wire [31:0] out_mem_inst; //saída da memória de instruções
wire [31:0] out_mem_data; //saída da memória de dados


reg      jump_enable;
reg[9:0] jump_dest;

wire rst;

wire[31:0] t0;
wire[31:0] t1;
wire[31:0] t2;
wire[31:0] t3;



displayDecoder H1(
.entrada(t1),
.saida(HEX1)
);
displayDecoder H2(
.entrada(t2),
.saida(HEX2)
);



// instanciando a memória de instruções (ROM)
mem_inst mem_i(
.address(PC),    //Endereco da instrucao
.clock(clock),    
.q(out_mem_inst) //Saida da instrucao
);



// ULA DO EXECUTE
reg[1:0] sb [31:0];

assign ex_a = (
//add/sub
( execute_IR[31:26] == 6'b000000 && ( execute_IR[5:0] == 6'b100000 || execute_IR[5:0] == 6'b100010 ) )
||
//addi
( execute_IR[31:26] == 6'b001000 )
||
//load
( execute_IR[31:26] == 6'b100011 )
||
//beq
( execute_IR[31:26] == 6'b000100 )
||
//jump
( execute_IR[31:26] == 6'b000010 )
||
//store
( execute_IR[31:26] == 6'b101011 )    
)
? ( ( sb[ execute_IR[25:21] ] == 2'b01 || sb[ execute_IR[25:21] ] == 2'b10 ) ? ( (sb[ execute_IR[25:21] ] == 2'b01) ? mem_saidaULA : wb_saidaULA ) : dado_lido_1 ) : 0 ;

assign ex_b = ( 
//add/sub
execute_IR[31:26] == 6'b000000 && ( execute_IR[5:0] == 6'b100000 || execute_IR[5:0] == 6'b100010 ) 
||
//beq
( execute_IR[31:26] == 6'b000100 )
||
//store
( execute_IR[31:26] == 6'b101011 ) 
||
//load
( execute_IR[31:26] == 6'b100011 ) 
) 
? ( ( sb[ execute_IR[20:16] ] == 2'b01 || sb[ execute_IR[20:16] ] == 2'b10 ) ? ( ( sb[ execute_IR[20:16] ] == 2'b01 ) ? mem_saidaULA : wb_saidaULA ) : dado_lido_2 ) : 0 ;

wire[9:0] mem_dest_ula;

ula ula_1(
.IR(execute_IR),
.in_1(ex_a),
.in_2(ex_b),
.in_immediate({{16{execute_IR[15]}}, execute_IR[15:0]}),
.saida(saidaULA),
.mem_dest(mem_dest_ula)
);


// BANCO DE REGISTRADORES 2.0
assign rs_in = (execute_IR[25:21]);
assign rt_in = (execute_IR[31:26] == 6'b001000 || execute_IR[31:26] == 6'b100011) ? execute_IR[15:11] : execute_IR[20:16];

assign wb_enable = ( 
(wback_IR[31:26] == 6'b000000 && ( wback_IR[5:0] == 6'b100000 || wback_IR[5:0] == 6'b100010) )
|| 
(wback_IR[31:26] == 6'b001000)
|| 
(wback_IR[31:26] == 6'b100011)
) 
? 1 : 0 ;

assign wb_dest = ( wback_IR[31:26] == 6'b001000 || wback_IR[31:26] == 6'b100011 )  ? wback_IR[20:16] : wback_IR[15:11] ;
/*
assign wb_write = (
( wback_IR[31:26] == 6'b000000 && ( wback_IR[5:0] == 6'b100000 || wback_IR[5:0] == 6'b100010 )) 
|| wback_IR[31:26] == 6'b001000) 
? wb_saidaULA : out_mem_data; 
*/

banco_de_registradores br(
.reset(rst),
.clock(clock), 
.br_out_R_rs(dado_lido_1), // A
.br_out_R_rt(dado_lido_2),	// B

.br_in_rs_decode(rs_in), //RS
.br_in_rt_decode(rt_in), //RT

.wb_enable(wb_enable),  //Switch de escrita
.br_in_data(wb_saidaULA),  //Dado escrito
.br_in_dest_wb(wb_dest),	//Registrado destino

//DISPLAY
.outdisplay0(t0),
.outdisplay1(t1),
.outdisplay2(t2),
.outdisplay3(t3)

); 
/////////////////////////////////////////////////////////////////////////////////

// MEMORIA DE DADOS

wire mem_enable;
wire[31:0] mem_saida;
wire[31:0] mem_data;
reg[9:0] mm_dest_Reg;

assign mem_enable = ( memory_IR[31:26] == 6'b101011 ) ? 1 : 0 ;
assign mem_data = ( memory_IR[31:26] == 6'b101011 ) ? mem_saidaULA : 0;

mem_data mem_d(
.address(mm_dest_Reg), //Endereco do dado
.clock(clock), 
.data(mem_data),       //Dado escrito
.wren(mem_enable), //Switch de escrita
.q(out_mem_data)    //Dado de saida 
);

// JUMP
wire[25:0] j_address;
wire j_enable;
wire beq_enable;

jump_beq j_b(
.IR(execute_IR),
.a(ex_a),
.b(ex_b),
.address(j_address),
.jump(j_enable),
.beq(beq_enable)
);

wire stall;
stall s(
.decode(decode_IR),
.execute(execute_IR),
.memory(memory_IR),
.wrback(wback_IR),
.stall(stall)
);

assign LEDG[0] = clock;

assign rst = ( KEY[0] == 0 ) ? 1 : 0 ;

integer i;

// Controlador de escrita da memoria de dados

always@(posedge clock) begin
  if(KEY[0] == 0) begin
    decode_IR  <= 32'b0;
    execute_IR <= 32'b0;
    memory_IR  <= 32'b0;
    wback_IR   <= 32'b0;
	 halt       <= 1'b1;
	 PC         <= 10'b0;
	 for (i=0;i<32;i=i+1) begin
		sb[i] <= 0;
	 end
  end
  else if(halt == 1'b1 && KEY[0] == 1) begin
    halt <= 1'b0;
    PC <= PC + 1;
  end	
  else if (KEY[0] == 1) begin
    if(j_enable == 1) begin
		PC <= j_address;
		decode_IR <= 0;
		execute_IR <= 0;
		halt <= 1'b1;
	 end
	 else 
	 if(beq_enable == 1) begin
		PC <= PC_execute + j_address[9:0];
		decode_IR <= 0;
		execute_IR <= 0;
		halt <= 1'b1;
	 end
	 else 
	 if(stall == 0) begin
	   PC <= PC + 1;
		PC_decode <= PC;

      decode_IR <= out_mem_inst;
		execute_IR <= decode_IR; 
	 end
	 else 
	 if(stall == 1) begin
	   PC <= PC;
		PC_decode <= PC_decode;
		decode_IR <= decode_IR;
      execute_IR <= execute_IR; 	
	 end
	 
	 // SB Control
	 if( wback_IR[31:26] == 6'b000000 && ( wback_IR[5:0] == 6'b100000 || wback_IR[5:0] == 6'b100010 ) ) begin
	   sb[ wback_IR[15:11] ] <= 00;
	 end else
	 if( wback_IR[31:26] == 6'b001000 ) begin
	   sb[ wback_IR[20:16] ] <= 00;
	 end
	 
	 //execute
	 if( execute_IR[31:26] == 6'b000000 && ( execute_IR[5:0] == 6'b100000 || execute_IR[5:0] == 6'b100010 ) ) begin
	   sb[ execute_IR[15:11] ] <= 01;
	 end else
    if( execute_IR[31:26] == 6'b001000 ) begin
	   sb[ execute_IR[20:16] ] <= 01;
    end   
	 
    //memory
	 if( memory_IR[31:26] == 6'b000000 && ( memory_IR[5:0] == 6'b100000 || memory_IR[5:0] == 6'b100010 ) ) begin
	   if ( (execute_IR[31:26] == 6'b001000 && execute_IR[15:11] == memory_IR[15:11]) || (execute_IR[31:26] == 6'b001000 && execute_IR[20:16] == memory_IR[15:11]) ) begin
		  sb[ memory_IR[15:11] ] <= 01;
	   end
	   else begin
	     sb[ memory_IR[15:11] ] <= 10;
	   end
	 end else
	 if( memory_IR[31:26] == 6'b001000 ) begin
      if ( (execute_IR[31:26] == 6'b001000 && execute_IR[20:16] == memory_IR[20:16]) || ( (execute_IR[31:26] == 6'b001000 && execute_IR[15:11] == memory_IR[20:16]) ) ) begin
		  sb[ memory_IR[20:16] ] <= 01;
	   end
	   else begin
	     sb[ memory_IR[20:16] ] <= 10;
	   end
	 end
	 ////////////////////////////////////////////////////////////////////
	 
	 PC_execute <= PC_decode;
    memory_IR <= execute_IR;
    wback_IR <= memory_IR;	
  
    mem_saidaULA <= saidaULA;
	 mm_dest_Reg <= mem_dest_ula;
	 if ( memory_IR[31:26] == 6'b100011) begin
	   wb_saidaULA  <= out_mem_data;
	 end
	 else begin
		wb_saidaULA  <= mem_saidaULA;
	 end

  end
//Fim do always
end
  
endmodule
