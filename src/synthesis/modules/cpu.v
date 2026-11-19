module cpu #(
	parameter ADDR_WIDTH = 6,
	parameter DATA_WIDTH = 16
)(
	input clk,
	input rst_n,
	input [DATA_WIDTH-1:0] mem,
	input [DATA_WIDTH-1:0] in,
	output reg we,
	output [ADDR_WIDTH-1:0] addr,
	output reg [DATA_WIDTH-1:0] data,
	output reg [DATA_WIDTH-1:0] out,
	output [ADDR_WIDTH-1:0] pc,
	output [ADDR_WIDTH-1:0] abl
);
	assign abl = state; 

	localparam START = 6'd000000;
	localparam IF1 = 6'd000001;
	localparam IF2 = 6'd000002;
	localparam IF3 = 6'd000003;
	localparam IF4 = 6'd000004;
	localparam SWC = 6'd000005;
	localparam IF2_1 = 6'd000006;
	localparam IF2_2 = 6'd000007;
 	localparam IF2_3 = 6'd000008;
 	localparam IF2_4 = 6'd000009;
 	localparam ID1 = 6'd0000010;
 	localparam LD_OP1_1 = 6'd000011;
 	localparam LD_OP1_2 = 6'd000012;
 	localparam LD_OP1_3 = 6'd000013;
 	localparam LD_OP1_4 = 6'd000014;
 	localparam LD_OP1_5 = 6'd000015;
 	localparam LD_OP1_6 = 6'd000016;
 	localparam LD_OP1_7 = 6'd000017;
	localparam LD_OP2_1 = 6'd000021;
 	localparam LD_OP2_2 = 6'd000022;
 	localparam LD_OP2_3 = 6'd000023;
 	localparam LD_OP2_4 = 6'd000024;
 	localparam LD_OP2_5 = 6'd000025;
 	localparam LD_OP2_6 = 6'd000026;
 	localparam LD_OP2_7 = 6'd000027;
	localparam LD_OP3_1 = 6'd000031;
 	localparam LD_OP3_2 = 6'd000032;
 	localparam LD_OP3_3 = 6'd000033;
 	localparam LD_OP3_4 = 6'd000034;
 	localparam LD_OP3_5 = 6'd000035;
 	localparam LD_OP3_6 = 6'd000036;
 	localparam LD_OP3_7 = 6'd000037;
 	localparam LDW = 6'd000038;
 	localparam S1 = 6'd000039;
 	localparam PRINTX1 = 6'd000040;
 	localparam PRINTY1 = 6'd000041;
 	localparam PRINTZ1 = 6'd000042;
 	localparam E1 = 6'd000050; 
 	localparam E2 = 6'd000051;
 	localparam EOUT = 6'd000052;
 	localparam EF = 6'd000053;
 	localparam IN_STATE = 6'd000060;
 	localparam END_STATE = 6'd000061;
	
	localparam MOV = 4'b0000;
	localparam ADD = 4'b0001;
	localparam SUB = 4'b0010;
	localparam MUL = 4'b0011;
	localparam DIV = 4'b0100;
	localparam IN  = 4'b0111;
	localparam OUT = 4'b1000;
	localparam STOP = 4'b1111;
	localparam BEQ = 4'b0101;
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	reg	[ADDR_WIDTH-1:0]  in_PC;
	reg [ADDR_WIDTH-1:0]  in_SP;
	reg [31:0] 			  in_IR;
	reg [ADDR_WIDTH-1:0]  in_MAR;
	reg [DATA_WIDTH-1:0]  in_A;
	reg [DATA_WIDTH-1:0]  in_X;
	reg [DATA_WIDTH-1:0]  in_Y;
	reg [DATA_WIDTH-1:0]  in_Z;
	reg [DATA_WIDTH-1:0]  in_W;

	reg cl_PC, 	ld_PC,  inc_PC, 	dec_PC, 	sr_PC,  ir_PC,  sl_PC,  il_PC;
	reg cl_SP, 	ld_SP, 	inc_SP, 	dec_SP, 	sr_SP,  ir_SP,  sl_SP,  il_SP;
	reg cl_IR, 	ld_IR, 	inc_IR, 	dec_IR, 	sr_IR,  ir_IR,  sl_IR,  il_IR;
	reg cl_MAR, ld_MAR, inc_MAR, 	dec_MAR, 	sr_MAR, ir_MAR, sl_MAR, il_MAR;
	reg cl_MDR, ld_MDR, inc_MDR, 	dec_MDR, 	sr_MDR, ir_MDR, sl_MDR, il_MDR;
	reg cl_A, 	ld_A, 	inc_A, 		dec_A, 		sr_A,   ir_A,   sl_A,   il_A;
	reg cl_X, 	ld_X, 	inc_X, 		dec_X, 		sr_X,  	ir_X,   sl_X,   il_X;
	reg cl_Y, 	ld_Y,   inc_Y, 		dec_Y, 		sr_Y,  	ir_Y,   sl_Y,   il_Y;
	reg cl_Z, 	ld_Z, 	inc_Z, 		dec_Z, 		sr_Z,  	ir_Z,   sl_Z,   il_Z;
	reg cl_W, 	ld_W, 	inc_W, 		dec_W, 		sr_W,  	ir_W,   sl_W,   il_W;

	
	wire [31:0] out_IR;
	wire [DATA_WIDTH-1:0] out_A, out_MDR;
	
	wire [DATA_WIDTH-1:0] out_X, out_Y, out_Z, out_W;
	wire [DATA_WIDTH-1:0] out_ALU;
	wire [2:0] operation_code;
	assign operation_code = out_IR[14:12] - 3'b001;
	
	wire [3:0] opcode;
	assign opcode = out_IR[15:12]; 
	
	reg [5:0] state, next_state;

	reg [DATA_WIDTH-1:0] out_next;

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	register #(.DATA_WIDTH(ADDR_WIDTH)) PC (.clk(clk), .rst_n(rst_n), .cl(cl_PC), .ld(ld_PC), .in(in_PC), 
														 .inc(inc_PC), .dec(dec_PC), .sr(sr_PC), .ir(ir_PC), .sl(sl_PC), .il(il_PC), .out(pc));
	
	register #(.DATA_WIDTH(ADDR_WIDTH)) SP (.clk(clk), .rst_n(rst_n), .cl(cl_SP), .ld(ld_SP), .in(in_SP), 
														 .inc(inc_SP), .dec(dec_SP), .sr(sr_SP), .ir(ir_SP), .sl(sl_SP), .il(il_SP), .out(sp));
	
	register #(.DATA_WIDTH(32)) IR (.clk(clk), .rst_n(rst_n), .cl(cl_IR), .ld(ld_IR), .in(in_IR), 
														 .inc(inc_IR), .dec(dec_IR), .sr(sr_IR), .ir(ir_IR), .sl(sl_IR), .il(il_IR), .out(out_IR));	
														 
	register #(.DATA_WIDTH(ADDR_WIDTH)) MAR (.clk(clk), .rst_n(rst_n), .cl(cl_MAR), .ld(ld_MAR), .in(in_MAR), 
														 .inc(inc_MAR), .dec(dec_MAR), .sr(sr_MAR), .ir(ir_MAR), .sl(sl_MAR), .il(il_MAR), .out(addr));
			
	register #(.DATA_WIDTH(DATA_WIDTH)) MDR (.clk(clk), .rst_n(rst_n), .cl(cl_MDR), .ld(ld_MDR), .in(mem), 
														 .inc(inc_MDR), .dec(dec_MDR), .sr(sr_MDR), .ir(ir_MDR), .sl(sl_MDR), .il(il_MDR), .out(out_MDR));	
														 
	register #(.DATA_WIDTH(DATA_WIDTH)) A (.clk(clk), .rst_n(rst_n), .cl(cl_A), .ld(ld_A), .in(in_A), 
														 .inc(inc_A), .dec(dec_A), .sr(sr_A), .ir(ir_A), .sl(sl_A), .il(il_A), .out(out_A));														 
	
	register #(.DATA_WIDTH()) X (.clk(clk), .rst_n(rst_n), .cl(cl_X), .ld(ld_X), .in(in_X),
														 .inc(inc_X), .dec(dec_X), .sr(sr_X), .ir(ir_X), .sl(sl_X), .il(il_X), .out(out_X));
	
	register #(.DATA_WIDTH()) Y (.clk(clk), .rst_n(rst_n), .cl(cl_Y), .ld(ld_Y), .in(in_Y),
														 .inc(inc_Y), .dec(dec_Y), .sr(sr_Y), .ir(ir_Y), .sl(sl_Y), .il(il_Y), .out(out_Y));
	
	register #(.DATA_WIDTH()) Z (.clk(clk), .rst_n(rst_n), .cl(cl_Z), .ld(ld_Z), .in(in_Z),
														 .inc(inc_Z), .dec(dec_Z), .sr(sr_Z), .ir(ir_Z), .sl(sl_Z), .il(il_Z), .out(out_Z));
	
	register #(.DATA_WIDTH()) W (.clk(clk), .rst_n(rst_n), .cl(cl_W), .ld(ld_W), .in(in_W),
														 .inc(inc_W), .dec(dec_W), .sr(sr_W), .ir(ir_W), .sl(sl_W), .il(il_W), .out(out_W));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	alu #(.DATA_WIDTH(DATA_WIDTH)) alu_unit (.oc(operation_code), .a(out_Y), .b(out_Z), .f(out_ALU));
	
	
	//TODO ADD VALUES FOR: IF1, IF2, ... reg1, reg2, ... MOV, BEQ, ...
	reg [31:0] temp_IR;
	
	always @(*) begin
		next_state = state;
		
		cl_PC = 0; 	ld_PC = 0; 	inc_PC  = 0; dec_PC = 0;  sr_PC = 0;  ir_PC = 0;  sl_PC = 0;  il_PC = 0;
		cl_SP = 0; 	ld_SP = 0;  inc_SP = 0;  dec_SP = 0;  sr_SP = 0;  ir_SP = 0;  sl_SP = 0;  il_SP = 0;
		cl_IR = 0; 	ld_IR = 0;  inc_IR = 0;  dec_IR = 0;  sr_IR = 0;  ir_IR = 0;  sl_IR = 0;  il_IR = 0;
		cl_MAR = 0; ld_MAR = 0; inc_MAR = 0; dec_MAR = 0; sr_MAR = 0; ir_MAR = 0; sl_MAR = 0; il_MAR = 0;
		cl_MDR = 0; ld_MDR = 0; inc_MDR = 0; dec_MDR = 0; sr_MDR = 0; ir_MDR = 0; sl_MDR = 0; il_MDR = 0;
		cl_A = 0; 	ld_A = 0; 	inc_A = 0; 	 dec_A = 0;   sr_A = 0;   ir_A = 0;   sl_A = 0;   il_A = 0;
		cl_X = 0; 	ld_X = 0; 	inc_X = 0; 	 dec_X = 0;   sr_X = 0;   ir_X = 0;   sl_X = 0;   il_X = 0;
		cl_Y = 0; 	ld_Y = 0; 	inc_Y = 0; 	 dec_Y = 0;   sr_Y = 0;   ir_Y = 0;   sl_Y = 0;   il_Y = 0;
		cl_Z = 0; 	ld_Z = 0; 	inc_Z = 0; 	 dec_Z = 0;   sr_Z = 0;   ir_Z = 0;   sl_Z = 0;   il_Z = 0;
		cl_W = 0; 	ld_W = 0; 	inc_W = 0; 	 dec_W = 0;   sr_W = 0;   ir_W = 0;   sl_W = 0;   il_W = 0;

		
		in_PC = {ADDR_WIDTH{1'b0}};
		in_SP = {ADDR_WIDTH{1'b0}};
		in_IR = {32{1'b0}};
		in_MAR = {ADDR_WIDTH{1'b0}};
		in_A = {DATA_WIDTH{1'b0}};
		in_X = {DATA_WIDTH{1'b0}};
		in_Y = {DATA_WIDTH{1'b0}};
		in_Z = {DATA_WIDTH{1'b0}};
		in_W = {DATA_WIDTH{1'b0}};
		
		out_next = out;

		we = 1'b0;
		
		temp_IR = 32'h00000000;
		
		case(state) 
			START: begin
				in_PC = {{(ADDR_WIDTH - 4){1'b0}}, 4'h8};
				ld_PC = 1'b1;
				in_SP = {ADDR_WIDTH{1'b1}};
				ld_SP = 1'b1;
				cl_MAR = 1'b1;
				cl_MDR = 1'b1;
				cl_IR = 1'b1;
				cl_A = 1'b1;
				next_state = IF1; 
			end
			
			IF1: begin // INSTRUCTION FETCH
				in_MAR = pc;
				ld_MAR = 1'b1;
				inc_PC = 1'b1;
				next_state = IF2;
			end
			IF2: begin
				next_state = IF3;
			end
			IF3: begin
				ld_MDR = 1'b1; 
				next_state = IF4;
			end
			IF4: begin 
				in_IR = out_MDR;
				ld_IR = 1'b1;
				next_state = SWC;
			end
			
			SWC: begin // CHECK IF FETCHING THE SECOND WORD IS NEEDED
				if(out_IR[15:12] == MOV && out_IR[3:0] == 4'h8)
					next_state = IF2_1;
				else if (out_IR[15:12] == BEQ && out_IR[3:0] == 4'h8)
					next_state = IF2_1;
				else 
					next_state = ID1;
			end
			
			IF2_1: begin // FETCHING SECOND WORD
				in_MAR = pc;
				ld_MAR = 1'b1;
				inc_PC = 1'b1;
				next_state = IF2_2;			
			end
			IF2_2: begin
				next_state = IF2_3;
			end
			IF2_3: begin
				ld_MDR = 1'b1;
				next_state = IF2_4;
			end
			IF2_4: begin
				temp_IR	 = out_IR;
				temp_IR[31:16] = out_MDR;
				in_IR = temp_IR;
				ld_IR = 1'b1;
				next_state = ID1;
			end
			
			ID1: begin // INSTRUCTION DECODE 
				
				case(opcode) 
					MOV: begin
						if(out_IR[3:0] == 4'h0)
							next_state = LD_OP2_1;
						else if(out_IR[3:0] == 4'h8)
							next_state = LD_OP1_1;
						else 
							next_state = IF1;
					end
					ADD,
					SUB,
					MUL: begin
						next_state = LD_OP2_1;
					end
					DIV: begin
						next_state = IF1;
					end
					IN: begin
						next_state = IN_STATE;
					end
					OUT: begin
						next_state = LD_OP1_1;
					end
					STOP: begin
						next_state = LD_OP2_1;
					end
					BEQ: begin
					end
					default: begin
						next_state = IF1;
					end
				endcase
			end
			
			IN_STATE: begin
				in_Y = in;
				ld_Y = 1'b1;
				next_state = LD_OP1_1;
			end
			
			LD_OP2_1: begin // LOADING Y
				in_MAR = out_IR[6:4];
				ld_MAR = 1'b1;
				next_state = LD_OP2_2;
			end
			LD_OP2_2: begin
				next_state = LD_OP2_3;
			end
			LD_OP2_3: begin
				ld_MDR = 1'b1;
				in_Y = mem;
				ld_Y = 1'b1;
				next_state = LD_OP2_4;
			end
			LD_OP2_4: begin
				if(out_IR[7]) begin
					in_MAR = out_Y;
					ld_MAR = 1'b1;
					next_state = LD_OP2_5;
				end
				next_state = LD_OP2_7;
		    end
			LD_OP2_5: begin
				next_state = LD_OP2_6;
			end
			LD_OP2_6: begin
				ld_MDR = 1'b1;
				in_Y = mem;
				ld_Y = 1'b1;
				next_state = LD_OP2_7;
			end
			LD_OP2_7: begin
				case(opcode) 
					MOV: next_state = LD_OP1_1;
					ADD,
					SUB,
					MUL: next_state = LD_OP3_1;
					STOP: next_state = LD_OP1_1;
					default: next_state = IF1;
				endcase
			end
			
			LD_OP1_1: begin // LOADING X
				in_MAR = out_IR[10:8];
				ld_MAR = 1'b1;
				next_state = LD_OP1_2;
			end
			LD_OP1_2: begin
				next_state = LD_OP1_3;
			end
			LD_OP1_3: begin
				ld_MDR = 1'b1;
				in_X = mem;
				ld_X = 1'b1;
				next_state = LD_OP1_4;
			end
			LD_OP1_4: begin
				if(out_IR[11]) begin
					in_MAR = out_X;
					ld_MAR = 1'b1;
					next_state = LD_OP1_5;
				end
				next_state = LD_OP1_7;
			end
			LD_OP1_5: begin
				next_state = LD_OP1_6;
			end
			LD_OP1_6: begin
				ld_MDR = 1'b1;
				in_X = mem;
				ld_X = 1'b1;
				next_state = LD_OP1_7;
			end
			LD_OP1_7: begin
				if (opcode == MOV && out_IR[3:0] == 4'h8)
					next_state = E1;
				else if (opcode == MOV && out_IR[3:0] == 4'h0)
					next_state = E2;
				else if (opcode == OUT)
					next_state = EOUT;
				else if (opcode == IN)
					next_state = E2;
				else if (opcode == ADD || opcode == SUB || opcode == MUL)
					next_state = EF;
				else if  (opcode == STOP)
					next_state = LD_OP3_1;
			end
		
			LD_OP3_1: begin // LOADING Z
				in_MAR = out_IR[2:0];
				ld_MAR = 1'b1;
				next_state = LD_OP3_2;
			end
			LD_OP3_2: begin
				next_state = LD_OP3_3;
			end
			LD_OP3_3: begin
				ld_MDR = 1'b1;
				in_Z = mem;
				ld_Z = 1'b1;
				next_state = LD_OP3_4;
			end
			LD_OP3_4: begin
				if(out_IR[3]) begin
					in_MAR = out_Z;
					ld_MAR = 1'b1;
					next_state = LD_OP3_5;
				end
				next_state = LD_OP3_7;
			end
			LD_OP3_5: begin
				next_state = LD_OP3_6;
			end
			LD_OP3_6: begin
				ld_MDR = 1'b1;
				in_Z = mem;
				ld_Z = 1'b1;
				next_state = LD_OP3_7;
			end
			LD_OP3_7: begin
				case(opcode)
					ADD,
					SUB,
					MUL: next_state = LDW;
					STOP: next_state = S1;
					default: next_state = IF1;
				endcase
			end
			
			LDW: begin
				in_W = out_ALU;
				ld_W = 1'b1;
				next_state = LD_OP1_1;
			end
			
			S1: begin // STOP
				if (out_IR[11:8] != 4'h0)
					next_state = PRINTX1;
				else if (out_IR[7:4] != 4'h0)
					next_state = PRINTY1;
				else if (out_IR[3:0] != 4'h0)
					next_state = PRINTZ1;
				else 
					next_state = END_STATE;
			end
			
			PRINTX1: begin
				out_next = out_X;
				if (out_IR[7:4] != 4'h0)
					next_state = PRINTY1;
				else if (out_IR[3:0] != 4'h0)
					next_state = PRINTZ1;
				else 
					next_state = END_STATE;
			end
			PRINTY1: begin
				out_next = out_Y;
				if (out_IR[3:0] != 4'h0)
					next_state = PRINTZ1;
				else
					next_state = END_STATE;
			end
			PRINTZ1: begin
				out_next = out_Z;
				next_state = END_STATE;
			end
			
			E1: begin
				in_W = out_IR[31:16];
				ld_W = 1'b1;
				next_state = EF;
			end
			E2: begin
				in_W = out_Y;
				ld_W = 1'b1;
				next_state = EF;
			end
			EOUT: begin
				out_next = out_X;
				next_state = IF1;
			end
			EF: begin
				data = out_W;
				we = 1'b1;
				next_state = IF1;
			end
			
			END_STATE: begin
				next_state = END_STATE;
			end
		
		endcase
	end

	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			state <= START;
			out <= 0;
		end
		else begin
			state <= next_state;
			out <= out_next;
		end
	end


endmodule