`default_nettype none

// --------------------------------------------------------------------------
// Test bench
// Test the sequence control matrix up to the Loading of the IR
// --------------------------------------------------------------------------
`timescale 1ns/1ps

`include "../../modules/program_counter/pc.v"


module sequence_control_tb;
   parameter Data_WIDTH = 16;                 // data width
   parameter SelectSize = 3;
   parameter ALUFlagSize = 4;
   parameter ALUOpsSize = 4;
   parameter RegFileSelectSize = 3;
   parameter AddrWidth = 8;      // 8bit Address width
   parameter WordSize = 2;       // Instructions a 2bytes in size

   // Test bench Signals
   // --- Outputs---
   // Branch and Stack
   wire STK_Ld_TB;
   wire BRA_Src_TB;
   // IR
   wire IR_Ld_TB;
   // PC
   wire PC_Ld_TB;
   wire PC_Rst_TB;
   wire PC_Inc_TB;
   wire [1:0] PC_Src_TB;       // 2Bits
   // Memory
   wire MEM_Wr_TB;
   wire MEM_En_TB;
   wire [1:0] ADDR_Src_TB;     // 2Bits
   // Regster File
   wire REG_WE_TB;
   wire [1:0] DATA_Src_TB;     // 2Bits
   wire [RegFileSelectSize-1:0] REG_Dest_TB;     // 3Bits
   wire [RegFileSelectSize-1:0] REG_Src1_TB;
   wire [RegFileSelectSize-1:0] REG_Src2_TB;
   wire Src1_Sel_TB;
   // ALU
   wire [ALUOpsSize-1:0] ALU_Op_TB;       // ALU operation: ADD, SUB etc.
   wire FLG_Ld_TB;
   wire FLG_Rst_TB;
   // Misc
   wire Halt_TB;               // Active High

   wire [Data_WIDTH-1:0] PC_DOut_TB;

   // --- Inputs ---
   reg [Data_WIDTH-1:0] IR_TB;
   reg [ALUFlagSize-1:0] ALU_Flgs_TB;
   reg Reset_TB;

   reg Clock_TB;

   // -------------------------------------------
   // Devices under test
   // -------------------------------------------
   SequenceControl #(.DataWidth(Data_WIDTH)) ControlMatrix
   (
      .Clk(Clock_TB),
      .IR(IR_TB),
      .ALU_Flgs(ALU_Flgs_TB),
      .Reset(Reset_TB),
      .STK_Ld(STK_Ld_TB),
      .BRA_Src(BRA_Src_TB),
      .IR_Ld(IR_Ld_TB),
      .PC_Ld(PC_Ld_TB),
      .PC_Rst(PC_Rst_TB),
      .PC_Inc(PC_Inc_TB),
      .PC_Src(PC_Src_TB),
      .MEM_Wr(MEM_Wr_TB),
      .MEM_En(MEM_En_TB),
      .ADDR_Src(ADDR_Src_TB),
      .REG_WE(REG_WE_TB),
      .DATA_Src(DATA_Src_TB),
      .REG_Dest(REG_Dest_TB),
      .REG_Src1(REG_Src1_TB),
      .REG_Src2(REG_Src2_TB),
      .Src1_Sel(Src1_Sel_TB),
      .ALU_Op(ALU_Op_TB),
      .FLG_Ld(FLG_Ld_TB),
      .FLG_Rst(FLG_Rst_TB),
      .Halt(Halt_TB)
   );

   ProgramCounter #(
      .DataWidth(Data_WIDTH),
      .WordByteSize(WordSize)) PC
   (
      .Clk(Clock_TB),
      .Reset(PC_Rst_TB),
      .LD(PC_Ld_TB),
      .Inc(PC_Inc_TB),
      .DIn({Data_WIDTH{1'b0}}),
      .DOut(PC_DOut_TB)
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
      $dumpfile("sequence_control_tb.vcd");  // waveforms file needs to be the same name as the tb file.
      $dumpvars;  // Save waveforms to vcd file
      
      $display("%d %m: Starting testbench simulation...", $stime);
   end

   always begin
      #50; // Pause for a bit

      // Controller should be ready to start idling
      $display("%d <-- ControlMatrix.next_state at", $stime);
      if (ControlMatrix.next_state !== 3'b110) begin
         $display("%d ERROR - Ready: ControlMatrix.next_state (%h).", $stime, ControlMatrix.next_state);
         $finish;
      end

      #200;
      // Controller should be idling
      $display("%d <-- 1 ControlMatrix.state at", $stime);
      if (ControlMatrix.state !== 3'b110) begin
         $display("%d ERROR - ControlMatrix.state (%h).", $stime, ControlMatrix.state);
         $finish;
      end

      // ------------------------------------
      // Allow Seq controller to Idle for a few clocks
      // ------------------------------------
      #300;

      // ------------------------------------
      // Reset controller
      // ------------------------------------
      Reset_TB = 1'b0;        // Enable reset
      $display("%d <-- Resetting at", $stime);
      // Allow a clock cycle to pass
      #200;
      Reset_TB = 1'b1;        // Disable reset

      // ======== State transition ===========
      $display("%d <-- State transition at", $stime);

      // Controller should have transitioned to "Reset"
      $display("%d <-- S_Reset ControlMatrix.state at", $stime);
      if (ControlMatrix.state !== 3'b000) begin
         $display("%d ERROR - S_Reset ControlMatrix.state (%h).", $stime, ControlMatrix.state);
         $finish;
      end

      // And also set the next state to "PC to Mem"
      $display("%d <-- S_FetchPCtoMEM ControlMatrix.next_state at", $stime);
      if (ControlMatrix.next_state !== 3'b001) begin
         $display("%d ERROR - S_Reset ControlMatrix.next_state (%h).", $stime, ControlMatrix.next_state);
         $finish;
      end

      $display("%d <-- PC_Rst_TB == 0 at", $stime);
      if (PC_Rst_TB !== 1'b0) begin
         $display("%d ERROR - PC_Rst (%h).", $stime, PC_Rst_TB);
         $finish;
      end

      #50; // Wait a bit and sample PC_DOut

      // It should be in an indeterminate state
      $display("%d <-- PC_DOut_TB prior reset at", $stime);
      if (PC_DOut_TB !== 16'hxxxx) begin
         $display("%d ERROR - xxxx PC_DOut_TB (%h).", $stime, PC_DOut_TB);
         $finish;
      end

      #50; // Now wait for negedge of clock where

      // PC actually resets to 0
      $display("%d <-- PC_DOut_TB reset at", $stime); // 850ns
      if (PC_DOut_TB !== 16'h0000) begin
         $display("%d ERROR - PC_DOut_TB (%h).", $stime, PC_DOut_TB);
         $finish;
      end

      // On the next posedge (900ns) the controller's state
      // should change to 3'b001 = "Fetch PC to MEM"
      #50; // Put us at 900ns
      #10;  // Wait for Delays
      
      // ======== State transition ===========
      $display("%d <-- State transition at", $stime);

      // Controller should have transitioned to "S_FetchPCtoMEM"
      $display("%d <-- S_FetchPCtoMEM ControlMatrix.state at", $stime);
      if (ControlMatrix.state !== 3'b001) begin
         $display("%d ERROR - S_FetchPCtoMEM ControlMatrix.state (%h).", $stime, ControlMatrix.state);
         // $finish;
      end

      // And also set the next state to "PC to Mem"
      $display("%d <-- S_FetchMEMtoIR ControlMatrix.next_state at", $stime);
      if (ControlMatrix.next_state !== 3'b010) begin
         $display("%d ERROR - S_FetchMEMtoIR ControlMatrix.next_state (%h).", $stime, ControlMatrix.next_state);
         // $finish;
      end

      // In the new sequence state the following signals be active
      $display("%d <-- PC_Rst_TB == 1 at", $stime);
      if (PC_Rst_TB !== 1'b1) begin
         $display("%d ERROR - PC_Rst_TB (%h).", $stime, PC_Rst_TB);
         // $finish;
      end

      $display("%d <-- MEM_Wr_TB at", $stime);
      if (MEM_Wr_TB !== 1'b1) begin
         $display("%d ERROR - MEM_Wr_TB (%h).", $stime, MEM_Wr_TB);
         // $finish;
      end

      $display("%d <-- MEM_En_TB at", $stime);
      if (MEM_En_TB !== 1'b0) begin
         $display("%d ERROR - MEM_En_TB (%h).", $stime, MEM_En_TB);
         // $finish;
      end

      $display("%d <-- ADDR_Src_TB at", $stime);
      if (ADDR_Src_TB !== 2'b00) begin
         $display("%d ERROR - ADDR_Src_TB (%h).", $stime, ADDR_Src_TB);
         // $finish;
      end

      #100; // Put us just past the 1000ns negedge
      // This means the target component (aka memory) 
      // has reacted to the neg-edge
      $display("%d <-- Neg-edge at", $stime);
      // Memory should have output the first instruction

      // ======== State transition ===========
      #100; // Put us just past 1100ns posedge
      $display("%d <-- State transition at", $stime);

      // Controller should have transitioned to "S_FetchMEMtoIR"
      $display("%d <-- S_FetchMEMtoIR ControlMatrix.state at", $stime);
      if (ControlMatrix.state !== 3'b010) begin
         $display("%d ERROR - S_FetchMEMtoIR ControlMatrix.state (%h).", $stime, ControlMatrix.state);
         // $finish;
      end

      $display("%d <-- S_Decode ControlMatrix.next_state at", $stime);
      if (ControlMatrix.next_state !== 3'b011) begin
         $display("%d ERROR - S_Decode ControlMatrix.next_state (%h).", $stime, ControlMatrix.next_state);
         // $finish;
      end

      #500;


      // ------------------------------------
      // Simulation duration
      // ------------------------------------
      #200 $display("%d %m: Testbench simulation FINISHED.", $stime);
      $finish;
   end
endmodule
