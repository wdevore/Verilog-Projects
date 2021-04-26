Tool for hex calcs
http://www.eecs.umich.edu/courses/eng100/calc.html

For Version 3 of A09

# Nop_Halt.dat
```
Adr Hex     Binary                  Assembly
@05 1000    0001_0000_0000_0000     NOP
@06 B000    1011_0000_0000_0000     HLT
@FF 0005                            Reset Vector
```

# Out_Reg.dat
```
Adr Hex     Binary                  Assembly
@05 91A5    1001_0001_1010_0101     LDI R1, 0xA5
@06 A001    1010_0000_0000_0001     OTR R1    Copy Reg 1 to output
@07 B000    1011_0000_0000_0000     HLT
@FF 0005                            Reset Vector
```

# Nop_Ld.dat
```
Adr Hex     Binary                  Assembly
@05 1000    0001_0000_0000_0000     NOP
@06 91A5    1001_0001_1010_0101     LDI R1, 0xA5
@07 A001    1010_0000_0000_0001     OTR R1   Copy Reg 1 to output
@08 B000    1011_0000_0000_0000     HLT
@FF 0005                            Reset Vector
```

# Out_Reg_Nop.dat -- Working, Extended mem_en 1 clock
```
Adr Hex     Binary                  Assembly
@05 91A5    1001_0001_1010_0101     LDI R1, 0xA5
@06 1000    0001_0000_0000_0000     NOP
@07 A001    1010_0000_0000_0001     OTR R1    Copy Reg 1 to output
@08 B000    1011_0000_0000_0000     HLT
@FF 0005                            Reset Vector
```

# Shift_Left.dat
```
Adr Hex     Binary                  Assembly
@05 9101    1001_0001_0000_0001     LDI R1, 0x01
@06 A001    1010_0000_0000_0001     OTR R1
@07 9205    1001_0010_0000_0101     LDI R2, 0x05
@08 A002    1010_0000_0000_0010     OTR R2
@09 4051    0100_0000_0101_0001     SHL R1, R1, R2  = R1 <-- R1 << R2
@0A A001    1010_0000_0000_0001     OTR R1
@0B B000    1011_0000_0000_0000     HLT
@FF 0005                            Reset Vector
```

# Shift_Right.dat
```
Adr Hex     Binary                  Assembly
@05 9108    1001_0001_0000_1000     LDI R1, 0x08
@06 A001    1010_0000_0000_0001     OTR R1
@07 9203    1001_0010_0000_0011     LDI R2, 0x03
@08 A002    1010_0000_0000_0010     OTR R2
@09 5051    0101_0000_0101_0001     SHR R1, R1, R2  = R1 <-- R1 >> R2
@0A A001    1010_0000_0000_0001     OTR R1
@0B B000    1011_0000_0000_0000     HLT
@FF 0005                            Reset Vector
```

# Add_Halt.dat
```
Adr Hex     Binary                  Assembly
@05 9102    1001_0001_0000_0010     LDI R1, 0x02
@06 A001    1010_0000_0000_0001     OTR R1
@07 9205    1001_0010_0000_0101     LDI R2, 0x05
@08 A002    1010_0000_0000_0010     OTR R2
@09 20D1    0010_0000_1101_0001     ADD R3, R2, R1
@0A A003    1010_0000_0000_0011     OTR R3
@0B B000    1011_0000_0000_0000     HLT
@FF 0005                            Reset Vector
```

# Sub_Halt.dat
```
Adr Hex     Binary                  Assembly
@05 9102    1001_0001_0000_0010     LDI R1, 0x02
@06 A001    1010_0000_0000_0001     OTR R1
@07 9204    1001_0010_0000_0100     LDI R2, 0x04
@08 A002    1010_0000_0000_0010     OTR R2
@09 30D1    0011_0000_1101_0001     SUB R3, R1, R2
@0A A003    1010_0000_0000_0011     OTR R3
@0B B000    1011_0000_0000_0000     HLT
@FF 0005                            Reset Vector
```

