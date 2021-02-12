// --------------------------------------------------------------------------
// Test bench
// --------------------------------------------------------------------------
`timescale 1ns/1ps

module demux_tb;
   parameter Data_WIDTH = 1;                 // data width
   
   // Test bench Signals
   // Outputs
   wire [Data_WIDTH-1:0] O0_TB;          // Output from demux
   wire [Data_WIDTH-1:0] O1_TB;          // Output from demux
   wire [Data_WIDTH-1:0] O2_TB;          // Output from demux
   wire [Data_WIDTH-1:0] O3_TB;          // Output from demux
   wire [Data_WIDTH-1:0] O4_TB;          // Output from demux
   wire [Data_WIDTH-1:0] O5_TB;          // Output from demux
   wire [Data_WIDTH-1:0] O6_TB;          // Output from demux
   wire [Data_WIDTH-1:0] O7_TB;          // Output from demux

   // Inputs
   reg [1:0] Select_TB;
   reg [Data_WIDTH-1:0] DIn_TB;
   reg Enable_TB;

   reg Clock_TB;

   // -------------------------------------------
   // Device under test
   // -------------------------------------------
   Demux #(.DataWidth(Data_WIDTH)) dut
   (
      .Select(Select_TB),
      .Enable(Enable_TB),
      .DIn(DIn_TB),
      .O0(O0_TB),
      .O1(O1_TB),
      .O2(O2_TB),
      .O3(O3_TB),
      .O4(O4_TB),
      .O5(O5_TB),
      .O6(O6_TB),
      .O7(O7_TB)
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
      $dumpfile("demux_tb.vcd");  // waveforms file needs to be the same name as the tb file.
      $dumpvars;  // Save waveforms to vcd file
      
      $display("%d %m: Starting testbench simulation...", $stime);
   end

   always begin
      // ------------------------------------
      // Test O0
      // ------------------------------------
      Select_TB = 3'b000; // Select O0
      DIn_TB = 0;  // Initial data
      Enable_TB = 1'b1;
      #10;

      if (O0_TB != 1'b0) begin
         $display("%d %m: ERROR - (A) Demux output incorrect (%h).", $stime, O0_TB);
         $finish;
      end

      if (O1_TB != 1'b1) begin
         $display("%d %m: ERROR - (B) Demux output incorrect (%h).", $stime, O1_TB);
         $finish;
      end

      #10;
      Select_TB = 3'b001; // Select O1
      DIn_TB = 0;
      Enable_TB = 1'b1;
      #10;

      if (O0_TB != 1'b1) begin
         $display("%d %m: ERROR - (C) Demux output incorrect (%h).", $stime, O0_TB);
         $finish;
      end

      if (O1_TB != 1'b0) begin
         $display("%d %m: ERROR - (D) Demux output incorrect (%h).", $stime, O1_TB);
         $finish;
      end

      #10;
      Select_TB = 2'b001; // Select O1
      DIn_TB = 0;
      Enable_TB = 1'b0;
      #10;

      if (O0_TB != 1'b1) begin
         $display("%d %m: ERROR - (E) Demux output incorrect (%h).", $stime, O0_TB);
         $finish;
      end

      if (O1_TB != 1'b1) begin
         $display("%d %m: ERROR - (F) Demux output incorrect (%h).", $stime, O1_TB);
         $finish;
      end

      #10;
      Select_TB = 3'b010; // Select O1
      DIn_TB = 0;
      Enable_TB = 1'b1;
      #10;

      if (O0_TB != 1'b1) begin
         $display("%d %m: ERROR - (2A) Demux output incorrect (%h).", $stime, O0_TB);
         $finish;
      end

      if (O1_TB != 1'b1) begin
         $display("%d %m: ERROR - (2B) Demux output incorrect (%h).", $stime, O1_TB);
         $finish;
      end

      if (O2_TB != 1'b0) begin
         $display("%d %m: ERROR - (2C) Demux output incorrect (%h).", $stime, O2_TB);
         $finish;
      end

      #10;
      Select_TB = 3'b010; // Select O1
      DIn_TB = 0;
      Enable_TB = 1'b0;
      #10;

      // ------------------------------------
      // Simulation duration
      // ------------------------------------
      #50 $display("%d %m: Testbench simulation PASSED.", $stime);
      $finish;
   end
endmodule
