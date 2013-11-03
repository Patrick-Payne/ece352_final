/******************************************************************************
 * File: FSM.v
 * Author: ECE243 development team, Patrick Payne, Alex Papanicolaou
 * Date Created: Original 2007, modifications November 2013
 * Purpose: Implements the control of the multicycle processor. See project
 *    documentation for details.
 * Original file Copyright (c) 2007 by University of Toronto ECE 243
 * development team.
 *****************************************************************************/

module FSM (
    input reset, clock, N, Z,
    input [3:0] instr,
    //output [3:0] state,
    output reg PCwrite, MemRead, MemWrite, IRload, R1Sel, MDRload,
    output reg R1R2Load, ALU1, ALUOutWrite, RFWrite, RegIn, FlagWrite,
    output reg [2:0] ALU2, ALUop);

  /* The 4 bit number representing the state of the control. */
  reg [3:0] state;
 
  /* state constants (note: asn = add/sub/nand, asnsh = add/sub/nand/shift) */
  parameter [3:0] reset_s = 0, c1 = 1, c2 = 2, c3_asn = 3, c4_asnsh = 4,
     c3_shift = 5, c3_ori = 6, c4_ori = 7, c5_ori = 8, c3_load = 9,
     c4_load = 10, c3_store = 11, c3_bpz = 12, c3_bz = 13, c3_bnz = 14;
  
  parameter [2:0] i_shift = 3, i_ori = 7;
  
  parameter [3:0] i_add = 4, i_subtract = 6, i_nand = 8, i_load = 0,
	  i_store = 2, i_bpz = 13, i_bz = 5, i_bnz = 9, i_nop = 10, i_stop = 1;

  /* determines the next state based upon the current state; supports
   * asynchronous reset.
   */
  always @(posedge clock or posedge reset) begin
    if (reset)
      state = reset_s;
    else begin
      case(state)
        reset_s: state = c1; // reset state
        c1: state = c2; // cycle 1
        c2: begin // cycle 2
          if(instr == i_add | instr == i_subtract | instr == i_nand)
            state = c3_asn;
          else if(instr[2:0] == i_shift) state = c3_shift;
          else if(instr[2:0] == i_ori) state = c3_ori;
          else if(instr == i_load) state = c3_load;
          else if(instr == i_store) state = c3_store;
          else if(instr == i_bpz) state = c3_bpz;
          else if(instr == i_bz) state = c3_bz;
          else if(instr == i_bnz) state = c3_bnz;
			 else if(instr == i_nop) state = c1;
          else state = 0;
        end
        c3_asn: state = c4_asnsh; // cycle 3: ADD SUB NAND
        c4_asnsh: state = c1; // cycle 4: ADD SUB NAND/SHIFT
        c3_shift: state = c4_asnsh; // cycle 3: SHIFT
        c3_ori: state = c4_ori; // cycle 3: ORI
        c4_ori: state = c5_ori; // cycle 4: ORI
        c5_ori: state = c1; // cycle 5: ORI
        c3_load: state = c4_load; // cycle 3: LOAD
        c4_load: state = c1; // cycle 4: LOAD
        c3_store: state = c1; // cycle 3: STORE
        c3_bpz: state = c1; // cycle 3: BPZ
        c3_bz: state = c1; // cycle 3: BZ
        c3_bnz: state = c1; // cycle 3: BNZ
      endcase
    end
  end

  /* Set the control sequences based upon the current state and instruction. */
  always @(*) begin
    case (state)
      reset_s: begin //control = 19'b0000000000000000000;
        PCwrite = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
      end     
      c1: begin  //control = 19'b1110100000010000000;
        PCwrite = 1;
        MemRead = 1;
        MemWrite = 0;
        IRload = 1;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b001;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
      end 
      c2: begin //control = 19'b0000000100000000000;
        PCwrite = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 1;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
      end
      c3_asn:  begin
        if (instr == i_add) begin // add, control = 19'b0000000010000001001;
          PCwrite = 0;
          MemRead = 0;
          MemWrite = 0;
          IRload = 0;
          R1Sel = 0;
          MDRload = 0;
          R1R2Load = 0;
          ALU1 = 1;
          ALU2 = 3'b000;
          ALUop = 3'b000;
          ALUOutWrite = 1;
          RFWrite = 0;
          RegIn = 0;
          FlagWrite = 1;
        end 
        else if (instr == i_subtract) begin //sub, ctl = 19'b0000000010000011001;
          PCwrite = 0;
          MemRead = 0;
          MemWrite = 0;
          IRload = 0;
          R1Sel = 0;
          MDRload = 0;
          R1R2Load = 0;
          ALU1 = 1;
          ALU2 = 3'b000;
          ALUop = 3'b001;
          ALUOutWrite = 1;
          RFWrite = 0;
          RegIn = 0;
          FlagWrite = 1;
        end
        else begin // nand, control = 19'b0000000010000111001;
          PCwrite = 0;
          MemRead = 0;
          MemWrite = 0;
          IRload = 0;
          R1Sel = 0;
          MDRload = 0;
          R1R2Load = 0;
          ALU1 = 1;
          ALU2 = 3'b000;
          ALUop = 3'b011;
          ALUOutWrite = 1;
          RFWrite = 0;
          RegIn = 0;
          FlagWrite = 1;
        end
      end
      c4_asnsh: begin //control = 19'b0000000000000000100;
        PCwrite = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 1;
        RegIn = 0;
        FlagWrite = 0;
      end
      c3_shift: begin //control = 19'b0000000011001001001;
        PCwrite = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 1;
        ALU2 = 3'b100;
        ALUop = 3'b100;
        ALUOutWrite = 1;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 1;
      end
      c3_ori: begin //control = 19'b0000010100000000000;
        PCwrite = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 1;
        MDRload = 0;
        R1R2Load = 1;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
      end
      c4_ori: begin //control = 19'b0000000010110101001;
        PCwrite = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 1;
        ALU2 = 3'b011;
        ALUop = 3'b010;
        ALUOutWrite = 1;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 1;
      end
      c5_ori: begin //control = 19'b0000010000000000100;
        PCwrite = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 1;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 1;
        RegIn = 0;
        FlagWrite = 0;
      end
      c3_load: begin //control = 19'b0010001000000000000;
        PCwrite = 0;
        MemRead = 1;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 1;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
      end
      c4_load: begin //control = 19'b0000000000000001110;
        PCwrite = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 1;
        RFWrite = 1;
        RegIn = 1;
        FlagWrite = 0;
      end
      c3_store: begin //control = 19'b0001000000000000000;
        PCwrite = 0;
        MemRead = 0;
        MemWrite = 1;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
      end
      c3_bpz: begin //control = {~N,18'b000000000100000000};
        PCwrite = ~N;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b010;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
      end
      c3_bz: begin //control = {Z,18'b000000000100000000};
        PCwrite = Z;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b010;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
      end
      c3_bnz: begin //control = {~Z,18'b000000000100000000};
        PCwrite = ~Z;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b010;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
      end
      default: begin //control = 19'b0000000000000000000;
        PCwrite = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
      end
    endcase
  end

endmodule
