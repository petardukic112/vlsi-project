module clk_div #(
	parameter DIVISOR = 50_000_000
)(
	input clk,
	input rst_n,
	output out
);
	
	reg out_next, out_reg;
	assign out = out_reg;
	integer cnt_reg, cnt_next;
	
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			cnt_reg <= 0;
			out_reg <= 1'b0;
		end
		else begin
			cnt_reg <= cnt_next;
			out_reg <= out_next;
		end
	end
	
	always @(*) begin
		out_next = out_reg;
		if(cnt_reg >= (DIVISOR - 1)) begin
			cnt_next = 0;
			out_next = ~out_reg;
		end
		else
			cnt_next = cnt_reg + 1;
	end


endmodule