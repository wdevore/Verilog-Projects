`default_nettype none

// --------------------------------------------------------------------------
// Test bench for a fetch cycle
// --------------------------------------------------------------------------
`timescale 1ns/1ps

// `define ROM "../../roms/Count_Out.dat"
`define VCD_OUTPUT "/media/RAMDisk/cpu_tb.vcd"

module cpu_tb;
   parameter AddrWidth_TB = 8;      // 8bit Address width
   parameter DataWidth_TB = 16;     // 16bit Data width
   parameter WordSize_TB = 1;       // Instructions a 1 = 2bytes in size

   parameter V_OUTPUT = "/media/RAMDisk/cpu_tb.vcd";

   // Test bench Signals
 
   // Inputs
   reg Clock_TB;
   reg Reset_TB;
   wire CPU_Halt_TB;
   wire CPU_Ready_TB;
   wire [DataWidth_TB-1:0] OutReg_TB;

   // Debugging
   integer index;
   integer cycleCnt;

   // -------------------------------------------
   // Device under test
   // -------------------------------------------
   CPU #(
      .DataWidth(DataWidth_TB),
      .AddrWidth(AddrWidth_TB),
      .WordSize(WordSize_TB)) cpu
   (
      .Clk(Clock_TB),
      .Reset(Reset_TB),
      .Ready(CPU_Ready_TB),
      .Halt(CPU_Halt_TB),
      .OutReg(OutReg_TB)
   );
    
   // -------------------------------------------
   // Test bench clock
   // -------------------------------------------
   initial begin
      Clock_TB <= 1'b0;
      cycleCnt = 0;
   end
   
   // The clock runs until the sim finishes. #100 = 200ns clock cycle
   always begin
      #100 Clock_TB = ~Clock_TB;
   end
 
   // -------------------------------------------
   // Configure starting sim states
   // -------------------------------------------
   initial begin
      $dumpfile(`VCD_OUTPUT);  // waveforms file needs to be the same name as the tb file.
      $dumpvars;  // Save waveforms to vcd file
      
      $display("%d %m: Starting testbench simulation...", $stime);

      // Setup defaults
      Reset_TB = 1'b1;
   end
     
   always begin
      // $display("%d <-- Reset", $stime);
      // ------------------------------------
      // Reset CPU
      // ------------------------------------
      Reset_TB = 1'b0;  // Enable reset
      #200 Reset_TB = 1'b1;
      // #2000 Reset_TB = 1'b0;
      // #200 Reset_TB = 1'b1;

      wait(cpu.ControlMatrix.state === cpu.ControlMatrix.S_Ready);
      $display("%d <-- CPU is ready", $stime);
     
      // Check memory was loaded
      // if (cpu.memory.mem[0] === 16'h0 || cpu.memory.mem[0] === {DataWidth_TB{1'bx}}) begin
      //    $display("%d %m: ###ERROR### - Memory doesn't appear to be loaded", $time);
      //    // $finish;
      // end
  
      // `include "tests/add_halt.v"
      // `include "tests/sub_halt.v"
   
      #30000;

      $display("------- Reg File contents ------");
      for(index = 0; index < 8; index = index + 1)
         $display("Reg [%h] = %b <- 0x%h", index, cpu.RegFile.reg_file[index], cpu.RegFile.reg_file[index]);

      $display("------- Memory contents ------");
      for(index = 0; index < 15; index = index + 1)
         $display("memory [%h] = %b <- 0x%h", index, cpu.memory.mem[index], cpu.memory.mem[index]);
     
      $display("------- Output contents ------");
      $display("Output {%h}", cpu.output_port);
       
      // ------------------------------------
      // Simulation END
      // ------------------------------------
      #100 $display("%d %m: Testbench simulation FINISHED.", $stime);
      $finish;
   end
endmodule
