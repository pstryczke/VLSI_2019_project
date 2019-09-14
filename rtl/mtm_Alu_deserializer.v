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
 
 `define IDLE		3'b000
 `define TYPE		3'b001
 `define DATA		3'b010
 `define CMD		3'b011
 `define CHECK_DATA	3'b100
 `define SEND_DATA	3'b101
 `define WAIT		3'b110
 `define SEND_ERR	3'b111
 
 `define ERR_DATA	6'b100100
 `define ERR_CRC	6'b010010
 `define ERR_OP		6'b001001
 
 `define AND		3'b000
 `define OR			3'b001
 `define ADD		3'b100
 `define SUB		3'b101
 
 
 module mtm_Alu_deserializer (
	input  wire clk,
	input  wire rst_n,
	input  wire sin,
	
	output reg	rdy_to_send,
	output reg	rdy_to_send_err,
	output reg  [31:0] B_out,
	output reg  [31:0] A_out,
	output reg  [2:0]  oprnt_out,
	output reg  [5:0]  err_flg_out
);
	reg [31:0] B_out_nxt;
	reg [31:0] A_out_nxt;
	reg [2:0]  oprnt_out_nxt;
	reg [5:0]  err_flg_out_nxt;
	
	reg [2:0] state;
	reg	[2:0] state_nxt;
	reg [3:0] bit_cnt;
	reg [3:0] bit_cnt_nxt;
	reg [3:0] frame_cnt;
	reg [3:0] frame_cnt_nxt;
	reg [3:0] crc_check;
	reg [3:0] crc_check_nxt;
	reg [3:0] crc_4;
	reg rdy_to_send_nxt;
	reg rdy_to_send_err_nxt;
	reg is_data;
	reg is_data_nxt;
	reg error;
	reg error_nxt;
	

	always @ (posedge clk) begin
		if(!rst_n) begin
			state			<= `IDLE;
			B_out 	 		<= 0;
			A_out			<= 0;
			oprnt_out 		<= 0;
			err_flg_out 	<= 0;
			bit_cnt			<= 0;
			frame_cnt		<= 0;
			crc_check		<= 0;
			rdy_to_send		<= 0;
			rdy_to_send_err <= 0;
			is_data			<= 0;
			error			<= 0;
			
		end
		else begin
			B_out 	 		<= B_out_nxt;
			A_out			<= A_out_nxt;
			oprnt_out 		<= oprnt_out_nxt;
			err_flg_out 	<= err_flg_out_nxt;	
			state			<= state_nxt;
			bit_cnt			<= bit_cnt_nxt;
			frame_cnt		<= frame_cnt_nxt;
			crc_check		<= crc_check_nxt;
			rdy_to_send		<= rdy_to_send_nxt;
			is_data			<= is_data_nxt;
			error			<= error_nxt;
			rdy_to_send_err <= rdy_to_send_err_nxt;
			
		end
	end
	
	always @* begin
		case(state)
		
			`IDLE: begin
				if (sin == 0) begin
					state_nxt = `WAIT;
				end
				else begin
					state_nxt = `IDLE;
				end
			end
			
			`WAIT: begin
				state_nxt = `TYPE;
			end
			
			`TYPE: begin
				if (is_data == 1) begin
					state_nxt = `DATA;
				end
				else begin
					state_nxt = `CMD;
				end
			end
			
			`DATA: begin
				
				if (bit_cnt == 8) begin
					if (error == 1) begin
						state_nxt = `CHECK_DATA;
					end
					else begin
						state_nxt = `IDLE;
					end
				end
				else begin
					state_nxt = `DATA;
				end
			end
			
			`CMD: begin
				if (bit_cnt == 8) begin
					state_nxt = `CHECK_DATA;
				end
				else begin
					state_nxt = `CMD;
				end
			end
			
			`CHECK_DATA: begin
				if (error == 0) begin
					state_nxt = `SEND_DATA;
				end
				else begin
					state_nxt = `SEND_ERR;
				end
			end
			
			`SEND_DATA: begin
				state_nxt = `IDLE;
			end
			
			`SEND_ERR: begin
				state_nxt = `IDLE;
			end
			
			default: begin
			end
		endcase	
	end
	
	always @* begin
		bit_cnt_nxt = bit_cnt;
		frame_cnt_nxt = frame_cnt;
		B_out_nxt = B_out;
		A_out_nxt = A_out;
		oprnt_out_nxt = oprnt_out;
		crc_check_nxt = crc_check;
		err_flg_out_nxt = err_flg_out;
		rdy_to_send_nxt = rdy_to_send;
		rdy_to_send_err_nxt = rdy_to_send_err;
		is_data_nxt = is_data;
		error_nxt = error;
		
		case(state_nxt)
		
			`IDLE: begin
				bit_cnt_nxt = 0;
				rdy_to_send_nxt = 0;
				rdy_to_send_err_nxt = 0;
				error_nxt = 0;
				err_flg_out_nxt = 6'b000000;
			end
			
			`WAIT: begin
			end
			
			`TYPE: begin
				//bit_cnt_nxt = 0;
				//rdy_to_send_nxt = 0;
				//rdy_to_send_err_nxt = 0;
				//error_nxt = 0;
				if (sin == 0) begin
					is_data_nxt = 1;
				end
				else begin
					is_data_nxt = 0;
				end
			end
			
			`DATA: begin
				//rdy_to_send_nxt = 0;
				
				bit_cnt_nxt = bit_cnt + 1;
				
				if (frame_cnt < 4) begin
					B_out_nxt = {B_out[30:0], sin};
				end
				else if (frame_cnt < 8) begin
					A_out_nxt = {A_out[30:0], sin};
				end
				
				if (bit_cnt == 7) begin
					frame_cnt_nxt = frame_cnt + 1;
				end
				
				if (frame_cnt_nxt > 8) begin
					error_nxt = 1;
					err_flg_out_nxt = `ERR_DATA;
				end
			end
			
			`CMD: begin
				rdy_to_send_nxt = 0;
				
				bit_cnt_nxt = bit_cnt + 1;
				
				if (bit_cnt > 0 && bit_cnt < 4) begin
					oprnt_out_nxt = {oprnt_out[1:0], sin};
				end
				else if (bit_cnt <= 7) begin
					crc_check_nxt = {crc_check[2:0], sin};
				end
				
				if (frame_cnt < 8) begin
					error_nxt = 1;
					err_flg_out_nxt = `ERR_DATA;
				end

			end
			
			`CHECK_DATA: begin
				bit_cnt_nxt = 0;
				frame_cnt_nxt = 0;
				rdy_to_send_nxt = 0;
				
				if (error == 0) begin
					if ((oprnt_out != `AND) && (oprnt_out != `OR) && (oprnt_out != `ADD) && (oprnt_out != `SUB)) begin
						error_nxt = 1;
						err_flg_out_nxt = `ERR_OP;
					end
				end
				
				CRC4_68({B_out, A_out, 1'b1, oprnt_out}, crc_4);
				
				if (error == 0) begin
					if (crc_4 != crc_check) begin
						error_nxt = 1;
						err_flg_out_nxt = `ERR_CRC;
					end
				end
			end
			
			`SEND_DATA: begin
				rdy_to_send_nxt = 1;
			end
			
			`SEND_ERR: begin
				rdy_to_send_err_nxt = 1;
				//err_flg_out_nxt = 6'b000000;
			end
			
			default: begin
			end
		endcase	
	end
	
	task CRC4_68;
     
      input reg [67:0] data;
      output reg [3:0] CRC4_result;
      
      reg [67:0] data_copy;
      reg [3:0] Result;

      begin
         data_copy = data;
         Result[0] = data_copy[66] ^ data_copy[64] ^ data_copy[63] ^ data_copy[60] ^ data_copy[56] ^ data_copy[55] ^ data_copy[54] ^ data_copy[53] ^ data_copy[51] ^ data_copy[49] ^ data_copy[48] ^ data_copy[45] ^ data_copy[41] ^ data_copy[40] ^ data_copy[39] ^ data_copy[38] ^ data_copy[36] ^ data_copy[34] ^ data_copy[33] ^ data_copy[30] ^ data_copy[26] ^ data_copy[25] ^ data_copy[24] ^ data_copy[23] ^ data_copy[21] ^ data_copy[19] ^ data_copy[18] ^ data_copy[15] ^ data_copy[11] ^ data_copy[10] ^ data_copy[9] ^ data_copy[8] ^ data_copy[6] ^ data_copy[4] ^ data_copy[3] ^ data_copy[0];
         Result[1] = data_copy[67] ^ data_copy[66] ^ data_copy[65] ^ data_copy[63] ^ data_copy[61] ^ data_copy[60] ^ data_copy[57] ^ data_copy[53] ^ data_copy[52] ^ data_copy[51] ^ data_copy[50] ^ data_copy[48] ^ data_copy[46] ^ data_copy[45] ^ data_copy[42] ^ data_copy[38] ^ data_copy[37] ^ data_copy[36] ^ data_copy[35] ^ data_copy[33] ^ data_copy[31] ^ data_copy[30] ^ data_copy[27] ^ data_copy[23] ^ data_copy[22] ^ data_copy[21] ^ data_copy[20] ^ data_copy[18] ^ data_copy[16] ^ data_copy[15] ^ data_copy[12] ^ data_copy[8] ^ data_copy[7] ^ data_copy[6] ^ data_copy[5] ^ data_copy[3] ^ data_copy[1] ^ data_copy[0];
         Result[2] = data_copy[67] ^ data_copy[66] ^ data_copy[64] ^ data_copy[62] ^ data_copy[61] ^ data_copy[58] ^ data_copy[54] ^ data_copy[53] ^ data_copy[52] ^ data_copy[51] ^ data_copy[49] ^ data_copy[47] ^ data_copy[46] ^ data_copy[43] ^ data_copy[39] ^ data_copy[38] ^ data_copy[37] ^ data_copy[36] ^ data_copy[34] ^ data_copy[32] ^ data_copy[31] ^ data_copy[28] ^ data_copy[24] ^ data_copy[23] ^ data_copy[22] ^ data_copy[21] ^ data_copy[19] ^ data_copy[17] ^ data_copy[16] ^ data_copy[13] ^ data_copy[9] ^ data_copy[8] ^ data_copy[7] ^ data_copy[6] ^ data_copy[4] ^ data_copy[2] ^ data_copy[1];
         Result[3] = data_copy[67] ^ data_copy[65] ^ data_copy[63] ^ data_copy[62] ^ data_copy[59] ^ data_copy[55] ^ data_copy[54] ^ data_copy[53] ^ data_copy[52] ^ data_copy[50] ^ data_copy[48] ^ data_copy[47] ^ data_copy[44] ^ data_copy[40] ^ data_copy[39] ^ data_copy[38] ^ data_copy[37] ^ data_copy[35] ^ data_copy[33] ^ data_copy[32] ^ data_copy[29] ^ data_copy[25] ^ data_copy[24] ^ data_copy[23] ^ data_copy[22] ^ data_copy[20] ^ data_copy[18] ^ data_copy[17] ^ data_copy[14] ^ data_copy[10] ^ data_copy[9] ^ data_copy[8] ^ data_copy[7] ^ data_copy[5] ^ data_copy[3] ^ data_copy[2];
         CRC4_result = Result;
      end
   endtask
endmodule
