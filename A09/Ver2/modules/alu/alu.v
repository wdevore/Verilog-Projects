`default_nettype none

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

localparam ZeroFlag   = 0,
           CarryFlag  = 1,
           NegFlag    = 2,
           OverFlag   = 3;  // aka. V flag

// Local Vars
reg [DataWidth-1:0] ORes;
// wire oF, nF, zF;
reg cF;

always @* begin
    // Initial conditions
    ORes = {DataWidth{1'b0}};// {DataWidth{1'bx}};
    cF = 1'b0;

    case (FuncOp)
        `AddOp: begin
            `ifdef SIMULATE
                $display("%d Add_OP: A: %h, B: %h", $stime, A, B);
            `endif

            // Carry and sum
            {cF, ORes} = A + B + IFlags[CarryFlag];
            `ifdef SIMULATE
                $display("%d Add_OP: Carry %b, Sum %h", $stime, cF, ORes);
            `endif
        end
        `SubOp: begin  // As if the Carry == 0
            `ifdef SIMULATE
                $display("%d Sub_OP: A: %h - B: %h", $stime, A, B);
            `endif

            {cF, ORes} = A + ((~B) + 1);
            `ifdef SIMULATE
                $display("%d Sub_OP: Carry %b, Diff %h", $stime, cF, ORes);
            `endif
        end
        `AndOp: begin
            `ifdef SIMULATE
                $display("%d And_OP: (%d) & (%d)", $stime, A, B);
            `endif
            {cF, ORes} = {1'b0, A & B};
        end
        `OrOp: begin
            `ifdef SIMULATE
                $display("%d Or_OP: (%d) | (%d)", $stime, A, B);
            `endif
            {cF, ORes} = {1'b0, A | B};
        end
        `NotOp: begin
            `ifdef SIMULATE
                $display("%d Not_OP: !(%d)", $stime, A);
            `endif
            {cF, ORes} = {1'b0, ~A};
        end
        `XorOp: begin
            `ifdef SIMULATE
                $display("%d Xor_OP: (%d) ^ (%d)", $stime, A, B);
            `endif
            {cF, ORes} = {1'b0, A ^ B};
        end
        `ShlOp: begin
            `ifdef SIMULATE
                $display("%d Shl_OP: (%d) << (%d)", $stime, A, B);
            `endif
            // The left hand side contains the variable to shift,
            // the right hand side contains the number of shifts to perform
            {cF, ORes} = {A[DataWidth-1], A << B};
        end
        `ShrOp: begin
            `ifdef SIMULATE
                $display("%d Shr_OP: (%d) >> (%d)", $stime, A, B);
            `endif
            {cF, ORes} = {A[0], A >> B};
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
