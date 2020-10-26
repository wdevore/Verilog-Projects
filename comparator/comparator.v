// A simple comparator used for learning simulation workflows

// comparator - comparator_tb.v
//
// Description:
// Testbench for comparator module.
//
// Note: the "board" selected is irrelevant because I'm only running
// a simulation and not attempting to upload to board. This simply
// allows apio to build.
//
// > apio init --board TinyFPGA-B2
// > apio build
// > apio sim

`timescale 1ns/10ps

module comparator #(
   parameter WIDTH = 8      // data width
   ) (
   input [WIDTH-1:0] a, b,  // values to compare
   output            lt,    // high when a < b
   output            eq,    // high when a = b
   output            gt     // high when a > b
   );
   assign lt = (a < b) ? 1'b1 : 1'b0;
   assign eq = (a == b) ? 1'b1 : 1'b0;
   assign gt = (a > b) ? 1'b1 : 1'b0;
endmodule  // comparator
