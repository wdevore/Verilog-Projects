`default_nettype none

// --------------------------------------------------------------------------
// A Fetch cycle module used for testing only
// The cycle is 2 clocks in duration
// --------------------------------------------------------------------------

// PC -> MUX_ADDR -> Memory -> IR

`include "../../modules/program_counter/pc.v"
`include "../../modules/mux/mux.v"
`include "../../modules/memory/memory.v"
`include "../../modules/register/register.v"

module FetchCycle
#(
    parameter DataWidth = 8,
    parameter AddrWidth = 8,
    parameter WordSize = 1,
    parameter SelectSize = 1)
(
    input wire [AddrWidth-1:0] DIn,  // Input to PC
    input wire Reset,                // Active Low
    input wire Clk,
    input wire [SelectSize-1:0] ADDR_Src,   // 2bit controls MUX_ADDR
    input wire PC_Ld,                       // Load: Active Low
    input wire PC_Inc,                      // Load: Active Low
    input wire IR_Ld,                       // Load: Active Low
    input wire MEM_RW,                      // Load: Write = Active Low
    input wire MEM_En,                      // Load: Active Low
    output wire [DataWidth-1:0] IROut       // IR Output
);

// --------------------------------------------------
// Internal connects
// --------------------------------------------------
wire [AddrWidth-1:0] pc_to_mux;
wire [AddrWidth-1:0] mux_to_mem_addr;
wire [DataWidth-1:0] mem_to_ir;

// Create PC and bind to data input and controls
ProgramCounter #(
    .DataWidth(AddrWidth),
    .WordByteSize(WordSize)) PC
(
    .Reset(Reset),
    .Clk(Clk),
    .LD(PC_Ld),
    .Inc(PC_Inc),
    .DIn(DIn),
    .DOut(pc_to_mux)
);

// Create MUX_ADDR and connect to PC
Mux #(
    .DataWidth(AddrWidth),
    .SelectSize(SelectSize)) MUX_ADDR
(
    .Select(ADDR_Src),
    .DIn0(pc_to_mux),
    .DIn1({AddrWidth{1'b0}}),
    .DIn2({AddrWidth{1'b0}}),
    .DIn3({AddrWidth{1'b0}}),
    .DOut(mux_to_mem_addr)
);

// Create memory and connect to IR 
Memory #(.AddrWidth(AddrWidth)) memory(
    .DIn({DataWidth{1'b0}}),  // Not relevant, so just use 0
    .Address(mux_to_mem_addr),
    .Write_EN(MEM_RW),
    .Clk(Clk),
    .DOut(mem_to_ir)
);

// Create IR and connect to putput
Register #(.DataWidth(DataWidth)) IR
(
    .Reset(Reset),
    .Clk(Clk),
    .LD(IR_Ld),
    .DIn(mem_to_ir),
    .DOut(IROut)
);

endmodule
