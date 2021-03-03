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
    // ALU
    output wire [3:0] ALU_Op,       // ALU operation: ADD, SUB etc.
    output wire FLG_Ld,
    output wire FLG_Rst,
    // Misc
    output wire Halt                // Active High
);

// Sequence states
parameter S_Reset         = 3'b000,
          S_FetchPCtoMEM  = 3'b001,
          S_FetchMEMtoIR  = 3'b010,
          S_Decode        = 3'b011,
          S_Execute0      = 3'b100,
          S_Execute1      = 3'b101,
          S_Idle          = 3'b110;

// Instruction Field
`define OPCODE IR[15:12]    // op-code field
`define CN[11:10]           // Branch conditions

// Internal state signals
reg [2:0] state;        // 3Bits for state
reg [2:0] next_state;   // 3Bits for next state

// Datapath Controls
reg pc_rst;             // PC reset
reg pc_inc;             // PC increment
reg ir_ld;
reg mem_wr;
reg mem_en;
reg [1:0] addr_src;     // MUX_ADDR selector
reg halt;

// Simulation
initial begin
    next_state = S_Idle;
end

// -------------------------------------------------------------
// Combinational control signals
// -------------------------------------------------------------
always @(*) begin
    case (state)
        // Machine is idling
        S_Idle: begin
            // We always know immediately what the next state is
            next_state = S_Idle;
        end

        S_Reset: begin
            // --- Previous State clean up ---------
            // None

            next_state = S_FetchPCtoMEM;

            // --- Next state setup -------------
            pc_rst = 1'b0;      // Enable resetting PC (active low)
            mem_en = 1'b1;      // Disable memory
            halt = 1'b0;        // Disable Halt regardless of state
        end

        // Part 1 of fetch sequence: PC to Mem address input
        S_FetchPCtoMEM: begin
            // --- Previous State clean up ---------
            pc_rst = 1'b1;      // Disable resetting PC

            // Next state
            next_state = S_FetchMEMtoIR;

            // --- Next state setup -------------
            mem_wr = 1'b1;      // Enable Read (active high)
            mem_en = 1'b0;      // Enable memory
            addr_src = 2'b00;   // Select PC as source
        end

        // Part 2 of fetch sequence
        S_FetchMEMtoIR: begin
            // --- Previous State clean up ---------
            mem_en = 1'b1;      // Disable memory, retains last output

            next_state = S_Decode;

            // --- Next state setup -------------
            ir_ld = 1'b0;       // Enable loading IR
            pc_inc = 1'b0;      // Enable Increment PC
        end

        S_Decode: begin
            // --- Previous State clean up ---------
            ir_ld = 1'b1;       // Disable loading IR
            pc_inc = 1'b1;      // Disable PC Inc

            case (`OPCODE)
                `NOP: begin
                    // No operation (a.k.a. do nothing)
                    next_state = S_FetchPCtoMEM;
                end
                `HLT: begin
                    // Signals CPU to stop and idle
                    next_state = S_Idle;
                    halt = 1'b1;
                end
            endcase
        end

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
assign IR_Ld = ir_ld;
assign MEM_Wr = mem_wr;
assign MEM_En = mem_en;
assign ADDR_Src = addr_src;
assign Halt = halt;

endmodule
