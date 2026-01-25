`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2025 11:57:15 AM
// Design Name: 
// Module Name: 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module alu_wrapper (
    input  wire        i_clk,
    input  wire        i_rst_n,

    // Control inputs
    input  wire        start,
    input  wire        op_sel,
    input  wire [7:0]  a_data,
    input  wire [7:0]  b_data,

    // Status / display outputs
    output wire        done,
    output wire [6:0]  seg,
    output wire [3:0]  an
);

    // ALU result
    wire [15:0] alu_result;
    
    // ======================
    // ALU
    // ======================
    alu_add_sub_bram u_alu (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .start     (start),
        .op_sel    (op_sel),
        .a         (a_data),
        .b         (b_data),
        .result    (alu_result),
        .done      (done)
    );

    // ======================
    // Seven segment display
    // ======================
    seven_seg_hex u_seven_seg (
        .i_clk   (i_clk),
        .value (alu_result),
        .seg   (seg),
        .an    (an)
    );

endmodule
