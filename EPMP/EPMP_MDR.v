`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:01:15 08/06/2009 
// Design Name: 
// Module Name:    EPMP_MDR 
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
module EPMP_MDR(clk, MDR_XB_Load, MDR_IB_Load, MDR_XB_En, MDR_IB_En, D, IBL, Debug_MDR);
    input clk;
    input MDR_XB_Load;
    input MDR_IB_Load;
    input MDR_XB_En;
    input MDR_IB_En;
    inout [7:0] D;
    inout [7:0] IBL;
    output [7:0] Debug_MDR;
reg [7:0] MD_Reg ;

assign D = (MDR_XB_En) ? MD_Reg : 8'bZ ;
assign IBL = (MDR_IB_En) ? MD_Reg : 8'bZ ;
assign Debug_MDR = MD_Reg ;

always @ (posedge clk)
	if (MDR_XB_Load)
		MD_Reg <= D ;
	else if (MDR_IB_Load)
		MD_Reg <= IBL ;

endmodule
