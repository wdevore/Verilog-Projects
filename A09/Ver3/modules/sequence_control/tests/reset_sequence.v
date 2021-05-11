initial begin
    // ------------------------------------
    // Reset Vector sequence
    // As long as Reset is Active (aka low) then the processor
    // remains in the reset state.
    // ------------------------------------
    $display("%d: Beginning reset", $stime);
    @(posedge Clock_TB);
    Reset_TB = 1'b0;        // Enable reset

    // "state" should remain at S_Reset
    // "vector_state" should remain at S_Vector1
    @(negedge Clock_TB);
    #10  // Wait for data

    if (ControlMatrix.state !== ControlMatrix.S_Reset) begin
        $display("%d ERROR - S_Reset ControlMatrix.state (%h).", $stime, ControlMatrix.state);
        $finish;
    end

    if (ControlMatrix.vector_state !== ControlMatrix.S_Vector1) begin
        $display("%d ERROR - S_Vector1 ControlMatrix.vector_state (%h).", $stime, ControlMatrix.vector_state);
        $finish;
    end

    // Sustaining reset state
    $display("%d: Waiting one extra cycle", $stime);
    // We will wait just one more cycle
    @(posedge Clock_TB);
    @(negedge Clock_TB);
    #10  // Wait for data

    if (ControlMatrix.state !== ControlMatrix.S_Reset) begin
        $display("%d ERROR - S_Reset 2 ControlMatrix.state (%h).", $stime, ControlMatrix.state);
        $finish;
    end

    if (ControlMatrix.vector_state !== ControlMatrix.S_Vector1) begin
        $display("%d ERROR - S_Vector1 2 ControlMatrix.vector_state (%h).", $stime, ControlMatrix.vector_state);
        $finish;
    end

    // ------------------------------------
    // Exit reset state by deactivating reset and begin vector reset
    // ------------------------------------
    $display("%d: Exiting reset", $stime);
    @(posedge Clock_TB);
    Reset_TB = 1'b1;        // Disable reset

    // On the neg-edge we should have transitioned from vector1 to 2
    @(negedge Clock_TB);    // Now next vector_state should be S_Vector2
    #10  // Wait for data

    if (ControlMatrix.state !== ControlMatrix.S_Reset) begin
        $display("%d ERROR - S_Reset 3 ControlMatrix.state (%h).", $stime, ControlMatrix.state);
        $finish;
    end

    if (ControlMatrix.vector_state !== ControlMatrix.S_Vector2) begin
        $display("%d ERROR - S_Vector2 ControlMatrix.vector_state (%h).", $stime, ControlMatrix.vector_state);
        $finish;
    end

    // Vector state 3
    @(posedge Clock_TB);

    @(negedge Clock_TB); 
    #10  // Wait for data

    if (ControlMatrix.state !== ControlMatrix.S_Reset) begin
        $display("%d ERROR - S_Reset 4 ControlMatrix.state (%h).", $stime, ControlMatrix.state);
        $finish;
    end

    if (ControlMatrix.vector_state !== ControlMatrix.S_Vector3) begin
        $display("%d ERROR - S_Vector3 ControlMatrix.vector_state (%h).", $stime, ControlMatrix.vector_state);
        $finish;
    end

    // Finally Vector state 4
    @(posedge Clock_TB);

    @(negedge Clock_TB);
    #10  // Wait for data

    if (ControlMatrix.state !== ControlMatrix.S_Reset) begin
        $display("%d ERROR - S_Reset 5 ControlMatrix.state (%h).", $stime, ControlMatrix.state);
        $finish;
    end

    if (ControlMatrix.vector_state !== ControlMatrix.S_Vector4) begin
        $display("%d ERROR - S_Vector4 ControlMatrix.vector_state (%h).", $stime, ControlMatrix.vector_state);
        $finish;
    end

    // ------------------------------------
    // The cpu should now be ready
    // ------------------------------------
    @(posedge Clock_TB);

    @(negedge Clock_TB);
    #10  // Wait for data

    if (ControlMatrix.state !== ControlMatrix.S_Ready) begin
        $display("%d ERROR - S_Reset 6 ControlMatrix.state (%h).", $stime, ControlMatrix.state);
        $finish;
    end

    // Now we are ready to start the Fetch IR sequence
    if (ControlMatrix.next_state !== ControlMatrix.S_FetchPCtoMEM) begin
        $display("%d ERROR - S_FetchPCtoMEM ControlMatrix.next_state (%h).", $stime, ControlMatrix.next_state);
        $finish;
    end

    // ------------------------------------
    // Now that memory has been presented with the PC address
    // The matrix transitions to: moving the memory output
    // to the instruction register
    // ------------------------------------
    @(posedge Clock_TB);

    @(negedge Clock_TB);
    #10  // Wait for data

    if (ControlMatrix.state !== ControlMatrix.S_FetchPCtoMEM) begin
        $display("%d ERROR - S_Reset 7 ControlMatrix.state (%h).", $stime, ControlMatrix.state);
        $finish;
    end

    // Now we are ready to start the Fetch IR sequence
    if (ControlMatrix.next_state !== ControlMatrix.S_FetchMEMtoIR) begin
        $display("%d ERROR - S_FetchMEMtoIR ControlMatrix.next_state (%h).", $stime, ControlMatrix.next_state);
        $finish;
    end

    // ------------------------------------
    // Simulation duration
    // ------------------------------------
    #500 $display("%d %m: Testbench simulation FINISHED.", $stime);
    $finish;

end