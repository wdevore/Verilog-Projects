`default_nettype none

// A09 CPU targeted for an FPGA

`undef SIMULATE

`include "../../modules/alu/alu.v"
`include "../../modules/register/register.v"

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
    output pin12,       // ALU flag bit 0  Z
    output pin13,       // ALU flag bit 1  C
    output pin14_sdo,   // ALU flag bit 2  N
    output pin15_sdi,   // ALU flag bit 3  V
    input pin17_ss,     // ALU load
    input pin18,        // ALU op bit 0
    input pin19,        // ALU op bit 1
    input pin20,        // ALU op bit 2
    input pin21,        // ALU op bit 3
    input pin22,        // Clock
    input pin23,        // Reset
    output pin24        // ClockCyl
);

localparam AddrWidth = 8;      // 8bit Address width
localparam DataWidth = 16;     // 16bit Data width
localparam WordSize = 1;       // Instructions a 1 = 2bytes in size
localparam FlagSize = 4;       //

wire [DataWidth-1:0] alu_to_out;
wire [DataWidth-1:0] alu_res;
wire [FlagSize-1:0] alu_to_flags;
wire [FlagSize-1:0] alu_flags;

reg [DataWidth-1:0] source1;
reg [DataWidth-1:0] source2;
reg [DataWidth-1:0] flags;


// ----------------------------------------------------------
// Clock unused
// ----------------------------------------------------------
reg [22:0] clk_1hz_counter = 23'b0;  // Hz clock generation counter
reg        clk_cyc = 1'b0;           // Hz clock
localparam FREQUENCY = 23'd2;  // 2Hz
  
// Clock divder and generator
always @(posedge pin3_clk_16mhz) begin
    if (clk_1hz_counter < 23'd7_999_999)
        clk_1hz_counter <= clk_1hz_counter + FREQUENCY;
    else begin
        clk_1hz_counter <= 23'b0;
        clk_cyc <= ~clk_cyc;
    end
end

always @* begin
    source1 = DataWidth'b0000000000010010;  // 18 = 0x12
    source2 = DataWidth'b0000000000010101;  // 21 = 0x15
    // Add = 0000000000100111 = 39
    // Sub = 1111111111111101 = -3
    // AND = 0000000000010000
    // OR  = 0000000000010111
    // XOR = 0000000000000111
end

// ----------------------------------------------------------
// Modules
// ----------------------------------------------------------

ALU #(.DataWidth(DataWidth)) Alu(
    .IFlags({FlagSize{1'b0}}),    // Not used yet
    .A(source1),
    .B(source2),
    .FuncOp({pin21,pin20,pin19,pin18}),
    .Y(alu_to_out),
    .OFlags(alu_to_flags)
);

Register #(.DataWidth(4)) ALU_Flags
(
    .Clk(pin22),
    .Reset(pin23),        // Typically reset after Branch instructions
    .LD(pin17_ss),
    .DIn(alu_to_flags),
    .DOut(alu_flags)
);

Register #(.DataWidth(DataWidth)) ALUResults
(
    .Clk(pin22),
    .Reset(pin23),
    .LD(pin17_ss),
    .DIn(alu_to_out),       // ALU output
    .DOut(alu_res)
);

// ----------------------------------------------------------
// IO routing
// ----------------------------------------------------------
// Route Output wires to pins
assign
    pin4  = alu_res[0],
    pin5  = alu_res[1],
    pin6  = alu_res[2],
    pin7  = alu_res[3],
    pin8  = alu_res[4],
    pin9  = alu_res[5],
    pin10 = alu_res[6],
    pin11 = alu_res[7];

assign
    pin12     = alu_flags[0],
    pin13     = alu_flags[1],
    pin14_sdo = alu_flags[2],
    pin15_sdi = alu_flags[3];

assign pin24 = clk_cyc;

// TinyFPGA standard pull pins defaults
assign
    pin1_usb_dp = 1'b0,
    pin2_usb_dn = 1'b0;

endmodule  // top