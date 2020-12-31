// All memory is: Big-endian ordering

function [WIDTH-1:0] read_mem;
    input [WIDTH-1:0] addr;		// the address from which to read
    
    read_mem = {MEM[addr],MEM[addr+1],MEM[addr+2],MEM[addr+3]};
endfunction

// Write the given value to the given address in big-endian order.

task write_mem;
    input [WIDTH-1:0] addr;	// Address to which to write.
    input [WIDTH-1:0] data;	// The data to write.
    
    begin
        {MEM[addr],MEM[addr+1],MEM[addr+2],MEM[addr+3]} = data;
    end
endtask
