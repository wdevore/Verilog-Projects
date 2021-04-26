// --------------------------------------------------------------------------
// Test bench
// Article on Overflow and Carry:
// http://teaching.idallen.com/dat2343/10f/notes/040_overflow.txt#:~:text=A%20math%20result%20can%20overflow,the%20ALU%20%22overflow%22%20flag.&text=The%20rules%20for%20turning%20on,significant%20(leftmost)%20bits%20added.
// --------------------------------------------------------------------------
`timescale 1ns/10ps

module alu_tb;
   parameter WIDTH = 16;                 // data width
   
   wire [WIDTH-1:0] OY_TB;         // Output result
   wire [3:0] OFlags_TB;           // Flags output

   // Inputs
   reg [3:0] IFlags_TB;            // Flags input
   reg [WIDTH-1:0] IA_TB, IB_TB;   // A,B register inputs
   reg [3:0] FuncOp_TB;            // ALU function to perform

   // -------------------------------------------
   // Test bench clock
   // -------------------------------------------
   reg Clock_TB;
   initial begin
      Clock_TB <= 1'b0;
   end
 
   // The clock runs until the sim finishes. 20ns cycle
   always begin
      #10 Clock_TB = ~Clock_TB;
   end
 
   // -------------------------------------------
   // Device under test
   // -------------------------------------------
   ALU #(.DataWidth(WIDTH)) dut(
      .IFlags(IFlags_TB),
      .A(IA_TB),
      .B(IB_TB),
      .FuncOp(FuncOp_TB),
      .Y(OY_TB),
      .OFlags(OFlags_TB)
      );

   // -------------------------------------------
   // Configure starting sim states
   // -------------------------------------------
   initial begin
      $dumpfile("alu_tb.vcd");  // waveforms file needs to be the same name as the tb file.
      $dumpvars;  // Save waveforms to vcd file
      
      $display("%d %m: Starting testbench simulation...", $stime);
      #10;
   end

   // `include "tests/add_op.v"
   // `include "tests/sub_op.v"
   // `include "tests/and_op.v"
   // `include "tests/or_op.v"
   `include "tests/xor_op.v"

endmodule
