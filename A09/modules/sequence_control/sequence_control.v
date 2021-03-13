`default_nettype none

// --------------------------------------------------------------------------
// Sequence control matrix
// --------------------------------------------------------------------------
// `include "constants.v"

module SequenceControl
#(
    parameter DataWidth = 8
)
(
    input wire Clk,
    input wire [DataWidth-1:0] IR,  // Provides: Op-code, CN, Dest/Src regs
    input wire [3:0] ALU_FlgsIn,
    input wire Reset,               // Active low
    // Branch and Stack
    output wire STK_Ld,
    output wire BRA_Src,
    // IR
    output wire IR_Ld,
    // PC
    output wire PC_Ld,
    output wire PC_Rst,
    output wire PC_Inc,
    output wire [1:0] PC_Src,       // 2Bits
    // Memory
    output wire MEM_Wr,
    output wire MEM_En,
    output wire [1:0] ADDR_Src,     // 2Bits
    // Regster File
    output wire REG_WE,
    output wire [1:0] DATA_Src,     // 2Bits
    output wire [2:0] REG_Dest,     // 3Bits
    output wire [2:0] REG_Src2,
    output wire [2:0] REG_Src1,
    output wire Src1_Sel,           // 1Bit
    // ALU
    output wire [ALUOpSize-1:0] ALU_Op,       // ALU operation: ADD, SUB etc.
    output wire ALU_Ld,
    output wire FLG_Ld,
    output wire FLG_Rst,
    // Misc
    output wire Halt                // Active High
);

// Sequence states
parameter S_Idle          = 3'b000,
          S_Reset         = 3'b001,
          S_FetchPCtoMEM  = 3'b010,
          S_FetchMEMtoIR  = 3'b011,
          S_Decode        = 3'b100,
          S_Execute       = 3'b101;

// Instruction Field
`define OPCODE IR[15:12]    // op-code field
`define JPLink IR[11]       // Link=0 (JPL) or not Link=1 (JMP)

`define REG_SRC1 IR[2:0]
`define REG_SRC2 IR[6:4]
`define REG_DEST IR[11:9]     // Dest reg file or Src 1

`define CN IR[11:10]        // Branch conditions
parameter BEQ = 2'b00;      // Branch on equal
parameter BNE = 2'b01;      // Branch on equal
parameter BLT = 2'b10;      // Branch on equal
parameter BCS = 2'b11;      // Branch on equal
reg takeBranch;            

parameter ALUOpSize = 4;
`define ZFlag ALU_FlgsIn[0] // Zero results
`define CFlag ALU_FlgsIn[1] // Carry generated
`define NFlag ALU_FlgsIn[2] // Negative bit set -- Sign
`define VFlag ALU_FlgsIn[3] // Overflow occured

// Internal state signals
reg [2:0] state;        // 3Bits for state
reg [2:0] next_state;   // 3Bits for next state

// Datapath Controls
reg pc_rst;             // PC reset
reg pc_inc;             // PC increment
reg [1:0] pc_src;       // MUX_PC selector
reg ir_ld;
reg mem_wr;
reg mem_en;
reg [1:0] addr_src;     // MUX_ADDR selector
reg halt;
reg [1:0] data_src;
reg reg_we;
reg pc_ld;
reg stk_ld;
reg bra_src;
reg flg_ld;
reg flg_rst;
reg src1_sel;
reg alu_ld;
reg [ALUOpSize-1:0] alu_op;
reg alu_instr;

// Simulation
initial begin
    next_state = S_Idle;
end

