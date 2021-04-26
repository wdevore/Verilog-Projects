`default_nettype none

// Currently unused because Verilog doesn't like logic loops
// which SR latches are by definition.
// So instead my curcuit uses 74LS02 nor gate chip.

// Gate level
// http://www.barrywatson.se/dd/dd_sr_latch_ungated.html
// OR
// http://www.eng.auburn.edu/~strouce/class/elec4200/flip-flop.pdf

// -----------------------------------------------------------
// Un-gated Latch
// -----------------------------------------------------------
module SRLatch(
    input wire S, R,
    output wire Q, Qn
);
wire So_to_Ri;
wire Ro_to_Si;

nor(So_to_Ri, S, Ro_to_Si);
nor(Ro_to_Si, R, So_to_Ri);

assign Qn = So_to_Ri;
assign Q = Ro_to_Si;

// Behaviour level
// Causes logic loop
// always @(*) begin
//     Q  = ~(R | Qn);
//     Qn = ~(S | Q);
// end

endmodule

// -----------------------------------------------------------
// Gated Latch
// -----------------------------------------------------------
module SRGLatch(
    input wire S, R,
    input wire G,
    output wire Q, Qn
);

wire So_to_Ri;
wire Ro_to_Si;
wire S3_to_S31;
wire R3_to_R31;

and(S, G, S3_to_S31);
and(R, G, R3_to_R31);

nor(So_to_Ri, S3_to_S31, Ro_to_Si);
nor(Ro_to_Si, R3_to_R31, So_to_Ri);

assign Qn = So_to_Ri;
assign Q = Ro_to_Si;

// Behaviour level
// Causes logic loop
// always @(*) begin
//     Q  = ~(R | Qn);
//     Qn = ~(S | Q);
// end

endmodule


