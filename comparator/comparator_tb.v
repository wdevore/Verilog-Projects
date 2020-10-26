// --------------------------------------------------------------------------
// Test bench
// --------------------------------------------------------------------------
module comparator_tb;
   parameter WIDTH = 2;   // data width
   integer i, j;          // for-loop variables
   reg [WIDTH-1:0] a, b;  // input values to compare
   wire lt, eq, gt;       // output comparison status

   initial begin
      $dumpfile("comparator_tb.vcd");  // waveforms file
      $dumpvars;  // save waveforms
      $display("%d %m: Starting testbench simulation...", $stime);
      $monitor("%d %m: MONITOR - a = %d, b = %d, lt = %d, eq = %d, gt = %d.", $stime, a, b, lt, eq, gt);
      #1;
      for (i = 0; i < 2 ** WIDTH; i = i + 1) begin
         for (j = 0; j < 2 ** WIDTH; j = j + 1) begin
            #1 a = i; b = j;
            #1;
            if (a < b && (!lt || eq || gt)) begin
               $display("%d %m: ERROR - Status flags lt (%d) eq (%d) gt (%d) are not correct for a (%d) less than b (%d).", $stime, lt, eq, gt, a, b);
               $finish;
            end
            if (a == b && (lt || !eq || gt)) begin
               $display("%d %m: ERROR - Status flags lt (%d) eq (%d) gt (%d) are not correct for a (%d) equal to b (%d).", $stime, lt, eq, gt, a, b);
               $finish;
            end
            if (a > b && (lt || eq || !gt)) begin
               $display("%d %m: ERROR - Status flags lt (%d) eq (%d) gt (%d) are not correct for a (%d) greater than b (%d). ", $stime, lt, eq, gt, a, b);
               $finish;
            end
         end
      end
      #1 $display("%d %m: Testbench simulation PASSED.", $stime);
      $finish;  // end simulation
   end

   // Instances
   comparator #(.WIDTH(WIDTH)) comparator_1(.a(a), .b(b), .lt(lt), .eq(eq), .gt(gt));

endmodule  // comparator_tb
