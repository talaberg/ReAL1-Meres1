`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:50:49 08/06/2009 
// Design Name: 
// Module Name:    board_level 
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
module board_level(clk, Reset, inport, outport, RxD, TxD, TxDdup, RxDdup);
    input clk;
    input Reset;
    input [2:0] inport;
    output reg [3:0] outport;
    output TxDdup, RxDdup;
    input RxD;
    output TxD;
assign RxDdup = RxD ;
assign TxDdup = TxD ;

// Processzor külsõ busz vezetékei
wire [7:0] D ;
wire [15:0] A ;
wire Write ;
wire Read ;
//wire [3:0] LED_state;

// Kommunikáció
wire [15:0]MB_Data;
wire [15:0]MB_Addr;
wire [7:0] RxBuf;
wire [7:0] TxBuf;
wire RxRdy;
wire Read_RxBuf;

// Debugger vezetékei
wire Debug_Run;
wire Write_Reg;
wire Debug_Reset;
wire [1:0]Debug_Mode;
wire [4:0]Debug_State;
wire [7:0]Debug_ACC;
wire [7:0]Debug_MDR;
wire [7:0]Debug_AUX_R;
wire [7:0]Debug_IR;
wire [15:0]Debug_PC;
wire [14:0]Debug_CU_Out;

// Select memory in the lower 32k
assign En = !A[15] ;

// Read input port in the higher 32k and read active
assign D = (A[15]&Read) ? {5'b0,inport} : 8'bZ ;

// Write output port in the higher 32k and write active
always @ (posedge clk)
	if (Reset)
		outport <= 0;
	else
	if (A[15] & Write)
		outport <= D[3:0] ;
		
RAM RAM_inst(
	.clk(clk), 
	.A(A[10:0]), 
	.D(D), 
	.Read(Read), 
	.Write(Write), 
	.En(En),
	.Debug_A(MB_Addr[10:0]), 
	.Debug_D(MB_Data[7:0]), 
	.Debug_Read(Read_Reg), 
	.Debug_Write(Write_Reg), 
	.Debug_En(MB_Addr[15:11]==0));
	
EPMP EPMP_inst(
	.clk(clk), 
	.Reset(Reset|Debug_Reset), 
	.D(D), 
	.A(A), 
	.Read(Read), 
	.Write(Write),
	.Debug_Run(Debug_Run), 
	.Debug_Mode(Debug_Mode), 
	.Debug_State(Debug_State), 
	.Debug_ACC(Debug_ACC), 
	.Debug_C(Debug_C), 
	.Debug_MDR(Debug_MDR), 
	.Debug_AUX_R(Debug_AUX_R), 
	.Debug_IR(Debug_IR), 
	.Debug_PC(Debug_PC), 
	.Debug_CU_Out(Debug_CU_Out));

Debugger Debugger_inst(
	.clk(clk), 
	.Reset(Reset),
	.D(D), 
	.A(A), 
	.Read_Reg(Read_Reg), 
	.Write_Reg(Write_Reg), 
	.MB_Data(MB_Data), 
	.MB_Addr(MB_Addr),	
	.Debug_Run(Debug_Run), 
	.Debug_Reset(Debug_Reset),
	.Debug_Mode(Debug_Mode), 
	.Debug_State(Debug_State), 
	.Debug_ACC(Debug_ACC), 
	.Debug_C(Debug_C), 
	.Debug_MDR(Debug_MDR), 
	.Debug_AUX_R(Debug_AUX_R), 
	.Debug_IR(Debug_IR), 
	.Debug_PC(Debug_PC), 
	.Debug_CU_Out(Debug_CU_Out));

ModBusASCII ModBusASCII_inst(
	.clk(clk), 
	.Reset(Reset), 
	.RxBuf(RxBuf), 
	.RxRdy(RxRdy), 
	.RxErr(RxErr), 
	.TxBuf(TxBuf), 
	.TxEmpty(TxEmpty), 
	.Read_RxBuf(Read_RxBuf), 
	.Write_TxBuf(Write_TxBuf), 
	.Read_Reg(Read_Reg), 
	.Write_Reg(Write_Reg), 
	.MB_Data(MB_Data), 
	//.LED_state(LED_state),
	.MB_Addr(MB_Addr));

UART UART_inst(
	.clk(clk), 
	.Reset(Reset), 
	.RxD(RxD), 
	.TxD(TxD), 
	.RxBuf(RxBuf), 
	.RxRdy(RxRdy),
	.RxErr(RxErr),	
	.TxBuf(TxBuf), 
	.Read_RxBuf(Read_RxBuf), 
	.Write_TxBuf(Write_TxBuf),
	.TxEmpty(TxEmpty));

endmodule
