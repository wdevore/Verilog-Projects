// --------------------------------------------------------------------------
// Basic flip flop
// --------------------------------------------------------------------------
module clock
#(
    parameter Default = 0
)
(
   input D,
   input C,
   output Q,
   output notQ
   );
   reg state;

   assign Q = state;
   assign notQ = ~state;

   always @ (posedge C) begin
      state <= D;
   end

   // Simulation
   initial begin
      state = Default;
   end
endmodule