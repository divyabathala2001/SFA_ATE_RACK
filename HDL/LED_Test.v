//need to confirm this led's are active high or active low, if they are active low then need to change the logic in led_on state
module LED_Controller #(
parameter clk_freq    = 50_000_000, // 50 MHz
parameter led_on_time = 2           //2 seconds 
)(
input wire i_clk_50mhz,
input wire i_reset_n,

input wire i_led_on_valid,

output reg [31:0] o_led //32 led's are used in the schematic 
);

//cycles/seconds = clk_freq
//total cycles for led_on_time (in seconds) = clk_freq * led_on_time 
localparam total_cycles = clk_freq * led_on_time;

localparam idle         = 1'd0;
localparam led_on       = 1'd1;

reg [31:0] timer;
reg        state;

always @(posedge i_clk_50mhz or negedge i_reset_n) begin
    if (!i_reset_n) begin
        state <= idle;
        o_led <= 32'b0;
        timer <= 32'b0;
    end else begin

        case (state)
        idle : begin
            o_led <= 32'b0;
            timer <= 32'b0;
            if(i_led_on_valid) begin
                timer <= total_cycles;
                state <= led_on;
            end
        end
        led_on : begin
            o_led <= {32{1'b1}};
            if(timer <= 32'b1)begin
                o_led <= {32{1'b0}};
                state <= idle;
            end else begin
                timer <= timer - 1'b1;
            end
        end
        default : state <= idle;
        endcase
    end
end           
endmodule
