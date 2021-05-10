// --------------------------------------------------------------------------
// Test bench
// --------------------------------------------------------------------------
`timescale 1ns/1ps

`define VCD_OUTPUT "/media/RAMDisk/memory_tb.vcd"

module memory_tb;
   parameter Data_WIDTH = 16;                 // data width
   parameter Address_WIDTH = 8;
   
   // Test bench Signals
   // Outputs
   wire [Data_WIDTH-1:0] DOut_TB;          // Output from memory

   // Inputs
   reg [Data_WIDTH-1:0] DIn_TB;
   reg [Address_WIDTH-1:0] Address_TB;
   reg WriteEn_TB;
   reg MemEn_TB;
   reg Clock_TB;

   // -------------------------------------------
   // Device under test
   // -------------------------------------------
   Memory dut(
      .DIn(DIn_TB),
      .Address(Address_TB),
      .Write_EN(WriteEn_TB),
      .Mem_En(MemEn_TB),
      .Clk(Clock_TB),
      .DOut(DOut_TB)
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
      $dumpfile(`VCD_OUTPUT);
      $dumpvars;  // Save waveforms to vcd file
      
      $display("%d %m: Starting testbench simulation...", $stime);

      MemEn_TB = 1'b1;   // Disable memory
      WriteEn_TB = 1'b1; // Disable writing to memory
      Address_TB = 8'bx; // Begining address of 0x00
      DIn_TB = 16'b0;    // Initial data
   end

   always begin
      @(posedge Clock_TB);

      // ------------------------------------
      // Read memory location 0x05: LDI R1, 0x01
      // ------------------------------------
      MemEn_TB = 1'b0;        // Enable memory
      Address_TB = 16'h0005;  // Assert address 0x05 <-- Reset vector address

      $display("%d (A) Wait for address to stablize", $stime);
      @(negedge Clock_TB);
      #10  // Wait for data

      if (DOut_TB !== 16'h9101) begin
         $display("%d %m: ERROR - (A) Memory 0x00 address has invalid value (%h).", $stime, DOut_TB);
         $finish;
      end
      $display("%d Read location 0x05", $stime);

      // ------------------------------------
      // Read memory location 0x06: LDI R2, 0x01
      // ------------------------------------
      @(posedge Clock_TB);
      Address_TB = 16'h0006; // Change address 0x06

      $display("%d (B) Wait for Clock edge and Data wait", $stime);
      @(negedge Clock_TB);
      #10 // Wait for data

      if (DOut_TB !== 16'h9201) begin
         $display("%d %m: ERROR - (B) Memory 0x00 address has invalid value (%h).", $stime, DOut_TB);
         $finish;
      end
      $display("%d Read location 0x06", $stime);

      // ------------------------------------
      // Read memory location 0x07: LDI R3, 0x08
      // ------------------------------------
      @(posedge Clock_TB);
      Address_TB = 16'h0007; // Change address 0x07

      $display("%d (C) Wait for Clock edge and Data wait", $stime);
      @(negedge Clock_TB);
      #10 // Wait for data

      if (DOut_TB !== 16'h9308) begin
         $display("%d %m: ERROR - (C) Memory 0x00 address has invalid value (%h).", $stime, DOut_TB);
         $finish;
      end
      $display("%d Read location 0x07", $stime);

      // =================================================================
      // ------------------------------------
      // Write to memory location 0x0A: 0x0666
      // ------------------------------------
      @(posedge Clock_TB);
      WriteEn_TB = 1'b0;    // Enable writing (active LOW)
      Address_TB = 16'h000A;   // Assert address
      DIn_TB = 16'h0666;

      @(negedge Clock_TB);
      #50 // Allow data to settle
      $display("%d Write location 0x0A", $stime);

      // ------------------------------------
      // Read memory location 0x0A
      // ------------------------------------
      @(posedge Clock_TB);
      WriteEn_TB = 1'b1;    // Disable writing
      Address_TB = 8'h0A;   // Assert address

      $display("%d (E) Waiting for Clock edge and Data", $stime);
      @(negedge Clock_TB);
      #10  // Wait a bit for data to settle

      // Now sample the output
      if (DOut_TB !== 16'h0666) begin
         $display("%d %m: ERROR - (E) Memory 0x00 address has invalid value (%h).", $stime, DOut_TB);
         $finish;
      end
      $display("%d Read location 0x0A", $stime);

      // ------------------------------------
      // Simulation duration
      // ------------------------------------
      #50 $display("%d %m: Testbench simulation PASSED.", $stime);
      $finish;
   end
endmodule
