`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HyperDbg
// Engineer: Sina Karvandi (sina@hyperdbg.org)
// 
// Create Date: 03/07/2024 03:27:12 PM
// Design Name: Block-RAM interface
// Module Name: bram_mem_interface
// Project Name: hwdbg
// Target Devices: zcu104
// Tool Versions: v0.1
// Description: This is the BRAM interface
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bram_mem_interface #
(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 32
)
(
    /*
     * General input ports
     */
    input clk,
    input reset_n,
    
    /*
     * Write input ports
     */
    input [ADDR_WIDTH:0] write_address,
    input enable_write,
    input [DATA_WIDTH-1:0] input_data,
    
    /*
     * Read output ports
     */
    input [ADDR_WIDTH:0] read_address,
    input enable_read,
    output [DATA_WIDTH-1:0] output_data
);

// Target wires and registers
reg [ADDR_WIDTH:0] target_address;


// Instantiate the rams_sp_rom module
rams_sp_rom #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) bram_inst (
    .clk(clk),
    .addr(target_address),
    .we(enable_write),
    .di(input_data),
    .dout(output_data)
);

always @(posedge clk) begin
    if (enable_write) begin
        target_address <= write_address;
    end else begin
        target_address <= read_address;
    end
end

endmodule