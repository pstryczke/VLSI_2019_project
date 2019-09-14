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
 
 `define IDLE		2'b00
 `define ERR_FRAME	2'b01
 `define DATA_FRAME	2'b10
 `define SEND_DATA	2'b11
  
 
 module mtm_Alu_serializer (
	input wire clk,
	input wire rst_n,
	input wire receive_data,
	input wire receive_err,
	input wire [31:0] C_in,
	input wire [3:0]  flag_in,
	input wire [2:0]  crc_in,
	input wire [5:0]  err_flg_in,

	output reg sout
 );
	reg [1:0] state;
	reg [1:0] state_nxt;
	reg [54:0] data_out;
	reg [54:0] data_out_nxt;
	reg [10:0] err_out;
	reg [10:0] err_out_nxt;
	reg [5:0]  bit_cnt;
	reg [5:0]  bit_cnt_nxt;
	reg is_err;
	reg is_err_nxt;
	reg sout_nxt;
	
	
	always @ (posedge clk) begin
		if(!rst_n) begin
			
			state		<= `IDLE;
			data_out	<= 0;
			err_out		<= 0;
			bit_cnt		<= 0;
			is_err		<= 0;
			sout		<= 1;
			
			
		end
		else begin
			
			state		<= state_nxt;
			data_out	<= data_out_nxt;
			err_out		<= err_out_nxt;
			bit_cnt		<= bit_cnt_nxt;
			is_err		<= is_err_nxt;
			sout		<= sout_nxt;
			
		end
	end
 
	always @* begin
		case(state)
			
			`IDLE: begin
				if (receive_err == 1) begin
					state_nxt = `ERR_FRAME;
				end
				else if (receive_data == 1) begin
					state_nxt = `DATA_FRAME;
				end
				else begin
					state_nxt = `IDLE;
				end
			end
			
			`ERR_FRAME: begin
				state_nxt = `SEND_DATA;
			end
			
			`DATA_FRAME: begin
				state_nxt = `SEND_DATA;
			end
			
			`SEND_DATA: begin
				if (bit_cnt == 0) begin
					state_nxt = `IDLE;
				end
				else begin
					state_nxt = `SEND_DATA;
				end
			end
			
			
		endcase
	end
	
	always @* begin
		data_out_nxt = data_out;
		err_out_nxt = err_out;
		bit_cnt_nxt = bit_cnt;
		sout_nxt = sout;
		is_err_nxt = is_err;
		
		
		case(state_nxt)
			
			`IDLE: begin
				data_out_nxt = 0;
				err_out_nxt = 0;
				bit_cnt_nxt = 0;
				is_err_nxt = 0;
				sout_nxt = 1;
			end
			
			`ERR_FRAME: begin
				bit_cnt_nxt = 11;
				err_out_nxt = {3'b011, err_flg_in, 2'b11};
				is_err_nxt = 1;
			end
			
			`DATA_FRAME: begin
				bit_cnt_nxt = 55;
				data_out_nxt[54:44] = {2'b00, C_in[31:24], 1'b1};
				data_out_nxt[43:33] = {2'b00, C_in[23:16], 1'b1};
				data_out_nxt[32:22] = {2'b00, C_in[15:8], 1'b1};
				data_out_nxt[21:11] = {2'b00, C_in[7:0], 1'b1};
				data_out_nxt[10:0] = {3'b010, flag_in, crc_in, 1'b1};
				is_err_nxt = 0;
			end
			
			`SEND_DATA: begin
				if (is_err == 0) begin
					bit_cnt_nxt = bit_cnt - 1;
					sout_nxt = data_out[bit_cnt_nxt];
				end
				else begin
					bit_cnt_nxt = bit_cnt - 1;
					sout_nxt = err_out[bit_cnt_nxt];
				end
			end
			
			
		endcase
	end
 endmodule