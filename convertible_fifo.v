`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:26:18 03/05/2026 
// Design Name: 
// Module Name:    convertible_fifo 
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
module convertible_fifo(
	input wire clk,
	input wire reset,
	
	input wire [71:0] net_in_data,
	input wire net_in_we,
	output wire net_in_full,
	
	input wire [71:0] net_out_data,
	input wire net_out_re,
	output wire net_out_empty,
	
	input wire mode_sel,
	input wire [7:0] proc_addr,
	input wire [71:0] proc_data_in,
	output wire [71:0] proc_data_out,
	input wire proc_we,
	
	input wire proc_head_we,
	input wire [7:0] proc_head_in,
	input wire proc_tail_we,
	input wire [7:0] proc_tail_in,
	
	output wire pkt_ready
    );
	reg [7:0] head_addr;
	reg [7:0] tail_addr;
	reg pkt_buffered_flag;
	wire is_eop = (net_in_we && (net_in_data[71:64] != 8'h00));
	wire [7:0] bram_addra = (mode_sel)?proc_addr:tail_addr;
	wire [71:0] bram_dina = (mode_sel)?proc_data_in: net_in_data;
	wire bram_wea = (mode_sel)?proc_we:(net_in_we && !net_in_full);
	wire [7:0] bram_addrb = (mode_sel)?proc_addr:head_addr;
	
	BRAM core_bram(
		.clka(clk),
		.ena(1'b1),
		.wea(bram_wea),
		.addra(bram_addra),
		.dina(bram_dina),
		.douta(),
		
		.clkb(clk),
		.enb(1'b1),
		.web(1'b0),
		.addrb(bram_addrb),
		.dinb(72'b0),
		.doutb(net_out_data)
	);
	assign proc_data_out = net_out_data;
	assign net_in_full = pkt_buffered_flag;
	assign pkt_ready = pkt_buffered_flag;
	assign net_out_empty = (head_addr == tail_addr);
	
	always @(posedge clk) begin
		if(reset)begin
			head_addr <= 8'b0;
			tail_addr <= 8'b0;
			pkt_buffered_flag <= 1'b0;
		end else begin
			if (proc_head_we) head_addr <= proc_head_in;
			if(proc_tail_we) tail_addr <= proc_tail_in;
			if(!mode_sel)begin
				if(net_in_we && !net_in_full) begin
					tail_addr <= tail_addr +1;
					if(is_eop)begin
						pkt_buffered_flag <= 1'b1;
					end
				end
				if(net_out_re && !net_out_empty)begin
					head_addr <= head_addr +1;
					if((head_addr + 1) == tail_addr) begin
						pkt_buffered_flag <= 1'b0;
					end
				end
			end
			else begin
				if(head_addr == tail_addr) begin
					pkt_buffered_flag <= 1'b0;
				end
			end
		end
	end
endmodule
