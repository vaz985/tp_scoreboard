module ula(
	input[31:0] IR,
	input[31:0] in_1,
	input[31:0] in_2,
	input[31:0] in_immediate,
	output reg[31:0] saida,
	output reg[9:0] mem_dest
);



always@(IR, in_1, in_2, in_immediate) begin

  if ( IR[31:26] == 6'b000000 ) begin
    //add
    if( IR[5:0] == 6'b100000 ) begin
      mem_dest <= 0;
	   saida <= in_1 + in_2;
    end
    //sub
    else if( IR[5:0] == 6'b100010 ) begin
      mem_dest <= 0;
		saida <= in_1 - in_2;
    end
  end
  // addi
  else if( IR[31:26] == 6'b001000 ) begin	 
	 saida <= in_1 + in_immediate;
	 mem_dest <= 0;
  end
  //load
  else if( IR[31:26] == 6'b100011 ) begin
    mem_dest <= IR[20:16];
	 saida <= in_1 + in_immediate;
  end
  //store
  else if( IR[31:26] == 6'b101011 ) begin
    mem_dest <= in_1 + in_immediate;
	 saida <= in_2;
  end
  else begin
    mem_dest <= 0;
	 saida <= 0;
  end
end

endmodule