// Rotary Encoder test - top.v
//

// --------------------------------------------------------------------------
// Main module
// --------------------------------------------------------------------------
module top (
   output pin1_usb_dp,// USB pull-up enable, set low to disable
   output pin2_usb_dn,
   input  pin3_clk_16mhz,   // 16 MHz on-board clock
   // pins 13-4 should be connected to 10 LEDs
   output pin13,
   output pin12,
   output pin11,
   output pin10,
   output pin9,
   output pin8,
   output pin7,   
   output pin6,
   output pin5,
   output pin4,         
   input  pin14_sdo,     // Rotary input A : Yellow before Green = CW
   input  pin15_sdi,     // Rotary input B
   output pin16_sck,     // debounced ~A
   output pin17_ss,      // debounced ~B
   output pin18,         // quad_dir (Yellow channel on DSO)
   output pin19          // quad_shift  (Green)
   );

   reg [22:0] clk_1hz_counter = 23'b0;  // Hz clock generation counter
   reg        clk_cyc = 1'b0;           // Hz clock

   reg[9:0] shift = 1;   // N bit shift register that shifts at each turn

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
            if (shift == 10'b1000000000)
               shift <= 1; // Wrap around
            else
               shift <= shift << 1;
         end
         else begin
            if (shift == 10'b0000000001)
               shift <= 10'b1000000000; // Wrap around
            else
               shift <= shift >> 1;
         end
      end
      else
         shift <= shift;
   end

   // Route to pins
   assign
      pin13 = shift[9],
      pin12 = shift[8],
      pin11 = shift[7],
      pin10 = shift[6],
      pin9  = shift[5],
      pin8  = shift[4],
      pin7  = shift[3],
      pin6  = shift[2],
      pin5  = shift[1],
      pin4  = shift[0];

   // Debug
   assign
      pin18 = quad_dir,
      pin19 = quad_shift;

   assign
      pin1_usb_dp = 1'b0,
      pin2_usb_dn = 1'b0;

endmodule  // top