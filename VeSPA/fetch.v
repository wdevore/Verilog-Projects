// Fetch the next instruction from memory and move it into the IR.

task fetch;
    begin
        // First fetch the instruction from memory.
        IR = read_mem(PC);
        PC = PC + 4;        // Move to the next instruction.
    end
endtask
