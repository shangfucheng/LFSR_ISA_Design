/* CSE141L
   possible lookup table for PC target
   leverage a few-bit pointer to a wider number
   Lookup table acts like a function: here Target = f(Addr);
 in general, Output = f(Input); lots of potential applications 
*/
module LUT(
  input       [ 3:0] Addr,
  output logic[ 9:0] Target
  );

always_comb begin
  Target = 10'h001;	   // default to 1 (or PC+1 for relative)
  case(Addr)		   
	4'b0000:   Target = 10'd8;   //program 1
	4'b0001:	 Target = 10'd14;	// program 1
	4'b0010:	 Target = 10'd4;	// program 2
	4'b0011:	Target = 10'd0;	// program 2
	4'b0100:   Target = 10'd13;	// program 2, 3
	4'b0101:  Target = 10'd20;	// program 3b 21 ..... program 3a 20
	4'b1010:  Target = 10'd21; // program 3b
	4'b0110:   Target = 10'd22;	// program 3b 26 ..... program 3a 22
	4'b1011:	  Target = 10'd26;	// program 3b
	4'b0111:   Target = 10'd25;	// program 3_2 25 // 22 for p3_1
	4'b1000:   Target = 10'd32;		// program 3
	4'b1001:   Target = 10'd34;	// program 3
//	default: Target = 10'h001;
  endcase
end

endmodule


			 // 3fc = 1111111100 -4
			 // PC    0000001000  8
			 //       0000000100  4  
			 
// find correct tap pattern, at last preamable, use 'h20^mem[73] == curr_LFSR(r0)??
			 
//	AOL lfsr tap
// 23 str lfsr^msg
//1 CLR             // reset r4 to 64
//  2 LDR r7 r3       // r3 = 128, r7 = tap pattern
//  3 ADD r3 r1       // r3++, to load next tap
//  4 LDR r0 r4       // r4 = 64, r0 = start state
//  5 LDR r6 r4       // r6 = space
//  6 XOR r6 r0
//  7 AOL r0 r7       // AOL start state, tap pattern
//  8 STR r6 r2       // store decrypted msg to 0-61
//  9 ADD r4 r1
// 10 ADD r2 r1       // r2++
// 11 CMP r2 r5       // cmp with 74 for now
// 12 BNE 100         // 100 = line 9

