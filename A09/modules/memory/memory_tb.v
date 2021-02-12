// --------------------------------------------------------------------------
// Test bench
// --------------------------------------------------------------------------
`timescale 1ns/1ps

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
   reg Clock_TB;

   // -------------------------------------------
   // Device under test
   // -------------------------------------------
   Memory dut(
      .DIn(DIn_TB),
      .Address(Address_TB),
      .Write_EN(WriteEn_TB),
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
      $dumpfile("memory_tb.vcd");  // waveforms file needs to be the same name as the tb file.
      $dumpvars;  // Save waveforms to vcd file
      
      $display("%d %m: Starting testbench simulation...", $stime);

      WriteEn_TB = 1'b1; // Disable writing to memory
      Address_TB = 8'bx; // Begining address of 0x00
      DIn_TB = 16'b0;    // Initial data
      #10;
   end

   always begin
      // ------------------------------------
      // Read memory location 0x00: LDI R1, 0x02 <-- 0x9202
      // ------------------------------------
      WriteEn_TB = 1'b1;   // Disable writing
      Address_TB = 8'b0;   // Assert address 0x00

      $display("%d (A) Wait for address to stablize", $stime);
      #100 // Allow Clock edge to occur
      #10  // Wait for data

      if (DOut_TB != 16'h9202) begin
         $display("%d %m: ERROR - (A) Memory 0x00 address has invalid value (%h).", $stime, DOut_TB);
         $finish;
      end
      $display("%d Read location 0x00", $stime);

      // ------------------------------------
      // Read memory location 0x01: LDI R2, 0x04 <-- 0x9304
      // ------------------------------------
      // The current time is 110ns
      // The next posEdge isn't until 300ns absolute
      // thus the next posEdge is at (300-110) = 190ns delay
      // So we wait until 180ns --10ns before edge-- then change address
      #(300-$time-10)

      WriteEn_TB = 1'b1;        // Disable writing
      Address_TB = 8'b00000001; // Change address 0x01

      $display("%d (B) Wait for Clock edge and Data wait", $stime);
      #20 // Allow Clock edge to occur
      #10 // Wait for data

      if (DOut_TB !== 16'h9304) begin
         $display("%d %m: ERROR - (B) Memory 0x00 address has invalid value (%h).", $stime, DOut_TB);
         $finish;
      end
      $display("%d Read location 0x01", $stime);

      // ------------------------------------
      // Read memory location 0x02: ADD R3, R2, R1 <-- 0x2621
      // ------------------------------------
      // The current $time is 320ns
      // The next posEdge isn't until 500ns absolute
      // thus the next posEdge is at (500-320) = 180ns delay
      // So we wait until 180ns --10ns before edge-- then change address
      #(500-$time-10)

      WriteEn_TB = 1'b1;        // Disable writing
      Address_TB = 8'b00000010; // Assert address 0x01

      $display("%d (B) Wait for Clock edge and Data wait", $stime);
      #20 // Allow Clock edge to occur
      #10 // Wait for data

      if (DOut_TB !== 16'h2621) begin
         $display("%d %m: ERROR - (C) Memory 0x00 address has invalid value (%h).", $stime, DOut_TB);
         $finish;
      end
      $display("%d Read location 0x02", $stime);

      // ------------------------------------
      // Read memory location 0x02: ADD R3, R2, R1 <-- 0x2621
      // ------------------------------------
      // The current $time is 520ns
      // The next posEdge isn't until 700ns absolute
      // thus the next posEdge is at (700-520) = 180ns delay
      // So we wait until 180ns --10ns before edge-- then change address
      #(700-$time-10)

      WriteEn_TB = 1'b1;        // Disable writing
      Address_TB = 8'b00000011; // Assert address 0x11

      $display("%d (B) Wait for Clock edge and Data wait", $stime);
      #20 // Allow Clock edge to occur
      #10 // Wait for data

      if (DOut_TB !== 16'h1000) begin
         $display("%d %m: ERROR - (C) Memory 0x00 address has invalid value (%h).", $stime, DOut_TB);
         $finish;
      end
      $display("%d Read location 0x02", $stime);

      // =================================================================
      // ------------------------------------
      // Write to memory location 0x0A: 0x0666
      // ------------------------------------
      // The current $time is 720ns
      // The next posEdge isn't until 900ns absolute
      // thus the next posEdge is at (900-720) = 180ns delay
      // So we wait until 180ns --10ns before edge-- then change Data
      #(900-$time-10)

      WriteEn_TB = 1'b0;    // Enable writing (active LOW)
      Address_TB = 8'h0A;   // Assert address

      DIn_TB = 16'h0666;
      #10 // Allow data to settle
      #20 // Allow clock to tick
      $display("%d Write location 0x02", $stime);

      // ------------------------------------
      // Read memory location 0x0A
      // ------------------------------------
      // The current $time is 920ns
      // The next posEdge isn't until 1100ns absolute
      // thus the next posEdge is at (1100-920) = 180ns delay
      // So we wait until 180ns --10ns before edge-- then change address
      #(1100-$time-40)

      WriteEn_TB = 1'b1;    // Disable writing
      Address_TB = 8'h0A;   // Assert address

      $display("%d (B) Waiting for Clock edge and Data", $stime);
      #180 // For Sync reads we need a Clock edge to occur
      #10  // Wait a bit for data to settle

      // Now sample the output
      if (DOut_TB !== 16'h0666) begin
         $display("%d %m: ERROR - (D) Memory 0x00 address has invalid value (%h).", $stime, DOut_TB);
         $finish;
      end
      $display("%d Read location 0x02", $stime);

      // ------------------------------------
      // Simulation duration
      // ------------------------------------
      #50 $display("%d %m: Testbench simulation PASSED.", $stime);
      $finish;
   end
endmodule
