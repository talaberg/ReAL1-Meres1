`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:47:56 08/06/2009 
// Design Name: 
// Module Name:    EPMP_PC 
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
module EPMP_PC(clk, Reset, PC_Load_En, PC_Inc_nLoad, PC_Out_En, IBH, IBL, Debug_PC);
    input clk;
    input Reset;
    input PC_Load_En;
    input PC_Inc_nLoad;
    input PC_Out_En;
    inout [7:0] IBH;
    inout [7:0] IBL;
    output [15:0] Debug_PC;
    
reg [15:0] PC_Reg ;
assign IBH = (PC_Out_En)?PC_Reg[15:8]:8'bZ ;
assign IBL = (PC_Out_En)?PC_Reg[7:0]:8'bZ ;

assign Debug_PC = PC_Reg ;

always @ (posedge clk)
	if (Reset)
		PC_Reg <= 0 ;
	else if (PC_Load_En) begin
		if (PC_Inc_nLoad)
			PC_Reg <= PC_Reg+1 ;
		else
			PC_Reg <= {IBH, IBL} ;
	end
	
endmodule
