initial begin
    #10 OE_TB = 1'b0;        // Enable output
    IFlags_TB = 4'b0;        // All flags cleared

    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,1
    // -------------------------------------------------------
    FuncOp_TB = dut.Xor_OP;
    IA_TB = 8'h0;            // Load A
    IB_TB = 8'h0;            // Load B
    
    #1;
    $display("(%08b), (%08b), (%08b)", IA_TB, IB_TB, OY_TB);
    if (OFlags_TB != 4'b0001) begin
        $display("%d %m: ERROR - Expected zero flag set. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'b0) begin
        $display("%d %m: ERROR - Expected value 0. Got: (%0d).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,0
    // -------------------------------------------------------
    FuncOp_TB = dut.Xor_OP;
    IA_TB = 8'h01;           // Load A
    IB_TB = 8'h01;           // Load B

    #1;
    $display("(%08b), (%08b), (%08b)", IA_TB, IB_TB, OY_TB);
    if (OFlags_TB != 4'b0001) begin
        $display("%d %m: ERROR - Expected all flags cleared. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'h0) begin
        $display("%d %m: ERROR - Expected value of 1: Got (%0d).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,0
    // -------------------------------------------------------
    FuncOp_TB = dut.Xor_OP;
    IA_TB = 8'h00;           // Load A
    IB_TB = 8'h01;           // Load B

    #1;
    $display("(%08b), (%08b), (%08b)", IA_TB, IB_TB, OY_TB);
    if (OFlags_TB != 4'b0000) begin
        $display("%d %m: ERROR - Expected 0000. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'b00000001) begin
        $display("%d %m: ERROR - Expected value b00000001: Got (%0d).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,1,0,0
    // -------------------------------------------------------
    FuncOp_TB = dut.Xor_OP;
    IA_TB = 8'b01010101;           // Load A
    IB_TB = 8'b10101010;           // Load B

    #1;
    $display("(%08b), (%08b), (%08b)", IA_TB, IB_TB, OY_TB);
    if (OFlags_TB != 4'b0100) begin
        $display("%d %m: ERROR - Expected 0001. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'hFF) begin
        $display("%d %m: ERROR - Expected value of 0: Got (%0d).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 1,0,0,0
    // -------------------------------------------------------
    FuncOp_TB = dut.Xor_OP;
    IA_TB = 8'hF0;           // Load A
    IB_TB = 8'hF1;           // Load B

    #1;
    $display("(%08b), (%08b), (%08b)", IA_TB, IB_TB, OY_TB);
    $display("----------------------------------");
    // $display("out: %d", OY_TB);
    // $display("flags: %04b", OFlags_TB);
    if (OFlags_TB != 4'b1000) begin
        $display("%d %m: ERROR - Expected 0100. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'b00000001) begin
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