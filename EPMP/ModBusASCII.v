`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:19:50 08/19/2009 
// Design Name: 
// Module Name:    ModBusASCII 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 	A soros vonalon érkezett ASCII karaktereket, mint ModBus üzeneteket feldolgozza
//						Támogatott funkciók, megkötések:
//							Singel Register Write (6-os), nem válaszol, broadcast-ban mûködik 
//							Read Holding Registers (3-as), az olvasott regiszterek száma csak 1 lehet
//						Device Address: vételnél csak a 0-át különbözteti meg (broadcast), adásnál 1
//						
//						
//						
//						
//						
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ModBusASCII(clk, Reset, RxBuf, RxRdy, RxErr, TxBuf, TxEmpty, Read_RxBuf, Write_TxBuf, Read_Reg, Write_Reg, MB_Data, MB_Addr);
    input clk;
    input Reset;
	 // Connection to UART
    input [7:0] RxBuf;
    input RxRdy;
    input RxErr;
    output reg [7:0] TxBuf;
    input TxEmpty;
    output reg Read_RxBuf;
    output reg Write_TxBuf ;
	 // Connection to registers
    output reg Read_Reg;
    output Write_Reg;  // Írást követõen egy órajelre aktív
    inout [15:0] MB_Data;
    output reg [15:0] MB_Addr;

`define MODBUS_START 58
`define CR 13
`define LF 10
`define WRITE_SINGLE_REGISTER 6
`define READ_HOLDING_REGISTERS 3

reg [4:0] AnsState ;
reg [1:0] mbState ;
reg [7:0] mbByte ;
wire [3:0] mbNibble ;
wire [7:0] ChkSum ;
wire [7:0] ChkSum_Write;
reg [15:0] mbWrData ;
reg mbMsgValid, mbMsgValidOld, BroadCast, mbByteValid, mbDataHi ;
reg mbWrite ;
reg [3:0] mbRxIdx ;
reg [7:0] mbLRC ;
reg [15:0] Read_buf ;

// ModBus ASCII interpreter
assign mbNibble = (RxBuf >= 48 && RxBuf <= 57)? RxBuf - 48 : RxBuf - 65 + 10 ;
assign MB_Data = (Write_Reg) ? mbWrData : 16'bZ ;
assign Write_Reg = mbMsgValid & !mbMsgValidOld & mbWrite ;
assign ChkSum = 250 - Read_buf[15:8] - Read_buf[7:0] ;
assign ChkSum_Write = 249 - MB_Addr[15:8] - MB_Addr[7:0] - mbWrData[15:8] - mbWrData[7:0] ;

