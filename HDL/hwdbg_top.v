`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Sina Karvandi (sina@hyperdbg.org)
// 
// Create Date: 03/06/2024 07:08:39 PM
// Design Name: hwdbg's top module
// Module Name: hwdbg_top
// Project Name: hwdbg 
// Target Devices: zcu104
// Tool Versions: v0.1
// Description: This is the top module file
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top_module #
(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 32
)
(
    /*
     * General input ports
     */
    input wire clk,
    input wire reset_n,
    
    /*
     * AXI slave interface (input to the communication module)
     */
    input  wire                   s00_axis_aclk,
    input  wire                   s00_axis_aresetn,
    input  wire [DATA_WIDTH-1:0]  s00_axis_tdata,
    input  wire [(DATA_WIDTH/8)-1:0] s00_axis_tstrb,
    input  wire                   s00_axis_tvalid,
    output wire                   s00_axis_tready,
    input  wire                   s00_axis_tlast,
    
    /*
     * AXI master interface (output of the communication module)
     */
    input  wire                   m00_axis_aclk,
    input  wire                   m00_axis_aresetn,
    output wire [DATA_WIDTH-1:0]  m00_axis_tdata,
    output wire [(DATA_WIDTH/8)-1:0] m00_axis_tstrb,
    output wire                   m00_axis_tvalid,
    input  wire                   m00_axis_tready,
    output wire                   m00_axis_tlast
);

//
// Include the axis_communication_module definition here
//
wire [ADDR_WIDTH:0] write_address;
wire [ADDR_WIDTH:0] read_address;
wire enable_write_data_from_bram;
wire [DATA_WIDTH-1:0] output_data_to_bram;
wire enable_read_data_from_bram;
wire [DATA_WIDTH-1:0] input_data_from_bram;


//
// Instantiate the axis_communication_module
//
axis_communication_module #(
    .ADDR_WIDTH(ADDR_WIDTH),                  // Set parameter ADDR_WIDTH to 12
    .C_AXIS_TDATA_WIDTH(DATA_WIDTH)           // Set parameter C_AXIS_TDATA_WIDTH to 32
) axis_communication_instance (
    // Connect your top module's clock and reset signals to the corresponding signals of axis_communication_module
    .s00_axis_aclk(s00_axis_aclk),
    .s00_axis_aresetn(s00_axis_aresetn),
    .m00_axis_aclk(m00_axis_aclk),
    .m00_axis_aresetn(m00_axis_aresetn),

    // Connect your top module's AXI slave interface signals to the corresponding signals of axis_communication_module
    .s00_axis_tdata(s00_axis_tdata),
    .s00_axis_tstrb(s00_axis_tstrb),
    .s00_axis_tvalid(s00_axis_tvalid),
    .s00_axis_tlast(s00_axis_tlast),
    .s00_axis_tready(s00_axis_tready),

    // Connect your top module's AXI master interface signals to the corresponding signals of axis_communication_module
    .m00_axis_tdata(m00_axis_tdata),
    .m00_axis_tstrb(m00_axis_tstrb),
    .m00_axis_tvalid(m00_axis_tvalid),
    .m00_axis_tlast(m00_axis_tlast),
    .m00_axis_tready(m00_axis_tready),
    
    // Connect BRAM interface connections
    .write_address(write_address),
    .enable_write_data_from_bram(enable_write_data_from_bram),
    .output_data_to_bram(output_data_to_bram),
    .read_address(read_address),
    .enable_read_data_from_bram(enable_read_data_from_bram),
    .input_data_from_bram(input_data_from_bram)
);

//
// Instantiate the BRAM interface
//
bram_mem_interface #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) bram_mem_interface_instance (
    .clk(clk),
    .reset_n(reset_n),
    .write_address(write_address),
    .enable_write(enable_write_data_from_bram),
    .input_data(output_data_to_bram),
    .read_address(read_address),
    .enable_read(enable_read_data_from_bram),
    .output_data(input_data_from_bram)
);

// Other logic in your top module

endmodule
