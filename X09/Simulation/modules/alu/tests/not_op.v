initial begin
    #10 OE_TB = 1'b0;        // Enable output
    IFlags_TB = 4'b0;        // All flags cleared

    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,1
    // -------------------------------------------------------
    FuncOp_TB = dut.Not_OP;
    IA_TB = 8'hFF;            // Load A
    
    #1;
    $display("(%08b), (%08b)", IA_TB, OY_TB);
    if (OFlags_TB != 4'b0001) begin
        $display("%d %m: ERROR - Expected zero flag set. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'b0) begin
        $display("%d %m: ERROR - Expected value 0. Got: (%08b).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,0
    // -------------------------------------------------------
    FuncOp_TB = dut.Not_OP;
    IA_TB = 8'h00;           // Load A

    #1;
    $display("(%08b), (%08b)", IA_TB, OY_TB);
    if (OFlags_TB != 4'b0100) begin
        $display("%d %m: ERROR - Expected 0100. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'hFF) begin
        $display("%d %m: ERROR - Expected value of 1: Got (%08b).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,1,0,0
    // -------------------------------------------------------
    FuncOp_TB = dut.Not_OP;
    IA_TB = 8'b01010101;           // Load A

    #1;
    $display("(%08b), (%08b)", IA_TB, OY_TB);
    if (OFlags_TB != 4'b0100) begin
        $display("%d %m: ERROR - Expected 0100. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'b10101010) begin
        $display("%d %m: ERROR - Expected value h10101010: Got (%08b).", $stime, OY_TB);
        $finish;
    end


    IFlags_TB = 4'b0;        // All flags cleared

    // ------------------------------------
    // Simulation duration
    // ------------------------------------
    #10 $display("%d %m: Testbench simulation PASSED.", $stime);
    $finish;
end