`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:02:17 03/06/2026 
// Design Name: 
// Module Name:    gpu_tensor_core 
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
module gpu_tensor_core (
    input  wire         clk,
    input  wire         reset,
    
    // control interface with CPU
    input  wire         start_mac,     
    output wire         mac_done,      // notify CPU
    
    // data interface with BRAM (up to 144 bits/cycle)
    input  wire [143:0] bram_data_in,  
    
    // calculated result write back (BRAM or net)
    output wire [71:0]  gpu_data_out,  
    output wire         gpu_out_valid  
);
endmodule