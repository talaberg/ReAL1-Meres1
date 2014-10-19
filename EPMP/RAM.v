`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:46:39 08/06/2009 
// Design Name: 
// Module Name:    RAM 
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
module RAM(clk, A, D, Read, Write, En, Debug_A, Debug_D, Debug_Read, Debug_Write, Debug_En);
    input clk;
	 input En;
    input [10:0] A;
    inout [7:0] D;
    input Read;
    input Write;
	 input Debug_En;
    input [10:0] Debug_A;
    inout [7:0] Debug_D;
    input Debug_Read;
    input Debug_Write;

wire [7:0] DO;
wire [10:0] ADDR;

wire [7:0] Debug_DO;
wire [10:0] Debug_ADDR;

assign DIP = 0 ; // Parity not used
assign D=(Read&En) ? DO : 8'bZ ;
assign Debug_D=(Debug_Read&Debug_En) ? Debug_DO : 8'bZ ;
assign ADDR=A[10:0] ;

   RAMB16_S9_S9 #(
      .INIT_A(9'h000),  // Value of output RAM registers on Port A at startup
      .INIT_B(9'h000),  // Value of output RAM registers on Port B at startup
      .SRVAL_A(9'h000), // Port A output value upon SSR assertion
      .SRVAL_B(9'h000), // Port B output value upon SSR assertion
      .WRITE_MODE_A("WRITE_FIRST"), // WRITE_FIRST, READ_FIRST or NO_CHANGE
      .WRITE_MODE_B("WRITE_FIRST"), // WRITE_FIRST, READ_FIRST or NO_CHANGE
      .SIM_COLLISION_CHECK("ALL"), // "NONE", "WARNING_ONLY", "GENERATE_X_ONLY", "ALL" 
		`include "RAM_init.vh"
   ) RAMB16_S9_inst (
      .DOA(DO),      // 8-bit Data Output
      .ADDRA(ADDR),  // 11-bit Address Input
      .CLKA(clk),    // Clock
      .DIA(D),      // 8-bit Data Input
      .DIPA(DIP),    // 1-bit parity Input
      .ENA(En),      // RAM Enable Input
      .SSRA(0),    // Synchronous Set/Reset Input
      .WEA(Write),       // Write Enable Input
      .DOB(Debug_DO),      // 8-bit Data Output
      .ADDRB(Debug_A),  // 11-bit Address Input
      .CLKB(clk),    // Clock
      .DIB(Debug_D),      // 8-bit Data Input
      .DIPB(DIP),    // 1-bit parity Input
      .ENB(Debug_En),      // RAM Enable Input
      .SSRB(0),    // Synchronous Set/Reset Input
      .WEB(Debug_Write)       // Write Enable Input
   );

   // End of RAMB16_S9_S9_inst instantiation
endmodule
