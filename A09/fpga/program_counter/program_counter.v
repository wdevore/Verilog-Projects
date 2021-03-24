`default_nettype none

// A09 CPU targeted for an FPGA

`undef SIMULATE

`include "../../modules/program_counter/pc.v"

module top
(
    // See pins.pcf for pin Definitions
    output pin1_usb_dp,     // USB pull-up enable, set low to disable
    output pin2_usb_dn,     // Both 1-2 are assigned Zero
    input  pin3_clk_16mhz,   // 16 MHz on-board clock -- UNUSED
    // pins 4-11 is the lower 8bits of the Output register
    output pin4,        // LSB
    output pin5,
    output pin6,
    output pin7,
    output pin8,
    output pin9,
    output pin10,   
    output pin11,       // MSB
    output pin12,
    output pin13,
    output pin14_sdo,
    output pin15_sdi,
    output pin16_sck,
    output pin17_ss,
    output pin18,
    output pin19,
    output pin20,
    input pin21,
    input pin22,
    output pin23,       // Reset
    output pin24        // Clock out
);

localparam AddrWidth = 8;      // 8bit Address width
localparam DataWidth = 16;     // 16bit Data width
localparam WordSize = 1;       // Instructions a 1 = 2bytes in size

wire [DataWidth-1:0] OutReg;

reg PC_rst;
reg PC_ld;
reg PC_inc;
reg [DataWidth-1:0] PC_in = 16'b0;
wire [DataWidth-1:0] PC_out;

// ----------------------------------------------------------
// Clock unused
// ----------------------------------------------------------
reg [22:0] clk_1hz_counter = 23'b0;  // Hz clock generation counter
reg        clk_cyc = 1'b0;           // Hz clock
localparam FREQUENCY = 23'd10;  // 10Hz

// or AndO(pin23, pin21, pin22);

always @* begin
    PC_rst <= 1'b1;
    PC_ld <= 1'b1;
    PC_inc <= 1'b0;
end

// Clock divder and generator
always @(posedge pin3_clk_16mhz) begin
    if (clk_1hz_counter < 23'd7_999_999)
        clk_1hz_counter <= clk_1hz_counter + FREQUENCY;
    else begin
        clk_1hz_counter <= 23'b0;
        clk_cyc <= ~clk_cyc;
    end
end
 
// ----------------------------------------------------------
// Modules
// ----------------------------------------------------------

ProgramCounter #(
    .DataWidth(DataWidth),
    .WordByteSize(WordSize)) PC
(
    .Clk(clk_cyc),
    .Reset(pin21),      // Active low
    .LD(PC_ld),
    .Inc(PC_inc),
    .DIn(PC_in),
    .DOut(PC_out)
);

// ----------------------------------------------------------
// IO routing
// ----------------------------------------------------------
// Route Output wires to pins
assign
    pin4 = PC_out[0],
    pin5 = PC_out[1],
    pin6 = PC_out[2],
    pin7 = PC_out[3],
    pin8 = PC_out[4],
    pin9 = PC_out[5],
    pin10 = PC_out[6],
    pin11 = PC_out[7];

assign
    pin12 = PC_out[8],
    pin13 = PC_out[9],
    pin14_sdo = PC_out[10],
    pin15_sdi = PC_out[11],
    pin16_sck = 1'b0,
    pin17_ss = 1'b0,
    pin18 = 1'b0,
    pin19 = 1'b0,
    pin20 = 1'b0;
    // pin21 = 1'b0,
    // pin22 = 1'b0;

assign pin23 = 1'b0;

// assign PC_rst = pin21;
assign pin24 = clk_cyc;

// TinyFPGA standard pull pins defaults
assign
    pin1_usb_dp = 1'b0,
    pin2_usb_dn = 1'b0;

endmodule  // top