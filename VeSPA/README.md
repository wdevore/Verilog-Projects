# VeSPA
A Verilog behavioral simulation of the VeSPA RISC CPU

Based on: "*Designing Digital Computer Systems with Verilog*"

## v.out
This is the assembly that would generate *v.out* -- note: *v.out* lacks the explicit addresses:

```
;
; A test program that simply loops ’count’ number of times.
; r0 = the value read from the variable ’count’
; r1 = the current iteration number
;
        .org 0          ; start the program at address 0
        ld r0,count     ; load the value of count into r0
        ldi r1,#0       ; initialize r1 to 0
back:   add r1,r1,#1    ; add one to the value in r1
        cmp r1,r0       ; compare iteration number (r1) to count (r0)
        ble back        ; loop if r1 <= r0
        hlt             ; otherwise, stop execution
;
; Define the storage locations
;
count:
        .word 0xA       ; number of times to loop (in hex)
```

As:
```
@0000 50 00 00 18
@0004 58 40 00 00
@0008 08 43 00 01
@000c 38 02 00 00
@0010 46 ff ff f4
@0014 f8 00 00 00
@0018 00 00 00 0a
```
