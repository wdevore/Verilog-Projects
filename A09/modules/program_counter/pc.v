`default_nettype none

// --------------------------------------------------------------------------
// Standard program counter with Auto-increment, Load and Reset.
// --------------------------------------------------------------------------

module ProgramCounter
#(
    parameter DataWidth = 8,
    parameter WordByteSize = 2)
(
    input wire Reset,                // Active Low
    input wire Clk,
    input wire LD,                   // Load: Active Low
    input wire [DataWidth-1:0] DIn,  // Input
    output reg [DataWidth-1:0] DOut  // Output
);

always @(posedge Clk) begin
    if (~Reset)
        DOut <= {DataWidth{1'b0}};
    else if (~LD)
        DOut <= DIn;
    else
        DOut <= DOut + WordByteSize;
end

endmodule
