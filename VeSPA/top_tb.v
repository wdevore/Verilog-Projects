// --------------------------------------------------------------------------
// Test bench for VeSPA cpu
// --------------------------------------------------------------------------
`timescale 1ns/1ps

`include "opcodes.v"
`include "op_fields.v"

`include "fetch.v"
`include "execute.v"

module vespa_tb;
    parameter WIDTH = 32;          // Datapath width.
    parameter NUMREGS = 32;        // Register File size
    parameter MEMSIZE = (1 << 9);  // Size of simulated RAM. o -> 2^9 = 512bytes

    // State registers
    reg[7:0]        MEM[0:MEMSIZE-1];  // Byte sized word of main memory.
    reg[WIDTH-1:0]  R[0:NUMREGS-1];    // General purpose registers.
    reg[WIDTH-1:0]  PC;                // Program counter.
    reg C;                             // Carry condition code bit.
    reg V;                             // Overflow condition code bit.
    reg Z;                             // Zero condition code bit.
    reg N;                             // Negative condition code bit.
    reg RUN;                           // Execute while RUN=1, used by HLT.

    reg[WIDTH-1:0]  op1;    // Source operand 1.
    reg[WIDTH-1:0]  op2;    // Source operand 2.
    reg[WIDTH:0]    result; // ALU results

    integer num_instrs;

    initial begin
        // Load MEM with instructions (aka program)
        $readmemh("v.out", MEM);

        RUN = 1;
        PC = 1;
        num_instrs = 0;

        while (RUN == 1) begin
            num_instrs = num_instrs + 1;    // Count instructions executed.
            fetch;                          // Fetch next instruction.
            execute;                        // Execute the instruction.
            print_trace;
        end

        $display("\nTotal instructions executed: %d\n\n", num_instrs);
        $finish;    // End simulation
    end
endmodule