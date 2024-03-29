// Define the op-codes specified in the ISA.

`define	NOP	'd0
`define	ADD	'd1
`define	SUB	'd2
`define	OR	'd3
`define	AND	'd4
`define	NOT	'd5
`define XOR 'd6
`define	CMP	'd7
`define	BXX	'd8
`define	JMP	'd9
`define	LD	'd10
`define	LDI	'd11
`define	LDX	'd12
`define	ST	'd13
`define	STX	'd14
`define	HLT	'd31

// Define the conditions available in a conditional branch.

`define	BRA	'b0000
`define	BNV	'b1000
`define	BCC	'b0001
`define	BCS	'b1001
`define	BVC	'b0010
`define	BVS	'b1010
`define	BEQ	'b0011
`define	BNE	'b1011
`define	BGE	'b0100
`define	BLT	'b1100
`define	BGT	'b0101
`define	BLE	'b1101
`define	BPL	'b0110
`define	BMI	'b1110
