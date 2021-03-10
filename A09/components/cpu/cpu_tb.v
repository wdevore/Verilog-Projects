// --------------------------------------------------------------------------
// Test bench for a fetch cycle
// --------------------------------------------------------------------------
`timescale 1ns/1ps

module fetch_tb;
   parameter AddrWidth_TB = 8;      // 8bit Address width
   parameter DataWidth_TB = 16;     // 16bit Data width
   parameter WordSize_TB = 1;       // Instructions a 1 = 2bytes in size
   parameter SelectSize_TB = 2;     // MUX select bits
   
   // Test bench Signals

   // Inputs
   reg Clock_TB;
   reg Reset_TB;

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
      Reset_TB = 1'b1;
   end

   always begin

      // ------------------------------------
      // Allow CPU to idle for several cycles
      // ------------------------------------
      #600 // wait 3 cycles
 
      // ------------------------------------
      // Reset CPU
      // ------------------------------------
      Reset_TB = 1'b0;  // Enable reset

      #100; // Wait 1/2 cycle. The CPU state should have changed
      $display("%d <-- Marker", $stime);

      #1; // Wait for the falling edge
      if (cpu.ControlMatrix.state !== cpu.ControlMatrix.S_Reset) begin
         $display("%d %m: ERROR - Reset state incorrect (%b)", $stime, cpu.ControlMatrix.state);
         $finish;
      end
      $display("%d CPU state: (%b)", $stime, cpu.ControlMatrix.state);
  
      Reset_TB = 1'b1;  // Disable reset

      #(200); // Wait 1 cycle then raise reset
      if (cpu.ControlMatrix.state !== cpu.ControlMatrix.S_FetchPCtoMEM) begin
         $display("%d %m: ERROR - Expected S_FetchPCtoMEM got: (%b)", $stime, cpu.ControlMatrix.state);
         $finish;
      end
      $display("%d CPU state: (%b)", $stime, cpu.ControlMatrix.state);
  
      #(200*15); // Allow 10 cycles for simulation

      // ------------------------------------
      // Simulation duration
      // ------------------------------------
      #50 $display("%d %m: Testbench simulation PASSED.", $stime);
      $finish;
   end
endmodule
