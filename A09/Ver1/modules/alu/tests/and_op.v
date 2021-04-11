initial begin
    IFlags_TB = 4'b0000;        // All flags cleared
    FuncOp_TB = dut.And_OP;

    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,1
    // -------------------------------------------------------
    IA_TB = 'h0000;            // Load A
    IB_TB = 'h0000;            // Load B
    $display("%d Checking : %h, %h", $time, IA_TB, IB_TB);
    
    #1;
    if (OFlags_TB !== 4'b0001) begin
        $display("%d %m: ERROR - Expected zero flag set. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB !== 'b0) begin
        $display("%d %m: ERROR - Expected value 0. Got: (%0d).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,0
    // -------------------------------------------------------
    IA_TB = 'h0001;           // Load A
    IB_TB = 'h0001;           // Load B
    $display("%d Checking : %h, %h", $time, IA_TB, IB_TB);

    #1;
    if (OFlags_TB !== 4'b0000) begin
        $display("%d %m: ERROR - Expected all flags cleared. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB !== 'h0001) begin
        $display("%d %m: ERROR - Expected value of 1: Got (%0d).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,1
    // -------------------------------------------------------
    IA_TB = 'h0000;           // Load A
    IB_TB = 'h0001;           // Load B
    $display("%d Checking : %h, %h", $time, IA_TB, IB_TB);

    #1;
    if (OFlags_TB !== 4'b0001) begin
        $display("%d %m: ERROR - Expected 0001. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB !== 'h0) begin
        $display("%d %m: ERROR - Expected value of 0: Got (%0d).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,1
    // -------------------------------------------------------
    IA_TB = 'b01010101;           // Load A
    IB_TB = 'b10101010;           // Load B
    $display("%d Checking : %h, %h", $time, IA_TB, IB_TB);

    #1;
    if (OFlags_TB !== 4'b0001) begin
        $display("%d %m: ERROR - Expected 0001. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB !== 'h0) begin
        $display("%d %m: ERROR - Expected value of 0: Got (%0d).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,1,0,0
    // -------------------------------------------------------
    IA_TB = 'hFFF0;           // Load A
    IB_TB = 'hFFF1;           // Load B
    $display("%d Checking : %h, %h", $time, IA_TB, IB_TB);

    #1;
    if (OFlags_TB !== 4'b0100) begin
        $display("%d %m: ERROR - Expected 0100. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB !== 'hFFF0) begin
        $display("%d %m: ERROR - Expected value of 0xF0: Got (%0d).", $stime, OY_TB);
        $finish;
    end


    IFlags_TB = 4'b0;        // All flags cleared

    // ------------------------------------
    // Simulation duration
    // ------------------------------------
    #10 $display("%d %m: Testbench simulation PASSED.", $stime);
    $finish;
end