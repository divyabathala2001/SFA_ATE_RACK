module loom_test(
input wire      i_clk_50mhz,
input wire      i_reset_n,

input wire      i_loom_test_valid,
input wire [9:0]i_loom_pins,

output reg [9:0]o_uut_pins,

output reg o_ack,
output reg o_nack
);

localparam IDLE      = 3'd0;
localparam DRIVE_LOW = 3'd1;
localparam READ_LOW   = 3'd2;
localparam DRIVE_HIGH = 3'd3;
localparam READ_HIGH = 3'd4;
localparam PASS      = 3'd5;
localparam FAIL      = 3'd6;

reg[2:0] state;
reg[3:0] pin_index;

always @(posedge i_clk_50mhz or negedge i_reset_n)begin
    if(!i_reset_n)begin
       state      <= IDLE;
       o_ack      <= 1'b0;
       o_nack     <= 1'b0;
       pin_index  <= 4'd0;
       o_uut_pins <= 10'd0;
    end else begin
        if(i_loom_test_valid)begin
            case (state)
            IDLE : begin
                state     <= DRIVE_LOW;
                pin_index <= 4'd0;
            end

            DRIVE_LOW : begin
                o_uut_pins <= 10'b0000000000;
                state      <=  READ_LOW;
            end
            READ_LOW  : begin
                if(i_loom_pins == 10'b0000000000)begin
                    state      <= DRIVE_HIGH;
                end else begin
                    state      <= FAIL ;
                end
            end
            DRIVE_HIGH : begin
                o_uut_pins <= (1'b1 << pin_index);
                state      <=  READ_HIGH;      
            end
            READ_HIGH : begin
                if(i_loom_pins   == (1'b1 << pin_index))begin
                    if(pin_index == 4'd9)begin
                        state   <= PASS;
                    end else begin
                        pin_index <= pin_index + 4'd1;
                        state     <= DRIVE_HIGH;
                    end
                end else begin
                        state    <= FAIL;
                end
            end
            PASS  : begin
                o_ack  <= 1'b1;
                o_nack <= 1'b0;
                o_uut_pins <= 10'b0;
                if(!i_loom_test_valid) state <= IDLE;
            end
            FAIL: begin
                o_ack      <= 1'b0;
                o_nack     <= 1'b1;
                o_uut_pins <= 10'b0;
                 if (!i_loom_test_valid) state <= IDLE;
                end
                default: state <= IDLE;
           endcase
        end
    end
end
endmodule
