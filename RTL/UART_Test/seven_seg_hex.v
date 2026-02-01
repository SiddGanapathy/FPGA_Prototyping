`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Siddanth Ganpathy & Gagan M
// 
// Create Date: 12/16/2025 11:57:15 AM
// Design Name: Seven_seg
// Module Name: seven_seg_hex
// Project Name: UART_Test
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision: 01/02/2026
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module seven_seg_hex (
    input  wire        i_clk,
    input  wire        i_rst_n, 
    input  wire [15:0] value,
    output reg  [6:0]  seg,
    output reg  [3:0]  an
);
    reg [1:0] sel;
    reg [3:0] digit;
    
    // Add reset to sequential logic
    always @(posedge i_clk) begin
        if (!i_rst_n)
            sel <= 2'b00;
        else
            sel <= sel + 1;
    end
    
    always @(*) begin
        case (sel)
            2'd0: begin an = 4'b1110; digit = value[3:0];   end
            2'd1: begin an = 4'b1101; digit = value[7:4];   end
            2'd2: begin an = 4'b1011; digit = value[11:8];  end
            2'd3: begin an = 4'b0111; digit = value[15:12]; end
        endcase
        
        case (digit)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;  // Added default case
        endcase
    end
endmodule