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
 `define COMPUTE	2'b01
 `define SEND_DATA	2'b10
 
 `define AND		3'b000
 `define OR			3'b001
 `define ADD		3'b100
 `define SUB		3'b101
 
 
 module mtm_Alu_core (
	input wire clk,
	input wire rst_n,
	input wire rdy_to_receive,
	input wire [31:0] B_in,
	input wire [31:0] A_in,
	input wire [2:0]  oprnt_in,

	output reg send_data,
	output reg [31:0] C_out,
	output reg [3:0]  flg_out,
	output reg [2:0]  crc_out
 );
	

	reg send_data_nxt;
	reg [31:0] C_out_nxt;
	reg [3:0]  flg_out_nxt;
	reg [2:0]  crc_out_nxt;
	
	reg [1:0] state;
	reg	[1:0] state_nxt;
	reg carry_flg;
	reg overflow_flg;
	reg zero_flg;
	reg negative_flg;
	
	
 
	always @ (posedge clk) begin
		if(!rst_n) begin
			
			state			<= `IDLE;
			C_out			<= 0;
			flg_out			<= 0;
			crc_out			<= 0;
			send_data		<= 0;
			carry_flg		<= 0;
			overflow_flg	<= 0;
			zero_flg		<= 0;
			negative_flg	<= 0;
			
		end
		else begin
		
			state		<= state_nxt;
			C_out		<= C_out_nxt;
			flg_out		<= flg_out_nxt;
			crc_out		<= crc_out_nxt;
			send_data	<= send_data_nxt;
			
		end
	end
	
	always @* begin
		case(state)
			
			`IDLE: begin
				if (rdy_to_receive == 1) begin
					state_nxt = `COMPUTE;
				end
				else begin
					state_nxt = `IDLE;
				end
			end
			
			`COMPUTE: begin
				state_nxt = `SEND_DATA;
			end
			
			`SEND_DATA: begin
				state_nxt = `IDLE;
			end
			
		endcase
	end
	
	always @* begin
		C_out_nxt = C_out;
		flg_out_nxt	= flg_out;
		crc_out_nxt	= crc_out;
		send_data_nxt = send_data;
		
		case(state_nxt)
			
			`IDLE: begin
				send_data_nxt = 0;
			end
			
			`COMPUTE: begin
				
				carry_flg = 0;
				overflow_flg = 0;
				negative_flg = 0;
				zero_flg = 0;
				
				case(oprnt_in)
					
					`AND: begin
						C_out_nxt = A_in & B_in;
					end
					
					`OR: begin
						C_out_nxt = A_in | B_in;
					end
					
					`ADD: begin
						{carry_flg, C_out_nxt} = {1'b0, A_in} + {1'b0, B_in};
						overflow_flg = ((B_in[31] ^ A_in[31] ^ C_out_nxt[31]) ^ carry_flg);
					end
					
					`SUB: begin
						{carry_flg, C_out_nxt} = {1'b0, A_in} - {1'b0, B_in};
						overflow_flg = ((B_in[31] ^ A_in[31] ^ C_out_nxt[31]) ^ carry_flg);
					end
				endcase
				
				if (C_out_nxt[31] == 1) begin
					negative_flg = 1;
				end
				if (C_out_nxt == 0) begin
					zero_flg = 1;
				end
				
				flg_out_nxt = {carry_flg, overflow_flg, zero_flg, negative_flg};
				CRC3_37({C_out_nxt, 1'b0, flg_out_nxt}, crc_out_nxt);
			end
			
			`SEND_DATA: begin
				send_data_nxt = 1;
			end
			
		endcase
	end
	
	task CRC3_37;

	  input reg [36:0] data;
	  output reg [2:0] CRC3_result;

	  reg [36:0] data_copy;
	  reg [2:0] Result;

	  begin
		 data_copy = data;
		 Result[0] = data_copy[35] ^ data_copy[32] ^ data_copy[31] ^ data_copy[30] ^ data_copy[28] ^ data_copy[25] ^ data_copy[24] ^ data_copy[23] ^ data_copy[21] ^ data_copy[18] ^ data_copy[17] ^ data_copy[16] ^ data_copy[14] ^ data_copy[11] ^ data_copy[10] ^ data_copy[9] ^ data_copy[7] ^ data_copy[4] ^ data_copy[3] ^ data_copy[2] ^ data_copy[0];
		 Result[1] = data_copy[36] ^ data_copy[35] ^ data_copy[33] ^ data_copy[30] ^ data_copy[29] ^ data_copy[28] ^ data_copy[26] ^ data_copy[23] ^ data_copy[22] ^ data_copy[21] ^ data_copy[19] ^ data_copy[16] ^ data_copy[15] ^ data_copy[14] ^ data_copy[12] ^ data_copy[9] ^ data_copy[8] ^ data_copy[7] ^ data_copy[5] ^ data_copy[2] ^ data_copy[1] ^ data_copy[0];
		 Result[2] = data_copy[36] ^ data_copy[34] ^ data_copy[31] ^ data_copy[30] ^ data_copy[29] ^ data_copy[27] ^ data_copy[24] ^ data_copy[23] ^ data_copy[22] ^ data_copy[20] ^ data_copy[17] ^ data_copy[16] ^ data_copy[15] ^ data_copy[13] ^ data_copy[10] ^ data_copy[9] ^ data_copy[8] ^ data_copy[6] ^ data_copy[3] ^ data_copy[2] ^ data_copy[1];
		 CRC3_result = Result;
	  end
	endtask
	
 endmodule