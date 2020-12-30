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
                R[‘rdst] = result[WIDTH-1:0];
                setcc(op1, op2, result, 0);
            end
            `AND: begin
                if (‘IMM_OP == 0)
                    op2 = R[‘rs2];
                else
                    op2 = sext16(‘immed16);
                
                op1      = R[‘rs1];
                result   = op1 & op2;
                R[‘rdst] = result[WIDTH-1:0];
            end
        endcase
    end
endtask
