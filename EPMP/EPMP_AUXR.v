`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:07:40 08/06/2009 
// Design Name: 
// Module Name:    EPMP_AUXR 
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
module EPMP_AUXR(clk, AuxR_Load_En, AuxR_Out_En, D, IBH, Debug_AUX_R);
    input clk;
    input AuxR_Load_En;
    input AuxR_Out_En;
    input [7:0] D;
    output [7:0] IBH;
    output [7:0] Debug_AUX_R;

reg [7:0] Aux_Reg ;

assign IBH = (AuxR_Out_En) ? Aux_Reg : 8'bZ ;
assign Debug_AUX_R = Aux_Reg ;

always @ (posedge clk)
	if (AuxR_Load_En)
		Aux_Reg <= D ;

endmodule
