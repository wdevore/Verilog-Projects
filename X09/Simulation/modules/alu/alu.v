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
        parameter N = 8, // Bitwidth, Default to 8 bits
        parameter FlagBits = 4  // V,N,C,Z
    )
    (
        output tri [N-1:0] Y,      // Tri-state output
        output wire [FlagBits-1:0] OFlags,
        input wire [FlagBits-1:0] IFlags,
        input wire [N-1:0] A,
        input wire [N-1:0] B,
        input wire [3:0] FuncOp,          // Operation
        input wire OE                     // Active low,  enables output
    );

    localparam  ZeroFlag   = 0,
                CarryFlag  = 1,
                NegFlag    = 2,
                OverFlag   = 3;  // aka. V flag

    // Allow operation codes
    localparam   Add_OP  = 4'b0000,
                Sub_OP  = 4'b0001, // Subtract
                Subc_OP = 4'b0010, // Subtract with carry(borrow)
                And_OP  = 4'b0011,
                Or_OP   = 4'b0100,
                Not_OP  = 4'b0101, // Negation
                Xor_OP  = 4'b0110,
                LsrA_OP = 4'b0111, // Logical right shift, zero fill
                LslA_OP = 4'b1000, // Logical left shift, zero fill
                LsrB_OP = 4'b1001, // Logical right shift, zero fill
                LslB_OP = 4'b1010, // Logical left shift, zero fill
                AsrA_OP = 4'b1011; // Arithmetic right shift
                AsrB_OP = 4'b1100; // Arithmetic right shift
                // Xnor_OP = 4'b0111;
    
    // Local Vars
    localparam RDelay = 1;
    reg [N-1:0] ORes;
    wire oF, nF, zF;
    reg cF;

    always @*
        case (FuncOp)
            Add_OP: begin
                $display("Add_OP: %d + %d", A, B);

                // Carry and sum
                {cF, ORes} = #RDelay A + B + IFlags[CarryFlag];
            end
            Sub_OP: begin  // As if the Carry == 0
                $display("Sub_OP: %d - %d", A, B);

                {cF, ORes} = #RDelay A + ((~B) + 1);
            end
            Subc_OP: begin
                $display("Subc_OP: %d - %d", A, B);
                //                     Borrow       Carry
                // C     Sub           Sub-WB       Sub-WC
                // 0     A+(~B+1)      A+(~B+1)     A+(~B)
                // 1                   A+(~B)       A+(~B+1) 
                //                      ^
                //                      |
                if (IFlags[CarryFlag] == 1'b0)
                    {cF, ORes} = #RDelay A + ((~B) + 1);
                else
                    {cF, ORes} = #RDelay A + ((~B));
            end
            And_OP: begin
                $display("And_OP: (%d) & (%d)", A, B);
                {cF, ORes} = #RDelay {1'b0, A & B};
            end
            Or_OP: begin
                $display("Or_OP: (%d) | (%d)", A, B);
                {cF, ORes} = #RDelay {1'b0, A | B};
            end
            Not_OP: begin
                $display("Not_OP: (%d)", A);
                {cF, ORes} = #RDelay {1'b0, ~A};
            end
            Xor_OP: begin
                $display("Xor_OP: (%d) ^ (%d)", A, B);
                {cF, ORes} = #RDelay {1'b0, A ^ B};
            end
            LsrA_OP: begin
                $display("LsrA_OP: (%d)", A);
                //                    0 ->  MSB LSB-1 -> cF 
                {ORes, cF} = #RDelay {1'b0, A[N-1:1], A[0]};
            end
            LslA_OP: begin
                $display("LslA_OP: (%d)", A);
                //                    cF <-   MSB-2 0 <- 0 
                {cF, ORes} = #RDelay {A[N-1], A[N-2:0], 1'b0};
            end
            LsrB_OP: begin
                $display("LsrB_OP: (%d)", B);
                //                    0 ->  MSB LSB-1 -> cF
                {ORes, cF} = #RDelay {1'b0, B[N-1:1], B[0]};
            end
            LslB_OP: begin
                $display("LslB_OP: (%d)", B);
                //                    cF <-   MSB-2 0 <- 0  
                {cF, ORes} = #RDelay {B[N-1], B[N-2:0], 1'b0};
            end
            AsrA_OP: begin
                $display("AsrA_OP: (%d)", A);
                //                    /--|
                //                    [N-1]->MSB LSB-1->cF 
                {ORes, cF} = #RDelay {A[N-1], A[N-1:1], A[0]};
            end
            // xnor_op: ORes = #RDelay ~(A ^ B); // Not implemented
            default: begin
                $display("*** UNKNOWN OP: %04b", FuncOp);
                ORes = #RDelay {N{1'bx}};
                // OFlags = #RDelay 4'bx;
            end
        endcase

    // Set remaining flags
    assign #RDelay zF = ORes == {N{1'b0}};  // Zero
    assign #RDelay nF = ORes[N-1];          // Negative

    // 2's compliment overflow flag
    // The rules for turning on the overflow flag in binary/integer math are two:
    // 1. If the sum of two numbers with the sign bits off yields a result number
    //    with the sign bit on, the "overflow" flag is turned on.
    // 2. If the sum of two numbers with the sign bits on yields a result number
    //    with the sign bit off, the "overflow" flag is turned on.
    //
    
    assign #RDelay oF =
        FuncOp == LslA_OP ? A[N-1] ^ A[N-2] : // For 6809 LSL the V flag is specially calculated using xor.
        FuncOp == LslB_OP ? B[N-1] ^ B[N-2] :
        (
            // Input Sign-bits Off yet Result sign-bit On 
            ((A[N-1] == 0) && (B[N-1] == 0) && (ORes[N-1] == 1)) ||
            // Input Sign-bits On yet Result sign-bit Off
            ((A[N-1] == 1) && (B[N-1] == 1) && (ORes[N-1] == 0))
        );

    //                       V,  N,  C,  Z
    assign #RDelay OFlags = {oF, nF, cF, zF};

    assign #RDelay Y = OE ? {N{1'bz}} : ORes;

endmodule