// -------------------------------------------------------------
// Combinational control signals
// -------------------------------------------------------------
always @(state) begin
    case (state)
        // Machine is idling
        S_Idle: begin
            $display("%d S_Idle", $stime);
            // We always know immediately what the next state is
            next_state = S_Idle;
            halt = 1'b0;        // Disable Halt regardless of state
        end

        S_Reset: begin
            $display("%d S_Reset", $stime);
            // --- Previous State clean up ---------
            // None

            next_state = S_FetchPCtoMEM;

            // --- Next state setup -------------
            ir_ld = 1'b1;       // Disable IR loading
            pc_inc = 1'b1;      // Disable PC Inc
            pc_rst = 1'b0;      // Enable resetting PC (active low)
            mem_wr = 1'b1;      // Enable memory read
            mem_en = 1'b1;      // Disable memory
            halt = 1'b0;        // Disable Halt regardless of state
        end

        // Part 1 of fetch sequence: PC to Mem address input
        S_FetchPCtoMEM: begin
            $display("%d S_FetchPCtoMEM", $stime);
            // --- Previous State clean up ---------
            pc_rst = 1'b1;      // Disable resetting PC
            pc_ld =  1'b1;      // Disable PC loading
            stk_ld = 1'b1;      // Disable Stack loading
            flg_ld = 1'b1;      // Disable Flag state loading
            alu_ld = 1'b1;      // Disable loading ALU output
            flg_rst = 1'b1;     // Disbled ALU flags reset
            reg_we = 1'b1;      // Disable writing to reg file
            src1_sel = 1'b1;    // Route Src1-IR to Reg-file Src1

            // Next state
            next_state = S_FetchMEMtoIR;

            // --- Next state setup -------------
            mem_wr = 1'b1;      // Enable Read (active high)
            mem_en = 1'b0;      // Enable memory
            addr_src = 2'b00;   // Select PC as source
        end

        // Part 2 of fetch sequence
        S_FetchMEMtoIR: begin
            $display("%d S_FetchMEMtoIR", $stime);
            mem_en = 1'b1;      // Disable memory

            next_state = S_Decode;

            // --- Next state setup -------------
            ir_ld = 1'b0;       // Enable loading IR
            // Take advantage of the next clock to bump the PC
            pc_inc = 1'b0;      // Enable Increment PC
        end

        S_Decode: begin
            $display("%d S_Decode", $stime);
            ir_ld = 1'b1;       // Disable loading IR
            pc_inc = 1'b1;      // Disable Increment PC

            // --- Next state setup -------------
            next_state = S_FetchPCtoMEM;

            case (`OPCODE)
                `NOP: begin // No operation (a.k.a. do nothing)
                    // Simply loop back to fetching the next instruction
                    $display("%d OPCODE: NOP", $stime);
                end

                `HLT: begin // Halt
                    $display("%d OPCODE: HLT", $stime);
                    // Signals CPU to stop and idle
                    next_state = S_Idle;
                    halt = 1'b1;
                end

                `LDI: begin // Load Immediate.
                    $display("%d OPCODE: LDI", $stime);
                    // IR[8:0] contains value loaded into Dest register
                    // Value is zero-extended
                    reg_we = 1'b0;      // Enable write to reg file
                    data_src = 2'b00;   // Select Zero extended source
                end

                `LD: begin // Load Direct (requires 1 extra cycle, S_Execute)
                    $display("%d OPCODE: LD", $stime);
                    // IR[8:0] contains an absolute address to load from
                    // Address is zero-extended.
                    next_state = S_Execute;

                    mem_en = 1'b0;      // Enable memory
                    addr_src = 2'b10;   // Select zero-extend as source
                end

                `ST: begin // Store Direct
                    $display("%d OPCODE: ST", $stime);
                    // IR[11:9] specifies a Src register for the
                    // the data. destination Address is "zero-extended"
                    // and specified IR[8:0]

                    mem_wr = 1'b0;      // Enable writing to memory
                    mem_en = 1'b0;      // Enable memory
                    addr_src = 2'b10;   // Select zero-extend as source
                    src1_sel = 1'b0;    // Route Dest-IR to Reg-file Src1
                end

                `STX: begin // Store Direct
                    $display("%d OPCODE: STX", $stime);
                    // IR[2:0] specifies the data to be stored
                    // IR[6:4] specifies the address to write to

                    mem_wr = 1'b0;      // Enable writing to memory
                    mem_en = 1'b0;      // Enable memory
                    addr_src = 2'b01;   // Select Source2 as Address
                    src1_sel = 1'b1;    // Route Src1-IR to Reg-file Src1
                end

                // This is also the JMP instruction
                `JPL: begin // Jump and "Link (JPL) or not Link (JMP)"
                    if (`JPLink == 1'b1)
                        $display("%d OPCODE: JMP", $stime);
                    else
                        $display("%d OPCODE: JPL", $stime);
                    // IR[11] specifies stack action

                    src1_sel = 1'b1;    // Route Src1-IR to Reg-file Src1
                    pc_src = 2'b10;     // Select Reg-File Source 1
                    pc_ld = 1'b0;       // Enable loading PC
                    stk_ld = `JPLink;   // loading Stack reg. JPL = 0
                end

                `RET: begin // Return from JPL instruction
                    $display("%d OPCODE: RET", $stime);
                    pc_src = 2'b01;     // Select Return address
                    pc_ld = 1'b0;       // Enable loading PC
                end

                `BRD: begin // Branch direct
                    $display("%d OPCODE: BRD: flags: V:%0b,N:%0b,C:%0b,Z:%0b", $stime, `VFlag, `NFlag, `CFlag, `ZFlag);
                    case (`CN)
                        BEQ:
                            takeBranch = `ZFlag == 1'b1; // If Z-flag Set then branch
                        BNE:
                            takeBranch = `ZFlag == 1'b0; // If Z-flag NOT Set then branch
                        BLT:
                            // Computer Architecture Tutorial Using an FPGA: ARM and Verilog Introduction
                            // Chp 11 "Status Register" pg 213-214
                            takeBranch = `NFlag != `VFlag; // If Sign Flag != Overfloat Flag
                        BCS:
                            takeBranch = `CFlag == 1'b1; // If Carry set then branch
                    endcase

                    // Determine if the PC should be loaded with a
                    // branch address specified by the lower 10 bits, but
                    // only if a condition is meet.
                    if (takeBranch == 1'b1) begin
                        $display("%d Taking branch...", $stime);
                        pc_ld = 1'b0;       // Enable PC load
                        bra_src = 1'b1;     // Select Sign extend
                        pc_src = 2'b00;     // Select Branch address source
                    end

                    flg_rst = 1'b0;     // Enable ALU flags reset
                end

                `BRX: begin // Branch Indexed
                    $display("%d OPCODE: BRX", $stime);
                    case (`CN)
                        BEQ:
                            takeBranch = `ZFlag == 1'b1; // If Z-flag Set then branch
                        BNE:
                            takeBranch = `ZFlag == 1'b0; // If Z-flag NOT Set then branch
                        BLT:
                            takeBranch = `NFlag != `VFlag; // If Sign Flag != Overfloat Flag
                        BCS:
                            takeBranch = `CFlag == 1'b1; // If Carry set then branch
                    endcase

                    // Determine if the PC should be loaded with a
                    // branch address specified by the lower 10 bits, but
                    // only if a condition is meet.
                    if (takeBranch == 1'b1) begin
                        pc_ld = 1'b0;       // Enable PC load
                        bra_src = 1'b0;     // Select Reg File source1
                        pc_src = 2'b00;     // Select Branch address source
                        src1_sel = 1'b1;    // Route Src1-IR to Reg-file Src1
                    end

                    flg_rst = 1'b0;     // Enable ALU flags reset
                end

                `ADD: begin // ALU add operation
                    $display("%d OPCODE: ADD", $stime);
                    alu_instr = 1'b1;
                    alu_op = 4'b0000;
                end
                `SUB: begin // ALU subtract operation
                    $display("%d OPCODE: SUB", $stime);
                    alu_instr = 1'b1;
                    alu_op = 4'b0001;
                end
                `AND: begin // ALU AND operation
                    $display("%d OPCODE: AND", $stime);
                    alu_instr = 1'b1;
                    alu_op = 4'b0010;
                end
                `OR: begin // ALU OR operation
                    $display("%d OPCODE: OR", $stime);
                    alu_instr = 1'b1;
                    alu_op = 4'b0011;
                end
                `XOR: begin // ALU XOR operation
                    $display("%d OPCODE: XOR", $stime);
                    alu_instr = 1'b1;
                    alu_op = 4'b0100;
                end
            endcase

            if (alu_instr == 1'b1) begin
                $display("%d S_Decode.alu_instr", $stime);
                next_state = S_Execute;
                src1_sel = 1'b1;    // Select Src1-IR to Reg-file Src1
                flg_ld = 1'b0;      // Enable loading ALU flags
                alu_ld = 1'b0;      // Enable loading ALU output
            end
        end

        S_Execute: begin
            $display("%d S_Execute", $stime);
            // The next state is alway fetch
            next_state = S_FetchPCtoMEM;

            case (`OPCODE)
                `LD: begin
                    // This cycle completes the instruction by loading
                    // the reg file with the data from memory.
                    // --- Previous State clean up ---------
                    mem_en = 1'b1;      // Disable memory

                    // --- Next state setup -------------
                    reg_we = 1'b0;      // Enable writing to reg file
                    data_src = 2'b01;   // Select memory output source
                end
                default: begin
                    if (alu_instr == 1'b1) begin
                        $display("%d S_Execute.alu_instr", $stime);
                        alu_instr = 1'b0;   // Complete ALU instruction

                        //alu_op = 4'b1000;   // Select Unknown Op
                        alu_ld = 1'b1;      // Disable loading ALU output
                        data_src = 2'b10;   // Select ALU output
                        reg_we = 1'b0;      // Enable write to Reg File
                    end                    
                end
            endcase
        end

        // Avoiding latches
        default:
            next_state = S_Idle;

    endcase // End (state)
end

// -------------------------------------------------------------
// Sequence control (clocked). Move to the next state on the
// rising edge of the next clock.
// -------------------------------------------------------------
always @(posedge Clk) begin
    if (Reset == 1'b0) begin
        state <= S_Reset;
    end
    else begin
        // Potential state change
        state <= next_state;        
    end
end

// -------------------------------------------------------------
// Route internal signals to outputs
// -------------------------------------------------------------
assign PC_Rst = pc_rst;
assign PC_Inc = pc_inc;
assign PC_Ld = pc_ld;
assign PC_Src = pc_src;
assign IR_Ld = ir_ld;
assign STK_Ld = stk_ld;
assign BRA_Src = bra_src;
assign FLG_Ld = flg_ld;
assign FLG_Rst = flg_rst;
assign MEM_Wr = mem_wr;
assign MEM_En = mem_en;
assign ADDR_Src = addr_src;
assign Halt = halt;
assign REG_WE = reg_we;
assign DATA_Src = data_src;
assign ALU_Ld = alu_ld;
assign ALU_Op = alu_op;
assign Src1_Sel = src1_sel;
assign REG_Src1 = `REG_SRC1;
assign REG_Src2 = `REG_SRC2;
assign REG_Dest = `REG_DEST;
endmodule
