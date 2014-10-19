`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:29:15 08/18/2009 
// Design Name: 
// Module Name:    Debugger 
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
module Debugger(clk, Reset, Read_Reg, Write_Reg, MB_Data, MB_Addr, D, A, Debug_Run, Debug_Reset, Debug_Mode, Debug_State, Debug_ACC, Debug_C, Debug_MDR, Debug_AUX_R, Debug_IR, Debug_PC, Debug_CU_Out);
    input clk;
    input Reset;
    input [7:0]D;
    input [15:0]A;
    input Read_Reg, Write_Reg;
    inout [15:0] MB_Data;
    input [15:0] MB_Addr;
    output reg Debug_Run=1;
    output reg Debug_Reset=0;
    output reg [1:0] Debug_Mode=0;
    input [4:0] Debug_State;
    input [7:0] Debug_ACC;
    input Debug_C;
    input [7:0] Debug_MDR;
    input [7:0] Debug_AUX_R;
    input [7:0] Debug_IR;
    input [15:0] Debug_PC;
    input [14:0] Debug_CU_Out;

reg [15:0] Read_Data ;

assign MB_Data = (Read_Reg && (MB_Addr[15:8]==8'hff)) ? Read_Data:16'bZ ;
always @(MB_Addr[2:0], A, D, Debug_ACC, Debug_C, Debug_MDR, Debug_AUX_R, Debug_State, Debug_IR, Debug_PC, Debug_CU_Out)
		case (MB_Addr[2:0])
         3'd0: Read_Data = A ;
         3'd1: Read_Data = {8'b0,D} ;
         3'd2: Read_Data = {7'b0,Debug_C,Debug_ACC} ;
         3'd3: Read_Data = {Debug_AUX_R,Debug_MDR} ;
         3'd4: Read_Data = {3'b0,Debug_State,Debug_IR} ;
         3'd5: Read_Data = Debug_PC ;
         3'd6: Read_Data = {0,Debug_CU_Out};
         3'd7: Read_Data = 16'h55AA ;
      endcase
					
// Futás vezérlése 
// Ha nem folyamatos a futási mód (Debug_Mode!=0), egy órajel múlva vissza is veszi a futásparancsot
always @(posedge clk) begin
	if (Reset == 1'b1) begin
		Debug_Run <= 1 ;
		Debug_Mode <= 0 ;
	end
	else begin
		if (Write_Reg && (MB_Addr==16'hFFFF)) begin // Write command register
			Debug_Mode <= {MB_Data[3],MB_Data[2]};
			Debug_Reset <= MB_Data[0] ;
			Debug_Run <= MB_Data[1] ;
		end
		else if (Debug_Mode!=0) // Not in continuous run
			Debug_Run <= 0 ;
	end // No reset
end // always clk

endmodule
