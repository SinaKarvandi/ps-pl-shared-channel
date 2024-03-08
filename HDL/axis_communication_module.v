/*

Copyright (c) 2014-2017 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Modified by Jeff Johnson http://www.fpgadeveloper.com

- Renamed ports to match Vivado's naming for AXI-Streaming slave and master
- Removed the async reset input to the module
- Added separate resets for slave and master interfaces
- Removed the tuser signals (not used by Vivado)


Modified by Sina Karvandi (sina@hyperdbg.org)
- Made it compatible with hwdbg debugger

*/

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * AXI4-Stream asynchronous communication module
 */
module axis_communication_module #
(
    parameter ADDR_WIDTH = 12,
    parameter C_AXIS_TDATA_WIDTH = 32
)
(
    /*
     * AXI slave interface (input to the communication module)
     */
    input  wire                   s00_axis_aclk,
    input  wire                   s00_axis_aresetn,
    input  wire [C_AXIS_TDATA_WIDTH-1:0]  s00_axis_tdata,
    input  wire [(C_AXIS_TDATA_WIDTH/8)-1:0] s00_axis_tstrb,
    input  wire                   s00_axis_tvalid,
    output wire                   s00_axis_tready,
    input  wire                   s00_axis_tlast,
    
    /*
     * AXI master interface (output of the communication module)
     */
    input  wire                   m00_axis_aclk,
    input  wire                   m00_axis_aresetn,
    output wire [C_AXIS_TDATA_WIDTH-1:0]  m00_axis_tdata,
    output wire [(C_AXIS_TDATA_WIDTH/8)-1:0] m00_axis_tstrb,
    output wire                   m00_axis_tvalid,
    input  wire                   m00_axis_tready,
    output wire                   m00_axis_tlast,
    
    /*
     * BRAM read/write 
     */
    output wire [ADDR_WIDTH:0] write_address,
    output wire enable_write_data_from_bram,
    output wire [C_AXIS_TDATA_WIDTH-1:0] output_data_to_bram,
    output wire [ADDR_WIDTH:0] read_address,
    output wire enable_read_data_from_bram,
    input  wire [C_AXIS_TDATA_WIDTH-1:0] input_data_from_bram
);

