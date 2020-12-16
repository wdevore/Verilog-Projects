// --------------------------------------------------------------------------
// Test bench
// --------------------------------------------------------------------------
`timescale 1ns/10ps

module alu_tb;
   parameter WIDTH = 8;                 // data width
   
   // Test bencch Signals for Counter module
   wire [WIDTH-1:0] OReg_TB;          // Output from counter
   reg Reset_TB, EN_TB, OE_TB;          // Control inputs
   reg [WIDTH-1:0] IData_TB;            // Input to counter

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
   Register #(.BitWidth(WIDTH)) dut(
      .Q(OReg_TB),
      .Clk(Clock_TB),
      .Reset(Reset_TB),
      .EN(EN_TB),
      .OE(OE_TB),
      .D(IData_TB)
      );

   // -------------------------------------------
   // Configure starting sim states
   // -------------------------------------------
   initial begin
      $dumpfile("alu_tb.vcd");  // waveforms file needs to be the same name as the tb file.
      $dumpvars;  // Save waveforms to vcd file
      
      $display("%d %m: Starting testbench simulation...", $stime);

      Reset_TB = 1'b1;  // Not resetting.
      EN_TB = 1'b1;     // Loading disabled
      IData_TB = 8'b0;
      OE_TB = 1'b1;     // Output disabled
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
      if (OReg_TB === 8'bx) begin
         $display("%d %m: ERROR - (A) Register value incorrect (%d).", $stime, OReg_TB);
         $finish;
      end

      if (OReg_TB != 8'h00) begin
         $display("%d %m: ERROR - (B) Register value incorrect (%d).", $stime, OReg_TB);
         $finish;
      end

      // ------------------------------------
      // Load h0A into register
      // ------------------------------------
      #20 OE_TB = 1'b1;       // Disable output
      #10 IData_TB = 8'h0A;   // Present data
      #10 EN_TB = 1'b0;       // Enable loading
      #20; // Clock data into register
      #10 EN_TB = 1'b1;       // Disable loading
      OE_TB = 1'b0;           // Disable output
      #1;  // Wait for register delay

      if (OReg_TB === 8'bz) begin
         $display("%d %m: ERROR - (C) Register value incorrect (%d).", $stime, OReg_TB);
         $finish;
      end

      if (OReg_TB != 8'h0A) begin
         $display("%d %m: ERROR - (D) Register value incorrect (%d).", $stime, OReg_TB);
         $finish;
      end

      // ------------------------------------
      // Load hA0 into register
      // ------------------------------------
      #20 OE_TB = 1'b1;       // Disable output
      #10 IData_TB = 8'hA0;   // Present data
      #10 EN_TB = 1'b0;       // Enable loading
      #20; // Clock data into register
      #10 EN_TB = 1'b1;       // Disable loading
      OE_TB = 1'b0;           // Enable output
      #1;  // Wait for register delay
      
      if (OReg_TB === 8'bz) begin
         $display("%d %m: ERROR - (E) Register value incorrect (%d).", $stime, OReg_TB);
         $finish;
      end

      if (OReg_TB != 8'hA0) begin
         $display("%d %m: ERROR - (F) Register value incorrect (%d).", $stime, OReg_TB);
         $finish;
      end

      // ------------------------------------
      // Pulse Reset signal (active low)
      // ------------------------------------
      #10 OE_TB = 1'b1;       // Disable output 
      Reset_TB = 1'b0;
      $display("%d Reset pulled low", $stime);
      #20 Reset_TB = 1'b1;
      $display("%d Reset pulled high", $stime);

      OE_TB = 1'b0;               // Enable output
      #1; // Wait for register's delay
      if (OReg_TB === 8'bz) begin
         $display("%d %m: ERROR - (G) Register value incorrect (%d).", $stime, OReg_TB);
         $finish;
      end

      if (OReg_TB != 8'h00) begin
         $display("%d %m: ERROR - (H) Register value incorrect (%d).", $stime, OReg_TB);
         $finish;
      end

      // ------------------------------------
      // Simulation duration
      // ------------------------------------
      #50 $display("%d %m: Testbench simulation PASSED.", $stime);
      $finish;
   end
endmodule
