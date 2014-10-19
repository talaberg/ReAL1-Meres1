`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:12:11 08/05/2009 
// Design Name: 
// Module Name:    EPMP_CU 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module EPMP_CU(Reset, C, clk, IR, ALU_Cmd, PC_Out_En, Debug_PC_Load_En, PC_Load_En, PC_Inc_nLoad, IR_Load, Debug_ALU_En, ALU_En, ACC_Out_En, MAR_Load, Read, Write, MDR_XB_Load, MDR_IB_Load, MDR_XB_En, MDR_IB_En, AuxR_Load_En, AuxR_Out_En,Debug_Run,Debug_Mode,Push_Stack,Pop_Stack,Debug_State);
    input Reset;
    input C;
    input clk;
    input [7:0] IR;
    input Debug_Run;
    input [1:0] Debug_Mode;
    output [3:0] ALU_Cmd;
    output PC_Out_En;
    output PC_Load_En;
    output Debug_PC_Load_En;  // At single steps remove the continuos enable from HW
    output PC_Inc_nLoad;
    output IR_Load;
	 output ALU_En;
	 output Debug_ALU_En; // At single steps remove the continuos enable from HW
    output ACC_Out_En;
    output MAR_Load;
    output Read;
    output Write;
    output MDR_XB_Load;
    output MDR_IB_Load;
    output MDR_XB_En;
    output MDR_IB_En;
    output AuxR_Load_En;
    output AuxR_Out_En;
	output Push_Stack;//Hozzáadva Push-pop stack
	output Pop_Stack;
    output [4:0] Debug_State;

wire [3:0] IR_Group;
wire [3:0] IR_Sub ;
reg [4:0] state ;

// Definitions of instruction groups
`define	GroupLoad 0
`define	GroupStore 1
`define	GroupInternal 2
`define	GroupJump 3
`define	GroupPushPop 4

// Definitions for sub-codes
`define	InstCJump 1
`define	Pop 1
`define	Push 2

// Outputs of CU are generated automatic in "State machine plan.xls"
`include "DefineStates.vh"

// Debug modes
// continuous_run 0
`define	istep	1					//	instruction step
`define	mstep	2					//	memory access step
`define	ustep	3					//	1 clock 

// Outputs of CU are generated automatic in "State machine plan.xls"
`include "assign_CU_outputs.vh"

assign Execution_enabled = Debug_Run || ((Debug_Mode==`istep)&&(state!=`StFetch2)) || ((Debug_Mode==`mstep)&&(Read==0)&&(Write==0)) ;
assign Debug_PC_Load_En = Execution_enabled && PC_Load_En ;
assign ALU_En = ((state==`StExecInst)&&(IR_Group==`GroupInternal)) || (state==`StExecData) || (state==`Pop1);
assign Debug_ALU_En = Execution_enabled && ALU_En;

assign IR_Group = IR[7:4] ;
assign IR_Sub = IR[3:0] ;
assign ALU_Cmd = IR[3:0] ;

assign Debug_State = state ;

always @ (posedge clk)
	if (Reset)
		state <= `StFetch0 ;
	else
    if (Execution_enabled)
		case (state)
		  `StExecInst : begin
			  if (IR_Group==`GroupInternal)
				 state <= `StFetch0 ; // No additional states needed
			  else if ((IR_Group==`GroupJump) && (IR_Sub==`InstCJump) && !C)
				 state <= `StJumpNC1 ; // Conditional jump not taken
			
			  else if ((IR_Group==`GroupPushPop) && (IR_Sub==`Pop))//hozzáadva
				state <= `StPop1 ;
				
			  else if ((IR_Group==`GroupPushPop) && (IR_Sub==`Push))//hozzáadva
				state <= `StPush1 ;
				
			  else
				 state <= state+1 ;
			  end
		  `StRead5 :
			  if (IR_Group==`GroupJump)
				 state <= `StJump1 ;
			  else
				 state <= state+1 ;
		  `StRead6 : begin
			  if (IR_Group==`GroupStore)
				 state <= `StWrite1 ;
			  else if (IR_Group==`GroupJump)
				 state <= `StJump1 ;
			  else
				 state <= state+1 ;
			  end
		  `StExecData : 
			  state <= `StFetch0 ;
		  `StWrite2 : 
			  state <= `StFetch0 ;
		  `StJump1 : 
			  state <= `StFetch0 ;
		  `StJumpNC2 : 
			  state <= `StFetch0 ;
		  `StPop1 : 
			  state <= `StFetch0 ;//hozzáadva
		  `StPush1 : 
			  state <= `StFetch0 ;//hozzáadva
		  default: // States without decisions, just take the next step
			 state <= state+1 ;
		endcase

endmodule
