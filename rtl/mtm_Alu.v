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

module mtm_Alu (
    input  wire clk,   // posedge active clock
    input  wire rst_n, // synchronous reset active low
    input  wire sin,   // serial data input
    output wire sout   // serial data output
);

module mtm_Alu_deserializer (
	input  wire clk,
	input  wire rst_n,
	input  wire sin,
	
	output reg  [31:0] B_out,
	output reg  [31:0] A_out,
	output reg  [2:0]  oprnt_out,
	output reg  [1:0]  err_flg_out
);

module mtm_Alu_core (
	input wire clk,
	input wire rst_n,
	input reg  [31:0] B_in,
	input reg  [31:0] A_in,
	input reg  [2:0]  oprnt_in,
	input reg  [1:0]  err_flg_in,
	
	output reg [31:0] C_out,
	output reg [3:0]  flg_out,
	output reg [2:0]  err_flg_out
);

module mtm_Alu_serializer (
	input wire clk,
	input wire rst_n,
	input reg  [31:0] C_in,
	input reg  [3:0]  flg_in,
	input reg  [2:0]  err_flg_in,
	
	output wire sout
);

mtm_Alu_deserializer u_mtm_Alu_deserializer(
);

mtm_Alu_core u_mtm_Alu_core(
);

mtm_Alu_serializer u_mtm_Alu_serializer(
);


endmodule
