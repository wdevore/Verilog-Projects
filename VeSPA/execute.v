// Contains both the Control unit and ALU combined

// Set the condition codes according to the given input value.

task setcc;
    input [WIDTH-1:0] op1;	// Operand 1.
    input [WIDTH-1:0] op2;	// Operand 2.
    input [WIDTH:0] result;	// The calculated result value.
    // Set if the operation was a subtraction.
    // In this case, the sign bit of op2 must be inverted to correctly
    // calculate the V bit.
    input subt;
    
    begin
        C = result[WIDTH];		// The carry out of the result.
        
        Z = ~(|result[WIDTH-1:0]);	// Result is zero if all bits are 0.
        
        N = result[WIDTH-1];	// Result is negative if the most
        // significant bit is a 1.
        
        // A two's complement overflow for addition occurs if the
        // sign bit of the result is the opposite of the sign bit
        // of the two operands.  Note that for subtraction, the subt
        // input should be set to invert the sign of op2 before calculating
        // the V bit.
        V = (result[WIDTH-1] & ~op1[WIDTH-1] & ~(subt ^ op2[WIDTH-1]))
        | (~result[WIDTH-1] &  op1[WIDTH-1] &  (subt ^ op2[WIDTH-1]));
    end
endtask

// Returns 1 if branch is to be taken.
// Check the condition codes and return either a 0 or 1 depending
// upon the particular condition selected by the instruction.

function checkcc;
    input Z;			// The condition code bits.
    input C;
    input N;
    input V;
    
    begin
        //	$display("####  COND                = %h",`COND);
        //	$display("####  Condition codes:  C = %b  V = %b  Z = %d  N = %b", C,V,Z,N);
        //	$display("####  IR                  = %h",IR);
        case (`COND)
            `BRA: begin
                checkcc = 1;
            end
            `BNV: begin
                checkcc = 0;
            end
            `BCC: begin
                checkcc = ~C;
            end
            `BCS: begin
                checkcc = C;
            end
            `BVC: begin
                checkcc = ~V;
            end
            `BVS: begin
                checkcc = V;
            end
            `BEQ: begin
                checkcc = Z;
            end
            `BNE: begin
                checkcc = ~Z;
            end
            `BGE: begin
                checkcc = (~N & ~V) | (N & V);
            end
            `BLT: begin
                checkcc = (N & ~V) | (~N & V);
            end
            `BGT: begin
                checkcc = ~Z & ((~N & ~V) | (N & V));
            end
            `BLE: begin
                // ERROR: changed the equation from Z + to Z |
                checkcc = Z | ((N & ~V) | (~N & V));
                
                $display("checkcc = %d", checkcc);
            end
            `BPL: begin
                checkcc = ~N;
            end
            `BMI: begin
                checkcc = N;
            end
        endcase
        //	$display("####  checkcc = %b",checkcc);
    end
endfunction

// Main task

task execute;
    begin
        case (`OPCODE)
            `ADD: begin
                if (`IMM_OP == 0)
                    op2 = R[`rs2];
                else
                    op2 = sext16(`immed16);
                
                op1      = R[`rs1];
                result   = op1 + op2;
                R[`rdst] = result[WIDTH-1:0];
                setcc(op1, op2, result, 0);
            end
            `AND: begin
                if (`IMM_OP == 0)
                    op2 = R[`rs2];
                else
                    op2 = sext16(`immed16);
                
                op1      = R[`rs1];
                result   = op1 & op2;
                R[`rdst] = result[WIDTH-1:0];
            end
            `XOR: begin
                if (`IMM_OP == 0)
                    op2 = R[`rs2];
                else
                    op2 = sext16(`immed16);
                
                op1      = R[`rs1];
                result   = op1 ^ op2;
                R[`rdst] = result[WIDTH-1:0];
            end
            `BXX: begin
                if (checkcc(Z,C,N,V) == 1) begin
                    PC = PC  + sext23(`immed23);
                end
            end
            `CMP: begin
                if (`IMM_OP == 0)
                    op2 = R[`rs2];
                else
                    op2 = sext16(`immed16);
                
                op1    = R[`rs1];
                result = op1 - op2;
                setcc(op1, op2, result, 1);
            end
            `HLT: begin
                RUN = 0;
            end
            `JMP: begin
                if (`IMM_OP == 1) begin // If jump-and-link operation, the old PC
                    R[`rdst] = PC;	// value must be saved before it is lost.
                end
                PC = R[`rs1] + sext16(`immed16);
            end
            `LD: begin
                R[`rdst] = read_mem(sext22(`immed22));
            end
            `LDI: begin
                R[`rdst] = sext22(`immed22);
            end
            `LDX: begin
                R[`rdst] = read_mem(R[`rs1] + sext17(`immed17));
            end
            `NOP: begin
                // Do nothing
            end
            `NOT: begin
                op1      = R[`rs1];
                result   = ~op1;
                R[`rdst] = result[WIDTH-1:0];
            end
            `OR: begin
                if (`IMM_OP == 0)
                    op2 = R[`rs2];
                else
                    op2 = sext16(`immed16);
                
                op1      = R[`rs1];
                result   = op1 | op2;
                R[`rdst] = result[WIDTH-1:0];
            end
            `ST: begin
                write_mem(sext22(`immed22),R[`rst]);
            end
            `STX: begin
                write_mem(R[`rs1] + sext17(`immed17),R[`rst]);
            end
            `SUB: begin
                if (`IMM_OP == 0)
                    op2 = R[`rs2];
                else
                    op2 = sext16(`immed16);
                
                op1      = R[`rs1];
                result   = op1 - op2;
                R[`rdst] = result[WIDTH-1:0];
                setcc(op1, op2, result, 1);
            end
            default: begin
                $display("Error: undefined opcode:  %d",`OPCODE);
            end
        endcase
    end
endtask

