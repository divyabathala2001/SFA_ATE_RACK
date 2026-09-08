module TARANG(    
input wire  i_clk_50mhz,
input wire  i_reset_n,

input wire  i_port, // 1'b1-->antenna_port , 1'b0-->bitport
input wire [1:0]i_band,
input wire  i_valid,

output reg  o_band_a0,
output reg  o_band_a1,
output reg  o_port_a2

);
localparam band1 = 2'b00;
localparam band2 = 2'b01;
localparam band3 = 2'b10;
localparam band4 = 2'b11;

always @(posedge i_clk_50mhz or negedge i_reset_n)begin
if(!i_reset_n)begin
    o_band_a0 <= 1'b0;
    o_band_a1 <= 1'b0;
    o_port_a2 <= 1'b0;
end else if(i_valid)begin
    case (i_band)
    band1: begin
        o_band_a0 <= 1'b1;
        o_band_a1 <= 1'b0;
    end
    band2: begin
        o_band_a0 <= 1'b0;
        o_band_a1 <= 1'b0;
    end
    band3: begin
        o_band_a0 <= 1'b0;
        o_band_a1 <= 1'b1;
    end
    band4: begin
        o_band_a0 <= 1'b1;
        o_band_a1 <= 1'b1;
    end
    endcase
    if(i_port)begin
        o_port_a2 <= 1'b0; //antenna_port
    end else begin
        o_port_a2 <= 1'b1; //bitport
    end
    
end
end
endmodule