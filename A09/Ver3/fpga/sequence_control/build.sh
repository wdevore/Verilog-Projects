yosys -p "synth_ice40 -json hardware.json -top top" -l yo.log -q -defer sequence_control.v