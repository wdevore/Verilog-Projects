initial begin
    @(posedge Clock_TB);
    Reset_TB = 1'b1;        // Disable reset

    @(negedge Clock_TB);
    #10  // Wait for data

    // Vector state 3
    @(posedge Clock_TB);
    @(negedge Clock_TB); 
    #10  // Wait for data

    // Finally Vector state 4
    @(posedge Clock_TB);
    @(negedge Clock_TB);
    #10  // Wait for data

    // ------------------------------------
    // The cpu should now be ready
    // ------------------------------------
    @(posedge Clock_TB);
    @(negedge Clock_TB);
    #10  // Wait for data

    // ------------------------------------
    // Now that memory has been presented with the PC address
    // The matrix transitions to: moving the memory output
    // to the instruction register
    // ------------------------------------
    @(posedge Clock_TB);
    @(negedge Clock_TB);
    #10  // Wait for data

    // ------------------------------------
    // Mem to IR
    // ------------------------------------
    @(posedge Clock_TB);
    IR_TB = 16'h20D1;    // ADD R3, R2, R1

    @(negedge Clock_TB);
    #10  // Wait for data

    if (ControlMatrix.state !== ControlMatrix.S_FetchMEMtoIR) begin
        $display("%d ERROR - S_FetchMEMtoIR 8 ControlMatrix.state (%h).", $stime, ControlMatrix.state);
        $finish;
    end

    // Decoding
    if (ControlMatrix.next_state !== ControlMatrix.S_Decode) begin
        $display("%d ERROR - S_Decode ControlMatrix.next_state (%h).", $stime, ControlMatrix.next_state);
        $finish;
    end

    // ------------------------------------
    // Decode instruction using injection.
    // ------------------------------------
    @(posedge Clock_TB);
    @(negedge Clock_TB);
    #10  // Wait for data

    if (ControlMatrix.state !== ControlMatrix.S_Decode) begin
        $display("%d ERROR - S_Decode 9 ControlMatrix.state (%h).", $stime, ControlMatrix.state);
        $finish;
    end

    // Decoding
    if (ControlMatrix.next_state !== ControlMatrix.S_ALU_Execute) begin
        $display("%d ERROR - S_ALU_Execute ControlMatrix.next_state (%h).", $stime, ControlMatrix.next_state);
        $finish;
    end

    // ------------------------------------
    // ALU 4th cycle
    // ------------------------------------
    @(posedge Clock_TB);
    @(negedge Clock_TB);
    #10  // Wait for data

    if (ControlMatrix.state !== ControlMatrix.S_ALU_Execute) begin
        $display("%d ERROR - S_ALU_Execute 10 ControlMatrix.state (%h).", $stime, ControlMatrix.state);
        $finish;
    end

    // Rinse and repeat
    if (ControlMatrix.next_state !== ControlMatrix.S_FetchPCtoMEM) begin
        $display("%d ERROR - S_FetchPCtoMEM ControlMatrix.next_state (%h).", $stime, ControlMatrix.next_state);
        $finish;
    end

    // ------------------------------------
    // Simulation duration
    // ------------------------------------
    #500 $display("%d %m: Testbench simulation FINISHED.", $stime);
    $finish;

end