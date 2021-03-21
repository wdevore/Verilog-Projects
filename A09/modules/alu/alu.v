// --------------------------------------------------------------------------
// ALU (subset of 74181)
// Operations:
//   Add, Sub
//   Shift left/right
//   Magnitude compare
//   And, Or, Nand, Nor, XNor
// Flags:
//   Flag        bit
//   Z zero      0
//   C carry     1
//   N negative  2
//   V Overflow  3
// The output is tri capable.
// --------------------------------------------------------------------------

// Add/Subtract references used for the ALU
// https://en.wikipedia.org/wiki/Carry_flag#
// http://teaching.idallen.com/dat2343/10f/notes/040_overflow.txt

module ALU
#(
    parameter DataWidth = 8, // Bitwidth, Default to 8 bits
                             // 3 2 1 0
    parameter FlagBits = 4   // V,N,C,Z
)
(
    input wire [FlagBits-1:0] IFlags,
    input wire [DataWidth-1:0] A,
    input wire [DataWidth-1:0] B,
    input wire [3:0] FuncOp,            // Operation
    output wire [DataWidth-1:0] Y,      // Results output
    output wire [FlagBits-1:0] OFlags   // Flag result
);

parameter ZeroFlag   = 0,
          CarryFlag  = 1,
          NegFlag    = 2,
          OverFlag   = 3;  // aka. V flag

// Allow operation codes
parameter Add_OP  = 4'b0000,
          Sub_OP  = 4'b0001,
          And_OP  = 4'b0010,
          Or_OP   = 4'b0011,
          Xor_OP  = 4'b0100;

// Local Vars
reg [DataWidth-1:0] ORes;
// wire oF, nF, zF;
reg cF;

always @(FuncOp, A, B, IFlags) begin
    case (FuncOp)
        Add_OP: begin
            `ifdef SIMULATE
                $display("%d Add_OP: A: %h, B: %h", $stime, A, B);
            `endif

            // Carry and sum
            {cF, ORes} = A + B + IFlags[CarryFlag];
            `ifdef SIMULATE
                $display("%d Add_OP: Carry %b, Sum %h", $stime, cF, ORes);
            `endif
        end
        Sub_OP: begin  // As if the Carry == 0
            `ifdef SIMULATE
                $display("%d Sub_OP: A: %h - B: %h", $stime, A, B);
            `endif

            {cF, ORes} = A + ((~B) + 1);
            `ifdef SIMULATE
                $display("%d Sub_OP: Carry %b, Diff %h", $stime, cF, ORes);
            `endif
        end
        And_OP: begin
            `ifdef SIMULATE
                $display("%d And_OP: (%d) & (%d)", $stime, A, B);
            `endif
            {cF, ORes} = {1'b0, A & B};
        end
        Or_OP: begin
            `ifdef SIMULATE
                $display("%d Or_OP: (%d) | (%d)", $stime, A, B);
            `endif
            {cF, ORes} = {1'b0, A | B};
        end
        Xor_OP: begin
            `ifdef SIMULATE
                $display("%d Xor_OP: (%d) ^ (%d)", $stime, A, B);
            `endif
            {cF, ORes} = {1'b0, A ^ B};
        end
        default: begin
            `ifdef SIMULATE
                $display("%d *** ALU UNKNOWN OP: %04b", $stime, FuncOp);
            `endif
            ORes = {DataWidth{1'b0}};// {DataWidth{1'bx}};
        end
    endcase
end

// Set remaining flags
// assign zF = ORes == {DataWidth{1'b0}};  // Zero
// assign nF = ORes[DataWidth-1];          // Negative

// 2's compliment overflow flag
// The rules for turning on the overflow flag in binary/integer math are two:
// 1. If the sum of two numbers with the sign bits off yields a result number
//    with the sign bit on, the "overflow" flag is turned on.
// 2. If the sum of two numbers with the sign bits on yields a result number
//    with the sign bit off, the "overflow" flag is turned on.
// assign oF = (
//         // Input Sign-bits Off yet Result sign-bit On 
//         ((A[DataWidth-1] == 0) && (B[DataWidth-1] == 0) && (ORes[DataWidth-1] == 1)) ||
//         // Input Sign-bits On yet Result sign-bit Off
//         ((A[DataWidth-1] == 1) && (B[DataWidth-1] == 1) && (ORes[DataWidth-1] == 0))
//     );

assign OFlags = {
    (
        // Input Sign-bits Off yet Result sign-bit On 
        ((A[DataWidth-1] == 0) && (B[DataWidth-1] == 0) && (ORes[DataWidth-1] == 1)) ||
        // Input Sign-bits On yet Result sign-bit Off
        ((A[DataWidth-1] == 1) && (B[DataWidth-1] == 1) && (ORes[DataWidth-1] == 0))
    ),                          // V
    ORes[DataWidth-1],          // N
    cF,                         // C
    ORes == {DataWidth{1'b0}}   // Z
};

assign Y = ORes;

endmodule
