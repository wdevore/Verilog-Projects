`default_nettype none

// --------------------------------------------------------------------------
// Multiplexers
// --------------------------------------------------------------------------

module Mux2
#(
    parameter DataWidth = 16,
    parameter SelectSize = 1
    )
(
   input wire [SelectSize-1:0] Select,
   input wire [DataWidth-1:0] DIn0,  // Data input
   input wire [DataWidth-1:0] DIn1,  // Data input
   output wire [DataWidth-1:0] DOut  // Output
);

assign DOut = (Select == 2'b00) ? DIn0 :
              (Select == 2'b01) ? DIn1 :
              1'b0;
endmodule

module Mux4
#(
    parameter DataWidth = 16,
    parameter SelectSize = 2
    )
(
   input wire [SelectSize-1:0] Select,
   input wire [DataWidth-1:0] DIn0,  // Data input
   input wire [DataWidth-1:0] DIn1,  // Data input
   input wire [DataWidth-1:0] DIn2,  // Data input
   input wire [DataWidth-1:0] DIn3,  // Data input
   output wire [DataWidth-1:0] DOut  // Output
);

assign DOut = (Select == 2'b00) ? DIn0 :
              (Select == 2'b01) ? DIn1 :
              (Select == 2'b10) ? DIn2 :
              (Select == 2'b11) ? DIn3 :
              1'b0;
endmodule

module Mux8
#(
    parameter DataWidth = 16,
    parameter SelectSize = 3
    )
(
   input wire [SelectSize-1:0] Select,
   input wire [DataWidth-1:0] DIn0,  // Data input
   input wire [DataWidth-1:0] DIn1,  // Data input
   input wire [DataWidth-1:0] DIn2,  // Data input
   input wire [DataWidth-1:0] DIn3,  // Data input
   input wire [DataWidth-1:0] DIn4,  // Data input
   input wire [DataWidth-1:0] DIn5,  // Data input
   input wire [DataWidth-1:0] DIn6,  // Data input
   input wire [DataWidth-1:0] DIn7,  // Data input
   output wire [DataWidth-1:0] DOut  // Output
);

assign DOut = (Select == 3'b000) ? DIn0 :
              (Select == 3'b001) ? DIn1 :
              (Select == 3'b010) ? DIn2 :
              (Select == 3'b011) ? DIn3 :
              (Select == 3'b100) ? DIn4 :
              (Select == 3'b101) ? DIn5 :
              (Select == 3'b110) ? DIn6 :
              (Select == 3'b111) ? DIn7 :
              1'b0;
endmodule
