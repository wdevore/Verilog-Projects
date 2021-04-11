`default_nettype none

// --------------------------------------------------------------------------
// 256x8 BRAM memory
// Single-Port
// --------------------------------------------------------------------------
// The path to the data file is relative to the test bench (TB).
// If the TB is run from this directory then the path would be "ROM.dat"
// `define ROM_CONTENTS "ROM.dat"
// Otherwise it is relative to the TB.
`timescale 1ns/1ps

`define ROM_CONTENTS "../../../roms/Nop_Ld.dat"

module Memory
    #(
        parameter AddrWidth = 8,
        parameter DataWidth = 16)
    (
        input wire [DataWidth-1:0] DIn,     // Memory data input
        input wire [AddrWidth-1:0] Address, // Memory address
        input wire Write_EN,                // Write enable (Active Low)
        input wire Mem_En,                  // Memory enable (active Low)
        input wire Clk,                     // neg-edge
        output reg [DataWidth-1:0] DOut     // Memory register data output (Sync)
        // output wire [DataWidth-1:0] DOut // Memory register data output (Async)
    );
    
    // Memory bank
    reg [DataWidth-1:0] mem [(1<<AddrWidth)-1:0]; // The actual memory

    // Debugging
    integer index;
    
    initial begin
        // I explicitly specify the start/end address in order to avoid the
        // warning: "WARNING: memory.v:23: $readmemh: Standard inconsistency, following 1364-2005."
        //     $readmemh (`ROM_CONTENTS, mem, 'h00, 'h04);
        $readmemh (`ROM_CONTENTS, mem);  // , 0, 6
`ifdef SIMULATE
        // Example of clearing remaining memory
        // for(index = 5; index < 20; index = index + 1)
        //     mem[index] = 16'h0000;

        // Example of displaying contents
        $display("------- ROM contents ------");
        for(index = 0; index < 15; index = index + 1)
            $display("memory[%d] = %b <- %h", index[4:0], mem[index], mem[index]);
`endif
    end


    // --------------------------------
    // Write to memory
    // --------------------------------
    always @(negedge Clk)
    begin
        if (~Mem_En && ~Write_EN) begin
            mem[Address] <= DIn;
            // $display("%d WRITE data Addr (0x%h), Data(0x%h), DIn(0x%h)", $stime, Address, mem[Address], DIn);
        end
    end

    // --------------------------------
    // Sync read from memory
    // --------------------------------
    always @(negedge Clk)
    begin
        if (~Mem_En && Write_EN) begin  // = Read
            DOut <= mem[Address];
            `ifdef SIMULATE
                $display("%d READ data Addr (0x%h), Data(0x%h), DIn(0x%h)", $stime, Address, mem[Address], DIn);
            `endif
        end
    end

    // --------------------------------
    // Async read
    // --------------------------------
    // assign DOut = mem[Address];
    // OR
    // Used with: output reg [DataWidth-1:0] DOut
    // always @(negedge Clk)
    // begin
    //     DOut = mem[Address]; // Output register controlled by clock.
    // end
endmodule
