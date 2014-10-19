`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:27:32 08/02/2009 
// Design Name: 
// Module Name:    EPMP_ALU 
// Project Name: 	 EPMP
// Target Devices: 
// Tool versions: 
// Description: Arithmetic Logical Unit
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module EPMP_ALU(clk, Reset, ALU_En, ACC_Out_En, ALU_Cmd, C, ACC_bus,Debug_ACC);
    input clk;
    input Reset;
    input ALU_En;
    input ACC_Out_En;
    input [3:0] ALU_Cmd;
    inout reg C=0;//inoutra cserélve
    output [7:0] Debug_ACC ;
    inout [7:0] ACC_bus;

reg [7:0] ACC=0 ;
wire [8:0] AddResult ;
wire [8:0] SubResult ;
 
`define ADD 0
`define SUB 1
`define CLR 2
`define NEG 3
`define INR 4
`define DCR 5
`define AND 6
`define OR  7
`define LOAD 8

assign AddResult = {1'b0,ACC}+{1'b0,ACC_bus}+C ;
assign SubResult = {1'b0,ACC}-{1'b0,ACC_bus}-C ;
assign ACC_bus = (ACC_Out_En)?ACC:8'bZ ;

assign Debug_ACC = ACC ;

always @ (posedge clk)
	if (Reset) begin
		ACC <= 0 ;
		C <= 0 ;
	end
	
	else if (ALU_En)
		
   case (ALU_Cmd)
      `LOAD : begin
        ACC<= ACC_bus ;
		  C <= C ;
               end
      `ADD  : begin
			ACC<= AddResult[7:0] ;
			C <= AddResult[8] ;
               end
      `SUB  : begin
			ACC<= SubResult[7:0] ;
			C <= SubResult[8] ;
               end
      `NEG  : begin
			ACC<= -ACC ;
			C <= 0 ;
               end
      `INR  : begin
			ACC<= ACC+1 ;
			C <= ACC==255 ;
               end
      `DCR  : begin
			ACC<= ACC-1 ;
			C <= ACC==0 ;
               end
      `CLR  : begin
			ACC<= 0 ;
			C <= 0 ;
               end
      `AND  : begin
			ACC<= ACC & ACC_bus;
			C <= 0 ;
               end
      `OR  : begin
			ACC<= ACC | ACC_bus;
			C <= 0 ;
               end
     default: begin
              ACC<=ACC;
				  C <= C ;
               end
   endcase
				
endmodule
