module alu #(
	parameter DATA_WIDTH = 16
)(
	input [2:0] oc,
	input [DATA_WIDTH-1:0] a,
	input [DATA_WIDTH-1:0] b,
	output reg [DATA_WIDTH-1:0] f
);

	always @(*)
		case (oc)
			3'o0: f = a + b;
			3'o1: f = a - b;
			3'o2: f = a * b;
			3'o3: f = a / b;
			3'o4: f = ~a;
			3'o5: f = a ^ b;
			3'o6: f = a | b;
			3'o7: f = a & b;
			default: f = 4'h0;
  endcase

endmodule