// Misc Instructions
`define NOP 4'b0000
`define HLT 4'b0001

// ALU Ops
`define ADD 4'b0010
`define SUB 4'b0011
`define AND 4'b0100
`define OR  4'b0101
`define XOR 4'b0110

// Jump/Branches
`define BRD 4'b0111
`define BRX 4'b1000
`define JPL 4'b1001
`define JMP 4'b1001
`define RET 4'b1010

// Load/Store
`define LDI 4'b1011
`define LD  4'b1100
`define ST  4'b1101
`define STX 4'b1110
`define MOV 4'b1111
