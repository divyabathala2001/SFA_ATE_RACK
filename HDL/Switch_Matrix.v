//switch configuration for SP2T and SP4T switches followed the standard of switch ICs used in the design. later we have to check and confirm with the RF Team 

module switch_matrix_controller(
input wire i_clk_50mhz,
input wire i_reset_n,

input wire i_matrix_valid,

input wire i_RF_IN,
input wire [1:0]i_BITE_IN, //2'b00-> BITE_IN_sig_gen,  2'b01->BITE_IN_spect_anal 
input wire [1:0]i_RF_OUT,  //2'b10->RF_OUT_spect_anal, 2'b11->RF_OUT_power_meter

output reg      o_SP2T_1_ctrl,//port side control switches 
output reg [1:0]o_SP4T_1_ctrl,
output reg [1:0]o_SP4T_2_ctrl,
output reg      o_SP2T_2_ctrl,//instrument side control switches
output reg      o_SP2T_3_ctrl

);

localparam BITE_IN_sig_gen    = 2'b00;  
localparam BITE_IN_spect_anal = 2'b01; 
localparam RF_OUT_spect_anal  = 2'b10; 
localparam RF_OUT_power_meter = 2'b11;  

always @(posedge i_clk_50mhz or negedge i_reset_n)begin
    if(!i_reset_n)begin
        o_SP2T_1_ctrl  <= 1'b1;  //default termination considering as 1'b1
        o_SP4T_1_ctrl  <= 2'b10; //default termination considering  as 2'b10
        o_SP4T_2_ctrl  <= 2'b10; //default termination considering  as 2'b10
    end else begin
    if(i_matrix_valid)begin
        //switching logic for RF_IN
        if (i_RF_IN) begin
            o_SP2T_1_ctrl <= 1'b0;
            o_SP2T_2_ctrl <= 1'b0;
        end else begin
            o_SP2T_1_ctrl <= 1'b1;  //default termination considering as 1'b1
        end

        //switching logic for BITE_IN 
        case (i_BITE_IN)
        BITE_IN_sig_gen : begin    //i_BITE_IN = 00
            o_SP4T_1_ctrl <= 2'b00;
            o_SP2T_2_ctrl <= 1'b1;
        end
        BITE_IN_spect_anal : begin //i_BITE_IN = 01
            o_SP4T_1_ctrl <= 2'b01;
            o_SP2T_3_ctrl <= 1'b0;
        end
        default: begin
            o_SP4T_1_ctrl <= 2'b10; //termination considering as 2'b10
        end
        endcase

        //switching logic for RF_OUT
        case (i_RF_OUT) 
        RF_OUT_spect_anal : begin //i_RF_OUT = 10
            o_SP4T_2_ctrl <= 2'b00; 
            o_SP2T_3_ctrl <= 1'b1;
        end
        RF_OUT_power_meter : begin //i_RF_OUT = 11
            o_SP4T_2_ctrl <= 2'b01;
        end
        default : begin
            o_SP4T_2_ctrl <= 2'b10;//termination considering  as 2'b10
        end
        endcase
        end 
        end
        end
    
endmodule