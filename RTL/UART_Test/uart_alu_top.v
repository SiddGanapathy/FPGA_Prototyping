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

module uart_alu_top (
    input  wire        i_clk,
    input  wire        i_rst_n,

    /* UART RX pin */
    input  wire        uart_rx,
    input  wire        op_sel_sw,
    /* Seven segment output */
    output wire [6:0]  seg,
    output wire [3:0]  an
);

    // ============================================================
    // UART RX signals
    // ============================================================
    wire [7:0]  rx_data;
    wire        fifo_empty;
    wire        fifo_full;
    reg         rx_req_r, rx_req_n;
    wire        rx_error;
    // ============================================================
    // ALU control signals
    // ============================================================
    reg         alu_start_r,  alu_start_n;
    reg         alu_op_sel_r, alu_op_sel_n;
    reg  [7:0]  a_data,a_data_n;
    reg  [7:0]  b_data,b_data_n;
    reg  [7:0]  data_in,data_in_n;
    wire [7:0]  a,b;
    wire        alu_done;   
    wire        rx_req;
    wire        alu_start;
    wire        alu_op_sel;

    // ============================================================
    // BRAM CONTROL signals
    // ============================================================
    reg  [2:0]  count,count_n;
    wire [2:0]  bram_addr;
    reg  [2:0]  bram_addr_wrt,bram_addr_wrt_n;
    reg  [2:0]  bram_addr_rd,bram_addr_rd_n;
    reg         bram_we_wrt,bram_we_wrt_n;    
    wire [7:0]  bram_dout;    
    wire        wstrb;
    // ============================================================
    // FSM states
    // ============================================================
    localparam [2:0]
        IDLE_Wrt            = 3'h00,
        Write_Data          = 3'h01,
        Write_DONE          = 3'h02;
        
    reg [2:0] state_wrt, state_wrt_nxt;
    
    localparam [7:0]
        IDLE_Rd             = 8'h00,
        READ_OP             = 8'h01,
        READ_ADDR_A         = 8'h02,
        READ_ADDR_B         = 8'h03,
        WAIT_Rd_DONE        = 8'h04;

    reg [7:0] state_rd, state_rd_nxt;

    // ============================================================
    // Assign registered outputs
    // ============================================================
    assign bram_addr = (state_wrt != IDLE_Wrt) ? bram_addr_wrt : bram_addr_rd;   
    assign wstrb     = (state_wrt != IDLE_Wrt) ? bram_we_wrt : 1'b0;
    assign rx_req     = rx_req_r;
    assign alu_start  = alu_start_r;
    assign alu_op_sel = alu_op_sel_r;
    assign a          = a_data;
    assign b          = b_data;

    // ============================================================
    //  Sequential block
    // ============================================================
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state_wrt       <= IDLE_Wrt;
            state_rd        <= IDLE_Rd;
            data_in         <= 8'd0;
            count           <= 3'd0;
            rx_req_r        <= 1'b0;
            alu_start_r     <= 1'b0;
            alu_op_sel_r    <= 1'b0;
            bram_addr_wrt   <= 3'd0;
            bram_we_wrt     <= 1'b0;
            bram_addr_rd    <= 3'd0;
            a_data          <= 3'd0;
            b_data          <= 3'd0;           
        end else begin
            state_wrt       <= state_wrt_nxt;
            state_rd        <= state_rd_nxt;  
            data_in         <= data_in_n;
            count           <= count_n;
            rx_req_r        <= rx_req_n;
            alu_start_r     <= alu_start_n;
            alu_op_sel_r    <= alu_op_sel_n;
            bram_addr_wrt   <= bram_addr_wrt_n;
            bram_we_wrt     <= bram_we_wrt_n;
            bram_addr_rd    <= bram_addr_rd_n;
            a_data          <= a_data_n;
            b_data          <= b_data_n;
        end
    end

    // ============================================================
    //  Combinational block
    // ============================================================
    always @(*) begin
        // defaults (hold state)
        state_wrt_nxt   = state_wrt;
        state_rd_nxt    = state_rd;
        rx_req_n        = 1'b0;
        alu_start_n     = 1'b0;
        data_in_n       = data_in;
        count_n         = count;
        bram_addr_wrt_n = bram_addr_wrt;
        bram_we_wrt_n   = 1'b0;
        bram_addr_rd_n  = bram_addr_rd;
        alu_op_sel_n    = alu_op_sel_r;
        a_data_n        = a_data;
        b_data_n        = b_data;
        
