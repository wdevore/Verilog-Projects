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


# Build or simulation via APIO

```
> apio init --board TinyFPGA-B2
> apio build
```

Or for simulation only:
```
> apio init --board TinyFPGA-B2
> apio sim
```

## Raw build

Run the following scripts in this order:
- run.sh

OR
- build.sh
- route.sh
- upload.sh

### Synth
```
yosys -p "synth_ice40 -json hardware.json -top top" -q -defer a09_cpu.v

yosys -p "synth_ice40 -json hardware.json -top top" -q -q -defer -l yo.log a09_cpu.v
```

Search for **Warning:** to find any issues, for example:
```
../../modules/sequence_control/sequence_control.v:196: Warning: Range select [15:12] out of bounds on signal `\IR': Setting all 4 result bits to undef.
../../modules/sequence_control/sequence_control.v:250: Warning: Range select out of bounds on signal `\IR': Setting result bit to undef.
../../modules/sequence_control/sequence_control.v:315: Warning: Range select [11:10] out of bounds on signal `\IR': Setting all 2 result bits to undef.
../../modules/sequence_control/sequence_control.v:528: Warning: Range select [11:9] out of bounds on signal `\IR': Setting all 3 result bits to undef.
../../components/cpu/cpu.v:119: Warning: Range [8:0] select out of bounds on signal `\ir': Setting 1 MSB bits to undef.
../../components/cpu/cpu.v:124: Warning: Range [9:0] select out of bounds on signal `\ir': Setting 2 MSB bits to undef.
../../components/cpu/cpu.v:124: Warning: Range select out of bounds on signal `\ir': Setting result bit to undef.
../../components/cpu/cpu.v:202: Warning: Range select [11:9] out of bounds on signal `\ir': Setting all 3 result bits to undef.
Warning: Wire top.\resetL.Ro_to_Si is used but has no driver.
Warning: Wire top.\cpu.ALUResults.Clk is used but has no driver.
```

The **Fix** is to manually update parameters in each module. The ```-defer``` doesn't seem to silence the warnings.

### Route
```
~/.apio/packages/toolchain-ice40/bin/nextpnr-ice40 --lp8k --package cm81 --json hardware.json --asc hardware.asc --pcf pins.pcf -l next.log -f --ignore-loops -q
```

### Pack
```
~/.apio/packages/toolchain-ice40/bin/icepack hardware.asc hardware.bin
```

Typical call if there are no combinatorial loops
```
nextpnr-ice40 --lp8k --package cm81 --json hardware.json --asc hardware.asc --pcf pins.pcf -q
```

### Upload
```
.local/bin/tinyfpgab/

tinyfpgab -c /dev/ttyACM0 --program hardware.bin
```

# Build warnings

## Warning: Range select XXX out of bounds on signal \YY
https://ask.csdn.net/questions/1800353

See this response below, but it basically says:

When you do ```./yosys -f "verilog -sv" file.v``` you are implicitly doing a ```read_verilog file.v```. What read_verilog does is it both analyses (i.e. builds the AST) and elaborates (i.e. converts into RTLIL) the design. Since there is no concept of hierarchy at this step, it elaborates each module in the design as if it was a top module, using default parameter values. It's this step that causes a warning.

``` 
$ ./yosys -q -f "verilog -sv" bug2039.v
bug2039.v:26: Warning: Range select out of bounds on signal `\o_result': Setting result bit to undef.
```
If you want to suppress this behaviour, you will need to add the ```-defer``` option and set the **top** explicitly:
 
```
$ ./yosys -q -f "verilog -sv -defer" bug2039.v -p "synth_ice40 -top ALU_Test_Top"
```
What this does is to defer the elaboration step to the hierarchy pass. Since nothing has been elaborated into RTLIL, hierarchy is currently unable to auto-detect the top-level (as it can't currently examine the AST) and so you have to set it manually.

# Test curcuit
## Using a R2R network
74LS02 using a resister divider network

https://electronics.stackexchange.com/questions/231616/can-i-use-a-voltage-divider-for-shifing-logic-levels

Picking R1 = 10kOhm and R2 = 20kOhm

## Using a TTGO microcontroller
See TTGO-Espressif-Projects/Verilog-Projects/A09 : https://github.com/wdevore/TTGO-Espressif-Projects/tree/main/a09_control