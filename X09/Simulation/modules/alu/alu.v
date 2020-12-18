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

// https://en.wikipedia.org/wiki/Carry_flag#

module ALU
    #(
        parameter BitWidth = 8, // Default to 8 bits
        parameter FlagBits = 4  // V,N,C,Z
    )
    (
        output tri [BitWidth-1:0] Y,      // Tri-state output
        output wire [FlagBits-1:0] OFlags,
        input wire [FlagBits-1:0] IFlags,
        input wire [BitWidth-1:0] A,
        input wire [BitWidth-1:0] B,
        input wire [3:0] FuncOp,          // Operation
        input wire OE                     // Active low,  enables output
    );

    parameter   ZeroFlag   = 0,
                CarryFlag  = 1,
                NegFlag    = 2,
                OverFlag   = 3;  // aka. V flag

    // Allow operation codes
    parameter   add_op  = 4'b0000,
                sub_op  = 4'b0001, // Subtract
                mul_op  = 4'b0010,
                and_op  = 4'b0011,
                or_op   = 4'b0100,
                not_op  = 4'b0101, // Negation
                xor_op  = 4'b0110,
                xnor_op = 4'b0111,
                subc_op = 4'b1000; // Subtract with carry(borrow)
    
    // Local Vars
    parameter RDelay = 1;
    reg [BitWidth-1:0] ORes;
    wire oF, nF, zF;
    reg cF;

    always @(*)
        case (FuncOp)
            add_op: begin
                $display("Add OP: %d + %d", A, B);

                // Carry and sum
                {cF, ORes} = #RDelay A + B + IFlags[CarryFlag];
            end
            sub_op: begin  // As if the Carry == 0
                $display("Sub OP: %d - %d", A, B);

                {cF, ORes} = #RDelay A + ((~B) + 1);
            end
            subc_op: begin
                $display("SubC OP: %d - %d", A, B);

                //                                  Sub with carry 6809 SBCx
                // C     Sub           Sub-WB       Sub-WC
                // 0     A+(~B+1)      A+(~B+1)     A+(~B)
                // 1                   A+(~B)       A+(~B+1)
                if (IFlags[CarryFlag] == 1'b0)
                    {cF, ORes} = #RDelay A + ((~B) + 1);
                else
                    {cF, ORes} = #RDelay A + ((~B));
            end
            // mul_op:  ORes = #RDelay A * B;
            // and_op:  ORes = #RDelay A & B;
            // or_op:   ORes = #RDelay A | B;
            // not_op:  ORes = #RDelay ~A;
            // xor_op:  ORes = #RDelay A ^ B;
            // xnor_op: ORes = #RDelay ~(A ^ B);
            default: begin
                $display("*** UNKNOWN OP: %04b", FuncOp);
                ORes = #RDelay {BitWidth{1'bx}};
                // OFlags = #RDelay 4'bx;
            end
        endcase

    assign zF = ORes == {BitWidth{1'b0}};  // Zero
    assign nF = ORes[BitWidth-1];          // Negative

    // 2's compliment overflow flag
    // The rules for turning on the overflow flag in binary/integer math are two:
    // 1. If the sum of two numbers with the sign bits off yields a result number
    //    with the sign bit on, the "overflow" flag is turned on.
    // 2. If the sum of two numbers with the sign bits on yields a result number
    //    with the sign bit off, the "overflow" flag is turned on.
    assign oF = (
            ((A[BitWidth-1] == 0) && (B[BitWidth-1] == 0) && (ORes[BitWidth-1] == 1)) ||
            ((A[BitWidth-1] == 1) && (B[BitWidth-1] == 1) && (ORes[BitWidth-1] == 0))
        );

    //               V,  N,  C,  Z
    assign OFlags = {oF, nF, cF, zF};

    assign #RDelay Y = OE ? {BitWidth{1'bz}} : ORes;

endmodule
