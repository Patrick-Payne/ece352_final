/******************************************************************************
 * File: multicycle.v
 * Author: ECE243 development team, Patrick Payne, Alex Papanicolaou
 * Date Created: Original 2007, modifications November 2013
 * Purpose: Implements the datapath of the multicycle processor. See project
 *    documentation for details.
 * Original file Copyright (c) 2007 by University of Toronto ECE 243
 * development team.
 *****************************************************************************/

module multicycle(
    input [1:0] KEY,
    input [2:0] SW,
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
    output [7:0] LEDG,
    output [17:0] LEDR);

  /* Internal registers/wires. */
  wire clock, reset;
  wire IR1Load, IR2Load, IR3Load, IR4Load;
  wire MDRLoad, MemRead, MemWrite, PC_sel, PCWrite, RegIn, Stop;
  wire ALU1, ALUOutWrite, FlagWrite, R1R2Load, R1Sel, RFWrite;
  wire [7:0] R2wire, R1wire, RFout1wire, RFout2wire;
  wire [7:0] PC_in, PCwire;
  wire [7:0] ALU1wire, ALU2wire, ALUwire, ALUOut, MDRwire, MEMwire;
  wire [7:0] IR1_in, IR1_out, IR2_out, IR3_out, IR4_out;
  wire [7:0] SE4wire, ZE5wire, ZE3wire, RegWire;
  wire [7:0] reg0, reg1, reg2, reg3;
  wire [7:0] HEX10_wire, HEX32_wire, HEX54_wire, HEX76_wire;
  wire [7:0] constant;
  reg [15:0] performance_count;
  wire [2:0] ALUOp, ALU2;
  wire [1:0] R1_in;
  wire [4:0] State;
  wire Nwire, Zwire;
  reg  N, Z;

  /* Input assigments */
  assign clock = KEY[1];
  assign reset = ~KEY[0]; // KEY is active high

  FSM  Control(
     .reset(reset), .clock(clock), .N(N), .Z(Z), .instr(IR1_out[3:0]),
     .MemRead(MemRead), .MemWrite(MemWrite), .R1Sel(R1Sel), .MDRload(MDRLoad),
     .R1R2Load(R1R2Load), .ALU1(ALU1), .ALUOutWrite(ALUOutWrite),
     .FlagWrite(FlagWrite), .ALU2(ALU2),
     .ALUop(ALUOp), .state(State));

  control_fetch fetch (
      .branch(1'b0), .opcode(IR1_out[3:0]), .pc_write(PCWrite),
      .pc_sel(PC_sel), .ir1_load(IR1Load));

  control_wb  wb (
    .opcode(IR4_out[3:0]), .rf_write(RFWrite), .ir4_load(IR4Load),
    .reg_in(RegIn), .stop(Stop));

  /* For now, just assign values for the pipelined instruction regs. */
  assign IR2Load = 1'b1;
  assign IR3Load = 1'b1;

  memory DataMem(
     .MemRead(MemRead), .wren(MemWrite), .clock(clock), .address(R2wire),
     .address_pc(PCwire), .data(R1wire), .q(MEMwire), .q_pc(IR1_in));

  ALU  ALU(
     .in1(ALU1wire), .in2(ALU2wire), .out(ALUwire),
     .ALUOp(ALUOp), .N(Nwire), .Z(Zwire));

  RF  RF_block(
     .clock(clock), .reset(reset), .RFWrite(RFWrite),
     .dataw(RegWire), .reg1(R1_in), .reg2(IR2_out[5:4]),
     .regw(IR4_out[7:6]), .data1(RFout1wire), .data2(RFout2wire),
     .r0(reg0), .r1(reg1), .r2(reg2), .r3(reg3));

  /* Implement the pipelined instruction registers. */
  register_8bit IR1_reg(
     .clock(clock), .aclr(reset), .enable(IR1Load),
     .data(IR1_in), .q(IR1_out));

  register_8bit IR2_reg(
     .clock(clock), .aclr(reset), .enable(IR2Load),
     .data(IR1_out), .q(IR2_out));

  register_8bit IR3_reg(
     .clock(clock), .aclr(reset), .enable(IR3Load),
     .data(IR2_out), .q(IR3_out));

  register_8bit IR4_reg(
     .clock(clock), .aclr(reset), .enable(IR4Load),
     .data(IR3_out), .q(IR4_out));


  register_8bit MDR_reg(
     .clock(clock), .aclr(reset), .enable(MDRLoad),
     .data(MEMwire), .q(MDRwire));

  register_8bit PC(
     .clock(clock), .aclr(reset), .enable(PCWrite),
     .data(PC_in), .q(PCwire));

  register_8bit R1(
     .clock(clock), .aclr(reset), .enable(R1R2Load),
     .data(RFout1wire), .q(R1wire));

  register_8bit R2(
     .clock(clock), .aclr(reset), .enable(R1R2Load),
     .data(RFout2wire), .q(R2wire));

  register_8bit ALUOut_reg(
     .clock(clock), .aclr(reset), .enable(ALUOutWrite),
     .data(ALUwire), .q(ALUOut));

  /* Muxes. */
  mux2to1_8bit PCsel_mux(
     .data0x(PCwire + 8'b1), .data1x(ALUwire),
     .sel(PC_sel), .result(PC_in));

  mux2to1_2bit R1Sel_mux(
     .data0x(IR2_out[7:6]), .data1x(constant[1:0]),
     .sel(R1Sel), .result(R1_in));

  mux2to1_8bit RegMux(
     .data0x(ALUOut), .data1x(MDRwire),
     .sel(RegIn), .result(RegWire));

  mux2to1_8bit ALU1_mux(
     .data0x(PCwire), .data1x(R1wire),
     .sel(ALU1), .result(ALU1wire));

  mux5to1_8bit ALU2_mux(
     .data0x(R2wire), .data1x(constant), .data2x(SE4wire),
     .data3x(ZE5wire), .data4x(ZE3wire), .sel(ALU2), .result(ALU2wire));

  sExtend SE4(.in(IR2_out[7:4]), .out(SE4wire));
  zExtend ZE3(.in(IR2_out[5:3]), .out(ZE3wire));
  zExtend ZE5(.in(IR2_out[7:3]), .out(ZE5wire));

  // define parameter for the data size to be extended
  defparam SE4.n = 4;
  defparam ZE3.n = 3;
  defparam ZE5.n = 5;

  always @(posedge clock, posedge reset) begin
    if (reset) begin
      N <= 0;
      Z <= 0;
    end
    else if (FlagWrite) begin
      N <= Nwire;
      Z <= Zwire;
    end
  end

  /* Create a dummy constant 1, used in the datapath. */
  assign constant = 1;

  /* Update the performance counter if the stop condition is not raised. */
  always @(posedge clock, posedge reset) begin
    if (reset) begin
      performance_count <= 0;
    end
    else if (!Stop) begin
      performance_count <= performance_count + 16'b1;
    end
  end

  /* Select the values to display on the hex displays. */
  // If switches are off, display the 4 registers.
  // If switch 1 is on, display the pipelined instruction registers.
  // If switch 2 is on, display the performance counter on HEX1 and HEX0.
  // If both switches are on, display the pipelined PC registers.
  mux4to1_8bit HEX10_mux(
     .data0x(reg3), .data1x(IR4_out), .data2x(performance_count[7:0]),
     .data3x(PCwire), .sel(SW[2:1]), .result(HEX10_wire));

  mux4to1_8bit HEX32_mux(
     .data0x(reg2), .data1x(IR3_out), .data2x(performance_count[15:8]),
     .data3x(PCwire), .sel(SW[2:1]), .result(HEX32_wire));

  mux4to1_8bit HEX54_mux(
     .data0x(reg1), .data1x(IR2_out), .data2x(reg1),
     .data3x(PCwire), .sel(SW[2:1]), .result(HEX54_wire));

  mux4to1_8bit HEX76_mux(
     .data0x(reg0), .data1x(IR1_out), .data2x(reg0),
     .data3x(PCwire), .sel(SW[2:1]), .result(HEX76_wire));

  /* Output */
  HEXs HEX_display(
     .in0(HEX76_wire), .in1(HEX54_wire),
     .in2(HEX32_wire), .in3(HEX10_wire),
     .out0(HEX0), .out1(HEX1), .out2(HEX2), .out3(HEX3),
     .out4(HEX4), .out5(HEX5), .out6(HEX6), .out7(HEX7));

  /* LED Indicators */
  assign LEDR[17] = PCWrite;
  assign LEDR[16] = Stop;
  assign LEDR[15] = MemRead;
  assign LEDR[14] = MemWrite;
  assign LEDR[13] = IR1Load;
  assign LEDR[12] = R1Sel;
  assign LEDR[11] = MDRLoad;
  assign LEDR[10] = R1R2Load;
  assign LEDR[9] = ALU1;
  assign LEDR[2] = ALUOutWrite;
  assign LEDR[1] = RFWrite;
  assign LEDR[0] = RegIn;
  assign LEDR[8:6] = ALU2[2:0];
  assign LEDR[5:3] = ALUOp[2:0];
  assign LEDG[6:2] = State;
  assign LEDG[7] = FlagWrite;
  assign LEDG[1] = N;
  assign LEDG[0] = Z;

endmodule
