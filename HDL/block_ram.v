module rams_sp_rom #
(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 32
)
(
    input clk,
    input we,
    input [ADDR_WIDTH:0] addr,
    input [DATA_WIDTH-1:0] di,
    output [DATA_WIDTH-1:0] dout
);

reg [DATA_WIDTH-1:0] ram [63:0];
reg [DATA_WIDTH-1:0] dout;

initial
begin
    ram[63] = 20'hAAAAA; ram[62] = 20'hAAAAA; ram[61] = 20'hAAAAA;
    ram[60] = 20'hBBBBB; ram[59] = 20'hBBBBB; ram[58] = 20'hBBBBB;
    ram [57] = 20'hCCCCC; ram[56] = 20'hCCCCC; ram[55] = 20'hCCCCC;
    ram[54] = 20'hDDDDD; ram[53] = 20'hDDDDD; ram[52] = 20'hDDDDD;
    ram[51] = 20'hEEEEE; ram[50] = 20'hEEEEE; ram[49] = 20'hEEEEE;
    ram[48] = 20'hFFFFF; ram[47] = 20'hFFFFF; ram[46] = 20'hFFFFF;
    ram[45] = 20'hAAAAA; ram[44] = 20'hAAAAA; ram[43] = 20'hAAAAA;
    ram[42] = 20'hBBBBB; ram[41] = 20'hBBBBB; ram[40] = 20'hBBBBB;
    ram[39] = 20'hCCCCC; ram[38] = 20'hCCCCC; ram[37] = 20'hCCCCC;
    ram[36] = 20'hDDDDD; ram[35] = 20'hDDDDD; ram[34] = 20'hDDDDD;
    ram[33] = 20'hEEEEE; ram[32] = 20'hEEEEE; ram[31] = 20'hEEEEE;
    ram[30] = 20'hFFFFF; ram[29] = 20'hFFFFF; ram[28] = 20'hFFFFF;
    ram[27] = 20'hAAAAA; ram[26] = 20'hAAAAA; ram[25] = 20'hAAAAA;
    ram[24] = 20'hBBBBB; ram[23] = 20'hBBBBB; ram[22] = 20'hBBBBB;
    ram[21] = 20'hCCCCC; ram[20] = 20'hCCCCC; ram[19] = 20'hCCCCC;
    ram[18] = 20'hDDDDD; ram[17] = 20'hDDDDD; ram[16] = 20'hDDDDD;
    ram[15] = 20'hEEEEE; ram[14] = 20'hEEEEE; ram[13] = 20'hEEEEE;
    ram[12] = 20'hFFFFF; ram[11] = 20'hFFFFF; ram[10] = 20'hFFFFF;
    ram[9] = 20'hAAAAA; ram[8] = 20'hAAAAA; ram[7] = 20'hAAAAA;
    ram[6] = 20'hBBBBB; ram[5] = 20'hBBBBB; ram[4] = 20'hBBBBB;
    ram[3] = 20'hCCCCC; ram[2] = 20'hCCCCC; ram[1] = 20'hCCCCC;
    ram[0] = 20'hDDDDD;
end

always @(posedge clk)
    begin
        if (we)
            ram[addr] <= di;
            dout <= ram[addr];
    end

endmodule
