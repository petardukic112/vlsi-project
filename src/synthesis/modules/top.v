module top #(
    parameter DIVISOR = 50_000_000,
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
)
(
    input clk,
    input rst_n,
    input [2:0] btn,
    input [8:0] sw,
    output [9:0] led,
    output [27:0] hex
);

    wire debounced_rst_n;

    debouncer RST_N_DEBOUNCER(
        .clk(clk), .rst_n(1'b1), .in(rst_n), .out(debounced_rst_n)
    );

    wire [4:0] in;

    genvar i;

    generate

        for (i = 0; i < 4; i = i + 1) begin: sw_init
            debouncer dbc(
                .clk(clk), .rst_n(debounced_rst_n), .in(sw[i]), .out(in[i])
            );
        end

    endgenerate

    //assign led[8:5] = in;

    wire slow_clk;

    clk_div#(.DIVISOR(DIVISOR)) CLK_DIV (
        .clk(clk), .rst_n(debounced_rst_n), .out(slow_clk)
    );

    assign led[9] = slow_clk;

    wire we;
    wire [ADDR_WIDTH - 1:0] addr;
    wire [DATA_WIDTH - 1:0] data, mem;

    

    memory #(.FILE_NAME(FILE_NAME), .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) MEMORY (
        .clk(slow_clk), .we(we), .addr(addr), .data(data), .out(mem)
    );

    wire [ADDR_WIDTH - 1:0] pc, sp, pc_output;

    cpu #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) CPU (
        .clk(slow_clk), .rst_n(debounced_rst_n),
        .mem(mem), .in(in), .we(we),
        .addr(addr), .data(data),
        .out(led[4:0]),
        .pc(pc), .abl(sp) //////////////////////
    );

    assign pc_output = pc == 0 ? 0 : pc - 1;

    wire [3:0] pc_ones, pc_tens, sp_ones, sp_tens;

    

    bcd PC_BCD(
        .in(pc_output), .ones(pc_ones), .tens(pc_tens)
    );

    bcd SP_BCD(
        .in(sp), .ones(sp_ones), .tens(sp_tens)
    );

    ssd PC_ONES_SSD (
        .in(pc_ones), .out(hex[6:0])
    );

    ssd PC_TENS_SSD (
        .in(pc_tens), .out(hex[13:7])
    );
    
    ssd SP_ONES_SSD (
        .in(sp_ones), .out(hex[20:14])
    );
    
    ssd SP_TENS_SSD (
        .in(sp_tens), .out(hex[27:21])
    );

    

endmodule