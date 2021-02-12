`default_nettype none

// --------------------------------------------------------------------------
// Multiplexer 4->1
// --------------------------------------------------------------------------

module Mux
#(
    parameter DataWidth = 8,
    parameter SelectSize = 1)
(
   input wire [SelectSize-1:0] Select,
   input wire [DataWidth-1:0] DIn0,  // Data input
   input wire [DataWidth-1:0] DIn1,  // Data input
   input wire [DataWidth-1:0] DIn2,  // Data input
   input wire [DataWidth-1:0] DIn3,  // Data input
   output wire [DataWidth-1:0] DOut  // Output
);

assign DOut = (Select == 4'b0000) ? DIn0 :
                (Select == 4'b0001) ? DIn1 :
                (Select == 4'b0010) ? DIn2 :
                (Select == 4'b0011) ? DIn3 :
                1'b0;

// Requires output defined as "reg"
// always @(Select, DIn0, DIn1, DIn2, DIn3) begin
//     case (Select[SelectSize-1:0])
//         4'b0000 : DOut  = DIn0;
//         4'b0001 : DOut  = DIn1;
//         4'b0010 : DOut  = DIn2;
//         4'b0011 : DOut  = DIn3;
//         default : DOut  = 1'b0;
//     endcase
// end

// Async one-hot
// assign output = (Select == 4'b0001) ? input_1 :
//                 (Select == 4'b0010) ? input_2 :
//                 (Select == 4'b0100) ? input_2 :
//                 (Select == 4'b1000) ? input_2 :
//                 1'b0;
endmodule
