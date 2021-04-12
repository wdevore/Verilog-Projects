// Misc Instructions
`define NOP 5'b00001

// ALU Ops (Arithmetic and Logic)
`define ADD 5'b00010
`define SUB 5'b00011
`define AND 5'b00100
`define OR  5'b00101
`define XOR 5'b00110
`define NOT 5'b00111
`define SHL 5'b01000
`define SHR 5'b01001

// Branches
`define BDQ 5'b01010    // BEQ
`define BDE 5'b01011    // BNE
`define BDT 5'b01100    // BLT
`define BDS 5'b01101    // BCS

`define BXQ 5'b01110    // BEQ
`define BXE 5'b01111    // BNE
`define BXT 5'b10000    // BLT
`define BXS 5'b10001    // BCS

`define JPL 5'b10010
`define JMP 5'b10011
`define RET 5'b10100

// Load/Store
`define LDI 5'b10101
`define LD  5'b10110
`define MOV 5'b10111
`define ST  5'b11000
`define STX 5'b11001

`define OTR 5'b11010
`define OTM 5'b11011

`define HLT 5'b11111

// ALU
`define AddOp 4'b0000
`define SubOp 4'b0001
`define AndOp 4'b0010
`define  OrOp 4'b0011
`define XorOp 4'b0100
`define NotOp 4'b0101
`define ShlOp 4'b0110
`define ShrOp 4'b0111