`default_nettype none

// --------------------------------------------------------------------------
// Sequence control matrix
// --------------------------------------------------------------------------
 
module SequenceControl
#(
    parameter DataWidth = 16,
    parameter PCSelectSize = 3  // 3 Bits
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
    output wire [PCSelectSize-1:0] PC_Src,
    // Memory
    output wire MEM_Wr,
    output wire MEM_En,
    output wire [1:0] ADDR_Src,     // 2Bits
    // Regster File
    output wire REG_WE,
    output wire [1:0] DATA_Src,     // 2Bits
    // ALU
    output wire [ALUOpSize-1:0] ALU_Op,       // ALU operation: ADD, SUB etc.
    output wire ALU_Ld,
    output wire FLG_Ld,
    output wire FLG_Rst,
    // Output
    output wire OUT_Ld,
    output wire OUT_Sel,      // 1 Bit
    // Misc
    output wire Ready,              // Active high
    output wire Halt                // Active high
);

// Sequence states
localparam  S_Reset         = 4'b0000,
            S_FetchPCtoMEM  = 4'b0001,
            S_FetchMEMtoIR  = 4'b0010,
            S_Decode        = 4'b0011,
            S_Execute       = 4'b0100,
            S_Ready         = 4'b0101,
            S_ALU_Execute   = 4'b0110, // Extra cycle for ALU instructions
            S_HALT          = 4'b0111;

localparam  S_Vector1       = 2'b00,
            S_Vector2       = 2'b01,
            S_Vector3       = 2'b10,
            S_Vector4       = 2'b11;

// Instruction Field
`define OPCODE IR[15:12]    // op-code field

`define REG_SRC1 IR[2:0]
`define REG_SRC2 IR[5:3]
`define REG_DEST IR[8:6]    // For LDI it is different

`define IgnoreDest IR[10]    // Used mostly CMP for comparisons

reg takeBranch;
reg branchType;

localparam ALUOpSize = 4;
`define ZFlag ALU_FlgsIn[0] // Zero results
`define CFlag ALU_FlgsIn[1] // Carry generated
`define NFlag ALU_FlgsIn[2] // Negative bit set -- Sign
`define VFlag ALU_FlgsIn[3] // Overflow occured

// Internal state signals
localparam StateSize = 4;
reg [StateSize-1:0] state;        // 3Bits for state
reg [StateSize-1:0] next_state;   // 3Bits for next state

localparam VectorStateSize = 2; // 2 Bits for state
reg [VectorStateSize-1:0] vector_state;
reg [VectorStateSize-1:0] next_vector_state;

// Datapath Controls
reg halt;

reg pc_rst;             // PC reset
reg pc_inc;             // PC increment
reg pc_ld;
reg [PCSelectSize-1:0] pc_src;       // MUX_PC selector
reg bra_src;

reg stk_ld;
reg ir_ld;

reg out_ld;
reg out_sel;

reg flg_ld;
reg flg_rst;
reg alu_ld;
reg [ALUOpSize-1:0] alu_op;
reg alu_instr;

reg mem_en;
reg mem_wr;
reg [1:0] addr_src;     // MUX_ADDR selector

reg reg_we;
reg [1:0] data_src;

// The ALU operation *is* the instruction itself.
`define ALUOp  IR[15:12]

// The "ready" flag is Set when the CPU has complete its reset activities.
reg ready;

// Once the reset sequence has complete this flag is Set.
reg resetComplete;

// Simulation
initial begin
    // Be default the CPU always attempts to start in Reset mode.
    state = S_Reset;
    // Also configure the reset sequence start state.
    vector_state = S_Vector1;
end

`ifdef SIMULATE
    reg [15:12] opCode;
    always @* begin
        opCode = `OPCODE;
    end
`endif    

