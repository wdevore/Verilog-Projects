`default_nettype none

// 4bit up counter - top.v
// This is expects a pcf specific to the tinyFPGA-B2 board

module top (
    // See pins.pcf for pin Definitions
    output wire pin1_usb_dp,     // USB pull-up enable, set low to disable
    output wire pin2_usb_dn,     // Both 1-2 are assigned Zero
    input  wire pin3_clk_16mhz,  // 16 MHz on-board clock -- UNUSED
    input wire pin13,            // Reset, active high, synchonous reset input
    input wire pin12,            // Enable, active high on counter
    output wire pin11,              // MSB output pin
    output wire pin10,
    output wire pin9,
    output wire pin8,               // LSB output pin
    output wire pin7,
    output wire pin6,
    output wire pin5,
    output wire pin4             
   );

// Clock driver
reg [22:0] clk_1hz_counter = 23'b0;  // 1 Hz clock generation counter
reg        clk_cyc = 1'b0;           // 1 Hz clock

localparam FREQUENCY = 23'd10;        // 10Hz
localparam CountSize = 8;

// -----------------------------------------------------------------
// Data types
// -----------------------------------------------------------------

reg[CountSize-1:0] counter_out = 0;   // counter_out, N bit vector output

// Core Clock Scaler 
always @(posedge pin3_clk_16mhz) begin
    if (clk_1hz_counter < 23'd7_999_999)
        clk_1hz_counter <= clk_1hz_counter + FREQUENCY;
    else begin
        clk_1hz_counter <= 23'b0;
        clk_cyc <= ~clk_cyc;
    end
end

// Application clock
always @(posedge clk_cyc) begin
    // At every rising edge of clock we check if reset is active
    // If active, we load the counter output with 4'b0000
    if (pin13 == 1'b1) begin
        counter_out <= 4'b0000;
    end
    // If enable is active, then we increment the counter
    else if (pin12 == 1'b1) begin
        counter_out <= counter_out + 1;
    end
end

assign pin11 = counter_out[7];
assign pin10 = counter_out[6];
assign pin9 = counter_out[5];
assign pin8 = counter_out[4];
assign pin7 = counter_out[3];
assign pin6 = counter_out[2];
assign pin5 = counter_out[1];
assign pin4 = counter_out[0];

assign pin1_usb_dp = 1'b0;
assign pin2_usb_dn = 1'b0;

endmodule  // top