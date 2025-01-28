// This module consist of properties of the FSM design `fsmWithBugs.sv`. Each
// property has an associated assertion that will be formally verified.

`default_nettype none

module fsmAssertions
( // FSM inputs
  input var logic       i_clk
, input var logic       i_rst_n
, input var logic [5:0] i_count40

// FSM State
, input var logic [2:0] i_fsmCurrentState
);

  // {{{ Auxillary logic
  typedef enum logic [2:0]
  { STATE_INIT
  , STATE_LOAD_COMMAND
  , STATE_START_FRAME
  , STATE_WRC_LOW
  , STATE_WRC_HIGH
  , STATE_END_FRAME
  , STATE_RDC_LOW
  , STATE_RDC_HIGH
  } ty_STATE_FSM;

  ty_STATE_FSM fsmPreviousState_q;

  // Current state is stored in a register to obtain previous state.
  always_ff @(posedge i_clk, negedge i_rst_n)
    if (!i_rst_n)
      fsmPreviousState_q <= STATE_INIT;
    else
      fsmPreviousState_q <= ty_STATE_FSM'(i_fsmCurrentState);

  logic [5:0] count40Previous_q;

  always_ff @(posedge i_clk, negedge i_rst_n)
    if (!i_rst_n)
      count40Previous_q <= '0;
    else
      count40Previous_q <= i_count40;

    // {{{ FSM Current State
    logic fsmCurrentStateIsLoadCommand, fsmCurrentStateIsStartFrame,
          fsmCurrentStateIsInit, fsmCurrentStateIsEndFrame,
          fsmCurrentStateIsWrcLow, fsmCurrentStateIsWrcHigh,
          fsmCurrentStateIsRdcLow, fsmCurrentStateIsRdcHigh;

    always_comb
      fsmCurrentStateIsInit = (i_fsmCurrentState == STATE_INIT);

    always_comb
      fsmCurrentStateIsLoadCommand = (i_fsmCurrentState == STATE_LOAD_COMMAND);

    always_comb
      fsmCurrentStateIsStartFrame = (i_fsmCurrentState == STATE_START_FRAME);

    always_comb
      fsmCurrentStateIsEndFrame = (i_fsmCurrentState == STATE_END_FRAME);

    always_comb
      fsmCurrentStateIsWrcLow = (i_fsmCurrentState == STATE_WRC_LOW);

    always_comb
      fsmCurrentStateIsWrcHigh = (i_fsmCurrentState == STATE_WRC_HIGH);

    always_comb
      fsmCurrentStateIsRdcLow = (i_fsmCurrentState == STATE_RDC_LOW);

    always_comb
      fsmCurrentStateIsRdcHigh = (i_fsmCurrentState == STATE_RDC_HIGH);
      // }}} FSM Current State

    // {{{ FSM Previous State
    logic fsmPreviousStateIsInit, fsmPreviousStateIsLoadCommand,
          fsmPreviousStateIsEndFrame, fsmPreviousStateIsWrcHigh,
          fsmPreviousStateIsStartFrame, fsmPreviousStateIsWrcLow,
          fsmPreviousStateIsRdcHigh, fsmPreviousStateIsRdcLow;

    logic fsmPreviousStateIsInitOrEndFrame,
          fsmPreviousStateIsWrcHighOrStartFrame,
          fsmPreviousStateIsRdcHighOrWrcHigh;

    always_comb
      fsmPreviousStateIsLoadCommand =
        (fsmPreviousState_q == STATE_LOAD_COMMAND);

    always_comb
      fsmPreviousStateIsInit = (fsmPreviousState_q == STATE_INIT);

    always_comb
      fsmPreviousStateIsEndFrame = (fsmPreviousState_q == STATE_END_FRAME);

    always_comb
      fsmPreviousStateIsWrcHigh = (fsmPreviousState_q == STATE_WRC_HIGH);

    always_comb
      fsmPreviousStateIsStartFrame = (fsmPreviousState_q == STATE_START_FRAME);

    always_comb
      fsmPreviousStateIsWrcLow = (fsmPreviousState_q == STATE_WRC_LOW);

    always_comb
      fsmPreviousStateIsRdcHigh = (fsmPreviousState_q ==  STATE_RDC_HIGH);

    always_comb
      fsmPreviousStateIsRdcLow = (fsmPreviousState_q == STATE_RDC_LOW);

    always_comb
      fsmPreviousStateIsInitOrEndFrame =
        fsmPreviousStateIsInit || fsmPreviousStateIsEndFrame;

    always_comb
      fsmPreviousStateIsWrcHighOrStartFrame =
        fsmPreviousStateIsWrcHigh || fsmPreviousStateIsStartFrame;

    always_comb
      fsmPreviousStateIsRdcHighOrWrcHigh =
        fsmPreviousStateIsRdcHigh || fsmPreviousStateIsWrcHigh;
    // }}} FSM Previous State
  // }}} Auxillary logic

  // {{{ States
  // FSM state must be START FRAME if previous state is LOAD COMMAND.
  logic assert_startFramePrecededByLoadCommand;

  always_comb
    assert_startFramePrecededByLoadCommand =
      !i_rst_n ||
      fsmPreviousStateIsLoadCommand ?
      (fsmCurrentStateIsLoadCommand || fsmCurrentStateIsStartFrame) : '1;

  assert property (@(posedge i_clk) assert_startFramePrecededByLoadCommand);

  // FSM state must be LOAD COMMAND if previous state is INIT or END FRAME.
  logic assert_loadCommandPrecededByInitOrEndFrame;

  always_comb
    assert_loadCommandPrecededByInitOrEndFrame =
      !i_rst_n ||
      fsmPreviousStateIsInitOrEndFrame ?
        |{fsmCurrentStateIsInit
        , fsmCurrentStateIsEndFrame
        , fsmCurrentStateIsLoadCommand
        } : '1;

  assert property (@(posedge i_clk) assert_loadCommandPrecededByInitOrEndFrame);

  // FSM state must be WRC LOW if previous state is WRC HIGH or START FRAME.
  logic assert_wrcLowPrecededByWrcHighOrStartFrame;

  always_comb
    assert_wrcLowPrecededByWrcHighOrStartFrame =
      !i_rst_n ||
      fsmPreviousStateIsWrcHighOrStartFrame ?
        |{fsmCurrentStateIsWrcHigh
        , fsmCurrentStateIsStartFrame
        , fsmCurrentStateIsWrcLow
        , fsmCurrentStateIsRdcLow // This transition is valid.
        } : '1;

  assert property (@(posedge i_clk) assert_wrcLowPrecededByWrcHighOrStartFrame);

  // FSM state must be WRC HIGH if previous state is WRC LOW.
  logic assert_wrcHighPrecededByWrcLow;

  always_comb
    assert_wrcHighPrecededByWrcLow =
      !i_rst_n ||
      fsmPreviousStateIsWrcLow ?
        (fsmCurrentStateIsWrcHigh || fsmCurrentStateIsWrcLow) : '1;

  assert property (@(posedge i_clk) assert_wrcHighPrecededByWrcLow);

  // FSM state must be RDC LOW if previous state is RDC HIGH or WRC HIGH.
  logic assert_rdcLowPrecededByRdcHighOrWrcHigh;

  always_comb
    assert_rdcLowPrecededByRdcHighOrWrcHigh =
      !i_rst_n ||
      fsmPreviousStateIsRdcHighOrWrcHigh ?
        |{fsmCurrentStateIsRdcLow
        , fsmCurrentStateIsRdcHigh
        , fsmCurrentStateIsEndFrame // This transition is valid.
        , fsmCurrentStateIsWrcHigh
        , fsmCurrentStateIsWrcLow   // This transition is valid.
        } : '1;

  assert property (@(posedge i_clk) assert_rdcLowPrecededByRdcHighOrWrcHigh);

  // FSM state must be RDC HIGH if previous state is RDC LOW.
  logic assert_rdcHighPrecededByRdcLow;

  always_comb
    assert_rdcHighPrecededByRdcLow =
      !i_rst_n ||
      fsmPreviousStateIsRdcLow ?
        (fsmCurrentStateIsRdcLow || fsmCurrentStateIsRdcHigh) : '1;

  assert property (@(posedge i_clk) assert_rdcHighPrecededByRdcLow);

  // FSM state must be END FRAME if previous state is RDC HIGH.
  logic assert_endFramePrecededRdcHigh;

  always_comb
    assert_endFramePrecededRdcHigh =
      !i_rst_n ||
      fsmPreviousStateIsRdcHigh ?
        |{fsmCurrentStateIsEndFrame
        , fsmCurrentStateIsRdcHigh
        , fsmCurrentStateIsRdcLow // This transition is valid.
        } : '1;

  assert property (@(posedge i_clk) assert_endFramePrecededRdcHigh);
  // }}} States

  // {{{ State transitions
  // State transitions from INIT to LOAD COMMAND only if count40 is equal to 39.
  logic assert_initToLoadCommandAtCount40;

  always_comb
    assert_initToLoadCommandAtCount40 =
        !i_rst_n ||
        (fsmCurrentStateIsLoadCommand && fsmPreviousStateIsInit) ?
          (count40Previous_q == 39) : '1;

  assert property (@(posedge i_clk) assert_initToLoadCommandAtCount40);

  // State transitions from WRC HIGH to WRC LOW only if count40 not equal to 17.
  logic assert_wrcHighToWrcLowAtCount40;

  always_comb
    assert_wrcHighToWrcLowAtCount40 =
      !i_rst_n ||
      (fsmCurrentStateIsWrcLow && fsmPreviousStateIsWrcHigh) ?
        (count40Previous_q != 17) : '1;

  assert property (@(posedge i_clk) assert_wrcHighToWrcLowAtCount40);

  // State transitions from WRC HIGH to RDC LOW if count40 equals to 17.
  logic assert_wrcHighToRdcLowAtCount40;

  always_comb
    assert_wrcHighToRdcLowAtCount40 =
        !i_rst_n ||
        (fsmCurrentStateIsRdcLow && fsmPreviousStateIsWrcHigh) ?
          (count40Previous_q == 17) : '1;

  assert property (@(posedge i_clk) assert_wrcHighToRdcLowAtCount40);

  // State transitions from RDC HIGH to RDC LOW only if count40 not equal to 35.
  logic assert_rdcHighToRdcLowAtCount40;

  always_comb
    assert_rdcHighToRdcLowAtCount40 =
      !i_rst_n ||
      (fsmCurrentStateIsRdcLow && fsmPreviousStateIsRdcHigh) ?
        (count40Previous_q != 35) : '1;

  assert property (@(posedge i_clk) assert_rdcHighToRdcLowAtCount40);

  // State transitions from RDC HIGH to END FRAME only if count40 equals to 35.
  logic assert_rdcHighToEndFrameAtCount40;

  always_comb
    assert_rdcHighToEndFrameAtCount40 =
      !i_rst_n ||
      (fsmCurrentStateIsEndFrame && fsmPreviousStateIsRdcHigh) ?
        (count40Previous_q == 35) : '1;

  assert property (@(posedge i_clk) assert_rdcHighToEndFrameAtCount40);

  // State transitions from END FRAME to LOAD COMMAND only if count40 is equal
  // to 39.
  logic assert_endFrameToLoadCommandAtCount40;

  always_comb
    assert_endFrameToLoadCommandAtCount40 =
      !i_rst_n ||
      (fsmCurrentStateIsLoadCommand && fsmPreviousStateIsEndFrame) ?
        (count40Previous_q == 39) : '1;

  assert property (@(posedge i_clk) assert_endFrameToLoadCommandAtCount40);
  // }}} State transitions

endmodule

`resetall