# BNE_Halt.dat
```
Adr Hex     Binary                  Assembly
@05 9102    1001_0001_0000_0010     LDI R1, 0x02
@06 A001    1010_0000_0000_0001     OTR R1
@07 9205    1001_0010_0000_0101     LDI R2, 0x05
@08 A002    1010_0000_0000_0010     OTR R2
@09 20D1    0010_0000_1101_0001     ADD R3, R2, R1   = 7
@0A A003    1010_0000_0000_0011     OTR R3
@0B 6004    0110_0000_0000_0100     BNE 0x04     -------
@0C 1000    0001_0000_0000_0000     NOP                 |
@0D 1000    0001_0000_0000_0000     NOP                 |  Branch to here
@0E B000    1011_0000_0000_0000     HLT                 |
@0F 9204    1001_0010_0000_0100     LDI R2, 0x04  <-----
@10 A002    1010_0000_0000_0010     OTR R2
@11 B000    1011_0000_0000_0000     HLT
@FF 0005                            Reset Vector
```

# JMP_Halt.dat
```
Adr Hex     Binary                  Assembly
@05 910B    1001_0001_0000_1011     LDI R1, 0x0B     <-- absolute address
@06 A001    1010_0000_0000_0001     OTR R1
@07 7001    0111_0000_0000_0001     JMP R1   --------
@08 1000    0001_0000_0000_0000     NOP              |
@09 1000    0001_0000_0000_0000     NOP              |
@0A B000    1011_0000_0000_0000     HLT              |
@0B 9209    1001_0010_0000_1001     LDI R2, 0x09  <--   Jump to here
@0C A002    1010_0000_0000_0010     OTR R2
@0D B000    1011_0000_0000_0000     HLT
@FF 0005                            Reset Vector
```

# Count_Up.dat
```
@05 9100    1001_0001_0000_0000     LDI R1, 0x00  <-- Counter
@06 9202    1001_0010_0000_0010     LDI R2, 0x02  <-- Count by 2
@07 9306    1001_0011_0000_0110     LDI R3, 0x06  <-- Count up to 6
@08 2051    0010_0000_0101_0001     ADD R1, R2, R1   <-------.  Inc
@09 A001    1010_0000_0000_0001     OTR R1                   |
@0A 3419    0011_0100_0001_1001     CMP R3, R1               |  Compare
@0B 60FD    0110_0000_1111_1101     BNE -3  >----------------.  Loop until 0
@0C B000    1011_0000_0000_0000     HLT
@FF 0005                            Reset Vector
```

# Count_Down.dat
```
@05 9105    1001_0001_0000_0101     LDI R1, 0x05  <-- Counter (A)
@06 9201    1001_0010_0000_0001     LDI R2, 0x01  <-- Count down by 1 (B)
@07 3051    0011_0000_0101_0001     SUB R1, R2, R1   <---. Dec (A - B)
@08 A001    1010_0000_0000_0001     OTR R1               |
@09 60FD    0110_0000_1111_1110     BDE -2    >----------.  Loop until 0
@0A B000    1011_0000_0000_0000     HLT
@FF 0005                            Reset Vector
```

# Cylon.dat
```
@05 9101    1001_0001_0000_0001     LDI R1, 0x01  <-- Pattern
@06 9201    1001_0010_0000_0001     LDI R2, 0x01  <-- Shift by 1
@07 9308    1001_0011_0000_1000     LDI R3, 0x08  <-- Left limit
@08 9401    1001_0100_0000_0001     LDI R4, 0x01  <-- Right limit
@09 950B    1001_0101_0000_1101     LDI R5, 0x0B  <-- Jump address to SHL
@0A A001    1010_0000_0000_0001     OTR R1
@0B 4051    0100_0000_0101_0001     SHL R1, R1, R2  <------.
@0C A001    1010_0000_0000_0001     OTR R1                 |
@0D 3419    0011_0100_0001_1001     CMP R3, R1             |
@0E 60FD    0110_0000_1111_1101     BNE -3    >------------. Loop while !=
@0F 5051    0101_0000_0101_0001     SHR R1, R1, R2  <------.
@10 A001    1010_0000_0000_0001     OTR R1                 |
@11 3421    0011_0100_0010_0001     CMP R4, R1             |
@12 60FD    0110_0000_1111_1101     BNE -3    >------------. Loop while !=
@13 7005    0111_0000_0000_0101     JMP R5
@14 B000    1011_0000_0000_0000     HLT      <-- Never reached
@FF 0005                            Reset Vector
```

