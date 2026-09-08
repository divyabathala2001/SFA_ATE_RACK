module Pulse_Gen #(parameter CLK_PERIOD_NS = 5, parameter width =16)//Assuming the clock to be 200MHZ
(
  input wire i_Clock,
  input wire i_Reset,
  input wire i_valid_start,
  input wire i_valid_stop,
  input wire [width-1 : 0] i_PW,//in ns
  input wire [width-1 : 0] i_PRI,//in ns
  output wire o_Pulse
);
//assuming PRI is never zero
reg out_Pulse;
reg stop_pending;
reg [width-1:0]counter;
reg [width-1:0]r_pw_cycles;
reg [width-1:0]r_pri_cycles;

wire [width-1:0]w_pw_cycles  = i_PW / CLK_PERIOD_NS;
wire [width-1:0]w_pri_cycles = i_PRI/ CLK_PERIOD_NS;

reg state;
localparam IDLE = 1'd0;
localparam RUN  = 1'd1;

assign o_Pulse  = out_Pulse;



/*always @(posedge i_Clock or negedge i_Reset)begin 
  if (~i_Reset)begin 
    r_pw_cycles<=0;
    r_pri_cycles<=0;
  end
  else begin 
    r_pw_cycles<= i_PW / CLK_PERIOD_NS;
    r_pri_cycles<= i_PRI/ CLK_PERIOD_NS;
  end
end*/

always@(posedge i_Clock or negedge i_Reset)begin 
  if (~i_Reset)begin
    state<=IDLE;
    counter<=0;
    out_Pulse<=0;
    stop_pending<=0;
  end
  else begin
    if (i_valid_stop)begin
      stop_pending<=1;
    end
    case (state)
    IDLE:begin
      out_Pulse<=0;
      counter<=0;
      r_pw_cycles<= w_pw_cycles;
      r_pri_cycles<= w_pri_cycles;
      if (i_valid_start)begin
        state<= RUN;
        stop_pending<=0;
        counter<=0;
      end
    end
    RUN: begin
        if (counter>=r_pri_cycles-1)begin
          counter<=0;
          if (stop_pending)begin
            state<=IDLE;
            stop_pending<=0;
          end
        end
        else begin
          counter<=counter+1;
        end
        if (counter<r_pw_cycles)begin
          out_Pulse<=1;
        end
        else begin
          out_Pulse<=0;
      end
    end
    endcase
    
  end
end
endmodule