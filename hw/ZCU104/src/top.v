`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HyperDbg
// Engineer: Sina Karvandi (sina@hyperdbg.org)
// 
// Create Date: 03/18/2024 06:40:03 PM
// Design Name: Shared BRAM over PS <> PL
// Module Name: top
// Project Name: hwdbg
// Target Devices: ZCU104
// Tool Versions: v0.1
// Description: This project shares 8 KB Block RAM (BRAM) make it accessible over PL <> PS
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top (
    output wire led_out_0,
    output wire led_out_1,
    output wire led_out_2,
    output wire led_out_3
);

// BRAM port A, PS access through software
wire [12:0] bram_porta_0_addr;
wire clk;
wire [31:0] bram_porta_0_din;
wire [31:0] bram_porta_0_dout;
wire bram_porta_0_en;
wire rst;
wire [3:0] bram_porta_0_we;

// BRAM port B, PL access
reg [10:0] bram_portb_0_addr = 11'b0;
reg [31:0] bram_portb_0_din = 32'b0;
wire [31:0] bram_portb_0_dout;
reg bram_portb_0_we = 1'b0;

// LED indicator storage
reg [31:0] led_out_reg = 32'b0;
reg all_addrs_initialized = 1'b0;

// Zyng system black
block_design_wrapper zynq_ps_interface_inst (
    .BRAM_PORTA_0_addr(bram_porta_0_addr),
    .BRAM_PORTA_0_clk(clk),
    .BRAM_PORTA_0_din(bram_porta_0_din),
    .BRAM_PORTA_0_dout(bram_porta_0_dout),
    .BRAM_PORTA_0_en(bram_porta_0_en),
    .BRAM_PORTA_0_rst(rst),
    .BRAM_PORTA_0_we(bram_porta_0_we)
);

// BRAM memory 2K by 32-bit
blk_mem_gen_0 blk_mem_gen_0_inst (
    // Zynga PS access through software
    .clka(clk),
    .ena(bram_porta_0_en),
    .wea(bram_porta_0_we[0]),
    .addra(bram_porta_0_addr[12:2]),
    .dina(bram_porta_0_din),
    .douta(bram_porta_0_dout),
    // PL fabric access
    .clkb(clk),
    .enb(1'b1),
    .web(bram_portb_0_we),
    .addrb(bram_portb_0_addr),
    .dinb(bram_portb_0_din),
    .doutb(bram_portb_0_dout)
);

// Write 32-bit counter data into BRAM
always @(posedge clk) begin
    if (rst) begin
        bram_portb_0_addr <= 11'b0;
        bram_portb_0_din <= 32'b0;
        bram_portb_0_we <= 4'b0;
        led_out_reg <= 32'b0;
        all_addrs_initialized <= 1'b0;
    end else begin
        if (!all_addrs_initialized) begin
            led_out_reg <= 32'b0;
            if (bram_portb_0_addr != 11'h7FF) begin
                bram_portb_0_addr <= bram_portb_0_addr + 1;
                bram_portb_0_din <= bram_portb_0_din + 1;
                bram_portb_0_we <= 4'b1;
            end else begin
                all_addrs_initialized <= 1'b1;
            end
        end else begin
            bram_portb_0_addr <= 11'b0;
            led_out_reg <= bram_portb_0_dout;
            bram_portb_0_we <= 4'b0;
        end
    end
end

// Connect LED signals to FPGA pins
assign led_out_0 = led_out_reg[0];
assign led_out_1 = led_out_reg[1];
assign led_out_2 = led_out_reg[2];
assign led_out_3 = led_out_reg[3];

endmodule