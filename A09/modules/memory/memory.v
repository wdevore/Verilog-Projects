// --------------------------------------------------------------------------
// 256x8 BRAM memory
// Single-Port
// --------------------------------------------------------------------------
`define ROM_CONTENTS "ROM.dat"

module Memory
    #(
        parameter AddrWidth = 8,
        parameter DataWidth = 16)
    (
        input wire [DataWidth-1:0] DIn,      // Memory data input
        input wire [AddrWidth-1:0] Address,  // Memory address
        input wire Write_EN,                 // Write enable
        input wire Clk,
        output reg [DataWidth-1:0] DOut      // Memory register data output
    );
    
    // Memory bank
    reg [DataWidth-1:0] mem [(1<<AddrWidth)-1:0]; // The actual memory
    integer index;
    initial begin
        // I explicityly specify the start/end address in order to avoid the
        // warning: "WARNING: memory.v:23: $readmemh: Standard inconsistency, following 1364-2005."
        $readmemh (`ROM_CONTENTS, mem, 'h00, 'h04);

        for(index = 0; index < 5; index = index + 1)
            $display("memory[%d] = %b <- 0x%h", index[4:0], mem[index], mem[index]);
    end
    
    always @(posedge Clk)
    begin
        if (Write_EN)
            mem[Address] <= DIn;
        
        DOut = mem[Address]; // Output register controlled by clock.
    end
endmodule
