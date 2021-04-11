# A09
A09 is the precursor the X09 CPU. A09 is a simplified 16bit CPU for learning purposes.

[Yosys](https://github.com/YosysHQ/yosys) reports that it takes **774** cells, which isn't *too* bad ;-)

```
=== top ===
   Number of wires:                530
   Number of wire bits:           1831
   Number of public wires:         165
   Number of public wire bits:    1338
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                774
     SB_CARRY                       87
     SB_DFFE                         1
     SB_DFFESR                       1
     SB_DFFNE                       72
     SB_DFFNESR                    116
     SB_DFFSR                       25
     SB_DFFSS                        1
     SB_LUT4                       470
     SB_RAM40_4KNRNW                 1
```

[CPU Layout diagram](A09_CPU.png) made using app.diagrams.net


https://www.chipverify.com/verilog/verilog-timing-control

# Synthization
