/******************************************************************************
 * (C) Copyright 2019 AGH UST All Rights Reserved
 *
 * MODULE:    mtm_Alu
 * PROJECT:   PPCU_VLSI
 * AUTHORS:	  Patryk Tokarczyk
 * DATE:	  12.09.2019
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

	wire [31:0] B;
	wire [31:0] A;
	wire send_to_core;
	wire [2:0] oprnt;
	wire [5:0] err_flg;
	//wire [5:0] err_flg_2;
	wire send_err_to_serial;
	wire send_data_to_serial;
	wire [31:0] C;
	wire [3:0] flags;
	wire [2:0] crc;
	

mtm_Alu_deserializer u_mtm_Alu_deserializer(
	.clk(clk),
	.rst_n(rst_n),
	.sin(sin),
	.rdy_to_send(send_to_core),
	.rdy_to_send_err(send_err_to_serial),
	.B_out(B),
	.A_out(A),
	.oprnt_out(oprnt),
	.err_flg_out(err_flg)
);

mtm_Alu_core u_mtm_Alu_core(
	.clk(clk),
	.rst_n(rst_n),
	.rdy_to_receive(send_to_core),
	.B_in(B),
	.A_in(A),
	.oprnt_in(oprnt),
	//.err_flg_in(err_flg),
	//.send_err(send_err_to_serial),
	.send_data(send_data_to_serial),
	.C_out(C),
	.flg_out(flags),
	.crc_out(crc)
	//.err_flg_out(err_flg_2)
);

mtm_Alu_serializer u_mtm_Alu_serializer(
	.clk(clk),
	.rst_n(rst_n),
	.receive_data(send_data_to_serial),
	.receive_err(send_err_to_serial),
	.C_in(C),
	.flag_in(flags),
	.crc_in(crc),
	.err_flg_in(err_flg),
	.sout(sout)
);


endmodule
