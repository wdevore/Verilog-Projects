`default_nettype none

// A09 CPU targeted for an FPGA

// `undef SIMULATE

`include "../../components/cpu/cpu.v"

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
    output pin12,       // Ready
    output pin13,       // Halt
    output pin14_sdo,   // IR Load
    output pin15_sdi,   // Mem_En
    output pin16_sck,   // Output_Ld
    output pin17_ss,    // IR[15]
    output pin18,       // IR[14]
    output pin19,       // IR[13]
    output pin20,       // IR[12]
    input pin22,        // Clock
    input pin23,        // Reset
    output pin24        // ClockCyl
);

localparam AddrWidth = 8;      // 8bit Address width
localparam DataWidth = 16;     // 16bit Data width
localparam WordSize = 1;       // Instructions a 1 = 2bytes in size
       
wire [DataWidth-1:0] OutReg;
reg ready;
reg halt;
reg ir_ld;
reg mem_en;
reg output_ld;
reg [DataWidth-1:0] ir;
 
// ----------------------------------------------------------
// Clock unused
// ----------------------------------------------------------
reg [22:0] clk_1hz_counter = 23'b0;  // Hz clock generation counter
reg        clk_cyc = 1'b0;           // Hz clock
localparam FREQUENCY = 23'd1;  // 1Hz
 
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

CPU #(
    .DataWidth(DataWidth),
    .AddrWidth(AddrWidth),
    .WordSize(WordSize)) cpu
(
    .Clk(pin22),
    .Reset(pin23),
    .Ready(ready),
    .Halt(halt),
    .IR_Ld(ir_ld),
    .Mem_En(mem_en),
    .Output_Ld(output_ld),
    .IR_Out(ir),
    .OutReg(OutReg)
);

// ----------------------------------------------------------
// IO routing
// ----------------------------------------------------------
// Route Output wires to pins
assign
    pin4 = OutReg[0],
    pin5 = OutReg[1],
    pin6 = OutReg[2],
    pin7 = OutReg[3],
    pin8 = OutReg[4],
    pin9 = OutReg[5],
    pin10 = OutReg[6],
    pin11 = OutReg[7];
  
assign pin12 = ready;
assign pin13 = halt;
assign pin14_sdo = ir_ld;
assign pin15_sdi = mem_en;
assign pin16_sck = output_ld;

assign pin17_ss = ir[15],
       pin18    = ir[14],
       pin19    = ir[13],
       pin20    = ir[12];

assign pin24 = clk_cyc;

// TinyFPGA standard pull pins defaults
assign
    pin1_usb_dp = 1'b0,
    pin2_usb_dn = 1'b0;

endmodule  // top