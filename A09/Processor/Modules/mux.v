`default_nettype none

// Multiplexers

// ~~~~~~~~~~~~~~~~~~~~~~~~~~
// Mux 2 input
// ~~~~~~~~~~~~~~~~~~~~~~~~~~
module Mux2
#(
    parameter DATA_WIDTH = 16
)
(
   input wire select_i,
   input wire [DATA_WIDTH-1:0] data0_i,  // Data input
   input wire [DATA_WIDTH-1:0] data1_i,  // Data input
   output wire [DATA_WIDTH-1:0] data_o  // Output
);

assign data_o = (select_i == 1'b0) ? data0_i : data1_i;

endmodule

// ~~~~~~~~~~~~~~~~~~~~~~~~~~
// Mux 4
// ~~~~~~~~~~~~~~~~~~~~~~~~~~
module Mux4
#(
    parameter DATA_WIDTH = 16,
    parameter SELECT_SIZE = 2
)
(
   input wire [SELECT_SIZE-1:0] select_i,
   input wire [DATA_WIDTH-1:0] data0_i,  // Data input
   input wire [DATA_WIDTH-1:0] data1_i,  // Data input
   input wire [DATA_WIDTH-1:0] data2_i,  // Data input
   input wire [DATA_WIDTH-1:0] data3_i,  // Data input
   output wire [DATA_WIDTH-1:0] data_o  // Output
);

assign data_o = (select_i == 2'b00) ? data0_i :
                (select_i == 2'b01) ? data1_i :
                (select_i == 2'b10) ? data2_i :
                (select_i == 2'b11) ? data3_i :
                {DATA_WIDTH{1'b0}};
endmodule

// ~~~~~~~~~~~~~~~~~~~~~~~~~~
// Mux 8
// ~~~~~~~~~~~~~~~~~~~~~~~~~~
module Mux8
#(
    parameter DATA_WIDTH = 16,
    parameter SELECT_SIZE = 3
)
(
   input wire [SELECT_SIZE-1:0] select_i,
   input wire [DATA_WIDTH-1:0] data0_i,  // Data input
   input wire [DATA_WIDTH-1:0] data1_i,  // Data input
   input wire [DATA_WIDTH-1:0] data2_i,  // Data input
   input wire [DATA_WIDTH-1:0] data3_i,  // Data input
   input wire [DATA_WIDTH-1:0] data4_i,  // Data input
   input wire [DATA_WIDTH-1:0] data5_i,  // Data input
   input wire [DATA_WIDTH-1:0] data6_i,  // Data input
   input wire [DATA_WIDTH-1:0] data7_i,  // Data input
   output wire [DATA_WIDTH-1:0] data_o  // Output
);

assign data_o = (select_i == 3'b000) ? data0_i :
                (select_i == 3'b001) ? data1_i :
                (select_i == 3'b010) ? data2_i :
                (select_i == 3'b011) ? data3_i :
                (select_i == 3'b100) ? data4_i :
                (select_i == 3'b101) ? data5_i :
                (select_i == 3'b110) ? data6_i :
                (select_i == 3'b111) ? data7_i :
                {DATA_WIDTH{1'b0}};
endmodule
