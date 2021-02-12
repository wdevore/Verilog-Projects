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
        input wire Write_EN,                 // Write enable (Active Low)
        input wire Clk,
        output reg [DataWidth-1:0] DOut      // Memory register data output (Sync)
        // output wire [DataWidth-1:0] DOut     // Memory register data output (Async)
    );
    
    // Memory bank
    reg [DataWidth-1:0] mem [(1<<AddrWidth)-1:0]; // The actual memory

    // Debugging
    // integer index;
    
    initial begin
        // I explicitly specify the start/end address in order to avoid the
        // warning: "WARNING: memory.v:23: $readmemh: Standard inconsistency, following 1364-2005."
        $readmemh (`ROM_CONTENTS, mem, 'h00, 'h04);

        // Example of clearing remaining memory
        // for(index = 5; index < 20; index = index + 1)
        //     mem[index] = 16'h0000;

        // Example of displaying contents
        // for(index = 0; index < 25; index = index + 1)
        //     $display("memory[%d] = %b <- 0x%h", index[4:0], mem[index], mem[index]);
    end
    
    always @(posedge Clk)
    begin
        if (~Write_EN) begin
            mem[Address] <= DIn;
            // $display("written data 0x%h, 0x%h, 0x%h", Address, mem[Address], DIn);
        end
    end

    // --------------------------------
    // Example of Sync read
    // --------------------------------
    always @(posedge Clk)
    begin
        if (Write_EN) begin  // = Read
            DOut <= mem[Address];
            $display("read data 0x%h, 0x%h, 0x%h", Address, mem[Address], DIn);
        end
    end

    // --------------------------------
    // Async read
    // --------------------------------
    // assign DOut = mem[Address];
    // OR
    // Used with: output reg [DataWidth-1:0] DOut
    // always @(posedge Clk)
    // begin
    //     DOut = mem[Address]; // Output register controlled by clock.
    // end
endmodule
