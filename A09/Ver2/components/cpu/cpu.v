`default_nettype none

`define SIMULATE

// --------------------------------------------------------------------------
// A09 CPU module
// --------------------------------------------------------------------------
`include "../../modules/sequence_control/constants.v"

// Components/Modules needed to construct CPU
`include "../../modules/program_counter/pc.v"
`include "../../modules/mux/mux.v"
`include "../../modules/memory/memory.v"
`include "../../modules/register/register.v"
`include "../../modules/register_file/register_file.v"
`include "../../modules/sequence_control/sequence_control.v"
`include "../../modules/alu/alu.v"

module CPU
#(
    parameter DataWidth = 16,        // Data path width
    parameter AddrWidth = 8,        // Address range 2^8 = 256 bytes
    parameter WordSize = 1,         // Word size when Inc PC. 1 = 2bytes
    parameter RegFileSelectSize = 3 // Max register count, 2^3 = 8 regs
)
(
    input wire Clk,
    input wire Reset,
    output wire Ready,
    output wire Halt,
    output wire IR_Ld,
    output wire Mem_En,
    output wire Output_Ld,
    output wire [DataWidth-1:0] IR_Out,
    output wire [DataWidth-1:0] OutReg
);

localparam ALUOpsSize = 4;
localparam ALUFlagSize = 4;

// AddrSize is the number of bits for an address
localparam AddrSize = 8;

// --------------------------------------------------
// Internal signals (a.k.a. wires) between modules
// --------------------------------------------------
wire [DataWidth-1:0] pc_to_out;
wire [DataWidth-1:0] mux_pc_to_pc;
wire [DataWidth-1:0] mem_to_out;

wire [DataWidth-1:0] mux_bra_to_alu2;
wire [DataWidth-1:0] mux_addr_to_mem_addr;
wire [DataWidth-1:0] mux_data_to_regfile;
wire [DataWidth-1:0] mux_out_to_output;

wire [DataWidth-1:0] stk_to_mux_pc;
wire [DataWidth-1:0] source1;
wire [DataWidth-1:0] source2;

wire [DataWidth-1:0] absoluteZeroExtH;
wire [DataWidth-1:0] absoluteZeroExtL;
wire [DataWidth-1:0] relativeSignedExt;
wire [DataWidth-1:0] branchAddress;

wire [DataWidth-1:0] output_port;

wire [DataWidth-1:0] alu_res_to_mux_data;
wire [DataWidth-1:0] alu_to_out;
wire [ALUFlagSize-1:0] alu_to_flags;

// ---------------------------------------------------
// Control matrix signals
// ---------------------------------------------------
// Branch and Stack
wire stk_ld;
wire bra_src;
// IR
// wire ir_ld;
wire [DataWidth-1:0] ir;
// PC
wire pc_ld;
wire pc_rst;
wire pc_inc;
wire [1:0] pc_src;       // 2Bits
// Memory
wire mem_wr;
// wire mem_en;
wire [1:0] addr_src;     // 2Bits
// Regster File
wire reg_we;
wire [1:0] data_src;     // 2Bits
wire [RegFileSelectSize-1:0] reg_dest;     // 3Bits
wire [RegFileSelectSize-1:0] reg_src1;
wire [RegFileSelectSize-1:0] reg_src2;
wire src1_sel;
// ALU
wire [ALUFlagSize-1:0] alu_flgs_to_scm;
wire [ALUOpsSize-1:0] alu_op;       // ALU operation: ADD, SUB etc.
wire flg_ld;
wire alu_ld;
wire flg_rst;
// Output
// wire output_ld;
wire [1:0] out_sel;     // 2Bits

wire [2:0] destReg;

// IR bit fields
`define DestRegLDI      ir[10:8]    // For LDI instruction
`define DestReg         ir[8:6]
`define Src2Reg         ir[5:3]
`define Src1Reg         ir[2:0]