always @(posedge clk) begin
	if (Reset == 1'b1) begin
		TxBuf <= 120 ;
		Write_TxBuf <= 0 ;
		Read_RxBuf <= 0 ;
		Read_Reg <= 0 ;
		AnsState <= 0 ;
		mbMsgValid <= 0 ;
		mbByteValid <= 0 ;
		mbState <= 0 ;
	end
	else begin
		mbMsgValidOld <= mbMsgValid ;
		if (mbByteValid) begin // Interpreting the reconustructed received bytes
			mbByteValid <= 0 ;
			mbLRC <= mbLRC + mbByte;
			mbRxIdx <= mbRxIdx+1 ;
			case (mbRxIdx)
				0:  // Slave address
					BroadCast <= mbByte==0 ;
				1: begin // Function code
						if (mbByte==`WRITE_SINGLE_REGISTER)
							mbWrite <= 1;
						else if ((mbByte==`READ_HOLDING_REGISTERS)&&!BroadCast) begin
							mbWrite <= 0;
						end
						else
							mbState <= 0 ; // Not suppported function
					end
				2: begin // Address high byte
						MB_Addr[15:8] <= mbByte ;
					end
				3: begin // Address low byte
						MB_Addr[7:0] <= mbByte ;
					end
				4: begin // 1st byte for Write or length for read
						if (mbWrite)
							mbWrData[15:8]<=mbByte ;
						else if (mbByte!=0)
							mbState <= 0 ; // Csak egy regiszter olvashatunk
					end
				5: begin // 2nd byte for Write or length for read
						if (mbWrite)
							mbWrData[7:0]<=mbByte ;
						else if (mbByte!=1)
							mbState <= 0 ; // Csak egy regiszter olvashatunk
					end
				6: begin
					end
				default: begin
							mbState <= 0 ; // Csak egy regiszter olvashatunk
					end
			endcase
		end
		else if (Read_RxBuf)
			Read_RxBuf <= 0 ;
		else if (RxRdy) begin
			Read_RxBuf <= 1 ;
			if (RxErr)
				mbState <= 0 ;
			else if (RxBuf==`MODBUS_START) begin
				mbLRC <= 0;
				mbRxIdx <= 0;
				mbDataHi <= 1;
				mbState <= 1;
			end
			else if (mbState == 1)	begin // adatok
				if (RxBuf == `CR)
				begin
					if ((mbLRC == 0) && (mbRxIdx==7))
						mbState <= 2; // jó az ellenõrzõ összeg
					else
						mbState <= 0; // Hibás chksum, újabb start karakterre várunk
				end
				else
				begin
					if ((RxBuf >= 48 && RxBuf <= 57)||(RxBuf >= 65 &&  RxBuf <= 70)) begin
						if (mbDataHi)
							mbByte[7:4] <= mbNibble ;
						else begin
							mbByte[3:0] <= mbNibble ;
							mbByteValid <= 1 ;
						end
					end
					else
						mbState <= 0; // Illegális karakter
					mbDataHi <= !mbDataHi;
				end
			end
			else if (mbState == 2)
			begin // LF karakter
				if (RxBuf == `LF)
				begin
					mbMsgValid <= 1;  // jó volt az üzenet keretezése
				end
				mbState <= 0;	// Az üzenet keretezése nem jó.
			end
		end
		
	// A vett érvényes üzenet feldolgozása
	if (mbMsgValid) begin
		if (mbWrite) begin // Answer for write 
			if (Write_TxBuf) // Leghamarabb 2 órajelenként írhatunk az Uart-ba
				Write_TxBuf <= 0 ;
			else if (TxEmpty) begin
				Write_TxBuf <= 1 ;
				AnsState <= AnsState+1 ;
				case (AnsState)
					0: TxBuf <= `MODBUS_START ;
					1: TxBuf <= 8'h30 ; // Slave address
					2: TxBuf <= 8'h31 ; // Slave address
					3: TxBuf <= 8'h30 ; // Function code
					4: TxBuf <= 8'h36 ; // Function code
					5: TxBuf <= Nibble2ASCII(MB_Addr[15:12]) ;
					6: TxBuf <= Nibble2ASCII(MB_Addr[11:8]) ;
					7: TxBuf <= Nibble2ASCII(MB_Addr[7:4]) ;
					8: TxBuf <= Nibble2ASCII(MB_Addr[3:0]) ;
					9: TxBuf <= Nibble2ASCII(mbWrData[15:12]) ;
					10: TxBuf <= Nibble2ASCII(mbWrData[11:8]) ;
					11: TxBuf <= Nibble2ASCII(mbWrData[7:4]) ;
					12: TxBuf <= Nibble2ASCII(mbWrData[3:0]) ;
					13: TxBuf <= Nibble2ASCII(ChkSum_Write[7:4]) ;
					14: TxBuf <= Nibble2ASCII(ChkSum_Write[3:0]) ;
					15: TxBuf <= `CR ;
					default: begin
						TxBuf <= `LF ;
						mbMsgValid <= 0 ;
						end
				endcase
			end // TxEmpty		
		end // Answer for write 	
		else begin // Answer for read
			if (Write_TxBuf) // Leghamarabb 2 órajelenként írhatunk az Uart-ba
				Write_TxBuf <= 0 ;
			else if (TxEmpty) begin
				Write_TxBuf <= 1 ;
				AnsState <= AnsState+1 ;
				case (AnsState)
					0: begin 
							TxBuf <= `MODBUS_START ;
							Read_Reg <= 1 ;
						end
					1: begin
							TxBuf <= 8'h30 ; // Slave address
							Read_buf <= MB_Data ;
							Read_Reg <= 0 ;
						end
					2: TxBuf <= 8'h31 ; // Slave address
					3: TxBuf <= 8'h30 ; // Function code
					4: TxBuf <= 8'h33 ; // Function code
					5: TxBuf <= 8'h30 ; // Length
					6: TxBuf <= 8'h32 ; // Length
					7: TxBuf <= Nibble2ASCII(Read_buf[15:12]) ;
					8: TxBuf <= Nibble2ASCII(Read_buf[11:8]) ;
					9: TxBuf <= Nibble2ASCII(Read_buf[7:4]) ;
					10: TxBuf <= Nibble2ASCII(Read_buf[3:0]) ;
					11: TxBuf <= Nibble2ASCII(ChkSum[7:4]) ;
					12: TxBuf <= Nibble2ASCII(ChkSum[3:0]) ;
					13: TxBuf <= `CR ;
					default: begin
						TxBuf <= `LF ;
						mbMsgValid <= 0 ;
						end
				endcase
			end // TxEmpty
		end // Answer for read
	end // mbMsgValid
	else begin
		Write_TxBuf <= 0 ;
		AnsState <= 0 ;
	end
 end // Nincs Reset
end // always

function [7:0] Nibble2ASCII;
	input [3:0] binary_input;
	begin
		if (binary_input < 10)
			Nibble2ASCII = 48 + binary_input ;
		else
			Nibble2ASCII = 65-10 + binary_input ;
	end
endfunction

endmodule