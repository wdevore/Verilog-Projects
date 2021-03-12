`default_nettype none

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
    parameter DataWidth = 8,        // Data path width
    parameter AddrWidth = 8,        // Address range 2^8 = 256 bytes
    parameter WordSize = 1,         // Word size when Inc PC. 1 = 2bytes
    parameter RegFileSelectSize = 3 // Max register count, 2^3 = 8 regs
)
(
    input wire Clk,
    input wire Reset
);

parameter ALUOpsSize = 4;
parameter ALUFlagSize = 4;

// AbsoluteAddrSize is the number of bits from the lower portion of the IR
// register for absolute movement
parameter AbsoluteAddrSize = 9;

// SignedSize is the number of bits from the lower portion of the IR
// register for signed movement
parameter SignedAddrSize = 10;

// --------------------------------------------------
// Internal signals (a.k.a. wires) between modules
// --------------------------------------------------
wire [DataWidth-1:0] pc_to_out;
wire [DataWidth-1:0] mux_pc_to_pc;
wire [DataWidth-1:0] mem_to_out;
wire [DataWidth-1:0] mux_bra_to_alu2;
wire [DataWidth-1:0] mux_addr_to_mem_addr;
wire [DataWidth-1:0] mux_data_to_regfile;
wire [DataWidth-1:0] stk_to_mux_pc;
wire [ALUFlagSize-1:0] alu_to_flags;
wire [DataWidth-1:0] alu_to_out;
wire [DataWidth-1:0] source1;
wire [DataWidth-1:0] source2;
wire [DataWidth-1:0] absoluteZeroExt;
wire [DataWidth-1:0] relativeSignedExt;
wire [DataWidth-1:0] branchAddress;
wire [DataWidth-1:0] alu_res_to_mux_data;

// ---------------------------------------------------
// Control matrix signals
// ---------------------------------------------------
// Branch and Stack
wire stk_ld;
wire bra_src;
// IR
wire ir_ld;
wire [DataWidth-1:0] ir;
// PC
wire pc_ld;
wire pc_rst;
wire pc_inc;
wire [1:0] pc_src;       // 2Bits
// Memory
wire mem_wr;
wire mem_en;
wire [1:0] addr_src;     // 2Bits
// Regster File
wire reg_we;
wire [1:0] data_src;     // 2Bits
wire [RegFileSelectSize-1:0] reg_dest;     // 3Bits
wire [RegFileSelectSize-1:0] reg_src1;
wire [RegFileSelectSize-1:0] reg_src2;
wire [RegFileSelectSize-1:0] mux_src1_to_reg_src1;
wire src1_sel;
// ALU
wire [ALUFlagSize-1:0] alu_flgs_to_scm;
wire [ALUOpsSize-1:0] alu_op;       // ALU operation: ADD, SUB etc.
wire flg_ld;
wire alu_ld;
wire flg_rst;
// Misc
wire halt;               // Active High

// IR bit fields
`define DestReg         ir[11:9]
`define Src1Reg         ir[2:0]
`define Src2Reg         ir[6:4]
`define AbsoluteAddr    ir[AbsoluteAddrSize-1:0]
`define SignedAddr      ir[SignedAddrSize-1:0]
// CN = (‘b00), BNE (‘b01), BLT (‘b10), BCS (‘b11)
`define CN              ir[11:10]       // Branch Condition type
// A Jump can store the return address (a.k.a Link) which
// provides for returning using RET 
`define JPLink          ir[11]          // Link=1 or not Link=0

// Zero extend lower absolute address bits from the IR register.
assign absoluteZeroExt = {{DataWidth-AbsoluteAddrSize{1'b0}}, `AbsoluteAddr};

// Sign extend the lower signed address bit from the IR register.
// assign relativeSignedExt = (ir[SignedAddrSize] == 1) ? {{DataWidth-SignedAddrSize{1'b1}}, `SignedAddr} : {{DataWidth-SignedAddrSize{1'b0}}, `SignedAddr};
// OR
assign relativeSignedExt = {{DataWidth-SignedAddrSize{ir[SignedAddrSize-1]}}, `SignedAddr};

// To generate the branch address we need to subtract 1 from the PC
// because the PC has been auto-incremented to the next address which
// means it isn't at the current address.
assign branchAddress = mux_bra_to_alu2 + (pc_to_out - WordSize);

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
    .IR_Ld(ir_ld),
    .PC_Ld(pc_ld),
    .PC_Rst(pc_rst),
    .PC_Inc(pc_inc),
    .PC_Src(pc_src),
    .MEM_Wr(mem_wr),
    .MEM_En(mem_en),
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
    .Halt(halt)
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
    .Mem_En(mem_en),
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
    .REG_Dst(`DestReg),
    .REG_Src1(mux_src1_to_reg_src1),
    .REG_Src2(`Src2Reg),
    .SRC1(source1),         // Output
    .SRC2(source2)          // Output
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
    .DIn2(absoluteZeroExt),     // IR[8:0] zero extended to [15:0]
    .DIn3({DataWidth{1'b0}}),   // Unused
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
    .DIn1(relativeSignedExt),   // IR[9:0] sign extended to [15:0]
    .DIn2({DataWidth{1'b0}}),   // Unused
    .DIn3({DataWidth{1'b0}}),   // Unused
    .DOut(mux_bra_to_alu2)
);

Mux #(
    .DataWidth(DataWidth),
    .SelectSize(2)) MUX_DATA
(
    .Select(data_src),
    .DIn0(absoluteZeroExt),     // IR[8:0] zero extended to [15:0]
    .DIn1(mem_to_out),          // Memory data out
    .DIn2(alu_res_to_mux_data), // ALU output
    .DIn3({DataWidth{1'b0}}),   // Unused
    .DOut(mux_data_to_regfile)
);

Mux #(
    .DataWidth(3),
    .SelectSize(1)) MUX_SRC1
(
    .Select(src1_sel),
    .DIn0(`DestReg),            // IR[]
    .DIn1(`Src1Reg),            // IR[]
    .DIn2({3{1'b0}}),           // Unused
    .DIn3({3{1'b0}}),           // Unused
    .DOut(mux_src1_to_reg_src1)
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
    .LD(ir_ld),
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

endmodule
