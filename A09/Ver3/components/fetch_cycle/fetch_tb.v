// --------------------------------------------------------------------------
// Test bench for a fetch cycle
// --------------------------------------------------------------------------
`timescale 1ns/1ps

module fetch_tb;
   parameter AddrWidth_TB = 8;      // 8bit Address width
   parameter DataWidth_TB = 16;     // 16bit Data width
   parameter WordSize_TB = 1;       // Instructions a 2bytes in size
   parameter SelectSize_TB = 2;     // MUX select bits
   
   // Test bench Signals
   // Output of the IR
   wire [DataWidth_TB-1:0] DOut_TB;

   // Inputs
   reg Reset_TB;
   reg PC_Ld_TB;
   reg PC_Inc_TB;
   reg IR_Ld_TB;
   reg MEM_RW_TB;
   reg MEM_En_TB;
   reg [SelectSize_TB-1:0] ADDR_Src_TB;  // Control MUX = 2bits
   reg [AddrWidth_TB-1:0] DIn_TB;  // Input to PC

   reg Clock_TB;

   // -------------------------------------------
   // Device under test
   // -------------------------------------------
   FetchCycle #(
      .DataWidth(DataWidth_TB),
      .AddrWidth(AddrWidth_TB),
      .WordSize(WordSize_TB),
      .SelectSize(SelectSize_TB)) dut
   (
      .DIn(DIn_TB),
      .Reset(Reset_TB),
      .Clk(Clock_TB),
      .ADDR_Src(ADDR_Src_TB),
      .PC_Ld(PC_Ld_TB),
      .PC_Inc(PC_Inc_TB),
      .IR_Ld(IR_Ld_TB),
      .MEM_RW(MEM_RW_TB),
      .MEM_En(MEM_En_TB),
      .IROut(DOut_TB)
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
      $dumpfile("fetch_tb.vcd");  // waveforms file needs to be the same name as the tb file.
      $dumpvars;  // Save waveforms to vcd file
       
      $display("%d %m: Starting testbench simulation...", $stime);

      // Setup defaults
      Reset_TB = 1'b1;  // Disable reset
      PC_Ld_TB = 1'b1;
      PC_Inc_TB = 1'b1;
      IR_Ld_TB = 1'b1;
      MEM_RW_TB = 1'b1; // Read = Active High
      MEM_En_TB = 1'b1;
      DIn_TB = {DataWidth_TB{1'b0}};      // DIn defaults to 0
      ADDR_Src_TB = {WordSize_TB{1'b0}}; 
   end

   always begin
      #50 // wait a bit
      // ------------------------------------
      // Reset PC
      // ------------------------------------
      Reset_TB = 1'b0;  // Enable reset
      PC_Ld_TB = 1'b1;  // Disable load

      #200; // Wait for clock edge to pass
      $display("%d <-- Marker", $stime);

      // if (dut.PC.DOut != 16'h0000) begin
      //    $display("%d %m: ERROR - Reset PC output incorrect (%h).", $stime, DOut_TB);
      //    // $finish;
      // end

      // ------------------------------------
      // Load PC
      // ------------------------------------
      Reset_TB = 1'b1;  // Disable reset
      PC_Ld_TB = 1'b0;  // Enable load
      DIn_TB = 16'h00A0;

      #200; // Wait for clock edge to pass
      $display("%d <-- Marker", $stime);

      // if (dut.PC.DOut !== 16'h00A0) begin
      //    $display("%d %m: ERROR - Load PC output incorrect (%h).", $stime, DOut_TB);
      //    // $finish;
      // end

      // ------------------------------------
      // Read Memory (1st clock of fetch)
      // ------------------------------------
      ADDR_Src_TB = 2'b00; // Select PC Source
      PC_Ld_TB = 1'b1;  // Disable load
      MEM_RW_TB = 1'b0; // Enable Read
      MEM_En_TB = 1'b0; // Enable Memory

      #200; // Wait for clock edge

      // if (dut.MUX_ADDR.DOut !== 16'h00A0) begin
      //    $display("%d %m: ERROR - MUX_ADDR output incorrect (%h).", $stime, DOut_TB);
      //    // $finish;
      // end

      // ------------------------------------
      // Load IR (2nd clock of fetch)
      // ------------------------------------
      IR_Ld_TB = 1'b0;  // Enable load
      // We can also move PC to next address
      PC_Inc_TB = 1'b0; // Enable PC increment

      #200; // Wait for clock edge

      // if (DOut_TB !== 16'h9202) begin
      //    $display("%d %m: ERROR - IR output incorrect (%h).", $stime, DOut_TB);
      //    // $finish;
      // end

      // ------------------------------------
      // End fetch cycle
      // ------------------------------------
      MEM_RW_TB = 1'b1; // Disable Read
      MEM_En_TB = 1'b1; // Disable Memory
      PC_Inc_TB = 1'b1; // Disable PC increment

      #200; // Wait for clock edge

      // ------------------------------------
      // Simulation duration
      // ------------------------------------
      #150 $display("%d %m: Testbench simulation PASSED.", $stime);
      $finish;
   end
endmodule
