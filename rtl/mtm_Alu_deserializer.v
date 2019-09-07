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
 
 
 module mtm_Alu_deserializer (
	input  wire clk,
	input  wire rst,
	input  wire sin,
	
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
	
	
	

	always @ (posedge clk or posedge rst) begin
		if(rst) begin
			B_out 	 		<= 0;
			B_out_nxt		<= 0;
			A_out			<= 0;
			A_out_nxt		<= 0;
			oprnt_out 		<= 0;
			err_flg_out 	<= 0;
			state			<= 'IDLE;
			state_nxt		<= 'IDLE;
			bit_cnt			<= 0;
			bit_cnt_nxt		<= 0;
			frame_cnt		<= 0;
			frame_cnt_nxt	<= 0;
			crc_check		<= 0;
			crc_check_nxt	<= 0;
			
		end
		else begin
			B_out 	 	<= B_out_nxt;
			A_out		<= A_out_nxt;
			oprnt_out 	<= oprnt_out_nxt;
			err_flg_out <= err_flg_out_nxt;	
			state		<= state_nxt;
			bit_cnt		<= bit_cnt_nxt;
			frame_cnt	<= frame_cnt_nxt;
			crc_check	<= crc_check_nxt;
			
		end
	end
	
	always @* begin
		case(state)
		
			'IDLE: begin
				if (sin == 0) begin
					state_nxt = 'TYPE;
				end
				else begin
					state_nxt = 'IDLE;
				end
			end
			
			'TYPE: begin
				if (sin == 0) begin
					state_nxt = 'DATA;
				end
				else begin
					if 
					state_nxt = 'CMD;
				end
			end
			
			'DATA: begin
				if (bit_cnt == 8) begin
					state_nxt = 'IDLE;
				end
				else begin
					state_nxt = 'DATA;
				end
			end
			
			'CMD: begin
				if (bit_cnt == 8) begin
					state_nxt = 'CHECK_DATA;
				end
				else begin
					state_nxt = 'CMD;
				end
			end
			
			'CHECK_DATA: begin
				state_nxt = 'SEND_DATA;
			end
			
			'SEND_DATA: begin
				state_nxt - 'IDLE;
			end
			
			default:
			end
		endcase	
	end
	
	always @* begin
		case(state_nxt)
		
			'IDLE: begin
				bit_cnt_nxt = 0;
				frame_cnt_nxt = frame_cnt;

			end
			
			'TYPE: begin
				bit_cnt_nxt = 0;
				frame_cnt_nxt = frame_cnt;
				
			end
			
			'DATA: begin
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
			end
			
			'CMD: begin
				bit_cnt_nxt = bit_cnt + 1;
				
				if (bit_cnt > 0 && bit_cnt < 4) begin
					oprnt_out_nxt = {oprnt_out[1:0], sin};
				end
				else if (bit_cnt <= 7) begin
					crc_check_nxt = {crc_check[2:0], sin};
				end
				
				if (frame_cnt != 8) begin
					err_flg_out_nxt = err_flg_out | ERR_DATA;
				end
			end
			
			'CHECK_DATA: begin
				
			
			end
			
			'SEND_DATA: begin

			
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
