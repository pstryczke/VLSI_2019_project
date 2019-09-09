/******************************************************************************
 * (C) Copyright 2019 AGH UST All Rights Reserved
 *
 * MODULE:    mtm_Alu
 * PROJECT:   PPCU_VLSI
 * AUTHORS:	  Patryk Tokarczyk, Sebastian Sztuk
 * DATE:	  02.09.2019
 * ------------------------------------------------------------------------------
 * The ALU should operate as described in the mtmAlu_test_top module.
 * It should consist of three modules connected together:
 *   mtm_Alu_deserializer
 *   mtm_Alu_core
 *   mtm_Alu_serializer
 * The ALU should use posedge active clock and synchronous reset active LOW.
 *
 *******************************************************************************/
 
 `define IDLE		3b'000
 `define TYPE		3b'001
 `define DATA		3b'010
 `define CMD		3b'011
 `define CHECK_DATA	3b'100
 `define SEND_DATA	3b'101
 
 `define ERR_DATA	6b'100100
 `define ERR_CRC	6b'010010
 `define ERR_OP		6b'001001
 
 
 module mtm_Alu_core (
	input wire clk,
	input wire rst_n,
	input wire rdy_to_send,
	input wire [31:0] B_in,
	input wire [31:0] A_in,
	input wire [2:0]  oprnt_in,
	input wire [1:0]  err_flg_in,

	
	output reg [31:0] C_out,
	output reg [3:0]  flg_out,
	output reg [2:0]  err_flg_out
 );
 
 endmodule