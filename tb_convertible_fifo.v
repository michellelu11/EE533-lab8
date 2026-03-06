`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   01:16:27 03/05/2026
// Design Name:   convertible_fifo
// Module Name:   C:/EE533/lab8/tb_convertible_fifo.v
// Project Name:  lab8
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: convertible_fifo
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_convertible_fifo;

	// Inputs
	reg clk;
	reg reset;
	reg [71:0] net_in_data;
	reg net_in_we;
	reg [71:0] net_out_data;
	reg net_out_re;
	reg mode_sel;
	reg [7:0] proc_addr;
	reg [71:0] proc_data_in;
	reg proc_we;
	reg proc_head_we;
	reg [7:0] proc_head_in;
	reg proc_tail_we;
	reg [7:0] proc_tail_in;

	// Outputs
	wire net_in_full;
	wire net_out_empty;
	wire [71:0] proc_data_out;
	wire pkt_ready;

	// Instantiate the Unit Under Test (UUT)
	convertible_fifo uut (
		.clk(clk), 
		.reset(reset), 
		.net_in_data(net_in_data), 
		.net_in_we(net_in_we), 
		.net_in_full(net_in_full), 
		.net_out_data(net_out_data), 
		.net_out_re(net_out_re), 
		.net_out_empty(net_out_empty), 
		.mode_sel(mode_sel), 
		.proc_addr(proc_addr), 
		.proc_data_in(proc_data_in), 
		.proc_data_out(proc_data_out), 
		.proc_we(proc_we), 
		.proc_head_we(proc_head_we), 
		.proc_head_in(proc_head_in), 
		.proc_tail_we(proc_tail_we), 
		.proc_tail_in(proc_tail_in), 
		.pkt_ready(pkt_ready)
	);
	
    // ???? (? 10ns ??????? 20ns)
	always #10 clk = ~clk;
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		net_in_data = 0;
		net_in_we = 0;
		net_out_data = 0;
		net_out_re = 0;
		mode_sel = 0;
		proc_addr = 0;
		proc_data_in = 0;
		proc_we = 0;
		proc_head_we = 0;
		proc_head_in = 0;
		proc_tail_we = 0;
		proc_tail_in = 0;

      #100;
      reset = 0;
      #20;
		net_in_data = 72'h00_1122334455667788; 
      net_in_we = 1;
      #20;

		net_in_data = 72'h00_AABBCCDDEEFF0011;
      #20;

      net_in_data = 72'hFF_9988776655443322; 
      #20;
        
		net_in_we = 0;
      #40;
       
      mode_sel = 1; 
      #20;


      proc_addr = 8'h00;
      #20;
        
      
      proc_addr = 8'h00;
      proc_data_in = 72'h00_FFFFFFFFFFFFFFFF;
      proc_we = 1;
      #20;
      proc_we = 0;
      #20;

      $stop;
    end
      
endmodule

