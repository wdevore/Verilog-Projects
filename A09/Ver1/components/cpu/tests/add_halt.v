// =========================================================
// Note: for this test make sure you change the "`define ROM"
// line to load "Add_Halt.dat"
// =========================================================

wait(cpu.ControlMatrix.state === cpu.ControlMatrix.S_FetchMEMtoIR && cpu.ControlMatrix.next_state === cpu.ControlMatrix.S_Decode);

// IR should have been loaded with the LDI instruction
// LDI R1, 0x02   <-- 0xB202
if (cpu.ir !== 'hB202) begin
    $display("%d %m: ###ERROR### - Expected IR = hB202 Got: %h", $stime, cpu.ir);
end

// Check Reg-File Src1 extracted from the lower IR
if (cpu.reg_src1 !== 3'b010) begin
    $display("%d %m: ###ERROR### - Expected reg_src1 = 'h2 Got: %b", $stime, cpu.reg_src1);
end

// Check Reg-File Destination extracted from the upper IR
if (cpu.reg_dest !== 3'b001) begin
    $display("%d %m: ###ERROR### - Expected reg_dest = 'h1 Got: %b", $stime, cpu.reg_src1);
end

// Check that data from memory is being written to Reg-File destination
// Which means we wait for a pos AND neg clock edge.
@(posedge Clock_TB) // Data is presented to Reg-File here
$display("%d <-- Marker Clock Reg-File pos-edge", $stime);

// Which should be present at the negative clock edge
@(negedge Clock_TB) // Data is "Writing" here

#1; // Wait for data to be written

if (cpu.RegFile.reg_file[1] !== 16'h0002) begin
    $display("%d %m: ###ERROR### - Expected Reg-File #1 write = 'h2 Got: %b", $stime, cpu.RegFile.reg_file[1]);
end

// ---------------------------------------------------
// Now wait for next instruction cycle to start
// ---------------------------------------------------
wait(cpu.ControlMatrix.state === cpu.ControlMatrix.S_FetchPCtoMEM && cpu.ControlMatrix.next_state === cpu.ControlMatrix.S_FetchMEMtoIR);
$display("%d <-- Instruction (%d) at", $stime, cycleCnt);
cycleCnt++;

wait(cpu.ControlMatrix.state === cpu.ControlMatrix.S_FetchMEMtoIR && cpu.ControlMatrix.next_state === cpu.ControlMatrix.S_Decode);

// Now that it has started we wait until the instruction
// has been loaded which has happened once we are at the Decode phase.
wait(cpu.ControlMatrix.state === cpu.ControlMatrix.S_Decode && cpu.ControlMatrix.next_state === cpu.ControlMatrix.S_FetchPCtoMEM);

// The instruction should be:
// LDI R2, 0x04  <-- 0xB404
if (cpu.ir !== 'hB404) begin
    $display("%d %m: ###ERROR### - Expected IR = hB404 Got: %h", $stime, cpu.ir);
end

// Now we check that R2 has been loaded with 0x04.
// To that we need to wait 1/2 clock for the neg-edge
@(negedge Clock_TB) // Data is "Writing" here

#1; // Wait for data to be written

if (cpu.RegFile.reg_file[2] !== 16'h0004) begin
    $display("%d %m: ###ERROR### - Expected Reg-File #2 write = 'h4 Got: %b", $stime, cpu.RegFile.reg_file[2]);
end

// ---------------------------------------------------
// Now wait for next instruction cycle to start
// ---------------------------------------------------
wait(cpu.ControlMatrix.state === cpu.ControlMatrix.S_FetchPCtoMEM && cpu.ControlMatrix.next_state === cpu.ControlMatrix.S_FetchMEMtoIR);
$display("%d <-- Instruction (%d) at", $stime, cycleCnt);
cycleCnt++;

wait(cpu.ControlMatrix.state === cpu.ControlMatrix.S_FetchMEMtoIR && cpu.ControlMatrix.next_state === cpu.ControlMatrix.S_Decode);

// The instruction has started. Now we wait until the instruction
// has been loaded which has happened once we are at the Decode phase.
// However, the ADD is a 4 cycle instruction and thus the next state
// after Decode is Execute NOT FetchPCtoMEM.
wait(cpu.ControlMatrix.state === cpu.ControlMatrix.S_Decode && cpu.ControlMatrix.next_state === cpu.ControlMatrix.S_Execute);

// The instruction should be:
// ADD R3, R2, R1  <-- 0x2621
if (cpu.ir !== 'h2621) begin
    $display("%d %m: ###ERROR### - Expected IR = h2621 Got: %h", $stime, cpu.ir);
end

// Now we wait for the Execute to complete
wait(cpu.ControlMatrix.state === cpu.ControlMatrix.S_Execute && cpu.ControlMatrix.next_state === cpu.ControlMatrix.S_FetchPCtoMEM);

// We need to wait 1/2 clock for the neg-edge
@(negedge Clock_TB) // Data is "Writing" here

#1; // Wait for data to be written

// R3 should now have the sum of 2 + 4 = 6
if (cpu.RegFile.reg_file[3] !== 16'h0006) begin
    $display("%d %m: ###ERROR### - Expected Reg-File #3 write = 'h6 Got: %b", $stime, cpu.RegFile.reg_file[2]);
end

$display("%d <-- Sum in R3 is (%d)", $stime, cpu.RegFile.reg_file[3]);

// ---------------------------------------------------
// Now wait for next instruction cycle to start
// ---------------------------------------------------
wait(cpu.ControlMatrix.state === cpu.ControlMatrix.S_FetchPCtoMEM && cpu.ControlMatrix.next_state === cpu.ControlMatrix.S_FetchMEMtoIR);
$display("%d <-- Instruction (%d) at", $stime, cycleCnt);
cycleCnt++;

// Now that it has started we wait until the instruction
// has been loaded which has happened once we are at the Decode phase.
wait(cpu.ControlMatrix.state === cpu.ControlMatrix.S_FetchMEMtoIR && cpu.ControlMatrix.next_state === cpu.ControlMatrix.S_Decode);

// Now that it has started we wait until the instruction
// has been loaded which has happened once we are at the Decode phase.
wait(cpu.ControlMatrix.state === cpu.ControlMatrix.S_Decode && cpu.ControlMatrix.next_state === cpu.ControlMatrix.S_Idle);

// The instruction should be:
// HLT
if (cpu.ir !== 'h1000) begin
    $display("%d %m: ###ERROR### - Expected IR = h1000 Got: %h", $stime, cpu.ir);
end
