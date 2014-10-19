`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:47:56 08/06/2009 
// Design Name: 
// Module Name:    EPMP_STACK
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Hardware stack for EPMP
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module EPMP_STACK(clk, Reset, Pop_Stack, Push_Stack, IBH, IBL);
    input clk;
    input Reset;
    input Pop_Stack; // Moves data from stack and enables output to IB
    input Push_Stack;
    inout [7:0] IBH;
    inout [7:0] IBL;
    
reg [15:0] Stack0 ;
reg [15:0] Stack1 ;
reg [15:0] Stack2 ;
reg [15:0] Stack3 ;
assign IBH = (Pop_Stack)?Stack0[15:8]:8'bZ ;
assign IBL = (Pop_Stack)?Stack0[7:0]:8'bZ ;

always @ (posedge clk)
	if (Reset) begin
		Stack0 <= 0 ;
		Stack1 <= 0 ;
		Stack2 <= 0 ;
		Stack3 <= 0 ;
	end
	else if (Pop_Stack) begin
		Stack0 <= Stack1 ;
		Stack1 <= Stack2 ;
		Stack2 <= Stack3 ;
		Stack3 <= 0 ;
	end
	else if (Push_Stack) begin
		Stack0 <= {IBH, IBL} ;
		Stack1 <= Stack0 ;
		Stack2 <= Stack1 ;
		Stack3 <= Stack2 ;
	end
	
endmodule