reg [ADDR_WIDTH:0] wr_ptr_reg = {ADDR_WIDTH+1{1'b0}}, wr_ptr_next;
reg [ADDR_WIDTH:0] wr_ptr_gray_reg = {ADDR_WIDTH+1{1'b0}}, wr_ptr_gray_next;
reg [ADDR_WIDTH:0] wr_addr_reg = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr_reg = {ADDR_WIDTH+1{1'b0}}, rd_ptr_next;
reg [ADDR_WIDTH:0] rd_ptr_gray_reg = {ADDR_WIDTH+1{1'b0}}, rd_ptr_gray_next;
reg [ADDR_WIDTH:0] rd_addr_reg = {ADDR_WIDTH+1{1'b0}};

reg [ADDR_WIDTH:0] wr_ptr_gray_sync1_reg = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] wr_ptr_gray_sync2_reg = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr_gray_sync1_reg = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr_gray_sync2_reg = {ADDR_WIDTH+1{1'b0}};

reg s00_rst_sync1_reg = 1'b1;
reg s00_rst_sync2_reg = 1'b1;
reg s00_rst_sync3_reg = 1'b1;
reg m00_rst_sync1_reg = 1'b1;
reg m00_rst_sync2_reg = 1'b1;
reg m00_rst_sync3_reg = 1'b1;

// reg [C_AXIS_TDATA_WIDTH+2-1:0] mem[(2**ADDR_WIDTH)-1:0];
reg [C_AXIS_TDATA_WIDTH+2-1:0] mem_read_data_reg = {C_AXIS_TDATA_WIDTH+2{1'b0}};
reg mem_read_data_valid_reg = 1'b0, mem_read_data_valid_next;
wire [C_AXIS_TDATA_WIDTH+2-1:0] mem_write_data;

reg [C_AXIS_TDATA_WIDTH+2-1:0] m00_data_reg = {C_AXIS_TDATA_WIDTH+2{1'b0}};

reg m00_axis_tvalid_reg = 1'b0, m00_axis_tvalid_next;

//
// full when first TWO MSBs do NOT match, but rest matches
// (gray code equivalent of first MSB different but rest same)
//
wire full = ((wr_ptr_gray_reg[ADDR_WIDTH] != rd_ptr_gray_sync2_reg[ADDR_WIDTH]) &&
             (wr_ptr_gray_reg[ADDR_WIDTH-1] != rd_ptr_gray_sync2_reg[ADDR_WIDTH-1]) &&
             (wr_ptr_gray_reg[ADDR_WIDTH-2:0] == rd_ptr_gray_sync2_reg[ADDR_WIDTH-2:0]));
//			 
// empty when pointers match exactly
//
wire empty = rd_ptr_gray_reg == wr_ptr_gray_sync2_reg;

//
// control signals
//
reg write;
reg read;
reg store_output;

assign s00_axis_tready = ~full & ~s00_rst_sync3_reg;

assign m00_axis_tvalid = m00_axis_tvalid_reg;

assign mem_write_data = {s00_axis_tlast, s00_axis_tdata} & 32'h55555555;
assign {m00_axis_tlast, m00_axis_tdata} = m00_data_reg;

//
// Assign BRAM interface
//
assign write_address = {wr_addr_reg[ADDR_WIDTH-1:0]};
assign output_data_to_bram = {mem_write_data};
assign enable_write_data_from_bram = {write};
assign read_address = {rd_addr_reg[ADDR_WIDTH-1:0]};
assign enable_read_data_from_bram = {read};
assign input_data_from_bram = {mem_read_data_reg};

//
// reset synchronization
//
always @(posedge s00_axis_aclk) begin
    if (!s00_axis_aresetn) begin
        s00_rst_sync1_reg <= 1'b1;
        s00_rst_sync2_reg <= 1'b1;
        s00_rst_sync3_reg <= 1'b1;
    end else begin
        s00_rst_sync1_reg <= 1'b0;
        s00_rst_sync2_reg <= s00_rst_sync1_reg | m00_rst_sync1_reg;
        s00_rst_sync3_reg <= s00_rst_sync2_reg;
    end
end

always @(posedge m00_axis_aclk) begin
    if (!m00_axis_aresetn) begin
        m00_rst_sync1_reg <= 1'b1;
        m00_rst_sync2_reg <= 1'b1;
        m00_rst_sync3_reg <= 1'b1;
    end else begin
        m00_rst_sync1_reg <= 1'b0;
        m00_rst_sync2_reg <= s00_rst_sync1_reg | m00_rst_sync1_reg;
        m00_rst_sync3_reg <= m00_rst_sync2_reg;
    end
end

//
// Write logic
//
always @* begin
    write = 1'b0;

    wr_ptr_next = wr_ptr_reg;
    wr_ptr_gray_next = wr_ptr_gray_reg;

    if (s00_axis_tvalid) begin
        // input data valid
        if (~full) begin
            // not full, perform write
            write = 1'b1;
            wr_ptr_next = wr_ptr_reg + 1;
            wr_ptr_gray_next = wr_ptr_next ^ (wr_ptr_next >> 1);
        end
    end
end

always @(posedge s00_axis_aclk) begin
    if (s00_rst_sync3_reg) begin
        wr_ptr_reg <= {ADDR_WIDTH+1{1'b0}};
        wr_ptr_gray_reg <= {ADDR_WIDTH+1{1'b0}};
    end else begin
        wr_ptr_reg <= wr_ptr_next;
        wr_ptr_gray_reg <= wr_ptr_gray_next;
    end

    wr_addr_reg <= wr_ptr_next;

    if (write) begin
    
        // mem[wr_addr_reg[ADDR_WIDTH-1:0]] <= mem_write_data;
		
		// sina _ add here what to do once the buffer is received
    end
end

//
// pointer synchronization
//
always @(posedge s00_axis_aclk) begin
    if (s00_rst_sync3_reg) begin
        rd_ptr_gray_sync1_reg <= {ADDR_WIDTH+1{1'b0}};
        rd_ptr_gray_sync2_reg <= {ADDR_WIDTH+1{1'b0}};
    end else begin
        rd_ptr_gray_sync1_reg <= rd_ptr_gray_reg;
        rd_ptr_gray_sync2_reg <= rd_ptr_gray_sync1_reg;
    end
end

always @(posedge m00_axis_aclk) begin
    if (m00_rst_sync3_reg) begin
        wr_ptr_gray_sync1_reg <= {ADDR_WIDTH+1{1'b0}};
        wr_ptr_gray_sync2_reg <= {ADDR_WIDTH+1{1'b0}};
    end else begin
        wr_ptr_gray_sync1_reg <= wr_ptr_gray_reg;
        wr_ptr_gray_sync2_reg <= wr_ptr_gray_sync1_reg;
    end
end

//
// Read logic
//
always @* begin
    read = 1'b0;

    rd_ptr_next = rd_ptr_reg;
    rd_ptr_gray_next = rd_ptr_gray_reg;

    mem_read_data_valid_next = mem_read_data_valid_reg;

    if (store_output | ~mem_read_data_valid_reg) begin
        // output data not valid OR currently being transferred
        if (~empty) begin
            // not empty, perform read
            read = 1'b1;
            mem_read_data_valid_next = 1'b1;
            rd_ptr_next = rd_ptr_reg + 1;
            rd_ptr_gray_next = rd_ptr_next ^ (rd_ptr_next >> 1);
        end else begin
            // empty, invalidate
            mem_read_data_valid_next = 1'b0;
        end
    end
end

always @(posedge m00_axis_aclk) begin
    if (m00_rst_sync3_reg) begin
        rd_ptr_reg <= {ADDR_WIDTH+1{1'b0}};
        rd_ptr_gray_reg <= {ADDR_WIDTH+1{1'b0}};
        mem_read_data_valid_reg <= 1'b0;
    end else begin
        rd_ptr_reg <= rd_ptr_next;
        rd_ptr_gray_reg <= rd_ptr_gray_next;
        mem_read_data_valid_reg <= mem_read_data_valid_next;
    end

    rd_addr_reg <= rd_ptr_next;

    if (read) begin
    
        // mem_read_data_reg <= mem[rd_addr_reg[ADDR_WIDTH-1:0]];
         
		// sina _ add here what to do once we need to send the data

    end
end

//
// Output register
//
always @* begin
    store_output = 1'b0;

    m00_axis_tvalid_next = m00_axis_tvalid_reg;

    if (m00_axis_tready | ~m00_axis_tvalid) begin
        store_output = 1'b1;
        m00_axis_tvalid_next = mem_read_data_valid_reg;
    end
end

always @(posedge m00_axis_aclk) begin
    if (m00_rst_sync3_reg) begin
        m00_axis_tvalid_reg <= 1'b0;
    end else begin
        m00_axis_tvalid_reg <= m00_axis_tvalid_next;
    end

    if (store_output) begin
        m00_data_reg <= mem_read_data_reg;
    end
end

endmodule