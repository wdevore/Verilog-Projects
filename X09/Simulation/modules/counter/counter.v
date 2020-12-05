// --------------------------------------------------------------------------
// N-bit tri-state read/write counter
// Can be used as a Program-counter
// Counts even if the output is disabled.
// --------------------------------------------------------------------------

module CounterUp
    #(
        parameter BitWidth = 8 // Default to 8 bits
    )
    (
        output tri [BitWidth-1:0] Q,    // Tri-state output
        input Clk,
        input Reset,   // Active low
        input Load,    // Active low
        input Enable,  // Active high, enables counting
        input OE,      // Active low,  enables output
        input [BitWidth-1:0] D
    );

    // Local Vars
    parameter RDelay = 1;
    reg [BitWidth-1:0] Cnt;
    
    always @(posedge Clk, negedge Reset) begin
        // Async Reset
        if (!Reset)
            Cnt <= #RDelay 0;
        else begin
            // Sync inputs
            if (!Load)
                Cnt <= #RDelay D;
            if (Enable) begin
                Cnt <= #RDelay Cnt + 1;
            end
        end
    end

    assign #RDelay Q = OE ? {BitWidth{1'bz}} : Cnt;

endmodule
