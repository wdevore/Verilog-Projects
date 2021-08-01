`default_nettype none
`ifdef SIMULATE
`timescale 1ns/1ps
`endif

// --------------------------------------------------------------------------
// 256x16 BRAM memory
// Single or Dual Port
// --------------------------------------------------------------------------
// The path to the data file is relative to the test bench (TB).
// If the TB is run from this directory then the path would be "ROM.dat"
// `define MEM_CONTENTS "ROM.dat"
// Otherwise it is relative to the TB.
// `define MEM_CONTENTS "../../../roms/Sub_Halt.dat"

module Memory
#(
    parameter WORDS = 8,    // 2^WORDS
    parameter DATA_WIDTH = 16)
(
    input wire clk_i,                         // neg-edge
    input wire [DATA_WIDTH-1:0] data_i,       // Memory data input
    input wire [WORDS-1:0] address_i,    // Memory address_i
    input wire write_en_ni,                   // Write enable (Active Low)
    output reg [DATA_WIDTH-1:0] data_o        // Memory register data output (ASync)
    // output wire [DATA_WIDTH-1:0] data_o   // Memory register data output (Sync)
);

// Memory bank
reg [DATA_WIDTH-1:0] mem [(1<<WORDS)-1:0]; // The actual memory

// Debugging
`ifdef SIMULATE
integer index;
`endif
    
initial begin
    // Example of clearing remaining memory
    // for(index = 5; index < 20; index = index + 1)
    //     mem[index] = 16'h0000;

    // I can explicitly specify the start/end address_i in order to avoid the
    // warning: "WARNING: memory.v:23: $readmemh: Standard inconsistency, following 1364-2005."
    //     $readmemh (`MEM_CONTENTS, mem, 'h00, 'h04);
    `ifdef USE_ROM
        // NOTE:
        // `` - The double-backtick(``) is essentially a token delimiter.
        // It helps the compiler clearly differentiate between the Argument and
        // the rest of the string in the macro text.
        // See: https://www.systemverilog.io/macros
        $display("Using ROM: %s", ``MEM_CONTENTS);
        $readmemh ({"../../../roms/", ``MEM_CONTENTS, ".dat"}, mem);  // , 0, 6
    `elsif USE_STATIC
        mem[0] = 16'h00ff;       // Simple data for testing
        mem[1] = 16'h00f0;
        mem[2] = 16'h000f;
        mem[255] = 16'h0001;
    `endif

    `ifdef SIMULATE
        // Example of displaying contents
        $display("------- Top MEM contents ------");
        for(index = 0; index < 15; index = index + 1)
            $display("memory[%d] = %b <- %h", index[7:0], mem[index], mem[index]);

        // Display the vector data residing at the bottom of memory
        $display("------- Bottom MEM contents ------");
        for(index = 250; index < 256; index = index + 1)
            $display("memory[%d] = %b <- %h", index[7:0], mem[index], mem[index]);
    `endif
end

// --------------------------------
// Register blobs
// --------------------------------
// Force Register blocks. Remove data_o <= ... above as well.
// assign data_o = mem[address_i];

// --------------------------------
// Single Port RAM -- Ultra+ class chips
// --------------------------------
// always @(negedge clk_i) begin
//     if (~write_en_ni) begin
//         mem[address_i] <= data_i;
//         `ifdef SIMULATE
//             $display("%d WRITE data at Addr(0x%h), Mem(0x%h), data_i(0x%h)", $stime, address_i, mem[address_i], data_i);
//         `endif
//     end
//     data_o <= mem[address_i];  // <-- remove this to simulate Register blobs
// end

// --------------------------------
// Dual Port RAM --  LP/HX and Ultra+ classes
// --------------------------------
always @(negedge clk_i) begin
    if (~write_en_ni) begin
        mem[address_i] <= data_i;
        `ifdef SIMULATE
            $display("%d Mem WRITE data Addr (0x%h), Data(0x%h), data_i(0x%h)", $stime, address_i, mem[address_i], data_i);
        `endif
    end
end

always @(negedge clk_i) begin
    data_o <= mem[address_i];
    `ifdef SIMULATE
        $display("%d Mem READ data Addr (0x%h), Data(0x%h), data_i(0x%h)", $stime, address_i, mem[address_i], data_i);
    `endif
end


// --------------------------------
// Handcrafted -- NOT RECOMMENDED
// --------------------------------
// SB_RAM256x16 ram256x16_inst (
//     .RDATA(data_o[15:0]),
//     .RADDR(address_i[7:0]),
//     .RCLK(clk_i),
//     .RCLKE(1'b1),
//     .RE(1'b1),
//     .WADDR(address_i[7:0]),
//     .WCLK(clk_i),
//     .WCLKE(1'b1),
//     .WDATA(data_i[15:0]),
//     .WE(~write_en_ni),
//     .MASK(16'h0000),
//     .READ_MODE(2'h0),
//     .WRITE_MODE(2'h0)
// );

endmodule

