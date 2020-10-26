// --------------------------------------------------------------------------
// Sync switch debouncer
// --------------------------------------------------------------------------
module digital_filter(
   input clk,
   input D,
   output reg Q);

   reg[3:0] dfilter4;
   localparam valid0 = 4'b0000, valid1 = 4'b1111;

   always @(posedge clk)
   begin
      dfilter4 <= {dfilter4[2:0], D};
      case(dfilter4)
         valid0: Q <= 0;
         valid1: Q <= 1;
         default: Q <= Q; // hold value
      endcase
   end
endmodule