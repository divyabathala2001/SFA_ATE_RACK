module UART_Frame(
    input wire i_clk,
    input wire i_rst_n,
    input wire i_en,
    input wire i_uart_rx_valid,
    input wire [7:0] i_uart_rx_data,
    // TurnONOFF Address Wires
    output wire o_ON,
    output wire o_OFF,
    // Loom Address Wires
    output wire o_Start_Loom,
    // LED Address Wires
    output wire o_Start_LED,

    // Tarang Address Wires
    output wire o_Tarang_DATA_VALID,
    output wire [1:0] o_Tarang_BAND,
    output wire o_Tarang_MODE,
    output wire o_Tarang_PORT,
    output wire [15:0] o_Pulse_width,
    output wire [15:0] o_PRI,

    // R118 Address Wires
    output wire o_R118_DATA_VALID,
    output wire [2:0] o_R118_BAND,
    output wire [1:0] o_R118_MODE,

    // Switch_matrix Address Wires
    output wire o_Switch_matrix_DATA_VALID
    output wire o_RF_IN,
    output wire [1:0] o_RF_OUT,
    output wire [1:0] o_BITE_IN
);
    // TurnONOFF Registers
    reg r_TurnONOFF_DATA_VALID;
    reg r_ON;
    reg r_OFF;
    // Loom Registers
    reg r_Loom_DATA_VALID;
    reg r_Start_Loom;
    // LED Registers
    reg r_LED_DATA_VALID;
    reg r_Start_LED;
    // Tarang Registers
    reg r_Tarang_DATA_VALID;
    reg [1:0] r_Tarang_BAND;
    reg r_Tarang_MODE;
    reg r_Tarang_PORT;
    reg [15:0] r_Pulse_width;
    reg [15:0] r_PRI;
    // R118 Registers
    reg r_R118_DATA_VALID;
    reg [2:0] r_R118_BAND;
    reg [1:0] r_R118_MODE;
    // Switch_matrix Registers
    reg r_Switch_matrix_DATA_VALID;
    reg r_RF_IN;
    reg [1:0] r_RF_OUT;
    reg [1:0] r_BITE_IN;

    // TurnONOFF Assign Statements
    assign o_ON = r_ON;
    assign o_OFF = r_OFF;
    // Loom Assign Statements
    assign o_Start_Loom = r_Start_Loom;
    // LED Assign Statements
    assign o_Start_LED = r_Start_LED;
    // Tarang Assign Statements
    assign o_Tarang_BAND = r_Tarang_BAND;
    assign o_Tarang_MODE = r_Tarang_MODE;
    assign o_Tarang_PORT = r_Tarang_PORT;
    assign o_Pulse_width = r_Pulse_width;
    assign o_PRI = r_PRI;
    // R118 Assign Statements
    assign o_R118_BAND = r_R118_BAND;
    assign o_R118_MODE = r_R118_MODE;
    // Switch_matrix Assign Statements
    assign o_RF_IN = r_RF_IN;
    assign o_RF_OUT = r_RF_OUT;
    assign o_BITE_IN = r_BITE_IN;

    // Frame Data Valid Assign Statements
    assign o_TurnONOFF_DATA_VALID = r_TurnONOFF_DATA_VALID;
    assign o_Loom_DATA_VALID = r_Loom_DATA_VALID;
    assign o_LED_DATA_VALID = r_LED_DATA_VALID;
    assign o_Tarang_DATA_VALID = r_Tarang_DATA_VALID;
    assign o_R118_DATA_VALID = r_R118_DATA_VALID;
    assign o_Switch_matrix_DATA_VALID = r_Switch_matrix_DATA_VALID;


    localparam TurnONOFF_PACKET_LENGTH = 2;
    wire [(TurnONOFF_PACKET_LENGTH*8) - 1 : 0] w_TurnONOFF_DATA;
    wire w_TurnONOFF_DATA_VALID;

    UART_packet_identifier #(
        .RX_PACKET_LEN(TurnONOFF_PACKET_LENGTH),
        .IDENTIFIER(4'hA),
        .HEADER(8'hAA),
        .IDENTIFIER_START_INDEX(0),
        .IDENTIFIER_END_INDEX(3),
        .FOOTER(8'h55)
    ) TurnONOFF_id_inst(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_en(1'b1),
        .i_uart_rx_data(i_uart_rx_data),
        .i_uart_rx_valid(i_uart_rx_valid),
        .o_data(w_TurnONOFF_DATA),
        .o_data_valid(w_TurnONOFF_DATA_VALID)
    );
    localparam Loom_PACKET_LENGTH = 2;
    wire [(Loom_PACKET_LENGTH*8) - 1 : 0] w_Loom_DATA;
    wire w_Loom_DATA_VALID;

    UART_packet_identifier #(
        .RX_PACKET_LEN(Loom_PACKET_LENGTH),
        .IDENTIFIER(4'hB),
        .HEADER(8'hAA),
        .IDENTIFIER_START_INDEX(0),
        .IDENTIFIER_END_INDEX(3),
        .FOOTER(8'h55)
    ) Loom_id_inst(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_en(1'b1),
        .i_uart_rx_data(i_uart_rx_data),
        .i_uart_rx_valid(i_uart_rx_valid),
        .o_data(w_Loom_DATA),
        .o_data_valid(w_Loom_DATA_VALID)
    );
    localparam LED_PACKET_LENGTH = 2;
    wire [(LED_PACKET_LENGTH*8) - 1 : 0] w_LED_DATA;
    wire w_LED_DATA_VALID;

    UART_packet_identifier #(
        .RX_PACKET_LEN(LED_PACKET_LENGTH),
        .IDENTIFIER(4'hC),
        .HEADER(8'hAA),
        .IDENTIFIER_START_INDEX(0),
        .IDENTIFIER_END_INDEX(3),
        .FOOTER(8'h55)
    ) LED_id_inst(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_en(1'b1),
        .i_uart_rx_data(i_uart_rx_data),
        .i_uart_rx_valid(i_uart_rx_valid),
        .o_data(w_LED_DATA),
        .o_data_valid(w_LED_DATA_VALID)
    );
    localparam Tarang_PACKET_LENGTH = 6;
    wire [(Tarang_PACKET_LENGTH*8) - 1 : 0] w_Tarang_DATA;
    wire w_Tarang_DATA_VALID;

    UART_packet_identifier #(
        .RX_PACKET_LEN(Tarang_PACKET_LENGTH),
        .IDENTIFIER(4'hD),
        .HEADER(8'hAA),
        .IDENTIFIER_START_INDEX(0),
        .IDENTIFIER_END_INDEX(3),
        .FOOTER(8'h55)
    ) Tarang_id_inst(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_en(1'b1),
        .i_uart_rx_data(i_uart_rx_data),
        .i_uart_rx_valid(i_uart_rx_valid),
        .o_data(w_Tarang_DATA),
        .o_data_valid(w_Tarang_DATA_VALID)
    );
    localparam R118_PACKET_LENGTH = 3;
    wire [(R118_PACKET_LENGTH*8) - 1 : 0] w_R118_DATA;
    wire w_R118_DATA_VALID;

    UART_packet_identifier #(
        .RX_PACKET_LEN(R118_PACKET_LENGTH),
        .IDENTIFIER(4'hE),
        .HEADER(8'hAA),
        .IDENTIFIER_START_INDEX(0),
        .IDENTIFIER_END_INDEX(3),
        .FOOTER(8'h55)
    ) R118_id_inst(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_en(1'b1),
        .i_uart_rx_data(i_uart_rx_data),
        .i_uart_rx_valid(i_uart_rx_valid),
        .o_data(w_R118_DATA),
        .o_data_valid(w_R118_DATA_VALID)
    );
    localparam Switch_matrix_PACKET_LENGTH = 3;
    wire [(Switch_matrix_PACKET_LENGTH*8) - 1 : 0] w_Switch_matrix_DATA;
    wire w_Switch_matrix_DATA_VALID;

    UART_packet_identifier #(
        .RX_PACKET_LEN(Switch_matrix_PACKET_LENGTH),
        .IDENTIFIER(4'h2),
        .HEADER(8'hAA),
        .IDENTIFIER_START_INDEX(0),
        .IDENTIFIER_END_INDEX(3),
        .FOOTER(8'h55)
    ) Switch_matrix_id_inst(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_en(1'b1),
        .i_uart_rx_data(i_uart_rx_data),
        .i_uart_rx_valid(i_uart_rx_valid),
        .o_data(w_Switch_matrix_DATA),
        .o_data_valid(w_Switch_matrix_DATA_VALID)
    );

    always @(posedge i_clk or negedge i_rst_n) begin
        if(i_rst_n == 1'b0) begin
            r_ON <= 0;
            r_OFF <= 0;
            r_TurnONOFF_DATA_VALID <= 1'b0;
        end
        else begin
            r_TurnONOFF_DATA_VALID <= 1'b0;
            if(i_en) begin
                r_ON <= 0;
                r_OFF <= 0; 
                if(w_TurnONOFF_DATA_VALID) begin
                    r_ON <= w_TurnONOFF_DATA[4:4];
                    r_OFF <= w_TurnONOFF_DATA[5:5];
                    r_TurnONOFF_DATA_VALID <= 1'b1;
                end
            end
        end
    end
    always @(posedge i_clk or negedge i_rst_n) begin
        if(i_rst_n == 1'b0) begin
            r_Start_Loom <= 0;
            r_Loom_DATA_VALID <= 1'b0;
        end
        else begin
            r_Loom_DATA_VALID <= 1'b0;
            if(i_en) begin
                r_Start_Loom <= 0;
                if(w_Loom_DATA_VALID) begin
                    r_Start_Loom <= w_Loom_DATA[4:4];
                    r_Loom_DATA_VALID <= 1'b1;
                end
            end
        end
    end
    always @(posedge i_clk or negedge i_rst_n) begin
        if(i_rst_n == 1'b0) begin
            r_Start_LED <= 0;
            r_LED_DATA_VALID <= 1'b0;
        end
        else begin
            r_LED_DATA_VALID <= 1'b0;
            r_Start_LED <= 0;
            if(i_en) begin
                if(w_LED_DATA_VALID) begin
                    r_Start_LED <= w_LED_DATA[4:4];
                    r_LED_DATA_VALID <= 1'b1;
                end
            end
        end
    end
    always @(posedge i_clk or negedge i_rst_n) begin
        if(i_rst_n == 1'b0) begin
            r_Tarang_BAND <= 0;
            r_Tarang_MODE <= 0;
            r_Tarang_PORT <= 0;
            r_Pulse_width <= 0;
            r_PRI <= 0;
            r_Tarang_DATA_VALID <= 1'b0;
        end
        else begin
            r_Tarang_DATA_VALID <= 1'b0;
            if(i_en) begin
                if(w_Tarang_DATA_VALID) begin
                    r_Tarang_BAND <= w_Tarang_DATA[5:4];
                    r_Tarang_MODE <= w_Tarang_DATA[6:6];
                    r_Tarang_PORT <= w_Tarang_DATA[7:7];
                    r_Pulse_width <= w_Tarang_DATA[23:8];
                    r_PRI <= w_Tarang_DATA[39:24];
                    r_Tarang_DATA_VALID <= 1'b1;
                end
            end
        end
    end
    always @(posedge i_clk or negedge i_rst_n) begin
        if(i_rst_n == 1'b0) begin
            r_R118_BAND <= 0;
            r_R118_MODE <= 0;
            r_R118_DATA_VALID <= 1'b0;
        end
        else begin
            r_R118_DATA_VALID <= 1'b0;
            if(i_en) begin
                if(w_R118_DATA_VALID) begin
                    r_R118_BAND <= w_R118_DATA[6:4];
                    r_R118_MODE <= w_R118_DATA[9:8];
                    r_R118_DATA_VALID <= 1'b1;
                end
            end
        end
    end
    always @(posedge i_clk or negedge i_rst_n) begin
        if(i_rst_n == 1'b0) begin
            r_RF_IN <= 0;
            r_RF_OUT <= 0;
            r_BITE_IN <= 0;
            r_Switch_matrix_DATA_VALID <= 1'b0;
        end
        else begin
            r_Switch_matrix_DATA_VALID <= 1'b0;
            if(i_en) begin
                if(w_Switch_matrix_DATA_VALID) begin
                    r_RF_IN <= w_Switch_matrix_DATA[4:4];
                    r_RF_OUT <= w_Switch_matrix_DATA[6:5];
                    r_BITE_IN <= w_Switch_matrix_DATA[9:8];
                    r_Switch_matrix_DATA_VALID <= 1'b1;
                end
            end
        end
    end
endmodule