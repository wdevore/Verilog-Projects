`default_nettype none

// --------------------------------------------------------------------------
// Test bench
// --------------------------------------------------------------------------
`timescale 1ns/1ps

// Test the sequence control matrix

module register_file_tb;
   parameter Data_WIDTH = 16;                 // data width
   parameter SelectSize = 3;
   
   // Test bench Signals
   // Outputs
   wire [Data_WIDTH-1:0] SRC1_TB;
   wire [Data_WIDTH-1:0] SRC2_TB;

   // Inputs
   reg REG_WE_TB;
   reg [Data_WIDTH-1:0] DIn_TB;
   reg [SelectSize-1:0] REG_Dst_TB;
   reg [SelectSize-1:0] REG_Src1_TB;
   reg [SelectSize-1:0] REG_Src2_TB;

   reg Clock_TB;

   // -------------------------------------------
   // Device under test
   // -------------------------------------------
   RegisterFile #(.DataWidth(Data_WIDTH)) dut
   (
      .Clk(Clock_TB),
      .REG_WE(REG_WE_TB),
      .DIn(DIn_TB),
      .REG_Dst(REG_Dst_TB),
      .REG_Src1(REG_Src1_TB),
      .REG_Src2(REG_Src2_TB),
      .SRC1(SRC1_TB),
      .SRC2(SRC2_TB)
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
      $dumpfile("register_file_tb.vcd");  // waveforms file needs to be the same name as the tb file.
      $dumpvars;  // Save waveforms to vcd file
      
      $display("%d %m: Starting testbench simulation...", $stime);

      REG_WE_TB = 1'b1;  // Disable Register write
      DIn_TB = {Data_WIDTH{1'b0}};  // DIn = 0
      REG_Dst_TB = 3'b0;      // Default to reg 0
      REG_Src1_TB = 3'b0;     // Default to reg 0
      REG_Src2_TB = 3'b0;     // Default to reg 0
   end

   always begin
      #50; // Pause for a bit

      // ------------------------------------
      // Load Reg 0 <- 0x00A0
      // ------------------------------------
      REG_WE_TB = 1'b0;  // Enable writing
      DIn_TB = 16'h00A0;  // Write 0x00A0
      REG_Dst_TB = 3'b0;    // Select Reg 0 as destination
      REG_Src1_TB = 3'b0;   // Default to reg 0 as Src #1

      #100; // Wait for clock edge to pass
      $display("%d <-- Marker", $stime);

      if (SRC1_TB != 16'h00A0) begin
         $display("%d %m: ERROR - (0) Src #1 output incorrect (%h).", $stime, SRC1_TB);
         $finish;
      end

      // ------------------------------------
      // Simulation duration
      // ------------------------------------
      #50 $display("%d %m: Testbench simulation PASSED.", $stime);
      $finish;
   end
endmodule