/////////////---------- Write BRAM FSM-------------////////////////
        case (state_wrt)
            // ------------------------------------------------
            IDLE_Wrt: begin
                if (fifo_full) begin
                    rx_req_n        = 1'b0;
                    state_wrt_nxt   = Write_Data;
                end
                else begin
                    rx_req_n        = 1'b1;
                    state_wrt_nxt   = state_wrt; 
                end
            end            
            Write_Data: begin
                if(count == 3'd7) begin
                    rx_req_n        = 1'b0;                    
                    count_n         = 3'd0;
                    bram_addr_wrt_n = 3'd0;
                    bram_we_wrt_n   = 1'd0;
                    data_in_n       = data_in;
                    state_wrt_nxt   = Write_DONE;                
                end
                else begin
                    rx_req_n        = rx_req_r;                   
                    bram_addr_wrt_n = count;
                    bram_we_wrt_n   = 1'd1;
                    count_n         = count + 1;
                    data_in_n       = rx_data;
                    state_wrt_nxt   = state_wrt;
                end
            end
            Write_DONE: begin 
                    state_wrt_nxt   = IDLE_Wrt;
            end
            default: state_wrt_nxt  = IDLE_Wrt;            
        endcase

/////////////---------- Read BRAM FSM-------------////////////////
        
        case (state_rd)
            // ------------------------------------------------
            IDLE_Rd: begin
                    state_rd_nxt    = READ_OP;
            end             
            READ_OP: begin
                    alu_op_sel_n    = op_sel_sw;
                    bram_addr_rd_n  = bram_addr_rd;                    
                    state_rd_nxt    = READ_ADDR_A;
            end
            READ_ADDR_A: begin
                    a_data_n        = bram_dout;     
                    bram_addr_rd_n  = bram_addr_rd + 3'd4;                                   
                    state_rd_nxt    = READ_ADDR_B;
            end
            READ_ADDR_B: begin
                    b_data_n        = bram_dout;
                    alu_start_n     = 1'b1;                    
                    state_rd_nxt    = WAIT_Rd_DONE;              
            end
            WAIT_Rd_DONE: begin
                    bram_addr_rd_n  = bram_addr_rd + 3'd4;                                
                if (alu_done)begin
                    state_rd_nxt    = READ_OP;
                end
                else begin                   
                    state_rd_nxt    = state_rd;                                
                end
            end
            default: state_rd_nxt   = IDLE_Rd;
        endcase
    end

    // ============================================================
    // UART RX + FIFO
    // ============================================================
    uart_rx_fifo_wrapper uart_rx_inst (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .o_rx_data    (rx_data),
        .i_rx_req     (rx_req),
        .o_fifo_empty (fifo_empty),
        .o_fifo_full  (fifo_full),
        .o_rx_error   (rx_error),
        .o_rts        (),
        .i_rx         (uart_rx)
    );

    // ======================
    // BRAM IP
    // ======================
    blk_mem_gen_0 u_bram (
        .clka   (i_clk),
        .ena    (1'b1),
        .wea    (wstrb),
        .addra  (bram_addr),
        .dina   (data_in),
        .douta  (bram_dout)
    );

    // ============================================================
    // ALU Wrapper
    // ============================================================
    alu_wrapper alu_inst (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .start      (alu_start),
        .op_sel     (alu_op_sel),
        .a_data     (a),
        .b_data     (b),
        .done       (alu_done),
        .seg        (seg),
        .an         (an)

    );

endmodule