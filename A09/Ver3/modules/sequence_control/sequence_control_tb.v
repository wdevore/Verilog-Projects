`default_nettype none

// --------------------------------------------------------------------------
// Test bench
// Test the sequence control matrix up to the Loading of the IR
// --------------------------------------------------------------------------
`timescale 1ns/1ps

`define VCD_OUTPUT "/media/RAMDisk/sequence_control_tb.vcd"

`include "../../modules/sequence_control/constants.v"
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
   wire [2:0] PC_Src_TB;       // 3 Bits
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
   wire ALU_Ld_TB;
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
      .ALU_FlgsIn(ALU_Flgs_TB),
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
      .ALU_Op(ALU_Op_TB),
      .FLG_Ld(FLG_Ld_TB),
      .ALU_Ld(ALU_Ld_TB),
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
      $dumpfile(`VCD_OUTPUT);
      $dumpvars;  // Save waveforms to vcd file
      
      $display("%d %m: Starting testbench simulation...", $stime);
   end

   always begin
      // ------------------------------------
      // Reset Vector sequence
      // As long as Reset is Active (aka low) then the processor
      // remains in the reset state.
      // ------------------------------------
      $display("%d: Beginning reset", $stime);
      @(posedge Clock_TB);
      Reset_TB = 1'b0;        // Enable reset

      // "state" should remain at S_Reset
      // "vector_state" should remain at S_Vector1
      @(negedge Clock_TB);
      #10  // Wait for data

      if (ControlMatrix.state !== ControlMatrix.S_Reset) begin
         $display("%d ERROR - S_Reset ControlMatrix.state (%h).", $stime, ControlMatrix.state);
         $finish;
      end

      if (ControlMatrix.vector_state !== ControlMatrix.S_Vector1) begin
         $display("%d ERROR - S_Vector1 ControlMatrix.vector_state (%h).", $stime, ControlMatrix.vector_state);
         $finish;
      end

      // Sustaining reset state
      $display("%d: Waiting one extra cycle", $stime);
      // We will wait just one more cycle
      @(posedge Clock_TB);
      @(negedge Clock_TB);
      #10  // Wait for data

      if (ControlMatrix.state !== ControlMatrix.S_Reset) begin
         $display("%d ERROR - S_Reset 2 ControlMatrix.state (%h).", $stime, ControlMatrix.state);
         $finish;
      end

      if (ControlMatrix.vector_state !== ControlMatrix.S_Vector1) begin
         $display("%d ERROR - S_Vector1 2 ControlMatrix.vector_state (%h).", $stime, ControlMatrix.vector_state);
         $finish;
      end

      // ------------------------------------
      // Exit reset state by deactivating reset
      // ------------------------------------
      $display("%d: Exiting reset", $stime);
      @(posedge Clock_TB);
      Reset_TB = 1'b1;        // Disable reset

      // On the neg-edge we should have transitioned from vector1 to 2
      @(negedge Clock_TB);    // Now next vector_state should be S_Vector2
      #10  // Wait for data

      if (ControlMatrix.state !== ControlMatrix.S_Reset) begin
         $display("%d ERROR - S_Reset 3 ControlMatrix.state (%h).", $stime, ControlMatrix.state);
         $finish;
      end

      if (ControlMatrix.vector_state !== ControlMatrix.S_Vector2) begin
         $display("%d ERROR - S_Vector2 ControlMatrix.vector_state (%h).", $stime, ControlMatrix.vector_state);
         $finish;
      end

      // Vector state 3
      @(posedge Clock_TB);
      Reset_TB = 1'b1;        // Disable reset

      @(negedge Clock_TB); 
      #10  // Wait for data

      if (ControlMatrix.state !== ControlMatrix.S_Reset) begin
         $display("%d ERROR - S_Reset 4 ControlMatrix.state (%h).", $stime, ControlMatrix.state);
         $finish;
      end

      if (ControlMatrix.vector_state !== ControlMatrix.S_Vector3) begin
         $display("%d ERROR - S_Vector3 ControlMatrix.vector_state (%h).", $stime, ControlMatrix.vector_state);
         $finish;
      end

      // Finally Vector state 4
      @(posedge Clock_TB);
      Reset_TB = 1'b1;        // Disable reset

      @(negedge Clock_TB);
      #10  // Wait for data

      if (ControlMatrix.state !== ControlMatrix.S_Reset) begin
         $display("%d ERROR - S_Reset 5 ControlMatrix.state (%h).", $stime, ControlMatrix.state);
         $finish;
      end

      if (ControlMatrix.vector_state !== ControlMatrix.S_Vector4) begin
         $display("%d ERROR - S_Vector4 ControlMatrix.vector_state (%h).", $stime, ControlMatrix.vector_state);
         $finish;
      end

      // ------------------------------------
      // The cpu should now be ready
      // ------------------------------------
      @(posedge Clock_TB);
      Reset_TB = 1'b1;        // Disable reset

      @(negedge Clock_TB);
      #10  // Wait for data

      if (ControlMatrix.state !== ControlMatrix.S_Ready) begin
         $display("%d ERROR - S_Reset 6 ControlMatrix.state (%h).", $stime, ControlMatrix.state);
         $finish;
      end

      // Now we are ready to start the Fetch IR sequence
      if (ControlMatrix.next_state !== ControlMatrix.S_FetchPCtoMEM) begin
         $display("%d ERROR - S_FetchPCtoMEM ControlMatrix.next_state (%h).", $stime, ControlMatrix.next_state);
         $finish;
      end

      // ------------------------------------
      // Now that memory has been presented with the PC address
      // The matrix transitions to: moving the memory output
      // to the instruction register
      // ------------------------------------
      @(posedge Clock_TB);

      @(negedge Clock_TB);
      #10  // Wait for data

      if (ControlMatrix.state !== ControlMatrix.S_FetchPCtoMEM) begin
         $display("%d ERROR - S_Reset 7 ControlMatrix.state (%h).", $stime, ControlMatrix.state);
         $finish;
      end

      // Now we are ready to start the Fetch IR sequence
      if (ControlMatrix.next_state !== ControlMatrix.S_FetchMEMtoIR) begin
         $display("%d ERROR - S_FetchMEMtoIR ControlMatrix.next_state (%h).", $stime, ControlMatrix.next_state);
         $finish;
      end

      // ------------------------------------
      // Decode instruction using injection.
      // ------------------------------------
      @(posedge Clock_TB);
      // However, we don't actually have any other components in this
      // test bench so we will need to "inject" an instruction
      // as if it came from memory.
      IR_TB = 16'h9101;    // LDI R1, 0x01

      @(negedge Clock_TB);
      #10  // Wait for data

      if (ControlMatrix.state !== ControlMatrix.S_FetchMEMtoIR) begin
         $display("%d ERROR - S_Reset 8 ControlMatrix.state (%h).", $stime, ControlMatrix.state);
         $finish;
      end

      // Decoding
      if (ControlMatrix.next_state !== ControlMatrix.S_Decode) begin
         $display("%d ERROR - S_Decode ControlMatrix.next_state (%h).", $stime, ControlMatrix.next_state);
         $finish;
      end

      // ------------------------------------
      // Simulation duration
      // ------------------------------------
      #500 $display("%d %m: Testbench simulation FINISHED.", $stime);
      $finish;
   end
endmodule
