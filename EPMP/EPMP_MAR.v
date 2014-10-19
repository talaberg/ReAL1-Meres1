`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:42:50 08/06/2009 
// Design Name: 
// Module Name:    EPMP_MAR 
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
module EPMP_MAR(IBL, IBH, MAR_Load, clk, A);
    input [7:0] IBL;
    input [7:0] IBH;
    input MAR_Load;
    input clk;
    output reg [15:0] A;

always @ (posedge clk)
	if (MAR_Load)
		A <= {IBH,IBL} ;
	else
		A <= A ;

endmodule
