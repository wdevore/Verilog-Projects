initial begin
    #10 OE_TB = 1'b0;        // Enable output
    IFlags_TB = 4'b0;        // All flags cleared

    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,1
    // -------------------------------------------------------
    FuncOp_TB = dut.LslA_OP;
    IA_TB = 8'h0;            // Load A
    
    #1;
    $display("1) (%08b), (%08b)", IA_TB, OY_TB);
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
    // Flags set: 0,0,1,1
    // -------------------------------------------------------
    FuncOp_TB = dut.LslA_OP;
    IA_TB = 8'b10000000;           // Load A

    #1;
    $display("2) (%08b), (%08b)", IA_TB, OY_TB);
    if (OFlags_TB != 4'b1011) begin
        $display("%d %m: ERROR - Expected 0000. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'b00000000) begin
        $display("%d %m: ERROR - Expected value of 0: Got (%08b).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,1,1,0
    // -------------------------------------------------------
    FuncOp_TB = dut.LslA_OP;
    IA_TB = 8'b11000000;           // Load A

    #1;
    $display("3) (%08b), (%08b)", IA_TB, OY_TB);
    if (OFlags_TB != 4'b0110) begin
        $display("%d %m: ERROR - Expected 0011. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'b10000000) begin
        $display("%d %m: ERROR - Expected value b1000000: Got (%08b).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 1,0,1,1
    // -------------------------------------------------------
    FuncOp_TB = dut.LslA_OP;
    IA_TB = 8'b10000000;           // Load A

    #1;
    $display("4) (%08b), (%08b)", IA_TB, OY_TB);
    if (OFlags_TB != 4'b1011) begin
        $display("%d %m: ERROR - Expected b1011. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'b00000000) begin
        $display("%d %m: ERROR - Expected value b00000000: Got (%08b).", $stime, OY_TB);
        $finish;
    end


    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,0
    // -------------------------------------------------------
    FuncOp_TB = dut.LslA_OP;
    IA_TB = 8'b00000001;           // Load A

    #1;
    $display("5) (%08b), (%08b)", IA_TB, OY_TB);
    if (OFlags_TB != 4'b0000) begin
        $display("%d %m: ERROR - Expected 1000. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'b00000010) begin
        $display("%d %m: ERROR - Expected value b00000010: Got (%08b).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,0
    // -------------------------------------------------------
    FuncOp_TB = dut.LslA_OP;
    IA_TB = OY_TB;           // Load A

    #1;
    $display("6) (%08b), (%08b)", IA_TB, OY_TB);
    if (OFlags_TB != 4'b0000) begin
        $display("%d %m: ERROR - Expected 0000. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'b00000100) begin
        $display("%d %m: ERROR - Expected value b00000100: Got (%08b).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,0
    // -------------------------------------------------------
    FuncOp_TB = dut.LslA_OP;
    IA_TB = OY_TB;           // Load A

    #1;
    $display("7) (%08b), (%08b)", IA_TB, OY_TB);
    if (OFlags_TB != 4'b0000) begin
        $display("%d %m: ERROR - Expected 0000. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'b00001000) begin
        $display("%d %m: ERROR - Expected value b00001000: Got (%08b).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,0
    // -------------------------------------------------------
    FuncOp_TB = dut.LslA_OP;
    IA_TB = OY_TB;           // Load A

    #1;
    $display("8) (%08b), (%08b)", IA_TB, OY_TB);
    if (OFlags_TB != 4'b0000) begin
        $display("%d %m: ERROR - Expected 0000. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'b00010000) begin
        $display("%d %m: ERROR - Expected value b00010000: Got (%08b).", $stime, OY_TB);
        $finish;
    end

    IFlags_TB = 4'b0;        // All flags cleared

    // ------------------------------------
    // Simulation duration
    // ------------------------------------
    #10 $display("%d %m: Testbench simulation PASSED.", $stime);
    $finish;
end