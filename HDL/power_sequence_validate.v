//ack is pending 
module power_sequnce_validate (
    input wire i_clk_50mhz,
    input wire i_reset_n,

    input wire i_turn_on_valid,
    input wire i_turn_off_valid,

    input wire i_Monitor_Neg12v,     //monitor IC O/P(+12V_Mon) --> fpgai/p(pin:B10)
    input wire i_Monitor_Pos12v,
    input wire i_Monitor_Pos8v,

    output reg o_Relay_Neg12v_Enable,//fpga o/p(pin : AA12)    --> relay driver i/p
    output reg o_Relay_Pos12v_Enable,
    output reg o_Relay_Pos8v_Enable
);
    // Per-stage dwell times, in 50 MHz clock ticks
    localparam RELAY1_DELAY_NEG12V     = 32'd5;  // 5 cycles (100 ns) before -12V turns ON
    localparam RELAY2_DELAY_POS12V     = 32'd5;  // 5 cycles (100 ns) before +12V turns ON
    localparam RELAY3_DELAY_POS8V      = 32'd5;  // 5 cycles (100 ns) before +8V turns ON
    localparam RELAY3_DELAY_POS8V_OFF  = 32'd5;  // 5 cycles (100 ns) before +8V turns OFF
    localparam RELAY2_DELAY_POS12V_OFF = 32'd5;  // 5 cycles (100 ns) before +12V turns OFF
    localparam RELAY1_DELAY_NEG12V_OFF = 32'd5;  // 5 cycles (100 ns) before -12V turns OFF

    // FSM State Encoding
    localparam POWER_OFF  = 3'b000; // All relays OFF (idle / fault-recovery -12v relay off at last)
    localparam NEG12V_ON  = 3'b001; // Step 1: Only -12V relay ON
    localparam POS12V_ON  = 3'b010; // Step 2: -12V and +12V relays ON
    localparam POS8V_ON   = 3'b011; // Step 3: All three relays ON
    localparam POS8V_OFF  = 3'b100; // Step 4: +8V turned OFF first
    localparam POS12V_OFF = 3'b101; // Step 5: +12V turned OFF second

    reg [2:0]  state;
    reg [31:0] delay_counter;

    // Ensures ALL THREE monitor voltages are present
    wire all_monitors_ok = i_Monitor_Neg12v && i_Monitor_Pos12v && i_Monitor_Pos8v;
    reg  buff1_all_monitors_ok;
    reg  buff2_all_monitors_ok;
    reg  buff1_turn_on_valid;
    reg  buff2_turn_on_valid;
    reg  buff1_turn_off_valid;
    reg  buff2_turn_off_valid;

    always @(posedge i_clk_50mhz or negedge i_reset_n) begin
        if (!i_reset_n) begin
            buff1_all_monitors_ok <= 1'b0;
            buff2_all_monitors_ok <= 1'b0;
            buff1_turn_on_valid <= 1'b0;
            buff2_turn_on_valid <= 1'b0;
            buff1_turn_off_valid <= 1'b0;
            buff2_turn_off_valid <= 1'b0;
        end else begin
            buff1_all_monitors_ok <= all_monitors_ok;
            buff2_all_monitors_ok <= buff1_all_monitors_ok;
            buff1_turn_on_valid <= i_turn_on_valid;
            buff2_turn_on_valid <= buff1_turn_on_valid;
            buff1_turn_off_valid <= i_turn_off_valid;
            buff2_turn_off_valid <= buff1_turn_off_valid;
        end
    end


    always @(posedge i_clk_50mhz or negedge i_reset_n) begin
        if (!i_reset_n) begin
            state <= POWER_OFF;
            delay_counter <= 32'd0;
        end else begin
            case (state)

                POWER_OFF: begin
                    if (buff2_all_monitors_ok && buff2_turn_on_valid && !buff2_turn_off_valid) begin
                        if (delay_counter >= RELAY1_DELAY_NEG12V - 1) begin
                            state <= NEG12V_ON;
                            delay_counter <= 32'd0;
                        end else begin
                            delay_counter <= delay_counter + 1'b1;
                        end
                    end else begin
                        delay_counter <= 32'd0;   
                    end
                end

                NEG12V_ON: begin
                    if (!buff2_all_monitors_ok || !buff2_turn_on_valid) begin
                        state <= POWER_OFF;   // only -12V was on -- stop immediately
                        delay_counter <= 32'd0;
                    end else if (delay_counter >= RELAY2_DELAY_POS12V - 1) begin
                        state <= POS12V_ON;
                        delay_counter <= 32'd0;
                    end else begin
                        delay_counter <= delay_counter + 1'b1;
                    end
                end

                POS12V_ON: begin
                    if (!buff2_all_monitors_ok || !buff2_turn_on_valid) begin
                        state <= POS12V_OFF;   // +12V was on but monitors failed -- stop immediately
                        delay_counter <= 32'd0;
                    end else if (delay_counter >= RELAY3_DELAY_POS8V - 1) begin
                        state <= POS8V_ON;
                        delay_counter <= 32'd0;
                    end else begin
                        delay_counter <= delay_counter + 1'b1;
                    end
                end

                POS8V_ON: begin
                    if (!buff2_all_monitors_ok || !buff2_turn_on_valid || buff2_turn_off_valid) begin
                        if (delay_counter >= RELAY3_DELAY_POS8V_OFF - 1) begin
                            state <= POS8V_OFF;
                            delay_counter <= 32'd0;
                         end else begin
                             delay_counter <= delay_counter + 1'b1;
                         end
                    end else begin
                        delay_counter <= 32'd0;   // steady, healthy -- nothing to count toward
                    end
                end

                POS8V_OFF: begin
                     if (delay_counter >= RELAY2_DELAY_POS12V_OFF - 1) begin
                        state <= POS12V_OFF;
                        delay_counter <= 32'd0;
                    end else begin
                        delay_counter <= delay_counter + 1'b1;
                    end
                end

                POS12V_OFF: begin
                     if (delay_counter >= RELAY1_DELAY_NEG12V_OFF - 1) begin
                        state <= POWER_OFF;
                        delay_counter <= 32'd0;
                    end else begin
                        delay_counter <= delay_counter + 1'b1;
                    end
                end

                default: begin
                    state <= POWER_OFF;
                    delay_counter <= 32'd0;
                end

            endcase
        end
    end

    always @(posedge i_clk_50mhz or negedge i_reset_n) begin
        if (!i_reset_n) begin
            o_Relay_Neg12v_Enable <= 1'b0;
            o_Relay_Pos12v_Enable <= 1'b0;
            o_Relay_Pos8v_Enable  <= 1'b0;
        end else begin
            case (state)
                POWER_OFF: begin
                    o_Relay_Neg12v_Enable <= 1'b0;
                    o_Relay_Pos12v_Enable <= 1'b0;
                    o_Relay_Pos8v_Enable  <= 1'b0;
                end

                NEG12V_ON: begin
                    o_Relay_Neg12v_Enable <= 1'b1;
                    o_Relay_Pos12v_Enable <= 1'b0;
                    o_Relay_Pos8v_Enable  <= 1'b0;
                end

                POS12V_ON: begin
                    o_Relay_Neg12v_Enable <= 1'b1;
                    o_Relay_Pos12v_Enable <= 1'b1;
                    o_Relay_Pos8v_Enable  <= 1'b0;
                end

                POS8V_ON: begin
                    o_Relay_Neg12v_Enable <= 1'b1;
                    o_Relay_Pos12v_Enable <= 1'b1;
                    o_Relay_Pos8v_Enable  <= 1'b1;
                end

                POS8V_OFF: begin
                    o_Relay_Neg12v_Enable <= 1'b1;
                    o_Relay_Pos12v_Enable <= 1'b1;
                    o_Relay_Pos8v_Enable  <= 1'b0;   // +8V just turned off
                end

                POS12V_OFF: begin
                    o_Relay_Neg12v_Enable <= 1'b1;
                    o_Relay_Pos12v_Enable <= 1'b0;   // +12V just turned off
                    o_Relay_Pos8v_Enable  <= 1'b0;
                end

                default: begin
                    o_Relay_Neg12v_Enable <= 1'b0;
                    o_Relay_Pos12v_Enable <= 1'b0;
                    o_Relay_Pos8v_Enable  <= 1'b0;
                end
            endcase
        end
    end

endmodule