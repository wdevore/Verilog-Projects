`default_nettype none

// --------------------------------------------------------------------------
// Test bench
// Test the sequence control matrix
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

   `include "tests/reset_sequence.v"
endmodule
