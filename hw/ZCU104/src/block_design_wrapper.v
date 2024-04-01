//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
//Date        : Fri Mar 29 17:05:44 2024
//Host        : DESKTOP-MDN4NRE running 64-bit major release  (build 9200)
//Command     : generate_target block_design_wrapper.bd
//Design      : block_design_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module block_design_wrapper
   (BRAM_PORTA_0_addr,
    BRAM_PORTA_0_clk,
    BRAM_PORTA_0_din,
    BRAM_PORTA_0_dout,
    BRAM_PORTA_0_en,
    BRAM_PORTA_0_rst,
    BRAM_PORTA_0_we,
    pl_ps_interrupt,
    ps_pl_gpio);
  output [12:0]BRAM_PORTA_0_addr;
  output BRAM_PORTA_0_clk;
  output [31:0]BRAM_PORTA_0_din;
  input [31:0]BRAM_PORTA_0_dout;
  output BRAM_PORTA_0_en;
  output BRAM_PORTA_0_rst;
  output [3:0]BRAM_PORTA_0_we;
  input pl_ps_interrupt;
  output [3:0]ps_pl_gpio;

  wire [12:0]BRAM_PORTA_0_addr;
  wire BRAM_PORTA_0_clk;
  wire [31:0]BRAM_PORTA_0_din;
  wire [31:0]BRAM_PORTA_0_dout;
  wire BRAM_PORTA_0_en;
  wire BRAM_PORTA_0_rst;
  wire [3:0]BRAM_PORTA_0_we;
  wire pl_ps_interrupt;
  wire [3:0]ps_pl_gpio;

  block_design block_design_i
       (.BRAM_PORTA_0_addr(BRAM_PORTA_0_addr),
        .BRAM_PORTA_0_clk(BRAM_PORTA_0_clk),
        .BRAM_PORTA_0_din(BRAM_PORTA_0_din),
        .BRAM_PORTA_0_dout(BRAM_PORTA_0_dout),
        .BRAM_PORTA_0_en(BRAM_PORTA_0_en),
        .BRAM_PORTA_0_rst(BRAM_PORTA_0_rst),
        .BRAM_PORTA_0_we(BRAM_PORTA_0_we),
        .pl_ps_interrupt(pl_ps_interrupt),
        .ps_pl_gpio(ps_pl_gpio));
endmodule
