// Revision Date:    2022.05.05
// Design Name:    BasicProcessor
// Module Name:    TopLevel 
// CSE141L -- partial only										   
module top_level(		   // you will have the same 3 ports
    input        init,	   // init/reset, active high
			     req,    // start next program
	             clk,	   // clock -- posedge used inside design
    output logic ack	   // done flag from DUT
    );

// program counter / instructon fetch connections
wire [ 3:0] TargSel; 	   // for branch LUT select
wire [ 9:0] PgmCtr,        // program counter (wider if you wish)
			PCTarg;
wire [ 8:0] Instruction;   // our 9-bit opcode

// data path connections -- everything is 8 bits wide
wire [ 7:0] ReadA, ReadB;  // reg_file outputs
wire [ 7:0] InA, InB, 	   // ALU operand inputs
            ALU_out;       // ALU result
wire [ 7:0] RegWriteValue, // data in to reg file
            MemWriteValue, // data in to data_memory
	   	    MemReadValue,  // data out from data_memory
			DatMemAddr  ,  // 
            Immediate;     //

// control wires  
wire        Imm,           // inserts Immediate into ALU
            MemWrite,	   // data_memory write enable
			RegWrEn,	   // reg_file write enable
			Zero,		   // ALU output = 0 flag
//			Neg,			// ALU negative flag
            Jump,	       // to program counter: jump 
            BranchEn;	   // to program counter: branch enable
// ALU status register, analogous to ARM
logic       PFq,           // delayed/stored parity bit from ALU
            SCq,           // delayed/stored shift-carry out flag 
				odd,				// odd flag
				Zq;            // delayed/stored null out flag from ALU
//				
logic clr;	// reset register value
	logic parity_check;

//logic[3:0] lfsrSel;	// select one LFSR out of 9
//logic[6:0] LFSR_state;
				
logic[15:0] CycleCt;	   // standalone; NOT PC!

	LUT LUT1(.Addr         (TargSel ) ,
           .Target       (PCTarg  )
    );
	 	

	assign clr = Instruction[8:6]==3'b010;
// Fetch stage = Program Counter + Instruction ROM
// "InstFetch" = PC register + branch/increment logic
  InstFetch IF1 (		       // this is the program counter module
	.Reset        (init   ) ,  // reset to 0
	.Start        (req   ) ,  // SystemVerilog shorthand for .grape(grape) is just .grape 
	.Clk          (clk     ) ,  //    here, (Clk) is required in Verilog, optional in SystemVerilog
	.BranchAbs    (Jump    ) ,  // jump enable
	.BranchRelEn  (BranchEn) ,  // branch enable
	.ALU_flag	  (Zq   ) ,  // 
 .Target       (PCTarg  ) ,  // "where to?" or "how far?" during a jump or branch
	.ProgCtr      (PgmCtr  )	   // program count = index to instruction memory
	);					  

	

// instruction ROM -- holds the machine code selected by program counter
// don't change W(9); increase A(10) if your machine code exceeds 1K lines 
  InstROM #(.A(10),.W(9)) IR1(
	.InstAddress  (PgmCtr     ) , 
	.InstOut      (Instruction)
	);

// Decode stage = Control Decoder + Reg_file
// Control decoder
  Ctrl Ctrl1 (
	.Instruction  (Instruction) ,  // from instr_ROM
	.Zero				(Zq)		,
// outputs
	.Branch         (Jump       ) ,  // to PC to handle jump/branch instructions
	.BranchEn     (BranchEn   )	,  // to PC
	.RegWrEn      (RegWrEn    )	,  // register file write enable
	.MemWrEn      (MemWrite   ) ,  // data memory write enable
    .LoadInst     (LoadInst   ) ,  // selects memory vs ALU output as data input to reg_file
    .PCTarg       (TargSel    ) ,    
	.tapSel       (tapSel     ) ,
	.parity_check (parity_check),
	.DatMemAddr   (DatMemAddr ) , 
    .Ack          (ack        )	   // "done" flag
  );

// reg file	-- don't change W(8); may increase to D(4) 
// I arbitrarily mapped to Instructon fields [5:3] and [2:0]
//   you do not have to do this!!!
	RegFile #(.W(8),.D(3)) RF1 (			  // D(3) makes this 8 elements deep
		.Clk		  (clk)	,
		.Reset	  (init),
		.clr			(clr),
		.parity_flg (PFq),	
		.WriteEn   (RegWrEn)    , 
		.RaddrA    (Instruction[5:3]),  // 00 = r0, 10 = r2
		.RaddrB    (Instruction[2:0]), 	// 01 = r1, 11 = r3
// by choosing Waddr = RaddrA, I am doing write-in-place operations
//    such as A = A+B, as opposed to C = A+B
		.Waddr     (Instruction[5:3]), 	// == RaddrA      // mux above
		.DataIn    (RegWriteValue) , 
		.DataOutA  (ReadA        ) , 
		.DataOutB  (ReadB		 )
	);

	
	
	assign InA = ReadA;
	assign InB = ReadB;	          			  // interject switch/mux if needed/desired
   assign MemWriteValue = ReadA;
// controlled by Ctrl1 -- must be high for load from data_mem; otherwise usually low
	assign RegWriteValue = LoadInst? MemReadValue : ALU_out;  // 2:1 switch into reg_file

	assign DatMemAddr = ReadB;
//	

	
	logic PF;	// parity flag
    ALU ALU1  (
	  .InputA  (InA),	 //(ReadA),
	  .InputB  (InB), 
	  .OP      (Instruction[8:6]),
	  .parity_check (parity_check),
	  .SC_in   (PFq),	 // registered version of output flag
	  .Out     (ALU_out),//regWriteValue),
	  .Zero	   (Zero),   // null output status flag
      .Parity      (PF),	 // output parity status flag
		.Odd		(odd),
//		.Neg		(Neg),
	  .SC_out  (SCout)  // shift/carry output flag
	  );				 // other flags as desired?

	  

// equiv. to ARM ALU status register
//   store flags for next clock cycle
   always @(posedge clk) begin
     SCq <= SCout;  
     PFq <= Zero&parity_check;
     Zq  <= Zero;

   end

  
	DataMem DM(
		.DataAddress  (DatMemAddr)    , 
		.WriteEn      (MemWrite), 
		.DataIn       (MemWriteValue), 
		.DataOut      (MemReadValue)  , 
		.Clk 		  (clk)		     ,
		.Reset		  (init)
	);

	

/* count number of instructions executed
      not part of main design, potentially useful
      This one halts when Ack is high  
*/


always_ff @(posedge clk)
  if (init == 1)	   // if(start)
  	CycleCt <= 0;
  else if(ack == 0)   // if(!halt)
  	CycleCt <= CycleCt+16'b1;

endmodule