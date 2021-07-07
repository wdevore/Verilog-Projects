`default_nettype none

// --------------------------------------------------------------------------
// A simple Control Matrix for educational purpose only. This module isn't part
// of the Processor.
// --------------------------------------------------------------------------
 
module MealyCM
#(
    parameter PC_SELECT_SIZE = 3,     // Mux8
    parameter ADDR_SELECT_SIZE = 2    // Mux4
)
(
    input wire clk_i,
    input wire reset_ni,
    // PC
    output wire pc_rst_no,               // Program counter reset
    output wire pc_ld_no,                // Program counter load
    output wire mar_rst_no,              // MAR reset
    output wire mar_ld_no,               // MAR load
    output wire [PC_SELECT_SIZE-1:0] pc_src_o,
    // Address
    output wire [ADDR_SELECT_SIZE-1:0] addr_src_o
);

// Sequence states
localparam  S_Reset         = 4'b0000,          // Non one-hot encoding
            S_Ready         = 4'b0001,
            S_HALT          = 4'b0010;

localparam  S_Vector1       = 2'b00,
            S_Vector2       = 2'b01,
            S_Vector3       = 2'b10,
            S_Vector4       = 2'b11;

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
reg pc_ld;
reg [PC_SELECT_SIZE-1:0] pc_src;       // MUX_PC selector
reg [1:0] addr_src;     // MUX_ADDR selector
reg mar_rst;
reg mar_ld;

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

// -------------------------------------------------------------
// Combinational control signals
// -------------------------------------------------------------
always @(state, vector_state) begin

    // ======================================
    // Default conditions at the start of every state
    // change of *state* or *vector_state*
    // ======================================
    ready = 1'b1;           // CPU is ready
    resetComplete = 1'b1;   // Reset is complete
    halt = 1'b0;            // Halt inactive

    next_state = S_Reset;
    next_vector_state = S_Vector1;
    
    // PC
    pc_rst = 1'b1;      // Disable resetting PC
    pc_ld =  1'b1;      // Disable PC loading
    pc_src = {PC_SELECT_SIZE{1'b0}};    // Select PC

    // MAR
    mar_rst = 1'b1;      // Disable resetting
    mar_ld =  1'b1;      // Disable

    addr_src = {ADDR_SELECT_SIZE{1'b0}};   // Select PC as source

    // ======================================
    // Main state machine
    // ======================================
    case (state)
        // In a reset state waiting for the Reset flag to deactivate (High)
        // While in this state nothing happens until Reset becomes inactive.
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
                    pc_src = 2'b10;    // Select Reset vector constant
                    pc_ld = 1'b0;      // Enable loading PC

                    mar_rst = 1'b0;    // reset MAR

                    next_vector_state = S_Vector2;
                end
                S_Vector2: begin
                    `ifdef SIMULATE
                        $display("%d S_Vector2", $stime);
                    `endif

                    addr_src = 2'b00;   // Select PC output
                    mar_ld = 1'b0;      // Enable loading MAR register

                    // I don't need this here because the default
                    // for every state change is disablement.
                    // mar_rst = 1'b1;    // Disable reset MAR

                    next_vector_state = S_Vector3;
                end
                S_Vector3: begin
                    `ifdef SIMULATE
                        $display("%d S_Vector3", $stime);
                    `endif

                    // See above for mar_ld
                    // mar_ld = 1'b1;      // Disable loading MAR register

                    next_vector_state = S_Vector4;
                end
                S_Vector4: begin
                    `ifdef SIMULATE
                        $display("%d S_Vector4", $stime);
                    `endif
                    resetComplete = 1'b1;   // Reset completed

                    // Reset completes by the next negedge clock
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
            next_state = S_HALT;
        end

        // Part 1 of fetch sequence: PC to Mem address input
        S_HALT: begin
            `ifdef SIMULATE
                $display("%d S_HALT", $stime);
            `endif
            halt = 1'b1;
            ready = 1'b0;   // CPU is halted
            next_state = S_HALT;
        end

        default:
            next_state = S_Reset;

    endcase // End (state)
end

// -------------------------------------------------------------
// Sequence control (sync). Move to the next state on the
// rising edge of the next clock.
// -------------------------------------------------------------
always @(posedge clk_i) begin
    if (~reset_ni) begin
        state <= S_Reset;
        vector_state <= S_Vector1;
    end
    else
        if (resetComplete) begin
            state <= next_state;
        end else begin
            state <= S_Reset;
            vector_state <= next_vector_state;
        end
end

// -------------------------------------------------------------
// Route internal signals to outputs
// -------------------------------------------------------------
assign pc_rst_no = pc_rst;
assign pc_ld_no = pc_ld;
assign pc_src_o = pc_src;
assign addr_src_o = addr_src;
assign mar_rst_no = mar_rst;
assign mar_ld_no = mar_ld;

endmodule