`define Instr    ir[15:11]

`define AddrH    ir[10:3]           // zero-extend-H
`define AddrL    ir[AddrSize-1:0]   // zero-extend-L

// Zero extend higher/middle absolute address bits from the IR register.
assign absoluteZeroExtH = {{DataWidth-AddrSize{1'b0}}, `AddrH};
// Zero extend lower absolute address bits from the IR register.
assign absoluteZeroExtL = {{DataWidth-AddrSize{1'b0}}, `AddrL};

// Sign extend the lower signed address bit from the IR register.
// assign relativeSignedExt = (ir[SignedAddrSize] == 1) ? {{DataWidth-SignedAddrSize{1'b1}}, `SignedAddr} : {{DataWidth-SignedAddrSize{1'b0}}, `SignedAddr};
// OR
assign relativeSignedExt = {{DataWidth-AddrSize{ir[AddrSize-1]}}, `AddrL};

// To generate the branch address we need to subtract 1 from the PC
// because the PC has been auto-incremented to the next address which
// means it isn't at the current address.
assign branchAddress = mux_bra_to_alu2 + (pc_to_out - WordSize);

assign OutReg = output_port;

assign IR_Out = ir;

// MUX_DST
assign destReg = (`Instr == `LDI || `Instr == `LD) ? `DestRegLDI : `DestReg;

// -------- Module ------------------------------------------
// Sequence control matrix
// ----------------------------------------------------------
SequenceControl #(.DataWidth(DataWidth)) ControlMatrix
(
    .Clk(Clk),
    .Reset(Reset),
    .IR(ir),
    .STK_Ld(stk_ld),
    .BRA_Src(bra_src),
    .IR_Ld(IR_Ld),
    .PC_Ld(pc_ld),
    .PC_Rst(pc_rst),
    .PC_Inc(pc_inc),
    .PC_Src(pc_src),
    .MEM_Wr(mem_wr),
    .MEM_En(Mem_En),
    .ADDR_Src(addr_src),
    .REG_WE(reg_we),
    .DATA_Src(data_src),
    .REG_Dest(reg_dest),
    .REG_Src1(reg_src1),
    .REG_Src2(reg_src2),
    .Src1_Sel(src1_sel),
    .ALU_Op(alu_op),
    .ALU_FlgsIn(alu_flgs_to_scm),
    .FLG_Ld(flg_ld),
    .ALU_Ld(alu_ld),
    .FLG_Rst(flg_rst),
    .OUT_Ld(Output_Ld),
    .OUT_Sel(out_sel),
    .Ready(Ready),
    .Halt(Halt)
);

// -------- Module ------------------------------------------
// Create PC and bind to data input and controls
// ----------------------------------------------------------
ProgramCounter #(
    .DataWidth(DataWidth),
    .WordByteSize(WordSize)) PC
(
    .Clk(Clk),
    .Reset(pc_rst),
    .LD(pc_ld),
    .Inc(pc_inc),
    .DIn(mux_pc_to_pc),
    .DOut(pc_to_out)
);

// -------- Module ------------------------------------------
// Create memory and connect to IR 
// ----------------------------------------------------------
Memory #(.AddrWidth(AddrWidth)) memory(
    .Clk(Clk),
    .DIn(source1),              // Register file src 1
    .Address(mux_addr_to_mem_addr[AddrWidth-1:0]),
    .Write_EN(mem_wr),
    .Mem_En(Mem_En),
    .DOut(mem_to_out)
);

// -------- Module ------------------------------------------
// Create register file and connect to ALU
// ----------------------------------------------------------
RegisterFile #(.DataWidth(DataWidth)) RegFile
(
    .Clk(Clk),
    .REG_WE(reg_we),
    .DIn(mux_data_to_regfile),
    .REG_Dst(destReg),          // IR[8:6] or IR[10:8]
    .REG_Src1(`Src1Reg),
    .REG_Src2(`Src2Reg),
    .SRC1(source1),             // Output
    .SRC2(source2)              // Output
);

// -------- Module ------------------------------------------
// Create ALU and connect to Register file and memory
// ----------------------------------------------------------
ALU #(.DataWidth(DataWidth)) Alu(
    .IFlags({ALUFlagSize{1'b0}}),    // Not used yet
    .A(source1),
    .B(source2),
    .FuncOp(alu_op),
    .Y(alu_to_out),
    .OFlags(alu_to_flags)
);

// ======================================================
// Multiplexers
// ======================================================

// -------- Module ------------------------------------------
// Create MUX_ADDR and connect to PC and Memory
// ----------------------------------------------------------
Mux #(
    .DataWidth(DataWidth),
    .SelectSize(2)) MUX_ADDR
(
    .Select(addr_src),
    .DIn0(pc_to_out),           // PC source
    .DIn1(source2),             // Source 2
    .DIn2(absoluteZeroExtL),    // zero extended lower
    .DIn3(absoluteZeroExtH),    // zero extended higher
    .DOut(mux_addr_to_mem_addr)
);

Mux #(
    .DataWidth(DataWidth),
    .SelectSize(2)) MUX_PC
(
    .Select(pc_src),
    .DIn0(branchAddress),       // Branch address
    .DIn1(stk_to_mux_pc),       // Return address
    .DIn2(source1),             // Register file src 1 (address)
    .DIn3({DataWidth{1'b0}}),   // Unused
    .DOut(mux_pc_to_pc)
);

Mux #(
    .DataWidth(DataWidth),
    .SelectSize(1)) MUX_BRA
(
    .Select(bra_src),
    .DIn0(source1),             // Register file src 1
    .DIn1(relativeSignedExt),   // sign extended
    .DIn2({DataWidth{1'b0}}),   // Unused
    .DIn3({DataWidth{1'b0}}),   // Unused
    .DOut(mux_bra_to_alu2)
);

Mux #(
    .DataWidth(DataWidth),
    .SelectSize(2)) MUX_DATA
(
    .Select(data_src),
    .DIn0(absoluteZeroExtL),    // zero extended lower
    .DIn1(mem_to_out),          // Memory data out
    .DIn2(alu_res_to_mux_data), // ALU output
    .DIn3(source1),             // Register file src 1
    .DOut(mux_data_to_regfile)
);

Mux #(
    .DataWidth(DataWidth),
    .SelectSize(2)) MUX_OUT
(
    .Select(out_sel),
    .DIn0(mem_to_out),          // Memory
    .DIn1(source1),             // Reg-File
    .DIn2({DataWidth{1'b0}}),   // Unused 
    .DIn3({DataWidth{1'b0}}),   // Unused
    .DOut(mux_out_to_output)
);

// ======================================================
// Registers
// ======================================================

// -------- Module ------------------------------------------
// Create IR and connect to putput
// ----------------------------------------------------------
Register #(.DataWidth(DataWidth)) IR
(
    .Clk(Clk),
    .Reset(Reset),
    .LD(IR_Ld),
    .DIn(mem_to_out),
    .DOut(ir)
);

Register #(.DataWidth(DataWidth)) Stack
(
    .Clk(Clk),
    .Reset(Reset),
    .LD(stk_ld),
    .DIn(pc_to_out),    // No need adjust PC because it sits at the next addr.
    .DOut(stk_to_mux_pc)
);

Register #(.DataWidth(DataWidth)) ALUResults
(
    .Clk(Clk),
    .Reset(Reset),
    .LD(alu_ld),
    .DIn(alu_to_out),       // ALU output
    .DOut(alu_res_to_mux_data)
);

// The ALU flags could feed the control matrix and
// feed back into the ALU, however, for A09 only,
// the control matrix is feed.
Register #(.DataWidth(ALUFlagSize)) ALU_Flags
(
    .Clk(Clk),
    .Reset(flg_rst),        // Typically reset after Branch instructions
    .LD(flg_ld),
    .DIn(alu_to_flags),
    .DOut(alu_flgs_to_scm)
);

// Output register. The output wires are typically connected to FPGA pins.
Register #(.DataWidth(DataWidth)) OutputR
(
    .Clk(Clk),
    .Reset(Reset),
    .LD(Output_Ld),
    .DIn(mux_out_to_output),       // ALU output
    .DOut(output_port)
);

endmodule
