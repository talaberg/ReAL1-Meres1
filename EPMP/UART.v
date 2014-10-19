`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:41:22 08/18/2009 
// Design Name: 
// Module Name:    UART 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 8 bit UART, no parity, Frame and overrun error checked
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module UART(clk, Reset, RxD, TxD, RxBuf, RxRdy, RxErr, TxBuf, TxEmpty, Read_RxBuf, Write_TxBuf);
    input clk;
    input Reset;
    input RxD;
    output TxD;
    output reg [7:0] RxBuf;
    output reg RxRdy;
    output reg RxErr;
    input [7:0] TxBuf;
    output reg TxEmpty;
    input Read_RxBuf;
    input Write_TxBuf;

reg [8:0] TxShift_Reg;
reg [7:0] TxBuf_Reg ;
reg [15:0] tr_counter;
reg [3:0] tr_bit_num;
wire [15:0] tr_counter_next;

reg [7:0] RxShift_Reg ;
reg [15:0] rec_counter;
reg [3:0] rec_bit_num;
reg RxShift_Rdy ;
reg RxD_sync ;
wire [15:0] rec_counter_next;

assign TxD = TxShift_Reg[0];

parameter baud_rate_step=16'd471; // baud_rate_step = baud_rate(115.2k) * 2^16 / 16MHz

assign tr_counter_next = tr_counter + baud_rate_step ;
assign tx_clk_en = !tr_counter_next[15] & tr_counter[15] ;

always@ (posedge clk) begin
	if (Reset == 1'b1)
	begin
		tr_counter <= 0;
		tr_bit_num <= 0;
		TxShift_Reg[0] <= 1;
		TxEmpty <= 1 ;
	end
	else
	begin
		tr_counter <= tr_counter_next ;
		if (Write_TxBuf) begin
			TxBuf_Reg <= TxBuf ;
			TxEmpty <= 0 ;
		end
		else if (tx_clk_en)
			case (tr_bit_num)
				4'd0 : if (!TxEmpty)
							begin
								TxEmpty <= 1 ;
								tr_bit_num <= 1 ;
								TxShift_Reg[8:0]<={TxBuf_Reg[7:0], 1'b0};
							end
				4'd10 : begin					
								tr_bit_num[3:0]<=4'd0;
								TxShift_Reg[8:0] <= {1'b1, TxShift_Reg[8:1]};
						end
				default : begin
								tr_bit_num[3:0] <= tr_bit_num[3:0]+4'd1;
								TxShift_Reg[8:0] <= {1'b1, TxShift_Reg[8:1]};
							end
			endcase		 
	end // Not in reset
end // always for transmit

assign rec_counter_next = rec_counter + baud_rate_step ;
assign rec_clk_en = !rec_counter_next[15] & rec_counter[15] ;

always@ (posedge clk) begin
	if (Reset == 1'b1)
	begin
		RxD_sync<=1 ;
		rec_counter <= 0;
		rec_bit_num <= 0;
		RxBuf <= 0 ;
		RxRdy <= 0 ;
		RxErr <= 0 ;
		RxShift_Rdy <= 0 ;
	end
	else
	begin
		RxD_sync<=RxD ;
		if (Read_RxBuf) begin
			RxRdy <= 0 ;
			RxErr <= 0 ;
		end
		if (RxShift_Rdy && !RxRdy) begin // a shiftregiszter áttölthetõ a bufferbe
			RxRdy <= 1 ;
			RxShift_Rdy <= 0 ;
			RxBuf <= RxShift_Reg ;
		end
		
		if (rec_bit_num==0) begin
			if (!RxD_sync) begin // Start bit lefutó éle (vagy zaj)
				rec_bit_num <= 1 ;
				rec_counter <= 16'h8000 ;
			end
		end
		else begin
			rec_counter <= rec_counter_next ;
			if (rec_clk_en)
				case (rec_bit_num)
					4'd1 : 
						if (RxD_sync)
							rec_bit_num <= 0 ; // Csak zaj volt, nincs start bit
						else if (RxShift_Rdy) begin
							RxErr <= 1 ; // Túlcsordulás hiba
							rec_bit_num <= 0 ;
						end
						else
							rec_bit_num <= 2 ; 
					4'd10 : begin
						RxShift_Rdy <= 1 ;
						rec_bit_num <= 0 ;
						if (!RxD_sync)
							RxErr <= 1 ; // Keretezés hiba
					end
					default: begin
						rec_bit_num <= rec_bit_num + 1 ;
						RxShift_Reg <= {RxD_sync,RxShift_Reg[7:1]} ;
						end
				endcase
			end // Receive started		 
	end // Not in reset
end // always for receive

endmodule
	