// -------------------------------------------------------------
// Combinational control signals
// -------------------------------------------------------------
always @(state, vector_state) begin

    // ======================================
    // Initial conditions on a *state* or *vector_state* change
    // ======================================
    ready = 1'b1;           // Default: CPU is ready
    resetComplete = 1'b1;   // Default: Reset is complete

    next_state = S_Reset;
    next_vector_state = S_Vector1;
    halt = 1'b0;        // Disable Halt regardless of state

    // PC
    pc_rst = 1'b1;      // Disable resetting PC
    pc_inc = 1'b1;      // Disable Increment PC
    pc_ld =  1'b1;      // Disable PC loading
    pc_src = 3'b000;    // Select PC
    bra_src = 1'b1;     // Select Sign extend

    // Misc: Stack, Output
    stk_ld = 1'b1;      // Disable Stack loading
    ir_ld = 1'b1;       // Disable IR loading

    // Output 
    out_ld = 1'b1;      // Disable output loading
    out_sel = 1'b0;    // Reg-File

    // ALU and Flags
    flg_rst = 1'b1;     // Disbled ALU flags reset
    flg_ld = 1'b1;      // Disable Flag state loading
    alu_ld = 1'b1;      // Disable loading ALU output
    alu_op = 4'b1111;   // Unknown ALU operation

    alu_instr = 1'b0;   // Default -- not an ALU instruction
    takeBranch = 1'b0;  // Default -- Don't take branch
    branchType = 1'b1;  // Default -- Not an Index branch instruction

    // Memory
    mem_en = 1'b1;      // Disable memory
    mem_wr = 1'b1;      // Disable Write (active low) i.e. Enable Read (Active high)
    addr_src = 2'b00;   // Select PC as source

    // Reg-File
    reg_we = 1'b1;      // Disable writing to reg file
    data_src = 2'b00;   // Select Zero extended-L source

    // ======================================
    // Main state machine
    // ======================================
    case (state)
        // CPU is in a reset state waiting for the Reset flag to deactivate (High)
        // While in this state the CPU continuosly loads the Reset-Vector.
        S_Reset: begin
            `ifdef SIMULATE
                $display("%d S_Reset", $stime);
            `endif
            ready = 1'b0;               // CPU is not ready while resetting.
            resetComplete = 1'b0;       // Reset not complete
            
            // ------------------------------------------------------
            // Vector reset sequence
            // ------------------------------------------------------
            case (vector_state)
                S_Vector1: begin
                    `ifdef SIMULATE
                        $display("%d S_Vector1", $stime);
                    `endif
                    pc_src = 3'b010;    // Select Reset vector constant
                    pc_ld = 1'b0;       // Enable loading PC
                    next_vector_state = S_Vector2;
                end
                S_Vector2: begin
                    `ifdef SIMULATE
                        $display("%d S_Vector2", $stime);
                    `endif
                    // PC is loaded and asserted to Memory.
                    mem_en = 1'b0;      // Enable memory, Read is the default behaviour
                    next_vector_state = S_Vector3;
                end
                S_Vector3: begin
                    `ifdef SIMULATE
                        $display("%d S_Vector3", $stime);
                    `endif
                    // Memory data out is ready and asserted to IR
                    ir_ld = 1'b0;      // Enable IR loading
                    next_vector_state = S_Vector4;
                end
                S_Vector4: begin
                    `ifdef SIMULATE
                        $display("%d S_Vector4", $stime);
                    `endif
                    // IR is loaded. Route Zero-extend-L to PC
                    pc_src = 3'b100;        // Select Zero-extend-L
                    pc_ld = 1'b0;           // Enable loading PC
                    resetComplete = 1'b1;   // Reset completed

                    // Reset completes by the next negedge clock
                    // Transition to the Ready state now that the PC is loaded
                    // with the address of the first instruction.
                    next_state = S_Ready;
                end
                default: begin
                    `ifdef SIMULATE
                        $display("%d ###### default Vector state ######", $stime);
                    `endif
                    next_vector_state = S_Vector1;
                end
            endcase
        end

        S_Ready: begin
            // We enter this state at the end of the Reset sequence.
            `ifdef SIMULATE
                $display("%d S_Ready", $stime);
            `endif
            ready = 1'b1;   // CPU is ready
            next_state = S_FetchPCtoMEM;
        end

        S_HALT: begin
            `ifdef SIMULATE
                $display("%d S_HALT", $stime);
            `endif
            // We can only exit this state on a reset.
            next_state = S_HALT;
            halt = 1'b1;
            ready = 1'b0;
        end

        // Part 1 of fetch sequence: PC to Mem address input
        S_FetchPCtoMEM: begin
            `ifdef SIMULATE
                $display("%d S_FetchPCtoMEM", $stime);
            `endif

            // Next state
            next_state = S_FetchMEMtoIR;

            // --- Next state setup -------------
            mem_en = 1'b0;      // Enable memory
            // By default memory read is enabled.
        end

        // Part 2 of fetch sequence
        S_FetchMEMtoIR: begin
            `ifdef SIMULATE
                $display("%d S_FetchMEMtoIR", $stime);
            `endif

            next_state = S_Decode;

            // mem_en = 1'b0;      // Enable memory
            ir_ld = 1'b0;       // Enable loading IR
            // Take advantage of the next clock to bump the PC
            pc_inc = 1'b0;      // Enable Increment PC
        end

        S_Decode: begin
            `ifdef SIMULATE
                $display("%d S_Decode : {%b}", $stime, `OPCODE);
            `endif

            // --- Next state setup -------------
            next_state = S_FetchPCtoMEM;

            case (`OPCODE)
                `NOP: begin // No operation (a.k.a. do nothing)
                    // Simply loop back to fetching the next instruction
                    `ifdef SIMULATE
                        $display("%d OPCODE: NOP", $stime);
                    `endif
                end

                // ---------------------------------------------------
                // ALU
                // ---------------------------------------------------
                `ADD: begin // ALU add operation
                    `ifdef SIMULATE
                        $display("%d OPCODE: ADD", $stime);
                    `endif
                    alu_instr = 1'b1;
                    alu_op = `ALUOp;
                end

                `SUB: begin // ALU subtract operation
                    if (`IgnoreDest == 1'b0) begin
                        `ifdef SIMULATE
                            $display("%d OPCODE: SUB", $stime);
                        `endif
                    end
                    else begin
                        `ifdef SIMULATE
                            $display("%d OPCODE: CMP", $stime);
                        `endif
                    end

                    alu_instr = 1'b1;   // See just below
                    alu_op = `ALUOp;
                end

                `SHL: begin // ALU XOR operation
                    `ifdef SIMULATE
                        $display("%d OPCODE: SHL", $stime);
                    `endif
                    alu_instr = 1'b1;
                    alu_op = `ALUOp;
                end

                `SHR: begin // ALU XOR operation
                    `ifdef SIMULATE
                        $display("%d OPCODE: SHR", $stime);
                    `endif
                    alu_instr = 1'b1;
                    alu_op = `ALUOp;
                end

                // ---------------------------------------------------
                // Branch Directs
                // ---------------------------------------------------
                `BNE: begin
                    `ifdef SIMULATE
                        $display("%d OPCODE: BNE [V:%0b,N:%0b,C:%0b,Z:%0b]", $stime, `VFlag, `NFlag, `CFlag, `ZFlag);
                    `endif
                    takeBranch = `ZFlag == 1'b0; // If Z-flag NOT Set then branch
                end

                // ---------------------------------------------------
                // Flow
                // ---------------------------------------------------
                `JMP: begin // Jump
                    // Jmp to an absolute address specified by Source 1
                    `ifdef SIMULATE
                        $display("%d OPCODE: JMP", $stime);
                    `endif

                    pc_src = 3'b011;    // Select Reg-File Source 1
                    pc_ld = 1'b0;       // Enable loading PC
                end

                `RET: begin // Return from JPL instruction
                    `ifdef SIMULATE
                        $display("%d OPCODE: RET", $stime);
                    `endif
                    pc_src = 2'b01;     // Select Return address
                    pc_ld = 1'b0;       // Enable loading PC
                end

                // ---------------------------------------------------
                // Load/Store
                // ---------------------------------------------------
                `LDI: begin // Load Immediate.
                    // The lower 8bits are loaded into the desination register.
                    // The bits are zero-extended-L
                    // The destination reg = IR[10:8]
                    `ifdef SIMULATE
                        $display("%d OPCODE: LDI", $stime);
                    `endif
                    
                    reg_we = 1'b0;      // Enable write to reg file
                    data_src = 2'b00;   // Select Zero extended-L source
                end

                // ---------------------------------------------------
                // Misc/Output
                // ---------------------------------------------------
                `OTR: begin // Copy Reg-file to output register
                    `ifdef SIMULATE
                        $display("%d OPCODE: OTR", $stime);
                    `endif

                    // Source is a Reg-File.
                    out_ld = 1'b0;      // Enable output loading
                    out_sel = 1'b0;     // Select Reg-File source
                end

                `HLT: begin // Halt
                    `ifdef SIMULATE
                        $display("%d OPCODE: HLT", $stime);
                    `endif
                    // Signals CPU to stop
                    next_state = S_HALT;
                    // ready = 1'b0;
                end

            endcase

            if (takeBranch == 1'b1) begin
                if (branchType == 1'b1) begin
                    // The branch address is specified in the lower byte
                    `ifdef SIMULATE
                        $display("%d --- Taking branch direct ---", $stime);
                    `endif
                end
                else begin
                    `ifdef SIMULATE
                        $display("%d --- Taking branch indexed ---", $stime);
                    `endif
                end

                bra_src = branchType;

                pc_ld = 1'b0;       // Enable PC load
                pc_src = 2'b00;     // Select Branch address source

                flg_rst = 1'b0;     // Enable ALU flags reset
            end

            if (alu_instr == 1'b1) begin
                if (`IgnoreDest == 1'b0) begin
                    `ifdef SIMULATE
                        $display("%d S_Decode:: Destination required.", $stime);
                    `endif
                    // The destination is required so an extra cycle is needed.
                    next_state = S_ALU_Execute;

                    alu_ld = 1'b0;      // Enable loading ALU output
                end
                else begin
                    // For some instructions, for example CMP,
                    // we don't care about a destination just the ALU flags.
                    `ifdef SIMULATE
                        $display("%d S_Decode:: Destination ignored.", $stime);
                    `endif
                end

                // We always need the ALU status bits
                flg_ld = 1'b0;      // Enable loading ALU flags
            end
        end

        S_ALU_Execute: begin
            `ifdef SIMULATE
                $display("%d S_ALU_Execute ALU Part 2", $stime);
            `endif

            // The next state is alway fetch
            next_state = S_FetchPCtoMEM;

            data_src = 2'b10;    // Select ALU output
            reg_we = 1'b0;       // Enable write to Reg File
        end

        default:
            next_state = S_Reset;

    endcase // End (state)
end

// -------------------------------------------------------------
// Sequence control (sync). Move to the next state on the
// rising edge of the next clock.
// -------------------------------------------------------------
always @(posedge Clk) begin
    if (Reset == 1'b0) begin
        state <= S_Reset;
        vector_state <= S_Vector1;
    end
    else
        if (resetComplete == 1'b1)
            state <= next_state;
        else begin
            state <= S_Reset;
            vector_state <= next_vector_state;
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
assign OUT_Ld = out_ld;
assign OUT_Sel = out_sel;
assign Ready = ready;

endmodule
