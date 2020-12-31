task print_trace;
    integer i;
    integer j;
    integer k;
    
    begin
        `ifdef TRACE_PC
        begin
            $display("Instruction #:%d\tPC = %h\tOPCODE = %d", num_instrs, PC, `OPCODE);
        end
        `endif // TRACE_PC
        
        `ifdef TRACE_CC
        begin
            $display("Condition codes: C = %b V = %b Z = %d N = %b", C,V,Z,N);
        end
        `endif // TRACE_CC
        
        `ifdef TRACE_REGS
        begin
            k = 0;
            for (i = 0; i < NUMREGS; i = i + 4)
            begin
                $write("R[%d]: ",k);
                for (j = 0; j < = 3; j = j + 1)
                begin
                    $write(" %h",R[k]);
                    k = k + 1;
                end
                $write("\n");
            end
            $write("\n");
        end
        `endif // TRACE_REGS
        
    end
endtask

`define EXTWIDTH = 16
function [WIDTH-1:0] sext16; // 16-bit input
    input [`EXTWIDTH-1:0] d_in; // the bit field to be sign extended
    sext16[WIDTH-1:0] = { {(WIDTH - `EXTWIDTH){d_in[`EXTWIDTH-1]}} ,d_in};
endfunction

`define EXTWIDTH = 17
function [WIDTH-1:0] sext17; // 17-bit input
    input [`EXTWIDTH-1:0] d_in; // the bit field to be sign extended
    sext17[WIDTH-1:0] = { {(WIDTH - `EXTWIDTH){d_in[`EXTWIDTH-1]}} ,d_in};
endfunction

`define EXTWIDTH = 22
function [WIDTH-1:0] sext22; // 22-bit input
    input [`EXTWIDTH-1:0] d_in; // the bit field to be sign extended
    sext22[WIDTH-1:0] = { {(WIDTH - `EXTWIDTH){d_in[`EXTWIDTH-1]}} ,d_in};
endfunction

`define EXTWIDTH = 23
function [WIDTH-1:0] sext23; // 23-bit input
    input [`EXTWIDTH-1:0] d_in; // the bit field to be sign extended
    sext23[WIDTH-1:0] = { {(WIDTH - `EXTWIDTH){d_in[`EXTWIDTH-1]}} ,d_in};
endfunction
