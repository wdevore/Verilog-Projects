`default_nettype none

`undef SIMULATE

`include "../../modules/program_counter/pc.v"
`include "../../modules/memory/memory.v"
`include "../../modules/mux/mux.v"

module top
(
    // See pins.pcf for pin Definitions
    output pin1_usb_dp,     // USB pull-up enable, set low to disable
    output pin2_usb_dn,     // Both 1-2 are assigned Zero
    input  pin3_clk_16mhz,   // 16 MHz on-board clock
    // pins 4-11 is the lower 8bits of the Output register
    output pin4,        // LSB
    output pin5,
    output pin6,
    output pin7,
    output pin8,
    output pin9,
    output pin10,   
    output pin11,
    output pin12,
    output pin13,
    output pin14_sdo,
    output pin15_sdi,   // Upper bit
    output pin16_sck,
    output pin17_ss,
    input pin18,        // PC Inc (Active low)
    input pin19,        // Select 'b0 
    input pin20,        // Select 'b1
    input pin21,        // Manual clock
    input pin22,        // Reset 
    output pin23,       // 
    output pin24        // Clock out
);

localparam AddrWidth = 8;      // 8bit Address width
localparam DataWidth = 16;     // 16bit Data width
localparam WordSize = 1;       // Instructions a 1 = 2bytes in size

wire [DataWidth-1:0] OutReg;

reg PC_ld;
reg [DataWidth-1:0] PC_in = 16'b0;
wire [DataWidth-1:0] PC_out;
wire [DataWidth-1:0] mux_addr_to_mem_addr;
wire [DataWidth-1:0] mem_to_out;

// ----------------------------------------------------------
// Clock unused
// ----------------------------------------------------------
reg [22:0] clk_1hz_counter = 23'b0;  // Hz clock generation counter
reg        clk_cyc = 1'b0;           // Hz clock
localparam FREQUENCY = 23'd10;  // 10Hz

always @* begin
    PC_ld <= 1'b1;
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
    .Clk(pin21),
    .Reset(pin22),      // Active low
    .LD(PC_ld),
    .Inc(pin18),       // Automatically inc PC
    .DIn(PC_in),
    .DOut(PC_out)
);

Mux #(
    .DataWidth(DataWidth),
    .SelectSize(2)) MUX_ADDR
(
    .Select({pin20, pin19}),
    .DIn0(PC_out),          // PC source
    .DIn1(16'h0002),
    .DIn2(16'h0001),
    .DIn3(16'h0004),
    .DOut(mux_addr_to_mem_addr)
);

Memory #(.AddrWidth(AddrWidth)) rom (
    .Clk(clk_cyc),
    .DIn({DataWidth{1'b0}}),              // Register file src 1
    .Address(mux_addr_to_mem_addr[AddrWidth-1:0]),
    .Write_EN(1'b1),        // Enable Read
    .Mem_En(1'b0),          // Enable memory
    .DOut(mem_to_out)
);

// We can't load the ROM from here. It's done from memory.v
// initial $readmemh (`ROM, rom.mem, 0, 6);
// TODO #############
// Need to add 3us delay before accessing the ROM.
// This is an issue with the Lattice FPGA, perhaps to load the ROM from
// the configuration bitstream.

// ----------------------------------------------------------
// IO routing
// ----------------------------------------------------------
// Route Output wires to pins
assign
    pin4  = mem_to_out[0],
    pin5  = mem_to_out[1],
    pin6  = mem_to_out[2],
    pin7  = mem_to_out[3],
    pin8  = mem_to_out[4],
    pin9  = mem_to_out[5],
    pin10 = mem_to_out[6],
    pin11 = mem_to_out[7];

assign
    pin12     = mem_to_out[8],
    pin13     = mem_to_out[9],
    pin14_sdo = mem_to_out[10],
    pin15_sdi = mem_to_out[11],
    pin16_sck = 1'b0,
    pin17_ss = 1'b0;

assign pin23 = 1'b0;

assign pin24 = clk_cyc;

// TinyFPGA standard pull pins defaults
assign
    pin1_usb_dp = 1'b0,
    pin2_usb_dn = 1'b0;

endmodule  // top