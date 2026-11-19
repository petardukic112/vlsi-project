module register #(
	parameter DATA_WIDTH = 16
)(
  input clk,
  input rst_n,
  input cl,
  input ld,
  input [DATA_WIDTH-1:0] in,
  input inc,
  input dec,
  input sr,
  input ir,
  input sl,
  input il,
  output [DATA_WIDTH-1:0] out
);
  
  reg [DATA_WIDTH-1:0] q_reg, q_next;
  assign out = q_reg;
  
  always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
      q_reg <= {DATA_WIDTH{1'b0}};
    else
      q_reg <= q_next;
  end
  
  always @(*) begin
    q_next = q_reg;
    if (cl)
      q_next = {DATA_WIDTH{1'b0}};
    else if (ld)
      q_next = in;
    else if (inc)	
      q_next = q_reg + { {(DATA_WIDTH-1){1'b0}}, 1'b1 };
    else if (dec)
      q_next = q_reg - { {(DATA_WIDTH-1){1'b0}}, 1'b1 };
    else if (sr) 
			q_next = {ir, q_reg[DATA_WIDTH-1:1]}; 
	  else if (sl)
			q_next = {q_reg[DATA_WIDTH-2:0], il};
   end  
endmodule
