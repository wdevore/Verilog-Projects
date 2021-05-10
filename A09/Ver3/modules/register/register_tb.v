// --------------------------------------------------------------------------
// Test bench
// --------------------------------------------------------------------------
`timescale 1ns/1ps

`define VCD_OUTPUT "/media/RAMDisk/register_tb.vcd"

module register_tb;
   parameter Data_WIDTH = 16;                 // data width
   
   // Test bench Signals
   // Outputs
   wire [Data_WIDTH-1:0] DOut_TB;

   // Inputs
   reg Reset_TB;
   reg LD_TB;
   reg [Data_WIDTH-1:0] DIn_TB;

   reg Clock_TB;

   // -------------------------------------------
   // Device under test
   // -------------------------------------------
   Register #(.DataWidth(Data_WIDTH)) dut
   (
      .Reset(Reset_TB),
      .Clk(Clock_TB),
      .LD(LD_TB),
      .DIn(DIn_TB),
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
      $dumpfile(`VCD_OUTPUT);
      $dumpvars;  // Save waveforms to vcd file
      
      $display("%d %m: Starting testbench simulation...", $stime);

      Reset_TB = 1'b1;  // Disable reset
      DIn_TB = {Data_WIDTH{1'b0}};  // DIn = 0
      LD_TB = 1'b1;     // Disable load
   end

   always begin
      // ------------------------------------
      // Reset first
      // ------------------------------------
      @(posedge Clock_TB);

      Reset_TB = 1'b0;  // Enable reset
      DIn_TB = {Data_WIDTH{1'b0}};  // DIn can any value
      LD_TB = 1'b1;     // Disable load

      @(negedge Clock_TB);
      #10  // Wait for data
      $display("%d <-- Marker", $stime);

      if (DOut_TB !== 16'h0000) begin
         $display("%d %m: ERROR - (0) PC output incorrect (%h).", $stime, DOut_TB);
         $finish;
      end

      // ------------------------------------
      // Load
      // ------------------------------------
      @(posedge Clock_TB);
      Reset_TB = 1'b1;  // Disable reset
      DIn_TB = 16'h00A0;  // Set Address to 0x00A0
      LD_TB = 1'b0;     // Enable load

      @(negedge Clock_TB);
      #10  // Wait for data

      if (DOut_TB !== 16'h00A0) begin
         $display("%d %m: ERROR - (1) PC output incorrect (%h).", $stime, DOut_TB);
         $finish;
      end

      // ------------------------------------
      // Reset
      // ------------------------------------
      @(posedge Clock_TB);
      Reset_TB = 1'b0;  // Enable reset
      LD_TB = 1'b1;     // Disable load

      @(negedge Clock_TB);
      #10  // Wait for data

      if (DOut_TB !== 16'h0000) begin
         $display("%d %m: ERROR - (2) PC output incorrect (%h).", $stime, DOut_TB);
         $finish;
      end

      // ------------------------------------
      // Simulation duration
      // ------------------------------------
      #50 $display("%d %m: Testbench simulation PASSED.", $stime);
      $finish;
   end
endmodule
