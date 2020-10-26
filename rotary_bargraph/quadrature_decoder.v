module quadrature_decoder (
  input A,
  input B,
  input Clk,
  output Dir,
  output Shift
);
  wire s0;
  wire s1;
  wire s2;
  wire s3;
  wire s4;
  wire s5;

  flip_flop #(
    .Default(0)
  )
  DIG_D_FF_1bit_i0 (
    .D( A ),
    .C( Clk ),
    .Q( s0 )
  );
  flip_flop #(
    .Default(0)
  )
  DIG_D_FF_1bit_i1 (
    .D( B ),
    .C( Clk ),
    .Q( s5 )
  );
  flip_flop #(
    .Default(0)
  )
  DIG_D_FF_1bit_i2 (
    .D( s0 ),
    .C( Clk ),
    .Q( s1 )
  );
  flip_flop #(
    .Default(0)
  )
  DIG_D_FF_1bit_i3 (
    .D( s5 ),
    .C( Clk ),
    .Q( s4 )
  );
  flip_flop #(
    .Default(0)
  )
  DIG_D_FF_1bit_i4 (
    .D( s1 ),
    .C( Clk ),
    .Q( s2 )
  );
  flip_flop #(
    .Default(0)
  )
  DIG_D_FF_1bit_i5 (
    .D( s4 ),
    .C( Clk ),
    .Q( s3 )
  );
  assign Dir = (s1 ^ s3);
  assign Shift = (s1 ^ s2 ^ s4 ^ s3);
endmodule
