function [WIDTH-1:0] read_mem;
    input[WIDTH-1:0] addr;  // The address from which to read
    // Big-endian ordering
    read_mem = {MEM[addr],MEM[addr+1],MEM[addr+2],MEM[addr+3]};
endfunction

task fetch;
    begin
        // First fetch the instruction from memory.
        IR = read_mem(PC);
        PC = PC + 4;        // Move to the next instruction.
    end
endtask
