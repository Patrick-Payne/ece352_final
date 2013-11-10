/******************************************************************************
 * File: control_fetch.v
 * Author: Patrick Payne
 * Date Created: Nov 09, 2013
 * Purpose: Implements the control circuitry for the fetch stage of the
 *  pipelined processor. The fetch stage controls the PCSel, PCWrite, and
 *  IR1load signals. It also accepts an input control signal for loading a
 *  target address from a branch instruction.
 *****************************************************************************/

module control_fetch (
    input branch, en_fetch,
    input [3:0] opcode,
    output reg pc_write, pc_sel, ir1_load);

  /* Define constants for the different possible opcodes. */
  parameter [2:0] i_shift = 3, i_ori = 7;
  parameter [3:0] i_add = 4, i_subtract = 6, i_nand = 8, i_load = 0,
	  i_store = 2, i_bpz = 13, i_bz = 5, i_bnz = 9, i_nop = 10, i_stop = 1;

  always @(*) begin 
    if ((opcode == i_stop) | (~en_fetch)) begin
      pc_write = 0;
      pc_sel = 0;
      ir1_load = 0;
    end
    else begin
      pc_sel = branch;
      pc_write = 1;
      ir1_load = 1;
    end
  end
endmodule
