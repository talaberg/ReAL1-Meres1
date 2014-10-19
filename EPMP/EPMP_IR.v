`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:57:10 08/06/2009 
// Design Name: 
// Module Name:    EPMP_IR 
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
module EPMP_IR(clk, IR_Load, IBL, IR);
    input clk;
    input IR_Load;
    input [7:0] IBL;
    output reg [7:0] IR;

always @ (posedge clk)
	if (IR_Load)
		IR <= IBL ;

endmodule
