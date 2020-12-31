// Define the op-code, source register, etc., fields in the IR.

`define	OPCODE	IR[31:27]	// op-code field
`define	rdst	IR[26:22]	// destination register
`define	rs1	    IR[21:17]	// source register 1
`define	IMM_OP	IR[16]		// IR[16]==1 when source 2 is immediate operand
`define	rs2	    IR[15:11]	// source register 2
`define	rst	    IR[26:22]	// source register for store op
`define	immed23	IR[22:0]	// 23-bit literal field
`define	immed22	IR[21:0]	// 22-bit literal field
`define	immed17	IR[16:0]	// 17-bit literal field
`define	immed16	IR[15:0]	// 16-bit literal field
`define	COND	IR[26:23]	// Branch conditions.
