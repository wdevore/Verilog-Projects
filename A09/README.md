# A09
A09 is the precursor the X09 CPU. A09 is a simplified 16bit CPU for learning purposes.

A [GTKWave Output](A09_Count_Up_GTKWave.png) of counting to 10 using the following program below:

```
@00 B200    1011_0010_0000_0000     LDI R1, 0x00  <-- Counter
@01 B401    1011_0100_0000_0001     LDI R2, 0x01  <-- Count by 1
@02 B60A    1011_0110_0000_1010     LDI R3, 0x0A  <-- Count up to A = 10
@03 2221    0010_0010_0010_0001     ADD R1, R2, R1   <-------  Inc
@04 F801    1111_1000_0000_0001     OUT R1                  |
@05 3131    0011_0001_0011_0001     CMP R3, R1              |  Compare
@06 77FD    0111_0111_1111_1101     BNE -3           --------  Loop until 0
@07 1000    0001_0000_0000_0000     HLT
```

[CPU Layout diagram](A09_CPU.png) made using app.diagrams.net

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

https://www.chipverify.com/verilog/verilog-timing-control

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