`default_nettype none

// --------------------------------------------------------------------------
// Sequence control matrix
// --------------------------------------------------------------------------

module SequenceControl
#(
    parameter DataWidth = 16
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
    // Output
    output wire OUT_Ld,
    output wire [1:0] OUT_Sel,      // 2Bits
    // Misc
    output wire Ready,              // Active high
    output wire Halt                // Active high
);

// Sequence states
localparam S_Idle         = 4'b0000,
           S_Reset        = 4'b0001,
           S_FetchPCtoMEM = 4'b0010,
           S_FetchMEMtoIR = 4'b0011,
           S_Decode       = 4'b0100,
           S_Execute      = 4'b0101,
           S_Ready        = 4'b0110,
           S_ALU_EXECUTE  = 4'b0111, // Extra cycle for ALU instructions
           S_HALT         = 4'b1000;

// Instruction Field
`define OPCODE IR[15:12]    // op-code field
`define JPLink IR[11]       // Link=0 (JPL) or not Link=1 (JMP)

`define REG_SRC1 IR[2:0]
`define REG_SRC2 IR[6:4]
`define REG_DEST IR[11:9]     // Dest reg file or Src 1

`define CN IR[11:10]        // Branch conditions
`define IgnoreDest IR[8]    // Used mostly SUB for comparisons
`define OutSrc IR[11]       // Memory (0) or Register file (1)

localparam BEQ = 2'b00;      // Branch on equal
localparam BNE = 2'b01;      // Branch on equal
localparam BLT = 2'b10;      // Branch on equal
localparam BCS = 2'b11;      // Branch on equal
reg takeBranch;            

localparam ALUOpSize = 4;
`define ZFlag ALU_FlgsIn[0] // Zero results
`define CFlag ALU_FlgsIn[1] // Carry generated
`define NFlag ALU_FlgsIn[2] // Negative bit set -- Sign
`define VFlag ALU_FlgsIn[3] // Overflow occured

// Internal state signals
localparam StateSize = 4;
reg [StateSize-1:0] state;        // 3Bits for state
reg [StateSize-1:0] next_state;   // 3Bits for next state

// Datapath Controls
reg halt;

reg pc_rst;             // PC reset
reg pc_inc;             // PC increment
reg pc_ld;
reg [1:0] pc_src;       // MUX_PC selector
reg bra_src;

reg stk_ld;
reg ir_ld;

reg out_ld;
reg [1:0] out_sel;

reg flg_ld;
reg flg_rst;
reg alu_ld;
reg [ALUOpSize-1:0] alu_op;
reg alu_instr;

reg mem_en;
reg mem_wr;
reg [1:0] addr_src;     // MUX_ADDR selector

reg reg_we;
reg src1_sel;
reg [1:0] data_src;

reg ready;              // (Active High) when CPU has completed reset activities.

// Simulation
initial begin
    state = S_Idle;
end

// -------------------------------------------------------------
// Combinational control signals
// -------------------------------------------------------------
always @(state) begin
    // Initial conditions
    ready = 1'b1;       // CPU is ready

    next_state = S_Idle;
    halt = 1'b0;        // Disable Halt regardless of state

    // PC
    pc_rst = 1'b1;      // Disable resetting PC
    pc_inc = 1'b1;      // Disable Increment PC
    pc_ld =  1'b1;      // Disable PC loading
    pc_src = 2'b00;     // Select PC
    bra_src = 1'b1;     // Select Sign extend

    // Misc: Stack, Output
    stk_ld = 1'b1;      // Disable Stack loading
    ir_ld = 1'b1;       // Disable IR loading

    // Output 
    out_ld = 1'b1;      // Disable output loading
    out_sel = 2'b01;    // Reg-File

    // ALU and Flags
    flg_rst = 1'b1;     // Disbled ALU flags reset
    flg_ld = 1'b1;      // Disable Flag state loading
    alu_ld = 1'b1;      // Disable loading ALU output
    alu_op = 4'b1000;   // Unknown ALU operation

    alu_instr = 1'b0;
    
    // Memory
    mem_en = 1'b1;      // Disable memory
    mem_wr = 1'b1;      // Disable Write (active low) i.e. Enable Read (Active high)
    addr_src = 2'b00;   // Select PC as source

    // Reg-File
    reg_we = 1'b1;      // Disable writing to reg file
    src1_sel = 1'b1;    // Route Src1-IR to Reg-file Src1
    data_src = 2'b00;   // Select Zero extended source

    case (state)
        // Machine is idling
        S_Idle: begin
            `ifdef SIMULATE
                $display("%d S_Idle", $stime);
            `endif
            // We always know immediately what the next state is
            next_state = S_Idle;
            ready = 1'b0;       // CPU not ready
        end

        S_Reset: begin
            `ifdef SIMULATE
                $display("%d S_Reset", $stime);
            `endif
            next_state = S_Ready;

            // --- Next state setup -------------
            pc_rst = 1'b0;      // Enable resetting PC (active low)
            ready = 1'b0;       // CPU not ready
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

        S_Ready: begin
            `ifdef SIMULATE
                $display("%d S_Ready", $stime);
            `endif
            next_state = S_FetchPCtoMEM;
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

            // --- Next state setup -------------
            ir_ld = 1'b0;       // Enable loading IR
            // Take advantage of the next clock to bump the PC
            pc_inc = 1'b0;      // Enable Increment PC
        end

        S_Decode: begin
            `ifdef SIMULATE
                $display("%d S_Decode", $stime);
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

                `HLT: begin // Halt
                    `ifdef SIMULATE
                        $display("%d OPCODE: HLT", $stime);
                    `endif
                    // Signals CPU to stop and idle
                    next_state = S_HALT; //S_Idle;
                    halt = 1'b1;
                    ready = 1'b0;
                end

                `LDI: begin // Load Immediate.
                    `ifdef SIMULATE
                        $display("%d OPCODE: LDI", $stime);
                    `endif
                    
                    // IR[8:0] contains value loaded into Dest register
                    // Value is zero-extended
                    reg_we = 1'b0;      // Enable write to reg file
                    data_src = 2'b00;   // Select Zero extended source
                end

                `LD: begin // Load Direct (requires 1 extra cycle, S_Execute)
                    `ifdef SIMULATE
                        $display("%d OPCODE: LD", $stime);
                    `endif
                    // IR[8:0] contains an absolute address to load from.
                    // Address is zero-extended.
                    next_state = S_Execute;

                    mem_en = 1'b0;      // Enable memory
                    addr_src = 2'b10;   // Select zero-extend as source
                end

                `ST: begin // Store Direct
                    `ifdef SIMULATE
                        $display("%d OPCODE: ST", $stime);
                    `endif
                    // IR[11:9] specifies a Src register for the
                    // the data. destination Address is "zero-extended"
                    // and specified IR[8:0]

                    mem_wr = 1'b0;      // Enable writing to memory
                    mem_en = 1'b0;      // Enable memory
                    addr_src = 2'b10;   // Select zero-extend as source
                    src1_sel = 1'b0;    // Route Dest-IR to Reg-file Src1
                end

                `STX: begin // Store Direct
                    `ifdef SIMULATE
                        $display("%d OPCODE: STX", $stime);
                    `endif
                    // Src1 = IR[2:0] specifies the data to be stored
                    // Src2 = IR[6:4] specifies the address to write to

                    mem_wr = 1'b0;      // Enable writing to memory
                    mem_en = 1'b0;      // Enable memory
                    addr_src = 2'b01;   // Select Source2 as Address
                    src1_sel = 1'b1;    // Route Src1-IR to Reg-file Src1
                end

                // This is also the JMP instruction
                `JPL: begin // Jump and "Link (JPL) or not Link (JMP)"
                    if (`JPLink == 1'b1) begin
                        `ifdef SIMULATE
                            $display("%d OPCODE: JMP", $stime);
                        `endif
                    end
                    else begin
                        `ifdef SIMULATE
                            $display("%d OPCODE: JPL", $stime);
                        `endif                        
                    end
                    // IR[11] specifies stack action

                    src1_sel = 1'b1;    // Route Src1-IR to Reg-file Src1
                    pc_src = 2'b10;     // Select Reg-File Source 1
                    pc_ld = 1'b0;       // Enable loading PC
                    stk_ld = `JPLink;   // loading Stack reg. JPL = 0
                end

                `OUT: begin // Copy source to output register
                    if (`OutSrc == 1'b1) begin
                        `ifdef SIMULATE
                            $display("%d OPCODE: OUT from Reg-File", $stime);
                        `endif
                        // Source is a Reg-File.
                        out_ld = 1'b0;      // Enable output loading
                        out_sel = 2'b01;    // Select Reg-File source
                    end
                    else begin
                        `ifdef SIMULATE
                            $display("%d OPCODE: OUT from Memory", $stime);
                        `endif
                        // Source is Memory so we need an extra cycle
                        next_state = S_Execute;

                        mem_en = 1'b0;      // Enable memory
                        addr_src = 2'b10;   // Select zero-extend
                    end
                end

                `RET: begin // Return from JPL instruction
                    `ifdef SIMULATE
                        $display("%d OPCODE: RET", $stime);
                    `endif
                    pc_src = 2'b01;     // Select Return address
                    pc_ld = 1'b0;       // Enable loading PC
                end

                `BRD: begin // Branch direct
                    case (`CN)
                        BEQ: begin
                            `ifdef SIMULATE
                                $display("%d OPCODE: BRD-BEQ: flags: V:%0b,N:%0b,C:%0b,Z:%0b", $stime, `VFlag, `NFlag, `CFlag, `ZFlag);
                            `endif
                            takeBranch = `ZFlag == 1'b1; // If Z-flag Set then branch
                        end
                        BNE: begin
                            `ifdef SIMULATE
                                $display("%d OPCODE: BRD-BNE: flags: V:%0b,N:%0b,C:%0b,Z:%0b", $stime, `VFlag, `NFlag, `CFlag, `ZFlag);
                            `endif
                            takeBranch = `ZFlag == 1'b0; // If Z-flag NOT Set then branch
                        end
                        BLT: begin
                            `ifdef SIMULATE
                                $display("%d OPCODE: BRD-BLT: flags: V:%0b,N:%0b,C:%0b,Z:%0b", $stime, `VFlag, `NFlag, `CFlag, `ZFlag);
                            `endif
                            // Computer Architecture Tutorial Using an FPGA: ARM and Verilog Introduction
                            // Chp 11 "Status Register" pg 213-214
                            takeBranch = `NFlag != `VFlag; // If Sign Flag != Overfloat Flag
                        end
                        BCS: begin
                            `ifdef SIMULATE
                                $display("%d OPCODE: BRD-BCS: flags: V:%0b,N:%0b,C:%0b,Z:%0b", $stime, `VFlag, `NFlag, `CFlag, `ZFlag);
                            `endif
                            takeBranch = `CFlag == 1'b1; // If Carry set then branch
                        end
                    endcase

                    // Determine if the PC should be loaded with a
                    // branch address specified by the lower 10 bits, but
                    // only if a ALU flag condition is meet.
                    if (takeBranch == 1'b1) begin
                        `ifdef SIMULATE
                            $display("%d --- Taking branch ---", $stime);
                        `endif

                        pc_ld = 1'b0;       // Enable PC load
                        bra_src = 1'b1;     // Select Sign extend
                        pc_src = 2'b00;     // Select Branch address source
                    end

                    flg_rst = 1'b0;     // Enable ALU flags reset
                end

                `BRX: begin // Branch Indexed
                    case (`CN)
                        BEQ: begin
                            `ifdef SIMULATE
                                $display("%d OPCODE: BRX-BEQ", $stime);
                            `endif
                            takeBranch = `ZFlag == 1'b1; // If Z-flag Set then branch
                        end
                        BNE: begin
                            `ifdef SIMULATE
                                $display("%d OPCODE: BRX-BNE", $stime);
                            `endif
                            takeBranch = `ZFlag == 1'b0; // If Z-flag NOT Set then branch
                        end
                        BLT: begin
                            `ifdef SIMULATE
                                $display("%d OPCODE: BRX-BLT", $stime);
                            `endif
                            takeBranch = `NFlag != `VFlag; // If Sign Flag != Overfloat Flag
                        end
                        BCS: begin
                            `ifdef SIMULATE
                                $display("%d OPCODE: BRX-BCS", $stime);
                            `endif
                            takeBranch = `CFlag == 1'b1; // If Carry set then branch
                        end
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
                    `ifdef SIMULATE
                        $display("%d OPCODE: ADD", $stime);
                    `endif
                    alu_instr = 1'b1;
                    alu_op = 4'b0000;
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
                    alu_op = 4'b0001;
                end
                `AND: begin // ALU AND operation
                    `ifdef SIMULATE
                        $display("%d OPCODE: AND", $stime);
                    `endif
                    alu_instr = 1'b1;
                    alu_op = 4'b0010;
                end
                `OR: begin // ALU OR operation
                    `ifdef SIMULATE
                        $display("%d OPCODE: OR", $stime);
                    `endif
                    alu_instr = 1'b1;
                    alu_op = 4'b0011;
                end
                `XOR: begin // ALU XOR operation
                    `ifdef SIMULATE
                        $display("%d OPCODE: XOR", $stime);
                    `endif
                    alu_instr = 1'b1;
                    alu_op = 4'b0100;
                end
            endcase

            if (alu_instr == 1'b1) begin
                `ifdef SIMULATE
                    $display("%d S_Decode::alu_instr", $stime);
                `endif
                // If the instruction indicates that the destination
                // should be stored then we need the extra cycle via S_ALU_EXECUTE.
                if (`IgnoreDest == 1'b0) begin
                    `ifdef SIMULATE
                        $display("%d S_Decode:: Destination required.", $stime);
                    `endif
                    // The destination is required so an cycle is needed.
                    next_state = S_ALU_EXECUTE;

                    src1_sel = 1'b1;    // Select Src1-IR to Reg-file Src1
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

        // A clock edge occurs  <-----

        S_ALU_EXECUTE: begin
            `ifdef SIMULATE
                $display("%d S_ALU_EXECUTE ALU Part 2", $stime);
            `endif

            // The next state is alway fetch
            next_state = S_FetchPCtoMEM;

            data_src = 2'b10;    // Select ALU output
            reg_we = 1'b0;       // Enable write to Reg File
        end

        S_Execute: begin
            // The next state is alway fetch
            next_state = S_FetchPCtoMEM;

            case (`OPCODE)
                `LD: begin
                    `ifdef SIMULATE
                        $display("%d S_Execute LD", $stime);
                    `endif
                    // This cycle completes the instruction by loading
                    // the reg file with the data from memory.
                    mem_en = 1'b1;      // Disable memory

                    // --- Next state setup -------------
                    reg_we = 1'b0;      // Enable writing to reg file
                    data_src = 2'b01;   // Select Memory output source
                end
                
                `OUT: begin
                    `ifdef SIMULATE
                        $display("%d S_Execute OUT", $stime);
                    `endif
                    
                    // ##### NOTE ######
                    // We need to maintain active addr_sr because we
                    // don't want the next instruction to appear while
                    // we are clocking the output reg.
                    // We also need to maintain mem_en.
                    // ####################
                    addr_src = 2'b10;   // Select zero-extend
                    mem_en = 1'b0;      // Enable memory

                    out_ld = 1'b0;      // Enable output loading
                    out_sel = 2'b00;    // Select Memory source
                end
            endcase
        end

        default:
            next_state = S_Idle;

    endcase // End (state)
end

// -------------------------------------------------------------
// Sequence control (sync). Move to the next state on the
// rising edge of the next clock.
// -------------------------------------------------------------
always @(posedge Clk) begin
    if (Reset == 1'b0)
        state <= S_Reset;
    else
        state <= next_state;        
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
assign OUT_Ld = out_ld;
assign OUT_Sel = out_sel;
assign Ready = ready;

endmodule
