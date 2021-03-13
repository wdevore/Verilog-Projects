`default_nettype none

// --------------------------------------------------------------------------
// Standard register with Load and Reset.
// --------------------------------------------------------------------------

module Register
#(
    parameter DataWidth = 8)
(
    input wire Clk,
    input wire Reset,                // Active Low
    input wire LD,                   // Load: Active Low
    input wire [DataWidth-1:0] DIn,  // Input
    output reg [DataWidth-1:0] DOut  // Output
);

always @(negedge Clk) begin
    if (~Reset)
        DOut <= {DataWidth{1'b0}};
    else if (~LD) begin
        $display("%d Register Load: %h", $stime, DIn);
        DOut <= DIn;
    end
    else
        DOut <= DOut;
end

endmodule
