`default_nettype none

// --------------------------------------------------------------------------
// Test bench for a fetch cycle
// --------------------------------------------------------------------------
`timescale 1ns/1ps

// `define ROM "../../roms/Count_Out.dat"

module cpu_tb;
   parameter AddrWidth_TB = 8;      // 8bit Address width
   parameter DataWidth_TB = 16;     // 16bit Data width
   parameter WordSize_TB = 1;       // Instructions a 1 = 2bytes in size
   
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
      $dumpfile("cpu_tb.vcd");  // waveforms file needs to be the same name as the tb file.
      $dumpvars;  // Save waveforms to vcd file
       
      $display("%d %m: Starting testbench simulation...", $stime);

      // Setup defaults
      Reset_TB = 1'b1;
   end
   
   always begin
      $display("%d <-- Reset", $stime);
      // ------------------------------------
      // Reset CPU
      // ------------------------------------
      #50 Reset_TB = 1'b0;  // Enable reset

      #300 Reset_TB = 1'b1;  // Disable reset

      wait(cpu.ControlMatrix.state === cpu.ControlMatrix.S_Ready);
 
      $display("%d <-- CPU ready", $stime);
   
      // Check memory was loaded
      if (cpu.memory.mem[0] === 16'h0 || cpu.memory.mem[0] === {DataWidth_TB{1'bx}}) begin
         $display("%d %m: ###ERROR### - Memory doesn't appear to be loaded", $time);
         // $finish;
      end
 
      // ---------------------------------------------------
      // Wait for the beginning of an instruction.
      // ---------------------------------------------------
      // This can be detected by checking both the current state and next-state
      // wait(cpu.ControlMatrix.state === cpu.ControlMatrix.S_FetchPCtoMEM && cpu.ControlMatrix.next_state === cpu.ControlMatrix.S_FetchMEMtoIR);
      // $display("%d <-- Instruction (%d) at", $stime, cycleCnt);
      // cycleCnt++;
      
      // `include "tests/add_halt.v"
      // `include "tests/sub_halt.v"
   
      // Wait for Halt to complete. Waiting on a posedge will
      // conflicts with other waits that occur at the same time,
      // so we wait on the neg-edge.
      @(negedge CPU_Halt_TB)
      $display("%d %m: Halt un-triggered", $stime);

      // Use this if the simulation goes into a "run-away"
      // (i.e. Halt is never reached)
      #10000;
     
      $display("------- Reg File contents ------");
      for(index = 0; index < 8; index = index + 1)
         $display("Reg [%h] = %b <- 0x%h", index, cpu.RegFile.reg_file[index], cpu.RegFile.reg_file[index]);
    
      $display("------- Memory contents ------");
      for(index = 0; index < 15; index = index + 1)
         $display("memory [%h] = %b <- 0x%h", index, cpu.memory.mem[index], cpu.memory.mem[index]);

      $display("------- Output contents ------");
      $display("Output {%h}", cpu.output_port);
      
      //  #10000 $finish; 
   
      // ------------------------------------
      // Simulation END
      // ------------------------------------
      #300 $display("%d %m: Testbench simulation FINISHED.", $stime);
      $finish;
   end
endmodule
