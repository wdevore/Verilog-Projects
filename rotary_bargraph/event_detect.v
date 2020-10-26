// --------------------------------------------------------------------------
// x4 decoder produces all 4 events from 1 turn of the rotary but we only want
// to recognize only one of them. So this module is a basic 2 bit counter that
// emits true when the counter = 0.
// --------------------------------------------------------------------------
module event_detect (
   input Clk,
   output Detected
   );
   wire s0;
   wire s1;
   wire s2;
   wire s3;

   flip_flop #(
      .Default(0)
   )
   DIG_D_FF_1bit_i0 (
      .D( s0 ),
      .C( Clk ),
      .Q( s1 ),
      .notQ ( s0 )
   );
   flip_flop #(
      .Default(0)
   )
   DIG_D_FF_1bit_i1 (
      .D( s2 ),
      .C( s0 ),
      .Q( s3 ),
      .notQ ( s2 )
   );
   assign Detected = (s1 & s3);
endmodule