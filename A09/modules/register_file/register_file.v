`default_nettype none

// --------------------------------------------------------------------------
// Register file 
// --------------------------------------------------------------------------

module RegisterFile
#(
    parameter DataWidth = 8,
    parameter RegisterCnt = 8,
    parameter SelectSize = 3)   // 3bits = 8 = RegisterCnt
(
    input wire Clk,
    input wire REG_WE,
    input wire [DataWidth-1:0] DIn,         // Data input
    // // Destination reg write, Write = Active Low
    input wire [SelectSize-1:0] REG_Dst,    // Reg destination select
    input wire [SelectSize-1:0] REG_Src1,   // Source #1 select
    input wire [SelectSize-1:0] REG_Src2,   // Source #2 select
    output wire [DataWidth-1:0] SRC1,       // Source 1 output
    output wire [DataWidth-1:0] SRC2        // Source 2 output
);

// The registers.
// Note: Not sure if this will be refactored to actual
// registers. The code below could trigger BRAM synthization
reg [DataWidth-1:0] reg_file [(1<<RegisterCnt)-1:0];

// An alternative is to sync the outputs too. Mine is Async
// See: "Digital Systems Design Using Verilog by Charles Roth, Lizy K. John, Byeong Kil Lee 2016 MIPS CPU"
always @(negedge Clk) begin
    if (REG_WE == 1'b0)
        reg_file[REG_Dst] <= DIn;
end

// Source outputs
assign SRC1 = reg_file[REG_Src1];
assign SRC2 = reg_file[REG_Src2];

endmodule
