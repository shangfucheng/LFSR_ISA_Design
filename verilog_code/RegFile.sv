// Create Date:    2019.01.25
// Design Name:    CSE141L
// Module Name:    reg_file 
// Revision:       2022.05.04
// Additional Comments: 	allows preloading with user constants
// This version is fully synthesizable and highly recommended.

/* parameters are compile time directives 
       this can be an any-width, any-depth reg_file: just override the params!
*/
module RegFile #(parameter W=8, D=3)(		 // W = data path width (leave at 8); D = address pointer width
  input                Clk,
                       Reset,	             // note use of Reset port
                       WriteEn,
							  clr,
							  parity_flg,
  input        [D-1:0] RaddrA,				 // address pointers
                       RaddrB,
                       Waddr,
  input        [W-1:0] DataIn,
  output       [W-1:0] DataOutA,			 // showing two different ways to handle DataOutX, for
  output logic [W-1:0] DataOutB				 //   pedagogic reasons only
    );

// W bits wide [W-1:0] and 2**4 registers deep 	 
logic [W-1:0] Registers[2**D];	             // or just registers[16] if we know D=4 always

// combinational reads 
/* can use always_comb in place of assign
    difference: assign is limited to one line of code, so
	always_comb is much more versatile     
*/
assign      DataOutA = Registers[RaddrA];	 // assign & always_comb do the same thing here 
always_comb DataOutB = Registers[RaddrB];    // can read from addr 0, just like ARM

// sequential (clocked) writes 
always_ff @ (posedge Clk) begin
  if (Reset) begin
	for(int i=0; i<2**D; i++)
	  Registers[i] <= 'h0;
// we can override this universal clear command with desired initialization values
	Registers[0] <= 'd61;	// r0 for program 1
	Registers[1] <= 'd1;		// r1 = 1
	Registers[2] <= 'd0;		// r2 = 0
	Registers[3] <= 'd128;                  // r3 for program 1
//	Reigsters[3] <= 'd10;			// r3 for program 2
	Registers[4] <= 'd64;       // R4 = 73 for program 2
	Registers[5] <= 'd73;                   // R5 = 0
	Registers[6] <= 'h00;						// r6 = space
	Registers[7] <= 'd1;
	end
  else if(clr) begin
  	 Registers[2] <= 'd0;		// r2 = 0
	 Registers[4] <= 'd64;
	 Registers[5] <= 'd73;
	 Registers[6] <= 'h00;
  end
  else if (WriteEn) begin	        // works just like data_memory writes
	 Registers[Waddr] <= DataIn;
  end
 end
endmodule
