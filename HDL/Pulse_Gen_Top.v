module Pulse_Gen_Top#(parameter width =16)
(
  input wire i_Clock,
  input wire i_Reset,
  input wire i_valid_start,
  input wire i_valid_stop,
  input wire [width-1:0] i_PW,//in ns
  input wire [width -1 :0] i_PRI,//in ns
  output wire o_Pulse
);

wire c0_sig;
wire locked_sig;

pll	pll_inst (
	.areset ( ~i_Reset ),
	.inclk0 ( i_Clock ),
	.c0     ( c0_sig ),
	.locked ( locked_sig )
);

pulse_gen pulse_inst(
  .i_Clock      (c0_sig),
  .i_Reset      (i_Reset),
  .i_valid_start(i_valid_start),
  .i_valid_stop (i_valid_stop),
  .i_PW         (i_PW),
  .i_PRI        (i_PRI),
  .o_Pulse      (o_Pulse)
);
endmodule