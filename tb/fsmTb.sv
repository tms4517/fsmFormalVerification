// Tb drives count40 input of the FSM and interfaces the assertions to the RTL.

`default_nettype none

module fsmTb;

  /* verilator lint_off UNDRIVEN */
  logic clk;
  logic rst_n;
  /* verilator lint_on UNDRIVEN */

  logic [5:0] count40_d, count40_q;

  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
      count40_q <= '0;
    else
      count40_q <= count40_d;

  always_comb
    if (count40_q == 6'd39)
      count40_d = '0;
    else
      count40_d = count40_q + 1'b1;

  fsmWithBugs u_fsmWithBugs
  ( .clk     (clk)
  , .rst_n   (rst_n)
  , .count40 (count40_q)
  /* verilator lint_off PINCONNECTEMPTY */
  , .tclk  ()
  , .trst  ()
  , .dq_en ()
  , .sr_en ()
  /* verilator lint_on PINCONNECTEMPTY */
  );

  fsmAssertions u_fsmAssertions
  ( .i_clk     (clk)
  , .i_rst_n   (rst_n)
  , .i_count40 (count40_q)

  , .i_fsmCurrentState (u_fsmWithBugs.state)
  );

endmodule

`resetall
