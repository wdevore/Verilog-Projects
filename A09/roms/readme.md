Tool for hex calcs

http://www.eecs.umich.edu/courses/eng100/calc.html

# Add_Halt.dat
```
Binary      Binary                  Assembly
@00 B202    1011_0010_0000_0010     LDI R1, 0x02
@01 B404    1011_0100_0000_0100     LDI R2, 0x04
@02 2621    0010_0110_0010_0001     ADD R3, R2, R1
@03 1000    0001_0000_0000_0000     HLT
```

# Sub_Halt.dat
```
Binary                  Assembly
1011_0010_0000_0010     LDI R1, 0x02
1011_0100_0000_0100     LDI R2, 0x04
0011_0110_0001_0010     SUB R3, R1, R2
0001_0000_0000_0000     HLT
```

# BRD_Halt.dat
```
Adr Hex     Assembly
@00 B202    LDI R1, 0x01
@01 B404    LDI R2, 0x02
@02 2621    ADD R3, R2, R1
@03 7404    BNE 0x04
@04 0000    NOP
@05 0000    NOP
@06 1000    HLT
@07 B204    LDI R2, 0x04
@08 1000    HLT
```

# JMP_Halt.dat
```
Adr Hex     Binary                  Assembly
@00 B205    1011_0010_0000_0101     LDI R1, 0x05
@01 9801    1001_1000_0000_0001     JMP R1   --------
@02 0000    0000_0000_0000_0000     NOP             |
@03 0000    0000_0000_0000_0000     NOP             |
@04 1000    0001_0000_0000_0000     HLT             |
@05 B409    1011_0100_0000_1001     LDI R2, 0x09  <-- Jump to here
@06 1000    0001_0000_0000_0000     HLT
```

# JPL_Halt.dat
```
Adr Hex     Binary                  Assembly
@00 B204    1011_0010_0000_0100     LDI R1, 0x04
@01 9001    1001_0000_0000_0001     JPL R1   --------
@02 0000    0000_0000_0000_0000     NOP             |    <---------- here
@03 1000    0001_0000_0000_0000     HLT             |              |
@04 B409    1011_0100_0000_1001     LDI R2, 0x09  <-- Jump here    |
@05 0000    0000_0000_0000_0000     NOP                            |
@06 A000    1010_0000_0000_0000     RET  <-- return from JPL to ----
@07 1000    0001_0000_0000_0000     HLT  <-- Should not be reached
```

# LD_Halt.dat
```
@00 C20A    1100_0010_0000_0100     LD R1, 0x0A
@01 0000    0000_0000_0000_0000     NOP
@02 C40B    1100_0100_0000_0100     LD R2, 0x0B
@03 1000    0001_0000_0000_0000     HLT
@04 0000
@05 0000
@06 0000
@07 0000
@08 0000
@09 0000
@0A 0101
@0B 1100
```

# ST_Halt.data
```
@00 B20A    1011_0010_0000_1010     LDI R1, 0x0A
@01 0000    0000_0000_0000_0000     NOP
@02 D209    1101_0010_0000_1001     ST R1, 0x09  --
@03 1000    0001_0000_0000_0000     HLT           |
@04 xxxx                                          |
@05 xxxx                                          |
@06 xxxx                                          |
@07 xxxx                                          |
@08 xxxx         R1's contents stored here        |
@09 0000    <--------------------------------------
@0A xxxx
```

# STX_Halt.data
```
@00 B20C    1011_0010_0000_1100     LDI R1, 0x0C  <-- Data
@01 B408    1011_0100_0000_1000     LDI R2, 0x08  <-- Address
@02 0000    0000_0000_0000_0000     NOP
@03 E021    1110_0000_0010_0001     STX R2, R1   --
@04 1000    0001_0000_0000_0000     HLT           |
@05 xxxx                                          |
@06 xxxx                                          |
@07 xxxx         R1's contents stored here        |
@08 0000    <--------------------------------------
@09 xxxx
```

# Count_Up.data
```
@00 B200    1011_0010_0000_0000     LDI R1, 0x00  <-- Counter
@01 B402    1011_0100_0000_0010     LDI R2, 0x02  <-- Count by 2
@02 B606    1011_0110_0000_0110     LDI R3, 0x06  <-- Count up to 6
@03 2221    0010_0010_0010_0001     ADD R1, R2, R1   <-------  Inc
@04 3131    0011_0001_0011_0001     CMP R3, R1              |  Compare
@05 77FE    0111_0111_1111_1110     BNE -2           --------  Loop until 0
@06 1000    0001_0000_0000_0000     HLT
```

# Count_Down.data
```
@00 B205    1011_0010_0000_0101     LDI R1, 0x05  <-- Counter (A)
@01 B401    1011_0100_0000_0001     LDI R2, 0x01  <-- Count down by 1 (B)
@02 3221    0011_0010_0010_0001     SUB R1, R2, R1   <-|  Dec (A - B)
@03 77FF    0111_0111_1111_1111     BNE -1    ---------|  Loop until 0
@04 1000    0001_0000_0000_0000     HLT
```

# Out_Mem.dat
```
Adr Hex     Binary                  Assembly
@00 F002    1111_1000_0000_0010     OUT 0x02   <-- Copy mem to output
@01 1000    0001_0000_0000_0000     HLT
@02 F0F0                            [Data]
```

# Out_Reg.dat
```
Adr Hex     Binary                  Assembly
@00 B2A5    1011_0010_1010_0101     LDI R1, 0xA5
@01 F801    1111_1000_0000_0001     OUT R1   <-- Copy Reg 1 to output
@02 1000    0001_0000_0000_0000     HLT
```

# Count_Out.data
```
@00 B200    1011_0010_0000_0000     LDI R1, 0x00  <-- Counter
@01 B401    1011_0100_0000_0001     LDI R2, 0x01  <-- Count by 1
@02 B60A    1011_0110_0000_1010     LDI R3, 0x0A  <-- Count up to A
@03 2221    0010_0010_0010_0001     ADD R1, R2, R1   <-------  Inc
@04 F801    1111_1000_0000_0001     OUT R1                  |
@05 3131    0011_0001_0011_0001     CMP R3, R1              |  Compare
@06 77FD    0111_0111_1111_1101     BNE -3           --------  Loop until 0
@07 1000    0001_0000_0000_0000     HLT
```