`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Siddanth Ganpathy & Gagan M
// 
// Create Date: 12/16/2025 11:57:15 AM
// Design Name: Alu_fifo
// Module Name: alu_add_sub_bram
// Project Name: UART_Test
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision: 07/02/2026
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module alu_add_sub_bram (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        start,
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    input  wire        op_sel,
    output wire [15:0] result,
    output wire        done
);

    reg [1:0] state, state_next;
    reg [15:0] reg_result, reg_result_next;
    reg reg_done, reg_done_next;
    reg [25:0] count,count_nxt;

    localparam IDLE      = 1'b0,
               EXEC      = 1'b1;

    // ======================
    // Sequential logic
    // ======================
    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            state         <= IDLE;
            reg_result    <= 0;
            reg_done      <= 0;
            count         <= 0;
        end else begin
            state         <= state_next;
            reg_result    <= reg_result_next;
            reg_done      <= reg_done_next;
            count         <= count_nxt;
        end
    end

    // ======================
    // Combinational logic
    // ======================
    always @(*) begin
        state_next          = state;
        reg_result_next     = reg_result;
        reg_done_next       = 1'b0;
        count_nxt           = count;

        case (state)
            IDLE: begin
                if (start) begin
                    state_next  = EXEC;
                end
                else begin
                    state_next  = state;
                end
            end
            EXEC: begin
            
                if (count == 26'd50_000_000) begin   // visible delay (~1s @50MHz)
                    reg_result_next = (op_sel == 0) ? (a + b) : (a - b);
                    reg_done_next   = 1'b1;
                    count_nxt       = 0;
                    state_next      = IDLE;
                end 
                else begin
                    count_nxt       = count + 1'b1;
                    reg_done_next   = 1'b0;
                    state_next      = EXEC;
                end
            
            end
            
            default: state_next = IDLE;
        endcase
    end

    assign result    = reg_result;
    assign done      = reg_done;

endmodule
