`default_nettype none

// Un-gated Latch
module SRLatch(
    input wire S, R,
    output wire Q, Qn
);

// Gate level
// http://www.barrywatson.se/dd/dd_sr_latch_ungated.html
// OR
// http://www.eng.auburn.edu/~strouce/class/elec4200/flip-flop.pdf
wire So_to_Ri;
wire Ro_to_Si;

nor(S, Ro_to_Si, So_to_Ri);
nor(R, So_to_Ri, Ro_to_Si);

assign Qn = So_to_Ri;
assign Q = Ro_to_Si;

// Behaviour level
// Causes logic loop
// always @(*) begin
//     Q  = ~(R | Qn);
//     Qn = ~(S | Q);
// end

endmodule