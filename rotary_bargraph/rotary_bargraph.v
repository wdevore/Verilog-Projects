// Rotary Encoder test - top.v
//


// --------------------------------------------------------------------------
// Rotary decoder
// Base on: https://www.fpga4fun.com/QuadratureDecoder.html
// This decoder is sometimes called a "4x decoder" because it counts all
// the transitions of the quadrature inputs.
// Note: I still want to build a variation based on these:
// https://www.fpga4student.com/2017/04/simple-debouncing-verilog-code-for.html
// https://www.beyond-circuits.com/wordpress/tutorial/tutorial12/

// --------------------------------------------------------------------------



// --------------------------------------------------------------------------
// Main module
// --------------------------------------------------------------------------
module top (
   output pin1_usb_dp,// USB pull-up enable, set low to disable
   output pin2_usb_dn,
   input  pin3_clk_16mhz,   // 16 MHz on-board clock
   // pins 13-4 should be connected to 10 LEDs
   output pin13,         // Left most bit
   output pin12,
   output pin11,
   output pin10,
   output pin9,
   output pin8,
   output pin7,   
   output pin6,
   output pin5,
   output pin4,          // Right most bit
   input  pin14_sdo,     // Rotary input A : Yellow before Green = CW
   input  pin15_sdi,     // Rotary input B
   );

   reg [22:0] clk_1hz_counter = 23'b0;  // Hz clock generation counter
   reg        clk_cyc = 1'b0;           // Hz clock

   // The bargraph works by shifting a fixed with number of 1s (i.e. 10 in this case)
   //                              _out of view
   //                             /          /- in view
   //                            |          |
   //                        |   V    |     V   |
   reg[19:0] bar_height = 20'b11111111110000000000;   // Holds bar height

   // 2KHz because of the quadrature
   localparam FREQUENCY = 23'd2000;

   wire inv_A, inv_B;

   wire quad_dir;
   wire quad_shift;
   wire event_enabled;

   // Debouncers
   digital_filter dfA(.clk(clk_cyc), .D(pin14_sdo), .Q(pin16_sck));
   digital_filter dfB(.clk(clk_cyc), .D(pin15_sdi), .Q(pin17_ss));

   // Convert from negative logic to positive logic
   not(inv_A, pin16_sck);
   not(inv_B, pin17_ss);

   // Generate events based on A/B
   quadrature_decoder decoder(.A(inv_A), .B(inv_B), .Clk(clk_cyc), .Dir(quad_dir), .Shift(quad_shift));

   // Filter out 3 of the 4 events. We just want one.
   event_detect ed(.Clk(quad_shift), .Detected(event_enabled));

   // Clock divder and generator
   always @(posedge pin3_clk_16mhz) begin
      if (clk_1hz_counter < 23'd7_999_999)
         clk_1hz_counter <= clk_1hz_counter + FREQUENCY;
      else begin
         clk_1hz_counter <= 23'b0;
         clk_cyc <= ~clk_cyc;
      end
   end

   // Ping/Pong effect, driven by Decoder
   // Warning! You can't use the 16MHz clock because: for one that would introduce cross-domain
   // clocking, and two, quadrature is based off of the 2KHz clock so they would be out of sync.
   // Introducing a FIFO would be nutty and overkill.
   always @(posedge clk_cyc) begin
      // Shift active LED only if Shift flag is High and Event detected.
      if (event_enabled == 1 && quad_shift == 1) begin
         if (quad_dir == 0) begin
            // Shrink = shift left
            if (bar_height == 20'b11111111110000000000)
               bar_height <= bar_height;
            else
               bar_height <= bar_height << 1;
         end
         else begin
            // Grow = shift right
            if (bar_height == 20'b00000000001111111111)
               bar_height <= bar_height;
            else
               bar_height <= bar_height >> 1;
         end
      end
      else
         bar_height <= bar_height;
   end

   // Route to pins
   assign
      pin13 = bar_height[9],
      pin12 = bar_height[8],
      pin11 = bar_height[7],
      pin10 = bar_height[6],
      pin9  = bar_height[5],
      pin8  = bar_height[4],
      pin7  = bar_height[3],
      pin6  = bar_height[2],
      pin5  = bar_height[1],
      pin4  = bar_height[0];

   // Debug
   assign
      pin18 = quad_dir,
      pin19 = quad_shift;

   assign
      pin1_usb_dp = 1'b0,
      pin2_usb_dn = 1'b0;

endmodule  // top