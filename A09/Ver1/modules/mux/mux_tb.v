// --------------------------------------------------------------------------
// Test bench
// --------------------------------------------------------------------------
`timescale 1ns/1ps

module mux_tb;
   parameter Data_WIDTH = 16;                 // data width
   parameter Select_Size = 2;
   
   // Test bench Signals
   // Outputs
   wire [Data_WIDTH-1:0] DOut_TB;          // Output from mux

   // Inputs
   reg [Select_Size-1:0] Select_TB;
   reg [Data_WIDTH-1:0] DIn0_TB;
   reg [Data_WIDTH-1:0] DIn1_TB;
   reg [Data_WIDTH-1:0] DIn2_TB;
   reg [Data_WIDTH-1:0] DIn3_TB;

   reg Clock_TB;

   // -------------------------------------------
   // Device under test
   // -------------------------------------------
   Mux #(.DataWidth(Data_WIDTH), .SelectSize(Select_Size)) dut
   (
      .Select(Select_TB),
      .DIn0(DIn0_TB),
      .DIn1(DIn1_TB),
      .DIn2(DIn2_TB),
      .DIn3(DIn3_TB),
      .DOut(DOut_TB)
      );

   // -------------------------------------------
   // Test bench clock - not really need for this TB
   // -------------------------------------------
   initial begin
      Clock_TB <= 1'b0;
   end

   // The clock runs until the sim finishes. #100 = 200ns clock cycle
   always begin
      #100 Clock_TB = ~Clock_TB;
   end

   // -------------------------------------------
   // Configure starting sim states
   // -------------------------------------------
   initial begin
      $dumpfile("mux_tb.vcd");  // waveforms file needs to be the same name as the tb file.
      $dumpvars;  // Save waveforms to vcd file
      
      $display("%d %m: Starting testbench simulation...", $stime);
   end

   always begin
      // ------------------------------------
      // Test DIn0
      // ------------------------------------
      Select_TB = 2'b00;
      DIn0_TB = 16'h000A;
      DIn1_TB = 16'h00A0;
      DIn2_TB = 16'h0A00;
      DIn3_TB = 16'hA000;

      #10;

      if (DOut_TB != 16'h000A) begin
         $display("%d %m: ERROR - (0) mux output incorrect (%h).", $stime, DOut_TB);
         $finish;
      end

      #10;
      Select_TB = 2'b01;
      #10;

      if (DOut_TB != 16'h00A0) begin
         $display("%d %m: ERROR - (1) mux output incorrect (%h).", $stime, DOut_TB);
         $finish;
      end

      #10;
      Select_TB = 2'b10;
      #10;

      if (DOut_TB != 16'h0A00) begin
         $display("%d %m: ERROR - (2) mux output incorrect (%h).", $stime, DOut_TB);
         $finish;
      end

      #10;
      Select_TB = 2'b11;
      #10;

      if (DOut_TB != 16'hA000) begin
         $display("%d %m: ERROR - (3) mux output incorrect (%h).", $stime, DOut_TB);
         $finish;
      end

      // ------------------------------------
      // Simulation duration
      // ------------------------------------
      #50 $display("%d %m: Testbench simulation PASSED.", $stime);
      $finish;
   end
endmodule
