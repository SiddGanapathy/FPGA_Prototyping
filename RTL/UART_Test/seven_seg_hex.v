`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Siddanth Ganpathy & Gagan M
// Module: seven_seg_hex
// Description:
//   4-digit multiplexed 7-segment HEX display driver
//   Clock: 50 MHz
//   Active-LOW segments and digit enables (common anode)
//////////////////////////////////////////////////////////////////////////////////

module seven_seg_hex (
    input  wire        i_clk,
    input  wire        i_rst_n, 
    input  wire [15:0] value,
    output reg  [6:0]  seg,
    output reg  [3:0]  an
);

    // ---------------------------------------------------------
    // Refresh clock divider
    // 50 MHz / 50,000 = 1 kHz digit refresh
    // ---------------------------------------------------------
    reg [15:0] refresh_cnt;
    reg [1:0]  sel;

    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            refresh_cnt <= 16'd0;
            sel         <= 2'd0;
        end else begin
            refresh_cnt <= refresh_cnt + 1;
            if (refresh_cnt == 16'd49999) begin
                refresh_cnt <= 16'd0;
                sel <= sel + 1;
            end
        end
    end

    // ---------------------------------------------------------
    // Digit select and segment decode
    // ---------------------------------------------------------
    reg [3:0] digit;

    always @(*) begin
        // Defaults (all OFF)
        an    = 4'b1111;
        seg   = 7'b1111111;
        digit = 4'h0;

        // Select active digit
        case (sel)
            2'd0: begin an = 4'b1110; digit = value[3:0];   end
            2'd1: begin an = 4'b1101; digit = value[7:4];   end
            2'd2: begin an = 4'b1011; digit = value[11:8];  end
            2'd3: begin an = 4'b0111; digit = value[15:12]; end
        endcase

        // HEX to 7-seg decode (active LOW)
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
            default: seg = 7'b1111111;
        endcase
    end

endmodule
