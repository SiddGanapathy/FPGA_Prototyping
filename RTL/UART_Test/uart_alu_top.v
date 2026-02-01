`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Siddanth Ganapathy & Gagan M
// 
// Create Date: 12/16/2025 11:57:15 AM
// Design Name: Uart_alu_top
// Module Name: uart_alu_top
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
    reg         rx_req_r, rx_req_nxt;
    wire        rx_error;

    // ============================================================
    // ALU control signals
    // ============================================================
    reg         alu_start_r,  alu_start_nxt;
    reg         alu_op_sel_r, alu_op_sel_nxt;
    reg  [7:0]  a_data,a_data_nxt;
    reg  [7:0]  b_data,b_data_nxt;
    reg  [7:0]  data_in,data_in_nxt;
    wire [7:0]  a,b;
    wire        alu_done;   
    wire        rx_req;
    wire        alu_start;
    wire        alu_op_sel;

    // ============================================================
    // State CONTROL signals
    // ============================================================
    reg         wrt_busy, wrt_busy_nxt;
    reg         rd_busy, rd_busy_nxt;
    
    // ============================================================
    // BRAM CONTROL signals
    // ============================================================
    reg  [2:0]  count,count_nxt;
    wire [2:0]  bram_addr;
    reg  [2:0]  bram_addr_wrt,bram_addr_wrt_nxt;
    reg  [2:0]  bram_addr_rd,bram_addr_rd_nxt;
    reg         bram_we_wrt,bram_we_wrt_nxt;    
    wire [7:0]  bram_dout;    
    wire        wstrb;
    // ============================================================
    // FSM states
    // ============================================================
    localparam [1:0]
        IDLE_Wrt            = 3'h00,
        WAIT_BYTE           = 3'h01,
        Write_Data          = 3'h02,
        Write_DONE          = 3'h03;
    
    reg [2:0] state_wrt, state_wrt_nxt;
    
    localparam [7:0]
        IDLE_Rd             = 8'h00,
        READ_OP             = 8'h01,
        WAIT_A              = 8'h02,
        READ_ADDR_A         = 8'h03,
        WAIT_B              = 8'h04,
        READ_ADDR_B         = 8'h05,
        WAIT_Rd_DONE        = 8'h06;

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
            wrt_busy        <= 1'b0;
            rd_busy         <= 1'b0;            
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
            wrt_busy        <= wrt_busy_nxt;
            rd_busy         <= rd_busy_nxt;
            data_in         <= data_in_nxt; 
            count           <= count_nxt;
            rx_req_r        <= rx_req_nxt;
            alu_start_r     <= alu_start_nxt;
            alu_op_sel_r    <= alu_op_sel_nxt;
            bram_addr_wrt   <= bram_addr_wrt_nxt;
            bram_we_wrt     <= bram_we_wrt_nxt;
            bram_addr_rd    <= bram_addr_rd_nxt;
            a_data          <= a_data_nxt;
            b_data          <= b_data_nxt;
       
        end
    end

    // ============================================================
    //  Combinational block
    // ============================================================
    always @(*) begin
        // defaults (hold state)
        state_wrt_nxt     = state_wrt;
        state_rd_nxt      = state_rd;
        wrt_busy_nxt      = wrt_busy;
        rd_busy_nxt       = rd_busy;
        rx_req_nxt        = 1'b0;
        alu_start_nxt     = 1'b0;
        data_in_nxt       = data_in;
        count_nxt         = count;
        bram_addr_wrt_nxt = bram_addr_wrt;
        bram_we_wrt_nxt   = 1'b0;
        bram_addr_rd_nxt  = bram_addr_rd;
        alu_op_sel_nxt    = alu_op_sel_r;
        a_data_nxt        = a_data;
        b_data_nxt        = b_data;
        
/////////////---------- Write BRAM FSM-------------////////////////
    case (state_wrt)
    
        IDLE_Wrt: begin
            if (fifo_full && !rd_busy) begin
                wrt_busy      = 1'b1;
                count_nxt     = 3'd0;
                rx_req_nxt    = 1'b1;    
                state_wrt_nxt = WAIT_BYTE; 
            end
            else begin
                wrt_busy_nxt  = wrt_busy;
                count_nxt     = count;
                rx_req_nxt    = rx_req_r;    
                state_wrt_nxt = state_wrt; 
            end            
        end    
        WAIT_BYTE: begin
            data_in_nxt   = rx_data;
            state_wrt_nxt = Write_Data;
        end
        Write_Data: begin
            bram_we_wrt_nxt   = 1'b1;
            bram_addr_wrt_nxt = count;
           // data_in_nxt       = data_in;  
            if (count == 3'd7) begin
                count_nxt     = 3'd0;
                state_wrt_nxt = Write_DONE;
            end
            else begin
                count_nxt     = count + 1'b1;
                rx_req_nxt    = 1'b1;      
                state_wrt_nxt = WAIT_BYTE; 
            end
        end
        Write_DONE: begin
            wrt_busy_nxt  = 1'b0;
            rd_busy_nxt   = 1'b1;        
            state_wrt_nxt = IDLE_Wrt;
        end

        // =====================================================
        default: begin
            state_wrt_nxt = IDLE_Wrt;
        end

    endcase
        
/////////////---------- Read BRAM FSM-------------////////////////
      
        case (state_rd)
            // ------------------------------------------------
            IDLE_Rd: begin
                if(rd_busy && !wrt_busy) begin
                    state_rd_nxt    = READ_OP;
                end
                else begin
                    state_rd_nxt    = state_rd;
                end
            end             
            READ_OP: begin
                    alu_op_sel_nxt    = op_sel_sw;
                    bram_addr_rd_nxt  = bram_addr_rd;                    
                    state_rd_nxt      = WAIT_A;
            end
            WAIT_A: begin
                    state_rd_nxt     = READ_ADDR_A;
            end
            READ_ADDR_A: begin
                    a_data_nxt        = bram_dout;     
                    bram_addr_rd_nxt  = bram_addr_rd +3'd1;                                   
                    state_rd_nxt      = WAIT_B;
            end
            WAIT_B: begin
                    state_rd_nxt     = READ_ADDR_B;
            end            
            READ_ADDR_B: begin
                    b_data_nxt        = bram_dout;
                    bram_addr_rd_nxt  = bram_addr_rd +3'd1;                    
                    alu_start_nxt     = 1'b1;                    
                    state_rd_nxt      = WAIT_Rd_DONE;              
            end
            WAIT_Rd_DONE: begin
                    rd_busy_nxt       = 1'b0;                                
                if (alu_done)begin
                    rd_busy_nxt     = 1'b1;
                    state_rd_nxt    = READ_OP;
                end
                else begin                   
                    state_rd_nxt    = state_rd;                                
                end
            end
            default: begin
                state_rd_nxt   = IDLE_Rd;
            end
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