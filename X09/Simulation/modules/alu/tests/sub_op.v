initial begin
    #10 OE_TB = 1'b0;        // Enable output
    IFlags_TB = 4'b0;        // All flags cleared

    // -------------------------------------------------------
    // Difference of two unsigned values
    //            V N C Z
    // Flags set: 0,0,0,1
    // -------------------------------------------------------
    FuncOp_TB = dut.Sub_OP;  // Select Add with no carry operation
    IA_TB = 8'h0;            // Load A
    IB_TB = 8'h0;            // Load B
    
    #1;
    if (OFlags_TB[dut.ZeroFlag] != 1'b1) begin
        $display("%d %m: ERROR - Expected Zero flag set. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'b0) begin
        $display("%d %m: ERROR - Expected Diff of 0. Got: (%0d).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,0
    // -------------------------------------------------------
    FuncOp_TB = dut.Sub_OP;  // Subtract without carry/borrow
    IA_TB = 8'h02;           // Load A
    IB_TB = 8'h01;           // Load B

    #1;
    if (OFlags_TB[dut.ZeroFlag] != 1'b0) begin
        $display("%d %m: ERROR - Expected Zero flag cleared. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'h01) begin
        $display("%d %m: ERROR - Expected value of 1: Got (%0d).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,0
    // -------------------------------------------------------
    FuncOp_TB = dut.Sub_OP;  // Subtract without carry/borrow
    IA_TB = 8'h00;           // Load A
    IB_TB = 8'h01;           // Load B

    #1;
    if (OFlags_TB != 4'b1110) begin
        $display("%d %m: ERROR - Expected 1110. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'hFF) begin
        $display("%d %m: ERROR - Expected value of 1: Got (%0d).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    //            V N C Z
    // Flags set: 0,0,0,0
    // -------------------------------------------------------
    FuncOp_TB = dut.Sub_OP;  // Subtract without carry/borrow
    IA_TB = 8'hFF;           // Load A
    IB_TB = 8'h0F;           // Load B

    #1;
    $display("----------------------------------");
    $display("out: %d", OY_TB);
    $display("flags: %04b", OFlags_TB);
    if (OFlags_TB != 4'b0100) begin
        $display("%d %m: ERROR - Expected 1110. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'hF0) begin
        $display("%d %m: ERROR - Expected value of 0xF0: Got (%0d).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    // Clearing carry results in subtracting 1
    // 0xFF - 0x01 w/o borrow = 0xFE
    //            V N C Z
    // Flags set: 0,0,0,0
    // -------------------------------------------------------
    FuncOp_TB = dut.Subc_OP; // Subtract with carry/borrow
    IFlags_TB = 4'b0000;     // Borrow cleared
    IA_TB = 8'hFF;           // Load A
    IB_TB = 8'h01;           // Load B

    #1;
    $display("----------------------------------");
    $display("%08b, %08b", IA_TB, (~IB_TB)+8'b00000001);
    $display("out: %d, %h, %08b", OY_TB, OY_TB, OY_TB);
    $display("flags: %04b", OFlags_TB);
    if (OFlags_TB != 4'b0100) begin
        $display("%d %m: ERROR - Expected 0100. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'hFE) begin
        $display("%d %m: ERROR - Expected value of 0xFD: Got (%0d).", $stime, OY_TB);
        $finish;
    end

    #10;
    // -------------------------------------------------------
    // Setting carry results in subtracting 2
    // 0xFF - 0x01 w borrow = 0xFD. Without borrow the answer
    // would be 0xFE.
    //            V N C Z
    // Flags set: 0,1,0,0
    // -------------------------------------------------------
    FuncOp_TB = dut.Subc_OP; // Subtract with carry/borrow
    IFlags_TB = 4'b0010;     // Borrow set
    IA_TB = 8'hFF;           // Load A
    IB_TB = 8'h01;           // Load B

    #1;
    $display("----------------------------------");
    $display("%08b, %08b", IA_TB, (~IB_TB)+8'b00000001);
    $display("out: %d, %h, %08b", OY_TB, OY_TB, OY_TB);
    $display("flags: %04b", OFlags_TB);
    if (OFlags_TB != 4'b0100) begin
        $display("%d %m: ERROR - Expected 0100. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'hFD) begin
        $display("%d %m: ERROR - Expected value of 0xFD: Got (%0d).", $stime, OY_TB);
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
    FuncOp_TB = dut.Subc_OP; // Subtract
    IFlags_TB = 4'b0000;     // Borrow cleared = without borrow
    IA_TB = 8'h23;           // Load A
    IB_TB = 8'hCF;           // Load B

    #1;
    $display("----------------------------------");
    $display("%08b, %08b", IA_TB, (~IB_TB)+8'b00000001);
    $display("out: %d, %h, %08b", OY_TB, OY_TB, OY_TB);
    $display("flags: %04b", OFlags_TB);

    if (OFlags_TB != 4'b0010) begin
        $display("%d %m: ERROR - Expected 1110. Got: (%04b).", $stime, OFlags_TB);
        $finish;
    end

    if (OY_TB != 8'h54) begin
        $display("%d %m: ERROR - Expected value of 0x54: Got (%0d).", $stime, OY_TB);
        $finish;
    end

    IFlags_TB = 4'b0;        // All flags cleared

    // ------------------------------------
    // Simulation duration
    // ------------------------------------
    #10 $display("%d %m: Testbench simulation PASSED.", $stime);
    $finish;
end