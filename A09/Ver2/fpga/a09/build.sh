touch ../../modules/sequence_control/constants.v
touch ../../components/cpu/cpu.v
touch ../../modules/program_counter/pc.v
touch ../../modules/mux/mux.v
touch ../../modules/memory/memory.v
touch ../../modules/register/register.v
touch ../../modules/register_file/register_file.v
touch ../../modules/sequence_control/sequence_control.v
touch ../../modules/alu/alu

yosys -p "synth_ice40 -json hardware.json -top top" -l yo.log -q -defer \
    a09_cpu.v
#    ../../modules/sequence_control/constants.v \
#    ../../components/cpu/cpu.v \
#    ../../modules/program_counter/pc.v \
#    ../../modules/mux/mux.v \
#    ../../modules/memory/memory.v \
#    ../../modules/register/register.v \
#    ../../modules/register_file/register_file.v \
#    ../../modules/sequence_control/sequence_control.v \
#    ../../modules/alu/alu.v
