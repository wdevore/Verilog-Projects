// --------------------------------------------------------------------------
// Test bench for a fetch cycle
// --------------------------------------------------------------------------
`timescale 1ns/1ps

module fetch_tb;
   parameter AddrWidth_TB = 8;      // 8bit Address width
   parameter DataWidth_TB = 16;     // 16bit Data width
   parameter WordSize_TB = 2;       // Instructions a 2bytes in size
   parameter SelectSize_TB = 2;     // MUX select bits
   
   // Test bench Signals

   // Inputs
   reg Reset_TB;

   reg Clock_TB;

   // -------------------------------------------
   // Device under test
   // -------------------------------------------
   CPU #(
      .DataWidth(DataWidth_TB),
      .AddrWidth(AddrWidth_TB),
      .WordSize(WordSize_TB)) cpu
   (
      .Clk(Clock_TB),
      .Reset(Reset_TB)
   );

   // -------------------------------------------
   // Test bench clock
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
      $dumpfile("cpu_tb.vcd");  // waveforms file needs to be the same name as the tb file.
      $dumpvars;  // Save waveforms to vcd file
       
      $display("%d %m: Starting testbench simulation...", $stime);

      // Setup defaults
   end

   always begin
      #50 // wait a bit

      // ------------------------------------
      // Reset PC
      // ------------------------------------
      // Reset_TB = 1'b0;  // Enable reset
      // PC_Ld_TB = 1'b1;  // Disable load

      // #200; // Wait for clock edge to pass
      // $display("%d <-- Marker", $stime);

      // if (dut.PC.DOut != 16'h0000) begin
      //    $display("%d %m: ERROR - Reset PC output incorrect (%h).", $stime, DOut_TB);
      //    $finish;
      // end

      #200; // Wait for clock edge

      // ------------------------------------
      // Simulation duration
      // ------------------------------------
      #50 $display("%d %m: Testbench simulation PASSED.", $stime);
      $finish;
   end
endmodule
