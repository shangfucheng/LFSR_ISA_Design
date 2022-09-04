// CSE141L
import Definitions::*;
// control decoder (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
module Ctrl (
  input[ 8:0]   Instruction,	   // machine code
  input[ 7:0]   DatMemAddr,
  input			Zero		  , 
  output logic  Branch    ,
					parity_check,
                BranchEn  ,
			    RegWrEn   ,	   // write to reg_file (common)
			    MemWrEn   ,	   // write to mem (store only)
			    LoadInst  ,	   // mem or ALU to reg_file ?
			    tapSel    ,
				 
			    Ack		  ,      // "done w/ program"
  output logic[3:0] PCTarg
//  output logic[2:0]  ALU_inst
  );

/* ***** All numerical values are completely arbitrary and for illustration only *****
*/

// alternative -- case format
//always_comb	begin
//// list the defaults here
//	Branch    = 'b0;
//	BranchEn  = 'b0;
//	RegWrEn   = 'b1; 
//	MemWrEn   = 'b0;
//	LoadInst  = 'b0;
//	TapSel    =	'b0;     
//	PCTarg    = 'b0;  
//	if(Instruction[8]) begin	// Branch Condition check	
//		if(Instruction[7:6]==2'b00) PCTarg = (Instruction[5] | Instruciton[4])? Instruction[2:1]:'b0;	// BLE
//		else if(Instruction[7:6]==2'b01) PCTarg = (Instruction[5] || !Instruciton[4])? Instruction[2:1]:'b0;	//BGE
//		else if(Instruction[7:6]==2'b10) PCTarg = (!Instruction[5] || Instruciton[4])? Instruction[2:1]:'b0;	// BLT
//		else if(Instruction[7:6]==2'b11) PCTarg = (!Instruction[5] || !Instruciton[4])? Instruction[2:1]:'b0;	// BGT
//		else PCTarg = 'b0;	// branch fail, continue;
//	end
//	else begin
//		Ack = Instruction == 'b111_000_111;
//		MemWrEn = Instruction[7:5]==3'b011;	// opcode == ldr, 011 in definitions
//		RegWrEn = Instruction[7:5]!=3'b011;
//		LoadInst = Instruction[7:5]==3'b110;  // calls out load specially
//		TapSel = LoadInst &&	 DatMemAddr=='d62;
//		Branch = Instruction[8];
//	end
//   // branch "where to?"
////   case(Instruction[7:6])  // list just the exceptions 
////     2'b00:   begin
////                  MemWrEn = 'b1;   // store, maybe
////				  RegWrEn = 'b0;
////			   end
////     2'b01:   LoadInst = 'b1;  // load
////     2'b10:   begin end
////     2'b11:   begin end
////
////// no default case needed -- covered before "case"
////   endcase
//end

assign Ack = Instruction == 'b111111111;
// alternative Ack = Instruction == 'b111_000_111

// ALU commands
//assign ALU_inst = Instruction[2:0]; 

// STR commands only -- write to data_memory
assign MemWrEn = Instruction[8:6]==3'b101;	// opcode == str, 101 in definitions

// all but STR and NOOP (or maybe CMP or TST) -- write to reg_file
assign RegWrEn = (Instruction[8:6]!=3'b101) & (Instruction[8:6]!=3'b110) & (Instruction[8:6]!=3'b011);

// route data memory --> reg_file for loads
//   whenever instruction = 9'b110??????; 
assign LoadInst = Instruction[8:6]==3'b100;  // calls out load specially

assign tapSel = LoadInst && DatMemAddr=='d62;
// jump enable command to program counter / instruction fetch module on right shift command
// equiv to simply: assign Jump = Instruction[2:0] == RSH;

// absoolute branch enable, branch every time instruction = 9'b1????????;
always_comb Branch = Instruction[8:6]==3'b011; // && !Zero;

// relative branch, will not use.
assign BranchEn = 'b0;

always_comb parity_check = (Instruction[8:6] == 3'b111) & (Instruction[5:3] == Instruction[2:0]);

// whenever branch or jump is taken, PC gets updated or incremented from "Target"
//  PCTarg = 2-bit address pointer into Target LUT  (PCTarg in --> Target out
// Branch::  8=1, 7-6 = branch condition, 5 = zero flag, 4 = negative flag, 3 = parity flag, 2-1 = branch LUT ptr, 0 = can not branch
always_comb begin
	if(Branch) begin	// Branch Condition check	
		PCTarg = Instruction[3:0];
	end
	else begin
		PCTarg = 'b0; // PgmCtr + 'b1;
	end
end

// assign PCTarg  = Instruction[3:2];

// reserve instruction = 9'b111111111; for Ack
//assign Ack = &Instruction; // = ProgCtr == 385;

endmodule

