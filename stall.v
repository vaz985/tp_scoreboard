module stall(
  input [31:0] decode,
  input [31:0] execute,
  input [31:0] memory,
  input [31:0] wrback,
  output reg stall
);

wire[5:0] opcode; 
assign opcode = decode[31:26];
wire[4:0] rs;     
assign rs = decode[25:21];
wire[4:0] rt;     
assign rt = decode[20:16];
wire[5:0] funct;  
assign funct = decode[5:0];

always @( decode,  execute,  memory,  wrback) begin
  if(execute[31:26] == 6'b100011) begin
    // R
	 if(opcode == 6'b000000 && ( funct == 100000 || funct == 100010)) begin
	   if( execute[20:16] == rs || execute[20:16] == rt ) begin
		  stall <= 1;
		end
		else begin
	     stall <= 0;
		end
	 end
	 else
	 // addi and load, both only need rs
	 if(opcode == 6'b001000 || opcode == 6'b100011) begin
      if( execute[20:16] == rs ) begin
		  stall <= 1;
		end
		else begin
		  stall <= 0;
		end
	 end
	 else
	 // beq and store, both need rs and rt
	 if(opcode == 6'b000100 || opcode == 6'b101011) begin
	   if( execute[20:16] == rs || execute[20:16] == rt ) begin
		  stall <= 1;
		end
		else begin
		  stall <= 0;
		end
	 end
	 // default
	 else begin
	   stall <= 0;
	 end
	 
  end
  else
  if(memory[31:26] == 6'b100011) begin
    // R
	 if(opcode == 6'b000000 && ( funct == 100000 || funct == 100010)) begin
	   if( memory[20:16] == rs || memory[20:16] == rt ) begin
		  stall <= 1;
		end
		else begin
	     stall <= 0;
		end
	 end
	 else
	 // addi and load, both only need rs
	 if(opcode == 6'b001000 || opcode == 6'b100011) begin
      if( memory[20:16] == rs ) begin
		  stall <= 1;
		end
		else begin
		  stall <= 0;
		end
	 end
	 else
	 // beq and store, both need rs and rt
	 if(opcode == 6'b000100 || opcode == 6'b101011) begin
	   if( memory[20:16] == rs || memory[20:16] == rt ) begin
		  stall <= 1;
		end
		else begin
		  stall <= 0;
		end
	 end
	 // default
	 else begin
	   stall <= 0;
	 end
  end
// no need to check wb?
/* 
  else
  if(wrback[31:26] == 6'b100011) begin
    // R
	 if(opcode == 6'b000000 && ( funct == 100000 || funct == 100010)) begin
	   if( wrback[20:16] == rs || wrback[20:16] == rt ) begin
		  stall <= 1;
		end
		else begin
	     stall <= 0;
		end
	 end
	 else
	 // addi and load, both only need rs
	 if(opcode == 6'b001000 || opcode == 6'b100011) begin
      if( wrback[20:16] == rs ) begin
		  stall <= 1;
		end
		else begin
		  stall <= 0;
		end
	 end
	 else
	 // beq and store, both need rs and rt
	 if(opcode == 6'b000100 || opcode == 6'b101011) begin
	   if( wrback[20:16] == rs || wrback[20:16] == rt ) begin
		  stall <= 1;
		end
		else begin
		  stall <= 0;
		end
	end
	// default
	 else begin
	   stall <= 0;
	 end
  end
*/ 
  else begin
    stall <= 0;
  end
  
end

endmodule