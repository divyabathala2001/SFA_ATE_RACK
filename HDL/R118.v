module R118(
input wire i_clk_50mhz,
input wire i_reset_n,
input wire i_valid,

input wire [2:0]i_band_sel,
input wire [1:0]i_mode,

output wire o_band_a0,
output wire o_band_a1,
output wire o_band_a2,

output reg o_mode_ms0,
output reg o_mode_ms1
);
localparam band_1_2GHZ   = 3'b000;
localparam band_2_6GHZ   = 3'b001;
localparam band_6_10GHZ  = 3'b010;
localparam band_10_14GHZ = 3'b011;
localparam band_14_18GHZ = 3'b100;


localparam BAND_OUT_1_2GHZ   = 3'b001;
localparam BAND_OUT_2_6GHZ   = 3'b010;
localparam BAND_OUT_6_10GHZ  = 3'b011; // document's default band
localparam BAND_OUT_10_14GHZ = 3'b100;
localparam BAND_OUT_14_18GHZ = 3'b101;
localparam BAND_OUT_DEFAULT  = BAND_OUT_6_10GHZ;

localparam mode_BIT_mode_RF          = 2'b00;
localparam mode_ANT_mode_RF          = 2'b01;
localparam mode_Receiver_Termination = 2'b10;
localparam mode_UNUSED               = 2'b11;


reg [2:0] r_band_ctrl;

assign o_band_a2 = r_band_ctrl[2];
assign o_band_a1 = r_band_ctrl[1];
assign o_band_a0 = r_band_ctrl[0];

always @(posedge i_clk_50mhz or negedge i_reset_n)begin
    if(!i_reset_n)begin
        r_band_ctrl <= BAND_OUT_DEFAULT;
        o_mode_ms0  <= 1'b0;
        o_mode_ms1  <= 1'b0;
    end else if (i_valid)begin
        case(i_band_sel)
        band_1_2GHZ   : r_band_ctrl <= BAND_OUT_1_2GHZ;
        band_2_6GHZ   : r_band_ctrl <= BAND_OUT_2_6GHZ;
        band_6_10GHZ  : r_band_ctrl <= BAND_OUT_6_10GHZ;
        band_10_14GHZ : r_band_ctrl <= BAND_OUT_10_14GHZ;
        band_14_18GHZ : r_band_ctrl <= BAND_OUT_14_18GHZ;
        default       : r_band_ctrl <= BAND_OUT_DEFAULT; //6-10GHz is the default band
        endcase

        case(i_mode)
        mode_BIT_mode_RF: begin
            {o_mode_ms1,o_mode_ms0} <= 2'b00;
        end
        mode_ANT_mode_RF: begin
            {o_mode_ms1,o_mode_ms0} <= 2'b10;
        end
        mode_Receiver_Termination: begin
            {o_mode_ms1,o_mode_ms0} <= 2'b01;
        end
        mode_UNUSED: begin
            {o_mode_ms1,o_mode_ms0} <= 2'b11;
        end
        endcase

    end
end
endmodule



// module Sample(
// input wire i_clk_50mhz,
// input wire i_reset_n,
// input wire i_valid,

// input wire [2:0]i_band_sel,
// input wire [1:0]i_mode,

// output reg o_band_a0,
// output reg o_band_a1,
// output reg o_band_a2,

// output reg o_mode_ms0,
// output reg o_mode_ms1
// );
// localparam band_1_2GHZ   = 3'b000;
// localparam band_2_6GHZ   = 3'b001;
// localparam band_6_10GHZ  = 3'b010;
// localparam band_10_14GHZ = 3'b011;
// localparam band_14_18GHZ = 3'b100;


// localparam mode_BIT_mode_RF = 2'b00;
// localparam mode_ANT_mode_RF = 2'b01;
// localparam mode_Receiver_Termination = 2'b10;
// localparam mode_UNUSED = 2'b11;

// always @(posedge i_clk_50mhz or negedge i_reset_n)begin
//     if(!i_reset_n)begin
//         o_band_a0  <= 1'b0;
//         o_band_a1  <= 1'b0;
//         o_band_a2  <= 1'b0;
//         o_mode_ms0 <= 1'b0;
//         o_mode_ms1 <= 1'b0;
//     end else if (i_valid)begin
//         case(i_band_sel)
//         band_1_2GHZ : begin 
//             {o_band_a2,o_band_a1,o_band_a0} <= 3'b001;
//         end
//         band_2_6GHZ : begin 
//             {o_band_a2,o_band_a1,o_band_a0} <= 3'b010;
//         end
//         band_6_10GHZ : begin 
//             {o_band_a2,o_band_a1,o_band_a0} <= 3'b011;
//         end
//         band_10_14GHZ : begin 
//             {o_band_a2,o_band_a1,o_band_a0} <= 3'b100;
//         end
//         band_14_18GHZ : begin 
//             {o_band_a2,o_band_a1,o_band_a0} <= 3'b101;
//         end
//         default : {o_band_a2,o_band_a1,o_band_a0} <= 3'b011; //in document, mentioned 6-10HZ is the default band
//         endcase

//         case(i_mode)
//         mode_BIT_mode_RF: begin
//             {o_mode_ms1,o_mode_ms0} <= 2'b00;
//         end
//         mode_ANT_mode_RF: begin
//             {o_mode_ms1,o_mode_ms0} <= 2'b10;
//         end
//         mode_Receiver_Termination: begin
//             {o_mode_ms1,o_mode_ms0} <= 2'b01;
//         end
//         mode_UNUSED: begin
//             {o_mode_ms1,o_mode_ms0} <= 2'b11;
//         end
//         endcase
        
//     end
// end
// endmodule