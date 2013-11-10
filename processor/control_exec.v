/******************************************************************************
 * File: control_exec.v
 * Author: ECE352 development team, Patrick Payne, Alex Papanicolaou
 * Date Created: Original 2007, modifications November 2013
 * Purpose: Implements the control of the multicycle processor. See project
 *    documentation for details.
 *****************************************************************************/
 
 module control_exec (
     input [3:0] instr,
     output reg ir3_load, mem_read, mem_write, mdr_load,
     output reg flag_write, stop,
     output reg alu_2, alu_op, alu_out_write);
     
  /* Define constants for the different possible opcodes. */
  parameter [2:0] i_shift = 3, i_ori = 7;
  parameter [3:0] i_add = 4, i_subtract = 6, i_nand = 8, i_load = 0,
	  i_store = 2, i_nop = 10, i_stop = 1;
    
  /* Define constants for different ALU operation modes. */
  parameter [2:0] aluop_add = 3'b000, aluop_sub = 3'b001, aluop_or = 3'b010,
      aluop_nand = 3'b011, aluop_shift = 3'b100;

  /* Define constants for the ALU1 mux inputs. */
  parameter [2:0] ALU2_R2 = 3'b000, ALU2_1 = 3'b001, ALU2_IMM4 = 3'b010,
      ALU2_IMM5 = 3'b011, ALU2_IMM3 = 3'b100;
  
  always @(*) begin
    if(instr[2:0] == i_shift) begin
      mem_read = 0;
      mem_write = 0;
      mdr_load = 0;
      alu_2 = ALU2_IMM3;
      alu_op = aluop_shift;
      alu_out_write = 1;
      ir3_load = 1;
      flag_write = 1;
    end
    else if(instr[2:0] == i_ori) begin
      mem_read = 0;
      mem_write = 0;
      mdr_load = 0;
      alu_2 = ALU2_IMM5;
      alu_op = aluop_or;
      alu_out_write = 1;
      ir3_load = 1;
      flag_write = 1;
    end
    else if(instr == i_add) begin
      mem_read = 0;
      mem_write = 0;
      mdr_load = 0;
      alu_2 = ALU2_R2;
      alu_op = aluop_add;
      alu_out_write = 1;
      ir3_load = 1;
      flag_write = 1;
    end
    else if(instr == i_subtract) begin
      mem_read = 0;
      mem_write = 0;
      mdr_load = 0;
      alu_2 = ALU2_R2;
      alu_op = aluop_sub;
      alu_out_write = 1;
      ir3_load = 1;
      flag_write = 1;
    end
    else if(instr == i_nand) begin
      mem_read = 0;
      mem_write = 0;
      mdr_load = 0;
      alu_2 = ALU2_R2;
      alu_op = aluop_nand;
      alu_out_write = 1;
      ir3_load = 1;
      flag_write = 1;
    end
    else if(instr == i_load) begin
      mem_read = 1;
      mem_write = 0;
      mdr_load = 1;
      alu_2 = ALU2_R2;
      alu_op = aluop_or;
      alu_out_write = 0;
      ir3_load = 1;
      flag_write = 0;
    end
    else if(instr == i_store) begin
      mem_read = 0;
      mem_write = 1;
      mdr_load = 0;
      alu_2 = ALU2_R2;
      alu_op = aluop_or;
      alu_out_write = 0;
      ir3_load = 1;
      flag_write = 0;
    end
    else if(instr == i_nop) begin
      mem_read = 0;
      mem_write = 0;
      mdr_load = 0;
      alu_2 = ALU2_R2;
      alu_op = aluop_or;
      alu_out_write = 0;
      ir3_load = 1;
      flag_write = 0;
    end
    else if(instr == i_stop) begin
      mem_read = 0;
      mem_write = 0;
      mdr_load = 0;
      alu_2 = ALU2_R2;
      alu_op = aluop_or;
      alu_out_write = 0;
      ir3_load = 0;
      flag_write = 0;
    end
    else begin
      mem_read = 0;
      mem_write = 0;
      mdr_load = 0;
      alu_2 = ALU2_R2;
      alu_op = aluop_or;
      alu_out_write = 0;
      ir3_load = 1;
      flag_write = 0;
    end
  end
endmodule