// --------------------------------------------------------------------------
// N-bit tri-state read/write register
// Can be used as a Data-path register
// The output is tri capable.
// --------------------------------------------------------------------------

module Register
    #(
        parameter BitWidth = 8 // Default to 8 bits
    )
    (
        output tri [BitWidth-1:0] Q,    // Tri-state output
        input Clk,
        input Reset,   // Active low, Resets to 0
        input EN,      // Active low, enables loading/writing at Clk
        input OE,      // Active low, enables output for reading
        input [BitWidth-1:0] D
    );

    // Local Vars
    parameter RDelay = 1;
    reg [BitWidth-1:0] Regr;
    
    always @(posedge Clk, negedge Reset)
        if (!Reset)
            Regr <= #RDelay 0;
        else if (!EN)
            Regr <= #RDelay D;

    assign #RDelay Q = OE ? {BitWidth{1'bz}} : Regr;

endmodule
