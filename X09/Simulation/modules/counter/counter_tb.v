// --------------------------------------------------------------------------
// Test bench
// --------------------------------------------------------------------------
`timescale 1ns/10ps

module counter_tb;
   parameter WIDTH = 8;                 // data width
   
   // Test bencch Signals for Counter module
   wire [WIDTH-1:0] OCount_TB;          // Output from counter
   reg Reset_TB, Load_TB, Enable_TB, OE_TB;    // Control inputs
   reg [WIDTH-1:0] IData_TB;            // Input to counter

   // -------------------------------------------
   // Test bench clock
   // -------------------------------------------
   reg Clock_TB;
   initial begin
      Clock_TB = 1'b0;
   end

   // The clock runs until the sim finishes.
   always begin
      #10 Clock_TB = ~Clock_TB;
   end

   // -------------------------------------------
   // Device under test
   // -------------------------------------------
   CounterUp #(.BitWidth(WIDTH)) dut(
      .Q(OCount_TB),
      .Clk(Clock_TB),
      .Reset(Reset_TB),
      .Load(Load_TB),
      .Enable(Enable_TB),
      .OE(OE_TB),
      .D(IData_TB)
      );

   // -------------------------------------------
   // Configure starting sim states
   // -------------------------------------------
   initial begin
      $dumpfile("counter_tb.vcd");  // waveforms file needs to be the same name as the tb file.
      $dumpvars;  // Save waveforms to vcd file
      
      $display("%d %m: Starting testbench simulation...", $stime);

      Reset_TB = 1'b1;
      Load_TB = 1'b1;
      Enable_TB = 1'b0;
      IData_TB = 8'b0;
      OE_TB = 1'b1;
      #10;
   end
   
   initial begin
      // ------------------------------------
      // Pulse Reset signal (active low)
      // ------------------------------------
      #20 Reset_TB = 1'b0;
      $display("%d Reset pulled low", $stime);
      #20 Reset_TB = 1'b1;
      $display("%d Reset pulled high", $stime);

      OE_TB = 1'b0;               // Enable output
      if (OCount_TB === 8'bx) begin
         $display("%d %m: ERROR - (A) Counter value incorrect (%d).", $stime, OCount_TB);
         $finish;
      end

      if (OCount_TB == 8'h00) begin
         $display("%d %m: ERROR - (B) Counter value incorrect (%d).", $stime, OCount_TB);
         $finish;
      end
      #20 OE_TB = 1'b1;           // Disable output

      // ------------------------------------
      // Allow the counter to count to 5
      // ------------------------------------
      #10 Enable_TB = 1'b1;       // Enable the counter
      OE_TB = 1'b0;           // Enable output
      #100 Enable_TB = 1'b0;      // 130 units allows the counter to reach h05
                                  // even if the output is disabled.
      $display("A %d, %d", $stime, OCount_TB);

      if (OCount_TB === 8'bz) begin
         $display("%d %m: ERROR - (C) Counter value incorrect (%d).", $stime, OCount_TB);
         $finish;
      end

      // We don't need to wait because we are sampling after the counter's delay.
      if (OCount_TB != 8'h05) begin
         $display("%d %m: ERROR - (D) Counter value incorrect (%d).", $stime, OCount_TB);
         $finish;
      end

      // ------------------------------------
      // Load h0F (active high)
      // ------------------------------------
      #10 IData_TB = 8'h0F;   // Present data
      #10 Load_TB = 1'b0;     // Load value
      #20 Load_TB = 1'b1;     // End loading
      if (OCount_TB != 8'h0F) begin
         $display("%d %m: ERROR - Loaded value incorrect (%h).", $stime, OCount_TB);
         $finish;
      end

      #10 Enable_TB = 1'b1;   // Enable the counter
      #60 Enable_TB = 1'b0;   // Disable the counter
      if (OCount_TB != 8'h12) begin
         $display("%d %m: ERROR - (E) Counter value incorrect (%h).", $stime, OCount_TB);
         $finish;
      end

      // ------------------------------------
      // Reset
      // ------------------------------------
      #10 Reset_TB = 1'b0;
      #20 Reset_TB = 1'b1;
      if (OCount_TB != 8'h00) begin
         $display("%d %m: ERROR - Reset value incorrect (%h).", $stime, OCount_TB);
         $finish;
      end

      OE_TB = 1'b1;           // Disable output
      Enable_TB = 1'b1;       // Enable the counter
      #70 Enable_TB = 1'b0;   // N units allows the counter to reach h04
      Enable_TB = 1'b0;       // Disable the counter
      OE_TB = 1'b0;       // Enable output
      #1;   // The counter has a delay (default 1unit), so we wait before we sample

      $display("B %d, %d", $stime, OCount_TB);
      if (OCount_TB === 8'bz) begin
         $display("%d %m: ERROR - (F) Counter output was not enabled (%d).", $stime, OCount_TB);
         $finish;
      end

      if (OCount_TB != 8'h04) begin
         $display("%d %m: ERROR - (G) Counter value incorrect (%h).", $stime, OCount_TB);
         $finish;
      end

      // ------------------------------------
      // Simulation duration
      // ------------------------------------
      #50 $display("%d %m: Testbench simulation PASSED.", $stime);
      $finish;
   end
endmodule
