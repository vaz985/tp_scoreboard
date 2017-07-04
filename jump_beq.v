module jump_beq(
	input[31:0] IR,
	input[31:0] a,
	input[31:0] b,
	output reg[25:0] address,
	output reg jump,
	output reg beq
);

always@(IR,a,b) begin

  jump <= ( IR[31:26] == 6'b000010  ) ? 1 : 0 ;  
  beq  <= ( IR[31:26] == 6'b000100 && ( a==b ) ) ? 1 : 0;
  
  if(IR[31:26] == 6'b000010) begin
    address <= IR[16:0];
  end
  else if (IR[31:26] == 6'b000100 && ( a==b )) begin
    address <= IR[16:0];
  end
  else begin
    address <= 0;
  end
end

endmodule