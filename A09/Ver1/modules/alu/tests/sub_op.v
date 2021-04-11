initial begin
    IFlags_TB = 4'b0000;        // All flags cleared
    FuncOp_TB = dut.Sub_OP;  // Select Add with no carry operation

    // -------------------------------------------------------
    // Difference of two unsigned values
    //            V N C Z
    // Flags set: 0,0,0,1
    // -------------------------------------------------------
    IA_TB = 'h0000;            // Load A
    IB_TB = 'h0000;            // Load B
    $display("%d Checking : %h, %h", $time, IA_TB, IB_TB);
    
    #1;
    $display("%d Flags : %04b", $time, OFlags_TB);
    if (OFlags_TB[dut.ZeroFlag] !== 1'b1) begin
        $display("%d %m: ERROR - Expected Zero flag set. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB !== 'h0000) begin
        $display("%d %m: ERROR - Expected Diff of 0. Got: (%0d = %04h).", $stime, OY_TB, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,0
    // -------------------------------------------------------
    IFlags_TB = 4'b0000;        // All flags cleared
    IA_TB = 'h0002;           // Load A
    IB_TB = 'h0001;           // Load B
    $display("%d Checking : %h, %h", $time, IA_TB, IB_TB);

    #1;
    $display("%d Flags : %04b", $time, OFlags_TB);
    if (OFlags_TB !== 4'b0000) begin
        $display("%d %m: ERROR - Expected Zero flag cleared. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB !== 'h0001) begin
        $display("%d %m: ERROR - Expected value of 1: Got (%0d = %04h).", $stime, OY_TB, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,0
    // -------------------------------------------------------
    IFlags_TB = 4'b0000;        // All flags cleared
    IA_TB = 'h0000;           // Load A
    IB_TB = 'h0001;           // Load B
    $display("%d Checking : %h, %h", $time, IA_TB, IB_TB);

    #1;
    $display("%d Flags : %04b", $time, OFlags_TB);
    if (OFlags_TB !== 4'b1110) begin
        $display("%d %m: ERROR - Expected 1110. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB !== 'hFFFF) begin
        $display("%d %m: ERROR - Expected value of 1: Got (%0d = %04h).", $stime, OY_TB, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,0
    // -------------------------------------------------------
    IFlags_TB = 4'b0000;        // All flags cleared
    IA_TB = 'hFFFF;           // Load A
    IB_TB = 'h00FF;           // Load B
    $display("%d Checking : %h, %h", $time, IA_TB, IB_TB);

    #1;
    $display("%d Flags : %04b", $time, OFlags_TB);
    if (OFlags_TB !== 4'b0100) begin
        $display("%d %m: ERROR - Expected 1110. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB !== 'hFF00) begin
        $display("%d %m: ERROR - Expected value of 0xF0: Got (%0d = %04h).", $stime, OY_TB, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    // Clearing carry results in subtracting 1
    // 0xFF - 0x01 w/o borrow = 0xFE
    //            V N C Z
    // Flags set: 0,0,0,0
    // -------------------------------------------------------
    IFlags_TB = 4'b0000;     // Borrow cleared
    IA_TB = 'hFFFF;           // Load A
    IB_TB = 'h0001;           // Load B
    $display("%d Checking : %h, %h", $time, IA_TB, IB_TB);

    #1;
    $display("%d Flags : %04b", $time, OFlags_TB);
    if (OFlags_TB !== 4'b0100) begin
        $display("%d %m: ERROR - Expected 0100. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB !== 'hFFFE) begin
        $display("%d %m: ERROR - Expected value of 0xFD: Got (%0d = %04h).", $stime, OY_TB, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    // 0xFF - 0x02 w borrow = 0xFD. Without borrow the answer
    // would be 0xFE.
    //            V N C Z
    // Flags set: 0,1,0,0
    // -------------------------------------------------------
    IA_TB = 'hFFFF;           // Load A
    IB_TB = 'h0002;           // Load B
    $display("%d Checking : %h, %h", $time, IA_TB, IB_TB);

    #1;
    $display("%d Flags : %04b", $time, OFlags_TB);
    if (OFlags_TB !== 4'b0100) begin
        $display("%d %m: ERROR - Expected 0100. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB !== 'hFFFD) begin
        $display("%d %m: ERROR - Expected value of 0xFD: Got (%0d = %04h).", $stime, OY_TB, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    // 0x23 – 0xCF = 0x54 w/o borrow  <- (~0xCF+1) = 31
    // Or CF as 2s complemented.
    // 0x23 + 0x31 = 0x54 + borrow generated (aka Carry flag set) = d84
    //            V N C Z
    // Flags set: 0,0,1,0
    // -------------------------------------------------------
    IFlags_TB = 4'b0000;     // Borrow cleared = without borrow
    IA_TB = 'h0023;           // Load A
    IB_TB = 'hFFCF;           // Load B
    $display("%d Checking : %h, %h", $time, IA_TB, IB_TB);

    #1;
    $display("%d Flags : %04b", $time, OFlags_TB);
    if (OFlags_TB !== 4'b0010) begin
        $display("%d %m: ERROR - Expected 1110. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB !== 'h0054) begin
        $display("%d %m: ERROR - Expected value of 0x54: Got (%0d = %04h).", $stime, OY_TB, OY_TB);
        $finish;
    end

    IFlags_TB = 4'b0;        // All flags cleared

    // ------------------------------------
    // Simulation duration
    // ------------------------------------
    #10 $display("%d %m: Testbench simulation PASSED.", $stime);
    $finish;
end