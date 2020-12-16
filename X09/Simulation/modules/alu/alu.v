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

module ALU
    #(
        parameter BitWidth = 8 // Default to 8 bits
    )
    (
        output tri [BitWidth-1:0] ResLow,    // Tri-state output
        output tri [BitWidth-1:0] ResHigh,    // Tri-state output
        output [3:0] Flags,
        input Clk,
        input [BitWidth-1:0] A,
        input [BitWidth-1:0] B,
        input [3:0] Func,                   // Operation
        input OE,      // Active low,  enables output
    );

    parameter   ZeroFlag   = 0,
                CarryFlag  = 1,
                NegFlag    = 2,
                OverFlag   = 3;

    // Allow operation codes
    parameter   add_op  = 4'b0000,
                sub_op  = 4'b0001,
                mul_op  = 4'b0010,
                and_op  = 4'b0011,
                or_op   = 4'b0100,
                not_op  = 4'b0101, //negation
                xor_op  = 4'b0110,
                xnor_op = 4'b0111;

    // Local Vars
    parameter RDelay = 1;
    reg [BitWidth-1:0] Res;

    always @(A, B, OP)
        case (Func)
            add_op: begin
                // Carry and sum
                {Flags[CarryFlag], Res} = #RDelay A + B;
                
                // MSB of signed
                Flags[NegFlag] = Res[BitWidth-1];

                if (Res == 0)
                    Flags[ZeroFlag] = 1;
                else
                    Flags[ZeroFlag] = 0;

                // 2's compliment overflow flag
                if ( ((A[BitWidth-1] == 0) && (B[BitWidth-1] == 0) && (Result[BitWidth-1] == 1)) ||
                    ( (A[BitWidth-1] == 1) && (B[BitWidth-1] == 1) && (Result[BitWidth-1] == 0)) )
                    Flags[OverFlag] = 1;
                else
                    Flags[OverFlag] = 0;
            end
            sub_op:  Res = #RDelay A - B;
            mul_op:  Res = #RDelay A * B;
            and_op:  Res = #RDelay A & B;
            or_op:   Res = #RDelay A | B;
            not_op:  Res = #RDelay ~A;
            xor_op:  Res = #RDelay A ^ B;
            xnor_op: Res = #RDelay ~(A ^ B);
            default:
                Res = {2*BitWidth{1'bx}};
                Flags = 4'bx;
        endcase

    assign #RDelay ResHigh = OE ? {BitWidth{1'bz}} : Res & 16'h;
    assign #RDelay {ResHigh, ResLow} = OE ? {BitWidth{1'bz}} : Res;

endmodule
