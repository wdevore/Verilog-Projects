`default_nettype none

// A09 CPU targeted for an FPGA

`undef SIMULATE

`include "../../modules/sequence_control/constants.v"

`include "../../modules/sequence_control/sequence_control.v"

module top
(
    // See pins.pcf for pin Definitions
    output pin1_usb_dp,     // USB pull-up enable, set low to disable
    output pin2_usb_dn,     // Both 1-2 are assigned Zero
    input  pin3_clk_16mhz,   // 16 MHz on-board clock -- UNUSED
    // pins 4-11 is the lower 8bits of the Output register
    output pin4,        // LSB
    output pin5,
    output pin6,
    output pin7,
    output pin8,
    output pin9,
    output pin10,   
    output pin11,       // 
    output pin12,       // 
    output pin13,       // 
    output pin14_sdo,   // 
    output pin15_sdi,   // 
    output pin16_sck,   // 
    input pin18,        // IR select bit 0
    input pin19,        // IR select bit 1
    input pin20,        // IR select bit 2
    input pin21,        // IR select bit 3
    input pin22,        // Clock
    input pin23,        // Reset
    output pin24        // ClockCyl
);

localparam AddrWidth = 8;      // 8bit Address width
localparam DataWidth = 16;     // 16bit Data width
localparam WordSize = 1;       // Instructions a 1 = 2bytes in size
localparam ALUOpSize = 4;

reg [DataWidth-1:0] ir;

// Datapath Controls
reg halt;

reg pc_rst;             // PC reset
reg pc_inc;             // PC increment
reg pc_ld;
reg [1:0] pc_src;       // MUX_PC selector
reg bra_src;

reg stk_ld;
reg ir_ld;

reg out_ld;
reg [1:0] out_sel;

reg flg_ld;
reg flg_rst;
reg alu_ld;
reg [ALUOpSize-1:0] alu_op;
reg alu_instr;

reg mem_en;
reg mem_wr;
reg [1:0] addr_src;     // MUX_ADDR selector

reg reg_we;
reg src1_sel;
reg [1:0] data_src;
reg [2:0] reg_dest;     // 3Bits
reg [2:0] reg_src1;
reg [2:0] reg_src2;

reg output_ld;

reg ready;              // (Active High) when CPU has completed reset activities.

// ----------------------------------------------------------
// Clock unused
// ----------------------------------------------------------
reg [22:0] clk_1hz_counter = 23'b0;  // Hz clock generation counter
reg        clk_cyc = 1'b0;           // Hz clock
localparam FREQUENCY = 23'd2;  // 2Hz
  
// Clock divder and generator
always @(posedge pin3_clk_16mhz) begin
    if (clk_1hz_counter < 23'd7_999_999)
        clk_1hz_counter <= clk_1hz_counter + FREQUENCY;
    else begin
        clk_1hz_counter <= 23'b0;
        clk_cyc <= ~clk_cyc;
    end
end

always @* begin
    ir = DataWidth'h0;

    case ({pin21,pin20,pin19,pin18})
        4'b0000: begin
            ir = DataWidth'hB200;  // LDI R1, 0x00
        end

        4'b0001: begin
            ir = DataWidth'hF803;  // OUT R3
        end

        4'b0010: begin
            ir = DataWidth'h2221;  // ADD R1, R2, R1
        end

        4'b0011: begin
            ir = DataWidth'h3131;  // CMP R3, R1
        end

        4'b0100: begin
            ir = DataWidth'h77FD;  // BNE -3
        end
        
        4'b0101: begin
            ir = DataWidth'h1000;  // HLT
        end

        default:
            ir = DataWidth'h0;    
    endcase
end

// ----------------------------------------------------------
// Modules
// ----------------------------------------------------------

SequenceControl #(.DataWidth(DataWidth)) ControlMatrix
(
    .Clk(pin22),
    .Reset(pin23),
    .IR(ir),
    .STK_Ld(stk_ld),
    .BRA_Src(bra_src),
    .IR_Ld(ir_ld),
    .PC_Ld(pc_ld),
    .PC_Rst(pc_rst),
    .PC_Inc(pc_inc),
    .PC_Src(pc_src),
    .MEM_Wr(mem_wr),
    .MEM_En(mem_en),
    .ADDR_Src(addr_src),
    .REG_WE(reg_we),
    .DATA_Src(data_src),
    .REG_Dest(reg_dest),
    .REG_Src1(reg_src1),
    .REG_Src2(reg_src2),
    .Src1_Sel(src1_sel),
    .ALU_Op(alu_op),
    .ALU_FlgsIn({3{1'b0}}),
    .FLG_Ld(flg_ld),
    .ALU_Ld(alu_ld),
    .FLG_Rst(flg_rst),
    .OUT_Ld(output_ld),
    .OUT_Sel(out_sel),
    .Ready(ready),
    .Halt(halt)
);

// ----------------------------------------------------------
// IO routing
// ----------------------------------------------------------
// Route Output wires to pins
assign
    pin4      = ir_ld,
    pin5      = pc_inc,
    pin6      = mem_wr,
    pin7      = mem_en,
    pin8      = reg_we,
    pin9      = output_ld,
    pin10     = ready,
    pin11     = halt,
    pin12     = reg_dest[0],
    pin13     = reg_dest[1],
    pin14_sdo = reg_dest[2],
    pin15_sdi = bra_src,
    pin16_sck = alu_ld;

assign pin24 = clk_cyc;

// TinyFPGA standard pull pins defaults
assign
    pin1_usb_dp = 1'b0,
    pin2_usb_dn = 1'b0;

endmodule  // top