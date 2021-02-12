`default_nettype none

// --------------------------------------------------------------------------
// Standard combinational Demux
// A09 will only use a 1bit Demux for selecting a register within the
// Register-File.
// --------------------------------------------------------------------------

module Demux
#(
    parameter DataWidth = 8)
(
   input wire [2:0] Select,        // 3bit Select code
   input wire Enable,
   input wire [DataWidth-1:0] DIn,  // Data input
   output wire [DataWidth-1:0] O0,  // Output
   output wire [DataWidth-1:0] O1,  // Output
   output wire [DataWidth-1:0] O2,  // Output
   output wire [DataWidth-1:0] O3,  // Output
   output wire [DataWidth-1:0] O4,  // Output
   output wire [DataWidth-1:0] O5,  // Output
   output wire [DataWidth-1:0] O6,  // Output
   output wire [DataWidth-1:0] O7   // Output
);
    assign O0 = (~Select[2] & ~Select[1] & ~Select[0]) & Enable ? DIn : {DataWidth{1'b1}};
    assign O1 = (~Select[2] & ~Select[1] & Select[0]) & Enable ? DIn : {DataWidth{1'b1}};
    assign O2 = (~Select[2] & Select[1]  & ~Select[0]) & Enable ? DIn : {DataWidth{1'b1}};
    assign O3 = (~Select[2] & Select[1]  & Select[0]) & Enable ? DIn : {DataWidth{1'b1}};
    assign O4 = (Select[2]  & ~Select[1] & ~Select[0]) & Enable ? DIn : {DataWidth{1'b1}};
    assign O5 = (Select[2]  & ~Select[1] & Select[0]) & Enable ? DIn : {DataWidth{1'b1}};
    assign O6 = (Select[2]  & Select[1]  & ~Select[0]) & Enable ? DIn : {DataWidth{1'b1}};
    assign O7 = (Select[2]  & Select[1]  & Select[0]) & Enable ? DIn : {DataWidth{1'b1}};
endmodule

// An always block example
// module Demux(
//    input wire [1:0] Select,        // 3bit Select code
//    input wire DIn, // Data input
//    output reg Oa,  // Output
//    output reg Ob  // Output
// );
//     always @(Select, DIn) begin
//         case (Select)
//         2'b00 : begin
//             Oa = DIn;
//             Ob = 0;
//         end
//         2'b01 : begin
//             Oa = 0;
//             Ob = DIn;
//         end
//         default: begin
//             Oa = 0;
//             Ob = 0;               
//         end
//         endcase
//     end
// endmodule
