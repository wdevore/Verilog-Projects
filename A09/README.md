# A09
A09 is the precursor the X09 CPU. A09 is a simplified 16bit CPU for learning purposes.

# Simulation
Memory map
```
0x00      'b00000000
|
|                        ROM (aka Upper BRAM)
|
0x3F      'b01111111     ---------
0x40      'b10000000
|
|                        RAM
|
0xFF      'b11111111
```

## The simulation initialization
- Clear registers (PC, Stack, ALU flags)
- Load ROM
- Sequence state = 'b00

# Synthization


# Build or simulation

```
> apio init --board TinyFPGA-B2
> apio build
```

Or for simulation only:
```
> apio init --board TinyFPGA-B2
> apio sim
```


```
//Sign extend immediate field
assign imm_ext = (instr[15] == 1)? {16'hFFFF, instr[15:0]} : {16'h0000, instr[15:0]};
```