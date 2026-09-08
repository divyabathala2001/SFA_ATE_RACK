module SFA_ATE_TOP(
input wire i_clk_50mhz,
input wire i_reset_n,

);

wire w_clk_200mhz;
wire locked_sig;

PLL	PLL_inst (
	.areset ( areset_sig  ),
	.inclk0 ( i_clk_50mhz ),
	.c0     ( w_clk_200mhz),
	.locked ( locked_sig  )
);

endmodule