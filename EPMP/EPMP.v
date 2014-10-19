`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:11:04 08/06/2009 
// Design Name: 
// Module Name:    EPMP 
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
module EPMP(clk, Reset, D, A, Read, Write, Debug_Run, Debug_Mode, Debug_State, Debug_ACC, Debug_C, Debug_MDR, Debug_AUX_R, Debug_IR, Debug_PC, Debug_CU_Out);
    input clk;
    input Reset;
    input Debug_Run ;
    input [1:0] Debug_Mode ;
    inout [7:0] D;
    output [15:0] A;
    output Read;
    output Write;
    output [4:0] Debug_State ;
    output [7:0] Debug_ACC;
    output [7:0] Debug_C;
    output [7:0] Debug_MDR;
    output [7:0] Debug_AUX_R;
    output [7:0] Debug_IR;
    output [15:0] Debug_PC;
    output [14:0] Debug_CU_Out;

wire [7:0] IBL ;
wire [7:0] IBH ;
wire [7:0] IR ;
wire [3:0] ALU_Cmd ;

EPMP_AUXR EPMP_AUXR_inst(
	.clk(clk), 
	.AuxR_Load_En(AuxR_Load_En), 
	.AuxR_Out_En(AuxR_Out_En), 
	.D(D), 
	.IBH(IBH),
	.Debug_AUX_R(Debug_AUX_R)
	);

EPMP_STACK EPMP_STACK_inst(
	.clk(clk),	
	.Reset(Reset), 
	.Pop_Stack(Pop_Stack), 
	.Push_Stack(Push_Stack), 
	.IBH(C),
	.IBL(IBL)
	);

EPMP_ALU EPMP_ALU_inst(
	.clk(clk), 
	.Reset(Reset), 
	.ALU_En(Debug_ALU_En), 
	.ACC_Out_En(ACC_Out_En), 
	.ALU_Cmd(ALU_Cmd), 
	.C(C), 
	.ACC_bus(IBL),
	.Debug_ACC(Debug_ACC)
	);

EPMP_CU EPMP_CU_inst(
	.Reset(Reset), 
	.C(C), 
	.clk(clk), 
	.IR(IR), 
	.ALU_Cmd(ALU_Cmd), 
	.PC_Out_En(PC_Out_En), 
	.Debug_PC_Load_En(Debug_PC_Load_En), 
	.PC_Load_En(PC_Load_En), 
	.PC_Inc_nLoad(PC_Inc_nLoad), 
	.IR_Load(IR_Load), 
	.Debug_ALU_En(Debug_ALU_En), 
	.ALU_En(ALU_En), 
	.ACC_Out_En(ACC_Out_En), 
	.MAR_Load(MAR_Load), 
	.Read(Read), 
	.Write(Write), 
	.MDR_XB_Load(MDR_XB_Load), 
	.MDR_IB_Load(MDR_IB_Load), 
	.MDR_XB_En(MDR_XB_En), 
	.MDR_IB_En(MDR_IB_En), 
	.AuxR_Load_En(AuxR_Load_En), 
	.AuxR_Out_En(AuxR_Out_En),
	.Push_Stack(Push_Stack),
	.Pop_Stack(Pop_Stack),
	.Debug_Run(Debug_Run),
	.Debug_Mode(Debug_Mode),
	.Debug_State(Debug_State)
	);

assign Debug_IR = IR ;

EPMP_IR EPMP_IR_inst(
	.clk(clk), 
	.IR_Load(IR_Load), 
	.IBL(IBL), 
	.IR(IR)
	);

EPMP_MAR EPMP_MAR_inst(
	.IBL(IBL), 
	.IBH(IBH), 
	.MAR_Load(MAR_Load), 
	.clk(clk), 
	.A(A)
	);

EPMP_MDR EPMP_MDR_inst(
	.clk(clk), 
	.MDR_XB_Load(MDR_XB_Load), 
	.MDR_IB_Load(MDR_IB_Load), 
	.MDR_XB_En(MDR_XB_En), 
	.MDR_IB_En(MDR_IB_En), 
	.D(D), 
	.IBL(IBL),
	.Debug_MDR(Debug_MDR)
	);

EPMP_PC EPMP_PC_inst(
	.clk(clk), 
	.Reset(Reset), 
	.PC_Load_En(Debug_PC_Load_En), 
	.PC_Inc_nLoad(PC_Inc_nLoad), 
	.PC_Out_En(PC_Out_En), 
	.IBH(IBH),
	.IBL(IBL),
	.Debug_PC(Debug_PC)
	);

assign Debug_CU_Out = {ALU_En,ACC_Out_En,IR_Load,AuxR_Out_En,AuxR_Load_En,MDR_IB_En,MDR_IB_Load,MDR_XB_En,
	MDR_XB_Load,Write,Read,MAR_Load,PC_Inc_nLoad,PC_Load_En,PC_Out_En};

assign Debug_C = C;
	
endmodule
