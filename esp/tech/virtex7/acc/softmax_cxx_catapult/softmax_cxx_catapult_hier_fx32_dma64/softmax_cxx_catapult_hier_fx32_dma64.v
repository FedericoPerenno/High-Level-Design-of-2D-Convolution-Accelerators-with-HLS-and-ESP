
//------> ./softmax_cxx_catapult_ccs_ctrl_in_buf_wait_v4.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
// Change History:
//    2019-01-24 - Add assertion to verify rdy signal behavior under reset.
//                 Fix bug in that behavior.
//    2019-01-04 - Fixed bug 54073 - rdy signal should not be asserted during
//                 reset
//    2018-11-19 - Improved code coverage for is_idle
//    2018-08-22 - Added is_idle to interface (as compare to
//                 ccs_ctrl_in_buf_wait_v2)
//------------------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_ccs_ctrl_in_buf_wait_v4 (clk, en, arst, srst, irdy, ivld, idat, vld, rdy, dat, is_idle);

    parameter integer rscid   = 1;
    parameter integer width   = 8;
    parameter integer ph_clk  =  1;
    parameter integer ph_en   =  1;
    parameter integer ph_arst =  1;
    parameter integer ph_srst =  1;

    input              clk;
    input              en;
    input              arst;
    input              srst;
    input              irdy;
    output             ivld;
    input  [width-1:0] dat;
    output             rdy;
    input              vld;
    output [width-1:0] idat;
    output             is_idle;

    reg                filled;
    wire               filled_next;
    wire               lbuf;
    wire               fbuf;
    reg    [width-1:0] abuf;
    reg                hs_init;

    assign lbuf = ~filled | irdy;
    assign filled_next = lbuf ? (vld && hs_init) : filled;

    assign rdy = lbuf && hs_init;

    assign ivld = filled_next;
    assign idat = abuf;

    assign fbuf = (lbuf && vld && hs_init) || (irdy && filled_next);
    assign is_idle = !fbuf && !lbuf;

    //assign is_idle = (~((rdy && vld && hs_init) || (irdy && ivld))) && !lbuf ;

    // Output registers:

    generate
    if (ph_arst == 0 && ph_clk==1)
    begin: POS_CLK_NEG_ARST
        always @(posedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= lbuf ? dat : abuf;
            filled <= filled_next;
            hs_init <= 1'b1;
        end
    end
    else if (ph_arst==1 && ph_clk==1)
    begin: POS_CLK_POS_ARST
        always @(posedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= lbuf ? dat : abuf;
            filled <= filled_next;
            hs_init <= 1'b1;
        end
    end
    else if (ph_arst == 0 && ph_clk==0)
    begin: NEG_CLK_NEG_ARST
        always @(negedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= lbuf ? dat : abuf;
            filled <= filled_next;
            hs_init <= 1'b1;
        end
    end
    else if (ph_arst==1 && ph_clk==0)
    begin: NEG_CLK_POS_ARST
        always @(negedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= lbuf ? dat : abuf;
            filled <= filled_next;
            hs_init <= 1'b1;
        end
    end
    endgenerate


`ifdef RDY_ASRT
    generate
    if (ph_clk==1)
    begin: POS_CLK_ASSERT

       property rdyAsrt ;
         @(posedge clk) ((srst==ph_srst) || (arst==ph_arst)) |=> (rdy==0);
       endproperty
       a1: assert property(rdyAsrt);

    end else if (ph_clk==0)
    begin: NEG_CLK_ASSERT

       property rdyAsrt ;
         @(negedge clk) ((srst==ph_srst) || (arst==ph_arst)) |=> (rdy==0);
       endproperty
       a1: assert property(rdyAsrt);

    end
    endgenerate

`endif

endmodule



//------> ./softmax_cxx_catapult_ccs_out_wait_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_ccs_out_wait_v1 (dat, irdy, vld, idat, rdy, ivld);

  parameter integer rscid = 1;
  parameter integer width = 8;

  output [width-1:0] dat;
  output             irdy;
  output             vld;
  input  [width-1:0] idat;
  input              rdy;
  input              ivld;

  wire   [width-1:0] dat;
  wire               irdy;
  wire               vld;

  assign dat = idat;
  assign irdy = rdy;
  assign vld = ivld;

endmodule



//------> ./softmax_cxx_catapult_ccs_sync_out_wait_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2015 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

module esp_acc_softmax_cxx_catapult_ccs_sync_out_wait_v1 (vld, irdy, ivld, rdy);
  parameter integer rscid = 1;

  input  ivld;
  output irdy;
  output vld;
  input  rdy;

  wire   irdy;
  wire   vld;

  assign vld = ivld;
  assign irdy = rdy;
endmodule

//------> ./softmax_cxx_catapult_ccs_out_buf_wait_v4.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

module esp_acc_softmax_cxx_catapult_ccs_out_buf_wait_v4 (clk, en, arst, srst, ivld, irdy, idat, rdy, vld, dat, is_idle);

    parameter integer rscid   = 1;
    parameter integer width   = 8;
    parameter integer ph_clk  =  1;
    parameter integer ph_en   =  1;
    parameter integer ph_arst =  1;
    parameter integer ph_srst =  1;

    input              clk;
    input              en;
    input              arst;
    input              srst;
    input              rdy;
    output             vld;
    input  [width-1:0] idat;
    output             irdy;
    input              ivld;
    output [width-1:0] dat;
    output             is_idle;

    reg                filled;
    wire               filled_next;
    reg                lbuf;
    wire               lbuf_next;
    reg    [width-1:0] abuf;
    wire               fbuf;
    reg                is_idle;

    assign lbuf_next = ~vld | rdy;
    assign filled_next = lbuf ? ivld : filled;
    assign vld = filled_next;
    assign irdy = lbuf_next;
    assign dat = lbuf ? idat : abuf;

    assign fbuf = (lbuf_next && ivld) || (rdy && filled_next);

//    assign is_idle = (~((rdy && vld) || (irdy && ivld))) && ~lbuf && (lbuf==lbuf_next);

    // Generate is_idle flag
    always@(lbuf, lbuf_next, fbuf)
      begin
        if (lbuf == lbuf_next)
          is_idle <= ~fbuf && ~lbuf;
        else
          is_idle <= 0;
      end


    // Output registers:
    generate
    if (ph_arst == 0 && ph_clk==1)
    begin: POS_CLK_NEG_ARST
        always @(posedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= dat;
            filled <= filled_next;
            lbuf <= lbuf_next;
        end
    end
    else if (ph_arst==1 && ph_clk==1)
    begin: POS_CLK_POS_ARST
        always @(posedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= dat;
            filled <= filled_next;
            lbuf <= lbuf_next;
        end
    end
    else if (ph_arst == 0 && ph_clk==0)
    begin: NEG_CLK_NEG_ARST
        always @(negedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= dat;
            filled <= filled_next;
            lbuf <= lbuf_next;
        end
    end
    else if (ph_arst==1 && ph_clk==0)
    begin: NEG_CLK_POS_ARST
        always @(negedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= dat;
            filled <= filled_next;
            lbuf <= lbuf_next;
        end
    end
    endgenerate

endmodule




//------> ./softmax_cxx_catapult_leading_sign_71_0.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    10.5c/896140 Production Release
//  HLS Date:       Sun Sep  6 22:45:38 PDT 2020
//
//  Generated by:   perenno@esp
//  Generated date: Sat Jul 23 16:05:48 2022
// ----------------------------------------------------------------------

//
// ------------------------------------------------------------------
//  Design Unit:    leading_sign_71_0
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_leading_sign_71_0 (
  mantissa, rtn
);
  input [70:0] mantissa;
  output [6:0] rtn;


  // Interconnect Declarations
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_6_2_sdt_2;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_18_3_sdt_3;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_26_2_sdt_2;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_42_4_sdt_4;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_50_2_sdt_2;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_62_3_sdt_3;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_70_2_sdt_2;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_90_5_sdt_5;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_98_2_sdt_2;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_110_3_sdt_3;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_118_2_sdt_2;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_134_4_sdt_4;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_142_2_sdt_2;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_154_3_sdt_3;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_162_2_sdt_2;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_186_6_sdt_6;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_194_2_sdt_2;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_6_2_sdt_1;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_14_2_sdt_1;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_26_2_sdt_1;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_34_2_sdt_1;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_50_2_sdt_1;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_58_2_sdt_1;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_70_2_sdt_1;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_78_2_sdt_1;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_98_2_sdt_1;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_106_2_sdt_1;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_118_2_sdt_1;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_126_2_sdt_1;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_142_2_sdt_1;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_150_2_sdt_1;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_162_2_sdt_1;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_170_2_sdt_1;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_194_2_sdt_1;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_200_2_sdt_1;
  wire c_h_1_2;
  wire c_h_1_5;
  wire c_h_1_6;
  wire c_h_1_9;
  wire c_h_1_12;
  wire c_h_1_13;
  wire c_h_1_14;
  wire c_h_1_17;
  wire c_h_1_20;
  wire c_h_1_21;
  wire c_h_1_24;
  wire c_h_1_27;
  wire c_h_1_28;
  wire c_h_1_29;
  wire c_h_1_30;
  wire c_h_1_33;
  wire c_h_1_34;

  wire[0:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_nl;
  wire[0:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_1_nl;
  wire[0:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_2_nl;
  wire[2:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_or_1_nl;
  wire[0:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_293_nl;
  wire[0:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_295_nl;
  wire[0:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_296_nl;
  wire[0:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_281_nl;

  // Interconnect Declarations for Component Instantiations
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_6_2_sdt_2
      = ~((mantissa[68:67]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_6_2_sdt_1
      = ~((mantissa[70:69]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_14_2_sdt_1
      = ~((mantissa[66:65]!=2'b00));
  assign c_h_1_2 = ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_6_2_sdt_1
      & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_6_2_sdt_2;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_18_3_sdt_3
      = (mantissa[64:63]==2'b00) & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_14_2_sdt_1;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_26_2_sdt_2
      = ~((mantissa[60:59]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_26_2_sdt_1
      = ~((mantissa[62:61]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_34_2_sdt_1
      = ~((mantissa[58:57]!=2'b00));
  assign c_h_1_5 = ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_26_2_sdt_1
      & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_26_2_sdt_2;
  assign c_h_1_6 = c_h_1_2 & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_18_3_sdt_3;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_42_4_sdt_4
      = (mantissa[56:55]==2'b00) & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_34_2_sdt_1
      & c_h_1_5;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_50_2_sdt_2
      = ~((mantissa[52:51]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_50_2_sdt_1
      = ~((mantissa[54:53]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_58_2_sdt_1
      = ~((mantissa[50:49]!=2'b00));
  assign c_h_1_9 = ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_50_2_sdt_1
      & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_50_2_sdt_2;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_62_3_sdt_3
      = (mantissa[48:47]==2'b00) & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_58_2_sdt_1;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_70_2_sdt_2
      = ~((mantissa[44:43]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_70_2_sdt_1
      = ~((mantissa[46:45]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_78_2_sdt_1
      = ~((mantissa[42:41]!=2'b00));
  assign c_h_1_12 = ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_70_2_sdt_1
      & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_70_2_sdt_2;
  assign c_h_1_13 = c_h_1_9 & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_62_3_sdt_3;
  assign c_h_1_14 = c_h_1_6 & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_42_4_sdt_4;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_90_5_sdt_5
      = (mantissa[40:39]==2'b00) & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_78_2_sdt_1
      & c_h_1_12 & c_h_1_13;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_98_2_sdt_2
      = ~((mantissa[36:35]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_98_2_sdt_1
      = ~((mantissa[38:37]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_106_2_sdt_1
      = ~((mantissa[34:33]!=2'b00));
  assign c_h_1_17 = ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_98_2_sdt_1
      & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_98_2_sdt_2;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_110_3_sdt_3
      = (mantissa[32:31]==2'b00) & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_106_2_sdt_1;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_118_2_sdt_2
      = ~((mantissa[28:27]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_118_2_sdt_1
      = ~((mantissa[30:29]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_126_2_sdt_1
      = ~((mantissa[26:25]!=2'b00));
  assign c_h_1_20 = ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_118_2_sdt_1
      & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_118_2_sdt_2;
  assign c_h_1_21 = c_h_1_17 & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_110_3_sdt_3;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_134_4_sdt_4
      = (mantissa[24:23]==2'b00) & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_126_2_sdt_1
      & c_h_1_20;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_142_2_sdt_2
      = ~((mantissa[20:19]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_142_2_sdt_1
      = ~((mantissa[22:21]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_150_2_sdt_1
      = ~((mantissa[18:17]!=2'b00));
  assign c_h_1_24 = ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_142_2_sdt_1
      & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_142_2_sdt_2;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_154_3_sdt_3
      = (mantissa[16:15]==2'b00) & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_150_2_sdt_1;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_162_2_sdt_2
      = ~((mantissa[12:11]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_162_2_sdt_1
      = ~((mantissa[14:13]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_170_2_sdt_1
      = ~((mantissa[10:9]!=2'b00));
  assign c_h_1_27 = ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_162_2_sdt_1
      & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_162_2_sdt_2;
  assign c_h_1_28 = c_h_1_24 & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_154_3_sdt_3;
  assign c_h_1_29 = c_h_1_21 & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_134_4_sdt_4;
  assign c_h_1_30 = c_h_1_14 & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_90_5_sdt_5;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_186_6_sdt_6
      = (mantissa[8:7]==2'b00) & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_170_2_sdt_1
      & c_h_1_27 & c_h_1_28 & c_h_1_29;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_194_2_sdt_2
      = ~((mantissa[4:3]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_194_2_sdt_1
      = ~((mantissa[6:5]!=2'b00));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_200_2_sdt_1
      = ~((mantissa[2:1]!=2'b00));
  assign c_h_1_33 = ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_194_2_sdt_1
      & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_194_2_sdt_2;
  assign c_h_1_34 = c_h_1_30 & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_186_6_sdt_6;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_nl
      = c_h_1_30 & (~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_186_6_sdt_6);
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_1_nl
      = c_h_1_14 & (c_h_1_29 | (~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_90_5_sdt_5))
      & (~ c_h_1_34);
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_2_nl
      = c_h_1_6 & (c_h_1_13 | (~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_42_4_sdt_4))
      & (~((~(c_h_1_21 & (c_h_1_28 | (~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_134_4_sdt_4))))
      & c_h_1_30)) & (~ c_h_1_34);
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_293_nl
      = c_h_1_2 & (c_h_1_5 | (~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_18_3_sdt_3))
      & (~((~(c_h_1_9 & (c_h_1_12 | (~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_62_3_sdt_3))))
      & c_h_1_14)) & (~((~(c_h_1_17 & (c_h_1_20 | (~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_110_3_sdt_3))
      & (~((~(c_h_1_24 & (c_h_1_27 | (~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_154_3_sdt_3))))
      & c_h_1_29)))) & c_h_1_30)) & (c_h_1_33 | (~ c_h_1_34));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_295_nl
      = ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_6_2_sdt_1
      & (ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_14_2_sdt_1
      | (~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_6_2_sdt_2))
      & (~((~(ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_26_2_sdt_1
      & (ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_34_2_sdt_1
      | (~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_26_2_sdt_2))))
      & c_h_1_6)) & (~((~(ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_50_2_sdt_1
      & (ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_58_2_sdt_1
      | (~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_50_2_sdt_2))
      & (~((~(ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_70_2_sdt_1
      & (ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_78_2_sdt_1
      | (~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_70_2_sdt_2))))
      & c_h_1_13)))) & c_h_1_14)) & (~((~(ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_98_2_sdt_1
      & (ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_106_2_sdt_1
      | (~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_98_2_sdt_2))
      & (~((~(ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_118_2_sdt_1
      & (ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_126_2_sdt_1
      | (~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_118_2_sdt_2))))
      & c_h_1_21)) & (~((~(ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_142_2_sdt_1
      & (ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_150_2_sdt_1
      | (~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_142_2_sdt_2))
      & (~((~(ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_162_2_sdt_1
      & (ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_170_2_sdt_1
      | (~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_162_2_sdt_2))))
      & c_h_1_28)))) & c_h_1_29)))) & c_h_1_30)) & (~((~(ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_194_2_sdt_1
      & (ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_200_2_sdt_1
      | (~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_194_2_sdt_2))))
      & c_h_1_34));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_296_nl
      = (~((mantissa[70]) | (~((mantissa[69:68]!=2'b01))))) & (~(((mantissa[66])
      | (~((mantissa[65:64]!=2'b01)))) & c_h_1_2)) & (~((~((~((mantissa[62]) | (~((mantissa[61:60]!=2'b01)))))
      & (~(((mantissa[58]) | (~((mantissa[57:56]!=2'b01)))) & c_h_1_5)))) & c_h_1_6))
      & (~((~((~((mantissa[54]) | (~((mantissa[53:52]!=2'b01))))) & (~(((mantissa[50])
      | (~((mantissa[49:48]!=2'b01)))) & c_h_1_9)) & (~((~((~((mantissa[46]) | (~((mantissa[45:44]!=2'b01)))))
      & (~(((mantissa[42]) | (~((mantissa[41:40]!=2'b01)))) & c_h_1_12)))) & c_h_1_13))))
      & c_h_1_14)) & (~((~((~((mantissa[38]) | (~((mantissa[37:36]!=2'b01))))) &
      (~(((mantissa[34]) | (~((mantissa[33:32]!=2'b01)))) & c_h_1_17)) & (~((~((~((mantissa[30])
      | (~((mantissa[29:28]!=2'b01))))) & (~(((mantissa[26]) | (~((mantissa[25:24]!=2'b01))))
      & c_h_1_20)))) & c_h_1_21)) & (~((~((~((mantissa[22]) | (~((mantissa[21:20]!=2'b01)))))
      & (~(((mantissa[18]) | (~((mantissa[17:16]!=2'b01)))) & c_h_1_24)) & (~((~((~((mantissa[14])
      | (~((mantissa[13:12]!=2'b01))))) & (~(((mantissa[10]) | (~((mantissa[9:8]!=2'b01))))
      & c_h_1_27)))) & c_h_1_28)))) & c_h_1_29)))) & c_h_1_30)) & (~((~((~((mantissa[6])
      | (~((mantissa[5:4]!=2'b01))))) & (~((~((mantissa[2:1]==2'b01))) & c_h_1_33))))
      & c_h_1_34));
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_281_nl
      = (~ (mantissa[0])) & ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_wrs_c_200_2_sdt_1
      & c_h_1_33 & c_h_1_34;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_or_1_nl
      = MUX_v_3_2_2(({ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_293_nl
      , ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_295_nl
      , ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_296_nl}),
      3'b111, ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_281_nl);
  assign rtn = {c_h_1_34 , ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_nl
      , ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_1_nl
      , ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_and_2_nl
      , ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_leading_sign_71_0_rtn_or_1_nl};

  function automatic [2:0] MUX_v_3_2_2;
    input [2:0] input_0;
    input [2:0] input_1;
    input [0:0] sel;
    reg [2:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_3_2_2 = result;
  end
  endfunction

endmodule




//------> ./softmax_cxx_catapult_mgc_shift_br_beh_v5.v 
module esp_acc_softmax_cxx_catapult_mgc_shift_br_v5(a,s,z);
   parameter    width_a = 4;
   parameter    signd_a = 1;
   parameter    width_s = 2;
   parameter    width_z = 8;

   input [width_a-1:0] a;
   input [width_s-1:0] s;
   output [width_z -1:0] z;

   generate
     if (signd_a)
     begin: SGNED
       assign z = fshr_s(a,s,a[width_a-1]);
     end
     else
     begin: UNSGNED
       assign z = fshr_s(a,s,1'b0);
     end
   endgenerate

   //Shift-left - unsigned shift argument one bit more
   function [width_z-1:0] fshl_u_1;
      input [width_a  :0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      parameter olen = width_z;
      parameter ilen = width_a+1;
      parameter len = (ilen >= olen) ? ilen : olen;
      reg [len-1:0] result;
      reg [len-1:0] result_t;
      begin
        result_t = {(len){sbit}};
        result_t[ilen-1:0] = arg1;
        result = result_t <<< arg2;
        fshl_u_1 =  result[olen-1:0];
      end
   endfunction // fshl_u

   //Shift right - unsigned shift argument
   function [width_z-1:0] fshr_u;
      input [width_a-1:0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      parameter olen = width_z;
      parameter ilen = signd_a ? width_a : width_a+1;
      parameter len = (ilen >= olen) ? ilen : olen;
      reg signed [len-1:0] result;
      reg signed [len-1:0] result_t;
      begin
        result_t = $signed( {(len){sbit}} );
        result_t[width_a-1:0] = arg1;
        result = result_t >>> arg2;
        fshr_u =  result[olen-1:0];
      end
   endfunction // fshr_u

   //Shift right - signed shift argument
   function [width_z-1:0] fshr_s;
     input [width_a-1:0] arg1;
     input [width_s-1:0] arg2;
     input sbit;
     begin
       if ( arg2[width_s-1] == 1'b0 )
       begin
         fshr_s = fshr_u(arg1, arg2, sbit);
       end
       else
       begin
         fshr_s = fshl_u_1({arg1, 1'b0},~arg2, sbit);
       end
     end
   endfunction

endmodule

//------> ./softmax_cxx_catapult_mgc_shift_bl_beh_v5.v 
module esp_acc_softmax_cxx_catapult_mgc_shift_bl_v5(a,s,z);
   parameter    width_a = 4;
   parameter    signd_a = 1;
   parameter    width_s = 2;
   parameter    width_z = 8;

   input [width_a-1:0] a;
   input [width_s-1:0] s;
   output [width_z -1:0] z;

   generate if ( signd_a )
   begin: SGNED
     assign z = fshl_s(a,s,a[width_a-1]);
   end
   else
   begin: UNSGNED
     assign z = fshl_s(a,s,1'b0);
   end
   endgenerate

   //Shift-left - unsigned shift argument one bit more
   function [width_z-1:0] fshl_u_1;
      input [width_a  :0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      parameter olen = width_z;
      parameter ilen = width_a+1;
      parameter len = (ilen >= olen) ? ilen : olen;
      reg [len-1:0] result;
      reg [len-1:0] result_t;
      begin
        result_t = {(len){sbit}};
        result_t[ilen-1:0] = arg1;
        result = result_t <<< arg2;
        fshl_u_1 =  result[olen-1:0];
      end
   endfunction // fshl_u

   //Shift-left - unsigned shift argument
   function [width_z-1:0] fshl_u;
      input [width_a-1:0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      fshl_u = fshl_u_1({sbit,arg1} ,arg2, sbit);
   endfunction // fshl_u

   //Shift right - unsigned shift argument
   function [width_z-1:0] fshr_u;
      input [width_a-1:0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      parameter olen = width_z;
      parameter ilen = signd_a ? width_a : width_a+1;
      parameter len = (ilen >= olen) ? ilen : olen;
      reg signed [len-1:0] result;
      reg signed [len-1:0] result_t;
      begin
        result_t = $signed( {(len){sbit}} );
        result_t[width_a-1:0] = arg1;
        result = result_t >>> arg2;
        fshr_u =  result[olen-1:0];
      end
   endfunction // fshl_u

   //Shift left - signed shift argument
   function [width_z-1:0] fshl_s;
      input [width_a-1:0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      reg [width_a:0] sbit_arg1;
      begin
        // Ignoring the possibility that arg2[width_s-1] could be X
        // because of customer complaints regarding X'es in simulation results
        if ( arg2[width_s-1] == 1'b0 )
        begin
          sbit_arg1[width_a:0] = {(width_a+1){1'b0}};
          fshl_s = fshl_u(arg1, arg2, sbit);
        end
        else
        begin
          sbit_arg1[width_a] = sbit;
          sbit_arg1[width_a-1:0] = arg1;
          fshl_s = fshr_u(sbit_arg1[width_a:1], ~arg2, sbit);
        end
      end
   endfunction

endmodule

//------> ./softmax_cxx_catapult_mgc_shift_l_beh_v5.v 
module esp_acc_softmax_cxx_catapult_mgc_shift_l_v5(a,s,z);
   parameter    width_a = 4;
   parameter    signd_a = 1;
   parameter    width_s = 2;
   parameter    width_z = 8;

   input [width_a-1:0] a;
   input [width_s-1:0] s;
   output [width_z -1:0] z;

   generate
   if (signd_a)
   begin: SGNED
      assign z = fshl_u(a,s,a[width_a-1]);
   end
   else
   begin: UNSGNED
      assign z = fshl_u(a,s,1'b0);
   end
   endgenerate

   //Shift-left - unsigned shift argument one bit more
   function [width_z-1:0] fshl_u_1;
      input [width_a  :0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      parameter olen = width_z;
      parameter ilen = width_a+1;
      parameter len = (ilen >= olen) ? ilen : olen;
      reg [len-1:0] result;
      reg [len-1:0] result_t;
      begin
        result_t = {(len){sbit}};
        result_t[ilen-1:0] = arg1;
        result = result_t <<< arg2;
        fshl_u_1 =  result[olen-1:0];
      end
   endfunction // fshl_u

   //Shift-left - unsigned shift argument
   function [width_z-1:0] fshl_u;
      input [width_a-1:0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      fshl_u = fshl_u_1({sbit,arg1} ,arg2, sbit);
   endfunction // fshl_u

endmodule

//------> ./softmax_cxx_catapult_mgc_mul_pipe_beh.v 
//
// File:      $Mgc_home/pkgs/hls_pkgs/mgc_comps_src/mgc_mul_pipe_beh.v
//
// BASELINE:  Catapult-C version 2006b.63
// MODIFIED:  2007-04-03, tnagler
//
// Note: this file uses Verilog2001 features;
//       please enable Verilog2001 in the flow!

module esp_acc_softmax_cxx_catapult_mgc_mul_pipe (a, b, clk, en, a_rst, s_rst, z);

    // Parameters:
    parameter integer width_a = 32'd4;  // input a bit width
    parameter         signd_a =  1'b1;  // input a type (1=signed, 0=unsigned)
    parameter integer width_b = 32'd4;  // input b bit width
    parameter         signd_b =  1'b1;  // input b type (1=signed, 0=unsigned)
    parameter integer width_z = 32'd8;  // result bit width (= width_a + width_b)
    parameter      clock_edge =  1'b0;  // clock polarity (1=posedge, 0=negedge)
    parameter   enable_active =  1'b0;  // enable polarity (1=posedge, 0=negedge)
    parameter    a_rst_active =  1'b1;  // unused
    parameter    s_rst_active =  1'b1;  // unused
    parameter integer  stages = 32'd2;  // number of output registers + 1 (careful!)
    parameter integer n_inreg = 32'd0;  // number of input registers

    localparam integer width_ab = width_a + width_b;  // multiplier result width
    localparam integer n_inreg_min = (n_inreg > 1) ? (n_inreg-1) : 0; // for Synopsys DC

    // I/O ports:
    input  [width_a-1:0] a;      // input A
    input  [width_b-1:0] b;      // input B
    input                clk;    // clock
    input                en;     // enable
    input                a_rst;  // async reset (unused)
    input                s_rst;  // sync reset (unused)
    output [width_z-1:0] z;      // output


    // Input registers:

    wire [width_a-1:0] a_f;
    wire [width_b-1:0] b_f;

    integer i;

    generate
    if (clock_edge == 1'b0)
    begin: NEG_EDGE1
        case (n_inreg)
        32'd0: begin: B1
            assign a_f = a,
                   b_f = b;
        end
        default: begin: B2
            reg [width_a-1:0] a_reg [n_inreg_min:0];
            reg [width_b-1:0] b_reg [n_inreg_min:0];
            always @(negedge clk)
            if (en == enable_active)
            begin: B21
                a_reg[0] <= a;
                b_reg[0] <= b;
                for (i = 0; i < n_inreg_min; i = i + 1)
                begin: B3
                    a_reg[i+1] <= a_reg[i];
                    b_reg[i+1] <= b_reg[i];
                end
            end
            assign a_f = a_reg[n_inreg_min],
                   b_f = b_reg[n_inreg_min];
        end
        endcase
    end
    else
    begin: POS_EDGE1
        case (n_inreg)
        32'd0: begin: B1
            assign a_f = a,
                   b_f = b;
        end
        default: begin: B2
            reg [width_a-1:0] a_reg [n_inreg_min:0];
            reg [width_b-1:0] b_reg [n_inreg_min:0];
            always @(posedge clk)
            if (en == enable_active)
            begin: B21
                a_reg[0] <= a;
                b_reg[0] <= b;
                for (i = 0; i < n_inreg_min; i = i + 1)
                begin: B3
                    a_reg[i+1] <= a_reg[i];
                    b_reg[i+1] <= b_reg[i];
                end
            end
            assign a_f = a_reg[n_inreg_min],
                   b_f = b_reg[n_inreg_min];
        end
        endcase
    end
    endgenerate


    // Output:
    wire [width_z-1:0]  xz;

    function signed [width_z-1:0] conv_signed;
      input signed [width_ab-1:0] res;
      conv_signed = res[width_z-1:0];
    endfunction

    generate
      wire signed [width_ab-1:0] res;
      if ( (signd_a == 1'b1) && (signd_b == 1'b1) )
      begin: SIGNED_AB
              assign res = $signed(a_f) * $signed(b_f);
              assign xz = conv_signed(res);
      end
      else if ( (signd_a == 1'b1) && (signd_b == 1'b0) )
      begin: SIGNED_A
              assign res = $signed(a_f) * $signed({1'b0, b_f});
              assign xz = conv_signed(res);
      end
      else if ( (signd_a == 1'b0) && (signd_b == 1'b1) )
      begin: SIGNED_B
              assign res = $signed({1'b0,a_f}) * $signed(b_f);
              assign xz = conv_signed(res);
      end
      else
      begin: UNSIGNED_AB
              assign res = a_f * b_f;
	      assign xz = res[width_z-1:0];
      end
    endgenerate


    // Output registers:

    reg  [width_z-1:0] reg_array[stages-2:0];
    wire [width_z-1:0] z;

    generate
    if (clock_edge == 1'b0)
    begin: NEG_EDGE2
        always @(negedge clk)
        if (en == enable_active)
            for (i = stages-2; i >= 0; i = i-1)
                if (i == 0)
                    reg_array[i] <= xz;
                else
                    reg_array[i] <= reg_array[i-1];
    end
    else
    begin: POS_EDGE2
        always @(posedge clk)
        if (en == enable_active)
            for (i = stages-2; i >= 0; i = i-1)
                if (i == 0)
                    reg_array[i] <= xz;
                else
                    reg_array[i] <= reg_array[i-1];
    end
    endgenerate

    assign z = reg_array[stages-2];
endmodule

//------> ./softmax_cxx_catapult_ccs_in_wait_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_ccs_in_wait_v1 (idat, rdy, ivld, dat, irdy, vld);

  parameter integer rscid = 1;
  parameter integer width = 8;

  output [width-1:0] idat;
  output             rdy;
  output             ivld;
  input  [width-1:0] dat;
  input              irdy;
  input              vld;

  wire   [width-1:0] idat;
  wire               rdy;
  wire               ivld;

  assign idat = dat;
  assign rdy = irdy;
  assign ivld = vld;

endmodule


//------> ./softmax_cxx_catapult_ccs_sync_out_vld_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2015 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

module esp_acc_softmax_cxx_catapult_ccs_sync_out_vld_v1 (vld, ivld);
  parameter integer rscid = 1;

  input  ivld;
  output vld;

  wire   vld;

  assign vld = ivld;
endmodule

//------> ./softmax_cxx_catapult_ccs_sync_in_wait_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2015 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

module esp_acc_softmax_cxx_catapult_ccs_sync_in_wait_v1 (rdy, vld, irdy, ivld);
  parameter integer rscid = 1;

  output rdy;
  input  vld;
  input  irdy;
  output ivld;

  wire   ivld;
  wire   rdy;

  assign ivld = vld;
  assign rdy = irdy;
endmodule

//------> ./softmax_cxx_catapult_ccs_genreg_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

module esp_acc_softmax_cxx_catapult_ccs_genreg_v1 (clk, en, arst, srst, d, z);
    parameter integer width   = 1;
    parameter integer ph_clk  = 1;
    parameter integer ph_en   = 1;
    parameter integer ph_arst = 0;
    parameter integer ph_srst = 1;
    parameter         has_en  = 1'b1;

    input clk;
    input en;
    input arst;
    input srst;
    input      [width-1:0] d;
    output reg [width-1:0] z;

    //  Generate parameters
    //  ph_clk | ph_arst | has_en     Label:
    //    1        1          1       GEN_CLK1_ARST1_EN1
    //    1        1          0       GEN_CLK1_ARST1_EN0
    //    1        0          1       GEN_CLK1_ARST0_EN1
    //    1        0          0       GEN_CLK1_ARST0_EN0
    //    0        1          1       GEN_CLK0_ARST1_EN1
    //    0        1          0       GEN_CLK0_ARST1_EN0
    //    0        0          1       GEN_CLK0_ARST0_EN1
    //    0        0          0       GEN_CLK0_ARST0_EN0

    generate
      // Pos edge clock, pos edge async reset, has enable
      if (ph_clk == 1 & ph_arst == 1 & has_en == 1)
      begin: GEN_CLK1_ARST1_EN1
        always @(posedge clk or posedge arst)
          if (arst == 1'b1)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else if (en == $unsigned(ph_en))
            z <= d;
      end  //GEN_CLK1_ARST1_EN1

      // Pos edge clock, pos edge async reset, no enable
      else if (ph_clk == 1 & ph_arst == 1 & has_en == 0)
      begin: GEN_CLK1_ARST1_EN0
        always @(posedge clk or posedge arst)
          if (arst == 1'b1)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else
            z <= d;
      end  //GEN_CLK1_ARST1_EN0

      // Pos edge clock, neg edge async reset, has enable
      else if (ph_clk == 1 & ph_arst == 0 & has_en == 1)
      begin: GEN_CLK1_ARST0_EN1
        always @(posedge clk or negedge arst)
          if (arst == 1'b0)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else if (en == $unsigned(ph_en))
            z <= d;
      end  //GEN_CLK1_ARST0_EN1

      // Pos edge clock, neg edge async reset, no enable
      else if (ph_clk == 1 & ph_arst == 0 & has_en == 0)
      begin: GEN_CLK1_ARST0_EN0
        always @(posedge clk or negedge arst)
          if (arst == 1'b0)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else
            z <= d;
      end  //GEN_CLK1_ARST0_EN0


      // Neg edge clock, pos edge async reset, has enable
      if (ph_clk == 0 & ph_arst == 1 & has_en == 1)
      begin: GEN_CLK0_ARST1_EN1
        always @(negedge clk or posedge arst)
          if (arst == 1'b1)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else if (en == $unsigned(ph_en))
            z <= d;
      end  //GEN_CLK0_ARST1_EN1

      // Neg edge clock, pos edge async reset, no enable
      else if (ph_clk == 0 & ph_arst == 1 & has_en == 0)
      begin: GEN_CLK0_ARST1_EN0
        always @(negedge clk or posedge arst)
          if (arst == 1'b1)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else
            z <= d;
      end  //GEN_CLK0_ARST1_EN0

      // Neg edge clock, neg edge async reset, has enable
      else if (ph_clk == 0 & ph_arst == 0 & has_en == 1)
      begin: GEN_CLK0_ARST0_EN1
        always @(negedge clk or negedge arst)
          if (arst == 1'b0)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else if (en == $unsigned(ph_en))
            z <= d;
      end  //GEN_CLK0_ARST0_EN1

      // Neg edge clock, neg edge async reset, no enable
      else if (ph_clk == 0 & ph_arst == 0 & has_en == 0)
      begin: GEN_CLK0_ARST0_EN0
        always @(negedge clk or negedge arst)
          if (arst == 1'b0)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else
            z <= d;
      end  //GEN_CLK0_ARST0_EN0
    endgenerate
endmodule


//------> ./softmax_cxx_catapult_ccs_fifo_wait_core_v5.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

/*
 *            _________________________________________________
 * WRITER    |                                                 |   READER
 *           |               ccs_fifo_wait_core                |
 *           |             _____________________               |
 *        --<|  din_rdy --<|  ---------------- <|--- dout_rdy <|---
 *           |             |       FIFO         |              |
 *        ---|> din_vld ---|> ----------------  |>-- dout_vld  |>--
 *        ---|>     din ---|> ----------------  |>-- dout      |>--
 *           |             |____________________|              |
 *           |_________________________________________________|
 *
 *    rdy    - can be considered as a notFULL signal
 *    vld    - can be considered as a notEMPTY signal
 *    is_idle - clk can be safely gated
 *
 * Change History:
 *    2019-01-24 - Add assertion to verify rdy signal behavior under reset.
 *                 Fix bug in that behavior.
 */

module esp_acc_softmax_cxx_catapult_ccs_fifo_wait_core_v5 (clk, en, arst, srst, din_vld, din_rdy, din, dout_vld, dout_rdy, dout, sd, is_idle);

    parameter integer rscid    = 0;     // resource ID
    parameter integer width    = 8;     // fifo width
    parameter integer sz_width = 8;     // size of port for elements in fifo
    parameter integer fifo_sz  = 8;     // fifo depth
    parameter integer ph_clk   = 1;  // clock polarity 1=rising edge, 0=falling edge
    parameter integer ph_en    = 1;  // clock enable polarity
    parameter integer ph_arst  = 1;  // async reset polarity
    parameter integer ph_srst  = 1;  // sync reset polarity
    parameter integer ph_log2  = 3;     // log2(fifo_sz)

    input                 clk;
    input                 en;
    input                 arst;
    input                 srst;
    input                 din_vld;    // writer has valid data
    output                din_rdy;    // fifo ready for data (not full)
    input  [width-1:0]    din;
    output                dout_vld;   // fifo has valid data (not empty)
    input                 dout_rdy;   // reader ready for data
    output [width-1:0]    dout;
    output [sz_width-1:0] sd;
    output                is_idle;

    localparam integer fifo_b  = width * fifo_sz;
    localparam integer fifo_mx = (fifo_sz > 0) ? (fifo_sz-1) : 0 ;
    localparam integer fifo_mx_over_8 = fifo_mx / 8 ;

    reg      [fifo_mx:0] stat_pre;
    wire     [fifo_mx:0] stat;
    reg      [( (fifo_b > 0) ? fifo_b : 1)-1:0] buff_pre;
    wire     [( (fifo_b > 0) ? fifo_b : 1)-1:0] buff;
    reg      [fifo_mx:0] en_l;
    reg      [fifo_mx_over_8:0] en_l_s;

    reg      [width-1:0] buff_nxt;

    reg                  stat_nxt;
    reg                  stat_behind;
    reg                  stat_ahead;
    reg                  en_l_var;

    integer              i;
    genvar               eni;

    wire [32:0]          size_t;
    reg  [31:0]          count;
    reg  [31:0]          count_t;
    reg  [32:0]          n_elem;
// synopsys translate_off
    reg  [31:0]          peak;
    initial
    begin
      count = 32'b0;
      peak  = 32'b0;
    end
// synopsys translate_on
  wire din_rdy_drv  ;
  wire dout_vld_drv ;
    wire                 active;
    wire                 din_vld_int;
    wire                 hs_init;

    //assign din_rdy  = din_rdy_drv;    // dout_rdy | (~stat[0] & hs_init);   // original
    assign din_rdy = (fifo_sz > 0) ? (~stat[0] | dout_rdy) && hs_init : dout_rdy ;
    assign dout_vld = dout_vld_drv;
    assign is_idle = (~((din_vld && din_rdy) || (dout_vld && dout_rdy))) && hs_init;

    generate
    if ( fifo_sz > 0 )
    begin: FIFO_REG
    assign din_vld_int = din_vld & hs_init;
    assign active =   (din_vld_int & din_rdy_drv) | (dout_rdy & dout_vld_drv);

      assign din_rdy_drv = dout_rdy | (~stat[0] & hs_init);
      assign dout_vld_drv = din_vld_int | stat[fifo_sz-1];

      assign size_t = (count - {31'b0 , (dout_rdy & stat[fifo_sz-1])}) + { 31'b0, din_vld_int};
      assign sd = size_t[sz_width-1:0];

      assign dout = (stat[fifo_sz-1]) ? buff[fifo_b-1:width*(fifo_sz-1)] : din;

      always @(*)
      begin: FIFOPROC
        n_elem = 33'b0;
        for (i = fifo_sz-1; i >= 0; i = i - 1)
        begin
          stat_behind = (i != 0) ? stat[i-1] : 1'b0;
          stat_ahead  = (i != (fifo_sz-1)) ? stat[i+1] : 1'b1;

          // Determine if this buffer element will have data
          stat_nxt = stat_ahead &                       // valid element ahead of this one (or head)
                       (stat_behind                     // valid element behind this one
                         | (stat[i] & (~dout_rdy))      // valid element and output not ready (in use, no tx)
                         | (stat[i] & din_vld_int)      // valid element and input has data
                         | (din_vld_int  & (~dout_rdy)) // input has data and output not ready
                       );
          stat_pre[i] = stat_nxt;

          if (dout_rdy & stat_behind )
          begin
            // pop n shift
            buff_nxt[0+:width] = buff[width*(i-1)+:width];
            en_l_var = 1'b1;
          end
          else if (din_vld_int & stat_nxt & ~((~dout_rdy) & stat[i]))
          begin
            // update tail with input data
            buff_nxt = din;
            en_l_var = 1'b1;
          end
          else
          begin
            // no-op, disable register
            buff_nxt = din; // Don't care input to disabled flop
            en_l_var = 1'b0;
          end
          buff_pre[width*i+:width] = buff_nxt[0+:width];

          if (ph_en != 0)
            en_l[i] = en & en_l_var;
          else
            en_l[i] = en | ~en_l_var;

          if ((stat_ahead == 1'b1) & (stat[i] == 1'b0))
            //found tail, update the number of elements for count
            n_elem = ($unsigned(fifo_sz) - 1) - $unsigned(i);
        end //for loop

        // Enable for stat registers (partitioned into banks of eight)
        // Take care of the head first
        if (ph_en != 0)
          en_l_s[(((fifo_sz > 0) ? fifo_sz : 1)-1)/8] = en & active;
        else
          en_l_s[(((fifo_sz > 0) ? fifo_sz : 1)-1)/8] = en | ~active;

        // Now every eight
        for (i = fifo_sz-1; i >= 7; i = i - 1)
        begin
          if (($unsigned(i)%8) == 0)
          begin
            if (ph_en != 0)
              en_l_s[(i/8)-1] = en & (stat[i]) & (active);
            else
              en_l_s[(i/8)-1] = en | ~(stat[i]) | ~(active);
          end
        end

        // Update count and peak
        if ( stat[fifo_sz-1] == 1'b0 )
          count_t = 32'b0;
        else if ( stat[0] == 1'b1 )
          count_t = fifo_sz;
        else
          count_t = n_elem[31:0];
        count = count_t;
// synopsys translate_off
        if ( peak < count )
          peak = count;
// synopsys translate_on
      end //FIFOPROC

      // Handshake valid after reset
      esp_acc_softmax_cxx_catapult_ccs_genreg_v1
      #(
        .width   (1),
        .ph_clk  (ph_clk),
        .ph_en   (1),
        .ph_arst (ph_arst),
        .ph_srst (ph_srst),
        .has_en  (1'b0)
      )
      HS_INIT_REG
      (
        .clk     (clk),
        .en      (1'b1),
        .arst    (arst),
        .srst    (srst),
        .d       (1'b1),
        .z       (hs_init)
      );

      // Buffer and status registers
      for (eni = fifo_sz-1; eni >= 0; eni = eni - 1)
      begin: GEN_REGS
        esp_acc_softmax_cxx_catapult_ccs_genreg_v1
        #(
          .width   (1),
          .ph_clk  (ph_clk),
          .ph_en   (ph_en),
          .ph_arst (ph_arst),
          .ph_srst (ph_srst),
          .has_en  (1'b1)
        )
        STATREG
        (
          .clk     (clk),
          .en      (en_l_s[eni/8]),
          .arst    (arst),
          .srst    (srst),
          .d       (stat_pre[eni]),
          .z       (stat[eni])
        );

        esp_acc_softmax_cxx_catapult_ccs_genreg_v1
        #(
          .width   (width),
          .ph_clk  (ph_clk),
          .ph_en   (ph_en),
          .ph_arst (ph_arst),
          .ph_srst (ph_srst),
          .has_en  (1'b1)
        )
        BUFREG
        (
          .clk     (clk),
          .en      (en_l[eni]),
          .arst    (arst),
          .srst    (srst),
          .d       (buff_pre[width*eni+:width]),
          .z       (buff[width*eni+:width])
        );
      end

    end
    else
    begin: FEED_THRU
      assign din_rdy_drv  = dout_rdy;
      assign dout_vld_drv = din_vld;
      assign dout     = din;
      // non-blocking is not II=1 when fifo_sz=0
      assign sd = {{(sz_width-1){1'b0}}, (din_vld & ~dout_rdy)};
    end
    endgenerate

`ifdef RDY_ASRT
    generate
    if (ph_clk==1)
    begin: POS_CLK_ASSERT

       property rdyAsrt ;
         @(posedge clk) ((srst==ph_srst) || (arst==ph_arst)) |=> (din_rdy==0);
       endproperty
       a1Pos: assert property(rdyAsrt);

    end else if (ph_clk==0)
    begin: NEG_CLK_ASSERT

       property rdyAsrt ;
         @(negedge clk) ((srst==ph_srst) || (arst==ph_arst)) |=> (din_rdy==0);
       endproperty
       a1Neg: assert property(rdyAsrt);

    end
    endgenerate

`endif

endmodule



//------> ./softmax_cxx_catapult_ccs_pipe_v5.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------
/*
 *
 *            _______________________________________________
 * WRITER    |                                              |          READER
 *           |                 ccs_pipe                     |
 *           |            ______________________            |
 *        --<| din_rdy --<|  ---------------- <|---dout_rdy<|---
 *           |            |       FIFO         |            |
 *        ---|>din_vld ---|> ----------------  |>--dout_vld |>--
 *        ---|>din -------|> ----------------  |> -----dout |>--
 *           |            |____________________|            |
 *           |______________________________________________|
 *
 *    din_rdy     - can be considered as a notFULL signal
 *    dout_vld    - can be considered as a notEMPTY signal
 *    write_stall - an internal debug signal formed from din_vld & !din_rdy
 *    read_stall  - an internal debug signal formed from dout_rdy & !dout_vld
 *    is_idle     - indicates the clock can be safely gated
 */

module esp_acc_softmax_cxx_catapult_ccs_pipe_v5 (clk, en, arst, srst, din_rdy, din_vld, din, dout_rdy, dout_vld, dout, sz, sz_req, is_idle);

    parameter integer rscid    = 0; // resource ID
    parameter integer width    = 8; // fifo width
    parameter integer sz_width = 8; // width of size of elements in fifo
    parameter integer fifo_sz  = 8; // fifo depth
    parameter integer log2_sz  = 3; // log2(fifo_sz)
    parameter integer ph_clk   = 1; // clock polarity 1=rising edge, 0=falling edge
    parameter integer ph_en    = 1; // clock enable polarity
    parameter integer ph_arst  = 1; // async reset polarity
    parameter integer ph_srst  = 1; // sync reset polarity

    // clock
    input              clk;
    input              en;
    input              arst;
    input              srst;

    // writer
    output             din_rdy;
    input              din_vld;
    input  [width-1:0] din;

    // reader
    input              dout_rdy;
    output             dout_vld;
    output [width-1:0] dout;

    // size
    output [sz_width-1:0] sz;
    input                 sz_req;
    output                is_idle;

// synopsys translate_off
    wire   write_stall;
    wire   read_stall;
    assign write_stall = din_vld & !din_rdy;
    assign read_stall  = dout_rdy & !dout_vld;
// synopsys translate_on

    esp_acc_softmax_cxx_catapult_ccs_fifo_wait_core_v5
    #(
        .rscid    (rscid),
        .width    (width),
        .sz_width (sz_width),
        .fifo_sz  (fifo_sz),
        .ph_clk   (ph_clk),
        .ph_en    (ph_en),
        .ph_arst  (ph_arst),
        .ph_srst  (ph_srst),
        .ph_log2  (log2_sz)
    )
    FIFO
    (
        .clk      (clk),
        .en       (en),
        .arst     (arst),
        .srst     (srst),
        .din_vld  (din_vld),
        .din_rdy  (din_rdy),
        .din      (din),
        .dout_vld (dout_vld),
        .dout_rdy (dout_rdy),
        .dout     (dout),
        .sd       (sz),
        .is_idle  (is_idle)
    );

endmodule


//------> ./softmax_cxx_catapult_ccs_sync_pipe_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

module esp_acc_softmax_cxx_catapult_ccs_sync_pipe_v1 (dout_vld, dout_rdy, din_vld, din_rdy);
  parameter integer rscid = 1;

  input  din_vld;
  output dout_vld;
  input  dout_rdy;
  output din_rdy;

  wire   dout_vld;
  wire   din_rdy;

  assign dout_vld = din_vld;
  assign din_rdy = dout_rdy;
endmodule

//------> ./softmax_cxx_catapult.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    10.5c/896140 Production Release
//  HLS Date:       Sun Sep  6 22:45:38 PDT 2020
// 
//  Generated by:   perenno@esp
//  Generated date: Wed Jul 27 17:02:16 2022
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_core_fsm (
  clk, rst, core_wen, fsm_output
);
  input clk;
  input rst;
  input core_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;


  // FSM State Type Declaration for esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_core_fsm_1
  parameter
    core_rlp_C_0 = 1'd0,
    main_C_0 = 1'd1;

  reg [0:0] state_var;
  reg [0:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 2'b01;
        state_var_NS = main_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( ~ rst ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_staller
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_staller (
  clk, rst, core_wen, core_wten, config_done_cnsi_wen_comp, load_done_cnsi_wen_comp,
      compute_done_cnsi_wen_comp, store_done_cnsi_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  reg core_wten;
  input config_done_cnsi_wen_comp;
  input load_done_cnsi_wen_comp;
  input compute_done_cnsi_wen_comp;
  input store_done_cnsi_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign core_wen = config_done_cnsi_wen_comp & load_done_cnsi_wen_comp & compute_done_cnsi_wen_comp
      & store_done_cnsi_wen_comp;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      core_wten <= 1'b0;
    end
    else begin
      core_wten <= ~ core_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_store_done_cnsi_store_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_store_done_cnsi_store_done_wait_dp
    (
  clk, rst, store_done_cnsi_oswt_unreg, store_done_cnsi_bawt, store_done_cnsi_wen_comp,
      store_done_cnsi_biwt, store_done_cnsi_bdwt, store_done_cnsi_bcwt
);
  input clk;
  input rst;
  input store_done_cnsi_oswt_unreg;
  output store_done_cnsi_bawt;
  output store_done_cnsi_wen_comp;
  input store_done_cnsi_biwt;
  input store_done_cnsi_bdwt;
  output store_done_cnsi_bcwt;
  reg store_done_cnsi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign store_done_cnsi_bawt = store_done_cnsi_biwt | store_done_cnsi_bcwt;
  assign store_done_cnsi_wen_comp = (~ store_done_cnsi_oswt_unreg) | store_done_cnsi_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      store_done_cnsi_bcwt <= 1'b0;
    end
    else begin
      store_done_cnsi_bcwt <= ~((~(store_done_cnsi_bcwt | store_done_cnsi_biwt))
          | store_done_cnsi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_store_done_cnsi_store_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_store_done_cnsi_store_done_wait_ctrl
    (
  core_wen, store_done_cnsi_oswt_unreg, store_done_cnsi_iswt0, store_done_cnsi_ivld,
      store_done_cnsi_biwt, store_done_cnsi_bdwt, store_done_cnsi_bcwt, store_done_cnsi_irdy_core_sct
);
  input core_wen;
  input store_done_cnsi_oswt_unreg;
  input store_done_cnsi_iswt0;
  input store_done_cnsi_ivld;
  output store_done_cnsi_biwt;
  output store_done_cnsi_bdwt;
  input store_done_cnsi_bcwt;
  output store_done_cnsi_irdy_core_sct;


  // Interconnect Declarations
  wire store_done_cnsi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign store_done_cnsi_bdwt = store_done_cnsi_oswt_unreg & core_wen;
  assign store_done_cnsi_biwt = store_done_cnsi_ogwt & store_done_cnsi_ivld;
  assign store_done_cnsi_ogwt = store_done_cnsi_iswt0 & (~ store_done_cnsi_bcwt);
  assign store_done_cnsi_irdy_core_sct = store_done_cnsi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_compute_done_cnsi_compute_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_compute_done_cnsi_compute_done_wait_dp
    (
  clk, rst, compute_done_cnsi_oswt_unreg, compute_done_cnsi_bawt, compute_done_cnsi_wen_comp,
      compute_done_cnsi_biwt, compute_done_cnsi_bdwt, compute_done_cnsi_bcwt
);
  input clk;
  input rst;
  input compute_done_cnsi_oswt_unreg;
  output compute_done_cnsi_bawt;
  output compute_done_cnsi_wen_comp;
  input compute_done_cnsi_biwt;
  input compute_done_cnsi_bdwt;
  output compute_done_cnsi_bcwt;
  reg compute_done_cnsi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign compute_done_cnsi_bawt = compute_done_cnsi_biwt | compute_done_cnsi_bcwt;
  assign compute_done_cnsi_wen_comp = (~ compute_done_cnsi_oswt_unreg) | compute_done_cnsi_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      compute_done_cnsi_bcwt <= 1'b0;
    end
    else begin
      compute_done_cnsi_bcwt <= ~((~(compute_done_cnsi_bcwt | compute_done_cnsi_biwt))
          | compute_done_cnsi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_compute_done_cnsi_compute_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_compute_done_cnsi_compute_done_wait_ctrl
    (
  core_wen, compute_done_cnsi_oswt_unreg, compute_done_cnsi_iswt0, compute_done_cnsi_ivld,
      compute_done_cnsi_biwt, compute_done_cnsi_bdwt, compute_done_cnsi_bcwt, compute_done_cnsi_irdy_core_sct
);
  input core_wen;
  input compute_done_cnsi_oswt_unreg;
  input compute_done_cnsi_iswt0;
  input compute_done_cnsi_ivld;
  output compute_done_cnsi_biwt;
  output compute_done_cnsi_bdwt;
  input compute_done_cnsi_bcwt;
  output compute_done_cnsi_irdy_core_sct;


  // Interconnect Declarations
  wire compute_done_cnsi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign compute_done_cnsi_bdwt = compute_done_cnsi_oswt_unreg & core_wen;
  assign compute_done_cnsi_biwt = compute_done_cnsi_ogwt & compute_done_cnsi_ivld;
  assign compute_done_cnsi_ogwt = compute_done_cnsi_iswt0 & (~ compute_done_cnsi_bcwt);
  assign compute_done_cnsi_irdy_core_sct = compute_done_cnsi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_load_done_cnsi_load_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_load_done_cnsi_load_done_wait_dp
    (
  clk, rst, load_done_cnsi_oswt_unreg, load_done_cnsi_bawt, load_done_cnsi_wen_comp,
      load_done_cnsi_biwt, load_done_cnsi_bdwt, load_done_cnsi_bcwt
);
  input clk;
  input rst;
  input load_done_cnsi_oswt_unreg;
  output load_done_cnsi_bawt;
  output load_done_cnsi_wen_comp;
  input load_done_cnsi_biwt;
  input load_done_cnsi_bdwt;
  output load_done_cnsi_bcwt;
  reg load_done_cnsi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign load_done_cnsi_bawt = load_done_cnsi_biwt | load_done_cnsi_bcwt;
  assign load_done_cnsi_wen_comp = (~ load_done_cnsi_oswt_unreg) | load_done_cnsi_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      load_done_cnsi_bcwt <= 1'b0;
    end
    else begin
      load_done_cnsi_bcwt <= ~((~(load_done_cnsi_bcwt | load_done_cnsi_biwt)) | load_done_cnsi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_load_done_cnsi_load_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_load_done_cnsi_load_done_wait_ctrl
    (
  core_wen, load_done_cnsi_oswt_unreg, load_done_cnsi_iswt0, load_done_cnsi_irdy_core_psct,
      load_done_cnsi_ivld, load_done_cnsi_biwt, load_done_cnsi_bdwt, load_done_cnsi_bcwt,
      load_done_cnsi_irdy_core_sct
);
  input core_wen;
  input load_done_cnsi_oswt_unreg;
  input load_done_cnsi_iswt0;
  input load_done_cnsi_irdy_core_psct;
  input load_done_cnsi_ivld;
  output load_done_cnsi_biwt;
  output load_done_cnsi_bdwt;
  input load_done_cnsi_bcwt;
  output load_done_cnsi_irdy_core_sct;


  // Interconnect Declarations
  wire load_done_cnsi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign load_done_cnsi_bdwt = load_done_cnsi_oswt_unreg & core_wen;
  assign load_done_cnsi_biwt = load_done_cnsi_ogwt & load_done_cnsi_ivld;
  assign load_done_cnsi_ogwt = load_done_cnsi_iswt0 & (~ load_done_cnsi_bcwt);
  assign load_done_cnsi_irdy_core_sct = load_done_cnsi_irdy_core_psct & load_done_cnsi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_config_done_cnsi_config_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_config_done_cnsi_config_done_wait_dp
    (
  clk, rst, config_done_cnsi_oswt_unreg, config_done_cnsi_bawt, config_done_cnsi_wen_comp,
      config_done_cnsi_biwt, config_done_cnsi_bdwt, config_done_cnsi_bcwt
);
  input clk;
  input rst;
  input config_done_cnsi_oswt_unreg;
  output config_done_cnsi_bawt;
  output config_done_cnsi_wen_comp;
  input config_done_cnsi_biwt;
  input config_done_cnsi_bdwt;
  output config_done_cnsi_bcwt;
  reg config_done_cnsi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign config_done_cnsi_bawt = config_done_cnsi_biwt | config_done_cnsi_bcwt;
  assign config_done_cnsi_wen_comp = (~ config_done_cnsi_oswt_unreg) | config_done_cnsi_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      config_done_cnsi_bcwt <= 1'b0;
    end
    else begin
      config_done_cnsi_bcwt <= ~((~(config_done_cnsi_bcwt | config_done_cnsi_biwt))
          | config_done_cnsi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_config_done_cnsi_config_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_config_done_cnsi_config_done_wait_ctrl
    (
  core_wen, config_done_cnsi_oswt_unreg, config_done_cnsi_iswt0, config_done_cnsi_ivld,
      config_done_cnsi_biwt, config_done_cnsi_bdwt, config_done_cnsi_bcwt, config_done_cnsi_irdy_core_sct
);
  input core_wen;
  input config_done_cnsi_oswt_unreg;
  input config_done_cnsi_iswt0;
  input config_done_cnsi_ivld;
  output config_done_cnsi_biwt;
  output config_done_cnsi_bdwt;
  input config_done_cnsi_bcwt;
  output config_done_cnsi_irdy_core_sct;


  // Interconnect Declarations
  wire config_done_cnsi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign config_done_cnsi_bdwt = config_done_cnsi_oswt_unreg & core_wen;
  assign config_done_cnsi_biwt = config_done_cnsi_ogwt & config_done_cnsi_ivld;
  assign config_done_cnsi_ogwt = config_done_cnsi_iswt0 & (~ config_done_cnsi_bcwt);
  assign config_done_cnsi_irdy_core_sct = config_done_cnsi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_acc_done_rsci_acc_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_acc_done_rsci_acc_done_wait_dp
    (
  clk, rst, acc_done_rsci_bawt, acc_done_rsci_biwt, acc_done_rsci_bdwt
);
  input clk;
  input rst;
  output acc_done_rsci_bawt;
  input acc_done_rsci_biwt;
  input acc_done_rsci_bdwt;


  // Interconnect Declarations
  reg acc_done_rsci_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign acc_done_rsci_bawt = acc_done_rsci_biwt | acc_done_rsci_bcwt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      acc_done_rsci_bcwt <= 1'b0;
    end
    else begin
      acc_done_rsci_bcwt <= ~((~(acc_done_rsci_bcwt | acc_done_rsci_biwt)) | acc_done_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_acc_done_rsci_acc_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_acc_done_rsci_acc_done_wait_ctrl
    (
  core_wen, acc_done_rsci_oswt_unreg, acc_done_rsci_iswt0, core_wten, acc_done_rsci_biwt,
      acc_done_rsci_bdwt
);
  input core_wen;
  input acc_done_rsci_oswt_unreg;
  input acc_done_rsci_iswt0;
  input core_wten;
  output acc_done_rsci_biwt;
  output acc_done_rsci_bdwt;



  // Interconnect Declarations for Component Instantiations 
  assign acc_done_rsci_bdwt = acc_done_rsci_oswt_unreg & core_wen;
  assign acc_done_rsci_biwt = (~ core_wten) & acc_done_rsci_iswt0;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_core_fsm (
  clk, rst, core_wen, fsm_output
);
  input clk;
  input rst;
  input core_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;


  // FSM State Type Declaration for esp_acc_softmax_cxx_catapult_config_core_core_fsm_1
  parameter
    core_rlp_C_0 = 1'd0,
    main_C_0 = 1'd1;

  reg [0:0] state_var;
  reg [0:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_catapult_config_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 2'b01;
        state_var_NS = main_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( ~ rst ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_staller
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_staller (
  core_wen, conf_info_rsci_wen_comp, plm_conf_load_rsci_wen_comp, plm_conf_compute_rsci_wen_comp,
      plm_conf_store_rsci_wen_comp, done_rsci_wen_comp
);
  output core_wen;
  input conf_info_rsci_wen_comp;
  input plm_conf_load_rsci_wen_comp;
  input plm_conf_compute_rsci_wen_comp;
  input plm_conf_store_rsci_wen_comp;
  input done_rsci_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign core_wen = conf_info_rsci_wen_comp & plm_conf_load_rsci_wen_comp & plm_conf_compute_rsci_wen_comp
      & plm_conf_store_rsci_wen_comp & done_rsci_wen_comp;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_done_rsci_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_done_rsci_done_wait_dp (
  clk, rst, done_rsci_oswt_unreg, done_rsci_bawt, done_rsci_wen_comp, done_rsci_biwt,
      done_rsci_bdwt, done_rsci_bcwt
);
  input clk;
  input rst;
  input done_rsci_oswt_unreg;
  output done_rsci_bawt;
  output done_rsci_wen_comp;
  input done_rsci_biwt;
  input done_rsci_bdwt;
  output done_rsci_bcwt;
  reg done_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign done_rsci_bawt = done_rsci_biwt | done_rsci_bcwt;
  assign done_rsci_wen_comp = (~ done_rsci_oswt_unreg) | done_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      done_rsci_bcwt <= 1'b0;
    end
    else begin
      done_rsci_bcwt <= ~((~(done_rsci_bcwt | done_rsci_biwt)) | done_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_done_rsci_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_done_rsci_done_wait_ctrl (
  core_wen, done_rsci_oswt_unreg, done_rsci_iswt0, done_rsci_biwt, done_rsci_bdwt,
      done_rsci_bcwt, done_rsci_ivld_core_sct, done_rsci_irdy
);
  input core_wen;
  input done_rsci_oswt_unreg;
  input done_rsci_iswt0;
  output done_rsci_biwt;
  output done_rsci_bdwt;
  input done_rsci_bcwt;
  output done_rsci_ivld_core_sct;
  input done_rsci_irdy;


  // Interconnect Declarations
  wire done_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign done_rsci_bdwt = done_rsci_oswt_unreg & core_wen;
  assign done_rsci_biwt = done_rsci_ogwt & done_rsci_irdy;
  assign done_rsci_ogwt = done_rsci_iswt0 & (~ done_rsci_bcwt);
  assign done_rsci_ivld_core_sct = done_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_plm_conf_store_rsci_plm_conf_store_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_plm_conf_store_rsci_plm_conf_store_wait_dp
    (
  clk, rst, plm_conf_store_rsci_oswt_unreg, plm_conf_store_rsci_bawt, plm_conf_store_rsci_wen_comp,
      plm_conf_store_rsci_biwt, plm_conf_store_rsci_bdwt, plm_conf_store_rsci_bcwt
);
  input clk;
  input rst;
  input plm_conf_store_rsci_oswt_unreg;
  output plm_conf_store_rsci_bawt;
  output plm_conf_store_rsci_wen_comp;
  input plm_conf_store_rsci_biwt;
  input plm_conf_store_rsci_bdwt;
  output plm_conf_store_rsci_bcwt;
  reg plm_conf_store_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_store_rsci_bawt = plm_conf_store_rsci_biwt | plm_conf_store_rsci_bcwt;
  assign plm_conf_store_rsci_wen_comp = (~ plm_conf_store_rsci_oswt_unreg) | plm_conf_store_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_conf_store_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_conf_store_rsci_bcwt <= ~((~(plm_conf_store_rsci_bcwt | plm_conf_store_rsci_biwt))
          | plm_conf_store_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_plm_conf_store_rsci_plm_conf_store_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_plm_conf_store_rsci_plm_conf_store_wait_ctrl
    (
  core_wen, plm_conf_store_rsci_oswt_unreg, plm_conf_store_rsci_iswt0, plm_conf_store_rsci_irdy_oreg,
      plm_conf_store_rsci_biwt, plm_conf_store_rsci_bdwt, plm_conf_store_rsci_bcwt,
      plm_conf_store_rsci_ivld_core_sct
);
  input core_wen;
  input plm_conf_store_rsci_oswt_unreg;
  input plm_conf_store_rsci_iswt0;
  input plm_conf_store_rsci_irdy_oreg;
  output plm_conf_store_rsci_biwt;
  output plm_conf_store_rsci_bdwt;
  input plm_conf_store_rsci_bcwt;
  output plm_conf_store_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire plm_conf_store_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_store_rsci_bdwt = plm_conf_store_rsci_oswt_unreg & core_wen;
  assign plm_conf_store_rsci_biwt = plm_conf_store_rsci_ogwt & plm_conf_store_rsci_irdy_oreg;
  assign plm_conf_store_rsci_ogwt = plm_conf_store_rsci_iswt0 & (~ plm_conf_store_rsci_bcwt);
  assign plm_conf_store_rsci_ivld_core_sct = plm_conf_store_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_plm_conf_compute_rsci_plm_conf_compute_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_plm_conf_compute_rsci_plm_conf_compute_wait_dp
    (
  clk, rst, plm_conf_compute_rsci_oswt_unreg, plm_conf_compute_rsci_bawt, plm_conf_compute_rsci_wen_comp,
      plm_conf_compute_rsci_biwt, plm_conf_compute_rsci_bdwt, plm_conf_compute_rsci_bcwt
);
  input clk;
  input rst;
  input plm_conf_compute_rsci_oswt_unreg;
  output plm_conf_compute_rsci_bawt;
  output plm_conf_compute_rsci_wen_comp;
  input plm_conf_compute_rsci_biwt;
  input plm_conf_compute_rsci_bdwt;
  output plm_conf_compute_rsci_bcwt;
  reg plm_conf_compute_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_compute_rsci_bawt = plm_conf_compute_rsci_biwt | plm_conf_compute_rsci_bcwt;
  assign plm_conf_compute_rsci_wen_comp = (~ plm_conf_compute_rsci_oswt_unreg) |
      plm_conf_compute_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_conf_compute_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_conf_compute_rsci_bcwt <= ~((~(plm_conf_compute_rsci_bcwt | plm_conf_compute_rsci_biwt))
          | plm_conf_compute_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_plm_conf_compute_rsci_plm_conf_compute_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_plm_conf_compute_rsci_plm_conf_compute_wait_ctrl
    (
  core_wen, plm_conf_compute_rsci_oswt_unreg, plm_conf_compute_rsci_iswt0, plm_conf_compute_rsci_irdy_oreg,
      plm_conf_compute_rsci_biwt, plm_conf_compute_rsci_bdwt, plm_conf_compute_rsci_bcwt,
      plm_conf_compute_rsci_ivld_core_sct
);
  input core_wen;
  input plm_conf_compute_rsci_oswt_unreg;
  input plm_conf_compute_rsci_iswt0;
  input plm_conf_compute_rsci_irdy_oreg;
  output plm_conf_compute_rsci_biwt;
  output plm_conf_compute_rsci_bdwt;
  input plm_conf_compute_rsci_bcwt;
  output plm_conf_compute_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire plm_conf_compute_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_compute_rsci_bdwt = plm_conf_compute_rsci_oswt_unreg & core_wen;
  assign plm_conf_compute_rsci_biwt = plm_conf_compute_rsci_ogwt & plm_conf_compute_rsci_irdy_oreg;
  assign plm_conf_compute_rsci_ogwt = plm_conf_compute_rsci_iswt0 & (~ plm_conf_compute_rsci_bcwt);
  assign plm_conf_compute_rsci_ivld_core_sct = plm_conf_compute_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_plm_conf_load_rsci_plm_conf_load_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_plm_conf_load_rsci_plm_conf_load_wait_dp
    (
  clk, rst, plm_conf_load_rsci_oswt_unreg, plm_conf_load_rsci_bawt, plm_conf_load_rsci_wen_comp,
      plm_conf_load_rsci_biwt, plm_conf_load_rsci_bdwt, plm_conf_load_rsci_bcwt
);
  input clk;
  input rst;
  input plm_conf_load_rsci_oswt_unreg;
  output plm_conf_load_rsci_bawt;
  output plm_conf_load_rsci_wen_comp;
  input plm_conf_load_rsci_biwt;
  input plm_conf_load_rsci_bdwt;
  output plm_conf_load_rsci_bcwt;
  reg plm_conf_load_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_load_rsci_bawt = plm_conf_load_rsci_biwt | plm_conf_load_rsci_bcwt;
  assign plm_conf_load_rsci_wen_comp = (~ plm_conf_load_rsci_oswt_unreg) | plm_conf_load_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_conf_load_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_conf_load_rsci_bcwt <= ~((~(plm_conf_load_rsci_bcwt | plm_conf_load_rsci_biwt))
          | plm_conf_load_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_plm_conf_load_rsci_plm_conf_load_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_plm_conf_load_rsci_plm_conf_load_wait_ctrl
    (
  core_wen, plm_conf_load_rsci_oswt_unreg, plm_conf_load_rsci_iswt0, plm_conf_load_rsci_irdy_oreg,
      plm_conf_load_rsci_biwt, plm_conf_load_rsci_bdwt, plm_conf_load_rsci_bcwt,
      plm_conf_load_rsci_ivld_core_sct
);
  input core_wen;
  input plm_conf_load_rsci_oswt_unreg;
  input plm_conf_load_rsci_iswt0;
  input plm_conf_load_rsci_irdy_oreg;
  output plm_conf_load_rsci_biwt;
  output plm_conf_load_rsci_bdwt;
  input plm_conf_load_rsci_bcwt;
  output plm_conf_load_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire plm_conf_load_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_load_rsci_bdwt = plm_conf_load_rsci_oswt_unreg & core_wen;
  assign plm_conf_load_rsci_biwt = plm_conf_load_rsci_ogwt & plm_conf_load_rsci_irdy_oreg;
  assign plm_conf_load_rsci_ogwt = plm_conf_load_rsci_iswt0 & (~ plm_conf_load_rsci_bcwt);
  assign plm_conf_load_rsci_ivld_core_sct = plm_conf_load_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_wait_dp (
  clk, rst, plm_conf_load_rsci_irdy, plm_conf_load_rsci_irdy_oreg, plm_conf_compute_rsci_irdy,
      plm_conf_compute_rsci_irdy_oreg, plm_conf_store_rsci_irdy, plm_conf_store_rsci_irdy_oreg
);
  input clk;
  input rst;
  input plm_conf_load_rsci_irdy;
  output plm_conf_load_rsci_irdy_oreg;
  input plm_conf_compute_rsci_irdy;
  output plm_conf_compute_rsci_irdy_oreg;
  input plm_conf_store_rsci_irdy;
  output plm_conf_store_rsci_irdy_oreg;


  // Interconnect Declarations
  reg plm_conf_load_rsci_irdy_oreg_rneg;
  reg plm_conf_compute_rsci_irdy_oreg_rneg;
  reg plm_conf_store_rsci_irdy_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_load_rsci_irdy_oreg = ~ plm_conf_load_rsci_irdy_oreg_rneg;
  assign plm_conf_compute_rsci_irdy_oreg = ~ plm_conf_compute_rsci_irdy_oreg_rneg;
  assign plm_conf_store_rsci_irdy_oreg = ~ plm_conf_store_rsci_irdy_oreg_rneg;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_conf_load_rsci_irdy_oreg_rneg <= 1'b0;
      plm_conf_compute_rsci_irdy_oreg_rneg <= 1'b0;
      plm_conf_store_rsci_irdy_oreg_rneg <= 1'b0;
    end
    else begin
      plm_conf_load_rsci_irdy_oreg_rneg <= ~ plm_conf_load_rsci_irdy;
      plm_conf_compute_rsci_irdy_oreg_rneg <= ~ plm_conf_compute_rsci_irdy;
      plm_conf_store_rsci_irdy_oreg_rneg <= ~ plm_conf_store_rsci_irdy;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_conf_info_rsci_conf_info_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_conf_info_rsci_conf_info_wait_dp
    (
  clk, rst, conf_info_rsci_oswt_unreg, conf_info_rsci_bawt, conf_info_rsci_wen_comp,
      conf_info_rsci_idat_mxwt, conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt,
      conf_info_rsci_idat
);
  input clk;
  input rst;
  input conf_info_rsci_oswt_unreg;
  output conf_info_rsci_bawt;
  output conf_info_rsci_wen_comp;
  output [31:0] conf_info_rsci_idat_mxwt;
  input conf_info_rsci_biwt;
  input conf_info_rsci_bdwt;
  output conf_info_rsci_bcwt;
  reg conf_info_rsci_bcwt;
  input [31:0] conf_info_rsci_idat;


  // Interconnect Declarations
  reg [31:0] conf_info_rsci_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_bawt = conf_info_rsci_biwt | conf_info_rsci_bcwt;
  assign conf_info_rsci_wen_comp = (~ conf_info_rsci_oswt_unreg) | conf_info_rsci_bawt;
  assign conf_info_rsci_idat_mxwt = MUX_v_32_2_2(conf_info_rsci_idat, conf_info_rsci_idat_bfwt,
      conf_info_rsci_bcwt);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_bcwt <= 1'b0;
    end
    else begin
      conf_info_rsci_bcwt <= ~((~(conf_info_rsci_bcwt | conf_info_rsci_biwt)) | conf_info_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_idat_bfwt <= 32'b00000000000000000000000000000000;
    end
    else if ( conf_info_rsci_biwt ) begin
      conf_info_rsci_idat_bfwt <= conf_info_rsci_idat;
    end
  end

  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [0:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_conf_info_rsci_conf_info_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_conf_info_rsci_conf_info_wait_ctrl
    (
  core_wen, conf_info_rsci_oswt_unreg, conf_info_rsci_iswt0, conf_info_rsci_biwt,
      conf_info_rsci_bdwt, conf_info_rsci_bcwt, conf_info_rsci_irdy_core_sct, conf_info_rsci_ivld
);
  input core_wen;
  input conf_info_rsci_oswt_unreg;
  input conf_info_rsci_iswt0;
  output conf_info_rsci_biwt;
  output conf_info_rsci_bdwt;
  input conf_info_rsci_bcwt;
  output conf_info_rsci_irdy_core_sct;
  input conf_info_rsci_ivld;


  // Interconnect Declarations
  wire conf_info_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_bdwt = conf_info_rsci_oswt_unreg & core_wen;
  assign conf_info_rsci_biwt = conf_info_rsci_ogwt & conf_info_rsci_ivld;
  assign conf_info_rsci_ogwt = conf_info_rsci_iswt0 & (~ conf_info_rsci_bcwt);
  assign conf_info_rsci_irdy_core_sct = conf_info_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_core_fsm (
  clk, rst, core_wen, fsm_output
);
  input clk;
  input rst;
  input core_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;


  // FSM State Type Declaration for esp_acc_softmax_cxx_catapult_load_core_core_fsm_1
  parameter
    core_rlp_C_0 = 1'd0,
    main_C_0 = 1'd1;

  reg [0:0] state_var;
  reg [0:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_catapult_load_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 2'b01;
        state_var_NS = main_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( ~ rst ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_staller
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_staller (
  clk, rst, core_wen, core_wten, conf_info_rsci_wen_comp, plm_in_rsci_wen_comp, dma_read_chnl_rsci_wen_comp,
      done_rsci_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  reg core_wten;
  input conf_info_rsci_wen_comp;
  input plm_in_rsci_wen_comp;
  input dma_read_chnl_rsci_wen_comp;
  input done_rsci_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign core_wen = conf_info_rsci_wen_comp & plm_in_rsci_wen_comp & dma_read_chnl_rsci_wen_comp
      & done_rsci_wen_comp;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      core_wten <= 1'b0;
    end
    else begin
      core_wten <= ~ core_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_done_rsci_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_done_rsci_done_wait_dp (
  clk, rst, done_rsci_oswt_unreg, done_rsci_bawt, done_rsci_wen_comp, done_rsci_biwt,
      done_rsci_bdwt, done_rsci_bcwt
);
  input clk;
  input rst;
  input done_rsci_oswt_unreg;
  output done_rsci_bawt;
  output done_rsci_wen_comp;
  input done_rsci_biwt;
  input done_rsci_bdwt;
  output done_rsci_bcwt;
  reg done_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign done_rsci_bawt = done_rsci_biwt | done_rsci_bcwt;
  assign done_rsci_wen_comp = (~ done_rsci_oswt_unreg) | done_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      done_rsci_bcwt <= 1'b0;
    end
    else begin
      done_rsci_bcwt <= ~((~(done_rsci_bcwt | done_rsci_biwt)) | done_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_done_rsci_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_done_rsci_done_wait_ctrl (
  core_wen, done_rsci_oswt_unreg, done_rsci_iswt0, done_rsci_biwt, done_rsci_bdwt,
      done_rsci_bcwt, done_rsci_ivld_core_sct, done_rsci_irdy
);
  input core_wen;
  input done_rsci_oswt_unreg;
  input done_rsci_iswt0;
  output done_rsci_biwt;
  output done_rsci_bdwt;
  input done_rsci_bcwt;
  output done_rsci_ivld_core_sct;
  input done_rsci_irdy;


  // Interconnect Declarations
  wire done_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign done_rsci_bdwt = done_rsci_oswt_unreg & core_wen;
  assign done_rsci_biwt = done_rsci_ogwt & done_rsci_irdy;
  assign done_rsci_ogwt = done_rsci_iswt0 & (~ done_rsci_bcwt);
  assign done_rsci_ivld_core_sct = done_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_dma_read_chnl_rsci_dma_read_chnl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_dma_read_chnl_rsci_dma_read_chnl_wait_dp
    (
  clk, rst, dma_read_chnl_rsci_oswt_unreg, dma_read_chnl_rsci_bawt, dma_read_chnl_rsci_wen_comp,
      dma_read_chnl_rsci_idat_mxwt, dma_read_chnl_rsci_biwt, dma_read_chnl_rsci_bdwt,
      dma_read_chnl_rsci_bcwt, dma_read_chnl_rsci_idat
);
  input clk;
  input rst;
  input dma_read_chnl_rsci_oswt_unreg;
  output dma_read_chnl_rsci_bawt;
  output dma_read_chnl_rsci_wen_comp;
  output [31:0] dma_read_chnl_rsci_idat_mxwt;
  input dma_read_chnl_rsci_biwt;
  input dma_read_chnl_rsci_bdwt;
  output dma_read_chnl_rsci_bcwt;
  reg dma_read_chnl_rsci_bcwt;
  input [63:0] dma_read_chnl_rsci_idat;


  // Interconnect Declarations
  reg [31:0] dma_read_chnl_rsci_idat_bfwt_31_0;


  // Interconnect Declarations for Component Instantiations 
  assign dma_read_chnl_rsci_bawt = dma_read_chnl_rsci_biwt | dma_read_chnl_rsci_bcwt;
  assign dma_read_chnl_rsci_wen_comp = (~ dma_read_chnl_rsci_oswt_unreg) | dma_read_chnl_rsci_bawt;
  assign dma_read_chnl_rsci_idat_mxwt = MUX_v_32_2_2((dma_read_chnl_rsci_idat[31:0]),
      dma_read_chnl_rsci_idat_bfwt_31_0, dma_read_chnl_rsci_bcwt);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_read_chnl_rsci_bcwt <= 1'b0;
    end
    else begin
      dma_read_chnl_rsci_bcwt <= ~((~(dma_read_chnl_rsci_bcwt | dma_read_chnl_rsci_biwt))
          | dma_read_chnl_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_read_chnl_rsci_idat_bfwt_31_0 <= 32'b00000000000000000000000000000000;
    end
    else if ( dma_read_chnl_rsci_biwt ) begin
      dma_read_chnl_rsci_idat_bfwt_31_0 <= dma_read_chnl_rsci_idat[31:0];
    end
  end

  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [0:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl
    (
  core_wen, dma_read_chnl_rsci_oswt_unreg, dma_read_chnl_rsci_iswt0, dma_read_chnl_rsci_biwt,
      dma_read_chnl_rsci_bdwt, dma_read_chnl_rsci_bcwt, dma_read_chnl_rsci_irdy_core_sct,
      dma_read_chnl_rsci_ivld
);
  input core_wen;
  input dma_read_chnl_rsci_oswt_unreg;
  input dma_read_chnl_rsci_iswt0;
  output dma_read_chnl_rsci_biwt;
  output dma_read_chnl_rsci_bdwt;
  input dma_read_chnl_rsci_bcwt;
  output dma_read_chnl_rsci_irdy_core_sct;
  input dma_read_chnl_rsci_ivld;


  // Interconnect Declarations
  wire dma_read_chnl_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign dma_read_chnl_rsci_bdwt = dma_read_chnl_rsci_oswt_unreg & core_wen;
  assign dma_read_chnl_rsci_biwt = dma_read_chnl_rsci_ogwt & dma_read_chnl_rsci_ivld;
  assign dma_read_chnl_rsci_ogwt = dma_read_chnl_rsci_iswt0 & (~ dma_read_chnl_rsci_bcwt);
  assign dma_read_chnl_rsci_irdy_core_sct = dma_read_chnl_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp
    (
  clk, rst, dma_read_ctrl_rsci_bawt, dma_read_ctrl_rsci_irdy_mxwt, dma_read_ctrl_rsci_irdy,
      dma_read_ctrl_rsci_biwt, dma_read_ctrl_rsci_bdwt
);
  input clk;
  input rst;
  output dma_read_ctrl_rsci_bawt;
  output dma_read_ctrl_rsci_irdy_mxwt;
  input dma_read_ctrl_rsci_irdy;
  input dma_read_ctrl_rsci_biwt;
  input dma_read_ctrl_rsci_bdwt;


  // Interconnect Declarations
  reg dma_read_ctrl_rsci_bcwt;
  reg dma_read_ctrl_rsci_irdy_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign dma_read_ctrl_rsci_bawt = dma_read_ctrl_rsci_biwt | dma_read_ctrl_rsci_bcwt;
  assign dma_read_ctrl_rsci_irdy_mxwt = MUX_s_1_2_2(dma_read_ctrl_rsci_irdy, dma_read_ctrl_rsci_irdy_bfwt,
      dma_read_ctrl_rsci_bcwt);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_read_ctrl_rsci_bcwt <= 1'b0;
    end
    else begin
      dma_read_ctrl_rsci_bcwt <= ~((~(dma_read_ctrl_rsci_bcwt | dma_read_ctrl_rsci_biwt))
          | dma_read_ctrl_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_read_ctrl_rsci_irdy_bfwt <= 1'b0;
    end
    else if ( dma_read_ctrl_rsci_biwt ) begin
      dma_read_ctrl_rsci_irdy_bfwt <= dma_read_ctrl_rsci_irdy;
    end
  end

  function automatic [0:0] MUX_s_1_2_2;
    input [0:0] input_0;
    input [0:0] input_1;
    input [0:0] sel;
    reg [0:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl
    (
  core_wen, core_wten, dma_read_ctrl_rsci_oswt_unreg, dma_read_ctrl_rsci_iswt0, dma_read_ctrl_rsci_biwt,
      dma_read_ctrl_rsci_bdwt
);
  input core_wen;
  input core_wten;
  input dma_read_ctrl_rsci_oswt_unreg;
  input dma_read_ctrl_rsci_iswt0;
  output dma_read_ctrl_rsci_biwt;
  output dma_read_ctrl_rsci_bdwt;



  // Interconnect Declarations for Component Instantiations 
  assign dma_read_ctrl_rsci_bdwt = dma_read_ctrl_rsci_oswt_unreg & core_wen;
  assign dma_read_ctrl_rsci_biwt = (~ core_wten) & dma_read_ctrl_rsci_iswt0;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_plm_in_rsci_plm_in_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_plm_in_rsci_plm_in_wait_dp (
  clk, rst, plm_in_rsci_oswt_unreg, plm_in_rsci_bawt, plm_in_rsci_wen_comp, plm_in_rsci_biwt,
      plm_in_rsci_bdwt, plm_in_rsci_bcwt
);
  input clk;
  input rst;
  input plm_in_rsci_oswt_unreg;
  output plm_in_rsci_bawt;
  output plm_in_rsci_wen_comp;
  input plm_in_rsci_biwt;
  input plm_in_rsci_bdwt;
  output plm_in_rsci_bcwt;
  reg plm_in_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsci_bawt = plm_in_rsci_biwt | plm_in_rsci_bcwt;
  assign plm_in_rsci_wen_comp = (~ plm_in_rsci_oswt_unreg) | plm_in_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_in_rsci_bcwt <= ~((~(plm_in_rsci_bcwt | plm_in_rsci_biwt)) | plm_in_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_plm_in_rsci_plm_in_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_plm_in_rsci_plm_in_wait_ctrl (
  core_wen, plm_in_rsci_oswt_unreg, plm_in_rsci_iswt0, plm_in_rsci_irdy_oreg, plm_in_rsci_biwt,
      plm_in_rsci_bdwt, plm_in_rsci_bcwt, plm_in_rsci_ivld_core_sct
);
  input core_wen;
  input plm_in_rsci_oswt_unreg;
  input plm_in_rsci_iswt0;
  input plm_in_rsci_irdy_oreg;
  output plm_in_rsci_biwt;
  output plm_in_rsci_bdwt;
  input plm_in_rsci_bcwt;
  output plm_in_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire plm_in_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsci_bdwt = plm_in_rsci_oswt_unreg & core_wen;
  assign plm_in_rsci_biwt = plm_in_rsci_ogwt & plm_in_rsci_irdy_oreg;
  assign plm_in_rsci_ogwt = plm_in_rsci_iswt0 & (~ plm_in_rsci_bcwt);
  assign plm_in_rsci_ivld_core_sct = plm_in_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_conf_info_rsci_conf_info_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_conf_info_rsci_conf_info_wait_dp (
  clk, rst, conf_info_rsci_oswt_unreg, conf_info_rsci_bawt, conf_info_rsci_wen_comp,
      conf_info_rsci_idat_mxwt, conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt,
      conf_info_rsci_idat
);
  input clk;
  input rst;
  input conf_info_rsci_oswt_unreg;
  output conf_info_rsci_bawt;
  output conf_info_rsci_wen_comp;
  output [31:0] conf_info_rsci_idat_mxwt;
  input conf_info_rsci_biwt;
  input conf_info_rsci_bdwt;
  output conf_info_rsci_bcwt;
  reg conf_info_rsci_bcwt;
  input [31:0] conf_info_rsci_idat;


  // Interconnect Declarations
  reg [31:0] conf_info_rsci_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_bawt = conf_info_rsci_biwt | conf_info_rsci_bcwt;
  assign conf_info_rsci_wen_comp = (~ conf_info_rsci_oswt_unreg) | conf_info_rsci_bawt;
  assign conf_info_rsci_idat_mxwt = MUX_v_32_2_2(conf_info_rsci_idat, conf_info_rsci_idat_bfwt,
      conf_info_rsci_bcwt);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_bcwt <= 1'b0;
    end
    else begin
      conf_info_rsci_bcwt <= ~((~(conf_info_rsci_bcwt | conf_info_rsci_biwt)) | conf_info_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_idat_bfwt <= 32'b00000000000000000000000000000000;
    end
    else if ( conf_info_rsci_biwt ) begin
      conf_info_rsci_idat_bfwt <= conf_info_rsci_idat;
    end
  end

  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [0:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_conf_info_rsci_conf_info_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_conf_info_rsci_conf_info_wait_ctrl
    (
  core_wen, conf_info_rsci_oswt_unreg, conf_info_rsci_iswt0, conf_info_rsci_irdy_core_psct,
      conf_info_rsci_ivld_oreg, conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt,
      conf_info_rsci_irdy_core_sct
);
  input core_wen;
  input conf_info_rsci_oswt_unreg;
  input conf_info_rsci_iswt0;
  input conf_info_rsci_irdy_core_psct;
  input conf_info_rsci_ivld_oreg;
  output conf_info_rsci_biwt;
  output conf_info_rsci_bdwt;
  input conf_info_rsci_bcwt;
  output conf_info_rsci_irdy_core_sct;


  // Interconnect Declarations
  wire conf_info_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_bdwt = conf_info_rsci_oswt_unreg & core_wen;
  assign conf_info_rsci_biwt = conf_info_rsci_ogwt & conf_info_rsci_ivld_oreg;
  assign conf_info_rsci_ogwt = conf_info_rsci_iswt0 & (~ conf_info_rsci_bcwt);
  assign conf_info_rsci_irdy_core_sct = conf_info_rsci_irdy_core_psct & conf_info_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_wait_dp (
  clk, rst, conf_info_rsci_ivld, conf_info_rsci_ivld_oreg, plm_in_rsci_irdy, plm_in_rsci_irdy_oreg
);
  input clk;
  input rst;
  input conf_info_rsci_ivld;
  output conf_info_rsci_ivld_oreg;
  input plm_in_rsci_irdy;
  output plm_in_rsci_irdy_oreg;


  // Interconnect Declarations
  reg conf_info_rsci_ivld_oreg_rneg;
  reg plm_in_rsci_irdy_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_ivld_oreg = ~ conf_info_rsci_ivld_oreg_rneg;
  assign plm_in_rsci_irdy_oreg = ~ plm_in_rsci_irdy_oreg_rneg;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_ivld_oreg_rneg <= 1'b0;
      plm_in_rsci_irdy_oreg_rneg <= 1'b0;
    end
    else begin
      conf_info_rsci_ivld_oreg_rneg <= ~ conf_info_rsci_ivld;
      plm_in_rsci_irdy_oreg_rneg <= ~ plm_in_rsci_irdy;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_core_fsm (
  clk, rst, core_wen, fsm_output
);
  input clk;
  input rst;
  input core_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;


  // FSM State Type Declaration for esp_acc_softmax_cxx_catapult_compute_core_core_fsm_1
  parameter
    core_rlp_C_0 = 1'd0,
    main_C_0 = 1'd1;

  reg [0:0] state_var;
  reg [0:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_catapult_compute_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 2'b01;
        state_var_NS = main_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( ~ rst ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_staller
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_staller (
  clk, rst, core_wen, core_wten, conf_info_rsci_wen_comp, plm_in_rsci_wen_comp, plm_out_rsci_wen_comp,
      done_rsci_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  reg core_wten;
  input conf_info_rsci_wen_comp;
  input plm_in_rsci_wen_comp;
  input plm_out_rsci_wen_comp;
  input done_rsci_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign core_wen = conf_info_rsci_wen_comp & plm_in_rsci_wen_comp & plm_out_rsci_wen_comp
      & done_rsci_wen_comp;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      core_wten <= 1'b0;
    end
    else begin
      core_wten <= ~ core_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_mgc_mul_15_0_32_1_47_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_mgc_mul_15_0_32_1_47_wait_ctrl
    (
  clk, rst, core_wen, core_wten, ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_oswt_unreg,
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_iswt1,
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_biwt,
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_oswt_unreg;
  input ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_iswt1;
  output ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_biwt;
  output ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bdwt;


  // Interconnect Declarations
  reg ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_c_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_pdswt0;
  reg [1:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_icwt;
  wire [2:0] nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_icwt;

  wire[1:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_acc_nl;
  wire[2:0] nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_acc_nl;

  // Interconnect Declarations for Component Instantiations 
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bdwt
      = ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_oswt_unreg
      & core_wen;
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_biwt
      = ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_c_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_pdswt0
      | (ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_icwt!=2'b00);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_c_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_pdswt0
          <= 1'b0;
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_icwt
          <= 2'b00;
    end
    else begin
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_c_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_pdswt0
          <= (~ core_wten) & ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_iswt1;
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_icwt
          <= nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_icwt[1:0];
    end
  end
  assign nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_acc_nl
      = conv_s2s_1_2(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_biwt)
      + conv_u2s_1_2(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_c_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_pdswt0);
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_acc_nl
      = nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_acc_nl[1:0];
  assign nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_icwt
      = ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_acc_nl
      + ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_icwt;

  function automatic [1:0] conv_s2s_1_2 ;
    input [0:0]  vector ;
  begin
    conv_s2s_1_2 = {vector[0], vector};
  end
  endfunction


  function automatic [1:0] conv_u2s_1_2 ;
    input [0:0]  vector ;
  begin
    conv_u2s_1_2 =  {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_mgc_mul_15_0_32_1_47_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_mgc_mul_15_0_32_1_47_wait_dp
    (
  clk, rst, ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt,
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg,
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt,
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_biwt,
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bdwt
);
  input clk;
  input rst;
  output ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt;
  input [46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg;
  output [18:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt;
  input ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_biwt;
  input ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bdwt;


  // Interconnect Declarations
  reg [1:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bcwt;
  wire [2:0] nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bcwt;
  reg [18:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_bfwt_1_46_28;
  reg [18:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_bfwt_46_28;

  wire[1:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_acc_1_nl;
  wire[2:0] nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_acc_1_nl;

  // Interconnect Declarations for Component Instantiations 
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt
      = ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_biwt
      | (ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bcwt!=2'b00);
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt
      = MUX_v_19_3_2((ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg[46:28]),
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_bfwt_46_28,
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_bfwt_1_46_28,
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bcwt);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bcwt
          <= 2'b00;
    end
    else begin
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bcwt
          <= nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bcwt[1:0];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_bfwt_46_28
          <= 19'b0000000000000000000;
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_bfwt_1_46_28
          <= 19'b0000000000000000000;
    end
    else if ( ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_biwt
        ) begin
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_bfwt_46_28
          <= ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg[46:28];
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_bfwt_1_46_28
          <= ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_bfwt_46_28;
    end
  end
  assign nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_acc_1_nl
      = conv_s2s_1_2(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bdwt)
      + conv_u2s_1_2(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_biwt);
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_acc_1_nl
      = nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_acc_1_nl[1:0];
  assign nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bcwt
      = ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_acc_1_nl
      + ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bcwt;

  function automatic [18:0] MUX_v_19_3_2;
    input [18:0] input_0;
    input [18:0] input_1;
    input [18:0] input_2;
    input [1:0] sel;
    reg [18:0] result;
  begin
    case (sel)
      2'b00 : begin
        result = input_0;
      end
      2'b01 : begin
        result = input_1;
      end
      default : begin
        result = input_2;
      end
    endcase
    MUX_v_19_3_2 = result;
  end
  endfunction


  function automatic [1:0] conv_s2s_1_2 ;
    input [0:0]  vector ;
  begin
    conv_s2s_1_2 = {vector[0], vector};
  end
  endfunction


  function automatic [1:0] conv_u2s_1_2 ;
    input [0:0]  vector ;
  begin
    conv_u2s_1_2 =  {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_done_rsci_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_done_rsci_done_wait_dp (
  clk, rst, done_rsci_oswt_unreg, done_rsci_bawt, done_rsci_wen_comp, done_rsci_biwt,
      done_rsci_bdwt, done_rsci_bcwt
);
  input clk;
  input rst;
  input done_rsci_oswt_unreg;
  output done_rsci_bawt;
  output done_rsci_wen_comp;
  input done_rsci_biwt;
  input done_rsci_bdwt;
  output done_rsci_bcwt;
  reg done_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign done_rsci_bawt = done_rsci_biwt | done_rsci_bcwt;
  assign done_rsci_wen_comp = (~ done_rsci_oswt_unreg) | done_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      done_rsci_bcwt <= 1'b0;
    end
    else begin
      done_rsci_bcwt <= ~((~(done_rsci_bcwt | done_rsci_biwt)) | done_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_done_rsci_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_done_rsci_done_wait_ctrl (
  core_wen, done_rsci_oswt_unreg, done_rsci_iswt0, done_rsci_biwt, done_rsci_bdwt,
      done_rsci_bcwt, done_rsci_ivld_core_sct, done_rsci_irdy
);
  input core_wen;
  input done_rsci_oswt_unreg;
  input done_rsci_iswt0;
  output done_rsci_biwt;
  output done_rsci_bdwt;
  input done_rsci_bcwt;
  output done_rsci_ivld_core_sct;
  input done_rsci_irdy;


  // Interconnect Declarations
  wire done_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign done_rsci_bdwt = done_rsci_oswt_unreg & core_wen;
  assign done_rsci_biwt = done_rsci_ogwt & done_rsci_irdy;
  assign done_rsci_ogwt = done_rsci_iswt0 & (~ done_rsci_bcwt);
  assign done_rsci_ivld_core_sct = done_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_plm_out_rsci_plm_out_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_plm_out_rsci_plm_out_wait_dp (
  clk, rst, plm_out_rsci_oswt_unreg, plm_out_rsci_bawt, plm_out_rsci_wen_comp, plm_out_rsci_biwt,
      plm_out_rsci_bdwt, plm_out_rsci_bcwt
);
  input clk;
  input rst;
  input plm_out_rsci_oswt_unreg;
  output plm_out_rsci_bawt;
  output plm_out_rsci_wen_comp;
  input plm_out_rsci_biwt;
  input plm_out_rsci_bdwt;
  output plm_out_rsci_bcwt;
  reg plm_out_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsci_bawt = plm_out_rsci_biwt | plm_out_rsci_bcwt;
  assign plm_out_rsci_wen_comp = (~ plm_out_rsci_oswt_unreg) | plm_out_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_out_rsci_bcwt <= ~((~(plm_out_rsci_bcwt | plm_out_rsci_biwt)) | plm_out_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_plm_out_rsci_plm_out_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_plm_out_rsci_plm_out_wait_ctrl (
  core_wen, plm_out_rsci_oswt_unreg, plm_out_rsci_iswt0, plm_out_rsci_irdy_oreg,
      plm_out_rsci_biwt, plm_out_rsci_bdwt, plm_out_rsci_bcwt, plm_out_rsci_ivld_core_sct
);
  input core_wen;
  input plm_out_rsci_oswt_unreg;
  input plm_out_rsci_iswt0;
  input plm_out_rsci_irdy_oreg;
  output plm_out_rsci_biwt;
  output plm_out_rsci_bdwt;
  input plm_out_rsci_bcwt;
  output plm_out_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire plm_out_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsci_bdwt = plm_out_rsci_oswt_unreg & core_wen;
  assign plm_out_rsci_biwt = plm_out_rsci_ogwt & plm_out_rsci_irdy_oreg;
  assign plm_out_rsci_ogwt = plm_out_rsci_iswt0 & (~ plm_out_rsci_bcwt);
  assign plm_out_rsci_ivld_core_sct = plm_out_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_plm_in_rsci_plm_in_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_plm_in_rsci_plm_in_wait_dp (
  clk, rst, plm_in_rsci_oswt_unreg, plm_in_rsci_bawt, plm_in_rsci_wen_comp, plm_in_rsci_idat_mxwt,
      plm_in_rsci_biwt, plm_in_rsci_bdwt, plm_in_rsci_bcwt, plm_in_rsci_idat
);
  input clk;
  input rst;
  input plm_in_rsci_oswt_unreg;
  output plm_in_rsci_bawt;
  output plm_in_rsci_wen_comp;
  output [511:0] plm_in_rsci_idat_mxwt;
  input plm_in_rsci_biwt;
  input plm_in_rsci_bdwt;
  output plm_in_rsci_bcwt;
  reg plm_in_rsci_bcwt;
  input [511:0] plm_in_rsci_idat;


  // Interconnect Declarations
  reg [511:0] plm_in_rsci_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsci_bawt = plm_in_rsci_biwt | plm_in_rsci_bcwt;
  assign plm_in_rsci_wen_comp = (~ plm_in_rsci_oswt_unreg) | plm_in_rsci_bawt;
  assign plm_in_rsci_idat_mxwt = MUX_v_512_2_2(plm_in_rsci_idat, plm_in_rsci_idat_bfwt,
      plm_in_rsci_bcwt);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_in_rsci_bcwt <= ~((~(plm_in_rsci_bcwt | plm_in_rsci_biwt)) | plm_in_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_idat_bfwt <= 512'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( plm_in_rsci_biwt ) begin
      plm_in_rsci_idat_bfwt <= plm_in_rsci_idat;
    end
  end

  function automatic [511:0] MUX_v_512_2_2;
    input [511:0] input_0;
    input [511:0] input_1;
    input [0:0] sel;
    reg [511:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_512_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_plm_in_rsci_plm_in_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_plm_in_rsci_plm_in_wait_ctrl (
  core_wen, plm_in_rsci_oswt_unreg, plm_in_rsci_iswt0, plm_in_rsci_irdy_core_psct,
      plm_in_rsci_ivld_oreg, plm_in_rsci_biwt, plm_in_rsci_bdwt, plm_in_rsci_bcwt,
      plm_in_rsci_irdy_core_sct
);
  input core_wen;
  input plm_in_rsci_oswt_unreg;
  input plm_in_rsci_iswt0;
  input plm_in_rsci_irdy_core_psct;
  input plm_in_rsci_ivld_oreg;
  output plm_in_rsci_biwt;
  output plm_in_rsci_bdwt;
  input plm_in_rsci_bcwt;
  output plm_in_rsci_irdy_core_sct;


  // Interconnect Declarations
  wire plm_in_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsci_bdwt = plm_in_rsci_oswt_unreg & core_wen;
  assign plm_in_rsci_biwt = plm_in_rsci_ogwt & plm_in_rsci_ivld_oreg;
  assign plm_in_rsci_ogwt = plm_in_rsci_iswt0 & (~ plm_in_rsci_bcwt);
  assign plm_in_rsci_irdy_core_sct = plm_in_rsci_irdy_core_psct & plm_in_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_conf_info_rsci_conf_info_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_conf_info_rsci_conf_info_wait_dp
    (
  clk, rst, conf_info_rsci_oswt_unreg, conf_info_rsci_bawt, conf_info_rsci_wen_comp,
      conf_info_rsci_idat_mxwt, conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt,
      conf_info_rsci_idat
);
  input clk;
  input rst;
  input conf_info_rsci_oswt_unreg;
  output conf_info_rsci_bawt;
  output conf_info_rsci_wen_comp;
  output [31:0] conf_info_rsci_idat_mxwt;
  input conf_info_rsci_biwt;
  input conf_info_rsci_bdwt;
  output conf_info_rsci_bcwt;
  reg conf_info_rsci_bcwt;
  input [31:0] conf_info_rsci_idat;


  // Interconnect Declarations
  reg [31:0] conf_info_rsci_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_bawt = conf_info_rsci_biwt | conf_info_rsci_bcwt;
  assign conf_info_rsci_wen_comp = (~ conf_info_rsci_oswt_unreg) | conf_info_rsci_bawt;
  assign conf_info_rsci_idat_mxwt = MUX_v_32_2_2(conf_info_rsci_idat, conf_info_rsci_idat_bfwt,
      conf_info_rsci_bcwt);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_bcwt <= 1'b0;
    end
    else begin
      conf_info_rsci_bcwt <= ~((~(conf_info_rsci_bcwt | conf_info_rsci_biwt)) | conf_info_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_idat_bfwt <= 32'b00000000000000000000000000000000;
    end
    else if ( conf_info_rsci_biwt ) begin
      conf_info_rsci_idat_bfwt <= conf_info_rsci_idat;
    end
  end

  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [0:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_conf_info_rsci_conf_info_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_conf_info_rsci_conf_info_wait_ctrl
    (
  core_wen, conf_info_rsci_oswt_unreg, conf_info_rsci_iswt0, conf_info_rsci_irdy_core_psct,
      conf_info_rsci_ivld_oreg, conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt,
      conf_info_rsci_irdy_core_sct
);
  input core_wen;
  input conf_info_rsci_oswt_unreg;
  input conf_info_rsci_iswt0;
  input conf_info_rsci_irdy_core_psct;
  input conf_info_rsci_ivld_oreg;
  output conf_info_rsci_biwt;
  output conf_info_rsci_bdwt;
  input conf_info_rsci_bcwt;
  output conf_info_rsci_irdy_core_sct;


  // Interconnect Declarations
  wire conf_info_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_bdwt = conf_info_rsci_oswt_unreg & core_wen;
  assign conf_info_rsci_biwt = conf_info_rsci_ogwt & conf_info_rsci_ivld_oreg;
  assign conf_info_rsci_ogwt = conf_info_rsci_iswt0 & (~ conf_info_rsci_bcwt);
  assign conf_info_rsci_irdy_core_sct = conf_info_rsci_irdy_core_psct & conf_info_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_wait_dp (
  clk, rst, conf_info_rsci_ivld, conf_info_rsci_ivld_oreg, plm_in_rsci_ivld, plm_in_rsci_ivld_oreg,
      plm_out_rsci_irdy, plm_out_rsci_irdy_oreg, ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z,
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg
);
  input clk;
  input rst;
  input conf_info_rsci_ivld;
  output conf_info_rsci_ivld_oreg;
  input plm_in_rsci_ivld;
  output plm_in_rsci_ivld_oreg;
  input plm_out_rsci_irdy;
  output plm_out_rsci_irdy_oreg;
  input [46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z;
  output [46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg;
  reg [46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg;


  // Interconnect Declarations
  reg conf_info_rsci_ivld_oreg_rneg;
  reg plm_in_rsci_ivld_oreg_rneg;
  reg plm_out_rsci_irdy_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_ivld_oreg = ~ conf_info_rsci_ivld_oreg_rneg;
  assign plm_in_rsci_ivld_oreg = ~ plm_in_rsci_ivld_oreg_rneg;
  assign plm_out_rsci_irdy_oreg = ~ plm_out_rsci_irdy_oreg_rneg;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_ivld_oreg_rneg <= 1'b0;
      plm_in_rsci_ivld_oreg_rneg <= 1'b0;
      plm_out_rsci_irdy_oreg_rneg <= 1'b0;
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg
          <= 47'b00000000000000000000000000000000000000000000000;
    end
    else begin
      conf_info_rsci_ivld_oreg_rneg <= ~ conf_info_rsci_ivld;
      plm_in_rsci_ivld_oreg_rneg <= ~ plm_in_rsci_ivld;
      plm_out_rsci_irdy_oreg_rneg <= ~ plm_out_rsci_irdy;
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg
          <= ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_core_fsm (
  clk, rst, core_wen, fsm_output
);
  input clk;
  input rst;
  input core_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;


  // FSM State Type Declaration for esp_acc_softmax_cxx_catapult_store_core_core_fsm_1
  parameter
    core_rlp_C_0 = 1'd0,
    main_C_0 = 1'd1;

  reg [0:0] state_var;
  reg [0:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_catapult_store_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 2'b01;
        state_var_NS = main_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( ~ rst ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_staller
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_staller (
  clk, rst, core_wen, core_wten, conf_info_rsci_wen_comp, plm_out_rsci_wen_comp,
      dma_write_chnl_rsci_wen_comp, done_rsci_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  reg core_wten;
  input conf_info_rsci_wen_comp;
  input plm_out_rsci_wen_comp;
  input dma_write_chnl_rsci_wen_comp;
  input done_rsci_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign core_wen = conf_info_rsci_wen_comp & plm_out_rsci_wen_comp & dma_write_chnl_rsci_wen_comp
      & done_rsci_wen_comp;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      core_wten <= 1'b0;
    end
    else begin
      core_wten <= ~ core_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_done_rsci_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_done_rsci_done_wait_dp (
  clk, rst, done_rsci_oswt_unreg, done_rsci_bawt, done_rsci_wen_comp, done_rsci_biwt,
      done_rsci_bdwt, done_rsci_bcwt
);
  input clk;
  input rst;
  input done_rsci_oswt_unreg;
  output done_rsci_bawt;
  output done_rsci_wen_comp;
  input done_rsci_biwt;
  input done_rsci_bdwt;
  output done_rsci_bcwt;
  reg done_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign done_rsci_bawt = done_rsci_biwt | done_rsci_bcwt;
  assign done_rsci_wen_comp = (~ done_rsci_oswt_unreg) | done_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      done_rsci_bcwt <= 1'b0;
    end
    else begin
      done_rsci_bcwt <= ~((~(done_rsci_bcwt | done_rsci_biwt)) | done_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_done_rsci_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_done_rsci_done_wait_ctrl (
  core_wen, done_rsci_oswt_unreg, done_rsci_iswt0, done_rsci_biwt, done_rsci_bdwt,
      done_rsci_bcwt, done_rsci_ivld_core_sct, done_rsci_irdy
);
  input core_wen;
  input done_rsci_oswt_unreg;
  input done_rsci_iswt0;
  output done_rsci_biwt;
  output done_rsci_bdwt;
  input done_rsci_bcwt;
  output done_rsci_ivld_core_sct;
  input done_rsci_irdy;


  // Interconnect Declarations
  wire done_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign done_rsci_bdwt = done_rsci_oswt_unreg & core_wen;
  assign done_rsci_biwt = done_rsci_ogwt & done_rsci_irdy;
  assign done_rsci_ogwt = done_rsci_iswt0 & (~ done_rsci_bcwt);
  assign done_rsci_ivld_core_sct = done_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_dma_write_chnl_rsci_dma_write_chnl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_dma_write_chnl_rsci_dma_write_chnl_wait_dp
    (
  clk, rst, dma_write_chnl_rsci_oswt_unreg, dma_write_chnl_rsci_bawt, dma_write_chnl_rsci_wen_comp,
      dma_write_chnl_rsci_biwt, dma_write_chnl_rsci_bdwt, dma_write_chnl_rsci_bcwt
);
  input clk;
  input rst;
  input dma_write_chnl_rsci_oswt_unreg;
  output dma_write_chnl_rsci_bawt;
  output dma_write_chnl_rsci_wen_comp;
  input dma_write_chnl_rsci_biwt;
  input dma_write_chnl_rsci_bdwt;
  output dma_write_chnl_rsci_bcwt;
  reg dma_write_chnl_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign dma_write_chnl_rsci_bawt = dma_write_chnl_rsci_biwt | dma_write_chnl_rsci_bcwt;
  assign dma_write_chnl_rsci_wen_comp = (~ dma_write_chnl_rsci_oswt_unreg) | dma_write_chnl_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_chnl_rsci_bcwt <= 1'b0;
    end
    else begin
      dma_write_chnl_rsci_bcwt <= ~((~(dma_write_chnl_rsci_bcwt | dma_write_chnl_rsci_biwt))
          | dma_write_chnl_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl
    (
  core_wen, dma_write_chnl_rsci_oswt_unreg, dma_write_chnl_rsci_iswt0, dma_write_chnl_rsci_irdy,
      dma_write_chnl_rsci_biwt, dma_write_chnl_rsci_bdwt, dma_write_chnl_rsci_bcwt,
      dma_write_chnl_rsci_ivld_core_sct
);
  input core_wen;
  input dma_write_chnl_rsci_oswt_unreg;
  input dma_write_chnl_rsci_iswt0;
  input dma_write_chnl_rsci_irdy;
  output dma_write_chnl_rsci_biwt;
  output dma_write_chnl_rsci_bdwt;
  input dma_write_chnl_rsci_bcwt;
  output dma_write_chnl_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire dma_write_chnl_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign dma_write_chnl_rsci_bdwt = dma_write_chnl_rsci_oswt_unreg & core_wen;
  assign dma_write_chnl_rsci_biwt = dma_write_chnl_rsci_ogwt & dma_write_chnl_rsci_irdy;
  assign dma_write_chnl_rsci_ogwt = dma_write_chnl_rsci_iswt0 & (~ dma_write_chnl_rsci_bcwt);
  assign dma_write_chnl_rsci_ivld_core_sct = dma_write_chnl_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp
    (
  clk, rst, dma_write_ctrl_rsci_bawt, dma_write_ctrl_rsci_irdy_mxwt, dma_write_ctrl_rsci_irdy,
      dma_write_ctrl_rsci_biwt, dma_write_ctrl_rsci_bdwt
);
  input clk;
  input rst;
  output dma_write_ctrl_rsci_bawt;
  output dma_write_ctrl_rsci_irdy_mxwt;
  input dma_write_ctrl_rsci_irdy;
  input dma_write_ctrl_rsci_biwt;
  input dma_write_ctrl_rsci_bdwt;


  // Interconnect Declarations
  reg dma_write_ctrl_rsci_bcwt;
  reg dma_write_ctrl_rsci_irdy_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign dma_write_ctrl_rsci_bawt = dma_write_ctrl_rsci_biwt | dma_write_ctrl_rsci_bcwt;
  assign dma_write_ctrl_rsci_irdy_mxwt = MUX_s_1_2_2(dma_write_ctrl_rsci_irdy, dma_write_ctrl_rsci_irdy_bfwt,
      dma_write_ctrl_rsci_bcwt);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_ctrl_rsci_bcwt <= 1'b0;
    end
    else begin
      dma_write_ctrl_rsci_bcwt <= ~((~(dma_write_ctrl_rsci_bcwt | dma_write_ctrl_rsci_biwt))
          | dma_write_ctrl_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_ctrl_rsci_irdy_bfwt <= 1'b0;
    end
    else if ( dma_write_ctrl_rsci_biwt ) begin
      dma_write_ctrl_rsci_irdy_bfwt <= dma_write_ctrl_rsci_irdy;
    end
  end

  function automatic [0:0] MUX_s_1_2_2;
    input [0:0] input_0;
    input [0:0] input_1;
    input [0:0] sel;
    reg [0:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl
    (
  core_wen, core_wten, dma_write_ctrl_rsci_oswt_unreg, dma_write_ctrl_rsci_iswt0,
      dma_write_ctrl_rsci_biwt, dma_write_ctrl_rsci_bdwt
);
  input core_wen;
  input core_wten;
  input dma_write_ctrl_rsci_oswt_unreg;
  input dma_write_ctrl_rsci_iswt0;
  output dma_write_ctrl_rsci_biwt;
  output dma_write_ctrl_rsci_bdwt;



  // Interconnect Declarations for Component Instantiations 
  assign dma_write_ctrl_rsci_bdwt = dma_write_ctrl_rsci_oswt_unreg & core_wen;
  assign dma_write_ctrl_rsci_biwt = (~ core_wten) & dma_write_ctrl_rsci_iswt0;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_plm_out_rsci_plm_out_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_plm_out_rsci_plm_out_wait_dp (
  clk, rst, plm_out_rsci_oswt_unreg, plm_out_rsci_bawt, plm_out_rsci_wen_comp, plm_out_rsci_idat_mxwt,
      plm_out_rsci_biwt, plm_out_rsci_bdwt, plm_out_rsci_bcwt, plm_out_rsci_idat
);
  input clk;
  input rst;
  input plm_out_rsci_oswt_unreg;
  output plm_out_rsci_bawt;
  output plm_out_rsci_wen_comp;
  output [511:0] plm_out_rsci_idat_mxwt;
  input plm_out_rsci_biwt;
  input plm_out_rsci_bdwt;
  output plm_out_rsci_bcwt;
  reg plm_out_rsci_bcwt;
  input [511:0] plm_out_rsci_idat;


  // Interconnect Declarations
  reg [511:0] plm_out_rsci_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsci_bawt = plm_out_rsci_biwt | plm_out_rsci_bcwt;
  assign plm_out_rsci_wen_comp = (~ plm_out_rsci_oswt_unreg) | plm_out_rsci_bawt;
  assign plm_out_rsci_idat_mxwt = MUX_v_512_2_2(plm_out_rsci_idat, plm_out_rsci_idat_bfwt,
      plm_out_rsci_bcwt);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_out_rsci_bcwt <= ~((~(plm_out_rsci_bcwt | plm_out_rsci_biwt)) | plm_out_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_idat_bfwt <= 512'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( plm_out_rsci_biwt ) begin
      plm_out_rsci_idat_bfwt <= plm_out_rsci_idat;
    end
  end

  function automatic [511:0] MUX_v_512_2_2;
    input [511:0] input_0;
    input [511:0] input_1;
    input [0:0] sel;
    reg [511:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_512_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_plm_out_rsci_plm_out_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_plm_out_rsci_plm_out_wait_ctrl (
  core_wen, plm_out_rsci_oswt_unreg, plm_out_rsci_iswt0, plm_out_rsci_ivld_oreg,
      plm_out_rsci_biwt, plm_out_rsci_bdwt, plm_out_rsci_bcwt, plm_out_rsci_irdy_core_sct
);
  input core_wen;
  input plm_out_rsci_oswt_unreg;
  input plm_out_rsci_iswt0;
  input plm_out_rsci_ivld_oreg;
  output plm_out_rsci_biwt;
  output plm_out_rsci_bdwt;
  input plm_out_rsci_bcwt;
  output plm_out_rsci_irdy_core_sct;


  // Interconnect Declarations
  wire plm_out_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsci_bdwt = plm_out_rsci_oswt_unreg & core_wen;
  assign plm_out_rsci_biwt = plm_out_rsci_ogwt & plm_out_rsci_ivld_oreg;
  assign plm_out_rsci_ogwt = plm_out_rsci_iswt0 & (~ plm_out_rsci_bcwt);
  assign plm_out_rsci_irdy_core_sct = plm_out_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_conf_info_rsci_conf_info_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_conf_info_rsci_conf_info_wait_dp (
  clk, rst, conf_info_rsci_oswt_unreg, conf_info_rsci_bawt, conf_info_rsci_wen_comp,
      conf_info_rsci_idat_mxwt, conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt,
      conf_info_rsci_idat
);
  input clk;
  input rst;
  input conf_info_rsci_oswt_unreg;
  output conf_info_rsci_bawt;
  output conf_info_rsci_wen_comp;
  output [31:0] conf_info_rsci_idat_mxwt;
  input conf_info_rsci_biwt;
  input conf_info_rsci_bdwt;
  output conf_info_rsci_bcwt;
  reg conf_info_rsci_bcwt;
  input [31:0] conf_info_rsci_idat;


  // Interconnect Declarations
  reg [31:0] conf_info_rsci_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_bawt = conf_info_rsci_biwt | conf_info_rsci_bcwt;
  assign conf_info_rsci_wen_comp = (~ conf_info_rsci_oswt_unreg) | conf_info_rsci_bawt;
  assign conf_info_rsci_idat_mxwt = MUX_v_32_2_2(conf_info_rsci_idat, conf_info_rsci_idat_bfwt,
      conf_info_rsci_bcwt);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_bcwt <= 1'b0;
    end
    else begin
      conf_info_rsci_bcwt <= ~((~(conf_info_rsci_bcwt | conf_info_rsci_biwt)) | conf_info_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_idat_bfwt <= 32'b00000000000000000000000000000000;
    end
    else if ( conf_info_rsci_biwt ) begin
      conf_info_rsci_idat_bfwt <= conf_info_rsci_idat;
    end
  end

  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [0:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_conf_info_rsci_conf_info_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_conf_info_rsci_conf_info_wait_ctrl
    (
  core_wen, conf_info_rsci_oswt_unreg, conf_info_rsci_iswt0, conf_info_rsci_irdy_core_psct,
      conf_info_rsci_ivld_oreg, conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt,
      conf_info_rsci_irdy_core_sct
);
  input core_wen;
  input conf_info_rsci_oswt_unreg;
  input conf_info_rsci_iswt0;
  input conf_info_rsci_irdy_core_psct;
  input conf_info_rsci_ivld_oreg;
  output conf_info_rsci_biwt;
  output conf_info_rsci_bdwt;
  input conf_info_rsci_bcwt;
  output conf_info_rsci_irdy_core_sct;


  // Interconnect Declarations
  wire conf_info_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_bdwt = conf_info_rsci_oswt_unreg & core_wen;
  assign conf_info_rsci_biwt = conf_info_rsci_ogwt & conf_info_rsci_ivld_oreg;
  assign conf_info_rsci_ogwt = conf_info_rsci_iswt0 & (~ conf_info_rsci_bcwt);
  assign conf_info_rsci_irdy_core_sct = conf_info_rsci_irdy_core_psct & conf_info_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_wait_dp (
  clk, rst, conf_info_rsci_ivld, conf_info_rsci_ivld_oreg, plm_out_rsci_ivld, plm_out_rsci_ivld_oreg
);
  input clk;
  input rst;
  input conf_info_rsci_ivld;
  output conf_info_rsci_ivld_oreg;
  input plm_out_rsci_ivld;
  output plm_out_rsci_ivld_oreg;


  // Interconnect Declarations
  reg conf_info_rsci_ivld_oreg_rneg;
  reg plm_out_rsci_ivld_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_ivld_oreg = ~ conf_info_rsci_ivld_oreg_rneg;
  assign plm_out_rsci_ivld_oreg = ~ plm_out_rsci_ivld_oreg_rneg;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_ivld_oreg_rneg <= 1'b0;
      plm_out_rsci_ivld_oreg_rneg <= 1'b0;
    end
    else begin
      conf_info_rsci_ivld_oreg_rneg <= ~ conf_info_rsci_ivld;
      plm_out_rsci_ivld_oreg_rneg <= ~ plm_out_rsci_ivld;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_store_done_cnsi
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_store_done_cnsi
    (
  clk, rst, store_done_cns_rdy, store_done_cns_vld, core_wen, store_done_cnsi_oswt_unreg,
      store_done_cnsi_bawt, store_done_cnsi_iswt0, store_done_cnsi_wen_comp
);
  input clk;
  input rst;
  output store_done_cns_rdy;
  input store_done_cns_vld;
  input core_wen;
  input store_done_cnsi_oswt_unreg;
  output store_done_cnsi_bawt;
  input store_done_cnsi_iswt0;
  output store_done_cnsi_wen_comp;


  // Interconnect Declarations
  wire store_done_cnsi_ivld;
  wire store_done_cnsi_biwt;
  wire store_done_cnsi_bdwt;
  wire store_done_cnsi_bcwt;
  wire store_done_cnsi_irdy_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_sync_in_wait_v1 #(.rscid(32'sd48)) store_done_cnsi
      (
      .vld(store_done_cns_vld),
      .rdy(store_done_cns_rdy),
      .ivld(store_done_cnsi_ivld),
      .irdy(store_done_cnsi_irdy_core_sct)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_store_done_cnsi_store_done_wait_ctrl
      softmax_cxx_catapult_core_core_store_done_cnsi_store_done_wait_ctrl_inst (
      .core_wen(core_wen),
      .store_done_cnsi_oswt_unreg(store_done_cnsi_oswt_unreg),
      .store_done_cnsi_iswt0(store_done_cnsi_iswt0),
      .store_done_cnsi_ivld(store_done_cnsi_ivld),
      .store_done_cnsi_biwt(store_done_cnsi_biwt),
      .store_done_cnsi_bdwt(store_done_cnsi_bdwt),
      .store_done_cnsi_bcwt(store_done_cnsi_bcwt),
      .store_done_cnsi_irdy_core_sct(store_done_cnsi_irdy_core_sct)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_store_done_cnsi_store_done_wait_dp
      softmax_cxx_catapult_core_core_store_done_cnsi_store_done_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .store_done_cnsi_oswt_unreg(store_done_cnsi_oswt_unreg),
      .store_done_cnsi_bawt(store_done_cnsi_bawt),
      .store_done_cnsi_wen_comp(store_done_cnsi_wen_comp),
      .store_done_cnsi_biwt(store_done_cnsi_biwt),
      .store_done_cnsi_bdwt(store_done_cnsi_bdwt),
      .store_done_cnsi_bcwt(store_done_cnsi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_compute_done_cnsi
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_compute_done_cnsi
    (
  clk, rst, compute_done_cns_rdy, compute_done_cns_vld, core_wen, compute_done_cnsi_oswt_unreg,
      compute_done_cnsi_bawt, compute_done_cnsi_iswt0, compute_done_cnsi_wen_comp
);
  input clk;
  input rst;
  output compute_done_cns_rdy;
  input compute_done_cns_vld;
  input core_wen;
  input compute_done_cnsi_oswt_unreg;
  output compute_done_cnsi_bawt;
  input compute_done_cnsi_iswt0;
  output compute_done_cnsi_wen_comp;


  // Interconnect Declarations
  wire compute_done_cnsi_ivld;
  wire compute_done_cnsi_biwt;
  wire compute_done_cnsi_bdwt;
  wire compute_done_cnsi_bcwt;
  wire compute_done_cnsi_irdy_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_sync_in_wait_v1 #(.rscid(32'sd47)) compute_done_cnsi
      (
      .vld(compute_done_cns_vld),
      .rdy(compute_done_cns_rdy),
      .ivld(compute_done_cnsi_ivld),
      .irdy(compute_done_cnsi_irdy_core_sct)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_compute_done_cnsi_compute_done_wait_ctrl
      softmax_cxx_catapult_core_core_compute_done_cnsi_compute_done_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .compute_done_cnsi_oswt_unreg(compute_done_cnsi_oswt_unreg),
      .compute_done_cnsi_iswt0(compute_done_cnsi_iswt0),
      .compute_done_cnsi_ivld(compute_done_cnsi_ivld),
      .compute_done_cnsi_biwt(compute_done_cnsi_biwt),
      .compute_done_cnsi_bdwt(compute_done_cnsi_bdwt),
      .compute_done_cnsi_bcwt(compute_done_cnsi_bcwt),
      .compute_done_cnsi_irdy_core_sct(compute_done_cnsi_irdy_core_sct)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_compute_done_cnsi_compute_done_wait_dp
      softmax_cxx_catapult_core_core_compute_done_cnsi_compute_done_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .compute_done_cnsi_oswt_unreg(compute_done_cnsi_oswt_unreg),
      .compute_done_cnsi_bawt(compute_done_cnsi_bawt),
      .compute_done_cnsi_wen_comp(compute_done_cnsi_wen_comp),
      .compute_done_cnsi_biwt(compute_done_cnsi_biwt),
      .compute_done_cnsi_bdwt(compute_done_cnsi_bdwt),
      .compute_done_cnsi_bcwt(compute_done_cnsi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_load_done_cnsi
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_load_done_cnsi
    (
  clk, rst, load_done_cns_rdy, load_done_cns_vld, core_wen, load_done_cnsi_oswt_unreg,
      load_done_cnsi_bawt, load_done_cnsi_iswt0, load_done_cnsi_wen_comp, load_done_cnsi_irdy_core_psct
);
  input clk;
  input rst;
  output load_done_cns_rdy;
  input load_done_cns_vld;
  input core_wen;
  input load_done_cnsi_oswt_unreg;
  output load_done_cnsi_bawt;
  input load_done_cnsi_iswt0;
  output load_done_cnsi_wen_comp;
  input load_done_cnsi_irdy_core_psct;


  // Interconnect Declarations
  wire load_done_cnsi_ivld;
  wire load_done_cnsi_biwt;
  wire load_done_cnsi_bdwt;
  wire load_done_cnsi_bcwt;
  wire load_done_cnsi_irdy_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_sync_in_wait_v1 #(.rscid(32'sd46)) load_done_cnsi
      (
      .vld(load_done_cns_vld),
      .rdy(load_done_cns_rdy),
      .ivld(load_done_cnsi_ivld),
      .irdy(load_done_cnsi_irdy_core_sct)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_load_done_cnsi_load_done_wait_ctrl
      softmax_cxx_catapult_core_core_load_done_cnsi_load_done_wait_ctrl_inst (
      .core_wen(core_wen),
      .load_done_cnsi_oswt_unreg(load_done_cnsi_oswt_unreg),
      .load_done_cnsi_iswt0(load_done_cnsi_iswt0),
      .load_done_cnsi_irdy_core_psct(load_done_cnsi_irdy_core_psct),
      .load_done_cnsi_ivld(load_done_cnsi_ivld),
      .load_done_cnsi_biwt(load_done_cnsi_biwt),
      .load_done_cnsi_bdwt(load_done_cnsi_bdwt),
      .load_done_cnsi_bcwt(load_done_cnsi_bcwt),
      .load_done_cnsi_irdy_core_sct(load_done_cnsi_irdy_core_sct)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_load_done_cnsi_load_done_wait_dp
      softmax_cxx_catapult_core_core_load_done_cnsi_load_done_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .load_done_cnsi_oswt_unreg(load_done_cnsi_oswt_unreg),
      .load_done_cnsi_bawt(load_done_cnsi_bawt),
      .load_done_cnsi_wen_comp(load_done_cnsi_wen_comp),
      .load_done_cnsi_biwt(load_done_cnsi_biwt),
      .load_done_cnsi_bdwt(load_done_cnsi_bdwt),
      .load_done_cnsi_bcwt(load_done_cnsi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_config_done_cnsi
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_config_done_cnsi
    (
  clk, rst, config_done_cns_rdy, config_done_cns_vld, core_wen, config_done_cnsi_oswt_unreg,
      config_done_cnsi_bawt, config_done_cnsi_iswt0, config_done_cnsi_wen_comp
);
  input clk;
  input rst;
  output config_done_cns_rdy;
  input config_done_cns_vld;
  input core_wen;
  input config_done_cnsi_oswt_unreg;
  output config_done_cnsi_bawt;
  input config_done_cnsi_iswt0;
  output config_done_cnsi_wen_comp;


  // Interconnect Declarations
  wire config_done_cnsi_ivld;
  wire config_done_cnsi_biwt;
  wire config_done_cnsi_bdwt;
  wire config_done_cnsi_bcwt;
  wire config_done_cnsi_irdy_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_sync_in_wait_v1 #(.rscid(32'sd45)) config_done_cnsi
      (
      .vld(config_done_cns_vld),
      .rdy(config_done_cns_rdy),
      .ivld(config_done_cnsi_ivld),
      .irdy(config_done_cnsi_irdy_core_sct)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_config_done_cnsi_config_done_wait_ctrl
      softmax_cxx_catapult_core_core_config_done_cnsi_config_done_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .config_done_cnsi_oswt_unreg(config_done_cnsi_oswt_unreg),
      .config_done_cnsi_iswt0(config_done_cnsi_iswt0),
      .config_done_cnsi_ivld(config_done_cnsi_ivld),
      .config_done_cnsi_biwt(config_done_cnsi_biwt),
      .config_done_cnsi_bdwt(config_done_cnsi_bdwt),
      .config_done_cnsi_bcwt(config_done_cnsi_bcwt),
      .config_done_cnsi_irdy_core_sct(config_done_cnsi_irdy_core_sct)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_config_done_cnsi_config_done_wait_dp
      softmax_cxx_catapult_core_core_config_done_cnsi_config_done_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .config_done_cnsi_oswt_unreg(config_done_cnsi_oswt_unreg),
      .config_done_cnsi_bawt(config_done_cnsi_bawt),
      .config_done_cnsi_wen_comp(config_done_cnsi_wen_comp),
      .config_done_cnsi_biwt(config_done_cnsi_biwt),
      .config_done_cnsi_bdwt(config_done_cnsi_bdwt),
      .config_done_cnsi_bcwt(config_done_cnsi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_acc_done_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_acc_done_rsci
    (
  clk, rst, acc_done_rsc_vld, core_wen, acc_done_rsci_oswt_unreg, acc_done_rsci_bawt,
      acc_done_rsci_iswt0, core_wten
);
  input clk;
  input rst;
  output acc_done_rsc_vld;
  input core_wen;
  input acc_done_rsci_oswt_unreg;
  output acc_done_rsci_bawt;
  input acc_done_rsci_iswt0;
  input core_wten;


  // Interconnect Declarations
  wire acc_done_rsci_biwt;
  wire acc_done_rsci_bdwt;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_sync_out_vld_v1 #(.rscid(32'sd44)) acc_done_rsci
      (
      .vld(acc_done_rsc_vld),
      .ivld(acc_done_rsci_biwt)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_acc_done_rsci_acc_done_wait_ctrl
      softmax_cxx_catapult_core_core_acc_done_rsci_acc_done_wait_ctrl_inst (
      .core_wen(core_wen),
      .acc_done_rsci_oswt_unreg(acc_done_rsci_oswt_unreg),
      .acc_done_rsci_iswt0(acc_done_rsci_iswt0),
      .core_wten(core_wten),
      .acc_done_rsci_biwt(acc_done_rsci_biwt),
      .acc_done_rsci_bdwt(acc_done_rsci_bdwt)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_acc_done_rsci_acc_done_wait_dp
      softmax_cxx_catapult_core_core_acc_done_rsci_acc_done_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .acc_done_rsci_bawt(acc_done_rsci_bawt),
      .acc_done_rsci_biwt(acc_done_rsci_biwt),
      .acc_done_rsci_bdwt(acc_done_rsci_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_done_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_done_rsci (
  clk, rst, done_rsc_rdy, done_rsc_vld, core_wen, done_rsci_oswt_unreg, done_rsci_bawt,
      done_rsci_iswt0, done_rsci_wen_comp
);
  input clk;
  input rst;
  input done_rsc_rdy;
  output done_rsc_vld;
  input core_wen;
  input done_rsci_oswt_unreg;
  output done_rsci_bawt;
  input done_rsci_iswt0;
  output done_rsci_wen_comp;


  // Interconnect Declarations
  wire done_rsci_biwt;
  wire done_rsci_bdwt;
  wire done_rsci_bcwt;
  wire done_rsci_ivld_core_sct;
  wire done_rsci_irdy;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_sync_out_wait_v1 #(.rscid(32'sd5)) done_rsci (
      .vld(done_rsc_vld),
      .rdy(done_rsc_rdy),
      .ivld(done_rsci_ivld_core_sct),
      .irdy(done_rsci_irdy)
    );
  esp_acc_softmax_cxx_catapult_config_core_done_rsci_done_wait_ctrl config_core_done_rsci_done_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .done_rsci_oswt_unreg(done_rsci_oswt_unreg),
      .done_rsci_iswt0(done_rsci_iswt0),
      .done_rsci_biwt(done_rsci_biwt),
      .done_rsci_bdwt(done_rsci_bdwt),
      .done_rsci_bcwt(done_rsci_bcwt),
      .done_rsci_ivld_core_sct(done_rsci_ivld_core_sct),
      .done_rsci_irdy(done_rsci_irdy)
    );
  esp_acc_softmax_cxx_catapult_config_core_done_rsci_done_wait_dp config_core_done_rsci_done_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .done_rsci_oswt_unreg(done_rsci_oswt_unreg),
      .done_rsci_bawt(done_rsci_bawt),
      .done_rsci_wen_comp(done_rsci_wen_comp),
      .done_rsci_biwt(done_rsci_biwt),
      .done_rsci_bdwt(done_rsci_bdwt),
      .done_rsci_bcwt(done_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_plm_conf_store_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_plm_conf_store_rsci (
  clk, rst, plm_conf_store_rsc_dat, plm_conf_store_rsc_vld, plm_conf_store_rsc_rdy,
      core_wen, plm_conf_store_rsci_irdy, plm_conf_store_rsci_oswt_unreg, plm_conf_store_rsci_bawt,
      plm_conf_store_rsci_iswt0, plm_conf_store_rsci_wen_comp, plm_conf_store_rsci_irdy_oreg,
      plm_conf_store_rsci_idat
);
  input clk;
  input rst;
  output [31:0] plm_conf_store_rsc_dat;
  output plm_conf_store_rsc_vld;
  input plm_conf_store_rsc_rdy;
  input core_wen;
  output plm_conf_store_rsci_irdy;
  input plm_conf_store_rsci_oswt_unreg;
  output plm_conf_store_rsci_bawt;
  input plm_conf_store_rsci_iswt0;
  output plm_conf_store_rsci_wen_comp;
  input plm_conf_store_rsci_irdy_oreg;
  input [31:0] plm_conf_store_rsci_idat;


  // Interconnect Declarations
  wire plm_conf_store_rsci_biwt;
  wire plm_conf_store_rsci_bdwt;
  wire plm_conf_store_rsci_bcwt;
  wire plm_conf_store_rsci_ivld_core_sct;
  wire plm_conf_store_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_out_buf_wait_v4 #(.rscid(32'sd4),
  .width(32'sd32),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_conf_store_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .irdy(plm_conf_store_rsci_irdy),
      .ivld(plm_conf_store_rsci_ivld_core_sct),
      .idat(plm_conf_store_rsci_idat),
      .rdy(plm_conf_store_rsc_rdy),
      .vld(plm_conf_store_rsc_vld),
      .dat(plm_conf_store_rsc_dat),
      .is_idle(plm_conf_store_rsc_is_idle)
    );
  esp_acc_softmax_cxx_catapult_config_core_plm_conf_store_rsci_plm_conf_store_wait_ctrl
      config_core_plm_conf_store_rsci_plm_conf_store_wait_ctrl_inst (
      .core_wen(core_wen),
      .plm_conf_store_rsci_oswt_unreg(plm_conf_store_rsci_oswt_unreg),
      .plm_conf_store_rsci_iswt0(plm_conf_store_rsci_iswt0),
      .plm_conf_store_rsci_irdy_oreg(plm_conf_store_rsci_irdy_oreg),
      .plm_conf_store_rsci_biwt(plm_conf_store_rsci_biwt),
      .plm_conf_store_rsci_bdwt(plm_conf_store_rsci_bdwt),
      .plm_conf_store_rsci_bcwt(plm_conf_store_rsci_bcwt),
      .plm_conf_store_rsci_ivld_core_sct(plm_conf_store_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_catapult_config_core_plm_conf_store_rsci_plm_conf_store_wait_dp
      config_core_plm_conf_store_rsci_plm_conf_store_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .plm_conf_store_rsci_oswt_unreg(plm_conf_store_rsci_oswt_unreg),
      .plm_conf_store_rsci_bawt(plm_conf_store_rsci_bawt),
      .plm_conf_store_rsci_wen_comp(plm_conf_store_rsci_wen_comp),
      .plm_conf_store_rsci_biwt(plm_conf_store_rsci_biwt),
      .plm_conf_store_rsci_bdwt(plm_conf_store_rsci_bdwt),
      .plm_conf_store_rsci_bcwt(plm_conf_store_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_plm_conf_compute_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_plm_conf_compute_rsci (
  clk, rst, plm_conf_compute_rsc_dat, plm_conf_compute_rsc_vld, plm_conf_compute_rsc_rdy,
      core_wen, plm_conf_compute_rsci_irdy, plm_conf_compute_rsci_oswt_unreg, plm_conf_compute_rsci_bawt,
      plm_conf_compute_rsci_iswt0, plm_conf_compute_rsci_wen_comp, plm_conf_compute_rsci_irdy_oreg,
      plm_conf_compute_rsci_idat
);
  input clk;
  input rst;
  output [31:0] plm_conf_compute_rsc_dat;
  output plm_conf_compute_rsc_vld;
  input plm_conf_compute_rsc_rdy;
  input core_wen;
  output plm_conf_compute_rsci_irdy;
  input plm_conf_compute_rsci_oswt_unreg;
  output plm_conf_compute_rsci_bawt;
  input plm_conf_compute_rsci_iswt0;
  output plm_conf_compute_rsci_wen_comp;
  input plm_conf_compute_rsci_irdy_oreg;
  input [31:0] plm_conf_compute_rsci_idat;


  // Interconnect Declarations
  wire plm_conf_compute_rsci_biwt;
  wire plm_conf_compute_rsci_bdwt;
  wire plm_conf_compute_rsci_bcwt;
  wire plm_conf_compute_rsci_ivld_core_sct;
  wire plm_conf_compute_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_out_buf_wait_v4 #(.rscid(32'sd3),
  .width(32'sd32),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_conf_compute_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .irdy(plm_conf_compute_rsci_irdy),
      .ivld(plm_conf_compute_rsci_ivld_core_sct),
      .idat(plm_conf_compute_rsci_idat),
      .rdy(plm_conf_compute_rsc_rdy),
      .vld(plm_conf_compute_rsc_vld),
      .dat(plm_conf_compute_rsc_dat),
      .is_idle(plm_conf_compute_rsc_is_idle)
    );
  esp_acc_softmax_cxx_catapult_config_core_plm_conf_compute_rsci_plm_conf_compute_wait_ctrl
      config_core_plm_conf_compute_rsci_plm_conf_compute_wait_ctrl_inst (
      .core_wen(core_wen),
      .plm_conf_compute_rsci_oswt_unreg(plm_conf_compute_rsci_oswt_unreg),
      .plm_conf_compute_rsci_iswt0(plm_conf_compute_rsci_iswt0),
      .plm_conf_compute_rsci_irdy_oreg(plm_conf_compute_rsci_irdy_oreg),
      .plm_conf_compute_rsci_biwt(plm_conf_compute_rsci_biwt),
      .plm_conf_compute_rsci_bdwt(plm_conf_compute_rsci_bdwt),
      .plm_conf_compute_rsci_bcwt(plm_conf_compute_rsci_bcwt),
      .plm_conf_compute_rsci_ivld_core_sct(plm_conf_compute_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_catapult_config_core_plm_conf_compute_rsci_plm_conf_compute_wait_dp
      config_core_plm_conf_compute_rsci_plm_conf_compute_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .plm_conf_compute_rsci_oswt_unreg(plm_conf_compute_rsci_oswt_unreg),
      .plm_conf_compute_rsci_bawt(plm_conf_compute_rsci_bawt),
      .plm_conf_compute_rsci_wen_comp(plm_conf_compute_rsci_wen_comp),
      .plm_conf_compute_rsci_biwt(plm_conf_compute_rsci_biwt),
      .plm_conf_compute_rsci_bdwt(plm_conf_compute_rsci_bdwt),
      .plm_conf_compute_rsci_bcwt(plm_conf_compute_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_plm_conf_load_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_plm_conf_load_rsci (
  clk, rst, plm_conf_load_rsc_dat, plm_conf_load_rsc_vld, plm_conf_load_rsc_rdy,
      core_wen, plm_conf_load_rsci_irdy, plm_conf_load_rsci_oswt_unreg, plm_conf_load_rsci_bawt,
      plm_conf_load_rsci_iswt0, plm_conf_load_rsci_wen_comp, plm_conf_load_rsci_irdy_oreg,
      plm_conf_load_rsci_idat
);
  input clk;
  input rst;
  output [31:0] plm_conf_load_rsc_dat;
  output plm_conf_load_rsc_vld;
  input plm_conf_load_rsc_rdy;
  input core_wen;
  output plm_conf_load_rsci_irdy;
  input plm_conf_load_rsci_oswt_unreg;
  output plm_conf_load_rsci_bawt;
  input plm_conf_load_rsci_iswt0;
  output plm_conf_load_rsci_wen_comp;
  input plm_conf_load_rsci_irdy_oreg;
  input [31:0] plm_conf_load_rsci_idat;


  // Interconnect Declarations
  wire plm_conf_load_rsci_biwt;
  wire plm_conf_load_rsci_bdwt;
  wire plm_conf_load_rsci_bcwt;
  wire plm_conf_load_rsci_ivld_core_sct;
  wire plm_conf_load_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_out_buf_wait_v4 #(.rscid(32'sd2),
  .width(32'sd32),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_conf_load_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .irdy(plm_conf_load_rsci_irdy),
      .ivld(plm_conf_load_rsci_ivld_core_sct),
      .idat(plm_conf_load_rsci_idat),
      .rdy(plm_conf_load_rsc_rdy),
      .vld(plm_conf_load_rsc_vld),
      .dat(plm_conf_load_rsc_dat),
      .is_idle(plm_conf_load_rsc_is_idle)
    );
  esp_acc_softmax_cxx_catapult_config_core_plm_conf_load_rsci_plm_conf_load_wait_ctrl
      config_core_plm_conf_load_rsci_plm_conf_load_wait_ctrl_inst (
      .core_wen(core_wen),
      .plm_conf_load_rsci_oswt_unreg(plm_conf_load_rsci_oswt_unreg),
      .plm_conf_load_rsci_iswt0(plm_conf_load_rsci_iswt0),
      .plm_conf_load_rsci_irdy_oreg(plm_conf_load_rsci_irdy_oreg),
      .plm_conf_load_rsci_biwt(plm_conf_load_rsci_biwt),
      .plm_conf_load_rsci_bdwt(plm_conf_load_rsci_bdwt),
      .plm_conf_load_rsci_bcwt(plm_conf_load_rsci_bcwt),
      .plm_conf_load_rsci_ivld_core_sct(plm_conf_load_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_catapult_config_core_plm_conf_load_rsci_plm_conf_load_wait_dp
      config_core_plm_conf_load_rsci_plm_conf_load_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .plm_conf_load_rsci_oswt_unreg(plm_conf_load_rsci_oswt_unreg),
      .plm_conf_load_rsci_bawt(plm_conf_load_rsci_bawt),
      .plm_conf_load_rsci_wen_comp(plm_conf_load_rsci_wen_comp),
      .plm_conf_load_rsci_biwt(plm_conf_load_rsci_biwt),
      .plm_conf_load_rsci_bdwt(plm_conf_load_rsci_bdwt),
      .plm_conf_load_rsci_bcwt(plm_conf_load_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core_conf_info_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core_conf_info_rsci (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, core_wen, conf_info_rsci_oswt_unreg,
      conf_info_rsci_bawt, conf_info_rsci_iswt0, conf_info_rsci_wen_comp, conf_info_rsci_idat_mxwt
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  input core_wen;
  input conf_info_rsci_oswt_unreg;
  output conf_info_rsci_bawt;
  input conf_info_rsci_iswt0;
  output conf_info_rsci_wen_comp;
  output [31:0] conf_info_rsci_idat_mxwt;


  // Interconnect Declarations
  wire conf_info_rsci_biwt;
  wire conf_info_rsci_bdwt;
  wire conf_info_rsci_bcwt;
  wire conf_info_rsci_irdy_core_sct;
  wire conf_info_rsci_ivld;
  wire [31:0] conf_info_rsci_idat;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_in_wait_v1 #(.rscid(32'sd1),
  .width(32'sd32)) conf_info_rsci (
      .rdy(conf_info_rsc_rdy),
      .vld(conf_info_rsc_vld),
      .dat(conf_info_rsc_dat),
      .irdy(conf_info_rsci_irdy_core_sct),
      .ivld(conf_info_rsci_ivld),
      .idat(conf_info_rsci_idat)
    );
  esp_acc_softmax_cxx_catapult_config_core_conf_info_rsci_conf_info_wait_ctrl config_core_conf_info_rsci_conf_info_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .conf_info_rsci_oswt_unreg(conf_info_rsci_oswt_unreg),
      .conf_info_rsci_iswt0(conf_info_rsci_iswt0),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_irdy_core_sct(conf_info_rsci_irdy_core_sct),
      .conf_info_rsci_ivld(conf_info_rsci_ivld)
    );
  esp_acc_softmax_cxx_catapult_config_core_conf_info_rsci_conf_info_wait_dp config_core_conf_info_rsci_conf_info_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsci_oswt_unreg(conf_info_rsci_oswt_unreg),
      .conf_info_rsci_bawt(conf_info_rsci_bawt),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_idat(conf_info_rsci_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_done_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_done_rsci (
  clk, rst, done_rsc_rdy, done_rsc_vld, core_wen, done_rsci_oswt_unreg, done_rsci_bawt,
      done_rsci_iswt0, done_rsci_wen_comp
);
  input clk;
  input rst;
  input done_rsc_rdy;
  output done_rsc_vld;
  input core_wen;
  input done_rsci_oswt_unreg;
  output done_rsci_bawt;
  input done_rsci_iswt0;
  output done_rsci_wen_comp;


  // Interconnect Declarations
  wire done_rsci_biwt;
  wire done_rsci_bdwt;
  wire done_rsci_bcwt;
  wire done_rsci_ivld_core_sct;
  wire done_rsci_irdy;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_sync_out_wait_v1 #(.rscid(32'sd10)) done_rsci
      (
      .vld(done_rsc_vld),
      .rdy(done_rsc_rdy),
      .ivld(done_rsci_ivld_core_sct),
      .irdy(done_rsci_irdy)
    );
  esp_acc_softmax_cxx_catapult_load_core_done_rsci_done_wait_ctrl load_core_done_rsci_done_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .done_rsci_oswt_unreg(done_rsci_oswt_unreg),
      .done_rsci_iswt0(done_rsci_iswt0),
      .done_rsci_biwt(done_rsci_biwt),
      .done_rsci_bdwt(done_rsci_bdwt),
      .done_rsci_bcwt(done_rsci_bcwt),
      .done_rsci_ivld_core_sct(done_rsci_ivld_core_sct),
      .done_rsci_irdy(done_rsci_irdy)
    );
  esp_acc_softmax_cxx_catapult_load_core_done_rsci_done_wait_dp load_core_done_rsci_done_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .done_rsci_oswt_unreg(done_rsci_oswt_unreg),
      .done_rsci_bawt(done_rsci_bawt),
      .done_rsci_wen_comp(done_rsci_wen_comp),
      .done_rsci_biwt(done_rsci_biwt),
      .done_rsci_bdwt(done_rsci_bdwt),
      .done_rsci_bcwt(done_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_dma_read_chnl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_dma_read_chnl_rsci (
  clk, rst, dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy,
      core_wen, dma_read_chnl_rsci_oswt_unreg, dma_read_chnl_rsci_bawt, dma_read_chnl_rsci_iswt0,
      dma_read_chnl_rsci_wen_comp, dma_read_chnl_rsci_idat_mxwt
);
  input clk;
  input rst;
  input [63:0] dma_read_chnl_rsc_dat;
  input dma_read_chnl_rsc_vld;
  output dma_read_chnl_rsc_rdy;
  input core_wen;
  input dma_read_chnl_rsci_oswt_unreg;
  output dma_read_chnl_rsci_bawt;
  input dma_read_chnl_rsci_iswt0;
  output dma_read_chnl_rsci_wen_comp;
  output [31:0] dma_read_chnl_rsci_idat_mxwt;


  // Interconnect Declarations
  wire dma_read_chnl_rsci_biwt;
  wire dma_read_chnl_rsci_bdwt;
  wire dma_read_chnl_rsci_bcwt;
  wire dma_read_chnl_rsci_irdy_core_sct;
  wire dma_read_chnl_rsci_ivld;
  wire [63:0] dma_read_chnl_rsci_idat;
  wire [31:0] dma_read_chnl_rsci_idat_mxwt_pconst;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_in_wait_v1 #(.rscid(32'sd9),
  .width(32'sd64)) dma_read_chnl_rsci (
      .rdy(dma_read_chnl_rsc_rdy),
      .vld(dma_read_chnl_rsc_vld),
      .dat(dma_read_chnl_rsc_dat),
      .irdy(dma_read_chnl_rsci_irdy_core_sct),
      .ivld(dma_read_chnl_rsci_ivld),
      .idat(dma_read_chnl_rsci_idat)
    );
  esp_acc_softmax_cxx_catapult_load_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl
      load_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl_inst (
      .core_wen(core_wen),
      .dma_read_chnl_rsci_oswt_unreg(dma_read_chnl_rsci_oswt_unreg),
      .dma_read_chnl_rsci_iswt0(dma_read_chnl_rsci_iswt0),
      .dma_read_chnl_rsci_biwt(dma_read_chnl_rsci_biwt),
      .dma_read_chnl_rsci_bdwt(dma_read_chnl_rsci_bdwt),
      .dma_read_chnl_rsci_bcwt(dma_read_chnl_rsci_bcwt),
      .dma_read_chnl_rsci_irdy_core_sct(dma_read_chnl_rsci_irdy_core_sct),
      .dma_read_chnl_rsci_ivld(dma_read_chnl_rsci_ivld)
    );
  esp_acc_softmax_cxx_catapult_load_core_dma_read_chnl_rsci_dma_read_chnl_wait_dp
      load_core_dma_read_chnl_rsci_dma_read_chnl_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .dma_read_chnl_rsci_oswt_unreg(dma_read_chnl_rsci_oswt_unreg),
      .dma_read_chnl_rsci_bawt(dma_read_chnl_rsci_bawt),
      .dma_read_chnl_rsci_wen_comp(dma_read_chnl_rsci_wen_comp),
      .dma_read_chnl_rsci_idat_mxwt(dma_read_chnl_rsci_idat_mxwt_pconst),
      .dma_read_chnl_rsci_biwt(dma_read_chnl_rsci_biwt),
      .dma_read_chnl_rsci_bdwt(dma_read_chnl_rsci_bdwt),
      .dma_read_chnl_rsci_bcwt(dma_read_chnl_rsci_bcwt),
      .dma_read_chnl_rsci_idat(dma_read_chnl_rsci_idat)
    );
  assign dma_read_chnl_rsci_idat_mxwt = dma_read_chnl_rsci_idat_mxwt_pconst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_dma_read_ctrl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_dma_read_ctrl_rsci (
  clk, rst, dma_read_ctrl_rsc_dat, dma_read_ctrl_rsc_vld, dma_read_ctrl_rsc_rdy,
      core_wen, core_wten, dma_read_ctrl_rsci_oswt_unreg, dma_read_ctrl_rsci_bawt,
      dma_read_ctrl_rsci_iswt0, dma_read_ctrl_rsci_irdy_mxwt, dma_read_ctrl_rsci_idat
);
  input clk;
  input rst;
  output [66:0] dma_read_ctrl_rsc_dat;
  output dma_read_ctrl_rsc_vld;
  input dma_read_ctrl_rsc_rdy;
  input core_wen;
  input core_wten;
  input dma_read_ctrl_rsci_oswt_unreg;
  output dma_read_ctrl_rsci_bawt;
  input dma_read_ctrl_rsci_iswt0;
  output dma_read_ctrl_rsci_irdy_mxwt;
  input [66:0] dma_read_ctrl_rsci_idat;


  // Interconnect Declarations
  wire dma_read_ctrl_rsci_irdy;
  wire dma_read_ctrl_rsci_biwt;
  wire dma_read_ctrl_rsci_bdwt;


  // Interconnect Declarations for Component Instantiations 
  wire [66:0] nl_dma_read_ctrl_rsci_idat;
  assign nl_dma_read_ctrl_rsci_idat = {59'b01100000000000000000000000000010000000000000000000000000000
      , (dma_read_ctrl_rsci_idat[7:4]) , 4'b0000};
  esp_acc_softmax_cxx_catapult_ccs_out_wait_v1 #(.rscid(32'sd8),
  .width(32'sd67)) dma_read_ctrl_rsci (
      .irdy(dma_read_ctrl_rsci_irdy),
      .ivld(dma_read_ctrl_rsci_biwt),
      .idat(nl_dma_read_ctrl_rsci_idat[66:0]),
      .rdy(dma_read_ctrl_rsc_rdy),
      .vld(dma_read_ctrl_rsc_vld),
      .dat(dma_read_ctrl_rsc_dat)
    );
  esp_acc_softmax_cxx_catapult_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl
      load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl_inst (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dma_read_ctrl_rsci_oswt_unreg(dma_read_ctrl_rsci_oswt_unreg),
      .dma_read_ctrl_rsci_iswt0(dma_read_ctrl_rsci_iswt0),
      .dma_read_ctrl_rsci_biwt(dma_read_ctrl_rsci_biwt),
      .dma_read_ctrl_rsci_bdwt(dma_read_ctrl_rsci_bdwt)
    );
  esp_acc_softmax_cxx_catapult_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp
      load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .dma_read_ctrl_rsci_bawt(dma_read_ctrl_rsci_bawt),
      .dma_read_ctrl_rsci_irdy_mxwt(dma_read_ctrl_rsci_irdy_mxwt),
      .dma_read_ctrl_rsci_irdy(dma_read_ctrl_rsci_irdy),
      .dma_read_ctrl_rsci_biwt(dma_read_ctrl_rsci_biwt),
      .dma_read_ctrl_rsci_bdwt(dma_read_ctrl_rsci_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_plm_in_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_plm_in_rsci (
  clk, rst, plm_in_rsc_dat, plm_in_rsc_vld, plm_in_rsc_rdy, core_wen, plm_in_rsci_irdy,
      plm_in_rsci_oswt_unreg, plm_in_rsci_bawt, plm_in_rsci_iswt0, plm_in_rsci_wen_comp,
      plm_in_rsci_irdy_oreg, plm_in_rsci_idat
);
  input clk;
  input rst;
  output [511:0] plm_in_rsc_dat;
  output plm_in_rsc_vld;
  input plm_in_rsc_rdy;
  input core_wen;
  output plm_in_rsci_irdy;
  input plm_in_rsci_oswt_unreg;
  output plm_in_rsci_bawt;
  input plm_in_rsci_iswt0;
  output plm_in_rsci_wen_comp;
  input plm_in_rsci_irdy_oreg;
  input [511:0] plm_in_rsci_idat;


  // Interconnect Declarations
  wire plm_in_rsci_biwt;
  wire plm_in_rsci_bdwt;
  wire plm_in_rsci_bcwt;
  wire plm_in_rsci_ivld_core_sct;
  wire plm_in_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_out_buf_wait_v4 #(.rscid(32'sd7),
  .width(32'sd512),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_in_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .irdy(plm_in_rsci_irdy),
      .ivld(plm_in_rsci_ivld_core_sct),
      .idat(plm_in_rsci_idat),
      .rdy(plm_in_rsc_rdy),
      .vld(plm_in_rsc_vld),
      .dat(plm_in_rsc_dat),
      .is_idle(plm_in_rsc_is_idle)
    );
  esp_acc_softmax_cxx_catapult_load_core_plm_in_rsci_plm_in_wait_ctrl load_core_plm_in_rsci_plm_in_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .plm_in_rsci_oswt_unreg(plm_in_rsci_oswt_unreg),
      .plm_in_rsci_iswt0(plm_in_rsci_iswt0),
      .plm_in_rsci_irdy_oreg(plm_in_rsci_irdy_oreg),
      .plm_in_rsci_biwt(plm_in_rsci_biwt),
      .plm_in_rsci_bdwt(plm_in_rsci_bdwt),
      .plm_in_rsci_bcwt(plm_in_rsci_bcwt),
      .plm_in_rsci_ivld_core_sct(plm_in_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_catapult_load_core_plm_in_rsci_plm_in_wait_dp load_core_plm_in_rsci_plm_in_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsci_oswt_unreg(plm_in_rsci_oswt_unreg),
      .plm_in_rsci_bawt(plm_in_rsci_bawt),
      .plm_in_rsci_wen_comp(plm_in_rsci_wen_comp),
      .plm_in_rsci_biwt(plm_in_rsci_biwt),
      .plm_in_rsci_bdwt(plm_in_rsci_bdwt),
      .plm_in_rsci_bcwt(plm_in_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core_conf_info_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core_conf_info_rsci (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, core_wen, conf_info_rsci_oswt_unreg,
      conf_info_rsci_bawt, conf_info_rsci_iswt0, conf_info_rsci_wen_comp, conf_info_rsci_irdy_core_psct,
      conf_info_rsci_ivld, conf_info_rsci_ivld_oreg, conf_info_rsci_idat_mxwt
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  input core_wen;
  input conf_info_rsci_oswt_unreg;
  output conf_info_rsci_bawt;
  input conf_info_rsci_iswt0;
  output conf_info_rsci_wen_comp;
  input conf_info_rsci_irdy_core_psct;
  output conf_info_rsci_ivld;
  input conf_info_rsci_ivld_oreg;
  output [31:0] conf_info_rsci_idat_mxwt;


  // Interconnect Declarations
  wire conf_info_rsci_biwt;
  wire conf_info_rsci_bdwt;
  wire conf_info_rsci_bcwt;
  wire conf_info_rsci_irdy_core_sct;
  wire [31:0] conf_info_rsci_idat;
  wire conf_info_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd6),
  .width(32'sd32),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf_info_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .rdy(conf_info_rsc_rdy),
      .vld(conf_info_rsc_vld),
      .dat(conf_info_rsc_dat),
      .irdy(conf_info_rsci_irdy_core_sct),
      .ivld(conf_info_rsci_ivld),
      .idat(conf_info_rsci_idat),
      .is_idle(conf_info_rsc_is_idle)
    );
  esp_acc_softmax_cxx_catapult_load_core_conf_info_rsci_conf_info_wait_ctrl load_core_conf_info_rsci_conf_info_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .conf_info_rsci_oswt_unreg(conf_info_rsci_oswt_unreg),
      .conf_info_rsci_iswt0(conf_info_rsci_iswt0),
      .conf_info_rsci_irdy_core_psct(conf_info_rsci_irdy_core_psct),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_irdy_core_sct(conf_info_rsci_irdy_core_sct)
    );
  esp_acc_softmax_cxx_catapult_load_core_conf_info_rsci_conf_info_wait_dp load_core_conf_info_rsci_conf_info_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsci_oswt_unreg(conf_info_rsci_oswt_unreg),
      .conf_info_rsci_bawt(conf_info_rsci_bawt),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_idat(conf_info_rsci_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp
    (
  clk, rst, core_wen, core_wten, ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_b_core,
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z,
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_oswt_unreg,
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt,
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_iswt1,
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg,
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input [31:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_b_core;
  output [46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z;
  wire [47:0] nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z;
  input ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_oswt_unreg;
  output ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt;
  input ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_iswt1;
  input [46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg;
  output [18:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt;


  // Interconnect Declarations
  wire ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_biwt;
  wire ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bdwt;
  wire [18:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt_pconst;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_compute_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_mgc_mul_15_0_32_1_47_wait_dp
      compute_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_mgc_mul_15_0_32_1_47_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt_pconst),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_biwt(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_biwt),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bdwt(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bdwt)
    );
  esp_acc_softmax_cxx_catapult_compute_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_mgc_mul_15_0_32_1_47_wait_ctrl
      compute_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_mgc_mul_15_0_32_1_47_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_oswt_unreg(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_oswt_unreg),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_iswt1(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_iswt1),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_biwt(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_biwt),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bdwt(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bdwt)
    );
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt
      = ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt_pconst;
  assign nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z
      = $signed(16'b0101110001010101) * $signed(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_b_core);
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z
      = nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z[46:0];
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_done_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_done_rsci (
  clk, rst, done_rsc_rdy, done_rsc_vld, core_wen, done_rsci_oswt_unreg, done_rsci_bawt,
      done_rsci_iswt0, done_rsci_wen_comp
);
  input clk;
  input rst;
  input done_rsc_rdy;
  output done_rsc_vld;
  input core_wen;
  input done_rsci_oswt_unreg;
  output done_rsci_bawt;
  input done_rsci_iswt0;
  output done_rsci_wen_comp;


  // Interconnect Declarations
  wire done_rsci_biwt;
  wire done_rsci_bdwt;
  wire done_rsci_bcwt;
  wire done_rsci_ivld_core_sct;
  wire done_rsci_irdy;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_sync_out_wait_v1 #(.rscid(32'sd15)) done_rsci
      (
      .vld(done_rsc_vld),
      .rdy(done_rsc_rdy),
      .ivld(done_rsci_ivld_core_sct),
      .irdy(done_rsci_irdy)
    );
  esp_acc_softmax_cxx_catapult_compute_core_done_rsci_done_wait_ctrl compute_core_done_rsci_done_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .done_rsci_oswt_unreg(done_rsci_oswt_unreg),
      .done_rsci_iswt0(done_rsci_iswt0),
      .done_rsci_biwt(done_rsci_biwt),
      .done_rsci_bdwt(done_rsci_bdwt),
      .done_rsci_bcwt(done_rsci_bcwt),
      .done_rsci_ivld_core_sct(done_rsci_ivld_core_sct),
      .done_rsci_irdy(done_rsci_irdy)
    );
  esp_acc_softmax_cxx_catapult_compute_core_done_rsci_done_wait_dp compute_core_done_rsci_done_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .done_rsci_oswt_unreg(done_rsci_oswt_unreg),
      .done_rsci_bawt(done_rsci_bawt),
      .done_rsci_wen_comp(done_rsci_wen_comp),
      .done_rsci_biwt(done_rsci_biwt),
      .done_rsci_bdwt(done_rsci_bdwt),
      .done_rsci_bcwt(done_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_plm_out_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_plm_out_rsci (
  clk, rst, plm_out_rsc_dat, plm_out_rsc_vld, plm_out_rsc_rdy, core_wen, plm_out_rsci_irdy,
      plm_out_rsci_oswt_unreg, plm_out_rsci_bawt, plm_out_rsci_iswt0, plm_out_rsci_wen_comp,
      plm_out_rsci_irdy_oreg, plm_out_rsci_idat
);
  input clk;
  input rst;
  output [511:0] plm_out_rsc_dat;
  output plm_out_rsc_vld;
  input plm_out_rsc_rdy;
  input core_wen;
  output plm_out_rsci_irdy;
  input plm_out_rsci_oswt_unreg;
  output plm_out_rsci_bawt;
  input plm_out_rsci_iswt0;
  output plm_out_rsci_wen_comp;
  input plm_out_rsci_irdy_oreg;
  input [511:0] plm_out_rsci_idat;


  // Interconnect Declarations
  wire plm_out_rsci_biwt;
  wire plm_out_rsci_bdwt;
  wire plm_out_rsci_bcwt;
  wire plm_out_rsci_ivld_core_sct;
  wire plm_out_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_out_buf_wait_v4 #(.rscid(32'sd14),
  .width(32'sd512),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_out_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .irdy(plm_out_rsci_irdy),
      .ivld(plm_out_rsci_ivld_core_sct),
      .idat(plm_out_rsci_idat),
      .rdy(plm_out_rsc_rdy),
      .vld(plm_out_rsc_vld),
      .dat(plm_out_rsc_dat),
      .is_idle(plm_out_rsc_is_idle)
    );
  esp_acc_softmax_cxx_catapult_compute_core_plm_out_rsci_plm_out_wait_ctrl compute_core_plm_out_rsci_plm_out_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .plm_out_rsci_oswt_unreg(plm_out_rsci_oswt_unreg),
      .plm_out_rsci_iswt0(plm_out_rsci_iswt0),
      .plm_out_rsci_irdy_oreg(plm_out_rsci_irdy_oreg),
      .plm_out_rsci_biwt(plm_out_rsci_biwt),
      .plm_out_rsci_bdwt(plm_out_rsci_bdwt),
      .plm_out_rsci_bcwt(plm_out_rsci_bcwt),
      .plm_out_rsci_ivld_core_sct(plm_out_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_catapult_compute_core_plm_out_rsci_plm_out_wait_dp compute_core_plm_out_rsci_plm_out_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsci_oswt_unreg(plm_out_rsci_oswt_unreg),
      .plm_out_rsci_bawt(plm_out_rsci_bawt),
      .plm_out_rsci_wen_comp(plm_out_rsci_wen_comp),
      .plm_out_rsci_biwt(plm_out_rsci_biwt),
      .plm_out_rsci_bdwt(plm_out_rsci_bdwt),
      .plm_out_rsci_bcwt(plm_out_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_plm_in_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_plm_in_rsci (
  clk, rst, plm_in_rsc_dat, plm_in_rsc_vld, plm_in_rsc_rdy, core_wen, plm_in_rsci_oswt_unreg,
      plm_in_rsci_bawt, plm_in_rsci_iswt0, plm_in_rsci_wen_comp, plm_in_rsci_irdy_core_psct,
      plm_in_rsci_ivld, plm_in_rsci_ivld_oreg, plm_in_rsci_idat_mxwt
);
  input clk;
  input rst;
  input [511:0] plm_in_rsc_dat;
  input plm_in_rsc_vld;
  output plm_in_rsc_rdy;
  input core_wen;
  input plm_in_rsci_oswt_unreg;
  output plm_in_rsci_bawt;
  input plm_in_rsci_iswt0;
  output plm_in_rsci_wen_comp;
  input plm_in_rsci_irdy_core_psct;
  output plm_in_rsci_ivld;
  input plm_in_rsci_ivld_oreg;
  output [511:0] plm_in_rsci_idat_mxwt;


  // Interconnect Declarations
  wire plm_in_rsci_biwt;
  wire plm_in_rsci_bdwt;
  wire plm_in_rsci_bcwt;
  wire plm_in_rsci_irdy_core_sct;
  wire [511:0] plm_in_rsci_idat;
  wire plm_in_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd13),
  .width(32'sd512),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_in_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .rdy(plm_in_rsc_rdy),
      .vld(plm_in_rsc_vld),
      .dat(plm_in_rsc_dat),
      .irdy(plm_in_rsci_irdy_core_sct),
      .ivld(plm_in_rsci_ivld),
      .idat(plm_in_rsci_idat),
      .is_idle(plm_in_rsc_is_idle)
    );
  esp_acc_softmax_cxx_catapult_compute_core_plm_in_rsci_plm_in_wait_ctrl compute_core_plm_in_rsci_plm_in_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .plm_in_rsci_oswt_unreg(plm_in_rsci_oswt_unreg),
      .plm_in_rsci_iswt0(plm_in_rsci_iswt0),
      .plm_in_rsci_irdy_core_psct(plm_in_rsci_irdy_core_psct),
      .plm_in_rsci_ivld_oreg(plm_in_rsci_ivld_oreg),
      .plm_in_rsci_biwt(plm_in_rsci_biwt),
      .plm_in_rsci_bdwt(plm_in_rsci_bdwt),
      .plm_in_rsci_bcwt(plm_in_rsci_bcwt),
      .plm_in_rsci_irdy_core_sct(plm_in_rsci_irdy_core_sct)
    );
  esp_acc_softmax_cxx_catapult_compute_core_plm_in_rsci_plm_in_wait_dp compute_core_plm_in_rsci_plm_in_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsci_oswt_unreg(plm_in_rsci_oswt_unreg),
      .plm_in_rsci_bawt(plm_in_rsci_bawt),
      .plm_in_rsci_wen_comp(plm_in_rsci_wen_comp),
      .plm_in_rsci_idat_mxwt(plm_in_rsci_idat_mxwt),
      .plm_in_rsci_biwt(plm_in_rsci_biwt),
      .plm_in_rsci_bdwt(plm_in_rsci_bdwt),
      .plm_in_rsci_bcwt(plm_in_rsci_bcwt),
      .plm_in_rsci_idat(plm_in_rsci_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core_conf_info_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core_conf_info_rsci (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, core_wen, conf_info_rsci_oswt_unreg,
      conf_info_rsci_bawt, conf_info_rsci_iswt0, conf_info_rsci_wen_comp, conf_info_rsci_irdy_core_psct,
      conf_info_rsci_ivld, conf_info_rsci_ivld_oreg, conf_info_rsci_idat_mxwt
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  input core_wen;
  input conf_info_rsci_oswt_unreg;
  output conf_info_rsci_bawt;
  input conf_info_rsci_iswt0;
  output conf_info_rsci_wen_comp;
  input conf_info_rsci_irdy_core_psct;
  output conf_info_rsci_ivld;
  input conf_info_rsci_ivld_oreg;
  output [31:0] conf_info_rsci_idat_mxwt;


  // Interconnect Declarations
  wire conf_info_rsci_biwt;
  wire conf_info_rsci_bdwt;
  wire conf_info_rsci_bcwt;
  wire conf_info_rsci_irdy_core_sct;
  wire [31:0] conf_info_rsci_idat;
  wire conf_info_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd12),
  .width(32'sd32),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf_info_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .rdy(conf_info_rsc_rdy),
      .vld(conf_info_rsc_vld),
      .dat(conf_info_rsc_dat),
      .irdy(conf_info_rsci_irdy_core_sct),
      .ivld(conf_info_rsci_ivld),
      .idat(conf_info_rsci_idat),
      .is_idle(conf_info_rsc_is_idle)
    );
  esp_acc_softmax_cxx_catapult_compute_core_conf_info_rsci_conf_info_wait_ctrl compute_core_conf_info_rsci_conf_info_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .conf_info_rsci_oswt_unreg(conf_info_rsci_oswt_unreg),
      .conf_info_rsci_iswt0(conf_info_rsci_iswt0),
      .conf_info_rsci_irdy_core_psct(conf_info_rsci_irdy_core_psct),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_irdy_core_sct(conf_info_rsci_irdy_core_sct)
    );
  esp_acc_softmax_cxx_catapult_compute_core_conf_info_rsci_conf_info_wait_dp compute_core_conf_info_rsci_conf_info_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsci_oswt_unreg(conf_info_rsci_oswt_unreg),
      .conf_info_rsci_bawt(conf_info_rsci_bawt),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_idat(conf_info_rsci_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_done_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_done_rsci (
  clk, rst, done_rsc_rdy, done_rsc_vld, core_wen, done_rsci_oswt_unreg, done_rsci_bawt,
      done_rsci_iswt0, done_rsci_wen_comp
);
  input clk;
  input rst;
  input done_rsc_rdy;
  output done_rsc_vld;
  input core_wen;
  input done_rsci_oswt_unreg;
  output done_rsci_bawt;
  input done_rsci_iswt0;
  output done_rsci_wen_comp;


  // Interconnect Declarations
  wire done_rsci_biwt;
  wire done_rsci_bdwt;
  wire done_rsci_bcwt;
  wire done_rsci_ivld_core_sct;
  wire done_rsci_irdy;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_sync_out_wait_v1 #(.rscid(32'sd27)) done_rsci
      (
      .vld(done_rsc_vld),
      .rdy(done_rsc_rdy),
      .ivld(done_rsci_ivld_core_sct),
      .irdy(done_rsci_irdy)
    );
  esp_acc_softmax_cxx_catapult_store_core_done_rsci_done_wait_ctrl store_core_done_rsci_done_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .done_rsci_oswt_unreg(done_rsci_oswt_unreg),
      .done_rsci_iswt0(done_rsci_iswt0),
      .done_rsci_biwt(done_rsci_biwt),
      .done_rsci_bdwt(done_rsci_bdwt),
      .done_rsci_bcwt(done_rsci_bcwt),
      .done_rsci_ivld_core_sct(done_rsci_ivld_core_sct),
      .done_rsci_irdy(done_rsci_irdy)
    );
  esp_acc_softmax_cxx_catapult_store_core_done_rsci_done_wait_dp store_core_done_rsci_done_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .done_rsci_oswt_unreg(done_rsci_oswt_unreg),
      .done_rsci_bawt(done_rsci_bawt),
      .done_rsci_wen_comp(done_rsci_wen_comp),
      .done_rsci_biwt(done_rsci_biwt),
      .done_rsci_bdwt(done_rsci_bdwt),
      .done_rsci_bcwt(done_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_dma_write_chnl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_dma_write_chnl_rsci (
  clk, rst, dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy,
      core_wen, dma_write_chnl_rsci_oswt_unreg, dma_write_chnl_rsci_bawt, dma_write_chnl_rsci_iswt0,
      dma_write_chnl_rsci_wen_comp, dma_write_chnl_rsci_idat
);
  input clk;
  input rst;
  output [63:0] dma_write_chnl_rsc_dat;
  output dma_write_chnl_rsc_vld;
  input dma_write_chnl_rsc_rdy;
  input core_wen;
  input dma_write_chnl_rsci_oswt_unreg;
  output dma_write_chnl_rsci_bawt;
  input dma_write_chnl_rsci_iswt0;
  output dma_write_chnl_rsci_wen_comp;
  input [63:0] dma_write_chnl_rsci_idat;


  // Interconnect Declarations
  wire dma_write_chnl_rsci_irdy;
  wire dma_write_chnl_rsci_biwt;
  wire dma_write_chnl_rsci_bdwt;
  wire dma_write_chnl_rsci_bcwt;
  wire dma_write_chnl_rsci_ivld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  wire [63:0] nl_dma_write_chnl_rsci_idat;
  assign nl_dma_write_chnl_rsci_idat = {32'b11011110101011011011111011101111 , (dma_write_chnl_rsci_idat[31:0])};
  esp_acc_softmax_cxx_catapult_ccs_out_wait_v1 #(.rscid(32'sd26),
  .width(32'sd64)) dma_write_chnl_rsci (
      .irdy(dma_write_chnl_rsci_irdy),
      .ivld(dma_write_chnl_rsci_ivld_core_sct),
      .idat(nl_dma_write_chnl_rsci_idat[63:0]),
      .rdy(dma_write_chnl_rsc_rdy),
      .vld(dma_write_chnl_rsc_vld),
      .dat(dma_write_chnl_rsc_dat)
    );
  esp_acc_softmax_cxx_catapult_store_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl
      store_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl_inst (
      .core_wen(core_wen),
      .dma_write_chnl_rsci_oswt_unreg(dma_write_chnl_rsci_oswt_unreg),
      .dma_write_chnl_rsci_iswt0(dma_write_chnl_rsci_iswt0),
      .dma_write_chnl_rsci_irdy(dma_write_chnl_rsci_irdy),
      .dma_write_chnl_rsci_biwt(dma_write_chnl_rsci_biwt),
      .dma_write_chnl_rsci_bdwt(dma_write_chnl_rsci_bdwt),
      .dma_write_chnl_rsci_bcwt(dma_write_chnl_rsci_bcwt),
      .dma_write_chnl_rsci_ivld_core_sct(dma_write_chnl_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_catapult_store_core_dma_write_chnl_rsci_dma_write_chnl_wait_dp
      store_core_dma_write_chnl_rsci_dma_write_chnl_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .dma_write_chnl_rsci_oswt_unreg(dma_write_chnl_rsci_oswt_unreg),
      .dma_write_chnl_rsci_bawt(dma_write_chnl_rsci_bawt),
      .dma_write_chnl_rsci_wen_comp(dma_write_chnl_rsci_wen_comp),
      .dma_write_chnl_rsci_biwt(dma_write_chnl_rsci_biwt),
      .dma_write_chnl_rsci_bdwt(dma_write_chnl_rsci_bdwt),
      .dma_write_chnl_rsci_bcwt(dma_write_chnl_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_dma_write_ctrl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_dma_write_ctrl_rsci (
  clk, rst, dma_write_ctrl_rsc_dat, dma_write_ctrl_rsc_vld, dma_write_ctrl_rsc_rdy,
      core_wen, core_wten, dma_write_ctrl_rsci_oswt_unreg, dma_write_ctrl_rsci_bawt,
      dma_write_ctrl_rsci_iswt0, dma_write_ctrl_rsci_irdy_mxwt, dma_write_ctrl_rsci_idat
);
  input clk;
  input rst;
  output [66:0] dma_write_ctrl_rsc_dat;
  output dma_write_ctrl_rsc_vld;
  input dma_write_ctrl_rsc_rdy;
  input core_wen;
  input core_wten;
  input dma_write_ctrl_rsci_oswt_unreg;
  output dma_write_ctrl_rsci_bawt;
  input dma_write_ctrl_rsci_iswt0;
  output dma_write_ctrl_rsci_irdy_mxwt;
  input [66:0] dma_write_ctrl_rsci_idat;


  // Interconnect Declarations
  wire dma_write_ctrl_rsci_irdy;
  wire dma_write_ctrl_rsci_biwt;
  wire dma_write_ctrl_rsci_bdwt;


  // Interconnect Declarations for Component Instantiations 
  wire [66:0] nl_dma_write_ctrl_rsci_idat;
  assign nl_dma_write_ctrl_rsci_idat = {35'b01100000000000000000000000000010000 ,
      (dma_write_ctrl_rsci_idat[31:4]) , 4'b0000};
  esp_acc_softmax_cxx_catapult_ccs_out_wait_v1 #(.rscid(32'sd25),
  .width(32'sd67)) dma_write_ctrl_rsci (
      .irdy(dma_write_ctrl_rsci_irdy),
      .ivld(dma_write_ctrl_rsci_biwt),
      .idat(nl_dma_write_ctrl_rsci_idat[66:0]),
      .rdy(dma_write_ctrl_rsc_rdy),
      .vld(dma_write_ctrl_rsc_vld),
      .dat(dma_write_ctrl_rsc_dat)
    );
  esp_acc_softmax_cxx_catapult_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl
      store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl_inst (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dma_write_ctrl_rsci_oswt_unreg(dma_write_ctrl_rsci_oswt_unreg),
      .dma_write_ctrl_rsci_iswt0(dma_write_ctrl_rsci_iswt0),
      .dma_write_ctrl_rsci_biwt(dma_write_ctrl_rsci_biwt),
      .dma_write_ctrl_rsci_bdwt(dma_write_ctrl_rsci_bdwt)
    );
  esp_acc_softmax_cxx_catapult_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp
      store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .dma_write_ctrl_rsci_bawt(dma_write_ctrl_rsci_bawt),
      .dma_write_ctrl_rsci_irdy_mxwt(dma_write_ctrl_rsci_irdy_mxwt),
      .dma_write_ctrl_rsci_irdy(dma_write_ctrl_rsci_irdy),
      .dma_write_ctrl_rsci_biwt(dma_write_ctrl_rsci_biwt),
      .dma_write_ctrl_rsci_bdwt(dma_write_ctrl_rsci_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_plm_out_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_plm_out_rsci (
  clk, rst, plm_out_rsc_dat, plm_out_rsc_vld, plm_out_rsc_rdy, core_wen, plm_out_rsci_oswt_unreg,
      plm_out_rsci_bawt, plm_out_rsci_iswt0, plm_out_rsci_wen_comp, plm_out_rsci_ivld,
      plm_out_rsci_ivld_oreg, plm_out_rsci_idat_mxwt
);
  input clk;
  input rst;
  input [511:0] plm_out_rsc_dat;
  input plm_out_rsc_vld;
  output plm_out_rsc_rdy;
  input core_wen;
  input plm_out_rsci_oswt_unreg;
  output plm_out_rsci_bawt;
  input plm_out_rsci_iswt0;
  output plm_out_rsci_wen_comp;
  output plm_out_rsci_ivld;
  input plm_out_rsci_ivld_oreg;
  output [511:0] plm_out_rsci_idat_mxwt;


  // Interconnect Declarations
  wire plm_out_rsci_biwt;
  wire plm_out_rsci_bdwt;
  wire plm_out_rsci_bcwt;
  wire plm_out_rsci_irdy_core_sct;
  wire [511:0] plm_out_rsci_idat;
  wire plm_out_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd24),
  .width(32'sd512),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_out_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .rdy(plm_out_rsc_rdy),
      .vld(plm_out_rsc_vld),
      .dat(plm_out_rsc_dat),
      .irdy(plm_out_rsci_irdy_core_sct),
      .ivld(plm_out_rsci_ivld),
      .idat(plm_out_rsci_idat),
      .is_idle(plm_out_rsc_is_idle)
    );
  esp_acc_softmax_cxx_catapult_store_core_plm_out_rsci_plm_out_wait_ctrl store_core_plm_out_rsci_plm_out_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .plm_out_rsci_oswt_unreg(plm_out_rsci_oswt_unreg),
      .plm_out_rsci_iswt0(plm_out_rsci_iswt0),
      .plm_out_rsci_ivld_oreg(plm_out_rsci_ivld_oreg),
      .plm_out_rsci_biwt(plm_out_rsci_biwt),
      .plm_out_rsci_bdwt(plm_out_rsci_bdwt),
      .plm_out_rsci_bcwt(plm_out_rsci_bcwt),
      .plm_out_rsci_irdy_core_sct(plm_out_rsci_irdy_core_sct)
    );
  esp_acc_softmax_cxx_catapult_store_core_plm_out_rsci_plm_out_wait_dp store_core_plm_out_rsci_plm_out_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsci_oswt_unreg(plm_out_rsci_oswt_unreg),
      .plm_out_rsci_bawt(plm_out_rsci_bawt),
      .plm_out_rsci_wen_comp(plm_out_rsci_wen_comp),
      .plm_out_rsci_idat_mxwt(plm_out_rsci_idat_mxwt),
      .plm_out_rsci_biwt(plm_out_rsci_biwt),
      .plm_out_rsci_bdwt(plm_out_rsci_bdwt),
      .plm_out_rsci_bcwt(plm_out_rsci_bcwt),
      .plm_out_rsci_idat(plm_out_rsci_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core_conf_info_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core_conf_info_rsci (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, core_wen, conf_info_rsci_oswt_unreg,
      conf_info_rsci_bawt, conf_info_rsci_iswt0, conf_info_rsci_wen_comp, conf_info_rsci_irdy_core_psct,
      conf_info_rsci_ivld, conf_info_rsci_ivld_oreg, conf_info_rsci_idat_mxwt
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  input core_wen;
  input conf_info_rsci_oswt_unreg;
  output conf_info_rsci_bawt;
  input conf_info_rsci_iswt0;
  output conf_info_rsci_wen_comp;
  input conf_info_rsci_irdy_core_psct;
  output conf_info_rsci_ivld;
  input conf_info_rsci_ivld_oreg;
  output [31:0] conf_info_rsci_idat_mxwt;


  // Interconnect Declarations
  wire conf_info_rsci_biwt;
  wire conf_info_rsci_bdwt;
  wire conf_info_rsci_bcwt;
  wire conf_info_rsci_irdy_core_sct;
  wire [31:0] conf_info_rsci_idat;
  wire conf_info_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd23),
  .width(32'sd32),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf_info_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .rdy(conf_info_rsc_rdy),
      .vld(conf_info_rsc_vld),
      .dat(conf_info_rsc_dat),
      .irdy(conf_info_rsci_irdy_core_sct),
      .ivld(conf_info_rsci_ivld),
      .idat(conf_info_rsci_idat),
      .is_idle(conf_info_rsc_is_idle)
    );
  esp_acc_softmax_cxx_catapult_store_core_conf_info_rsci_conf_info_wait_ctrl store_core_conf_info_rsci_conf_info_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .conf_info_rsci_oswt_unreg(conf_info_rsci_oswt_unreg),
      .conf_info_rsci_iswt0(conf_info_rsci_iswt0),
      .conf_info_rsci_irdy_core_psct(conf_info_rsci_irdy_core_psct),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_irdy_core_sct(conf_info_rsci_irdy_core_sct)
    );
  esp_acc_softmax_cxx_catapult_store_core_conf_info_rsci_conf_info_wait_dp store_core_conf_info_rsci_conf_info_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsci_oswt_unreg(conf_info_rsci_oswt_unreg),
      .conf_info_rsci_bawt(conf_info_rsci_bawt),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_idat(conf_info_rsci_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core (
  clk, rst, acc_done_rsc_vld, config_done_cns_rdy, config_done_cns_vld, load_done_cns_rdy,
      load_done_cns_vld, compute_done_cns_rdy, compute_done_cns_vld, store_done_cns_rdy,
      store_done_cns_vld
);
  input clk;
  input rst;
  output acc_done_rsc_vld;
  output config_done_cns_rdy;
  input config_done_cns_vld;
  output load_done_cns_rdy;
  input load_done_cns_vld;
  output compute_done_cns_rdy;
  input compute_done_cns_vld;
  output store_done_cns_rdy;
  input store_done_cns_vld;


  // Interconnect Declarations
  wire core_wen;
  wire acc_done_rsci_bawt;
  wire core_wten;
  wire config_done_cnsi_bawt;
  wire config_done_cnsi_wen_comp;
  wire load_done_cnsi_bawt;
  wire load_done_cnsi_wen_comp;
  reg load_done_cnsi_irdy_core_psct;
  wire compute_done_cnsi_bawt;
  wire compute_done_cnsi_wen_comp;
  wire store_done_cnsi_bawt;
  wire store_done_cnsi_wen_comp;
  wire [1:0] fsm_output;
  wire and_dcpl_1;
  wire and_dcpl_2;
  wire and_dcpl_5;
  wire and_dcpl_13;
  wire and_dcpl_14;
  wire and_dcpl_17;
  wire and_dcpl_18;
  wire and_dcpl_19;
  wire and_dcpl_21;
  wire and_dcpl_26;
  wire and_dcpl_27;
  wire and_56_cse;
  reg main_stage_v_4;
  reg reg_store_done_cnsi_irdy_core_psct_cse;
  reg reg_compute_done_cnsi_irdy_core_psct_cse;
  reg reg_store_done_cnsi_oswt_cse;
  reg reg_load_done_cnsi_iswt0_cse;
  wire or_20_cse;
  wire or_17_cse;
  wire or_15_cse;
  wire or_cse;
  wire main_stage_v_4_mx0c1;
  reg reg_config_done_cnsi_iswt0_cse;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_acc_done_rsci softmax_cxx_catapult_core_core_acc_done_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .acc_done_rsc_vld(acc_done_rsc_vld),
      .core_wen(core_wen),
      .acc_done_rsci_oswt_unreg(and_dcpl_27),
      .acc_done_rsci_bawt(acc_done_rsci_bawt),
      .acc_done_rsci_iswt0(reg_store_done_cnsi_oswt_cse),
      .core_wten(core_wten)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_config_done_cnsi softmax_cxx_catapult_core_core_config_done_cnsi_inst
      (
      .clk(clk),
      .rst(rst),
      .config_done_cns_rdy(config_done_cns_rdy),
      .config_done_cns_vld(config_done_cns_vld),
      .core_wen(core_wen),
      .config_done_cnsi_oswt_unreg(and_56_cse),
      .config_done_cnsi_bawt(config_done_cnsi_bawt),
      .config_done_cnsi_iswt0(reg_config_done_cnsi_iswt0_cse),
      .config_done_cnsi_wen_comp(config_done_cnsi_wen_comp)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_load_done_cnsi softmax_cxx_catapult_core_core_load_done_cnsi_inst
      (
      .clk(clk),
      .rst(rst),
      .load_done_cns_rdy(load_done_cns_rdy),
      .load_done_cns_vld(load_done_cns_vld),
      .core_wen(core_wen),
      .load_done_cnsi_oswt_unreg(and_dcpl_19),
      .load_done_cnsi_bawt(load_done_cnsi_bawt),
      .load_done_cnsi_iswt0(reg_load_done_cnsi_iswt0_cse),
      .load_done_cnsi_wen_comp(load_done_cnsi_wen_comp),
      .load_done_cnsi_irdy_core_psct(load_done_cnsi_irdy_core_psct)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_compute_done_cnsi softmax_cxx_catapult_core_core_compute_done_cnsi_inst
      (
      .clk(clk),
      .rst(rst),
      .compute_done_cns_rdy(compute_done_cns_rdy),
      .compute_done_cns_vld(compute_done_cns_vld),
      .core_wen(core_wen),
      .compute_done_cnsi_oswt_unreg(and_dcpl_14),
      .compute_done_cnsi_bawt(compute_done_cnsi_bawt),
      .compute_done_cnsi_iswt0(reg_compute_done_cnsi_irdy_core_psct_cse),
      .compute_done_cnsi_wen_comp(compute_done_cnsi_wen_comp)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_store_done_cnsi softmax_cxx_catapult_core_core_store_done_cnsi_inst
      (
      .clk(clk),
      .rst(rst),
      .store_done_cns_rdy(store_done_cns_rdy),
      .store_done_cns_vld(store_done_cns_vld),
      .core_wen(core_wen),
      .store_done_cnsi_oswt_unreg(and_dcpl_18),
      .store_done_cnsi_bawt(store_done_cnsi_bawt),
      .store_done_cnsi_iswt0(reg_store_done_cnsi_irdy_core_psct_cse),
      .store_done_cnsi_wen_comp(store_done_cnsi_wen_comp)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_staller softmax_cxx_catapult_core_core_staller_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .config_done_cnsi_wen_comp(config_done_cnsi_wen_comp),
      .load_done_cnsi_wen_comp(load_done_cnsi_wen_comp),
      .compute_done_cnsi_wen_comp(compute_done_cnsi_wen_comp),
      .store_done_cnsi_wen_comp(store_done_cnsi_wen_comp)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_core_fsm softmax_cxx_catapult_core_core_core_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  assign or_20_cse = load_done_cnsi_bawt | (~ reg_load_done_cnsi_iswt0_cse);
  assign or_17_cse = compute_done_cnsi_bawt | (~ reg_compute_done_cnsi_irdy_core_psct_cse);
  assign or_15_cse = store_done_cnsi_bawt | (~ reg_store_done_cnsi_irdy_core_psct_cse);
  assign or_cse = acc_done_rsci_bawt | (~ main_stage_v_4);
  assign and_dcpl_1 = or_cse & or_15_cse;
  assign and_dcpl_2 = and_dcpl_1 & or_17_cse;
  assign and_dcpl_5 = load_done_cnsi_bawt & reg_load_done_cnsi_iswt0_cse;
  assign and_dcpl_13 = compute_done_cnsi_bawt & reg_compute_done_cnsi_irdy_core_psct_cse;
  assign and_dcpl_14 = and_dcpl_1 & and_dcpl_13;
  assign and_dcpl_17 = or_cse & store_done_cnsi_bawt & (~(compute_done_cnsi_bawt
      & reg_compute_done_cnsi_irdy_core_psct_cse)) & reg_store_done_cnsi_irdy_core_psct_cse;
  assign and_dcpl_18 = or_cse & reg_store_done_cnsi_irdy_core_psct_cse & store_done_cnsi_bawt;
  assign and_dcpl_19 = and_dcpl_2 & and_dcpl_5;
  assign and_dcpl_21 = and_dcpl_1 & and_dcpl_13 & (~(load_done_cnsi_bawt & reg_load_done_cnsi_iswt0_cse));
  assign and_dcpl_26 = and_dcpl_2 & and_dcpl_5 & (~ config_done_cnsi_bawt);
  assign and_dcpl_27 = main_stage_v_4 & acc_done_rsci_bawt;
  assign and_56_cse = and_dcpl_2 & or_20_cse & config_done_cnsi_bawt & (fsm_output[1]);
  assign main_stage_v_4_mx0c1 = and_dcpl_27 & (~(store_done_cnsi_bawt & reg_store_done_cnsi_irdy_core_psct_cse));
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_config_done_cnsi_iswt0_cse <= 1'b0;
    end
    else if ( core_wen & ((config_done_cnsi_bawt & or_20_cse & or_17_cse & or_15_cse
        & or_cse) | (fsm_output[0])) ) begin
      reg_config_done_cnsi_iswt0_cse <= 1'b1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_store_done_cnsi_irdy_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_14 | and_dcpl_17) ) begin
      reg_store_done_cnsi_irdy_core_psct_cse <= ~ and_dcpl_17;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_store_done_cnsi_oswt_cse <= 1'b0;
    end
    else if ( core_wen ) begin
      reg_store_done_cnsi_oswt_cse <= and_dcpl_18;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_compute_done_cnsi_irdy_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_19 | and_dcpl_21) ) begin
      reg_compute_done_cnsi_irdy_core_psct_cse <= ~ and_dcpl_21;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      load_done_cnsi_irdy_core_psct <= 1'b0;
    end
    else if ( core_wen & (and_56_cse | (and_dcpl_2 & and_dcpl_5 & config_done_cnsi_bawt)
        | and_dcpl_26) ) begin
      load_done_cnsi_irdy_core_psct <= ~ and_dcpl_26;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_load_done_cnsi_iswt0_cse <= 1'b0;
    end
    else if ( core_wen & (and_56_cse | and_dcpl_26) ) begin
      reg_load_done_cnsi_iswt0_cse <= ~ and_dcpl_26;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_4 <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_18 | main_stage_v_4_mx0c1) ) begin
      main_stage_v_4 <= ~ main_stage_v_4_mx0c1;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config_core (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, plm_conf_load_rsc_dat,
      plm_conf_load_rsc_vld, plm_conf_load_rsc_rdy, plm_conf_compute_rsc_dat, plm_conf_compute_rsc_vld,
      plm_conf_compute_rsc_rdy, plm_conf_store_rsc_dat, plm_conf_store_rsc_vld, plm_conf_store_rsc_rdy,
      done_rsc_rdy, done_rsc_vld
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  output [31:0] plm_conf_load_rsc_dat;
  output plm_conf_load_rsc_vld;
  input plm_conf_load_rsc_rdy;
  output [31:0] plm_conf_compute_rsc_dat;
  output plm_conf_compute_rsc_vld;
  input plm_conf_compute_rsc_rdy;
  output [31:0] plm_conf_store_rsc_dat;
  output plm_conf_store_rsc_vld;
  input plm_conf_store_rsc_rdy;
  input done_rsc_rdy;
  output done_rsc_vld;


  // Interconnect Declarations
  wire core_wen;
  wire conf_info_rsci_bawt;
  wire conf_info_rsci_wen_comp;
  wire [31:0] conf_info_rsci_idat_mxwt;
  wire plm_conf_load_rsci_irdy;
  wire plm_conf_load_rsci_bawt;
  wire plm_conf_load_rsci_wen_comp;
  wire plm_conf_load_rsci_irdy_oreg;
  wire plm_conf_compute_rsci_irdy;
  wire plm_conf_compute_rsci_bawt;
  wire plm_conf_compute_rsci_wen_comp;
  wire plm_conf_compute_rsci_irdy_oreg;
  wire plm_conf_store_rsci_irdy;
  wire plm_conf_store_rsci_bawt;
  wire plm_conf_store_rsci_wen_comp;
  wire plm_conf_store_rsci_irdy_oreg;
  reg [31:0] plm_conf_store_rsci_idat;
  wire done_rsci_bawt;
  wire done_rsci_wen_comp;
  wire [1:0] fsm_output;
  wire and_dcpl_1;
  wire and_dcpl_9;
  wire or_dcpl_3;
  wire or_dcpl_5;
  wire and_dcpl_15;
  wire and_dcpl_16;
  wire or_dcpl_6;
  wire and_dcpl_17;
  wire and_dcpl_20;
  wire or_tmp_8;
  reg reg_done_rsci_ivld_core_psct_cse;
  reg reg_plm_conf_store_rsci_ivld_core_psct_cse;
  reg [31:0] reg_plm_conf_compute_rsci_idat_cse;
  wire or_cse;
  reg reg_conf_info_rsci_iswt0_cse;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_config_core_conf_info_rsci config_core_conf_info_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .core_wen(core_wen),
      .conf_info_rsci_oswt_unreg(or_tmp_8),
      .conf_info_rsci_bawt(conf_info_rsci_bawt),
      .conf_info_rsci_iswt0(reg_conf_info_rsci_iswt0_cse),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_catapult_config_core_wait_dp config_core_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .plm_conf_load_rsci_irdy(plm_conf_load_rsci_irdy),
      .plm_conf_load_rsci_irdy_oreg(plm_conf_load_rsci_irdy_oreg),
      .plm_conf_compute_rsci_irdy(plm_conf_compute_rsci_irdy),
      .plm_conf_compute_rsci_irdy_oreg(plm_conf_compute_rsci_irdy_oreg),
      .plm_conf_store_rsci_irdy(plm_conf_store_rsci_irdy),
      .plm_conf_store_rsci_irdy_oreg(plm_conf_store_rsci_irdy_oreg)
    );
  esp_acc_softmax_cxx_catapult_config_core_plm_conf_load_rsci config_core_plm_conf_load_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_load_rsc_dat(plm_conf_load_rsc_dat),
      .plm_conf_load_rsc_vld(plm_conf_load_rsc_vld),
      .plm_conf_load_rsc_rdy(plm_conf_load_rsc_rdy),
      .core_wen(core_wen),
      .plm_conf_load_rsci_irdy(plm_conf_load_rsci_irdy),
      .plm_conf_load_rsci_oswt_unreg(and_dcpl_15),
      .plm_conf_load_rsci_bawt(plm_conf_load_rsci_bawt),
      .plm_conf_load_rsci_iswt0(reg_plm_conf_store_rsci_ivld_core_psct_cse),
      .plm_conf_load_rsci_wen_comp(plm_conf_load_rsci_wen_comp),
      .plm_conf_load_rsci_irdy_oreg(plm_conf_load_rsci_irdy_oreg),
      .plm_conf_load_rsci_idat(reg_plm_conf_compute_rsci_idat_cse)
    );
  esp_acc_softmax_cxx_catapult_config_core_plm_conf_compute_rsci config_core_plm_conf_compute_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_compute_rsc_dat(plm_conf_compute_rsc_dat),
      .plm_conf_compute_rsc_vld(plm_conf_compute_rsc_vld),
      .plm_conf_compute_rsc_rdy(plm_conf_compute_rsc_rdy),
      .core_wen(core_wen),
      .plm_conf_compute_rsci_irdy(plm_conf_compute_rsci_irdy),
      .plm_conf_compute_rsci_oswt_unreg(and_dcpl_15),
      .plm_conf_compute_rsci_bawt(plm_conf_compute_rsci_bawt),
      .plm_conf_compute_rsci_iswt0(reg_plm_conf_store_rsci_ivld_core_psct_cse),
      .plm_conf_compute_rsci_wen_comp(plm_conf_compute_rsci_wen_comp),
      .plm_conf_compute_rsci_irdy_oreg(plm_conf_compute_rsci_irdy_oreg),
      .plm_conf_compute_rsci_idat(reg_plm_conf_compute_rsci_idat_cse)
    );
  esp_acc_softmax_cxx_catapult_config_core_plm_conf_store_rsci config_core_plm_conf_store_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_store_rsc_dat(plm_conf_store_rsc_dat),
      .plm_conf_store_rsc_vld(plm_conf_store_rsc_vld),
      .plm_conf_store_rsc_rdy(plm_conf_store_rsc_rdy),
      .core_wen(core_wen),
      .plm_conf_store_rsci_irdy(plm_conf_store_rsci_irdy),
      .plm_conf_store_rsci_oswt_unreg(and_dcpl_15),
      .plm_conf_store_rsci_bawt(plm_conf_store_rsci_bawt),
      .plm_conf_store_rsci_iswt0(reg_plm_conf_store_rsci_ivld_core_psct_cse),
      .plm_conf_store_rsci_wen_comp(plm_conf_store_rsci_wen_comp),
      .plm_conf_store_rsci_irdy_oreg(plm_conf_store_rsci_irdy_oreg),
      .plm_conf_store_rsci_idat(plm_conf_store_rsci_idat)
    );
  esp_acc_softmax_cxx_catapult_config_core_done_rsci config_core_done_rsci_inst (
      .clk(clk),
      .rst(rst),
      .done_rsc_rdy(done_rsc_rdy),
      .done_rsc_vld(done_rsc_vld),
      .core_wen(core_wen),
      .done_rsci_oswt_unreg(and_dcpl_16),
      .done_rsci_bawt(done_rsci_bawt),
      .done_rsci_iswt0(reg_done_rsci_ivld_core_psct_cse),
      .done_rsci_wen_comp(done_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_catapult_config_core_staller config_core_staller_inst (
      .core_wen(core_wen),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .plm_conf_load_rsci_wen_comp(plm_conf_load_rsci_wen_comp),
      .plm_conf_compute_rsci_wen_comp(plm_conf_compute_rsci_wen_comp),
      .plm_conf_store_rsci_wen_comp(plm_conf_store_rsci_wen_comp),
      .done_rsci_wen_comp(done_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_catapult_config_core_core_fsm config_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  assign or_cse = done_rsci_bawt | (~ reg_done_rsci_ivld_core_psct_cse);
  assign and_dcpl_1 = plm_conf_load_rsci_bawt & plm_conf_compute_rsci_bawt;
  assign and_dcpl_9 = reg_done_rsci_ivld_core_psct_cse & (~ done_rsci_bawt);
  assign or_dcpl_3 = ~(plm_conf_load_rsci_bawt & plm_conf_compute_rsci_bawt);
  assign or_dcpl_5 = ((or_dcpl_3 | (~ plm_conf_store_rsci_bawt)) & reg_plm_conf_store_rsci_ivld_core_psct_cse)
      | and_dcpl_9 | (~ conf_info_rsci_bawt);
  assign and_dcpl_15 = or_cse & plm_conf_load_rsci_bawt & plm_conf_compute_rsci_bawt
      & plm_conf_store_rsci_bawt & reg_plm_conf_store_rsci_ivld_core_psct_cse;
  assign and_dcpl_16 = reg_done_rsci_ivld_core_psct_cse & done_rsci_bawt;
  assign or_dcpl_6 = ~(plm_conf_store_rsci_bawt & reg_plm_conf_store_rsci_ivld_core_psct_cse);
  assign and_dcpl_17 = (or_dcpl_3 | or_dcpl_6) & and_dcpl_16;
  assign and_dcpl_20 = or_cse & and_dcpl_1 & plm_conf_store_rsci_bawt & reg_plm_conf_store_rsci_ivld_core_psct_cse
      & (~ conf_info_rsci_bawt);
  assign or_tmp_8 = (~((~(and_dcpl_1 & plm_conf_store_rsci_bawt)) & reg_plm_conf_store_rsci_ivld_core_psct_cse))
      & or_cse & conf_info_rsci_bawt & (fsm_output[1]);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_conf_info_rsci_iswt0_cse <= 1'b0;
    end
    else if ( core_wen & ((conf_info_rsci_bawt & (plm_conf_load_rsci_bawt | (~ reg_plm_conf_store_rsci_ivld_core_psct_cse))
        & (plm_conf_compute_rsci_bawt | (~ reg_plm_conf_store_rsci_ivld_core_psct_cse))
        & (plm_conf_store_rsci_bawt | (~ reg_plm_conf_store_rsci_ivld_core_psct_cse))
        & or_cse) | (fsm_output[0])) ) begin
      reg_conf_info_rsci_iswt0_cse <= 1'b1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_done_rsci_ivld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_15 | and_dcpl_17) ) begin
      reg_done_rsci_ivld_core_psct_cse <= ~ and_dcpl_17;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_conf_store_rsci_idat <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_5 | ((and_dcpl_9 | or_dcpl_3 | or_dcpl_6 | (~
        conf_info_rsci_bawt)) & (fsm_output[0])))) ) begin
      plm_conf_store_rsci_idat <= conf_info_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_plm_conf_store_rsci_ivld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & (or_tmp_8 | and_dcpl_20) ) begin
      reg_plm_conf_store_rsci_ivld_core_psct_cse <= ~ and_dcpl_20;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_plm_conf_compute_rsci_idat_cse <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_5 | (fsm_output[0]))) ) begin
      reg_plm_conf_compute_rsci_idat_cse <= conf_info_rsci_idat_mxwt;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load_core (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, plm_in_rsc_dat,
      plm_in_rsc_vld, plm_in_rsc_rdy, dma_read_ctrl_rsc_dat, dma_read_ctrl_rsc_vld,
      dma_read_ctrl_rsc_rdy, dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy,
      done_rsc_rdy, done_rsc_vld
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  output [511:0] plm_in_rsc_dat;
  output plm_in_rsc_vld;
  input plm_in_rsc_rdy;
  output [66:0] dma_read_ctrl_rsc_dat;
  output dma_read_ctrl_rsc_vld;
  input dma_read_ctrl_rsc_rdy;
  input [63:0] dma_read_chnl_rsc_dat;
  input dma_read_chnl_rsc_vld;
  output dma_read_chnl_rsc_rdy;
  input done_rsc_rdy;
  output done_rsc_vld;


  // Interconnect Declarations
  wire core_wen;
  wire conf_info_rsci_bawt;
  reg conf_info_rsci_iswt0;
  wire core_wten;
  wire conf_info_rsci_wen_comp;
  reg conf_info_rsci_irdy_core_psct;
  wire conf_info_rsci_ivld;
  wire conf_info_rsci_ivld_oreg;
  wire [31:0] conf_info_rsci_idat_mxwt;
  wire plm_in_rsci_irdy;
  wire plm_in_rsci_bawt;
  wire plm_in_rsci_wen_comp;
  wire plm_in_rsci_irdy_oreg;
  wire dma_read_ctrl_rsci_bawt;
  wire dma_read_ctrl_rsci_irdy_mxwt;
  wire dma_read_chnl_rsci_bawt;
  wire dma_read_chnl_rsci_wen_comp;
  wire [31:0] dma_read_chnl_rsci_idat_mxwt;
  wire done_rsci_bawt;
  wire done_rsci_wen_comp;
  reg [31:0] plm_in_rsci_idat_511_480;
  reg [31:0] plm_in_rsci_idat_479_448;
  reg [31:0] plm_in_rsci_idat_447_416;
  reg [31:0] plm_in_rsci_idat_415_384;
  reg [31:0] plm_in_rsci_idat_383_352;
  reg [31:0] plm_in_rsci_idat_351_320;
  reg [31:0] plm_in_rsci_idat_319_288;
  reg [31:0] plm_in_rsci_idat_287_256;
  reg [31:0] plm_in_rsci_idat_255_224;
  reg [31:0] plm_in_rsci_idat_223_192;
  reg [31:0] plm_in_rsci_idat_191_160;
  reg [31:0] plm_in_rsci_idat_159_128;
  reg [31:0] plm_in_rsci_idat_127_96;
  reg [31:0] plm_in_rsci_idat_95_64;
  reg [31:0] plm_in_rsci_idat_63_32;
  reg [31:0] plm_in_rsci_idat_31_0;
  reg [3:0] dma_read_ctrl_rsci_idat_7_4;
  wire [1:0] fsm_output;
  wire [4:0] LOAD_BATCH_LOOP_acc_1_tmp;
  wire [5:0] nl_LOAD_BATCH_LOOP_acc_1_tmp;
  wire [4:0] LOAD_LOOP_acc_1_tmp;
  wire [5:0] nl_LOAD_LOOP_acc_1_tmp;
  wire and_tmp;
  wire or_tmp_17;
  wire mux_tmp_8;
  wire and_tmp_5;
  wire or_tmp_100;
  wire mux_tmp_93;
  wire mux_tmp_98;
  wire mux_tmp_100;
  wire mux_tmp_104;
  wire and_dcpl_3;
  wire and_tmp_40;
  wire mux_tmp_117;
  wire and_tmp_46;
  wire or_dcpl_2;
  wire or_dcpl_3;
  wire and_tmp_51;
  wire and_tmp_52;
  wire mux_tmp_135;
  wire mux_tmp_136;
  wire and_tmp_53;
  wire mux_tmp_137;
  wire and_tmp_54;
  wire mux_tmp_140;
  wire or_tmp_153;
  wire mux_tmp_146;
  wire and_dcpl_8;
  wire and_dcpl_10;
  wire mux_tmp_171;
  wire or_dcpl_4;
  wire or_tmp_177;
  wire mux_tmp_179;
  wire and_dcpl_12;
  wire and_dcpl_17;
  wire and_dcpl_19;
  wire and_dcpl_20;
  wire and_dcpl_22;
  wire and_dcpl_25;
  wire and_dcpl_26;
  wire or_dcpl_12;
  wire or_dcpl_13;
  wire and_dcpl_47;
  wire and_dcpl_68;
  wire not_tmp_95;
  wire and_dcpl_89;
  wire not_tmp_96;
  wire and_dcpl_106;
  wire and_dcpl_109;
  wire and_dcpl_111;
  wire and_dcpl_112;
  wire and_dcpl_113;
  wire and_dcpl_114;
  wire and_tmp_78;
  wire mux_tmp_189;
  wire or_tmp_201;
  wire and_dcpl_116;
  wire and_dcpl_118;
  wire and_dcpl_119;
  wire and_dcpl_121;
  wire and_dcpl_133;
  wire and_dcpl_139;
  wire and_dcpl_144;
  wire and_dcpl_149;
  wire or_tmp_232;
  wire or_dcpl_33;
  wire and_dcpl_164;
  wire or_tmp_244;
  wire and_tmp_86;
  wire or_tmp_246;
  wire and_dcpl_166;
  wire or_dcpl_39;
  wire or_tmp_248;
  wire or_tmp_250;
  wire not_tmp_134;
  wire or_tmp_253;
  wire not_tmp_136;
  wire or_tmp_257;
  wire not_tmp_143;
  wire or_tmp_261;
  wire not_tmp_145;
  wire and_dcpl_167;
  wire not_tmp_156;
  wire and_dcpl_177;
  wire or_tmp_312;
  wire and_320_cse;
  wire and_354_cse;
  wire and_356_cse;
  wire main_stage_en_4;
  wire lfst_exit_LOAD_LOOP_lpi_1_dfm_1_mx0w0;
  wire lfst_exit_LOAD_LOOP_lpi_1_dfm_0_mx0w0;
  wire lfst_exit_LOAD_LOOP_lpi_1_1_mx0;
  wire lfst_exit_LOAD_LOOP_lpi_1_0_mx0;
  wire exitL_exit_LOAD_LOOP_lpi_1_dfm_mx1;
  wire exitL_exitL_exit_LOAD_LOOP_lpi_1_dfm_1;
  reg exit_LOAD_BATCH_LOOP_lpi_1_dfm_3;
  reg exitL_exit_LOAD_BATCH_LOOP_sva;
  reg LOAD_BATCH_LOOP_asn_itm;
  reg lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1;
  reg LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1;
  reg main_stage_v_1;
  reg lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0;
  wire lfst_exit_LOAD_LOOP_lpi_1_dfm_3_1_1;
  wire lfst_exit_LOAD_LOOP_lpi_1_dfm_3_0_1;
  reg LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  reg lfst_exit_LOAD_LOOP_lpi_1_dfm_2_1_1;
  reg lfst_exit_LOAD_LOOP_lpi_1_dfm_1_1;
  wire LOAD_LOOP_and_60_ssc_1;
  reg lfst_exit_LOAD_LOOP_lpi_1_dfm_1_0;
  reg LOAD_LOOP_or_tmp_1;
  wire LOAD_LOOP_and_stg_2_0_sva_1;
  wire LOAD_LOOP_and_stg_2_6_sva_1;
  wire LOAD_LOOP_and_stg_2_1_sva_1;
  wire LOAD_LOOP_and_stg_2_5_sva_1;
  wire LOAD_LOOP_and_stg_2_2_sva_1;
  wire LOAD_LOOP_and_stg_2_4_sva_1;
  wire LOAD_LOOP_and_stg_2_3_sva_1;
  wire LOAD_LOOP_and_stg_1_0_sva_1;
  wire LOAD_LOOP_and_stg_1_1_sva_1;
  wire LOAD_LOOP_and_stg_1_2_sva_1;
  reg LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm_2;
  reg lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1;
  reg lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0;
  reg LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2;
  reg main_stage_v_2;
  reg exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_3;
  reg main_stage_v_3;
  reg [3:0] LOAD_LOOP_i_4_0_sva_1_1_3_0;
  reg [3:0] LOAD_LOOP_i_4_0_lpi_1_3_0;
  reg LOAD_LOOP_equal_tmp_1;
  reg lfst_exit_LOAD_LOOP_lpi_1_1;
  reg lfst_exit_LOAD_LOOP_lpi_1_0;
  reg LOAD_BATCH_LOOP_if_asn_sft_lpi_1;
  reg exitL_exit_LOAD_LOOP_lpi_1_dfm;
  reg LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm_1;
  reg exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_2;
  reg LOAD_LOOP_and_26_psp;
  reg LOAD_LOOP_and_25_psp;
  reg LOAD_LOOP_and_24_psp;
  reg LOAD_LOOP_and_23_psp;
  reg LOAD_LOOP_and_22_psp;
  reg LOAD_LOOP_and_21_psp;
  reg LOAD_LOOP_and_20_psp;
  reg LOAD_LOOP_and_19_psp;
  reg LOAD_LOOP_and_18_psp;
  reg LOAD_LOOP_and_17_psp;
  reg LOAD_LOOP_and_16_psp;
  reg LOAD_LOOP_and_15_psp;
  reg LOAD_LOOP_and_14_psp;
  reg LOAD_LOOP_and_13_psp;
  reg LOAD_LOOP_and_12_psp;
  reg reg_done_rsci_ivld_core_psct_cse;
  reg reg_dma_read_chnl_rsci_irdy_core_psct_cse;
  reg reg_dma_read_ctrl_rsci_ivld_core_psct_cse;
  reg reg_plm_in_rsci_ivld_core_psct_cse;
  wire or_50_cse;
  wire or_76_cse;
  wire nor_57_cse;
  wire or_309_cse;
  wire or_303_cse;
  wire and_410_cse;
  wire LOAD_LOOP_and_63_cse;
  wire and_440_cse;
  wire or_446_cse;
  wire or_128_cse;
  wire or_19_cse;
  wire or_131_cse;
  wire or_155_cse;
  wire nor_101_cse;
  wire and_281_cse;
  wire nor_74_cse;
  wire mux_111_cse;
  wire nor_27_cse;
  wire and_59_cse;
  wire and_426_cse;
  wire mux_238_cse;
  wire and_84_cse;
  wire mux_276_cse;
  wire and_10_cse;
  wire and_11_cse;
  wire or_462_tmp;
  wire LOAD_BATCH_LOOP_if_and_1_tmp;
  wire and_451_cse;
  reg [31:0] LOAD_BATCH_LOOP_plm_tmp_data_7_lpi_1;
  reg [31:0] LOAD_BATCH_LOOP_plm_tmp_data_8_lpi_1;
  reg [31:0] LOAD_BATCH_LOOP_plm_tmp_data_6_lpi_1;
  reg [31:0] LOAD_BATCH_LOOP_plm_tmp_data_9_lpi_1;
  reg [31:0] LOAD_BATCH_LOOP_plm_tmp_data_5_lpi_1;
  reg [31:0] LOAD_BATCH_LOOP_plm_tmp_data_10_lpi_1;
  reg [31:0] LOAD_BATCH_LOOP_plm_tmp_data_4_lpi_1;
  reg [31:0] LOAD_BATCH_LOOP_plm_tmp_data_11_lpi_1;
  reg [31:0] LOAD_BATCH_LOOP_plm_tmp_data_3_lpi_1;
  reg [31:0] LOAD_BATCH_LOOP_plm_tmp_data_12_lpi_1;
  reg [31:0] LOAD_BATCH_LOOP_plm_tmp_data_2_lpi_1;
  reg [31:0] LOAD_BATCH_LOOP_plm_tmp_data_13_lpi_1;
  reg [31:0] LOAD_BATCH_LOOP_plm_tmp_data_1_lpi_1;
  reg [31:0] LOAD_BATCH_LOOP_plm_tmp_data_14_lpi_1;
  reg [31:0] LOAD_BATCH_LOOP_plm_tmp_data_0_lpi_1;
  reg [31:0] batch_lpi_1_dfm;
  reg LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm;
  reg exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_1;
  reg [3:0] LOAD_BATCH_LOOP_b_4_0_lpi_1_3_0;
  reg lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1;
  reg lfst_exit_LOAD_LOOP_lpi_1_dfm_st_0;
  wire conf_info_rsci_iswt0_mx0c1;
  wire [3:0] LOAD_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_mx0w0;
  wire plm_in_rsci_idat_31_0_mx0c1;
  wire plm_in_rsci_idat_63_32_mx0c1;
  wire plm_in_rsci_idat_95_64_mx0c1;
  wire plm_in_rsci_idat_127_96_mx0c1;
  wire plm_in_rsci_idat_159_128_mx0c1;
  wire plm_in_rsci_idat_191_160_mx0c1;
  wire plm_in_rsci_idat_223_192_mx0c1;
  wire plm_in_rsci_idat_255_224_mx0c1;
  wire plm_in_rsci_idat_287_256_mx0c1;
  wire plm_in_rsci_idat_319_288_mx0c1;
  wire plm_in_rsci_idat_351_320_mx0c1;
  wire plm_in_rsci_idat_383_352_mx0c1;
  wire plm_in_rsci_idat_415_384_mx0c1;
  wire plm_in_rsci_idat_447_416_mx0c1;
  wire plm_in_rsci_idat_479_448_mx0c1;
  wire [3:0] LOAD_LOOP_i_4_0_lpi_1_3_0_mx0w0;
  wire exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_mx1;
  wire LOAD_BATCH_LOOP_b_4_0_lpi_1_3_0_mx0c1;
  wire LOAD_BATCH_LOOP_if_asn_sft_lpi_1_mx0;
  wire main_stage_v_1_mx0c1;
  wire lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1_mx0c1;
  wire LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1;
  wire main_stage_v_2_mx0c1;
  wire main_stage_v_3_mx0c1;
  wire exit_LOAD_BATCH_LOOP_lpi_1_dfm_4;
  wire LOAD_LOOP_and_cse;
  wire LOAD_LOOP_i_and_2_cse;
  wire LOAD_LOOP_and_91_cse;
  wire LOAD_LOOP_and_93_cse;
  wire LOAD_BATCH_LOOP_if_acc_itm_32_1;
  wire LOAD_LOOP_i_and_4_cse;

  wire[0:0] LOAD_LOOP_mux_68_nl;
  wire[0:0] mux_217_nl;
  wire[0:0] mux_224_nl;
  wire[0:0] nor_81_nl;
  wire[0:0] nor_82_nl;
  wire[0:0] mux_223_nl;
  wire[0:0] and_246_nl;
  wire[0:0] mux_240_nl;
  wire[0:0] mux_242_nl;
  wire[0:0] mux_241_nl;
  wire[0:0] and_264_nl;
  wire[0:0] mux_244_nl;
  wire[0:0] mux_243_nl;
  wire[0:0] and_265_nl;
  wire[0:0] mux_246_nl;
  wire[0:0] and_266_nl;
  wire[0:0] mux_245_nl;
  wire[0:0] mux_248_nl;
  wire[0:0] and_267_nl;
  wire[0:0] mux_247_nl;
  wire[0:0] mux_250_nl;
  wire[0:0] mux_249_nl;
  wire[0:0] and_268_nl;
  wire[0:0] mux_252_nl;
  wire[0:0] mux_251_nl;
  wire[0:0] and_269_nl;
  wire[0:0] mux_254_nl;
  wire[0:0] and_270_nl;
  wire[0:0] mux_253_nl;
  wire[0:0] mux_256_nl;
  wire[0:0] and_271_nl;
  wire[0:0] mux_255_nl;
  wire[0:0] mux_258_nl;
  wire[0:0] mux_257_nl;
  wire[0:0] and_272_nl;
  wire[0:0] mux_260_nl;
  wire[0:0] mux_259_nl;
  wire[0:0] and_273_nl;
  wire[0:0] mux_262_nl;
  wire[0:0] and_274_nl;
  wire[0:0] mux_261_nl;
  wire[0:0] mux_264_nl;
  wire[0:0] and_275_nl;
  wire[0:0] mux_263_nl;
  wire[0:0] mux_266_nl;
  wire[0:0] mux_265_nl;
  wire[0:0] and_276_nl;
  wire[0:0] mux_268_nl;
  wire[0:0] mux_267_nl;
  wire[0:0] and_277_nl;
  wire[0:0] mux_270_nl;
  wire[0:0] and_278_nl;
  wire[0:0] mux_269_nl;
  wire[0:0] mux_275_nl;
  wire[0:0] and_290_nl;
  wire[0:0] and_289_nl;
  wire[0:0] and_287_nl;
  wire[0:0] mux_294_nl;
  wire[0:0] or_387_nl;
  wire[0:0] or_386_nl;
  wire[0:0] LOAD_LOOP_mux_22_nl;
  wire[0:0] mux_297_nl;
  wire[0:0] or_395_nl;
  wire[0:0] mux_296_nl;
  wire[0:0] and_407_nl;
  wire[0:0] mux_295_nl;
  wire[0:0] LOAD_BATCH_LOOP_not_12_nl;
  wire[0:0] nor_nl;
  wire[0:0] and_453_nl;
  wire[0:0] LOAD_LOOP_mux_67_nl;
  wire[0:0] and_243_nl;
  wire[0:0] mux_222_nl;
  wire[0:0] or_275_nl;
  wire[0:0] mux_221_nl;
  wire[0:0] and_412_nl;
  wire[0:0] LOAD_BATCH_LOOP_if_LOAD_BATCH_LOOP_if_LOAD_BATCH_LOOP_if_or_nl;
  wire[32:0] LOAD_BATCH_LOOP_if_acc_nl;
  wire[33:0] nl_LOAD_BATCH_LOOP_if_acc_nl;
  wire[31:0] mux_7_nl;
  wire[3:0] LOAD_LOOP_i_mux_nl;
  wire[0:0] LOAD_LOOP_mux_66_nl;
  wire[0:0] or_147_nl;
  wire[0:0] or_150_nl;
  wire[0:0] nand_53_nl;
  wire[0:0] mux_112_nl;
  wire[0:0] and_54_nl;
  wire[0:0] and_53_nl;
  wire[0:0] or_172_nl;
  wire[0:0] mux_148_nl;
  wire[0:0] mux_147_nl;
  wire[0:0] mux_154_nl;
  wire[0:0] mux_187_nl;
  wire[0:0] mux_186_nl;
  wire[0:0] and_86_nl;
  wire[0:0] and_85_nl;
  wire[0:0] or_201_nl;
  wire[0:0] mux_185_nl;
  wire[0:0] mux_184_nl;
  wire[0:0] nor_109_nl;
  wire[0:0] mux_183_nl;
  wire[0:0] mux_182_nl;
  wire[0:0] or_200_nl;
  wire[0:0] mux_181_nl;
  wire[0:0] mux_200_nl;
  wire[0:0] or_237_nl;
  wire[0:0] mux_199_nl;
  wire[0:0] and_413_nl;
  wire[0:0] mux_204_nl;
  wire[0:0] mux_203_nl;
  wire[0:0] mux_202_nl;
  wire[0:0] mux_201_nl;
  wire[0:0] and_206_nl;
  wire[0:0] or_242_nl;
  wire[0:0] mux_216_nl;
  wire[0:0] mux_215_nl;
  wire[0:0] and_236_nl;
  wire[0:0] mux_214_nl;
  wire[0:0] mux_236_nl;
  wire[0:0] nor_114_nl;
  wire[0:0] nor_115_nl;
  wire[0:0] mux_237_nl;
  wire[0:0] and_261_nl;
  wire[0:0] and_260_nl;
  wire[0:0] and_258_nl;
  wire[0:0] mux_239_nl;
  wire[0:0] and_262_nl;
  wire[0:0] mux_125_nl;
  wire[0:0] mux_124_nl;
  wire[0:0] mux_123_nl;
  wire[0:0] mux_122_nl;
  wire[0:0] mux_121_nl;
  wire[0:0] mux_120_nl;
  wire[0:0] mux_119_nl;
  wire[0:0] mux_118_nl;
  wire[0:0] mux_117_nl;
  wire[0:0] mux_116_nl;
  wire[0:0] and_424_nl;
  wire[0:0] mux_115_nl;
  wire[0:0] mux_114_nl;
  wire[0:0] mux_106_nl;
  wire[0:0] mux_105_nl;
  wire[0:0] mux_104_nl;
  wire[0:0] mux_103_nl;
  wire[0:0] mux_143_nl;
  wire[0:0] mux_142_nl;
  wire[0:0] mux_141_nl;
  wire[0:0] and_61_nl;
  wire[0:0] and_60_nl;
  wire[0:0] mux_140_nl;
  wire[0:0] mux_139_nl;
  wire[0:0] mux_138_nl;
  wire[0:0] mux_137_nl;
  wire[0:0] mux_136_nl;
  wire[0:0] or_162_nl;
  wire[0:0] mux_135_nl;
  wire[0:0] mux_134_nl;
  wire[0:0] mux_133_nl;
  wire[0:0] mux_132_nl;
  wire[0:0] mux_130_nl;
  wire[0:0] mux_129_nl;
  wire[0:0] mux_128_nl;
  wire[0:0] mux_127_nl;
  wire[0:0] mux_274_nl;
  wire[0:0] mux_273_nl;
  wire[0:0] nor_86_nl;
  wire[0:0] mux_280_nl;
  wire[0:0] mux_279_nl;
  wire[0:0] and_418_nl;
  wire[0:0] nor_84_nl;
  wire[0:0] mux_278_nl;
  wire[0:0] mux_277_nl;
  wire[0:0] and_419_nl;
  wire[0:0] and_420_nl;
  wire[0:0] nor_85_nl;
  wire[0:0] mux_160_nl;
  wire[0:0] mux_159_nl;
  wire[0:0] mux_158_nl;
  wire[0:0] mux_157_nl;
  wire[0:0] mux_156_nl;
  wire[0:0] mux_153_nl;
  wire[0:0] mux_152_nl;
  wire[0:0] mux_151_nl;
  wire[0:0] mux_150_nl;
  wire[0:0] mux_189_nl;
  wire[0:0] or_220_nl;
  wire[0:0] mux_190_nl;
  wire[0:0] or_222_nl;
  wire[0:0] mux_191_nl;
  wire[0:0] or_223_nl;
  wire[0:0] mux_192_nl;
  wire[0:0] or_224_nl;
  wire[0:0] mux_193_nl;
  wire[0:0] mux_194_nl;
  wire[0:0] and_416_nl;
  wire[0:0] mux_195_nl;
  wire[0:0] mux_233_nl;
  wire[0:0] mux_232_nl;
  wire[0:0] mux_231_nl;
  wire[0:0] mux_300_nl;
  wire[0:0] mux_228_nl;
  wire[0:0] and_250_nl;
  wire[0:0] mux_227_nl;
  wire[0:0] mux_226_nl;
  wire[0:0] mux_225_nl;
  wire[0:0] or_282_nl;
  wire[0:0] mux_286_nl;
  wire[0:0] or_377_nl;
  wire[0:0] mux_285_nl;
  wire[0:0] or_376_nl;
  wire[0:0] or_375_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [0:0] nl_load_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg;
  assign nl_load_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg = and_dcpl_139
      & and_dcpl_3 & (fsm_output[1]);
  wire [0:0] nl_load_core_plm_in_rsci_inst_plm_in_rsci_oswt_unreg;
  assign nl_load_core_plm_in_rsci_inst_plm_in_rsci_oswt_unreg = or_dcpl_3 & and_dcpl_111
      & LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm_2 & (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2)
      & plm_in_rsci_bawt & main_stage_v_2;
  wire [511:0] nl_load_core_plm_in_rsci_inst_plm_in_rsci_idat;
  assign nl_load_core_plm_in_rsci_inst_plm_in_rsci_idat = {plm_in_rsci_idat_511_480
      , plm_in_rsci_idat_479_448 , plm_in_rsci_idat_447_416 , plm_in_rsci_idat_415_384
      , plm_in_rsci_idat_383_352 , plm_in_rsci_idat_351_320 , plm_in_rsci_idat_319_288
      , plm_in_rsci_idat_287_256 , plm_in_rsci_idat_255_224 , plm_in_rsci_idat_223_192
      , plm_in_rsci_idat_191_160 , plm_in_rsci_idat_159_128 , plm_in_rsci_idat_127_96
      , plm_in_rsci_idat_95_64 , plm_in_rsci_idat_63_32 , plm_in_rsci_idat_31_0};
  wire [0:0] nl_load_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_oswt_unreg;
  assign nl_load_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_oswt_unreg = and_dcpl_19
      & dma_read_ctrl_rsci_bawt & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1) & and_dcpl_22;
  wire [66:0] nl_load_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat;
  assign nl_load_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat = {59'b01100000000000000000000000000010000000000000000000000000000
      , dma_read_ctrl_rsci_idat_7_4 , 4'b0000};
  wire [0:0] nl_load_core_dma_read_chnl_rsci_inst_dma_read_chnl_rsci_oswt_unreg;
  assign nl_load_core_dma_read_chnl_rsci_inst_dma_read_chnl_rsci_oswt_unreg = and_dcpl_19
      & and_dcpl_119;
  esp_acc_softmax_cxx_catapult_load_core_wait_dp load_core_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsci_ivld(conf_info_rsci_ivld),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg),
      .plm_in_rsci_irdy(plm_in_rsci_irdy),
      .plm_in_rsci_irdy_oreg(plm_in_rsci_irdy_oreg)
    );
  esp_acc_softmax_cxx_catapult_load_core_conf_info_rsci load_core_conf_info_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .core_wen(core_wen),
      .conf_info_rsci_oswt_unreg(nl_load_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg[0:0]),
      .conf_info_rsci_bawt(conf_info_rsci_bawt),
      .conf_info_rsci_iswt0(conf_info_rsci_iswt0),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_irdy_core_psct(conf_info_rsci_irdy_core_psct),
      .conf_info_rsci_ivld(conf_info_rsci_ivld),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_catapult_load_core_plm_in_rsci load_core_plm_in_rsci_inst (
      .clk(clk),
      .rst(rst),
      .plm_in_rsc_dat(plm_in_rsc_dat),
      .plm_in_rsc_vld(plm_in_rsc_vld),
      .plm_in_rsc_rdy(plm_in_rsc_rdy),
      .core_wen(core_wen),
      .plm_in_rsci_irdy(plm_in_rsci_irdy),
      .plm_in_rsci_oswt_unreg(nl_load_core_plm_in_rsci_inst_plm_in_rsci_oswt_unreg[0:0]),
      .plm_in_rsci_bawt(plm_in_rsci_bawt),
      .plm_in_rsci_iswt0(reg_plm_in_rsci_ivld_core_psct_cse),
      .plm_in_rsci_wen_comp(plm_in_rsci_wen_comp),
      .plm_in_rsci_irdy_oreg(plm_in_rsci_irdy_oreg),
      .plm_in_rsci_idat(nl_load_core_plm_in_rsci_inst_plm_in_rsci_idat[511:0])
    );
  esp_acc_softmax_cxx_catapult_load_core_dma_read_ctrl_rsci load_core_dma_read_ctrl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_read_ctrl_rsc_dat(dma_read_ctrl_rsc_dat),
      .dma_read_ctrl_rsc_vld(dma_read_ctrl_rsc_vld),
      .dma_read_ctrl_rsc_rdy(dma_read_ctrl_rsc_rdy),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dma_read_ctrl_rsci_oswt_unreg(nl_load_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_oswt_unreg[0:0]),
      .dma_read_ctrl_rsci_bawt(dma_read_ctrl_rsci_bawt),
      .dma_read_ctrl_rsci_iswt0(reg_dma_read_ctrl_rsci_ivld_core_psct_cse),
      .dma_read_ctrl_rsci_irdy_mxwt(dma_read_ctrl_rsci_irdy_mxwt),
      .dma_read_ctrl_rsci_idat(nl_load_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat[66:0])
    );
  esp_acc_softmax_cxx_catapult_load_core_dma_read_chnl_rsci load_core_dma_read_chnl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_read_chnl_rsc_dat(dma_read_chnl_rsc_dat),
      .dma_read_chnl_rsc_vld(dma_read_chnl_rsc_vld),
      .dma_read_chnl_rsc_rdy(dma_read_chnl_rsc_rdy),
      .core_wen(core_wen),
      .dma_read_chnl_rsci_oswt_unreg(nl_load_core_dma_read_chnl_rsci_inst_dma_read_chnl_rsci_oswt_unreg[0:0]),
      .dma_read_chnl_rsci_bawt(dma_read_chnl_rsci_bawt),
      .dma_read_chnl_rsci_iswt0(reg_dma_read_chnl_rsci_irdy_core_psct_cse),
      .dma_read_chnl_rsci_wen_comp(dma_read_chnl_rsci_wen_comp),
      .dma_read_chnl_rsci_idat_mxwt(dma_read_chnl_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_catapult_load_core_done_rsci load_core_done_rsci_inst (
      .clk(clk),
      .rst(rst),
      .done_rsc_rdy(done_rsc_rdy),
      .done_rsc_vld(done_rsc_vld),
      .core_wen(core_wen),
      .done_rsci_oswt_unreg(and_dcpl_109),
      .done_rsci_bawt(done_rsci_bawt),
      .done_rsci_iswt0(reg_done_rsci_ivld_core_psct_cse),
      .done_rsci_wen_comp(done_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_catapult_load_core_staller load_core_staller_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .plm_in_rsci_wen_comp(plm_in_rsci_wen_comp),
      .dma_read_chnl_rsci_wen_comp(dma_read_chnl_rsci_wen_comp),
      .done_rsci_wen_comp(done_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_catapult_load_core_core_fsm load_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  assign and_440_cse = lfst_exit_LOAD_LOOP_lpi_1_dfm_1_1 & lfst_exit_LOAD_LOOP_lpi_1_dfm_1_0;
  assign LOAD_LOOP_i_and_2_cse = core_wen & (~((~ mux_tmp_136) | and_dcpl_10 | (~
      main_stage_v_1)));
  assign or_50_cse = (~ LOAD_BATCH_LOOP_asn_itm) | conf_info_rsci_bawt;
  assign nor_101_cse = ~(exit_LOAD_BATCH_LOOP_lpi_1_dfm_3 | exitL_exit_LOAD_BATCH_LOOP_sva);
  assign LOAD_LOOP_and_63_cse = core_wen & (~ (fsm_output[0]));
  assign or_446_cse = exitL_exit_LOAD_BATCH_LOOP_sva | exit_LOAD_BATCH_LOOP_lpi_1_dfm_3
      | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign LOAD_LOOP_and_cse = core_wen & (~ or_dcpl_4);
  assign or_76_cse = exitL_exit_LOAD_BATCH_LOOP_sva | exit_LOAD_BATCH_LOOP_lpi_1_dfm_3;
  assign or_303_cse = (LOAD_LOOP_i_4_0_lpi_1_3_0[1:0]!=2'b00);
  assign or_309_cse = (LOAD_LOOP_i_4_0_lpi_1_3_0[1:0]!=2'b10);
  assign nor_57_cse = ~((LOAD_LOOP_i_4_0_lpi_1_3_0[1:0]!=2'b01));
  assign and_410_cse = (LOAD_LOOP_i_4_0_lpi_1_3_0[1:0]==2'b11);
  assign LOAD_LOOP_i_and_4_cse = core_wen & (and_dcpl_167 | and_dcpl_149);
  assign and_290_nl = dma_read_ctrl_rsci_bawt & and_281_cse;
  assign and_289_nl = or_tmp_17 & and_281_cse;
  assign mux_275_nl = MUX_s_1_2_2(and_290_nl, and_289_nl, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign and_287_nl = ((~ or_446_cse) | LOAD_BATCH_LOOP_if_acc_itm_32_1) & or_19_cse;
  assign mux_276_cse = MUX_s_1_2_2(mux_275_nl, and_287_nl, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign or_387_nl = LOAD_BATCH_LOOP_if_asn_sft_lpi_1 | exitL_exit_LOAD_LOOP_lpi_1_dfm;
  assign or_386_nl = or_tmp_100 | (~ or_tmp_153);
  assign mux_294_nl = MUX_s_1_2_2(or_387_nl, or_386_nl, main_stage_v_1);
  assign LOAD_LOOP_and_91_cse = LOAD_LOOP_and_63_cse & (~(mux_294_nl | or_76_cse));
  assign LOAD_LOOP_and_93_cse = LOAD_LOOP_and_63_cse & (~(lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0
      | (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1) | or_131_cse));
  assign or_128_cse = (~ lfst_exit_LOAD_LOOP_lpi_1_1) | lfst_exit_LOAD_LOOP_lpi_1_0
      | LOAD_BATCH_LOOP_if_asn_sft_lpi_1 | exitL_exit_LOAD_LOOP_lpi_1_dfm;
  assign LOAD_BATCH_LOOP_not_12_nl = ~ exitL_exit_LOAD_BATCH_LOOP_sva;
  assign LOAD_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_mx0w0 = MUX_v_4_2_2(4'b0000, LOAD_BATCH_LOOP_b_4_0_lpi_1_3_0,
      LOAD_BATCH_LOOP_not_12_nl);
  assign and_451_cse = LOAD_LOOP_or_tmp_1 & (~ dma_read_ctrl_rsci_irdy_mxwt);
  assign or_462_tmp = and_451_cse | and_440_cse | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign LOAD_BATCH_LOOP_if_and_1_tmp = LOAD_LOOP_equal_tmp_1 & (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign nor_nl = ~(LOAD_BATCH_LOOP_if_and_1_tmp | or_462_tmp);
  assign and_453_nl = LOAD_BATCH_LOOP_if_and_1_tmp & (~ or_462_tmp);
  assign LOAD_LOOP_i_4_0_lpi_1_3_0_mx0w0 = MUX1HOT_v_4_3_2((signext_4_1(~ dma_read_ctrl_rsci_irdy_mxwt)),
      LOAD_LOOP_i_4_0_sva_1_1_3_0, LOAD_LOOP_i_4_0_lpi_1_3_0, {nor_nl , and_453_nl
      , or_462_tmp});
  assign LOAD_LOOP_mux_67_nl = MUX_s_1_2_2(exit_LOAD_BATCH_LOOP_lpi_1_dfm_4, (LOAD_BATCH_LOOP_acc_1_tmp[4]),
      LOAD_LOOP_acc_1_tmp[4]);
  assign and_412_nl = lfst_exit_LOAD_LOOP_lpi_1_dfm_2_1_1 & (~ and_440_cse);
  assign mux_221_nl = MUX_s_1_2_2(and_412_nl, dma_read_ctrl_rsci_irdy_mxwt, LOAD_LOOP_or_tmp_1);
  assign or_275_nl = or_tmp_100 | (~ mux_221_nl);
  assign mux_222_nl = MUX_s_1_2_2(or_128_cse, or_275_nl, main_stage_v_1);
  assign and_243_nl = (~ mux_222_nl) & nor_101_cse;
  assign exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_mx1 = MUX_s_1_2_2(exit_LOAD_BATCH_LOOP_lpi_1_dfm_4,
      LOAD_LOOP_mux_67_nl, and_243_nl);
  assign lfst_exit_LOAD_LOOP_lpi_1_1_mx0 = MUX_s_1_2_2(lfst_exit_LOAD_LOOP_lpi_1_dfm_3_1_1,
      lfst_exit_LOAD_LOOP_lpi_1_1, or_dcpl_33);
  assign lfst_exit_LOAD_LOOP_lpi_1_0_mx0 = MUX_s_1_2_2(lfst_exit_LOAD_LOOP_lpi_1_dfm_3_0_1,
      lfst_exit_LOAD_LOOP_lpi_1_0, or_dcpl_33);
  assign LOAD_BATCH_LOOP_if_asn_sft_lpi_1_mx0 = MUX_s_1_2_2(LOAD_BATCH_LOOP_if_asn_sft_lpi_1,
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1, main_stage_v_1);
  assign LOAD_BATCH_LOOP_if_LOAD_BATCH_LOOP_if_LOAD_BATCH_LOOP_if_or_nl = (~(lfst_exit_LOAD_LOOP_lpi_1_dfm_3_1_1
      | lfst_exit_LOAD_LOOP_lpi_1_dfm_3_0_1)) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign exitL_exit_LOAD_LOOP_lpi_1_dfm_mx1 = MUX_s_1_2_2(exitL_exit_LOAD_LOOP_lpi_1_dfm,
      LOAD_BATCH_LOOP_if_LOAD_BATCH_LOOP_if_LOAD_BATCH_LOOP_if_or_nl, main_stage_v_1);
  assign lfst_exit_LOAD_LOOP_lpi_1_dfm_1_mx0w0 = lfst_exit_LOAD_LOOP_lpi_1_1_mx0
      & (~ exitL_exitL_exit_LOAD_LOOP_lpi_1_dfm_1);
  assign lfst_exit_LOAD_LOOP_lpi_1_dfm_0_mx0w0 = lfst_exit_LOAD_LOOP_lpi_1_0_mx0
      & (~ exitL_exitL_exit_LOAD_LOOP_lpi_1_dfm_1);
  assign exit_LOAD_BATCH_LOOP_lpi_1_dfm_4 = (~ LOAD_BATCH_LOOP_if_acc_itm_32_1) &
      exitL_exitL_exit_LOAD_LOOP_lpi_1_dfm_1;
  assign mux_7_nl = MUX_v_32_2_2(batch_lpi_1_dfm, conf_info_rsci_idat_mxwt, exitL_exit_LOAD_BATCH_LOOP_sva);
  assign nl_LOAD_BATCH_LOOP_if_acc_nl = ({29'b10000000000000000000000000000 , LOAD_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_mx0w0})
      + conv_u2u_32_33(~ mux_7_nl) + 33'b000000000000000000000000000000001;
  assign LOAD_BATCH_LOOP_if_acc_nl = nl_LOAD_BATCH_LOOP_if_acc_nl[32:0];
  assign LOAD_BATCH_LOOP_if_acc_itm_32_1 = readslicef_33_1_32(LOAD_BATCH_LOOP_if_acc_nl);
  assign nl_LOAD_BATCH_LOOP_acc_1_tmp = conv_u2u_4_5(LOAD_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_mx0w0)
      + 5'b00001;
  assign LOAD_BATCH_LOOP_acc_1_tmp = nl_LOAD_BATCH_LOOP_acc_1_tmp[4:0];
  assign LOAD_LOOP_i_mux_nl = MUX_v_4_2_2(LOAD_LOOP_i_4_0_lpi_1_3_0, LOAD_LOOP_i_4_0_lpi_1_3_0_mx0w0,
      main_stage_v_1);
  assign nl_LOAD_LOOP_acc_1_tmp = conv_u2u_4_5(LOAD_LOOP_i_mux_nl) + 5'b00001;
  assign LOAD_LOOP_acc_1_tmp = nl_LOAD_LOOP_acc_1_tmp[4:0];
  assign exitL_exitL_exit_LOAD_LOOP_lpi_1_dfm_1 = exitL_exit_LOAD_LOOP_lpi_1_dfm_mx1
      | exit_LOAD_BATCH_LOOP_lpi_1_dfm_3 | exitL_exit_LOAD_BATCH_LOOP_sva;
  assign LOAD_LOOP_mux_66_nl = MUX_s_1_2_2(lfst_exit_LOAD_LOOP_lpi_1_dfm_2_1_1, lfst_exit_LOAD_LOOP_lpi_1_dfm_1_1,
      and_440_cse);
  assign lfst_exit_LOAD_LOOP_lpi_1_dfm_3_1_1 = (LOAD_LOOP_mux_66_nl & (~ and_451_cse))
      | LOAD_LOOP_and_60_ssc_1;
  assign lfst_exit_LOAD_LOOP_lpi_1_dfm_3_0_1 = (and_440_cse & (~ LOAD_LOOP_and_60_ssc_1))
      | and_451_cse;
  assign LOAD_LOOP_and_stg_2_0_sva_1 = LOAD_LOOP_and_stg_1_0_sva_1 & (~ (LOAD_LOOP_i_4_0_lpi_1_3_0[2]));
  assign LOAD_LOOP_and_stg_2_6_sva_1 = LOAD_LOOP_and_stg_1_2_sva_1 & (LOAD_LOOP_i_4_0_lpi_1_3_0[2]);
  assign LOAD_LOOP_and_stg_2_1_sva_1 = LOAD_LOOP_and_stg_1_1_sva_1 & (~ (LOAD_LOOP_i_4_0_lpi_1_3_0[2]));
  assign LOAD_LOOP_and_stg_2_5_sva_1 = LOAD_LOOP_and_stg_1_1_sva_1 & (LOAD_LOOP_i_4_0_lpi_1_3_0[2]);
  assign LOAD_LOOP_and_stg_2_2_sva_1 = LOAD_LOOP_and_stg_1_2_sva_1 & (~ (LOAD_LOOP_i_4_0_lpi_1_3_0[2]));
  assign LOAD_LOOP_and_stg_2_4_sva_1 = LOAD_LOOP_and_stg_1_0_sva_1 & (LOAD_LOOP_i_4_0_lpi_1_3_0[2]);
  assign LOAD_LOOP_and_stg_2_3_sva_1 = and_410_cse & (~ (LOAD_LOOP_i_4_0_lpi_1_3_0[2]));
  assign LOAD_LOOP_and_stg_1_0_sva_1 = ~((LOAD_LOOP_i_4_0_lpi_1_3_0[1:0]!=2'b00));
  assign LOAD_LOOP_and_stg_1_1_sva_1 = (LOAD_LOOP_i_4_0_lpi_1_3_0[1:0]==2'b01);
  assign LOAD_LOOP_and_stg_1_2_sva_1 = (LOAD_LOOP_i_4_0_lpi_1_3_0[1:0]==2'b10);
  assign LOAD_LOOP_and_60_ssc_1 = dma_read_ctrl_rsci_irdy_mxwt & LOAD_LOOP_or_tmp_1;
  assign main_stage_en_4 = or_50_cse & (dma_read_ctrl_rsci_bawt | (~((~(lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1
      | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1)) & main_stage_v_1))) & (dma_read_chnl_rsci_bawt
      | (~(lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1 & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0)
      & (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1) & main_stage_v_1))) & (plm_in_rsci_bawt
      | (~(LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm_2 & lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1
      & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0) & (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2)
      & main_stage_v_2))) & (done_rsci_bawt | (~(exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_3
      & main_stage_v_3)));
  assign or_19_cse = (~ main_stage_v_2) | plm_in_rsci_bawt | (~ LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm_2)
      | (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1) | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0
      | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2;
  assign and_tmp = ((~ main_stage_v_3) | (~ exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_3)
      | done_rsci_bawt) & or_19_cse;
  assign or_tmp_17 = dma_read_chnl_rsci_bawt | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0;
  assign and_10_cse = or_tmp_17 & and_tmp;
  assign and_11_cse = dma_read_ctrl_rsci_bawt & and_tmp;
  assign mux_tmp_8 = MUX_s_1_2_2(and_11_cse, and_10_cse, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign and_tmp_5 = LOAD_BATCH_LOOP_if_acc_itm_32_1 & and_tmp;
  assign or_tmp_100 = LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign or_131_cse = (~ main_stage_v_1) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1;
  assign or_147_nl = LOAD_BATCH_LOOP_if_acc_itm_32_1 | (~ and_tmp);
  assign mux_tmp_93 = MUX_s_1_2_2(or_147_nl, and_tmp_5, exitL_exit_LOAD_BATCH_LOOP_sva);
  assign or_150_nl = (~ exit_LOAD_BATCH_LOOP_lpi_1_dfm_3) | LOAD_BATCH_LOOP_if_acc_itm_32_1
      | (~ and_tmp);
  assign mux_tmp_98 = MUX_s_1_2_2(or_150_nl, and_tmp_5, exitL_exit_LOAD_BATCH_LOOP_sva);
  assign nand_53_nl = ~((~(exit_LOAD_BATCH_LOOP_lpi_1_dfm_3 & LOAD_BATCH_LOOP_if_acc_itm_32_1))
      & and_tmp);
  assign mux_tmp_100 = MUX_s_1_2_2(nand_53_nl, and_tmp_5, exitL_exit_LOAD_BATCH_LOOP_sva);
  assign and_426_cse = (LOAD_BATCH_LOOP_acc_1_tmp[4]) & (LOAD_LOOP_acc_1_tmp[4]);
  assign mux_111_cse = MUX_s_1_2_2(mux_tmp_98, mux_tmp_100, and_426_cse);
  assign mux_112_nl = MUX_s_1_2_2(mux_tmp_93, mux_111_cse, lfst_exit_LOAD_LOOP_lpi_1_dfm_2_1_1);
  assign mux_tmp_104 = MUX_s_1_2_2(mux_112_nl, mux_tmp_98, and_440_cse);
  assign and_dcpl_3 = conf_info_rsci_bawt & LOAD_BATCH_LOOP_asn_itm;
  assign or_155_cse = LOAD_BATCH_LOOP_if_acc_itm_32_1 | (~ main_stage_en_4);
  assign and_tmp_40 = or_155_cse & and_tmp;
  assign and_54_nl = dma_read_ctrl_rsci_bawt & and_tmp_40;
  assign and_53_nl = or_155_cse & and_10_cse;
  assign mux_tmp_117 = MUX_s_1_2_2(and_54_nl, and_53_nl, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign and_tmp_46 = (~((~ dma_read_ctrl_rsci_bawt) | main_stage_en_4)) & and_tmp;
  assign or_dcpl_2 = done_rsci_bawt | (~ exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_3);
  assign or_dcpl_3 = or_dcpl_2 | (~ main_stage_v_3);
  assign and_tmp_51 = or_tmp_17 & or_19_cse;
  assign and_tmp_52 = dma_read_ctrl_rsci_bawt & or_19_cse;
  assign mux_tmp_135 = MUX_s_1_2_2(and_tmp_52, and_tmp_51, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign mux_tmp_136 = MUX_s_1_2_2(mux_tmp_135, or_19_cse, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_tmp_53 = LOAD_BATCH_LOOP_if_acc_itm_32_1 & mux_tmp_136;
  assign or_172_nl = dma_read_ctrl_rsci_irdy_mxwt | (~ and_tmp_52);
  assign mux_tmp_137 = MUX_s_1_2_2(or_172_nl, (~ and_tmp_51), lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign and_tmp_54 = and_440_cse & mux_tmp_135;
  assign mux_147_nl = MUX_s_1_2_2(mux_tmp_135, and_tmp_54, lfst_exit_LOAD_LOOP_lpi_1_dfm_2_1_1);
  assign mux_148_nl = MUX_s_1_2_2(mux_147_nl, (~ mux_tmp_137), LOAD_LOOP_or_tmp_1);
  assign mux_tmp_140 = MUX_s_1_2_2(mux_148_nl, or_19_cse, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign or_tmp_153 = LOAD_LOOP_or_tmp_1 | lfst_exit_LOAD_LOOP_lpi_1_dfm_2_1_1;
  assign mux_154_nl = MUX_s_1_2_2(and_tmp_54, mux_tmp_135, or_tmp_153);
  assign mux_tmp_146 = MUX_s_1_2_2(mux_154_nl, or_19_cse, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_dcpl_8 = (~ conf_info_rsci_bawt) & LOAD_BATCH_LOOP_asn_itm;
  assign and_dcpl_10 = (~ done_rsci_bawt) & exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_3
      & main_stage_v_3;
  assign mux_tmp_171 = MUX_s_1_2_2(mux_tmp_135, or_19_cse, or_131_cse);
  assign or_dcpl_4 = (~ mux_tmp_171) | and_dcpl_10;
  assign or_tmp_177 = and_440_cse | (~ mux_tmp_135);
  assign and_84_cse = LOAD_BATCH_LOOP_if_acc_itm_32_1 & or_19_cse;
  assign and_86_nl = ((~ exitL_exit_LOAD_LOOP_lpi_1_dfm) | LOAD_BATCH_LOOP_if_acc_itm_32_1)
      & or_19_cse;
  assign and_85_nl = exitL_exit_LOAD_LOOP_lpi_1_dfm & LOAD_BATCH_LOOP_if_acc_itm_32_1
      & or_19_cse;
  assign or_201_nl = lfst_exit_LOAD_LOOP_lpi_1_1 | LOAD_BATCH_LOOP_if_asn_sft_lpi_1;
  assign mux_186_nl = MUX_s_1_2_2(and_86_nl, and_85_nl, or_201_nl);
  assign nor_109_nl = ~(LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 | (~ LOAD_LOOP_or_tmp_1)
      | mux_tmp_137);
  assign or_200_nl = lfst_exit_LOAD_LOOP_lpi_1_dfm_2_1_1 | or_tmp_177;
  assign mux_182_nl = MUX_s_1_2_2(or_200_nl, mux_tmp_137, LOAD_LOOP_or_tmp_1);
  assign mux_183_nl = MUX_s_1_2_2((~ mux_182_nl), or_19_cse, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_184_nl = MUX_s_1_2_2(nor_109_nl, mux_183_nl, LOAD_BATCH_LOOP_if_acc_itm_32_1);
  assign mux_185_nl = MUX_s_1_2_2(mux_184_nl, and_tmp_53, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_187_nl = MUX_s_1_2_2(mux_186_nl, mux_185_nl, main_stage_v_1);
  assign mux_181_nl = MUX_s_1_2_2(and_84_cse, and_tmp_53, main_stage_v_1);
  assign mux_tmp_179 = MUX_s_1_2_2(mux_187_nl, mux_181_nl, or_76_cse);
  assign and_dcpl_12 = ~((LOAD_LOOP_i_4_0_lpi_1_3_0[3:2]!=2'b00));
  assign and_dcpl_17 = (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0) & lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1
      & (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1) & main_stage_v_1 & LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm_1;
  assign and_dcpl_19 = or_19_cse & or_dcpl_3;
  assign and_dcpl_20 = and_dcpl_19 & dma_read_chnl_rsci_bawt;
  assign and_dcpl_22 = (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1) & main_stage_v_1;
  assign and_dcpl_25 = dma_read_chnl_rsci_bawt & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0)
      & lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1;
  assign and_dcpl_26 = and_dcpl_25 & and_dcpl_22 & LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm_1;
  assign or_dcpl_12 = (~ dma_read_chnl_rsci_bawt) | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0
      | (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1) | or_131_cse | (~ LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm_1);
  assign or_dcpl_13 = (~ or_19_cse) | and_dcpl_10;
  assign and_dcpl_47 = (LOAD_LOOP_i_4_0_lpi_1_3_0[3:2]==2'b01);
  assign and_dcpl_68 = (LOAD_LOOP_i_4_0_lpi_1_3_0[3:2]==2'b10);
  assign not_tmp_95 = ~((LOAD_LOOP_i_4_0_lpi_1_3_0[3]) | (~ or_19_cse));
  assign and_dcpl_89 = (LOAD_LOOP_i_4_0_lpi_1_3_0[3:2]==2'b11);
  assign not_tmp_96 = (~((LOAD_LOOP_i_4_0_lpi_1_3_0[3:2]==2'b11))) & or_19_cse;
  assign and_dcpl_106 = ((~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1) | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0
      | (~ LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm_2) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2
      | plm_in_rsci_bawt) & or_dcpl_3;
  assign and_dcpl_109 = done_rsci_bawt & exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_3 &
      main_stage_v_3;
  assign and_dcpl_111 = lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1 & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0);
  assign and_dcpl_112 = and_dcpl_111 & LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm_2;
  assign and_dcpl_113 = and_dcpl_112 & (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2)
      & (~ plm_in_rsci_bawt);
  assign and_dcpl_114 = (and_dcpl_113 | (~ main_stage_v_2) | (~ exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_2))
      & and_dcpl_109;
  assign and_tmp_78 = dma_read_ctrl_rsci_irdy_mxwt & dma_read_ctrl_rsci_bawt & or_19_cse;
  assign mux_tmp_189 = MUX_s_1_2_2(and_tmp_78, and_tmp_51, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign or_tmp_201 = or_128_cse | (~ or_19_cse);
  assign and_413_nl = lfst_exit_LOAD_LOOP_lpi_1_dfm_2_1_1 & (~ or_tmp_177);
  assign mux_199_nl = MUX_s_1_2_2(and_413_nl, mux_tmp_189, LOAD_LOOP_or_tmp_1);
  assign or_237_nl = or_tmp_100 | (~ mux_199_nl);
  assign mux_200_nl = MUX_s_1_2_2(or_tmp_201, or_237_nl, main_stage_v_1);
  assign and_dcpl_116 = (~ mux_200_nl) & or_dcpl_3;
  assign and_dcpl_118 = and_dcpl_116 & or_50_cse & nor_101_cse;
  assign and_dcpl_119 = and_dcpl_25 & and_dcpl_22;
  assign and_206_nl = and_440_cse & or_19_cse;
  assign mux_201_nl = MUX_s_1_2_2(or_19_cse, and_206_nl, lfst_exit_LOAD_LOOP_lpi_1_dfm_2_1_1);
  assign mux_202_nl = MUX_s_1_2_2(mux_201_nl, or_19_cse, LOAD_LOOP_or_tmp_1);
  assign or_242_nl = (~ or_50_cse) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign mux_203_nl = MUX_s_1_2_2(mux_202_nl, or_19_cse, or_242_nl);
  assign mux_204_nl = MUX_s_1_2_2(mux_203_nl, or_19_cse, or_76_cse);
  assign and_dcpl_121 = mux_204_nl & or_dcpl_3 & and_dcpl_119;
  assign and_dcpl_133 = or_dcpl_12 & or_dcpl_3 & and_dcpl_112 & (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2)
      & plm_in_rsci_bawt & main_stage_v_2;
  assign and_dcpl_139 = mux_tmp_171 & or_dcpl_3;
  assign and_dcpl_144 = mux_tmp_136 & or_dcpl_3;
  assign and_236_nl = or_128_cse & or_19_cse;
  assign mux_214_nl = MUX_s_1_2_2(mux_tmp_140, mux_tmp_136, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_215_nl = MUX_s_1_2_2(and_236_nl, mux_214_nl, main_stage_v_1);
  assign mux_216_nl = MUX_s_1_2_2(mux_215_nl, mux_tmp_171, or_76_cse);
  assign and_dcpl_149 = mux_216_nl & or_dcpl_3;
  assign or_tmp_232 = (~ lfst_exit_LOAD_LOOP_lpi_1_1) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1
      | exitL_exit_LOAD_LOOP_lpi_1_dfm;
  assign or_dcpl_33 = LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 | (~ main_stage_v_1);
  assign nor_114_nl = ~(exitL_exit_LOAD_LOOP_lpi_1_dfm | (~ or_19_cse));
  assign nor_115_nl = ~(LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 | (~ mux_tmp_146));
  assign mux_236_nl = MUX_s_1_2_2(nor_114_nl, nor_115_nl, main_stage_v_1);
  assign and_dcpl_164 = mux_236_nl & or_dcpl_3;
  assign or_tmp_244 = and_440_cse | LOAD_LOOP_or_tmp_1 | lfst_exit_LOAD_LOOP_lpi_1_dfm_2_1_1;
  assign and_tmp_86 = ((~ or_tmp_244) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 |
      exitL_exit_LOAD_BATCH_LOOP_sva | exit_LOAD_BATCH_LOOP_lpi_1_dfm_3) & or_19_cse;
  assign or_tmp_246 = exitL_exit_LOAD_LOOP_lpi_1_dfm | exitL_exit_LOAD_BATCH_LOOP_sva
      | exit_LOAD_BATCH_LOOP_lpi_1_dfm_3;
  assign and_261_nl = dma_read_ctrl_rsci_bawt & and_tmp_86;
  assign and_260_nl = or_tmp_17 & and_tmp_86;
  assign mux_237_nl = MUX_s_1_2_2(and_261_nl, and_260_nl, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign and_258_nl = or_446_cse & or_19_cse;
  assign mux_238_cse = MUX_s_1_2_2(mux_237_nl, and_258_nl, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_262_nl = or_tmp_246 & or_19_cse;
  assign mux_239_nl = MUX_s_1_2_2(and_262_nl, mux_238_cse, main_stage_v_1);
  assign and_dcpl_166 = mux_239_nl & or_dcpl_3;
  assign or_dcpl_39 = or_dcpl_33 | (~ LOAD_LOOP_equal_tmp_1);
  assign or_tmp_248 = LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 | (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1)
      | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0;
  assign or_tmp_250 = and_dcpl_12 | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 | (~
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1) | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0;
  assign not_tmp_134 = ~((LOAD_LOOP_i_4_0_lpi_1_3_0[3:2]!=2'b00) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1
      | (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1) | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0);
  assign or_tmp_253 = and_dcpl_89 | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 | (~
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1) | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0;
  assign not_tmp_136 = ~((LOAD_LOOP_i_4_0_lpi_1_3_0[3:2]!=2'b11) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1
      | (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1) | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0);
  assign or_tmp_257 = (~((LOAD_LOOP_i_4_0_lpi_1_3_0[3:2]!=2'b10))) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1
      | (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1) | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0;
  assign not_tmp_143 = ~((LOAD_LOOP_i_4_0_lpi_1_3_0[3:2]!=2'b10) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1
      | (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1) | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0);
  assign or_tmp_261 = (~((LOAD_LOOP_i_4_0_lpi_1_3_0[3:2]!=2'b01))) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1
      | (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1) | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0;
  assign not_tmp_145 = ~((LOAD_LOOP_i_4_0_lpi_1_3_0[3:2]!=2'b01) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1
      | (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1) | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0);
  assign and_dcpl_167 = and_dcpl_116 & nor_101_cse;
  assign nor_74_cse = ~((~ or_tmp_244) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 |
      exitL_exit_LOAD_BATCH_LOOP_sva | exit_LOAD_BATCH_LOOP_lpi_1_dfm_3);
  assign and_281_cse = (nor_74_cse | LOAD_BATCH_LOOP_if_acc_itm_32_1) & or_19_cse;
  assign not_tmp_156 = ~(nor_74_cse | LOAD_BATCH_LOOP_if_acc_itm_32_1 | (~ or_19_cse));
  assign and_dcpl_177 = mux_238_cse & or_dcpl_3 & or_50_cse;
  assign nor_27_cse = ~((~ lfst_exit_LOAD_LOOP_lpi_1_1) | lfst_exit_LOAD_LOOP_lpi_1_0
      | LOAD_BATCH_LOOP_if_asn_sft_lpi_1 | (~ (LOAD_BATCH_LOOP_acc_1_tmp[4])) | (~
      (LOAD_LOOP_acc_1_tmp[4])));
  assign mux_122_nl = MUX_s_1_2_2(mux_tmp_98, mux_tmp_100, nor_27_cse);
  assign mux_123_nl = MUX_s_1_2_2(mux_122_nl, mux_tmp_93, exitL_exit_LOAD_LOOP_lpi_1_dfm);
  assign and_424_nl = dma_read_ctrl_rsci_irdy_mxwt & (LOAD_BATCH_LOOP_acc_1_tmp[4])
      & (LOAD_LOOP_acc_1_tmp[4]);
  assign mux_116_nl = MUX_s_1_2_2(mux_tmp_98, mux_tmp_100, and_424_nl);
  assign mux_117_nl = MUX_s_1_2_2(mux_tmp_104, mux_116_nl, LOAD_LOOP_or_tmp_1);
  assign mux_118_nl = MUX_s_1_2_2((~ exitL_exit_LOAD_BATCH_LOOP_sva), mux_117_nl,
      dma_read_ctrl_rsci_bawt);
  assign mux_114_nl = MUX_s_1_2_2(mux_tmp_104, mux_111_cse, LOAD_LOOP_or_tmp_1);
  assign mux_115_nl = MUX_s_1_2_2((~ exitL_exit_LOAD_BATCH_LOOP_sva), mux_114_nl,
      or_tmp_17);
  assign mux_119_nl = MUX_s_1_2_2(mux_118_nl, mux_115_nl, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign mux_120_nl = MUX_s_1_2_2(mux_119_nl, mux_tmp_93, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_104_nl = MUX_s_1_2_2((~ exitL_exit_LOAD_BATCH_LOOP_sva), mux_tmp_93,
      dma_read_ctrl_rsci_bawt);
  assign mux_103_nl = MUX_s_1_2_2((~ exitL_exit_LOAD_BATCH_LOOP_sva), mux_tmp_93,
      or_tmp_17);
  assign mux_105_nl = MUX_s_1_2_2(mux_104_nl, mux_103_nl, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign mux_106_nl = MUX_s_1_2_2(mux_105_nl, mux_tmp_93, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_121_nl = MUX_s_1_2_2(mux_120_nl, mux_106_nl, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_124_nl = MUX_s_1_2_2(mux_123_nl, mux_121_nl, main_stage_v_1);
  assign mux_125_nl = MUX_s_1_2_2(exitL_exit_LOAD_BATCH_LOOP_sva, (~ mux_124_nl),
      or_50_cse);
  assign or_tmp_312 = (mux_125_nl & main_stage_en_4) | (fsm_output[0]);
  assign and_59_cse = (~ main_stage_en_4) & and_10_cse;
  assign and_61_nl = ((~ exitL_exit_LOAD_LOOP_lpi_1_dfm) | LOAD_BATCH_LOOP_if_acc_itm_32_1
      | (~ main_stage_en_4)) & and_tmp;
  assign and_60_nl = (~((~(exitL_exit_LOAD_LOOP_lpi_1_dfm & LOAD_BATCH_LOOP_if_acc_itm_32_1))
      & main_stage_en_4)) & and_tmp;
  assign mux_141_nl = MUX_s_1_2_2(and_61_nl, and_60_nl, nor_27_cse);
  assign or_162_nl = and_440_cse | lfst_exit_LOAD_LOOP_lpi_1_dfm_2_1_1;
  assign mux_136_nl = MUX_s_1_2_2(mux_tmp_117, mux_tmp_8, or_162_nl);
  assign mux_137_nl = MUX_s_1_2_2(mux_136_nl, mux_tmp_8, LOAD_LOOP_or_tmp_1);
  assign mux_132_nl = MUX_s_1_2_2(and_tmp_46, and_59_cse, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign mux_133_nl = MUX_s_1_2_2(mux_tmp_117, mux_132_nl, lfst_exit_LOAD_LOOP_lpi_1_dfm_2_1_1);
  assign mux_134_nl = MUX_s_1_2_2(mux_133_nl, mux_tmp_8, and_440_cse);
  assign mux_129_nl = MUX_s_1_2_2(and_11_cse, and_tmp_46, dma_read_ctrl_rsci_irdy_mxwt);
  assign mux_130_nl = MUX_s_1_2_2(mux_129_nl, and_59_cse, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign mux_135_nl = MUX_s_1_2_2(mux_134_nl, mux_130_nl, LOAD_LOOP_or_tmp_1);
  assign mux_138_nl = MUX_s_1_2_2(mux_137_nl, mux_135_nl, and_426_cse);
  assign mux_139_nl = MUX_s_1_2_2(mux_138_nl, and_tmp_40, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_128_nl = MUX_s_1_2_2(mux_tmp_117, and_tmp_40, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_140_nl = MUX_s_1_2_2(mux_139_nl, mux_128_nl, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_142_nl = MUX_s_1_2_2(mux_141_nl, mux_140_nl, main_stage_v_1);
  assign mux_127_nl = MUX_s_1_2_2(mux_tmp_117, and_tmp_40, or_131_cse);
  assign mux_143_nl = MUX_s_1_2_2(mux_142_nl, mux_127_nl, or_76_cse);
  assign and_320_cse = mux_143_nl & and_dcpl_3 & (fsm_output[1]);
  assign nor_86_nl = ~(LOAD_BATCH_LOOP_if_asn_sft_lpi_1 | (~ or_19_cse));
  assign mux_273_nl = MUX_s_1_2_2(nor_86_nl, and_84_cse, or_tmp_246);
  assign mux_274_nl = MUX_s_1_2_2(mux_273_nl, mux_276_cse, main_stage_v_1);
  assign and_354_cse = mux_274_nl & or_dcpl_3 & or_50_cse & (fsm_output[1]);
  assign and_418_nl = LOAD_BATCH_LOOP_if_asn_sft_lpi_1 & or_19_cse;
  assign nor_84_nl = ~(LOAD_BATCH_LOOP_if_acc_itm_32_1 | (~ or_19_cse));
  assign mux_279_nl = MUX_s_1_2_2(and_418_nl, nor_84_nl, or_tmp_246);
  assign and_419_nl = dma_read_ctrl_rsci_bawt & not_tmp_156;
  assign and_420_nl = or_tmp_17 & not_tmp_156;
  assign mux_277_nl = MUX_s_1_2_2(and_419_nl, and_420_nl, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign nor_85_nl = ~((~ or_446_cse) | LOAD_BATCH_LOOP_if_acc_itm_32_1 | (~ or_19_cse));
  assign mux_278_nl = MUX_s_1_2_2(mux_277_nl, nor_85_nl, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_280_nl = MUX_s_1_2_2(mux_279_nl, mux_278_nl, main_stage_v_1);
  assign and_356_cse = mux_280_nl & or_dcpl_3 & or_50_cse & (fsm_output[1]);
  assign mux_156_nl = MUX_s_1_2_2(mux_tmp_146, mux_tmp_136, LOAD_BATCH_LOOP_if_acc_itm_32_1);
  assign mux_157_nl = MUX_s_1_2_2(mux_156_nl, and_tmp_53, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_150_nl = MUX_s_1_2_2(and_tmp_54, (~ mux_tmp_137), LOAD_LOOP_or_tmp_1);
  assign mux_151_nl = MUX_s_1_2_2(mux_150_nl, or_19_cse, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_152_nl = MUX_s_1_2_2(mux_151_nl, mux_tmp_140, LOAD_BATCH_LOOP_if_acc_itm_32_1);
  assign mux_153_nl = MUX_s_1_2_2(mux_152_nl, and_tmp_53, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_158_nl = MUX_s_1_2_2(mux_157_nl, mux_153_nl, and_426_cse);
  assign mux_159_nl = MUX_s_1_2_2(mux_158_nl, and_tmp_53, or_76_cse);
  assign mux_160_nl = MUX_s_1_2_2(mux_tmp_136, mux_159_nl, main_stage_en_4);
  assign conf_info_rsci_iswt0_mx0c1 = and_320_cse | (mux_160_nl & or_dcpl_3 & and_dcpl_3
      & main_stage_v_1);
  assign plm_in_rsci_idat_31_0_mx0c1 = ((LOAD_LOOP_i_4_0_lpi_1_3_0!=4'b0000)) & or_19_cse
      & or_dcpl_3 & and_dcpl_26;
  assign plm_in_rsci_idat_63_32_mx0c1 = ((LOAD_LOOP_i_4_0_lpi_1_3_0!=4'b0001)) &
      or_19_cse & or_dcpl_3 & and_dcpl_26;
  assign plm_in_rsci_idat_95_64_mx0c1 = ((LOAD_LOOP_i_4_0_lpi_1_3_0!=4'b0010)) &
      or_19_cse & or_dcpl_3 & and_dcpl_26;
  assign plm_in_rsci_idat_127_96_mx0c1 = ((LOAD_LOOP_i_4_0_lpi_1_3_0!=4'b0011)) &
      or_19_cse & or_dcpl_3 & and_dcpl_26;
  assign plm_in_rsci_idat_159_128_mx0c1 = ((LOAD_LOOP_i_4_0_lpi_1_3_0!=4'b0100))
      & or_19_cse & or_dcpl_3 & and_dcpl_26;
  assign plm_in_rsci_idat_191_160_mx0c1 = ((LOAD_LOOP_i_4_0_lpi_1_3_0!=4'b0101))
      & or_19_cse & or_dcpl_3 & and_dcpl_26;
  assign plm_in_rsci_idat_223_192_mx0c1 = ((LOAD_LOOP_i_4_0_lpi_1_3_0!=4'b0110))
      & or_19_cse & or_dcpl_3 & and_dcpl_26;
  assign plm_in_rsci_idat_255_224_mx0c1 = (~((LOAD_LOOP_i_4_0_lpi_1_3_0==4'b0111)))
      & or_19_cse & or_dcpl_3 & and_dcpl_26;
  assign or_220_nl = (LOAD_LOOP_i_4_0_lpi_1_3_0[2:0]!=3'b000);
  assign mux_189_nl = MUX_s_1_2_2(not_tmp_95, or_19_cse, or_220_nl);
  assign plm_in_rsci_idat_287_256_mx0c1 = mux_189_nl & or_dcpl_3 & and_dcpl_26;
  assign or_222_nl = (LOAD_LOOP_i_4_0_lpi_1_3_0[2:0]!=3'b001);
  assign mux_190_nl = MUX_s_1_2_2(not_tmp_95, or_19_cse, or_222_nl);
  assign plm_in_rsci_idat_319_288_mx0c1 = mux_190_nl & or_dcpl_3 & and_dcpl_26;
  assign or_223_nl = (LOAD_LOOP_i_4_0_lpi_1_3_0[2:0]!=3'b010);
  assign mux_191_nl = MUX_s_1_2_2(not_tmp_95, or_19_cse, or_223_nl);
  assign plm_in_rsci_idat_351_320_mx0c1 = mux_191_nl & or_dcpl_3 & and_dcpl_26;
  assign or_224_nl = (LOAD_LOOP_i_4_0_lpi_1_3_0[2:0]!=3'b011);
  assign mux_192_nl = MUX_s_1_2_2(not_tmp_95, or_19_cse, or_224_nl);
  assign plm_in_rsci_idat_383_352_mx0c1 = mux_192_nl & or_dcpl_3 & and_dcpl_26;
  assign mux_193_nl = MUX_s_1_2_2(not_tmp_96, or_19_cse, or_303_cse);
  assign plm_in_rsci_idat_415_384_mx0c1 = mux_193_nl & or_dcpl_3 & and_dcpl_26;
  assign and_416_nl = (~((LOAD_LOOP_i_4_0_lpi_1_3_0[0]) & (LOAD_LOOP_i_4_0_lpi_1_3_0[2])
      & (LOAD_LOOP_i_4_0_lpi_1_3_0[3]))) & or_19_cse;
  assign mux_194_nl = MUX_s_1_2_2(and_416_nl, or_19_cse, LOAD_LOOP_i_4_0_lpi_1_3_0[1]);
  assign plm_in_rsci_idat_447_416_mx0c1 = mux_194_nl & or_dcpl_3 & and_dcpl_26;
  assign mux_195_nl = MUX_s_1_2_2(not_tmp_96, or_19_cse, or_309_cse);
  assign plm_in_rsci_idat_479_448_mx0c1 = mux_195_nl & or_dcpl_3 & and_dcpl_26;
  assign mux_300_nl = MUX_s_1_2_2(mux_tmp_135, or_19_cse, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_231_nl = MUX_s_1_2_2(or_19_cse, mux_300_nl, main_stage_v_1);
  assign and_250_nl = or_tmp_232 & or_19_cse;
  assign or_282_nl = lfst_exit_LOAD_LOOP_lpi_1_dfm_2_1_1 | (~ mux_tmp_135);
  assign mux_225_nl = MUX_s_1_2_2(or_282_nl, mux_tmp_137, LOAD_LOOP_or_tmp_1);
  assign mux_226_nl = MUX_s_1_2_2((~ mux_225_nl), or_19_cse, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_227_nl = MUX_s_1_2_2(mux_226_nl, mux_tmp_136, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_228_nl = MUX_s_1_2_2(and_250_nl, mux_227_nl, main_stage_v_1);
  assign mux_232_nl = MUX_s_1_2_2(mux_231_nl, mux_228_nl, LOAD_LOOP_acc_1_tmp[4]);
  assign mux_233_nl = MUX_s_1_2_2(mux_232_nl, mux_tmp_171, or_76_cse);
  assign LOAD_BATCH_LOOP_b_4_0_lpi_1_3_0_mx0c1 = mux_233_nl & or_dcpl_3 & or_50_cse;
  assign main_stage_v_1_mx0c1 = and_dcpl_144 & and_dcpl_8 & main_stage_v_1;
  assign lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1_mx0c1 = and_356_cse | (and_dcpl_177
      & (~ LOAD_BATCH_LOOP_if_acc_itm_32_1) & main_stage_v_1);
  assign LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1 = (and_dcpl_166 & or_50_cse
      & (fsm_output[1])) | (and_dcpl_177 & main_stage_v_1);
  assign or_376_nl = dma_read_ctrl_rsci_bawt | and_dcpl_113;
  assign or_375_nl = or_tmp_17 | and_dcpl_113;
  assign mux_285_nl = MUX_s_1_2_2(or_376_nl, or_375_nl, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign or_377_nl = LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 | mux_285_nl;
  assign mux_286_nl = MUX_s_1_2_2(and_dcpl_113, or_377_nl, main_stage_v_1);
  assign main_stage_v_2_mx0c1 = (~ mux_286_nl) & or_dcpl_3 & main_stage_v_2;
  assign main_stage_v_3_mx0c1 = (and_dcpl_113 | (~ main_stage_v_2)) & or_dcpl_2 &
      main_stage_v_3;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_iswt0 <= 1'b0;
    end
    else if ( core_wen & (or_tmp_312 | conf_info_rsci_iswt0_mx0c1) ) begin
      conf_info_rsci_iswt0 <= (~ conf_info_rsci_iswt0_mx0c1) | or_tmp_312;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_irdy_core_psct <= 1'b0;
    end
    else if ( core_wen & (or_tmp_312 | and_320_cse) ) begin
      conf_info_rsci_irdy_core_psct <= ~ and_320_cse;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exitL_exit_LOAD_BATCH_LOOP_sva <= 1'b1;
    end
    else if ( core_wen & (~(or_dcpl_4 | and_dcpl_8 | (fsm_output[0]))) ) begin
      exitL_exit_LOAD_BATCH_LOOP_sva <= exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_mx1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_read_ctrl_rsci_idat_7_4 <= 4'b0000;
    end
    else if ( core_wen & (~((~ mux_tmp_179) | and_dcpl_10 | and_dcpl_8 | (fsm_output[0])))
        ) begin
      dma_read_ctrl_rsci_idat_7_4 <= LOAD_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_idat_31_0 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_20 & and_dcpl_17 & and_dcpl_12 & LOAD_LOOP_and_stg_1_0_sva_1)
        | plm_in_rsci_idat_31_0_mx0c1) ) begin
      plm_in_rsci_idat_31_0 <= MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt, LOAD_BATCH_LOOP_plm_tmp_data_0_lpi_1,
          plm_in_rsci_idat_31_0_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_idat_63_32 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_20 & and_dcpl_17 & and_dcpl_12 & LOAD_LOOP_and_stg_1_1_sva_1)
        | plm_in_rsci_idat_63_32_mx0c1) ) begin
      plm_in_rsci_idat_63_32 <= MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt, LOAD_BATCH_LOOP_plm_tmp_data_1_lpi_1,
          plm_in_rsci_idat_63_32_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_idat_95_64 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_20 & and_dcpl_17 & and_dcpl_12 & LOAD_LOOP_and_stg_1_2_sva_1)
        | plm_in_rsci_idat_95_64_mx0c1) ) begin
      plm_in_rsci_idat_95_64 <= MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt, LOAD_BATCH_LOOP_plm_tmp_data_2_lpi_1,
          plm_in_rsci_idat_95_64_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_idat_127_96 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_20 & and_dcpl_17 & and_dcpl_12 & and_410_cse)
        | plm_in_rsci_idat_127_96_mx0c1) ) begin
      plm_in_rsci_idat_127_96 <= MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt, LOAD_BATCH_LOOP_plm_tmp_data_3_lpi_1,
          plm_in_rsci_idat_127_96_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_idat_159_128 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_20 & and_dcpl_17 & and_dcpl_47 & LOAD_LOOP_and_stg_1_0_sva_1)
        | plm_in_rsci_idat_159_128_mx0c1) ) begin
      plm_in_rsci_idat_159_128 <= MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt, LOAD_BATCH_LOOP_plm_tmp_data_4_lpi_1,
          plm_in_rsci_idat_159_128_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_idat_191_160 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_20 & and_dcpl_17 & and_dcpl_47 & LOAD_LOOP_and_stg_1_1_sva_1)
        | plm_in_rsci_idat_191_160_mx0c1) ) begin
      plm_in_rsci_idat_191_160 <= MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt, LOAD_BATCH_LOOP_plm_tmp_data_5_lpi_1,
          plm_in_rsci_idat_191_160_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_idat_223_192 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_20 & and_dcpl_17 & and_dcpl_47 & LOAD_LOOP_and_stg_1_2_sva_1)
        | plm_in_rsci_idat_223_192_mx0c1) ) begin
      plm_in_rsci_idat_223_192 <= MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt, LOAD_BATCH_LOOP_plm_tmp_data_6_lpi_1,
          plm_in_rsci_idat_223_192_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_idat_255_224 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_20 & and_dcpl_17 & and_dcpl_47 & and_410_cse)
        | plm_in_rsci_idat_255_224_mx0c1) ) begin
      plm_in_rsci_idat_255_224 <= MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt, LOAD_BATCH_LOOP_plm_tmp_data_7_lpi_1,
          plm_in_rsci_idat_255_224_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_idat_287_256 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_20 & and_dcpl_17 & and_dcpl_68 & LOAD_LOOP_and_stg_1_0_sva_1)
        | plm_in_rsci_idat_287_256_mx0c1) ) begin
      plm_in_rsci_idat_287_256 <= MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt, LOAD_BATCH_LOOP_plm_tmp_data_8_lpi_1,
          plm_in_rsci_idat_287_256_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_idat_319_288 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_20 & and_dcpl_17 & and_dcpl_68 & LOAD_LOOP_and_stg_1_1_sva_1)
        | plm_in_rsci_idat_319_288_mx0c1) ) begin
      plm_in_rsci_idat_319_288 <= MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt, LOAD_BATCH_LOOP_plm_tmp_data_9_lpi_1,
          plm_in_rsci_idat_319_288_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_idat_351_320 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_20 & and_dcpl_17 & and_dcpl_68 & LOAD_LOOP_and_stg_1_2_sva_1)
        | plm_in_rsci_idat_351_320_mx0c1) ) begin
      plm_in_rsci_idat_351_320 <= MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt, LOAD_BATCH_LOOP_plm_tmp_data_10_lpi_1,
          plm_in_rsci_idat_351_320_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_idat_383_352 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_20 & and_dcpl_17 & and_dcpl_68 & and_410_cse)
        | plm_in_rsci_idat_383_352_mx0c1) ) begin
      plm_in_rsci_idat_383_352 <= MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt, LOAD_BATCH_LOOP_plm_tmp_data_11_lpi_1,
          plm_in_rsci_idat_383_352_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_idat_415_384 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_20 & and_dcpl_17 & and_dcpl_89 & LOAD_LOOP_and_stg_1_0_sva_1)
        | plm_in_rsci_idat_415_384_mx0c1) ) begin
      plm_in_rsci_idat_415_384 <= MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt, LOAD_BATCH_LOOP_plm_tmp_data_12_lpi_1,
          plm_in_rsci_idat_415_384_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_idat_447_416 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_20 & and_dcpl_17 & and_dcpl_89 & LOAD_LOOP_and_stg_1_1_sva_1)
        | plm_in_rsci_idat_447_416_mx0c1) ) begin
      plm_in_rsci_idat_447_416 <= MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt, LOAD_BATCH_LOOP_plm_tmp_data_13_lpi_1,
          plm_in_rsci_idat_447_416_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_idat_479_448 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_20 & and_dcpl_17 & and_dcpl_89 & LOAD_LOOP_and_stg_1_2_sva_1)
        | plm_in_rsci_idat_479_448_mx0c1) ) begin
      plm_in_rsci_idat_479_448 <= MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt, LOAD_BATCH_LOOP_plm_tmp_data_14_lpi_1,
          plm_in_rsci_idat_479_448_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_idat_511_480 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_13 | or_dcpl_12)) ) begin
      plm_in_rsci_idat_511_480 <= dma_read_chnl_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_done_rsci_ivld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_106 & main_stage_v_2 & exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_2)
        | and_dcpl_114) ) begin
      reg_done_rsci_ivld_core_psct_cse <= ~ and_dcpl_114;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_dma_read_chnl_rsci_irdy_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_118 | and_dcpl_121) ) begin
      reg_dma_read_chnl_rsci_irdy_core_psct_cse <= (~ and_dcpl_121) | and_dcpl_118;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_dma_read_ctrl_rsci_ivld_core_psct_cse <= 1'b0;
      lfst_exit_LOAD_LOOP_lpi_1_1 <= 1'b0;
      lfst_exit_LOAD_LOOP_lpi_1_0 <= 1'b0;
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1 <= 1'b0;
    end
    else if ( core_wen ) begin
      reg_dma_read_ctrl_rsci_ivld_core_psct_cse <= mux_tmp_179 & or_dcpl_3 & or_50_cse
          & (fsm_output[1]);
      lfst_exit_LOAD_LOOP_lpi_1_1 <= lfst_exit_LOAD_LOOP_lpi_1_1_mx0;
      lfst_exit_LOAD_LOOP_lpi_1_0 <= lfst_exit_LOAD_LOOP_lpi_1_0_mx0;
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1 <= LOAD_BATCH_LOOP_if_asn_sft_lpi_1_mx0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_plm_in_rsci_ivld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_19 & and_dcpl_26) | and_dcpl_133) ) begin
      reg_plm_in_rsci_ivld_core_psct_cse <= ~ and_dcpl_133;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_asn_itm <= 1'b1;
    end
    else if ( core_wen & ((main_stage_en_4 & (fsm_output[1])) | (main_stage_v_1 &
        main_stage_en_4)) ) begin
      LOAD_BATCH_LOOP_asn_itm <= exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_mx1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_i_4_0_lpi_1_3_0 <= 4'b0000;
      LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm_2 <= 1'b0;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1 <= 1'b0;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0 <= 1'b0;
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2 <= 1'b0;
    end
    else if ( LOAD_LOOP_i_and_2_cse ) begin
      LOAD_LOOP_i_4_0_lpi_1_3_0 <= LOAD_LOOP_i_4_0_lpi_1_3_0_mx0w0;
      LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm_2 <= LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm_1;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1 <= lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0 <= lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0;
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2 <= LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_LOAD_BATCH_LOOP_lpi_1_dfm_3 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_149 & or_50_cse & (fsm_output[1])) | (mux_217_nl
        & or_dcpl_3 & or_50_cse & main_stage_v_1) | and_dcpl_118) ) begin
      exit_LOAD_BATCH_LOOP_lpi_1_dfm_3 <= MUX_s_1_2_2(exit_LOAD_BATCH_LOOP_lpi_1_dfm_4,
          LOAD_LOOP_mux_68_nl, and_dcpl_118);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_b_4_0_lpi_1_3_0 <= 4'b0000;
    end
    else if ( core_wen & ((mux_224_nl & or_dcpl_3 & or_50_cse & (LOAD_LOOP_acc_1_tmp[4])
        & (~ exit_LOAD_BATCH_LOOP_lpi_1_dfm_3) & (~ exitL_exit_LOAD_BATCH_LOOP_sva))
        | LOAD_BATCH_LOOP_b_4_0_lpi_1_3_0_mx0c1) ) begin
      LOAD_BATCH_LOOP_b_4_0_lpi_1_3_0 <= MUX_v_4_2_2((LOAD_BATCH_LOOP_acc_1_tmp[3:0]),
          LOAD_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_mx0w0, LOAD_BATCH_LOOP_b_4_0_lpi_1_3_0_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      batch_lpi_1_dfm <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & exitL_exit_LOAD_BATCH_LOOP_sva ) begin
      batch_lpi_1_dfm <= conf_info_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exitL_exit_LOAD_LOOP_lpi_1_dfm <= 1'b0;
    end
    else if ( LOAD_LOOP_and_63_cse ) begin
      exitL_exit_LOAD_LOOP_lpi_1_dfm <= exitL_exit_LOAD_LOOP_lpi_1_dfm_mx1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_1 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_139 & or_50_cse & (fsm_output[1])) | main_stage_v_1_mx0c1)
        ) begin
      main_stage_v_1 <= ~ main_stage_v_1_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 <= 1'b0;
    end
    else if ( core_wen & (((~ main_stage_v_1) & and_dcpl_164 & nor_101_cse) | and_dcpl_166)
        ) begin
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 <= MUX_s_1_2_2(LOAD_BATCH_LOOP_if_asn_sft_lpi_1,
          exit_LOAD_BATCH_LOOP_lpi_1_dfm_4, and_dcpl_166);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_or_tmp_1 <= 1'b0;
      LOAD_LOOP_equal_tmp_1 <= 1'b0;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_2_1_1 <= 1'b0;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_1_1 <= 1'b0;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_1_0 <= 1'b0;
    end
    else if ( LOAD_LOOP_and_cse ) begin
      LOAD_LOOP_or_tmp_1 <= (lfst_exit_LOAD_LOOP_lpi_1_dfm_0_mx0w0 & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_1_mx0w0))
          | (~(lfst_exit_LOAD_LOOP_lpi_1_dfm_1_mx0w0 | lfst_exit_LOAD_LOOP_lpi_1_dfm_0_mx0w0));
      LOAD_LOOP_equal_tmp_1 <= lfst_exit_LOAD_LOOP_lpi_1_dfm_1_mx0w0 & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_0_mx0w0);
      lfst_exit_LOAD_LOOP_lpi_1_dfm_2_1_1 <= ~ (LOAD_LOOP_acc_1_tmp[4]);
      lfst_exit_LOAD_LOOP_lpi_1_dfm_1_1 <= lfst_exit_LOAD_LOOP_lpi_1_dfm_1_mx0w0;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_1_0 <= lfst_exit_LOAD_LOOP_lpi_1_dfm_0_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_i_4_0_sva_1_1_3_0 <= 4'b0000;
    end
    else if ( core_wen & (~((~ mux_240_nl) | and_dcpl_10)) ) begin
      LOAD_LOOP_i_4_0_sva_1_1_3_0 <= LOAD_LOOP_acc_1_tmp[3:0];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_0_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_242_nl) | or_dcpl_39)) ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_0_lpi_1 <= dma_read_chnl_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_14_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_244_nl) | or_dcpl_39)) ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_14_lpi_1 <= dma_read_chnl_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_1_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_246_nl) | or_dcpl_39)) ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_1_lpi_1 <= dma_read_chnl_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_13_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_248_nl) | or_dcpl_39)) ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_13_lpi_1 <= dma_read_chnl_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_2_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_250_nl) | or_dcpl_39)) ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_2_lpi_1 <= dma_read_chnl_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_12_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_252_nl) | or_dcpl_39)) ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_12_lpi_1 <= dma_read_chnl_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_3_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_254_nl) | or_dcpl_39)) ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_3_lpi_1 <= dma_read_chnl_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_11_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_256_nl) | or_dcpl_39)) ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_11_lpi_1 <= dma_read_chnl_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_4_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_258_nl) | or_dcpl_39)) ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_4_lpi_1 <= dma_read_chnl_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_10_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_260_nl) | or_dcpl_39)) ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_10_lpi_1 <= dma_read_chnl_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_5_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_262_nl) | or_dcpl_39)) ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_5_lpi_1 <= dma_read_chnl_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_9_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_264_nl) | or_dcpl_39)) ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_9_lpi_1 <= dma_read_chnl_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_6_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_266_nl) | or_dcpl_39)) ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_6_lpi_1 <= dma_read_chnl_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_8_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_268_nl) | or_dcpl_39)) ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_8_lpi_1 <= dma_read_chnl_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_7_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_270_nl) | or_dcpl_39)) ) begin
      LOAD_BATCH_LOOP_plm_tmp_data_7_lpi_1 <= dma_read_chnl_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm_1 <= 1'b0;
      exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_1 <= 1'b0;
    end
    else if ( LOAD_LOOP_i_and_4_cse ) begin
      LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm_1 <= MUX_s_1_2_2((LOAD_LOOP_acc_1_tmp[4]),
          LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm, and_dcpl_149);
      exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_1 <= MUX_s_1_2_2(exit_LOAD_BATCH_LOOP_lpi_1_dfm_4,
          LOAD_LOOP_mux_22_nl, and_dcpl_167);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1 <= 1'b0;
    end
    else if ( core_wen & (and_354_cse | (mux_276_cse & or_dcpl_3 & or_50_cse & main_stage_v_1)
        | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1_mx0c1) ) begin
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1 <= MUX_s_1_2_2(lfst_exit_LOAD_LOOP_lpi_1_dfm_1_mx0w0,
          lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0 <= 1'b0;
    end
    else if ( core_wen & (and_354_cse | and_356_cse) ) begin
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0 <= MUX_s_1_2_2(lfst_exit_LOAD_LOOP_lpi_1_dfm_0_mx0w0,
          lfst_exit_LOAD_LOOP_lpi_1_dfm_st_0, and_356_cse);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_164 & or_50_cse & nor_101_cse) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1)
        ) begin
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 <= MUX_s_1_2_2(LOAD_BATCH_LOOP_if_asn_sft_lpi_1_mx0,
          exit_LOAD_BATCH_LOOP_lpi_1_dfm_4, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_2 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_144 & main_stage_v_1) | main_stage_v_2_mx0c1)
        ) begin
      main_stage_v_2 <= ~ main_stage_v_2_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_2 <= 1'b0;
    end
    else if ( core_wen & (~ or_dcpl_13) ) begin
      exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_2 <= exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_3 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_106 & main_stage_v_2) | main_stage_v_3_mx0c1)
        ) begin
      main_stage_v_3 <= ~ main_stage_v_3_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_3 <= 1'b0;
    end
    else if ( core_wen & (~(and_dcpl_113 | and_dcpl_10 | (~ main_stage_v_2))) ) begin
      exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_3 <= exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_2;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1 <= 1'b0;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_0 <= 1'b0;
    end
    else if ( LOAD_LOOP_and_91_cse ) begin
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1 <= lfst_exit_LOAD_LOOP_lpi_1_dfm_1_mx0w0;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_0 <= lfst_exit_LOAD_LOOP_lpi_1_dfm_0_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_and_25_psp <= 1'b0;
      LOAD_LOOP_and_23_psp <= 1'b0;
      LOAD_LOOP_and_21_psp <= 1'b0;
      LOAD_LOOP_and_19_psp <= 1'b0;
      LOAD_LOOP_and_17_psp <= 1'b0;
      LOAD_LOOP_and_15_psp <= 1'b0;
      LOAD_LOOP_and_13_psp <= 1'b0;
      LOAD_LOOP_and_12_psp <= 1'b0;
      LOAD_LOOP_and_14_psp <= 1'b0;
      LOAD_LOOP_and_16_psp <= 1'b0;
      LOAD_LOOP_and_18_psp <= 1'b0;
      LOAD_LOOP_and_20_psp <= 1'b0;
      LOAD_LOOP_and_22_psp <= 1'b0;
      LOAD_LOOP_and_24_psp <= 1'b0;
      LOAD_LOOP_and_26_psp <= 1'b0;
    end
    else if ( LOAD_LOOP_and_93_cse ) begin
      LOAD_LOOP_and_25_psp <= LOAD_LOOP_and_stg_2_6_sva_1 & (LOAD_LOOP_i_4_0_lpi_1_3_0[3]);
      LOAD_LOOP_and_23_psp <= LOAD_LOOP_and_stg_2_5_sva_1 & (LOAD_LOOP_i_4_0_lpi_1_3_0[3]);
      LOAD_LOOP_and_21_psp <= LOAD_LOOP_and_stg_2_4_sva_1 & (LOAD_LOOP_i_4_0_lpi_1_3_0[3]);
      LOAD_LOOP_and_19_psp <= LOAD_LOOP_and_stg_2_3_sva_1 & (LOAD_LOOP_i_4_0_lpi_1_3_0[3]);
      LOAD_LOOP_and_17_psp <= LOAD_LOOP_and_stg_2_2_sva_1 & (LOAD_LOOP_i_4_0_lpi_1_3_0[3]);
      LOAD_LOOP_and_15_psp <= LOAD_LOOP_and_stg_2_1_sva_1 & (LOAD_LOOP_i_4_0_lpi_1_3_0[3]);
      LOAD_LOOP_and_13_psp <= LOAD_LOOP_and_stg_2_0_sva_1 & (LOAD_LOOP_i_4_0_lpi_1_3_0[3]);
      LOAD_LOOP_and_12_psp <= and_410_cse & (LOAD_LOOP_i_4_0_lpi_1_3_0[3:2]==2'b01);
      LOAD_LOOP_and_14_psp <= LOAD_LOOP_and_stg_2_6_sva_1 & (~ (LOAD_LOOP_i_4_0_lpi_1_3_0[3]));
      LOAD_LOOP_and_16_psp <= LOAD_LOOP_and_stg_2_5_sva_1 & (~ (LOAD_LOOP_i_4_0_lpi_1_3_0[3]));
      LOAD_LOOP_and_18_psp <= LOAD_LOOP_and_stg_2_4_sva_1 & (~ (LOAD_LOOP_i_4_0_lpi_1_3_0[3]));
      LOAD_LOOP_and_20_psp <= LOAD_LOOP_and_stg_2_3_sva_1 & (~ (LOAD_LOOP_i_4_0_lpi_1_3_0[3]));
      LOAD_LOOP_and_22_psp <= LOAD_LOOP_and_stg_2_2_sva_1 & (~ (LOAD_LOOP_i_4_0_lpi_1_3_0[3]));
      LOAD_LOOP_and_24_psp <= LOAD_LOOP_and_stg_2_1_sva_1 & (~ (LOAD_LOOP_i_4_0_lpi_1_3_0[3]));
      LOAD_LOOP_and_26_psp <= LOAD_LOOP_and_stg_2_0_sva_1 & (~ (LOAD_LOOP_i_4_0_lpi_1_3_0[3]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm <= 1'b0;
    end
    else if ( LOAD_LOOP_and_63_cse & (~(mux_297_nl | and_dcpl_10 | or_76_cse)) )
        begin
      LOAD_LOOP_i_slc_LOAD_LOOP_i_4_0_4_itm <= LOAD_LOOP_acc_1_tmp[4];
    end
  end
  assign LOAD_LOOP_mux_68_nl = MUX_s_1_2_2(exit_LOAD_BATCH_LOOP_lpi_1_dfm_4, (LOAD_BATCH_LOOP_acc_1_tmp[4]),
      LOAD_LOOP_acc_1_tmp[4]);
  assign mux_217_nl = MUX_s_1_2_2(mux_tmp_140, mux_tmp_136, or_446_cse);
  assign nor_81_nl = ~(or_tmp_232 | (~ or_19_cse));
  assign and_246_nl = lfst_exit_LOAD_LOOP_lpi_1_dfm_2_1_1 & mux_tmp_135;
  assign mux_223_nl = MUX_s_1_2_2(and_246_nl, mux_tmp_189, LOAD_LOOP_or_tmp_1);
  assign nor_82_nl = ~(or_tmp_100 | (~ mux_223_nl));
  assign mux_224_nl = MUX_s_1_2_2(nor_81_nl, nor_82_nl, main_stage_v_1);
  assign mux_240_nl = MUX_s_1_2_2(or_19_cse, mux_tmp_135, main_stage_v_1);
  assign mux_241_nl = MUX_s_1_2_2(not_tmp_134, or_tmp_250, LOAD_LOOP_and_26_psp);
  assign and_264_nl = LOAD_LOOP_and_26_psp & or_tmp_248;
  assign mux_242_nl = MUX_s_1_2_2(mux_241_nl, and_264_nl, or_303_cse);
  assign mux_243_nl = MUX_s_1_2_2(not_tmp_136, or_tmp_253, LOAD_LOOP_and_25_psp);
  assign and_265_nl = LOAD_LOOP_and_25_psp & or_tmp_248;
  assign mux_244_nl = MUX_s_1_2_2(mux_243_nl, and_265_nl, or_309_cse);
  assign and_266_nl = LOAD_LOOP_and_24_psp & or_tmp_248;
  assign mux_245_nl = MUX_s_1_2_2(not_tmp_134, or_tmp_250, LOAD_LOOP_and_24_psp);
  assign mux_246_nl = MUX_s_1_2_2(and_266_nl, mux_245_nl, nor_57_cse);
  assign and_267_nl = LOAD_LOOP_and_23_psp & or_tmp_248;
  assign mux_247_nl = MUX_s_1_2_2(not_tmp_136, or_tmp_253, LOAD_LOOP_and_23_psp);
  assign mux_248_nl = MUX_s_1_2_2(and_267_nl, mux_247_nl, nor_57_cse);
  assign mux_249_nl = MUX_s_1_2_2(not_tmp_134, or_tmp_250, LOAD_LOOP_and_22_psp);
  assign and_268_nl = LOAD_LOOP_and_22_psp & or_tmp_248;
  assign mux_250_nl = MUX_s_1_2_2(mux_249_nl, and_268_nl, or_309_cse);
  assign mux_251_nl = MUX_s_1_2_2(not_tmp_136, or_tmp_253, LOAD_LOOP_and_21_psp);
  assign and_269_nl = LOAD_LOOP_and_21_psp & or_tmp_248;
  assign mux_252_nl = MUX_s_1_2_2(mux_251_nl, and_269_nl, or_303_cse);
  assign and_270_nl = LOAD_LOOP_and_20_psp & or_tmp_248;
  assign mux_253_nl = MUX_s_1_2_2(not_tmp_134, or_tmp_250, LOAD_LOOP_and_20_psp);
  assign mux_254_nl = MUX_s_1_2_2(and_270_nl, mux_253_nl, and_410_cse);
  assign and_271_nl = LOAD_LOOP_and_19_psp & or_tmp_248;
  assign mux_255_nl = MUX_s_1_2_2(not_tmp_143, or_tmp_257, LOAD_LOOP_and_19_psp);
  assign mux_256_nl = MUX_s_1_2_2(and_271_nl, mux_255_nl, and_410_cse);
  assign mux_257_nl = MUX_s_1_2_2(not_tmp_145, or_tmp_261, LOAD_LOOP_and_18_psp);
  assign and_272_nl = LOAD_LOOP_and_18_psp & or_tmp_248;
  assign mux_258_nl = MUX_s_1_2_2(mux_257_nl, and_272_nl, or_303_cse);
  assign mux_259_nl = MUX_s_1_2_2(not_tmp_143, or_tmp_257, LOAD_LOOP_and_17_psp);
  assign and_273_nl = LOAD_LOOP_and_17_psp & or_tmp_248;
  assign mux_260_nl = MUX_s_1_2_2(mux_259_nl, and_273_nl, or_309_cse);
  assign and_274_nl = LOAD_LOOP_and_16_psp & or_tmp_248;
  assign mux_261_nl = MUX_s_1_2_2(not_tmp_145, or_tmp_261, LOAD_LOOP_and_16_psp);
  assign mux_262_nl = MUX_s_1_2_2(and_274_nl, mux_261_nl, nor_57_cse);
  assign and_275_nl = LOAD_LOOP_and_15_psp & or_tmp_248;
  assign mux_263_nl = MUX_s_1_2_2(not_tmp_143, or_tmp_257, LOAD_LOOP_and_15_psp);
  assign mux_264_nl = MUX_s_1_2_2(and_275_nl, mux_263_nl, nor_57_cse);
  assign mux_265_nl = MUX_s_1_2_2(not_tmp_145, or_tmp_261, LOAD_LOOP_and_14_psp);
  assign and_276_nl = LOAD_LOOP_and_14_psp & or_tmp_248;
  assign mux_266_nl = MUX_s_1_2_2(mux_265_nl, and_276_nl, or_309_cse);
  assign mux_267_nl = MUX_s_1_2_2(not_tmp_143, or_tmp_257, LOAD_LOOP_and_13_psp);
  assign and_277_nl = LOAD_LOOP_and_13_psp & or_tmp_248;
  assign mux_268_nl = MUX_s_1_2_2(mux_267_nl, and_277_nl, or_303_cse);
  assign and_278_nl = LOAD_LOOP_and_12_psp & or_tmp_248;
  assign mux_269_nl = MUX_s_1_2_2(not_tmp_145, or_tmp_261, LOAD_LOOP_and_12_psp);
  assign mux_270_nl = MUX_s_1_2_2(and_278_nl, mux_269_nl, and_410_cse);
  assign LOAD_LOOP_mux_22_nl = MUX_s_1_2_2(exit_LOAD_BATCH_LOOP_lpi_1_dfm_4, (LOAD_BATCH_LOOP_acc_1_tmp[4]),
      LOAD_LOOP_acc_1_tmp[4]);
  assign and_407_nl = lfst_exit_LOAD_LOOP_lpi_1_dfm_2_1_1 & (~(and_440_cse | (~((lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1
      | dma_read_ctrl_rsci_bawt) & or_19_cse))));
  assign mux_295_nl = MUX_s_1_2_2(and_tmp_78, or_19_cse, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign mux_296_nl = MUX_s_1_2_2(and_407_nl, mux_295_nl, LOAD_LOOP_or_tmp_1);
  assign or_395_nl = or_tmp_100 | (~ mux_296_nl);
  assign mux_297_nl = MUX_s_1_2_2(or_tmp_201, or_395_nl, main_stage_v_1);

  function automatic [3:0] MUX1HOT_v_4_3_2;
    input [3:0] input_2;
    input [3:0] input_1;
    input [3:0] input_0;
    input [2:0] sel;
    reg [3:0] result;
  begin
    result = input_0 & {4{sel[0]}};
    result = result | ( input_1 & {4{sel[1]}});
    result = result | ( input_2 & {4{sel[2]}});
    MUX1HOT_v_4_3_2 = result;
  end
  endfunction


  function automatic [0:0] MUX_s_1_2_2;
    input [0:0] input_0;
    input [0:0] input_1;
    input [0:0] sel;
    reg [0:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [0:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction


  function automatic [3:0] MUX_v_4_2_2;
    input [3:0] input_0;
    input [3:0] input_1;
    input [0:0] sel;
    reg [3:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_4_2_2 = result;
  end
  endfunction


  function automatic [0:0] readslicef_33_1_32;
    input [32:0] vector;
    reg [32:0] tmp;
  begin
    tmp = vector >> 32;
    readslicef_33_1_32 = tmp[0:0];
  end
  endfunction


  function automatic [3:0] signext_4_1;
    input [0:0] vector;
  begin
    signext_4_1= {{3{vector[0]}}, vector};
  end
  endfunction


  function automatic [4:0] conv_u2u_4_5 ;
    input [3:0]  vector ;
  begin
    conv_u2u_4_5 = {1'b0, vector};
  end
  endfunction


  function automatic [32:0] conv_u2u_32_33 ;
    input [31:0]  vector ;
  begin
    conv_u2u_32_33 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute_core (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, plm_in_rsc_dat,
      plm_in_rsc_vld, plm_in_rsc_rdy, plm_out_rsc_dat, plm_out_rsc_vld, plm_out_rsc_rdy,
      done_rsc_rdy, done_rsc_vld, CALC_SOFTMAX_LOOP_mul_cmp_a, CALC_SOFTMAX_LOOP_mul_cmp_b,
      CALC_SOFTMAX_LOOP_mul_cmp_en, CALC_SOFTMAX_LOOP_mul_cmp_z
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  input [511:0] plm_in_rsc_dat;
  input plm_in_rsc_vld;
  output plm_in_rsc_rdy;
  output [511:0] plm_out_rsc_dat;
  output plm_out_rsc_vld;
  input plm_out_rsc_rdy;
  input done_rsc_rdy;
  output done_rsc_vld;
  output [66:0] CALC_SOFTMAX_LOOP_mul_cmp_a;
  output [90:0] CALC_SOFTMAX_LOOP_mul_cmp_b;
  output CALC_SOFTMAX_LOOP_mul_cmp_en;
  input [91:0] CALC_SOFTMAX_LOOP_mul_cmp_z;


  // Interconnect Declarations
  wire core_wen;
  wire conf_info_rsci_bawt;
  reg conf_info_rsci_iswt0;
  wire core_wten;
  wire conf_info_rsci_wen_comp;
  reg conf_info_rsci_irdy_core_psct;
  wire conf_info_rsci_ivld;
  wire conf_info_rsci_ivld_oreg;
  wire [31:0] conf_info_rsci_idat_mxwt;
  wire plm_in_rsci_bawt;
  reg plm_in_rsci_iswt0;
  wire plm_in_rsci_wen_comp;
  reg plm_in_rsci_irdy_core_psct;
  wire plm_in_rsci_ivld;
  wire plm_in_rsci_ivld_oreg;
  wire [511:0] plm_in_rsci_idat_mxwt;
  wire plm_out_rsci_irdy;
  wire plm_out_rsci_bawt;
  wire plm_out_rsci_wen_comp;
  wire plm_out_rsci_irdy_oreg;
  wire done_rsci_bawt;
  wire done_rsci_wen_comp;
  reg [31:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_b_core;
  wire [46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z;
  wire ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt;
  reg ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_iswt1;
  wire [46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg;
  wire [18:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt;
  reg [31:0] plm_out_rsci_idat_511_480;
  reg [31:0] plm_out_rsci_idat_479_448;
  reg [31:0] plm_out_rsci_idat_447_416;
  reg [31:0] plm_out_rsci_idat_415_384;
  reg [31:0] plm_out_rsci_idat_383_352;
  reg [31:0] plm_out_rsci_idat_351_320;
  reg [31:0] plm_out_rsci_idat_319_288;
  reg [31:0] plm_out_rsci_idat_287_256;
  reg [31:0] plm_out_rsci_idat_255_224;
  reg [31:0] plm_out_rsci_idat_223_192;
  reg [31:0] plm_out_rsci_idat_191_160;
  reg [31:0] plm_out_rsci_idat_159_128;
  reg [31:0] plm_out_rsci_idat_127_96;
  reg [31:0] plm_out_rsci_idat_95_64;
  reg [31:0] plm_out_rsci_idat_63_32;
  reg [31:0] plm_out_rsci_idat_31_0;
  wire [1:0] fsm_output;
  wire [4:0] COMPUTE_LOOP_acc_1_tmp;
  wire [5:0] nl_COMPUTE_LOOP_acc_1_tmp;
  wire [4:0] CALC_SOFTMAX_LOOP_acc_1_tmp;
  wire [5:0] nl_CALC_SOFTMAX_LOOP_acc_1_tmp;
  wire or_tmp_5;
  wire or_tmp_89;
  wire or_tmp_152;
  wire and_tmp_26;
  wire and_tmp_27;
  wire or_tmp_166;
  wire or_tmp_167;
  wire and_tmp_30;
  wire and_tmp_31;
  wire and_tmp_33;
  wire and_dcpl_12;
  wire or_tmp_179;
  wire and_tmp_35;
  wire and_tmp_36;
  wire and_tmp_37;
  wire and_tmp_42;
  wire and_tmp_46;
  wire and_tmp_47;
  wire and_tmp_52;
  wire mux_tmp_138;
  wire and_tmp_66;
  wire or_dcpl_13;
  wire or_dcpl_14;
  wire and_dcpl_20;
  wire and_dcpl_23;
  wire or_dcpl_15;
  wire or_dcpl_16;
  wire and_dcpl_25;
  wire or_dcpl_20;
  wire or_dcpl_21;
  wire and_dcpl_114;
  wire and_dcpl_116;
  wire and_tmp_67;
  wire or_tmp_234;
  wire mux_tmp_140;
  wire mux_tmp_142;
  wire mux_tmp_144;
  wire mux_tmp_146;
  wire mux_tmp_148;
  wire mux_tmp_150;
  wire mux_tmp_152;
  wire mux_tmp_154;
  wire mux_tmp_156;
  wire mux_tmp_158;
  wire or_dcpl_27;
  wire and_dcpl_124;
  wire and_dcpl_127;
  wire and_dcpl_129;
  wire and_dcpl_130;
  wire and_dcpl_131;
  wire and_dcpl_132;
  wire and_dcpl_140;
  wire or_tmp_244;
  wire not_tmp_175;
  wire or_tmp_247;
  wire and_dcpl_146;
  wire and_tmp_76;
  wire and_dcpl_151;
  wire and_dcpl_154;
  wire or_tmp_263;
  wire and_dcpl_156;
  wire and_dcpl_158;
  wire or_dcpl_41;
  wire or_dcpl_48;
  wire or_tmp_310;
  wire and_dcpl_171;
  wire and_dcpl_173;
  wire or_tmp_328;
  wire and_tmp_99;
  wire and_tmp_100;
  wire and_tmp_101;
  wire and_dcpl_177;
  wire and_tmp_105;
  wire and_tmp_107;
  wire or_tmp_353;
  wire mux_tmp_234;
  wire and_dcpl_182;
  wire and_dcpl_183;
  wire or_dcpl_52;
  wire and_dcpl_187;
  wire or_tmp_368;
  wire or_tmp_373;
  wire and_dcpl_193;
  wire and_dcpl_195;
  wire and_dcpl_196;
  wire and_tmp_124;
  wire and_dcpl_301;
  wire or_dcpl_89;
  wire or_tmp_416;
  wire and_tmp_126;
  wire and_tmp_129;
  wire and_dcpl_426;
  wire or_dcpl_156;
  wire or_dcpl_158;
  wire or_dcpl_161;
  wire or_dcpl_164;
  wire or_dcpl_167;
  wire or_dcpl_170;
  wire or_dcpl_173;
  wire or_dcpl_176;
  wire or_dcpl_179;
  wire or_dcpl_182;
  wire or_dcpl_185;
  wire or_dcpl_188;
  wire or_dcpl_191;
  wire or_dcpl_194;
  wire or_dcpl_197;
  wire or_dcpl_200;
  wire or_dcpl_203;
  wire and_dcpl_436;
  wire mux_tmp_271;
  wire or_tmp_446;
  wire or_84_cse;
  wire and_620_cse;
  wire and_636_cse;
  wire and_656_cse;
  wire and_654_cse;
  wire main_stage_en_22;
  wire lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_mx0w0;
  wire lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_mx0w0;
  wire lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1_mx0;
  wire lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0_mx0;
  wire exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_mx1;
  wire exitL_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3;
  reg exitL_exit_COMPUTE_LOOP_sva;
  reg COMPUTE_LOOP_asn_itm;
  wire lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3_1_1;
  wire lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3_0_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2_1_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1;
  reg CALC_SOFTMAX_LOOP_equal_tmp_1_1;
  wire CALC_SOFTMAX_LOOP_and_46_ssc_1;
  wire CALC_SOFTMAX_LOOP_and_47_ssc_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_0;
  reg CALC_SOFTMAX_LOOP_or_tmp_1;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1;
  reg main_stage_v_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_3;
  reg main_stage_v_3;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_20;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_20_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_20_0;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_20;
  reg main_stage_v_20;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_21;
  reg main_stage_v_21;
  wire lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_mx1;
  wire lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_mx1;
  wire [4:0] CALC_EXP_LOOP_i_4_0_sva_2;
  wire [5:0] nl_CALC_EXP_LOOP_i_4_0_sva_2;
  wire [4:0] SUM_EXP_LOOP_i_4_0_sva_2;
  wire [5:0] nl_SUM_EXP_LOOP_i_4_0_sva_2;
  wire [3:0] CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0;
  wire COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1;
  wire CALC_SOFTMAX_LOOP_equal_tmp_mx0w0;
  wire CALC_SOFTMAX_LOOP_equal_tmp_1_mx0w0;
  wire [70:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1_dfm_1;
  wire [66:0] operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
  wire [70:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
  wire [71:0] nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
  reg CALC_SOFTMAX_LOOP_equal_tmp_1;
  wire ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_7_sva_1;
  wire ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_6_sva_1;
  wire ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_5_sva_1;
  wire ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_4_sva_1;
  wire ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_3_sva_1;
  wire ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_2_sva_1;
  wire ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_1_sva_1;
  wire ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_0_sva_1;
  wire ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_0_sva_1;
  wire ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_1_sva_1;
  wire ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_2_sva_1;
  wire ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_3_sva_1;
  reg [3:0] CALC_EXP_LOOP_i_4_0_lpi_1_3_0;
  wire CALC_SOFTMAX_LOOP_and_stg_2_0_sva_1;
  wire CALC_SOFTMAX_LOOP_and_stg_2_6_sva_1;
  wire CALC_SOFTMAX_LOOP_and_stg_2_1_sva_1;
  wire CALC_SOFTMAX_LOOP_and_stg_2_5_sva_1;
  wire CALC_SOFTMAX_LOOP_and_stg_2_2_sva_1;
  wire CALC_SOFTMAX_LOOP_and_stg_2_4_sva_1;
  wire CALC_SOFTMAX_LOOP_and_stg_2_3_sva_1;
  wire CALC_SOFTMAX_LOOP_and_stg_1_3_sva_1;
  wire CALC_SOFTMAX_LOOP_and_stg_1_0_sva_1;
  wire CALC_SOFTMAX_LOOP_and_stg_1_1_sva_1;
  wire CALC_SOFTMAX_LOOP_and_stg_1_2_sva_1;
  reg [3:0] CALC_SOFTMAX_LOOP_i_4_0_lpi_1_dfm_1_3_0;
  reg [3:0] CALC_SOFTMAX_LOOP_i_4_0_sva_1_1_3_0;
  reg [3:0] CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_19_0;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_19;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_19;
  reg main_stage_v_19;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_19_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_7;
  reg main_stage_v_7;
  reg main_stage_v_4;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_4;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_5;
  reg main_stage_v_5;
  reg main_stage_v_6;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_6;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_1;
  reg CALC_EXP_LOOP_and_svs_st_6;
  reg CALC_EXP_LOOP_and_svs_st_5;
  reg CALC_EXP_LOOP_and_svs_st_7;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_0;
  reg COMPUTE_LOOP_if_and_71_itm_6;
  reg ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_3;
  reg main_stage_v_8;
  reg COMPUTE_LOOP_if_and_71_itm_7;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_8;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_1;
  reg main_stage_v_9;
  reg main_stage_v_10;
  reg main_stage_v_11;
  reg main_stage_v_13;
  reg main_stage_v_14;
  reg main_stage_v_15;
  reg main_stage_v_16;
  reg main_stage_v_18;
  reg main_stage_v_2;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_2;
  reg CALC_EXP_LOOP_and_svs_st_4;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_3;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_4;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_0;
  reg CALC_SOFTMAX_LOOP_equal_tmp_2;
  reg CALC_SOFTMAX_LOOP_equal_tmp_1_2;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_2;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1;
  reg exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm;
  reg CALC_SOFTMAX_LOOP_and_26_psp_18;
  reg CALC_SOFTMAX_LOOP_and_24_psp_18;
  reg CALC_SOFTMAX_LOOP_and_22_psp_18;
  reg CALC_SOFTMAX_LOOP_and_20_psp_18;
  reg CALC_SOFTMAX_LOOP_and_18_psp_18;
  reg CALC_SOFTMAX_LOOP_and_16_psp_18;
  reg CALC_SOFTMAX_LOOP_and_14_psp_18;
  reg CALC_SOFTMAX_LOOP_and_12_psp_18;
  reg CALC_SOFTMAX_LOOP_and_13_psp_18;
  reg CALC_SOFTMAX_LOOP_and_15_psp_18;
  reg CALC_SOFTMAX_LOOP_and_17_psp_18;
  reg CALC_SOFTMAX_LOOP_and_19_psp_18;
  reg CALC_SOFTMAX_LOOP_and_21_psp_18;
  reg CALC_SOFTMAX_LOOP_and_23_psp_18;
  reg CALC_SOFTMAX_LOOP_and_25_psp_18;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_0;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_9;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_12;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_11;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_10;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_13;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_14_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_14_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_14;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_15_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_15_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_15;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_17_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_17_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_17;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_16;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_16_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_18_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_18_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_18;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_16_1;
  reg main_stage_v_17;
  reg main_stage_v_12;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_20;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1;
  reg [70:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19;
  reg CALC_SOFTMAX_LOOP_equal_tmp_19;
  reg [70:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2;
  reg COMPUTE_LOOP_if_and_70_itm_4;
  reg COMPUTE_LOOP_if_and_69_itm_4;
  reg COMPUTE_LOOP_if_and_68_itm_4;
  reg COMPUTE_LOOP_if_and_67_itm_4;
  reg COMPUTE_LOOP_if_and_66_itm_4;
  reg COMPUTE_LOOP_if_and_65_itm_4;
  reg COMPUTE_LOOP_if_and_64_itm_4;
  reg COMPUTE_LOOP_if_and_63_itm_4;
  reg COMPUTE_LOOP_if_and_62_itm_4;
  reg COMPUTE_LOOP_if_and_61_itm_4;
  reg COMPUTE_LOOP_if_and_60_itm_4;
  reg COMPUTE_LOOP_if_and_59_itm_4;
  reg COMPUTE_LOOP_if_and_58_itm_4;
  reg COMPUTE_LOOP_if_and_57_itm_4;
  reg COMPUTE_LOOP_if_and_56_itm_4;
  reg COMPUTE_LOOP_if_and_55_itm_4;
  reg [3:0] SUM_EXP_LOOP_i_4_0_lpi_1_3_0;
  reg reg_done_rsci_ivld_core_psct_cse;
  reg reg_plm_out_rsci_ivld_core_psct_cse;
  wire nor_43_cse;
  wire COMPUTE_LOOP_and_16_cse;
  wire CALC_SOFTMAX_LOOP_i_and_1_cse;
  wire CALC_SOFTMAX_LOOP_i_and_2_cse;
  wire CALC_SOFTMAX_LOOP_and_56_cse;
  wire CALC_SOFTMAX_LOOP_and_59_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse;
  wire or_143_cse;
  wire or_142_cse;
  wire CALC_SOFTMAX_LOOP_i_and_3_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_and_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_and_2_cse;
  wire or_186_cse;
  wire CALC_SOFTMAX_LOOP_and_62_cse;
  wire or_94_cse;
  wire or_287_cse;
  wire nand_190_cse;
  wire or_238_cse;
  wire and_44_cse;
  wire nor_118_cse;
  wire nor_133_cse;
  wire or_267_cse;
  wire and_260_cse;
  wire or_659_cse;
  wire and_346_cse;
  wire or_520_cse;
  wire or_296_cse;
  wire nand_189_cse;
  wire or_483_cse;
  wire or_482_cse;
  wire ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_4_cse;
  wire ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_5_cse;
  wire ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_6_cse;
  wire ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_7_cse;
  reg reg_CALC_EXP_LOOP_and_svs_1_cse;
  reg reg_lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_cse;
  wire COMPUTE_LOOP_if_nor_2_cse;
  wire and_259_cse;
  wire mux_252_cse;
  reg [66:0] CALC_SOFTMAX_LOOP_mux_40_itm_4;
  reg [90:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_1;
  wire [90:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_1_dfm_1;
  reg [69:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_2_69_0;
  wire [90:0] operator_91_21_false_AC_TRN_AC_WRAP_rshift_itm;
  wire [69:0] operator_71_0_false_AC_TRN_AC_WRAP_lshift_itm;
  reg [31:0] COMPUTE_LOOP_plm_out_tmp_data_7_lpi_1;
  reg [31:0] COMPUTE_LOOP_plm_out_tmp_data_8_lpi_1;
  reg [31:0] COMPUTE_LOOP_plm_out_tmp_data_6_lpi_1;
  reg [31:0] COMPUTE_LOOP_plm_out_tmp_data_9_lpi_1;
  reg [31:0] COMPUTE_LOOP_plm_out_tmp_data_5_lpi_1;
  reg [31:0] COMPUTE_LOOP_plm_out_tmp_data_10_lpi_1;
  reg [31:0] COMPUTE_LOOP_plm_out_tmp_data_4_lpi_1;
  reg [31:0] COMPUTE_LOOP_plm_out_tmp_data_11_lpi_1;
  reg [31:0] COMPUTE_LOOP_plm_out_tmp_data_3_lpi_1;
  reg [31:0] COMPUTE_LOOP_plm_out_tmp_data_12_lpi_1;
  reg [31:0] COMPUTE_LOOP_plm_out_tmp_data_2_lpi_1;
  reg [31:0] COMPUTE_LOOP_plm_out_tmp_data_13_lpi_1;
  reg [31:0] COMPUTE_LOOP_plm_out_tmp_data_1_lpi_1;
  reg [31:0] COMPUTE_LOOP_plm_out_tmp_data_14_lpi_1;
  reg [31:0] COMPUTE_LOOP_plm_out_tmp_data_0_lpi_1;
  reg [511:0] COMPUTE_LOOP_plm_in_tmp_data_lpi_1;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_7_lpi_1;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_8_lpi_1;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_6_lpi_1;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_9_lpi_1;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_5_lpi_1;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_10_lpi_1;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_4_lpi_1;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_11_lpi_1;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_3_lpi_1;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_12_lpi_1;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_2_lpi_1;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_13_lpi_1;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_1_lpi_1;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_14_lpi_1;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_0_lpi_1;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_15_lpi_1;
  reg [70:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1;
  reg [31:0] batch_lpi_1_dfm;
  reg CALC_SOFTMAX_LOOP_and_26_psp;
  reg CALC_SOFTMAX_LOOP_and_24_psp;
  reg CALC_SOFTMAX_LOOP_and_22_psp;
  reg CALC_SOFTMAX_LOOP_and_20_psp;
  reg CALC_SOFTMAX_LOOP_and_18_psp;
  reg CALC_SOFTMAX_LOOP_and_16_psp;
  reg CALC_SOFTMAX_LOOP_and_14_psp;
  reg CALC_SOFTMAX_LOOP_and_12_psp;
  reg CALC_SOFTMAX_LOOP_and_13_psp;
  reg CALC_SOFTMAX_LOOP_and_15_psp;
  reg CALC_SOFTMAX_LOOP_and_17_psp;
  reg CALC_SOFTMAX_LOOP_and_19_psp;
  reg CALC_SOFTMAX_LOOP_and_21_psp;
  reg CALC_SOFTMAX_LOOP_and_23_psp;
  reg CALC_SOFTMAX_LOOP_and_25_psp;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st;
  reg [7:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_69_57_9_0_itm;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm;
  reg [10:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm;
  reg ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm;
  reg CALC_SOFTMAX_LOOP_equal_tmp_1_3;
  reg CALC_SOFTMAX_LOOP_equal_tmp_1_4;
  reg CALC_SOFTMAX_LOOP_equal_tmp_3;
  reg CALC_SOFTMAX_LOOP_equal_tmp_4;
  reg CALC_SOFTMAX_LOOP_equal_tmp_5;
  reg CALC_SOFTMAX_LOOP_equal_tmp_6;
  reg CALC_SOFTMAX_LOOP_equal_tmp_7;
  reg CALC_SOFTMAX_LOOP_equal_tmp_8;
  reg CALC_SOFTMAX_LOOP_equal_tmp_9;
  reg CALC_SOFTMAX_LOOP_equal_tmp_10;
  reg CALC_SOFTMAX_LOOP_equal_tmp_11;
  reg CALC_SOFTMAX_LOOP_equal_tmp_12;
  reg CALC_SOFTMAX_LOOP_equal_tmp_13;
  reg CALC_SOFTMAX_LOOP_equal_tmp_14;
  reg CALC_SOFTMAX_LOOP_equal_tmp_15;
  reg CALC_SOFTMAX_LOOP_equal_tmp_16;
  reg CALC_SOFTMAX_LOOP_equal_tmp_17;
  reg CALC_SOFTMAX_LOOP_equal_tmp_18;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_4;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_5;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_6;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_7;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_8;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_9;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_10;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_11;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_12;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_13;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_14;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_15;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_16;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_17;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_18;
  reg [6:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_sva_1;
  reg CALC_SOFTMAX_LOOP_and_12_psp_1;
  reg CALC_SOFTMAX_LOOP_and_12_psp_2;
  reg CALC_SOFTMAX_LOOP_and_12_psp_3;
  reg CALC_SOFTMAX_LOOP_and_12_psp_4;
  reg CALC_SOFTMAX_LOOP_and_12_psp_5;
  reg CALC_SOFTMAX_LOOP_and_12_psp_6;
  reg CALC_SOFTMAX_LOOP_and_12_psp_7;
  reg CALC_SOFTMAX_LOOP_and_12_psp_8;
  reg CALC_SOFTMAX_LOOP_and_12_psp_9;
  reg CALC_SOFTMAX_LOOP_and_12_psp_10;
  reg CALC_SOFTMAX_LOOP_and_12_psp_11;
  reg CALC_SOFTMAX_LOOP_and_12_psp_12;
  reg CALC_SOFTMAX_LOOP_and_12_psp_13;
  reg CALC_SOFTMAX_LOOP_and_12_psp_14;
  reg CALC_SOFTMAX_LOOP_and_12_psp_15;
  reg CALC_SOFTMAX_LOOP_and_12_psp_16;
  reg CALC_SOFTMAX_LOOP_and_12_psp_17;
  reg CALC_SOFTMAX_LOOP_and_13_psp_1;
  reg CALC_SOFTMAX_LOOP_and_13_psp_2;
  reg CALC_SOFTMAX_LOOP_and_13_psp_3;
  reg CALC_SOFTMAX_LOOP_and_13_psp_4;
  reg CALC_SOFTMAX_LOOP_and_13_psp_5;
  reg CALC_SOFTMAX_LOOP_and_13_psp_6;
  reg CALC_SOFTMAX_LOOP_and_13_psp_7;
  reg CALC_SOFTMAX_LOOP_and_13_psp_8;
  reg CALC_SOFTMAX_LOOP_and_13_psp_9;
  reg CALC_SOFTMAX_LOOP_and_13_psp_10;
  reg CALC_SOFTMAX_LOOP_and_13_psp_11;
  reg CALC_SOFTMAX_LOOP_and_13_psp_12;
  reg CALC_SOFTMAX_LOOP_and_13_psp_13;
  reg CALC_SOFTMAX_LOOP_and_13_psp_14;
  reg CALC_SOFTMAX_LOOP_and_13_psp_15;
  reg CALC_SOFTMAX_LOOP_and_13_psp_16;
  reg CALC_SOFTMAX_LOOP_and_13_psp_17;
  reg CALC_SOFTMAX_LOOP_and_14_psp_1;
  reg CALC_SOFTMAX_LOOP_and_14_psp_2;
  reg CALC_SOFTMAX_LOOP_and_14_psp_3;
  reg CALC_SOFTMAX_LOOP_and_14_psp_4;
  reg CALC_SOFTMAX_LOOP_and_14_psp_5;
  reg CALC_SOFTMAX_LOOP_and_14_psp_6;
  reg CALC_SOFTMAX_LOOP_and_14_psp_7;
  reg CALC_SOFTMAX_LOOP_and_14_psp_8;
  reg CALC_SOFTMAX_LOOP_and_14_psp_9;
  reg CALC_SOFTMAX_LOOP_and_14_psp_10;
  reg CALC_SOFTMAX_LOOP_and_14_psp_11;
  reg CALC_SOFTMAX_LOOP_and_14_psp_12;
  reg CALC_SOFTMAX_LOOP_and_14_psp_13;
  reg CALC_SOFTMAX_LOOP_and_14_psp_14;
  reg CALC_SOFTMAX_LOOP_and_14_psp_15;
  reg CALC_SOFTMAX_LOOP_and_14_psp_16;
  reg CALC_SOFTMAX_LOOP_and_14_psp_17;
  reg CALC_SOFTMAX_LOOP_and_15_psp_1;
  reg CALC_SOFTMAX_LOOP_and_15_psp_2;
  reg CALC_SOFTMAX_LOOP_and_15_psp_3;
  reg CALC_SOFTMAX_LOOP_and_15_psp_4;
  reg CALC_SOFTMAX_LOOP_and_15_psp_5;
  reg CALC_SOFTMAX_LOOP_and_15_psp_6;
  reg CALC_SOFTMAX_LOOP_and_15_psp_7;
  reg CALC_SOFTMAX_LOOP_and_15_psp_8;
  reg CALC_SOFTMAX_LOOP_and_15_psp_9;
  reg CALC_SOFTMAX_LOOP_and_15_psp_10;
  reg CALC_SOFTMAX_LOOP_and_15_psp_11;
  reg CALC_SOFTMAX_LOOP_and_15_psp_12;
  reg CALC_SOFTMAX_LOOP_and_15_psp_13;
  reg CALC_SOFTMAX_LOOP_and_15_psp_14;
  reg CALC_SOFTMAX_LOOP_and_15_psp_15;
  reg CALC_SOFTMAX_LOOP_and_15_psp_16;
  reg CALC_SOFTMAX_LOOP_and_15_psp_17;
  reg CALC_SOFTMAX_LOOP_and_16_psp_1;
  reg CALC_SOFTMAX_LOOP_and_16_psp_2;
  reg CALC_SOFTMAX_LOOP_and_16_psp_3;
  reg CALC_SOFTMAX_LOOP_and_16_psp_4;
  reg CALC_SOFTMAX_LOOP_and_16_psp_5;
  reg CALC_SOFTMAX_LOOP_and_16_psp_6;
  reg CALC_SOFTMAX_LOOP_and_16_psp_7;
  reg CALC_SOFTMAX_LOOP_and_16_psp_8;
  reg CALC_SOFTMAX_LOOP_and_16_psp_9;
  reg CALC_SOFTMAX_LOOP_and_16_psp_10;
  reg CALC_SOFTMAX_LOOP_and_16_psp_11;
  reg CALC_SOFTMAX_LOOP_and_16_psp_12;
  reg CALC_SOFTMAX_LOOP_and_16_psp_13;
  reg CALC_SOFTMAX_LOOP_and_16_psp_14;
  reg CALC_SOFTMAX_LOOP_and_16_psp_15;
  reg CALC_SOFTMAX_LOOP_and_16_psp_16;
  reg CALC_SOFTMAX_LOOP_and_16_psp_17;
  reg CALC_SOFTMAX_LOOP_and_17_psp_1;
  reg CALC_SOFTMAX_LOOP_and_17_psp_2;
  reg CALC_SOFTMAX_LOOP_and_17_psp_3;
  reg CALC_SOFTMAX_LOOP_and_17_psp_4;
  reg CALC_SOFTMAX_LOOP_and_17_psp_5;
  reg CALC_SOFTMAX_LOOP_and_17_psp_6;
  reg CALC_SOFTMAX_LOOP_and_17_psp_7;
  reg CALC_SOFTMAX_LOOP_and_17_psp_8;
  reg CALC_SOFTMAX_LOOP_and_17_psp_9;
  reg CALC_SOFTMAX_LOOP_and_17_psp_10;
  reg CALC_SOFTMAX_LOOP_and_17_psp_11;
  reg CALC_SOFTMAX_LOOP_and_17_psp_12;
  reg CALC_SOFTMAX_LOOP_and_17_psp_13;
  reg CALC_SOFTMAX_LOOP_and_17_psp_14;
  reg CALC_SOFTMAX_LOOP_and_17_psp_15;
  reg CALC_SOFTMAX_LOOP_and_17_psp_16;
  reg CALC_SOFTMAX_LOOP_and_17_psp_17;
  reg CALC_SOFTMAX_LOOP_and_18_psp_1;
  reg CALC_SOFTMAX_LOOP_and_18_psp_2;
  reg CALC_SOFTMAX_LOOP_and_18_psp_3;
  reg CALC_SOFTMAX_LOOP_and_18_psp_4;
  reg CALC_SOFTMAX_LOOP_and_18_psp_5;
  reg CALC_SOFTMAX_LOOP_and_18_psp_6;
  reg CALC_SOFTMAX_LOOP_and_18_psp_7;
  reg CALC_SOFTMAX_LOOP_and_18_psp_8;
  reg CALC_SOFTMAX_LOOP_and_18_psp_9;
  reg CALC_SOFTMAX_LOOP_and_18_psp_10;
  reg CALC_SOFTMAX_LOOP_and_18_psp_11;
  reg CALC_SOFTMAX_LOOP_and_18_psp_12;
  reg CALC_SOFTMAX_LOOP_and_18_psp_13;
  reg CALC_SOFTMAX_LOOP_and_18_psp_14;
  reg CALC_SOFTMAX_LOOP_and_18_psp_15;
  reg CALC_SOFTMAX_LOOP_and_18_psp_16;
  reg CALC_SOFTMAX_LOOP_and_18_psp_17;
  reg CALC_SOFTMAX_LOOP_and_19_psp_1;
  reg CALC_SOFTMAX_LOOP_and_19_psp_2;
  reg CALC_SOFTMAX_LOOP_and_19_psp_3;
  reg CALC_SOFTMAX_LOOP_and_19_psp_4;
  reg CALC_SOFTMAX_LOOP_and_19_psp_5;
  reg CALC_SOFTMAX_LOOP_and_19_psp_6;
  reg CALC_SOFTMAX_LOOP_and_19_psp_7;
  reg CALC_SOFTMAX_LOOP_and_19_psp_8;
  reg CALC_SOFTMAX_LOOP_and_19_psp_9;
  reg CALC_SOFTMAX_LOOP_and_19_psp_10;
  reg CALC_SOFTMAX_LOOP_and_19_psp_11;
  reg CALC_SOFTMAX_LOOP_and_19_psp_12;
  reg CALC_SOFTMAX_LOOP_and_19_psp_13;
  reg CALC_SOFTMAX_LOOP_and_19_psp_14;
  reg CALC_SOFTMAX_LOOP_and_19_psp_15;
  reg CALC_SOFTMAX_LOOP_and_19_psp_16;
  reg CALC_SOFTMAX_LOOP_and_19_psp_17;
  reg CALC_SOFTMAX_LOOP_and_20_psp_1;
  reg CALC_SOFTMAX_LOOP_and_20_psp_2;
  reg CALC_SOFTMAX_LOOP_and_20_psp_3;
  reg CALC_SOFTMAX_LOOP_and_20_psp_4;
  reg CALC_SOFTMAX_LOOP_and_20_psp_5;
  reg CALC_SOFTMAX_LOOP_and_20_psp_6;
  reg CALC_SOFTMAX_LOOP_and_20_psp_7;
  reg CALC_SOFTMAX_LOOP_and_20_psp_8;
  reg CALC_SOFTMAX_LOOP_and_20_psp_9;
  reg CALC_SOFTMAX_LOOP_and_20_psp_10;
  reg CALC_SOFTMAX_LOOP_and_20_psp_11;
  reg CALC_SOFTMAX_LOOP_and_20_psp_12;
  reg CALC_SOFTMAX_LOOP_and_20_psp_13;
  reg CALC_SOFTMAX_LOOP_and_20_psp_14;
  reg CALC_SOFTMAX_LOOP_and_20_psp_15;
  reg CALC_SOFTMAX_LOOP_and_20_psp_16;
  reg CALC_SOFTMAX_LOOP_and_20_psp_17;
  reg CALC_SOFTMAX_LOOP_and_21_psp_1;
  reg CALC_SOFTMAX_LOOP_and_21_psp_2;
  reg CALC_SOFTMAX_LOOP_and_21_psp_3;
  reg CALC_SOFTMAX_LOOP_and_21_psp_4;
  reg CALC_SOFTMAX_LOOP_and_21_psp_5;
  reg CALC_SOFTMAX_LOOP_and_21_psp_6;
  reg CALC_SOFTMAX_LOOP_and_21_psp_7;
  reg CALC_SOFTMAX_LOOP_and_21_psp_8;
  reg CALC_SOFTMAX_LOOP_and_21_psp_9;
  reg CALC_SOFTMAX_LOOP_and_21_psp_10;
  reg CALC_SOFTMAX_LOOP_and_21_psp_11;
  reg CALC_SOFTMAX_LOOP_and_21_psp_12;
  reg CALC_SOFTMAX_LOOP_and_21_psp_13;
  reg CALC_SOFTMAX_LOOP_and_21_psp_14;
  reg CALC_SOFTMAX_LOOP_and_21_psp_15;
  reg CALC_SOFTMAX_LOOP_and_21_psp_16;
  reg CALC_SOFTMAX_LOOP_and_21_psp_17;
  reg CALC_SOFTMAX_LOOP_and_22_psp_1;
  reg CALC_SOFTMAX_LOOP_and_22_psp_2;
  reg CALC_SOFTMAX_LOOP_and_22_psp_3;
  reg CALC_SOFTMAX_LOOP_and_22_psp_4;
  reg CALC_SOFTMAX_LOOP_and_22_psp_5;
  reg CALC_SOFTMAX_LOOP_and_22_psp_6;
  reg CALC_SOFTMAX_LOOP_and_22_psp_7;
  reg CALC_SOFTMAX_LOOP_and_22_psp_8;
  reg CALC_SOFTMAX_LOOP_and_22_psp_9;
  reg CALC_SOFTMAX_LOOP_and_22_psp_10;
  reg CALC_SOFTMAX_LOOP_and_22_psp_11;
  reg CALC_SOFTMAX_LOOP_and_22_psp_12;
  reg CALC_SOFTMAX_LOOP_and_22_psp_13;
  reg CALC_SOFTMAX_LOOP_and_22_psp_14;
  reg CALC_SOFTMAX_LOOP_and_22_psp_15;
  reg CALC_SOFTMAX_LOOP_and_22_psp_16;
  reg CALC_SOFTMAX_LOOP_and_22_psp_17;
  reg CALC_SOFTMAX_LOOP_and_23_psp_1;
  reg CALC_SOFTMAX_LOOP_and_23_psp_2;
  reg CALC_SOFTMAX_LOOP_and_23_psp_3;
  reg CALC_SOFTMAX_LOOP_and_23_psp_4;
  reg CALC_SOFTMAX_LOOP_and_23_psp_5;
  reg CALC_SOFTMAX_LOOP_and_23_psp_6;
  reg CALC_SOFTMAX_LOOP_and_23_psp_7;
  reg CALC_SOFTMAX_LOOP_and_23_psp_8;
  reg CALC_SOFTMAX_LOOP_and_23_psp_9;
  reg CALC_SOFTMAX_LOOP_and_23_psp_10;
  reg CALC_SOFTMAX_LOOP_and_23_psp_11;
  reg CALC_SOFTMAX_LOOP_and_23_psp_12;
  reg CALC_SOFTMAX_LOOP_and_23_psp_13;
  reg CALC_SOFTMAX_LOOP_and_23_psp_14;
  reg CALC_SOFTMAX_LOOP_and_23_psp_15;
  reg CALC_SOFTMAX_LOOP_and_23_psp_16;
  reg CALC_SOFTMAX_LOOP_and_23_psp_17;
  reg CALC_SOFTMAX_LOOP_and_24_psp_1;
  reg CALC_SOFTMAX_LOOP_and_24_psp_2;
  reg CALC_SOFTMAX_LOOP_and_24_psp_3;
  reg CALC_SOFTMAX_LOOP_and_24_psp_4;
  reg CALC_SOFTMAX_LOOP_and_24_psp_5;
  reg CALC_SOFTMAX_LOOP_and_24_psp_6;
  reg CALC_SOFTMAX_LOOP_and_24_psp_7;
  reg CALC_SOFTMAX_LOOP_and_24_psp_8;
  reg CALC_SOFTMAX_LOOP_and_24_psp_9;
  reg CALC_SOFTMAX_LOOP_and_24_psp_10;
  reg CALC_SOFTMAX_LOOP_and_24_psp_11;
  reg CALC_SOFTMAX_LOOP_and_24_psp_12;
  reg CALC_SOFTMAX_LOOP_and_24_psp_13;
  reg CALC_SOFTMAX_LOOP_and_24_psp_14;
  reg CALC_SOFTMAX_LOOP_and_24_psp_15;
  reg CALC_SOFTMAX_LOOP_and_24_psp_16;
  reg CALC_SOFTMAX_LOOP_and_24_psp_17;
  reg CALC_SOFTMAX_LOOP_and_25_psp_1;
  reg CALC_SOFTMAX_LOOP_and_25_psp_2;
  reg CALC_SOFTMAX_LOOP_and_25_psp_3;
  reg CALC_SOFTMAX_LOOP_and_25_psp_4;
  reg CALC_SOFTMAX_LOOP_and_25_psp_5;
  reg CALC_SOFTMAX_LOOP_and_25_psp_6;
  reg CALC_SOFTMAX_LOOP_and_25_psp_7;
  reg CALC_SOFTMAX_LOOP_and_25_psp_8;
  reg CALC_SOFTMAX_LOOP_and_25_psp_9;
  reg CALC_SOFTMAX_LOOP_and_25_psp_10;
  reg CALC_SOFTMAX_LOOP_and_25_psp_11;
  reg CALC_SOFTMAX_LOOP_and_25_psp_12;
  reg CALC_SOFTMAX_LOOP_and_25_psp_13;
  reg CALC_SOFTMAX_LOOP_and_25_psp_14;
  reg CALC_SOFTMAX_LOOP_and_25_psp_15;
  reg CALC_SOFTMAX_LOOP_and_25_psp_16;
  reg CALC_SOFTMAX_LOOP_and_25_psp_17;
  reg CALC_SOFTMAX_LOOP_and_26_psp_1;
  reg CALC_SOFTMAX_LOOP_and_26_psp_2;
  reg CALC_SOFTMAX_LOOP_and_26_psp_3;
  reg CALC_SOFTMAX_LOOP_and_26_psp_4;
  reg CALC_SOFTMAX_LOOP_and_26_psp_5;
  reg CALC_SOFTMAX_LOOP_and_26_psp_6;
  reg CALC_SOFTMAX_LOOP_and_26_psp_7;
  reg CALC_SOFTMAX_LOOP_and_26_psp_8;
  reg CALC_SOFTMAX_LOOP_and_26_psp_9;
  reg CALC_SOFTMAX_LOOP_and_26_psp_10;
  reg CALC_SOFTMAX_LOOP_and_26_psp_11;
  reg CALC_SOFTMAX_LOOP_and_26_psp_12;
  reg CALC_SOFTMAX_LOOP_and_26_psp_13;
  reg CALC_SOFTMAX_LOOP_and_26_psp_14;
  reg CALC_SOFTMAX_LOOP_and_26_psp_15;
  reg CALC_SOFTMAX_LOOP_and_26_psp_16;
  reg CALC_SOFTMAX_LOOP_and_26_psp_17;
  reg [2:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_2_itm_1;
  reg [6:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_3_itm_1;
  reg [8:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_18_10_itm_1;
  reg [9:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm_1;
  reg [6:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_18_12_itm_1;
  reg [7:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_69_57_9_0_itm_1;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1;
  reg [10:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_1;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm_1;
  reg ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_1;
  reg ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_2;
  reg ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_4;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_itm_1;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_itm_2;
  reg [66:0] CALC_SOFTMAX_LOOP_mux_40_itm_1;
  reg [66:0] CALC_SOFTMAX_LOOP_mux_40_itm_2;
  reg COMPUTE_LOOP_if_and_55_itm_1;
  reg COMPUTE_LOOP_if_and_55_itm_2;
  reg COMPUTE_LOOP_if_and_55_itm_3;
  reg COMPUTE_LOOP_if_and_56_itm_1;
  reg COMPUTE_LOOP_if_and_56_itm_2;
  reg COMPUTE_LOOP_if_and_56_itm_3;
  reg COMPUTE_LOOP_if_and_57_itm_1;
  reg COMPUTE_LOOP_if_and_57_itm_2;
  reg COMPUTE_LOOP_if_and_57_itm_3;
  reg COMPUTE_LOOP_if_and_58_itm_1;
  reg COMPUTE_LOOP_if_and_58_itm_2;
  reg COMPUTE_LOOP_if_and_58_itm_3;
  reg COMPUTE_LOOP_if_and_59_itm_1;
  reg COMPUTE_LOOP_if_and_59_itm_2;
  reg COMPUTE_LOOP_if_and_59_itm_3;
  reg COMPUTE_LOOP_if_and_60_itm_1;
  reg COMPUTE_LOOP_if_and_60_itm_2;
  reg COMPUTE_LOOP_if_and_60_itm_3;
  reg COMPUTE_LOOP_if_and_61_itm_1;
  reg COMPUTE_LOOP_if_and_61_itm_2;
  reg COMPUTE_LOOP_if_and_61_itm_3;
  reg COMPUTE_LOOP_if_and_62_itm_1;
  reg COMPUTE_LOOP_if_and_62_itm_2;
  reg COMPUTE_LOOP_if_and_62_itm_3;
  reg COMPUTE_LOOP_if_and_63_itm_1;
  reg COMPUTE_LOOP_if_and_63_itm_2;
  reg COMPUTE_LOOP_if_and_63_itm_3;
  reg COMPUTE_LOOP_if_and_64_itm_1;
  reg COMPUTE_LOOP_if_and_64_itm_2;
  reg COMPUTE_LOOP_if_and_64_itm_3;
  reg COMPUTE_LOOP_if_and_65_itm_1;
  reg COMPUTE_LOOP_if_and_65_itm_2;
  reg COMPUTE_LOOP_if_and_65_itm_3;
  reg COMPUTE_LOOP_if_and_66_itm_1;
  reg COMPUTE_LOOP_if_and_66_itm_2;
  reg COMPUTE_LOOP_if_and_66_itm_3;
  reg COMPUTE_LOOP_if_and_67_itm_1;
  reg COMPUTE_LOOP_if_and_67_itm_2;
  reg COMPUTE_LOOP_if_and_67_itm_3;
  reg COMPUTE_LOOP_if_and_68_itm_1;
  reg COMPUTE_LOOP_if_and_68_itm_2;
  reg COMPUTE_LOOP_if_and_68_itm_3;
  reg COMPUTE_LOOP_if_and_69_itm_1;
  reg COMPUTE_LOOP_if_and_69_itm_2;
  reg COMPUTE_LOOP_if_and_69_itm_3;
  reg COMPUTE_LOOP_if_and_70_itm_1;
  reg COMPUTE_LOOP_if_and_70_itm_2;
  reg COMPUTE_LOOP_if_and_70_itm_3;
  reg COMPUTE_LOOP_if_and_71_itm_1;
  reg COMPUTE_LOOP_if_and_71_itm_2;
  reg COMPUTE_LOOP_if_and_71_itm_3;
  reg COMPUTE_LOOP_if_and_71_itm_4;
  reg COMPUTE_LOOP_if_and_71_itm_5;
  reg CALC_EXP_LOOP_and_svs_st_2;
  reg CALC_EXP_LOOP_and_svs_st_3;
  reg [70:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_1;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_2;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_3;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_4;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_5;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_6;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_7;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_8;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_9;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_10;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_11;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_12;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_13;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_14;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_15;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_16;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_17;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_18;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_1;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_2;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_3;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_4;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_5;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_6;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_7;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_8;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_9;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_10;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_11;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_12;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_13;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_14;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_15;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_16;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_17;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_18;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_19;
  reg [3:0] COMPUTE_LOOP_b_4_0_lpi_1_3_0;
  reg [5:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_7_2;
  reg [1:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_0;
  reg [3:0] CALC_EXP_LOOP_i_4_0_lpi_1_dfm_1_3_0;
  reg [5:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_7_2;
  reg [1:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_1_0;
  reg [5:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_2_7_2;
  reg [1:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_2_1_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_0;
  wire conf_info_rsci_iswt0_mx0c1;
  wire plm_out_rsci_idat_31_0_mx0c1;
  wire plm_out_rsci_idat_63_32_mx0c1;
  wire plm_out_rsci_idat_95_64_mx0c1;
  wire plm_out_rsci_idat_127_96_mx0c1;
  wire plm_out_rsci_idat_159_128_mx0c1;
  wire plm_out_rsci_idat_191_160_mx0c1;
  wire plm_out_rsci_idat_223_192_mx0c1;
  wire plm_out_rsci_idat_255_224_mx0c1;
  wire plm_out_rsci_idat_287_256_mx0c1;
  wire plm_out_rsci_idat_319_288_mx0c1;
  wire plm_out_rsci_idat_351_320_mx0c1;
  wire plm_out_rsci_idat_383_352_mx0c1;
  wire plm_out_rsci_idat_415_384_mx0c1;
  wire plm_out_rsci_idat_447_416_mx0c1;
  wire plm_out_rsci_idat_479_448_mx0c1;
  wire exit_COMPUTE_LOOP_lpi_1_dfm_3_mx0c1;
  wire exit_COMPUTE_LOOP_lpi_1_dfm_3_mx1;
  wire [3:0] CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0_mx0w0;
  wire [3:0] CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0_mx1;
  wire COMPUTE_LOOP_b_4_0_lpi_1_3_0_mx0c1;
  wire COMPUTE_LOOP_if_asn_sft_lpi_1_mx0;
  wire main_stage_v_1_mx0c1;
  wire CALC_EXP_LOOP_and_svs_mx0w0;
  wire COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1;
  wire main_stage_v_2_mx0c1;
  wire main_stage_v_3_mx0c1;
  wire main_stage_v_4_mx0c1;
  wire main_stage_v_5_mx0c1;
  wire main_stage_v_6_mx0c1;
  wire main_stage_v_7_mx0c1;
  wire main_stage_v_8_mx0c1;
  wire [10:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_mx0w0;
  wire [11:0] nl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_mx0w0;
  wire main_stage_v_9_mx0c1;
  wire main_stage_v_10_mx0c1;
  wire main_stage_v_11_mx0c1;
  wire main_stage_v_12_mx0c1;
  wire main_stage_v_13_mx0c1;
  wire main_stage_v_14_mx0c1;
  wire main_stage_v_15_mx0c1;
  wire main_stage_v_16_mx0c1;
  wire main_stage_v_17_mx0c1;
  wire main_stage_v_18_mx0c1;
  wire main_stage_v_19_mx0c1;
  wire main_stage_v_20_mx0c1;
  wire main_stage_v_21_mx0c1;
  wire [5:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_7_2_mx0w0;
  wire [6:0] nl_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_7_2_mx0w0;
  wire [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_mx0w0;
  wire [7:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_mx0w0;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0;
  wire CALC_SOFTMAX_LOOP_and_12_psp_mx0w0;
  wire CALC_SOFTMAX_LOOP_and_13_psp_mx0w0;
  wire CALC_SOFTMAX_LOOP_and_14_psp_mx0w0;
  wire CALC_SOFTMAX_LOOP_and_15_psp_mx0w0;
  wire CALC_SOFTMAX_LOOP_and_16_psp_mx0w0;
  wire CALC_SOFTMAX_LOOP_and_17_psp_mx0w0;
  wire CALC_SOFTMAX_LOOP_and_18_psp_mx0w0;
  wire CALC_SOFTMAX_LOOP_and_19_psp_mx0w0;
  wire CALC_SOFTMAX_LOOP_and_20_psp_mx0w0;
  wire CALC_SOFTMAX_LOOP_and_21_psp_mx0w0;
  wire CALC_SOFTMAX_LOOP_and_22_psp_mx0w0;
  wire CALC_SOFTMAX_LOOP_and_23_psp_mx0w0;
  wire CALC_SOFTMAX_LOOP_and_24_psp_mx0w0;
  wire CALC_SOFTMAX_LOOP_and_25_psp_mx0w0;
  wire CALC_SOFTMAX_LOOP_and_26_psp_mx0w0;
  wire CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_1_mx0c1;
  wire exit_COMPUTE_LOOP_lpi_1_dfm_4;
  wire [3:0] COMPUTE_LOOP_b_4_0_lpi_1_dfm_3_0_1;
  wire [18:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire signed [19:0] nl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire [18:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire [6:0] libraries_leading_sign_71_0_1bc993dc735dc189e3e2a7ebf4857c14bb7e_1;
  wire mux_271_rgt;
  wire and_606_rgt;
  wire CALC_EXP_LOOP_and_3_cse;
  wire CALC_SOFTMAX_LOOP_and_84_cse;
  wire ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_8_cse;
  wire CALC_SOFTMAX_LOOP_and_401_cse;
  wire CALC_SOFTMAX_LOOP_and_416_cse;
  wire COMPUTE_LOOP_if_acc_itm_32_1;

  wire[0:0] mux_169_nl;
  wire[0:0] mux_168_nl;
  wire[0:0] or_340_nl;
  wire[31:0] COMPUTE_LOOP_if_mux_107_nl;
  wire[31:0] COMPUTE_LOOP_if_mux_109_nl;
  wire[31:0] COMPUTE_LOOP_if_mux_110_nl;
  wire[31:0] COMPUTE_LOOP_if_mux_111_nl;
  wire[31:0] COMPUTE_LOOP_if_mux_112_nl;
  wire[31:0] COMPUTE_LOOP_if_mux_113_nl;
  wire[31:0] COMPUTE_LOOP_if_mux_114_nl;
  wire[31:0] COMPUTE_LOOP_if_mux_115_nl;
  wire[31:0] COMPUTE_LOOP_if_mux_116_nl;
  wire[31:0] COMPUTE_LOOP_if_mux_117_nl;
  wire[31:0] COMPUTE_LOOP_if_mux_118_nl;
  wire[31:0] COMPUTE_LOOP_if_mux_119_nl;
  wire[31:0] COMPUTE_LOOP_if_mux_120_nl;
  wire[31:0] COMPUTE_LOOP_if_mux_121_nl;
  wire[31:0] COMPUTE_LOOP_if_mux_122_nl;
  wire[31:0] COMPUTE_LOOP_if_mux_123_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_89_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_mux_410_nl;
  wire[0:0] mux_221_nl;
  wire[0:0] mux_220_nl;
  wire[0:0] mux_219_nl;
  wire[0:0] and_706_nl;
  wire[0:0] mux_218_nl;
  wire[0:0] mux_217_nl;
  wire[0:0] mux_216_nl;
  wire[0:0] nor_44_nl;
  wire[0:0] nor_45_nl;
  wire[0:0] nor_47_nl;
  wire[0:0] nor_48_nl;
  wire[0:0] CALC_EXP_LOOP_not_6_nl;
  wire[0:0] mux_270_nl;
  wire[0:0] or_654_nl;
  wire[0:0] mux_269_nl;
  wire[0:0] mux_268_nl;
  wire[0:0] or_652_nl;
  wire[0:0] COMPUTE_LOOP_if_COMPUTE_LOOP_if_nor_nl;
  wire[0:0] COMPUTE_LOOP_if_COMPUTE_LOOP_if_nor_2_nl;
  wire[0:0] and_601_nl;
  wire[0:0] or_671_nl;
  wire[66:0] CALC_SOFTMAX_LOOP_mux_101_nl;
  wire[66:0] COMPUTE_LOOP_if_mux_187_nl;
  wire[66:0] COMPUTE_LOOP_if_mux_185_nl;
  wire[66:0] COMPUTE_LOOP_if_mux_183_nl;
  wire[66:0] COMPUTE_LOOP_if_mux_181_nl;
  wire[66:0] COMPUTE_LOOP_if_mux_179_nl;
  wire[66:0] COMPUTE_LOOP_if_mux_177_nl;
  wire[66:0] COMPUTE_LOOP_if_mux_175_nl;
  wire[66:0] COMPUTE_LOOP_if_mux_173_nl;
  wire[66:0] COMPUTE_LOOP_if_mux_171_nl;
  wire[66:0] COMPUTE_LOOP_if_mux_169_nl;
  wire[66:0] COMPUTE_LOOP_if_mux_167_nl;
  wire[66:0] COMPUTE_LOOP_if_mux_165_nl;
  wire[66:0] COMPUTE_LOOP_if_mux_163_nl;
  wire[66:0] COMPUTE_LOOP_if_mux_161_nl;
  wire[66:0] COMPUTE_LOOP_if_mux_159_nl;
  wire[66:0] COMPUTE_LOOP_if_mux_157_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_68_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_mux_21_nl;
  wire[0:0] mux_282_nl;
  wire[0:0] mux_281_nl;
  wire[0:0] or_747_nl;
  wire[0:0] or_746_nl;
  wire[0:0] or_742_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_88_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_mux_409_nl;
  wire[0:0] COMPUTE_LOOP_if_and_nl;
  wire[0:0] COMPUTE_LOOP_if_and_36_nl;
  wire[0:0] COMPUTE_LOOP_if_or_16_nl;
  wire[0:0] COMPUTE_LOOP_if_COMPUTE_LOOP_if_COMPUTE_LOOP_if_or_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_not_4_nl;
  wire[32:0] COMPUTE_LOOP_if_acc_nl;
  wire[33:0] nl_COMPUTE_LOOP_if_acc_nl;
  wire[31:0] mux_8_nl;
  wire[0:0] COMPUTE_LOOP_not_12_nl;
  wire[0:0] or_755_nl;
  wire[0:0] mux_288_nl;
  wire[0:0] mux_287_nl;
  wire[0:0] mux_286_nl;
  wire[0:0] mux_285_nl;
  wire[0:0] or_754_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_mux_408_nl;
  wire[3:0] COMPUTE_LOOP_if_COMPUTE_LOOP_if_and_2_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_not_nl;
  wire[4:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_7_nl;
  wire[2:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_1_nl;
  wire[0:0] nor_135_nl;
  wire[0:0] mux_148_nl;
  wire[0:0] and_712_nl;
  wire[0:0] or_350_nl;
  wire[0:0] mux_150_nl;
  wire[0:0] or_349_nl;
  wire[0:0] mux_152_nl;
  wire[0:0] or_348_nl;
  wire[0:0] mux_154_nl;
  wire[0:0] or_347_nl;
  wire[0:0] mux_156_nl;
  wire[0:0] or_346_nl;
  wire[0:0] mux_158_nl;
  wire[0:0] or_345_nl;
  wire[0:0] mux_160_nl;
  wire[0:0] or_344_nl;
  wire[0:0] mux_162_nl;
  wire[0:0] or_343_nl;
  wire[0:0] mux_164_nl;
  wire[0:0] or_342_nl;
  wire[0:0] mux_166_nl;
  wire[0:0] or_341_nl;
  wire[0:0] mux_179_nl;
  wire[0:0] mux_178_nl;
  wire[0:0] and_262_nl;
  wire[0:0] mux_177_nl;
  wire[0:0] mux_176_nl;
  wire[0:0] mux_175_nl;
  wire[0:0] nor_128_nl;
  wire[0:0] nor_129_nl;
  wire[0:0] mux_184_nl;
  wire[0:0] mux_183_nl;
  wire[0:0] and_270_nl;
  wire[0:0] mux_182_nl;
  wire[0:0] mux_181_nl;
  wire[0:0] mux_180_nl;
  wire[0:0] nor_126_nl;
  wire[0:0] nor_127_nl;
  wire[0:0] and_268_nl;
  wire[0:0] and_267_nl;
  wire[0:0] mux_189_nl;
  wire[0:0] mux_188_nl;
  wire[0:0] mux_207_nl;
  wire[0:0] mux_206_nl;
  wire[0:0] mux_205_nl;
  wire[0:0] or_388_nl;
  wire[0:0] mux_215_nl;
  wire[0:0] mux_214_nl;
  wire[0:0] mux_213_nl;
  wire[0:0] and_710_nl;
  wire[0:0] mux_212_nl;
  wire[0:0] mux_211_nl;
  wire[0:0] mux_210_nl;
  wire[0:0] nor_119_nl;
  wire[0:0] nor_120_nl;
  wire[0:0] nor_122_nl;
  wire[0:0] nor_123_nl;
  wire[0:0] mux_229_nl;
  wire[0:0] mux_228_nl;
  wire[0:0] mux_227_nl;
  wire[0:0] nor_117_nl;
  wire[0:0] mux_226_nl;
  wire[0:0] mux_225_nl;
  wire[0:0] mux_224_nl;
  wire[0:0] and_324_nl;
  wire[0:0] and_323_nl;
  wire[0:0] mux_223_nl;
  wire[0:0] mux_222_nl;
  wire[0:0] mux_242_nl;
  wire[0:0] mux_241_nl;
  wire[0:0] nor_130_nl;
  wire[0:0] mux_240_nl;
  wire[0:0] mux_239_nl;
  wire[0:0] mux_238_nl;
  wire[0:0] nor_131_nl;
  wire[0:0] nor_132_nl;
  wire[0:0] or_495_nl;
  wire[0:0] mux_246_nl;
  wire[0:0] nor_113_nl;
  wire[0:0] and_709_nl;
  wire[0:0] mux_245_nl;
  wire[0:0] mux_244_nl;
  wire[0:0] nor_114_nl;
  wire[0:0] nor_115_nl;
  wire[0:0] nor_116_nl;
  wire[0:0] mux_257_nl;
  wire[0:0] nor_109_nl;
  wire[0:0] mux_256_nl;
  wire[0:0] and_708_nl;
  wire[0:0] mux_255_nl;
  wire[0:0] nor_110_nl;
  wire[0:0] nor_111_nl;
  wire[0:0] nor_112_nl;
  wire[0:0] mux_279_nl;
  wire[0:0] mux_111_nl;
  wire[0:0] mux_110_nl;
  wire[0:0] mux_109_nl;
  wire[0:0] mux_108_nl;
  wire[0:0] or_284_nl;
  wire[0:0] mux_107_nl;
  wire[0:0] mux_106_nl;
  wire[0:0] mux_105_nl;
  wire[0:0] mux_104_nl;
  wire[0:0] mux_103_nl;
  wire[0:0] mux_102_nl;
  wire[0:0] mux_101_nl;
  wire[0:0] nor_137_nl;
  wire[0:0] nor_138_nl;
  wire[0:0] or_278_nl;
  wire[0:0] mux_100_nl;
  wire[0:0] mux_99_nl;
  wire[0:0] and_713_nl;
  wire[0:0] nor_139_nl;
  wire[0:0] mux_98_nl;
  wire[0:0] mux_97_nl;
  wire[0:0] and_83_nl;
  wire[0:0] and_82_nl;
  wire[0:0] mux_121_nl;
  wire[0:0] mux_120_nl;
  wire[0:0] mux_119_nl;
  wire[0:0] and_100_nl;
  wire[0:0] mux_118_nl;
  wire[0:0] mux_117_nl;
  wire[0:0] and_99_nl;
  wire[0:0] mux_116_nl;
  wire[0:0] mux_115_nl;
  wire[0:0] mux_114_nl;
  wire[0:0] mux_113_nl;
  wire[0:0] mux_112_nl;
  wire[0:0] and_97_nl;
  wire[0:0] and_95_nl;
  wire[0:0] and_94_nl;
  wire[0:0] mux_131_nl;
  wire[0:0] mux_130_nl;
  wire[0:0] mux_129_nl;
  wire[0:0] and_113_nl;
  wire[0:0] mux_128_nl;
  wire[0:0] mux_127_nl;
  wire[0:0] and_112_nl;
  wire[0:0] mux_126_nl;
  wire[0:0] mux_125_nl;
  wire[0:0] mux_124_nl;
  wire[0:0] mux_123_nl;
  wire[0:0] mux_122_nl;
  wire[0:0] and_110_nl;
  wire[0:0] and_108_nl;
  wire[0:0] and_107_nl;
  wire[0:0] mux_237_nl;
  wire[0:0] mux_236_nl;
  wire[0:0] mux_235_nl;
  wire[0:0] nor_42_nl;
  wire[0:0] mux_234_nl;
  wire[0:0] mux_233_nl;
  wire[0:0] mux_232_nl;
  wire[0:0] and_332_nl;
  wire[0:0] and_331_nl;
  wire[0:0] mux_231_nl;
  wire[0:0] mux_230_nl;
  wire[0:0] and_347_nl;
  wire[0:0] mux_251_nl;
  wire[0:0] mux_250_nl;
  wire[0:0] mux_249_nl;
  wire[0:0] mux_248_nl;
  wire[0:0] mux_247_nl;
  wire[0:0] mux_253_nl;
  wire[0:0] nor_37_nl;
  wire[0:0] mux_262_nl;
  wire[0:0] nor_108_nl;
  wire[0:0] mux_278_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_and_1_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [70:0] nl_operator_91_21_false_AC_TRN_AC_WRAP_rshift_rg_a;
  assign nl_operator_91_21_false_AC_TRN_AC_WRAP_rshift_rg_a = {ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_1
      , ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm_1
      , 50'b00000000000000000000000000000000000000000000000000};
  wire [7:0] nl_operator_91_21_false_AC_TRN_AC_WRAP_rshift_rg_s;
  assign nl_operator_91_21_false_AC_TRN_AC_WRAP_rshift_rg_s = {ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_2_7_2
      , ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_2_1_0};
  wire[10:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl;
  wire[11:0] nl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl;
  wire [20:0] nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_a;
  assign nl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl
      = conv_u2u_9_11(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_18_10_itm_1)
      + ({ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_2_itm_1
      , 1'b1 , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_3_itm_1});
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl
      = nl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl[10:0];
  assign nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_a = {ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl
      , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm_1};
  wire [6:0] nl_operator_71_0_false_AC_TRN_AC_WRAP_lshift_rg_s;
  assign nl_operator_71_0_false_AC_TRN_AC_WRAP_lshift_rg_s = ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_sva_1;
  wire [0:0] nl_compute_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg;
  assign nl_compute_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg = and_dcpl_158
      & and_dcpl_12 & (fsm_output[1]);
  wire [0:0] nl_compute_core_plm_in_rsci_inst_plm_in_rsci_oswt_unreg;
  assign nl_compute_core_plm_in_rsci_inst_plm_in_rsci_oswt_unreg = and_dcpl_116 &
      and_dcpl_154;
  wire [0:0] nl_compute_core_plm_out_rsci_inst_plm_out_rsci_oswt_unreg;
  assign nl_compute_core_plm_out_rsci_inst_plm_out_rsci_oswt_unreg = and_dcpl_130
      & CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_20 & main_stage_v_20
      & or_dcpl_16 & plm_out_rsci_bawt;
  wire [511:0] nl_compute_core_plm_out_rsci_inst_plm_out_rsci_idat;
  assign nl_compute_core_plm_out_rsci_inst_plm_out_rsci_idat = {plm_out_rsci_idat_511_480
      , plm_out_rsci_idat_479_448 , plm_out_rsci_idat_447_416 , plm_out_rsci_idat_415_384
      , plm_out_rsci_idat_383_352 , plm_out_rsci_idat_351_320 , plm_out_rsci_idat_319_288
      , plm_out_rsci_idat_287_256 , plm_out_rsci_idat_255_224 , plm_out_rsci_idat_223_192
      , plm_out_rsci_idat_191_160 , plm_out_rsci_idat_159_128 , plm_out_rsci_idat_127_96
      , plm_out_rsci_idat_95_64 , plm_out_rsci_idat_63_32 , plm_out_rsci_idat_31_0};
  wire [0:0] nl_compute_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_inst_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_oswt_unreg;
  assign nl_compute_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_inst_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_oswt_unreg
      = and_dcpl_25 & main_stage_v_3 & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_3)
      & ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt
      & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_1);
  esp_acc_softmax_cxx_catapult_leading_sign_71_0  leading_sign_71_0_rg (
      .mantissa(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1),
      .rtn(libraries_leading_sign_71_0_1bc993dc735dc189e3e2a7ebf4857c14bb7e_1)
    );
  esp_acc_softmax_cxx_catapult_mgc_shift_br_v5 #(.width_a(32'sd71),
  .signd_a(32'sd0),
  .width_s(32'sd8),
  .width_z(32'sd91)) operator_91_21_false_AC_TRN_AC_WRAP_rshift_rg (
      .a(nl_operator_91_21_false_AC_TRN_AC_WRAP_rshift_rg_a[70:0]),
      .s(nl_operator_91_21_false_AC_TRN_AC_WRAP_rshift_rg_s[7:0]),
      .z(operator_91_21_false_AC_TRN_AC_WRAP_rshift_itm)
    );
  esp_acc_softmax_cxx_catapult_mgc_shift_bl_v5 #(.width_a(32'sd21),
  .signd_a(32'sd0),
  .width_s(32'sd7),
  .width_z(32'sd67)) operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg (
      .a(nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_a[20:0]),
      .s(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_18_12_itm_1),
      .z(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1)
    );
  esp_acc_softmax_cxx_catapult_mgc_shift_l_v5 #(.width_a(32'sd70),
  .signd_a(32'sd0),
  .width_s(32'sd7),
  .width_z(32'sd70)) operator_71_0_false_AC_TRN_AC_WRAP_lshift_rg (
      .a(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_2_69_0),
      .s(nl_operator_71_0_false_AC_TRN_AC_WRAP_lshift_rg_s[6:0]),
      .z(operator_71_0_false_AC_TRN_AC_WRAP_lshift_itm)
    );
  esp_acc_softmax_cxx_catapult_compute_core_wait_dp compute_core_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsci_ivld(conf_info_rsci_ivld),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg),
      .plm_in_rsci_ivld(plm_in_rsci_ivld),
      .plm_in_rsci_ivld_oreg(plm_in_rsci_ivld_oreg),
      .plm_out_rsci_irdy(plm_out_rsci_irdy),
      .plm_out_rsci_irdy_oreg(plm_out_rsci_irdy_oreg),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg)
    );
  esp_acc_softmax_cxx_catapult_compute_core_conf_info_rsci compute_core_conf_info_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .core_wen(core_wen),
      .conf_info_rsci_oswt_unreg(nl_compute_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg[0:0]),
      .conf_info_rsci_bawt(conf_info_rsci_bawt),
      .conf_info_rsci_iswt0(conf_info_rsci_iswt0),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_irdy_core_psct(conf_info_rsci_irdy_core_psct),
      .conf_info_rsci_ivld(conf_info_rsci_ivld),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_catapult_compute_core_plm_in_rsci compute_core_plm_in_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsc_dat(plm_in_rsc_dat),
      .plm_in_rsc_vld(plm_in_rsc_vld),
      .plm_in_rsc_rdy(plm_in_rsc_rdy),
      .core_wen(core_wen),
      .plm_in_rsci_oswt_unreg(nl_compute_core_plm_in_rsci_inst_plm_in_rsci_oswt_unreg[0:0]),
      .plm_in_rsci_bawt(plm_in_rsci_bawt),
      .plm_in_rsci_iswt0(plm_in_rsci_iswt0),
      .plm_in_rsci_wen_comp(plm_in_rsci_wen_comp),
      .plm_in_rsci_irdy_core_psct(plm_in_rsci_irdy_core_psct),
      .plm_in_rsci_ivld(plm_in_rsci_ivld),
      .plm_in_rsci_ivld_oreg(plm_in_rsci_ivld_oreg),
      .plm_in_rsci_idat_mxwt(plm_in_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_catapult_compute_core_plm_out_rsci compute_core_plm_out_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsc_dat(plm_out_rsc_dat),
      .plm_out_rsc_vld(plm_out_rsc_vld),
      .plm_out_rsc_rdy(plm_out_rsc_rdy),
      .core_wen(core_wen),
      .plm_out_rsci_irdy(plm_out_rsci_irdy),
      .plm_out_rsci_oswt_unreg(nl_compute_core_plm_out_rsci_inst_plm_out_rsci_oswt_unreg[0:0]),
      .plm_out_rsci_bawt(plm_out_rsci_bawt),
      .plm_out_rsci_iswt0(reg_plm_out_rsci_ivld_core_psct_cse),
      .plm_out_rsci_wen_comp(plm_out_rsci_wen_comp),
      .plm_out_rsci_irdy_oreg(plm_out_rsci_irdy_oreg),
      .plm_out_rsci_idat(nl_compute_core_plm_out_rsci_inst_plm_out_rsci_idat[511:0])
    );
  esp_acc_softmax_cxx_catapult_compute_core_done_rsci compute_core_done_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .done_rsc_rdy(done_rsc_rdy),
      .done_rsc_vld(done_rsc_vld),
      .core_wen(core_wen),
      .done_rsci_oswt_unreg(and_dcpl_127),
      .done_rsci_bawt(done_rsci_bawt),
      .done_rsci_iswt0(reg_done_rsci_ivld_core_psct_cse),
      .done_rsci_wen_comp(done_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_catapult_compute_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp
      compute_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_b_core(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_b_core),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_oswt_unreg(nl_compute_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_inst_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_oswt_unreg[0:0]),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_iswt1(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_iswt1),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt)
    );
  esp_acc_softmax_cxx_catapult_compute_core_staller compute_core_staller_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .plm_in_rsci_wen_comp(plm_in_rsci_wen_comp),
      .plm_out_rsci_wen_comp(plm_out_rsci_wen_comp),
      .done_rsci_wen_comp(done_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_catapult_compute_core_core_fsm compute_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  assign mux_168_nl = MUX_s_1_2_2(mux_tmp_158, (~ and_dcpl_25), main_stage_v_7);
  assign or_340_nl = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_0 | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_1)
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_7;
  assign mux_169_nl = MUX_s_1_2_2(mux_168_nl, mux_tmp_158, or_340_nl);
  assign CALC_SOFTMAX_LOOP_mul_cmp_en = (~ mux_169_nl) & (fsm_output[1]);
  assign COMPUTE_LOOP_and_16_cse = core_wen & (~ (fsm_output[0]));
  assign and_44_cse = (~ done_rsci_bawt) & exit_COMPUTE_LOOP_lpi_1_dfm_3_st_21 &
      main_stage_v_21;
  assign nor_43_cse = ~(COMPUTE_LOOP_if_acc_itm_32_1 | (~ or_143_cse));
  assign CALC_SOFTMAX_LOOP_i_and_1_cse = core_wen & (~ or_dcpl_13);
  assign CALC_SOFTMAX_LOOP_i_and_2_cse = core_wen & (~(or_dcpl_52 | (and_dcpl_182
      & main_stage_v_1)));
  assign CALC_SOFTMAX_LOOP_and_56_cse = core_wen & (and_dcpl_177 | and_dcpl_171);
  assign CALC_SOFTMAX_LOOP_and_59_cse = core_wen & (~((~ mux_tmp_138) | and_44_cse
      | (~ main_stage_v_2)));
  assign CALC_SOFTMAX_LOOP_and_84_cse = core_wen & (~ or_dcpl_52);
  assign CALC_EXP_LOOP_and_3_cse = core_wen & (~ or_dcpl_21);
  assign or_143_cse = (~ main_stage_v_20) | plm_out_rsci_bawt | (~ CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_20)
      | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_20_1) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_20_0
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_20;
  assign or_142_cse = (~ main_stage_v_21) | (~ exit_COMPUTE_LOOP_lpi_1_dfm_3_st_21)
      | done_rsci_bawt;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse
      = core_wen & (and_tmp_124 | and_dcpl_301);
  assign CALC_SOFTMAX_LOOP_i_and_3_cse = core_wen & (~((~ or_143_cse) | and_44_cse
      | (~ main_stage_v_19)));
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse
      = core_wen & (~((~ and_tmp_124) | (~ main_stage_v_7) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_7
      | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_1 | (~ CALC_EXP_LOOP_and_svs_st_7)));
  assign or_652_nl = (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign mux_268_nl = MUX_s_1_2_2(or_tmp_373, or_652_nl, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign mux_269_nl = MUX_s_1_2_2(mux_268_nl, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1,
      CALC_SOFTMAX_LOOP_or_tmp_1);
  assign or_654_nl = COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1 | mux_269_nl;
  assign mux_270_nl = MUX_s_1_2_2(or_tmp_416, or_654_nl, main_stage_v_1);
  assign CALC_SOFTMAX_LOOP_and_62_cse = core_wen & (~(mux_270_nl | or_tmp_152));
  assign or_186_cse = (~ main_stage_v_3) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_1
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_3 | ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_and_cse = core_wen
      & ((and_tmp_126 & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_6) & CALC_EXP_LOOP_and_svs_st_6
      & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_1)) | and_tmp_129);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse
      = core_wen & (and_tmp_126 | and_dcpl_426);
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_and_2_cse = core_wen
      & (~((~ and_tmp_126) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_6 | (~ CALC_EXP_LOOP_and_svs_st_6)
      | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_1 | (~ main_stage_v_6)));
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_4_cse
      = ~((ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt[11:10]!=2'b00)
      | or_dcpl_21);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_5_cse
      = (ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt[11:10]==2'b01)
      & (~ or_dcpl_21);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_6_cse
      = (ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt[11:10]==2'b10)
      & (~ or_dcpl_21);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_7_cse
      = (ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt[11:10]==2'b11)
      & (~ or_dcpl_21);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_8_cse
      = core_wen & (ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_4_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_5_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_6_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_7_cse);
  assign and_601_nl = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1 & and_dcpl_25;
  assign or_671_nl = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1 | or_dcpl_21;
  assign mux_271_rgt = MUX_s_1_2_2(and_601_nl, or_671_nl, lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_1);
  assign and_606_rgt = and_dcpl_25 & (or_dcpl_156 | (~ CALC_EXP_LOOP_and_svs_st_4));
  assign or_238_cse = (~ main_stage_v_1) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1;
  assign CALC_SOFTMAX_LOOP_and_401_cse = core_wen & ((and_dcpl_116 & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1)
      & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_1 & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_0))
      | and_dcpl_436);
  assign CALC_SOFTMAX_LOOP_and_416_cse = COMPUTE_LOOP_and_16_cse & (~(COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1
      | (~ main_stage_v_1) | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_1) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_0));
  assign lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1_mx0 = MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3_1_1,
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1, or_dcpl_48);
  assign lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0_mx0 = MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3_0_1,
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0, or_dcpl_48);
  assign CALC_SOFTMAX_LOOP_mux_409_nl = MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
      (COMPUTE_LOOP_acc_1_tmp[4]), CALC_SOFTMAX_LOOP_acc_1_tmp[4]);
  assign CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_88_nl = MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
      CALC_SOFTMAX_LOOP_mux_409_nl, CALC_SOFTMAX_LOOP_equal_tmp_mx0w0);
  assign exit_COMPUTE_LOOP_lpi_1_dfm_3_mx1 = MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
      CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_88_nl, mux_tmp_234);
  assign COMPUTE_LOOP_if_and_nl = CALC_SOFTMAX_LOOP_or_tmp_1 & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign COMPUTE_LOOP_if_and_36_nl = CALC_SOFTMAX_LOOP_equal_tmp_1 & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign COMPUTE_LOOP_if_or_16_nl = CALC_SOFTMAX_LOOP_equal_tmp_1_1 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0_mx0w0 = MUX1HOT_v_4_3_2(CALC_SOFTMAX_LOOP_i_4_0_lpi_1_dfm_1_3_0,
      CALC_SOFTMAX_LOOP_i_4_0_sva_1_1_3_0, CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0, {COMPUTE_LOOP_if_and_nl
      , COMPUTE_LOOP_if_and_36_nl , COMPUTE_LOOP_if_or_16_nl});
  assign CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0_mx1 = MUX_v_4_2_2(CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0,
      CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0_mx0w0, main_stage_v_1);
  assign COMPUTE_LOOP_if_asn_sft_lpi_1_mx0 = MUX_s_1_2_2(COMPUTE_LOOP_if_asn_sft_lpi_1,
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1, main_stage_v_1);
  assign COMPUTE_LOOP_if_COMPUTE_LOOP_if_COMPUTE_LOOP_if_or_nl = (~(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3_1_1
      | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3_0_1)) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_mx1 = MUX_s_1_2_2(exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm,
      COMPUTE_LOOP_if_COMPUTE_LOOP_if_COMPUTE_LOOP_if_or_nl, main_stage_v_1);
  assign CALC_SOFTMAX_LOOP_equal_tmp_mx0w0 = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_mx0w0
      & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_mx0w0);
  assign CALC_SOFTMAX_LOOP_equal_tmp_1_mx0w0 = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_mx0w0
      & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_mx0w0;
  assign CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_not_4_nl
      = ~ exitL_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1;
  assign CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0 = MUX_v_4_2_2(4'b0000, CALC_EXP_LOOP_i_4_0_lpi_1_3_0,
      CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_not_4_nl);
  assign lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_mx0w0 = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1_mx0
      & (~ exitL_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_mx0w0 = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0_mx0
      & (~ exitL_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign CALC_EXP_LOOP_and_svs_mx0w0 = (CALC_EXP_LOOP_i_4_0_sva_2[4]) & (SUM_EXP_LOOP_i_4_0_sva_2[4]);
  assign nl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_mx0w0
      = conv_s2u_9_11(ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[18:10])
      + ({1'b1 , ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1});
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_mx0w0
      = nl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_mx0w0[10:0];
  assign COMPUTE_LOOP_if_nor_2_cse = ~(CALC_SOFTMAX_LOOP_equal_tmp_mx0w0 | CALC_SOFTMAX_LOOP_equal_tmp_1_mx0w0);
  assign nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1_dfm_1
      + conv_u2u_67_71(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0
      = nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0[70:0];
  assign nl_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_7_2_mx0w0
      = ({1'b1 , (~ (ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_sva_1[6:2]))})
      + 6'b001101;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_7_2_mx0w0
      = nl_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_7_2_mx0w0[5:0];
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_mx0w0
      = MUX_v_10_8_2(10'b1111111101, 10'b1100011001, 10'b1001100100, 10'b0111010000,
      10'b0101010100, 10'b0011101011, 10'b0010010001, 10'b0001000100, operator_71_0_false_AC_TRN_AC_WRAP_lshift_itm[69:67]);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_mx0w0
      = MUX_v_8_8_2(8'b00011100, 8'b01001011, 8'b01101100, 8'b10000100, 8'b10010111,
      8'b10100110, 8'b10110011, 8'b10111100, operator_71_0_false_AC_TRN_AC_WRAP_lshift_itm[69:67]);
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0
      = ~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0!=71'b00000000000000000000000000000000000000000000000000000000000000000000000));
  assign lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_mx1 = MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1,
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_mx0w0, mux_tmp_234);
  assign lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_mx1 = MUX_s_1_2_2(reg_lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_cse,
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_mx0w0, mux_tmp_234);
  assign CALC_SOFTMAX_LOOP_and_12_psp_mx0w0 = CALC_SOFTMAX_LOOP_and_stg_1_3_sva_1
      & (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[3:2]==2'b01);
  assign CALC_SOFTMAX_LOOP_and_13_psp_mx0w0 = CALC_SOFTMAX_LOOP_and_stg_2_0_sva_1
      & (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[3]);
  assign CALC_SOFTMAX_LOOP_and_14_psp_mx0w0 = CALC_SOFTMAX_LOOP_and_stg_2_6_sva_1
      & (~ (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[3]));
  assign CALC_SOFTMAX_LOOP_and_15_psp_mx0w0 = CALC_SOFTMAX_LOOP_and_stg_2_1_sva_1
      & (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[3]);
  assign CALC_SOFTMAX_LOOP_and_16_psp_mx0w0 = CALC_SOFTMAX_LOOP_and_stg_2_5_sva_1
      & (~ (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[3]));
  assign CALC_SOFTMAX_LOOP_and_17_psp_mx0w0 = CALC_SOFTMAX_LOOP_and_stg_2_2_sva_1
      & (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[3]);
  assign CALC_SOFTMAX_LOOP_and_18_psp_mx0w0 = CALC_SOFTMAX_LOOP_and_stg_2_4_sva_1
      & (~ (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[3]));
  assign CALC_SOFTMAX_LOOP_and_19_psp_mx0w0 = CALC_SOFTMAX_LOOP_and_stg_2_3_sva_1
      & (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[3]);
  assign CALC_SOFTMAX_LOOP_and_20_psp_mx0w0 = CALC_SOFTMAX_LOOP_and_stg_2_3_sva_1
      & (~ (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[3]));
  assign CALC_SOFTMAX_LOOP_and_21_psp_mx0w0 = CALC_SOFTMAX_LOOP_and_stg_2_4_sva_1
      & (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[3]);
  assign CALC_SOFTMAX_LOOP_and_22_psp_mx0w0 = CALC_SOFTMAX_LOOP_and_stg_2_2_sva_1
      & (~ (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[3]));
  assign CALC_SOFTMAX_LOOP_and_23_psp_mx0w0 = CALC_SOFTMAX_LOOP_and_stg_2_5_sva_1
      & (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[3]);
  assign CALC_SOFTMAX_LOOP_and_24_psp_mx0w0 = CALC_SOFTMAX_LOOP_and_stg_2_1_sva_1
      & (~ (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[3]));
  assign CALC_SOFTMAX_LOOP_and_25_psp_mx0w0 = CALC_SOFTMAX_LOOP_and_stg_2_6_sva_1
      & (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[3]);
  assign CALC_SOFTMAX_LOOP_and_26_psp_mx0w0 = CALC_SOFTMAX_LOOP_and_stg_2_0_sva_1
      & (~ (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[3]));
  assign exit_COMPUTE_LOOP_lpi_1_dfm_4 = (~ COMPUTE_LOOP_if_acc_itm_32_1) & exitL_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1;
  assign mux_8_nl = MUX_v_32_2_2(batch_lpi_1_dfm, conf_info_rsci_idat_mxwt, exitL_exit_COMPUTE_LOOP_sva);
  assign nl_COMPUTE_LOOP_if_acc_nl = ({29'b10000000000000000000000000000 , COMPUTE_LOOP_b_4_0_lpi_1_dfm_3_0_1})
      + conv_u2u_32_33(~ mux_8_nl) + 33'b000000000000000000000000000000001;
  assign COMPUTE_LOOP_if_acc_nl = nl_COMPUTE_LOOP_if_acc_nl[32:0];
  assign COMPUTE_LOOP_if_acc_itm_32_1 = readslicef_33_1_32(COMPUTE_LOOP_if_acc_nl);
  assign COMPUTE_LOOP_not_12_nl = ~ exitL_exit_COMPUTE_LOOP_sva;
  assign COMPUTE_LOOP_b_4_0_lpi_1_dfm_3_0_1 = MUX_v_4_2_2(4'b0000, COMPUTE_LOOP_b_4_0_lpi_1_3_0,
      COMPUTE_LOOP_not_12_nl);
  assign nl_COMPUTE_LOOP_acc_1_tmp = conv_u2u_4_5(COMPUTE_LOOP_b_4_0_lpi_1_dfm_3_0_1)
      + 5'b00001;
  assign COMPUTE_LOOP_acc_1_tmp = nl_COMPUTE_LOOP_acc_1_tmp[4:0];
  assign nl_CALC_SOFTMAX_LOOP_acc_1_tmp = conv_u2u_4_5(CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0_mx1)
      + 5'b00001;
  assign CALC_SOFTMAX_LOOP_acc_1_tmp = nl_CALC_SOFTMAX_LOOP_acc_1_tmp[4:0];
  assign exitL_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1 = exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_mx1
      | exit_COMPUTE_LOOP_lpi_1_dfm_3 | exitL_exit_COMPUTE_LOOP_sva;
  assign or_754_nl = (~ or_tmp_353) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign mux_285_nl = MUX_s_1_2_2(or_tmp_373, or_754_nl, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign mux_286_nl = MUX_s_1_2_2(mux_285_nl, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1,
      CALC_SOFTMAX_LOOP_or_tmp_1);
  assign mux_287_nl = MUX_s_1_2_2(mux_286_nl, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1,
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_288_nl = MUX_s_1_2_2(exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm, mux_287_nl,
      main_stage_v_1);
  assign or_755_nl = mux_288_nl | or_tmp_152;
  assign COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1 = MUX_s_1_2_2(COMPUTE_LOOP_if_asn_sft_lpi_1_mx0,
      exit_COMPUTE_LOOP_lpi_1_dfm_4, or_755_nl);
  assign CALC_SOFTMAX_LOOP_mux_408_nl = MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2_1_1,
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3_1_1 = (CALC_SOFTMAX_LOOP_mux_408_nl
      & (~ CALC_SOFTMAX_LOOP_and_46_ssc_1)) | CALC_SOFTMAX_LOOP_and_47_ssc_1;
  assign lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3_0_1 = (lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_0
      & CALC_SOFTMAX_LOOP_equal_tmp_1_1 & (~ CALC_SOFTMAX_LOOP_and_47_ssc_1)) | CALC_SOFTMAX_LOOP_and_46_ssc_1;
  assign CALC_SOFTMAX_LOOP_and_46_ssc_1 = (~ reg_CALC_EXP_LOOP_and_svs_1_cse) & CALC_SOFTMAX_LOOP_or_tmp_1;
  assign CALC_SOFTMAX_LOOP_and_47_ssc_1 = reg_CALC_EXP_LOOP_and_svs_1_cse & CALC_SOFTMAX_LOOP_or_tmp_1;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_1_dfm_1
      = MUX_v_91_2_2(operator_91_21_false_AC_TRN_AC_WRAP_rshift_itm, 91'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_4);
  assign or_94_cse = conf_info_rsci_bawt | (~ COMPUTE_LOOP_asn_itm);
  assign main_stage_en_22 = or_94_cse & (plm_in_rsci_bawt | (~((~(lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1)) & main_stage_v_1))) & (ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt
      | (~((~(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_1 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_3))
      & main_stage_v_3))) & (plm_out_rsci_bawt | (~(CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_20
      & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_20_1 & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_20_0)
      & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_20) & main_stage_v_20))) & (done_rsci_bawt
      | (~(exit_COMPUTE_LOOP_lpi_1_dfm_3_st_21 & main_stage_v_21)));
  assign nl_CALC_EXP_LOOP_i_4_0_sva_2 = conv_u2u_4_5(CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0)
      + 5'b00001;
  assign CALC_EXP_LOOP_i_4_0_sva_2 = nl_CALC_EXP_LOOP_i_4_0_sva_2[4:0];
  assign CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_not_nl
      = ~ exitL_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1;
  assign COMPUTE_LOOP_if_COMPUTE_LOOP_if_and_2_nl = MUX_v_4_2_2(4'b0000, SUM_EXP_LOOP_i_4_0_lpi_1_3_0,
      CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_not_nl);
  assign nl_SUM_EXP_LOOP_i_4_0_sva_2 = conv_u2u_4_5(COMPUTE_LOOP_if_COMPUTE_LOOP_if_and_2_nl)
      + 5'b00001;
  assign SUM_EXP_LOOP_i_4_0_sva_2 = nl_SUM_EXP_LOOP_i_4_0_sva_2[4:0];
  assign nl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = $signed(({1'b1 , ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1}))
      * $signed(conv_u2s_10_11(ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_69_57_9_0_itm_1));
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = nl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[18:0];
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1_dfm_1
      = MUX_v_71_2_2(71'b00000000000000000000000000000000000000000000000000000000000000000000000,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1,
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_4);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_7_nl
      = MUX_v_5_4_2(5'b01100, 5'b01110, 5'b10001, 5'b10100, ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt[11:10]);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_1_nl
      = MUX_v_3_4_2(3'b010, 3'b110, 3'b001, 3'b101, ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt[11:10]);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = conv_u2u_19_19(({ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_7_nl
      , 1'b0 , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_1_nl})
      * (ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt[9:0]));
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_7_sva_1
      = ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_3_sva_1
      & (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[2]);
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_6_sva_1
      = ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_2_sva_1
      & (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[2]);
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_5_sva_1
      = ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_1_sva_1
      & (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[2]);
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_4_sva_1
      = ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_0_sva_1
      & (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[2]);
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_3_sva_1
      = ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_3_sva_1
      & (~ (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[2]));
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_2_sva_1
      = ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_2_sva_1
      & (~ (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[2]));
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_1_sva_1
      = ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_1_sva_1
      & (~ (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[2]));
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_0_sva_1
      = ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_0_sva_1
      & (~ (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[2]));
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_0_sva_1
      = ~((CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[1:0]!=2'b00));
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_1_sva_1
      = (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[1:0]==2'b01);
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_2_sva_1
      = (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[1:0]==2'b10);
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_3_sva_1
      = (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[1:0]==2'b11);
  assign CALC_SOFTMAX_LOOP_and_stg_2_0_sva_1 = CALC_SOFTMAX_LOOP_and_stg_1_0_sva_1
      & (~ (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[2]));
  assign CALC_SOFTMAX_LOOP_and_stg_2_6_sva_1 = CALC_SOFTMAX_LOOP_and_stg_1_2_sva_1
      & (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[2]);
  assign CALC_SOFTMAX_LOOP_and_stg_2_1_sva_1 = CALC_SOFTMAX_LOOP_and_stg_1_1_sva_1
      & (~ (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[2]));
  assign CALC_SOFTMAX_LOOP_and_stg_2_5_sva_1 = CALC_SOFTMAX_LOOP_and_stg_1_1_sva_1
      & (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[2]);
  assign CALC_SOFTMAX_LOOP_and_stg_2_2_sva_1 = CALC_SOFTMAX_LOOP_and_stg_1_2_sva_1
      & (~ (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[2]));
  assign CALC_SOFTMAX_LOOP_and_stg_2_4_sva_1 = CALC_SOFTMAX_LOOP_and_stg_1_0_sva_1
      & (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[2]);
  assign CALC_SOFTMAX_LOOP_and_stg_2_3_sva_1 = CALC_SOFTMAX_LOOP_and_stg_1_3_sva_1
      & (~ (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[2]));
  assign CALC_SOFTMAX_LOOP_and_stg_1_3_sva_1 = (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[1:0]==2'b11);
  assign CALC_SOFTMAX_LOOP_and_stg_1_0_sva_1 = ~((CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[1:0]!=2'b00));
  assign CALC_SOFTMAX_LOOP_and_stg_1_1_sva_1 = (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[1:0]==2'b01);
  assign CALC_SOFTMAX_LOOP_and_stg_1_2_sva_1 = (CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0[1:0]==2'b10);
  assign or_84_cse = ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt
      | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_1 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_3;
  assign or_tmp_5 = COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1 | lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1
      | plm_in_rsci_bawt;
  assign or_tmp_89 = lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1 | plm_in_rsci_bawt;
  assign or_tmp_152 = exitL_exit_COMPUTE_LOOP_sva | exit_COMPUTE_LOOP_lpi_1_dfm_3;
  assign or_267_cse = (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0
      | COMPUTE_LOOP_if_asn_sft_lpi_1 | exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm;
  assign and_tmp_26 = or_142_cse & or_143_cse & or_186_cse & or_94_cse;
  assign and_tmp_27 = or_tmp_5 & and_tmp_26;
  assign or_tmp_166 = COMPUTE_LOOP_if_acc_itm_32_1 | (~ and_tmp_27);
  assign or_tmp_167 = COMPUTE_LOOP_if_acc_itm_32_1 | (~ and_tmp_26);
  assign and_tmp_30 = or_tmp_89 & (COMPUTE_LOOP_acc_1_tmp[4]) & (CALC_SOFTMAX_LOOP_acc_1_tmp[4])
      & and_tmp_26;
  assign and_tmp_31 = reg_CALC_EXP_LOOP_and_svs_1_cse & and_tmp_30;
  assign and_tmp_33 = or_tmp_89 & and_tmp_26;
  assign and_dcpl_12 = conf_info_rsci_bawt & COMPUTE_LOOP_asn_itm;
  assign or_tmp_179 = (~ main_stage_v_1) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1
      | lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1 | plm_in_rsci_bawt;
  assign and_tmp_35 = or_143_cse & or_186_cse;
  assign and_tmp_36 = or_142_cse & and_tmp_35;
  assign or_287_cse = COMPUTE_LOOP_if_acc_itm_32_1 | (~ main_stage_en_22);
  assign and_tmp_37 = or_287_cse & and_tmp_36;
  assign nand_190_cse = ~((COMPUTE_LOOP_acc_1_tmp[4]) & (CALC_SOFTMAX_LOOP_acc_1_tmp[4])
      & main_stage_en_22);
  assign and_tmp_42 = nand_190_cse & and_tmp_36;
  assign and_tmp_46 = or_142_cse & or_143_cse & or_84_cse;
  assign and_tmp_47 = or_287_cse & and_tmp_46;
  assign and_tmp_52 = nand_190_cse & and_tmp_46;
  assign nor_135_nl = ~(main_stage_v_3 | (~ or_143_cse));
  assign mux_tmp_138 = MUX_s_1_2_2(nor_135_nl, or_143_cse, or_84_cse);
  assign and_tmp_66 = or_tmp_179 & mux_tmp_138;
  assign or_dcpl_13 = (~ and_tmp_66) | and_44_cse;
  assign or_dcpl_14 = or_dcpl_13 | ((~ conf_info_rsci_bawt) & COMPUTE_LOOP_asn_itm);
  assign and_dcpl_20 = (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_19_0) & CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_19;
  assign and_dcpl_23 = main_stage_v_19 & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_19)
      & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_19_1;
  assign or_dcpl_15 = done_rsci_bawt | (~ exit_COMPUTE_LOOP_lpi_1_dfm_3_st_21);
  assign or_dcpl_16 = or_dcpl_15 | (~ main_stage_v_21);
  assign and_dcpl_25 = or_143_cse & or_dcpl_16;
  assign or_dcpl_20 = (~ main_stage_v_19) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_19
      | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_19_1) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_19_0
      | (~ CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_19);
  assign or_dcpl_21 = (~ or_143_cse) | and_44_cse;
  assign and_dcpl_114 = (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1) & main_stage_v_1;
  assign and_dcpl_116 = mux_tmp_138 & or_dcpl_16;
  assign and_tmp_67 = main_stage_v_18 & and_dcpl_25;
  assign or_tmp_234 = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_18_0 | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_18_1)
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_18 | (~ and_tmp_67);
  assign and_712_nl = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_16_1 & main_stage_v_16;
  assign mux_148_nl = MUX_s_1_2_2(or_tmp_234, (~ and_dcpl_25), and_712_nl);
  assign or_350_nl = COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_16 | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_16_0;
  assign mux_tmp_140 = MUX_s_1_2_2(mux_148_nl, or_tmp_234, or_350_nl);
  assign mux_150_nl = MUX_s_1_2_2(mux_tmp_140, (~ and_dcpl_25), main_stage_v_17);
  assign or_349_nl = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_17_0 | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_17_1)
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_17;
  assign mux_tmp_142 = MUX_s_1_2_2(mux_150_nl, mux_tmp_140, or_349_nl);
  assign mux_152_nl = MUX_s_1_2_2(mux_tmp_142, (~ and_dcpl_25), main_stage_v_15);
  assign or_348_nl = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_15_0 | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_15_1)
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_15;
  assign mux_tmp_144 = MUX_s_1_2_2(mux_152_nl, mux_tmp_142, or_348_nl);
  assign mux_154_nl = MUX_s_1_2_2(mux_tmp_144, (~ and_dcpl_25), main_stage_v_14);
  assign or_347_nl = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_14_0 | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_14_1)
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_14;
  assign mux_tmp_146 = MUX_s_1_2_2(mux_154_nl, mux_tmp_144, or_347_nl);
  assign mux_156_nl = MUX_s_1_2_2(mux_tmp_146, (~ and_dcpl_25), main_stage_v_13);
  assign or_346_nl = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_0 | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_1)
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_13;
  assign mux_tmp_148 = MUX_s_1_2_2(mux_156_nl, mux_tmp_146, or_346_nl);
  assign mux_158_nl = MUX_s_1_2_2(mux_tmp_148, (~ and_dcpl_25), main_stage_v_10);
  assign or_345_nl = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_0 | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_1)
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_10;
  assign mux_tmp_150 = MUX_s_1_2_2(mux_158_nl, mux_tmp_148, or_345_nl);
  assign mux_160_nl = MUX_s_1_2_2(mux_tmp_150, (~ and_dcpl_25), main_stage_v_11);
  assign or_344_nl = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_0 | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_1)
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_11;
  assign mux_tmp_152 = MUX_s_1_2_2(mux_160_nl, mux_tmp_150, or_344_nl);
  assign mux_162_nl = MUX_s_1_2_2(mux_tmp_152, (~ and_dcpl_25), main_stage_v_12);
  assign or_343_nl = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_0 | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_1)
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_12;
  assign mux_tmp_154 = MUX_s_1_2_2(mux_162_nl, mux_tmp_152, or_343_nl);
  assign mux_164_nl = MUX_s_1_2_2(mux_tmp_154, (~ and_dcpl_25), main_stage_v_9);
  assign or_342_nl = (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_1) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_0
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_9;
  assign mux_tmp_156 = MUX_s_1_2_2(mux_164_nl, mux_tmp_154, or_342_nl);
  assign mux_166_nl = MUX_s_1_2_2(mux_tmp_156, (~ and_dcpl_25), main_stage_v_8);
  assign or_341_nl = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_0 | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_1)
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_8;
  assign mux_tmp_158 = MUX_s_1_2_2(mux_166_nl, mux_tmp_156, or_341_nl);
  assign or_dcpl_27 = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_20_0 | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_20_1)
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_20 | (~ CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_20)
      | plm_out_rsci_bawt;
  assign and_dcpl_124 = or_dcpl_27 & or_dcpl_16;
  assign and_dcpl_127 = done_rsci_bawt & exit_COMPUTE_LOOP_lpi_1_dfm_3_st_21 & main_stage_v_21;
  assign and_dcpl_129 = (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_20_0) & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_20_1;
  assign and_dcpl_130 = and_dcpl_129 & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_20);
  assign and_dcpl_131 = and_dcpl_130 & CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_20
      & (~ plm_out_rsci_bawt);
  assign and_dcpl_132 = (and_dcpl_131 | (~ main_stage_v_20) | (~ exit_COMPUTE_LOOP_lpi_1_dfm_3_st_20))
      & and_dcpl_127;
  assign and_dcpl_140 = or_dcpl_20 & and_dcpl_129 & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_20)
      & CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_20 & main_stage_v_20
      & plm_out_rsci_bawt & or_dcpl_16;
  assign or_tmp_244 = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1 | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_0
      | CALC_SOFTMAX_LOOP_or_tmp_1;
  assign not_tmp_175 = ~(or_tmp_89 & and_tmp_35);
  assign or_tmp_247 = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2_1_1 | CALC_SOFTMAX_LOOP_or_tmp_1;
  assign and_260_cse = or_tmp_5 & and_tmp_35;
  assign and_259_cse = or_tmp_179 & and_tmp_35;
  assign and_262_nl = exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm & and_tmp_35;
  assign nor_128_nl = ~(or_tmp_247 | not_tmp_175);
  assign nor_129_nl = ~(or_tmp_244 | not_tmp_175);
  assign mux_175_nl = MUX_s_1_2_2(nor_128_nl, nor_129_nl, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign mux_176_nl = MUX_s_1_2_2(mux_175_nl, and_tmp_35, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_177_nl = MUX_s_1_2_2(mux_176_nl, and_260_cse, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_178_nl = MUX_s_1_2_2(and_262_nl, mux_177_nl, main_stage_v_1);
  assign mux_179_nl = MUX_s_1_2_2(mux_178_nl, and_259_cse, or_tmp_152);
  assign and_dcpl_146 = mux_179_nl & or_dcpl_16;
  assign and_tmp_76 = or_tmp_89 & or_143_cse;
  assign and_270_nl = exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm & or_143_cse;
  assign nor_126_nl = ~(or_tmp_247 | (~ and_tmp_76));
  assign nor_127_nl = ~(or_tmp_244 | (~ and_tmp_76));
  assign mux_180_nl = MUX_s_1_2_2(nor_126_nl, nor_127_nl, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign mux_181_nl = MUX_s_1_2_2(mux_180_nl, or_143_cse, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_268_nl = or_tmp_5 & or_143_cse;
  assign mux_182_nl = MUX_s_1_2_2(mux_181_nl, and_268_nl, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_183_nl = MUX_s_1_2_2(and_270_nl, mux_182_nl, main_stage_v_1);
  assign and_267_nl = or_tmp_179 & or_143_cse;
  assign mux_184_nl = MUX_s_1_2_2(mux_183_nl, and_267_nl, or_tmp_152);
  assign and_dcpl_151 = mux_184_nl & or_dcpl_16 & or_84_cse;
  assign and_dcpl_154 = (~ lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1) & plm_in_rsci_bawt
      & and_dcpl_114;
  assign or_tmp_263 = COMPUTE_LOOP_if_acc_itm_32_1 | (~ and_tmp_35);
  assign mux_206_nl = MUX_s_1_2_2((~ or_tmp_263), and_tmp_35, or_tmp_247);
  assign mux_205_nl = MUX_s_1_2_2((~ or_tmp_263), and_tmp_35, or_tmp_244);
  assign mux_207_nl = MUX_s_1_2_2(mux_206_nl, mux_205_nl, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign or_388_nl = exitL_exit_COMPUTE_LOOP_sva | exit_COMPUTE_LOOP_lpi_1_dfm_3
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign mux_188_nl = MUX_s_1_2_2(mux_207_nl, (~ or_tmp_263), or_388_nl);
  assign mux_189_nl = MUX_s_1_2_2(and_tmp_35, mux_188_nl, or_94_cse);
  assign and_dcpl_156 = mux_189_nl & or_dcpl_16 & and_dcpl_154;
  assign and_dcpl_158 = and_tmp_66 & or_dcpl_16;
  assign or_dcpl_41 = ~(main_stage_v_8 & COMPUTE_LOOP_if_and_71_itm_7);
  assign or_dcpl_48 = COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1 | (~ main_stage_v_1);
  assign or_tmp_310 = (~ or_tmp_89) | COMPUTE_LOOP_if_acc_itm_32_1 | (~ and_tmp_35);
  assign nor_118_cse = ~(COMPUTE_LOOP_if_acc_itm_32_1 | (~ and_tmp_35));
  assign and_710_nl = COMPUTE_LOOP_if_asn_sft_lpi_1 & and_tmp_35;
  assign mux_213_nl = MUX_s_1_2_2(and_710_nl, nor_118_cse, exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm);
  assign nor_119_nl = ~(or_tmp_247 | or_tmp_310);
  assign nor_120_nl = ~(or_tmp_244 | or_tmp_310);
  assign mux_210_nl = MUX_s_1_2_2(nor_119_nl, nor_120_nl, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign mux_211_nl = MUX_s_1_2_2(mux_210_nl, nor_118_cse, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign nor_122_nl = ~((~ or_tmp_5) | COMPUTE_LOOP_if_acc_itm_32_1 | (~ and_tmp_35));
  assign mux_212_nl = MUX_s_1_2_2(mux_211_nl, nor_122_nl, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_214_nl = MUX_s_1_2_2(mux_213_nl, mux_212_nl, main_stage_v_1);
  assign nor_123_nl = ~((~ or_tmp_179) | COMPUTE_LOOP_if_acc_itm_32_1 | (~ and_tmp_35));
  assign mux_215_nl = MUX_s_1_2_2(mux_214_nl, nor_123_nl, or_tmp_152);
  assign and_dcpl_171 = mux_215_nl & or_dcpl_16;
  assign and_dcpl_173 = or_94_cse & main_stage_v_3;
  assign or_tmp_328 = (~ or_tmp_89) | COMPUTE_LOOP_if_acc_itm_32_1 | (~ or_143_cse);
  assign and_tmp_99 = COMPUTE_LOOP_if_acc_itm_32_1 & and_tmp_35;
  assign and_tmp_100 = or_tmp_89 & and_tmp_35;
  assign and_tmp_101 = COMPUTE_LOOP_if_acc_itm_32_1 & and_tmp_100;
  assign or_483_cse = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2_1_1 | CALC_SOFTMAX_LOOP_or_tmp_1
      | COMPUTE_LOOP_if_acc_itm_32_1;
  assign or_482_cse = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1 | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_0
      | CALC_SOFTMAX_LOOP_or_tmp_1 | COMPUTE_LOOP_if_acc_itm_32_1;
  assign nor_117_nl = ~(COMPUTE_LOOP_if_asn_sft_lpi_1 | (~ and_tmp_35));
  assign mux_227_nl = MUX_s_1_2_2(nor_117_nl, and_tmp_99, exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm);
  assign and_324_nl = or_483_cse & and_tmp_100;
  assign and_323_nl = or_482_cse & and_tmp_100;
  assign mux_224_nl = MUX_s_1_2_2(and_324_nl, and_323_nl, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign mux_225_nl = MUX_s_1_2_2(mux_224_nl, and_tmp_99, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_223_nl = MUX_s_1_2_2(and_tmp_101, and_tmp_99, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_226_nl = MUX_s_1_2_2(mux_225_nl, mux_223_nl, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_228_nl = MUX_s_1_2_2(mux_227_nl, mux_226_nl, main_stage_v_1);
  assign mux_222_nl = MUX_s_1_2_2(and_tmp_101, and_tmp_99, or_238_cse);
  assign mux_229_nl = MUX_s_1_2_2(mux_228_nl, mux_222_nl, or_tmp_152);
  assign and_dcpl_177 = mux_229_nl & or_dcpl_16;
  assign and_tmp_105 = COMPUTE_LOOP_if_acc_itm_32_1 & or_143_cse;
  assign and_tmp_107 = COMPUTE_LOOP_if_acc_itm_32_1 & and_tmp_76;
  assign or_tmp_353 = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_0 | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1;
  assign nor_133_cse = ~(COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1 | exit_COMPUTE_LOOP_lpi_1_dfm_3);
  assign nor_130_nl = ~(COMPUTE_LOOP_if_asn_sft_lpi_1 | exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm
      | exit_COMPUTE_LOOP_lpi_1_dfm_3);
  assign nor_131_nl = ~((~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2_1_1) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1
      | exit_COMPUTE_LOOP_lpi_1_dfm_3);
  assign nor_132_nl = ~((~ or_tmp_353) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1 | exit_COMPUTE_LOOP_lpi_1_dfm_3);
  assign mux_238_nl = MUX_s_1_2_2(nor_131_nl, nor_132_nl, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign mux_239_nl = MUX_s_1_2_2(mux_238_nl, nor_133_cse, CALC_SOFTMAX_LOOP_or_tmp_1);
  assign mux_240_nl = MUX_s_1_2_2(mux_239_nl, nor_133_cse, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_241_nl = MUX_s_1_2_2(nor_130_nl, mux_240_nl, main_stage_v_1);
  assign or_495_nl = main_stage_v_1 | (~ COMPUTE_LOOP_if_asn_sft_lpi_1) | exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm
      | exit_COMPUTE_LOOP_lpi_1_dfm_3;
  assign mux_242_nl = MUX_s_1_2_2(mux_241_nl, or_495_nl, COMPUTE_LOOP_if_acc_itm_32_1);
  assign mux_tmp_234 = MUX_s_1_2_2(mux_242_nl, COMPUTE_LOOP_if_acc_itm_32_1, exitL_exit_COMPUTE_LOOP_sva);
  assign and_dcpl_182 = ~(lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1 | plm_in_rsci_bawt);
  assign and_dcpl_183 = and_dcpl_182 & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign or_dcpl_52 = (~ mux_tmp_138) | and_44_cse;
  assign nor_113_nl = ~(or_267_cse | (~ and_tmp_35));
  assign nor_114_nl = ~((~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2_1_1) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1 | (~ and_tmp_35));
  assign nor_115_nl = ~((~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_0
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1
      | (~ and_tmp_35));
  assign mux_244_nl = MUX_s_1_2_2(nor_114_nl, nor_115_nl, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign nor_116_nl = ~((~ reg_CALC_EXP_LOOP_and_svs_1_cse) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1 | (~ and_tmp_35));
  assign mux_245_nl = MUX_s_1_2_2(mux_244_nl, nor_116_nl, CALC_SOFTMAX_LOOP_or_tmp_1);
  assign and_709_nl = or_tmp_89 & mux_245_nl;
  assign mux_246_nl = MUX_s_1_2_2(nor_113_nl, and_709_nl, main_stage_v_1);
  assign and_dcpl_187 = mux_246_nl & or_dcpl_16;
  assign or_tmp_368 = (~ reg_CALC_EXP_LOOP_and_svs_1_cse) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign and_346_cse = COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1 & and_tmp_35;
  assign or_520_cse = (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_0
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign or_tmp_373 = (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2_1_1) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign and_dcpl_193 = and_dcpl_116 & (or_tmp_89 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_dcpl_195 = ~(exit_COMPUTE_LOOP_lpi_1_dfm_3 | exitL_exit_COMPUTE_LOOP_sva);
  assign nor_109_nl = ~(exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm | (~ and_tmp_35));
  assign nor_110_nl = ~((~ or_tmp_247) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1 | (~
      and_tmp_35));
  assign nor_111_nl = ~((~ or_tmp_244) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1 | (~
      and_tmp_35));
  assign mux_255_nl = MUX_s_1_2_2(nor_110_nl, nor_111_nl, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign and_708_nl = or_tmp_89 & mux_255_nl;
  assign nor_112_nl = ~(COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1 | (~ and_tmp_35));
  assign mux_256_nl = MUX_s_1_2_2(and_708_nl, nor_112_nl, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_257_nl = MUX_s_1_2_2(nor_109_nl, mux_256_nl, main_stage_v_1);
  assign and_dcpl_196 = mux_257_nl & or_dcpl_16;
  assign and_tmp_124 = or_142_cse & or_143_cse & ((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3!=71'b00000000000000000000000000000000000000000000000000000000000000000000000));
  assign and_dcpl_301 = or_143_cse & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[0])
      | (ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[2])))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[4:3]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[7:5]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[9:8]!=2'b00)))
      & or_dcpl_16 & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[11:10]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[14:12]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[16:15]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[19:17]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[21:20]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[24:22]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[26:25]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[29:27]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[31:30]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[34:32]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[36:35]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[39:37]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[41:40]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[44:42]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[46:45]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[49:47]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[51:50]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[54:52]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[56:55]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[59:57]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[61:60]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[64:62]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[66:65]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[69:67]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[70])
      | (ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3[1])));
  assign or_dcpl_89 = ~(main_stage_v_19 & CALC_SOFTMAX_LOOP_equal_tmp_19);
  assign or_tmp_416 = COMPUTE_LOOP_if_asn_sft_lpi_1 | exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm;
  assign or_659_cse = (ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2!=71'b00000000000000000000000000000000000000000000000000000000000000000000000);
  assign and_tmp_126 = or_142_cse & or_143_cse & or_659_cse;
  assign and_tmp_129 = or_142_cse & or_143_cse & (COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_6
      | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_1 | (~(CALC_EXP_LOOP_and_svs_st_6
      & or_659_cse)));
  assign and_dcpl_426 = or_143_cse & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[0])
      | (ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[2])))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[4:3]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[7:5]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[9:8]!=2'b00)))
      & or_dcpl_16 & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[11:10]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[14:12]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[16:15]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[19:17]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[21:20]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[24:22]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[26:25]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[29:27]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[31:30]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[34:32]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[36:35]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[39:37]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[41:40]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[44:42]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[46:45]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[49:47]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[51:50]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[54:52]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[56:55]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[59:57]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[61:60]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[64:62]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[66:65]!=2'b00)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[69:67]!=3'b000)))
      & (~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[70])
      | (ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2[1])));
  assign or_dcpl_156 = COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_4 | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_1;
  assign or_dcpl_158 = ~(main_stage_v_4 & COMPUTE_LOOP_if_and_70_itm_4);
  assign or_dcpl_161 = ~(main_stage_v_4 & COMPUTE_LOOP_if_and_69_itm_4);
  assign or_dcpl_164 = ~(main_stage_v_4 & COMPUTE_LOOP_if_and_68_itm_4);
  assign or_dcpl_167 = ~(main_stage_v_4 & COMPUTE_LOOP_if_and_67_itm_4);
  assign or_dcpl_170 = ~(main_stage_v_4 & COMPUTE_LOOP_if_and_66_itm_4);
  assign or_dcpl_173 = ~(main_stage_v_4 & COMPUTE_LOOP_if_and_65_itm_4);
  assign or_dcpl_176 = ~(main_stage_v_4 & COMPUTE_LOOP_if_and_64_itm_4);
  assign or_dcpl_179 = ~(main_stage_v_4 & COMPUTE_LOOP_if_and_63_itm_4);
  assign or_dcpl_182 = ~(main_stage_v_4 & COMPUTE_LOOP_if_and_62_itm_4);
  assign or_dcpl_185 = ~(main_stage_v_4 & COMPUTE_LOOP_if_and_61_itm_4);
  assign or_dcpl_188 = ~(main_stage_v_4 & COMPUTE_LOOP_if_and_60_itm_4);
  assign or_dcpl_191 = ~(main_stage_v_4 & COMPUTE_LOOP_if_and_59_itm_4);
  assign or_dcpl_194 = ~(main_stage_v_4 & COMPUTE_LOOP_if_and_58_itm_4);
  assign or_dcpl_197 = ~(main_stage_v_4 & COMPUTE_LOOP_if_and_57_itm_4);
  assign or_dcpl_200 = ~(main_stage_v_4 & COMPUTE_LOOP_if_and_56_itm_4);
  assign or_dcpl_203 = ~(main_stage_v_4 & COMPUTE_LOOP_if_and_55_itm_4);
  assign and_dcpl_436 = and_dcpl_116 & (COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1 |
      (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_1) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_0);
  assign mux_279_nl = MUX_s_1_2_2(or_tmp_373, or_520_cse, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign mux_tmp_271 = MUX_s_1_2_2(mux_279_nl, or_tmp_368, CALC_SOFTMAX_LOOP_or_tmp_1);
  assign or_284_nl = (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0
      | COMPUTE_LOOP_if_asn_sft_lpi_1 | (~((COMPUTE_LOOP_acc_1_tmp[4]) & (CALC_SOFTMAX_LOOP_acc_1_tmp[4])
      & and_tmp_26));
  assign mux_108_nl = MUX_s_1_2_2(or_284_nl, or_tmp_167, exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm);
  assign mux_102_nl = MUX_s_1_2_2(and_tmp_33, and_tmp_30, lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2_1_1);
  assign nor_137_nl = ~(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_0 | (~ and_tmp_33));
  assign nor_138_nl = ~(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_0 | (~ and_tmp_30));
  assign mux_101_nl = MUX_s_1_2_2(nor_137_nl, nor_138_nl, lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1);
  assign mux_103_nl = MUX_s_1_2_2(mux_102_nl, mux_101_nl, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign mux_104_nl = MUX_s_1_2_2(mux_103_nl, and_tmp_31, CALC_SOFTMAX_LOOP_or_tmp_1);
  assign mux_105_nl = MUX_s_1_2_2((~ mux_104_nl), (~ and_tmp_26), COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_713_nl = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2_1_1 & and_tmp_30;
  assign nor_139_nl = ~((~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_0
      | (~ and_tmp_30));
  assign mux_99_nl = MUX_s_1_2_2(and_713_nl, nor_139_nl, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign mux_100_nl = MUX_s_1_2_2(mux_99_nl, and_tmp_31, CALC_SOFTMAX_LOOP_or_tmp_1);
  assign or_278_nl = COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1 | (~ mux_100_nl);
  assign mux_106_nl = MUX_s_1_2_2(mux_105_nl, or_278_nl, COMPUTE_LOOP_if_acc_itm_32_1);
  assign mux_107_nl = MUX_s_1_2_2(mux_106_nl, or_tmp_166, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_109_nl = MUX_s_1_2_2(mux_108_nl, mux_107_nl, main_stage_v_1);
  assign mux_98_nl = MUX_s_1_2_2(or_tmp_167, or_tmp_166, main_stage_v_1);
  assign mux_110_nl = MUX_s_1_2_2(mux_109_nl, mux_98_nl, exit_COMPUTE_LOOP_lpi_1_dfm_3);
  assign and_83_nl = COMPUTE_LOOP_if_acc_itm_32_1 & and_tmp_26;
  assign and_82_nl = COMPUTE_LOOP_if_acc_itm_32_1 & and_tmp_27;
  assign mux_97_nl = MUX_s_1_2_2(and_83_nl, and_82_nl, main_stage_v_1);
  assign mux_111_nl = MUX_s_1_2_2(mux_110_nl, mux_97_nl, exitL_exit_COMPUTE_LOOP_sva);
  assign or_tmp_446 = ((~ mux_111_nl) & main_stage_en_22) | (fsm_output[0]);
  assign or_296_cse = (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0
      | COMPUTE_LOOP_if_asn_sft_lpi_1 | (~ (COMPUTE_LOOP_acc_1_tmp[4])) | (~ (CALC_SOFTMAX_LOOP_acc_1_tmp[4]))
      | (~ main_stage_en_22);
  assign nand_189_cse = ~(reg_CALC_EXP_LOOP_and_svs_1_cse & (COMPUTE_LOOP_acc_1_tmp[4])
      & (CALC_SOFTMAX_LOOP_acc_1_tmp[4]) & main_stage_en_22);
  assign and_100_nl = or_296_cse & and_tmp_36;
  assign mux_119_nl = MUX_s_1_2_2(and_100_nl, and_tmp_37, exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm);
  assign mux_114_nl = MUX_s_1_2_2(and_tmp_37, and_tmp_42, lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2_1_1);
  assign mux_112_nl = MUX_s_1_2_2(and_tmp_37, and_tmp_42, lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1);
  assign mux_113_nl = MUX_s_1_2_2(mux_112_nl, and_tmp_36, lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_0);
  assign mux_115_nl = MUX_s_1_2_2(mux_114_nl, mux_113_nl, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign and_97_nl = nand_189_cse & and_tmp_36;
  assign mux_116_nl = MUX_s_1_2_2(mux_115_nl, and_97_nl, CALC_SOFTMAX_LOOP_or_tmp_1);
  assign and_99_nl = or_tmp_89 & mux_116_nl;
  assign mux_117_nl = MUX_s_1_2_2(and_99_nl, and_tmp_37, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_95_nl = or_tmp_5 & and_tmp_37;
  assign mux_118_nl = MUX_s_1_2_2(mux_117_nl, and_95_nl, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_120_nl = MUX_s_1_2_2(mux_119_nl, mux_118_nl, main_stage_v_1);
  assign and_94_nl = or_tmp_179 & and_tmp_37;
  assign mux_121_nl = MUX_s_1_2_2(mux_120_nl, and_94_nl, or_tmp_152);
  assign and_620_cse = mux_121_nl & and_dcpl_12 & (fsm_output[1]);
  assign and_636_cse = and_dcpl_146 & or_94_cse & COMPUTE_LOOP_if_acc_itm_32_1 &
      (fsm_output[1]);
  assign and_654_cse = and_dcpl_171 & or_94_cse & (fsm_output[1]);
  assign and_656_cse = and_dcpl_177 & or_94_cse & (fsm_output[1]);
  assign and_113_nl = or_296_cse & and_tmp_46;
  assign mux_129_nl = MUX_s_1_2_2(and_113_nl, and_tmp_47, exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm);
  assign mux_124_nl = MUX_s_1_2_2(and_tmp_47, and_tmp_52, lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2_1_1);
  assign mux_122_nl = MUX_s_1_2_2(and_tmp_47, and_tmp_52, lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1);
  assign mux_123_nl = MUX_s_1_2_2(mux_122_nl, and_tmp_46, lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_0);
  assign mux_125_nl = MUX_s_1_2_2(mux_124_nl, mux_123_nl, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign and_110_nl = nand_189_cse & and_tmp_46;
  assign mux_126_nl = MUX_s_1_2_2(mux_125_nl, and_110_nl, CALC_SOFTMAX_LOOP_or_tmp_1);
  assign and_112_nl = or_tmp_89 & mux_126_nl;
  assign mux_127_nl = MUX_s_1_2_2(and_112_nl, and_tmp_47, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_108_nl = or_tmp_5 & and_tmp_47;
  assign mux_128_nl = MUX_s_1_2_2(mux_127_nl, and_108_nl, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_130_nl = MUX_s_1_2_2(mux_129_nl, mux_128_nl, main_stage_v_1);
  assign and_107_nl = or_tmp_179 & and_tmp_47;
  assign mux_131_nl = MUX_s_1_2_2(mux_130_nl, and_107_nl, or_tmp_152);
  assign conf_info_rsci_iswt0_mx0c1 = and_620_cse | (mux_131_nl & main_stage_v_3
      & conf_info_rsci_bawt & COMPUTE_LOOP_asn_itm);
  assign plm_out_rsci_idat_31_0_mx0c1 = and_dcpl_25 & and_dcpl_23 & and_dcpl_20 &
      (~ CALC_SOFTMAX_LOOP_and_26_psp_18);
  assign plm_out_rsci_idat_63_32_mx0c1 = and_dcpl_25 & and_dcpl_23 & and_dcpl_20
      & (~ CALC_SOFTMAX_LOOP_and_24_psp_18);
  assign plm_out_rsci_idat_95_64_mx0c1 = and_dcpl_25 & and_dcpl_23 & and_dcpl_20
      & (~ CALC_SOFTMAX_LOOP_and_22_psp_18);
  assign plm_out_rsci_idat_127_96_mx0c1 = and_dcpl_25 & and_dcpl_23 & and_dcpl_20
      & (~ CALC_SOFTMAX_LOOP_and_20_psp_18);
  assign plm_out_rsci_idat_159_128_mx0c1 = and_dcpl_25 & and_dcpl_23 & and_dcpl_20
      & (~ CALC_SOFTMAX_LOOP_and_18_psp_18);
  assign plm_out_rsci_idat_191_160_mx0c1 = and_dcpl_25 & and_dcpl_23 & and_dcpl_20
      & (~ CALC_SOFTMAX_LOOP_and_16_psp_18);
  assign plm_out_rsci_idat_223_192_mx0c1 = and_dcpl_25 & and_dcpl_23 & and_dcpl_20
      & (~ CALC_SOFTMAX_LOOP_and_14_psp_18);
  assign plm_out_rsci_idat_255_224_mx0c1 = and_dcpl_25 & and_dcpl_23 & and_dcpl_20
      & (~ CALC_SOFTMAX_LOOP_and_12_psp_18);
  assign plm_out_rsci_idat_287_256_mx0c1 = and_dcpl_25 & and_dcpl_23 & and_dcpl_20
      & (~ CALC_SOFTMAX_LOOP_and_13_psp_18);
  assign plm_out_rsci_idat_319_288_mx0c1 = and_dcpl_25 & and_dcpl_23 & and_dcpl_20
      & (~ CALC_SOFTMAX_LOOP_and_15_psp_18);
  assign plm_out_rsci_idat_351_320_mx0c1 = and_dcpl_25 & and_dcpl_23 & and_dcpl_20
      & (~ CALC_SOFTMAX_LOOP_and_17_psp_18);
  assign plm_out_rsci_idat_383_352_mx0c1 = and_dcpl_25 & and_dcpl_23 & and_dcpl_20
      & (~ CALC_SOFTMAX_LOOP_and_19_psp_18);
  assign plm_out_rsci_idat_415_384_mx0c1 = and_dcpl_25 & and_dcpl_23 & and_dcpl_20
      & (~ CALC_SOFTMAX_LOOP_and_21_psp_18);
  assign plm_out_rsci_idat_447_416_mx0c1 = and_dcpl_25 & and_dcpl_23 & and_dcpl_20
      & (~ CALC_SOFTMAX_LOOP_and_23_psp_18);
  assign plm_out_rsci_idat_479_448_mx0c1 = and_dcpl_25 & and_dcpl_23 & and_dcpl_20
      & (~ CALC_SOFTMAX_LOOP_and_25_psp_18);
  assign nor_42_nl = ~(COMPUTE_LOOP_if_asn_sft_lpi_1 | (~ or_143_cse));
  assign mux_235_nl = MUX_s_1_2_2(nor_42_nl, and_tmp_105, exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm);
  assign and_332_nl = or_483_cse & and_tmp_76;
  assign and_331_nl = or_482_cse & and_tmp_76;
  assign mux_232_nl = MUX_s_1_2_2(and_332_nl, and_331_nl, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign mux_233_nl = MUX_s_1_2_2(mux_232_nl, and_tmp_105, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_231_nl = MUX_s_1_2_2(and_tmp_107, and_tmp_105, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_234_nl = MUX_s_1_2_2(mux_233_nl, mux_231_nl, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_236_nl = MUX_s_1_2_2(mux_235_nl, mux_234_nl, main_stage_v_1);
  assign mux_230_nl = MUX_s_1_2_2(and_tmp_107, and_tmp_105, or_238_cse);
  assign mux_237_nl = MUX_s_1_2_2(mux_236_nl, mux_230_nl, or_tmp_152);
  assign exit_COMPUTE_LOOP_lpi_1_dfm_3_mx0c1 = and_656_cse | (mux_237_nl & or_dcpl_16
      & or_84_cse & and_dcpl_173);
  assign and_347_nl = or_267_cse & and_tmp_35;
  assign mux_249_nl = MUX_s_1_2_2(and_346_cse, and_260_cse, or_tmp_373);
  assign mux_248_nl = MUX_s_1_2_2(and_346_cse, and_260_cse, or_520_cse);
  assign mux_250_nl = MUX_s_1_2_2(mux_249_nl, mux_248_nl, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign mux_247_nl = MUX_s_1_2_2(and_346_cse, and_260_cse, or_tmp_368);
  assign mux_251_nl = MUX_s_1_2_2(mux_250_nl, mux_247_nl, CALC_SOFTMAX_LOOP_or_tmp_1);
  assign mux_252_cse = MUX_s_1_2_2(and_347_nl, mux_251_nl, main_stage_v_1);
  assign nor_37_nl = ~(exitL_exit_COMPUTE_LOOP_sva | exit_COMPUTE_LOOP_lpi_1_dfm_3
      | (~ (CALC_SOFTMAX_LOOP_acc_1_tmp[4])));
  assign mux_253_nl = MUX_s_1_2_2(and_259_cse, mux_252_cse, nor_37_nl);
  assign COMPUTE_LOOP_b_4_0_lpi_1_3_0_mx0c1 = mux_253_nl & or_dcpl_16 & or_94_cse;
  assign main_stage_v_1_mx0c1 = and_dcpl_193 & main_stage_v_1 & (~ conf_info_rsci_bawt)
      & COMPUTE_LOOP_asn_itm;
  assign COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1 = (and_dcpl_146 & or_94_cse
      & (fsm_output[1])) | (and_dcpl_151 & and_dcpl_173);
  assign nor_108_nl = ~(or_tmp_5 | (~ mux_tmp_138));
  assign mux_262_nl = MUX_s_1_2_2(mux_tmp_138, nor_108_nl, main_stage_v_1);
  assign main_stage_v_2_mx0c1 = mux_262_nl & or_dcpl_16 & main_stage_v_2;
  assign main_stage_v_3_mx0c1 = and_dcpl_25 & or_84_cse & main_stage_v_3 & (~ main_stage_v_2);
  assign main_stage_v_4_mx0c1 = (~(or_84_cse & main_stage_v_3)) & or_143_cse & or_dcpl_16
      & main_stage_v_4;
  assign main_stage_v_5_mx0c1 = and_dcpl_25 & main_stage_v_5 & (~ main_stage_v_4);
  assign main_stage_v_6_mx0c1 = and_dcpl_25 & (~ main_stage_v_5) & main_stage_v_6;
  assign main_stage_v_7_mx0c1 = and_dcpl_25 & main_stage_v_7 & (~ main_stage_v_6);
  assign main_stage_v_8_mx0c1 = and_dcpl_25 & main_stage_v_8 & (~ main_stage_v_7);
  assign main_stage_v_9_mx0c1 = and_dcpl_25 & main_stage_v_9 & (~ main_stage_v_8);
  assign main_stage_v_10_mx0c1 = and_dcpl_25 & main_stage_v_10 & (~ main_stage_v_9);
  assign main_stage_v_11_mx0c1 = and_dcpl_25 & (~ main_stage_v_10) & main_stage_v_11;
  assign main_stage_v_12_mx0c1 = and_dcpl_25 & (~ main_stage_v_11) & main_stage_v_12;
  assign main_stage_v_13_mx0c1 = and_dcpl_25 & main_stage_v_13 & (~ main_stage_v_12);
  assign main_stage_v_14_mx0c1 = and_dcpl_25 & main_stage_v_14 & (~ main_stage_v_13);
  assign main_stage_v_15_mx0c1 = and_dcpl_25 & main_stage_v_15 & (~ main_stage_v_14);
  assign main_stage_v_16_mx0c1 = and_dcpl_25 & main_stage_v_16 & (~ main_stage_v_15);
  assign main_stage_v_17_mx0c1 = and_dcpl_25 & (~ main_stage_v_16) & main_stage_v_17;
  assign main_stage_v_18_mx0c1 = and_dcpl_25 & main_stage_v_18 & (~ main_stage_v_17);
  assign main_stage_v_19_mx0c1 = and_dcpl_25 & (~ main_stage_v_18) & main_stage_v_19;
  assign main_stage_v_20_mx0c1 = and_dcpl_124 & main_stage_v_20 & (~ main_stage_v_19);
  assign main_stage_v_21_mx0c1 = (and_dcpl_131 | (~ main_stage_v_20)) & or_dcpl_15
      & main_stage_v_21;
  assign mux_278_nl = MUX_s_1_2_2(mux_252_cse, and_259_cse, or_tmp_152);
  assign CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_1_mx0c1 = mux_278_nl
      & or_dcpl_16;
  assign CALC_SOFTMAX_LOOP_mul_cmp_a = CALC_SOFTMAX_LOOP_mux_40_itm_4;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_and_1_nl
      = (~ or_dcpl_41) & (fsm_output[1]);
  assign CALC_SOFTMAX_LOOP_mul_cmp_b = MUX_v_91_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_1,
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_1_dfm_1,
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_and_1_nl);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_iswt0 <= 1'b0;
    end
    else if ( core_wen & (or_tmp_446 | conf_info_rsci_iswt0_mx0c1) ) begin
      conf_info_rsci_iswt0 <= (~ conf_info_rsci_iswt0_mx0c1) | or_tmp_446;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_irdy_core_psct <= 1'b0;
    end
    else if ( core_wen & (or_tmp_446 | and_620_cse) ) begin
      conf_info_rsci_irdy_core_psct <= ~ and_620_cse;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exitL_exit_COMPUTE_LOOP_sva <= 1'b1;
    end
    else if ( core_wen & (~(or_dcpl_14 | (fsm_output[0]))) ) begin
      exitL_exit_COMPUTE_LOOP_sva <= exit_COMPUTE_LOOP_lpi_1_dfm_3_mx1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_idat_31_0 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_25 & and_dcpl_23 & and_dcpl_20 & CALC_SOFTMAX_LOOP_and_26_psp_18)
        | plm_out_rsci_idat_31_0_mx0c1) ) begin
      plm_out_rsci_idat_31_0 <= MUX_v_32_2_2((CALC_SOFTMAX_LOOP_mul_cmp_z[91:60]),
          COMPUTE_LOOP_plm_out_tmp_data_0_lpi_1, plm_out_rsci_idat_31_0_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_idat_63_32 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_25 & and_dcpl_23 & and_dcpl_20 & CALC_SOFTMAX_LOOP_and_24_psp_18)
        | plm_out_rsci_idat_63_32_mx0c1) ) begin
      plm_out_rsci_idat_63_32 <= MUX_v_32_2_2((CALC_SOFTMAX_LOOP_mul_cmp_z[91:60]),
          COMPUTE_LOOP_plm_out_tmp_data_1_lpi_1, plm_out_rsci_idat_63_32_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_idat_95_64 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_25 & and_dcpl_23 & and_dcpl_20 & CALC_SOFTMAX_LOOP_and_22_psp_18)
        | plm_out_rsci_idat_95_64_mx0c1) ) begin
      plm_out_rsci_idat_95_64 <= MUX_v_32_2_2((CALC_SOFTMAX_LOOP_mul_cmp_z[91:60]),
          COMPUTE_LOOP_plm_out_tmp_data_2_lpi_1, plm_out_rsci_idat_95_64_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_idat_127_96 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_25 & and_dcpl_23 & and_dcpl_20 & CALC_SOFTMAX_LOOP_and_20_psp_18)
        | plm_out_rsci_idat_127_96_mx0c1) ) begin
      plm_out_rsci_idat_127_96 <= MUX_v_32_2_2((CALC_SOFTMAX_LOOP_mul_cmp_z[91:60]),
          COMPUTE_LOOP_plm_out_tmp_data_3_lpi_1, plm_out_rsci_idat_127_96_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_idat_159_128 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_25 & and_dcpl_23 & and_dcpl_20 & CALC_SOFTMAX_LOOP_and_18_psp_18)
        | plm_out_rsci_idat_159_128_mx0c1) ) begin
      plm_out_rsci_idat_159_128 <= MUX_v_32_2_2((CALC_SOFTMAX_LOOP_mul_cmp_z[91:60]),
          COMPUTE_LOOP_plm_out_tmp_data_4_lpi_1, plm_out_rsci_idat_159_128_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_idat_191_160 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_25 & and_dcpl_23 & and_dcpl_20 & CALC_SOFTMAX_LOOP_and_16_psp_18)
        | plm_out_rsci_idat_191_160_mx0c1) ) begin
      plm_out_rsci_idat_191_160 <= MUX_v_32_2_2((CALC_SOFTMAX_LOOP_mul_cmp_z[91:60]),
          COMPUTE_LOOP_plm_out_tmp_data_5_lpi_1, plm_out_rsci_idat_191_160_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_idat_223_192 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_25 & and_dcpl_23 & and_dcpl_20 & CALC_SOFTMAX_LOOP_and_14_psp_18)
        | plm_out_rsci_idat_223_192_mx0c1) ) begin
      plm_out_rsci_idat_223_192 <= MUX_v_32_2_2((CALC_SOFTMAX_LOOP_mul_cmp_z[91:60]),
          COMPUTE_LOOP_plm_out_tmp_data_6_lpi_1, plm_out_rsci_idat_223_192_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_idat_255_224 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_25 & and_dcpl_23 & and_dcpl_20 & CALC_SOFTMAX_LOOP_and_12_psp_18)
        | plm_out_rsci_idat_255_224_mx0c1) ) begin
      plm_out_rsci_idat_255_224 <= MUX_v_32_2_2((CALC_SOFTMAX_LOOP_mul_cmp_z[91:60]),
          COMPUTE_LOOP_plm_out_tmp_data_7_lpi_1, plm_out_rsci_idat_255_224_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_idat_287_256 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_25 & and_dcpl_23 & and_dcpl_20 & CALC_SOFTMAX_LOOP_and_13_psp_18)
        | plm_out_rsci_idat_287_256_mx0c1) ) begin
      plm_out_rsci_idat_287_256 <= MUX_v_32_2_2((CALC_SOFTMAX_LOOP_mul_cmp_z[91:60]),
          COMPUTE_LOOP_plm_out_tmp_data_8_lpi_1, plm_out_rsci_idat_287_256_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_idat_319_288 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_25 & and_dcpl_23 & and_dcpl_20 & CALC_SOFTMAX_LOOP_and_15_psp_18)
        | plm_out_rsci_idat_319_288_mx0c1) ) begin
      plm_out_rsci_idat_319_288 <= MUX_v_32_2_2((CALC_SOFTMAX_LOOP_mul_cmp_z[91:60]),
          COMPUTE_LOOP_plm_out_tmp_data_9_lpi_1, plm_out_rsci_idat_319_288_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_idat_351_320 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_25 & and_dcpl_23 & and_dcpl_20 & CALC_SOFTMAX_LOOP_and_17_psp_18)
        | plm_out_rsci_idat_351_320_mx0c1) ) begin
      plm_out_rsci_idat_351_320 <= MUX_v_32_2_2((CALC_SOFTMAX_LOOP_mul_cmp_z[91:60]),
          COMPUTE_LOOP_plm_out_tmp_data_10_lpi_1, plm_out_rsci_idat_351_320_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_idat_383_352 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_25 & and_dcpl_23 & and_dcpl_20 & CALC_SOFTMAX_LOOP_and_19_psp_18)
        | plm_out_rsci_idat_383_352_mx0c1) ) begin
      plm_out_rsci_idat_383_352 <= MUX_v_32_2_2((CALC_SOFTMAX_LOOP_mul_cmp_z[91:60]),
          COMPUTE_LOOP_plm_out_tmp_data_11_lpi_1, plm_out_rsci_idat_383_352_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_idat_415_384 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_25 & and_dcpl_23 & and_dcpl_20 & CALC_SOFTMAX_LOOP_and_21_psp_18)
        | plm_out_rsci_idat_415_384_mx0c1) ) begin
      plm_out_rsci_idat_415_384 <= MUX_v_32_2_2((CALC_SOFTMAX_LOOP_mul_cmp_z[91:60]),
          COMPUTE_LOOP_plm_out_tmp_data_12_lpi_1, plm_out_rsci_idat_415_384_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_idat_447_416 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_25 & and_dcpl_23 & and_dcpl_20 & CALC_SOFTMAX_LOOP_and_23_psp_18)
        | plm_out_rsci_idat_447_416_mx0c1) ) begin
      plm_out_rsci_idat_447_416 <= MUX_v_32_2_2((CALC_SOFTMAX_LOOP_mul_cmp_z[91:60]),
          COMPUTE_LOOP_plm_out_tmp_data_13_lpi_1, plm_out_rsci_idat_447_416_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_idat_479_448 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_25 & and_dcpl_23 & and_dcpl_20 & CALC_SOFTMAX_LOOP_and_25_psp_18)
        | plm_out_rsci_idat_479_448_mx0c1) ) begin
      plm_out_rsci_idat_479_448 <= MUX_v_32_2_2((CALC_SOFTMAX_LOOP_mul_cmp_z[91:60]),
          COMPUTE_LOOP_plm_out_tmp_data_14_lpi_1, plm_out_rsci_idat_479_448_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_idat_511_480 <= 32'b00000000000000000000000000000000;
    end
    else if ( COMPUTE_LOOP_and_16_cse & (~(or_dcpl_21 | or_dcpl_20)) ) begin
      plm_out_rsci_idat_511_480 <= CALC_SOFTMAX_LOOP_mul_cmp_z[91:60];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_iswt1
          <= 1'b0;
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_b_core
          <= 32'b00000000000000000000000000000000;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1 <= 1'b0;
    end
    else if ( core_wen ) begin
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_iswt1
          <= and_dcpl_116 & or_tmp_89 & and_dcpl_114 & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_1);
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_b_core
          <= MUX_v_32_16_2(COMPUTE_LOOP_if_mux_107_nl, COMPUTE_LOOP_if_mux_109_nl,
          COMPUTE_LOOP_if_mux_110_nl, COMPUTE_LOOP_if_mux_111_nl, COMPUTE_LOOP_if_mux_112_nl,
          COMPUTE_LOOP_if_mux_113_nl, COMPUTE_LOOP_if_mux_114_nl, COMPUTE_LOOP_if_mux_115_nl,
          COMPUTE_LOOP_if_mux_116_nl, COMPUTE_LOOP_if_mux_117_nl, COMPUTE_LOOP_if_mux_118_nl,
          COMPUTE_LOOP_if_mux_119_nl, COMPUTE_LOOP_if_mux_120_nl, COMPUTE_LOOP_if_mux_121_nl,
          COMPUTE_LOOP_if_mux_122_nl, COMPUTE_LOOP_if_mux_123_nl, CALC_EXP_LOOP_i_4_0_lpi_1_dfm_1_3_0);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1_mx0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0_mx0;
      COMPUTE_LOOP_if_asn_sft_lpi_1 <= COMPUTE_LOOP_if_asn_sft_lpi_1_mx0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_done_rsci_ivld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_124 & main_stage_v_20 & exit_COMPUTE_LOOP_lpi_1_dfm_3_st_20)
        | and_dcpl_132) ) begin
      reg_done_rsci_ivld_core_psct_cse <= ~ and_dcpl_132;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_plm_out_rsci_ivld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & and_dcpl_23 & and_dcpl_20) | and_dcpl_140)
        ) begin
      reg_plm_out_rsci_ivld_core_psct_cse <= ~ and_dcpl_140;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_irdy_core_psct <= 1'b0;
    end
    else if ( core_wen & (and_636_cse | (and_dcpl_151 & main_stage_v_3 & COMPUTE_LOOP_if_acc_itm_32_1
        & or_94_cse) | and_dcpl_156) ) begin
      plm_in_rsci_irdy_core_psct <= ~ and_dcpl_156;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_iswt0 <= 1'b0;
    end
    else if ( core_wen & (and_636_cse | and_dcpl_156) ) begin
      plm_in_rsci_iswt0 <= ~ and_dcpl_156;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_asn_itm <= 1'b1;
    end
    else if ( core_wen & ((main_stage_en_22 & (fsm_output[1])) | (main_stage_v_3
        & main_stage_en_22)) ) begin
      COMPUTE_LOOP_asn_itm <= exit_COMPUTE_LOOP_lpi_1_dfm_3_mx1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_1
          <= 91'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ or_143_cse) | and_44_cse | or_dcpl_41)) ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_1
          <= ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_1_dfm_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_COMPUTE_LOOP_lpi_1_dfm_3 <= 1'b0;
    end
    else if ( core_wen & (and_654_cse | (mux_221_nl & or_dcpl_16 & or_84_cse & and_dcpl_173)
        | exit_COMPUTE_LOOP_lpi_1_dfm_3_mx0c1) ) begin
      exit_COMPUTE_LOOP_lpi_1_dfm_3 <= MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
          CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_89_nl, exit_COMPUTE_LOOP_lpi_1_dfm_3_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0 <= 4'b0000;
    end
    else if ( core_wen & (~(or_dcpl_52 | and_dcpl_183 | (~ main_stage_v_1))) ) begin
      CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0 <= CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_b_4_0_lpi_1_3_0 <= 4'b0000;
    end
    else if ( core_wen & ((and_dcpl_187 & (~ exit_COMPUTE_LOOP_lpi_1_dfm_3) & (CALC_SOFTMAX_LOOP_acc_1_tmp[4])
        & (~ exitL_exit_COMPUTE_LOOP_sva) & or_94_cse) | COMPUTE_LOOP_b_4_0_lpi_1_3_0_mx0c1)
        ) begin
      COMPUTE_LOOP_b_4_0_lpi_1_3_0 <= MUX_v_4_2_2((COMPUTE_LOOP_acc_1_tmp[3:0]),
          COMPUTE_LOOP_b_4_0_lpi_1_dfm_3_0_1, COMPUTE_LOOP_b_4_0_lpi_1_3_0_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      batch_lpi_1_dfm <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & exitL_exit_COMPUTE_LOOP_sva ) begin
      batch_lpi_1_dfm <= conf_info_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm <= 1'b0;
    end
    else if ( COMPUTE_LOOP_and_16_cse ) begin
      exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm <= exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_mx1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_1 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_158 & or_94_cse & (fsm_output[1])) | main_stage_v_1_mx0c1)
        ) begin
      main_stage_v_1 <= ~ main_stage_v_1_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_196 & and_dcpl_195) | and_dcpl_146) ) begin
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1 <= MUX_s_1_2_2(COMPUTE_LOOP_if_asn_sft_lpi_1_mx0,
          exit_COMPUTE_LOOP_lpi_1_dfm_4, and_dcpl_146);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_i_4_0_lpi_1_dfm_1_3_0 <= 4'b0000;
      CALC_SOFTMAX_LOOP_or_tmp_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_1_1 <= 1'b0;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1 <= 1'b0;
      CALC_EXP_LOOP_i_4_0_lpi_1_dfm_1_3_0 <= 4'b0000;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_0 <= 1'b0;
      reg_CALC_EXP_LOOP_and_svs_1_cse <= 1'b0;
      COMPUTE_LOOP_if_and_55_itm_1 <= 1'b0;
      COMPUTE_LOOP_if_and_56_itm_1 <= 1'b0;
      COMPUTE_LOOP_if_and_57_itm_1 <= 1'b0;
      COMPUTE_LOOP_if_and_58_itm_1 <= 1'b0;
      COMPUTE_LOOP_if_and_59_itm_1 <= 1'b0;
      COMPUTE_LOOP_if_and_60_itm_1 <= 1'b0;
      COMPUTE_LOOP_if_and_61_itm_1 <= 1'b0;
      COMPUTE_LOOP_if_and_62_itm_1 <= 1'b0;
      COMPUTE_LOOP_if_and_63_itm_1 <= 1'b0;
      COMPUTE_LOOP_if_and_64_itm_1 <= 1'b0;
      COMPUTE_LOOP_if_and_65_itm_1 <= 1'b0;
      COMPUTE_LOOP_if_and_66_itm_1 <= 1'b0;
      COMPUTE_LOOP_if_and_67_itm_1 <= 1'b0;
      COMPUTE_LOOP_if_and_68_itm_1 <= 1'b0;
      COMPUTE_LOOP_if_and_69_itm_1 <= 1'b0;
      COMPUTE_LOOP_if_and_70_itm_1 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_i_and_1_cse ) begin
      CALC_SOFTMAX_LOOP_i_4_0_lpi_1_dfm_1_3_0 <= MUX_v_4_2_2(4'b0000, CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0_mx1,
          CALC_EXP_LOOP_not_6_nl);
      CALC_SOFTMAX_LOOP_or_tmp_1 <= (lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_mx1
          & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_mx1)) | (~(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_mx1
          | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_mx1));
      CALC_SOFTMAX_LOOP_equal_tmp_1 <= CALC_SOFTMAX_LOOP_equal_tmp_mx0w0;
      CALC_SOFTMAX_LOOP_equal_tmp_1_1 <= CALC_SOFTMAX_LOOP_equal_tmp_1_mx0w0;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1 <= ~ exitL_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1;
      CALC_EXP_LOOP_i_4_0_lpi_1_dfm_1_3_0 <= CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_mx0w0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_mx0w0;
      reg_CALC_EXP_LOOP_and_svs_1_cse <= CALC_EXP_LOOP_and_svs_mx0w0;
      COMPUTE_LOOP_if_and_55_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_0_sva_1
          & (~ (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[3])) & COMPUTE_LOOP_if_nor_2_cse
          & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1);
      COMPUTE_LOOP_if_and_56_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_1_sva_1
          & (~ (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[3])) & COMPUTE_LOOP_if_nor_2_cse
          & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1);
      COMPUTE_LOOP_if_and_57_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_2_sva_1
          & (~ (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[3])) & COMPUTE_LOOP_if_nor_2_cse
          & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1);
      COMPUTE_LOOP_if_and_58_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_3_sva_1
          & (~ (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[3])) & COMPUTE_LOOP_if_nor_2_cse
          & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1);
      COMPUTE_LOOP_if_and_59_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_4_sva_1
          & (~ (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[3])) & COMPUTE_LOOP_if_nor_2_cse
          & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1);
      COMPUTE_LOOP_if_and_60_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_5_sva_1
          & (~ (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[3])) & COMPUTE_LOOP_if_nor_2_cse
          & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1);
      COMPUTE_LOOP_if_and_61_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_6_sva_1
          & (~ (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[3])) & COMPUTE_LOOP_if_nor_2_cse
          & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1);
      COMPUTE_LOOP_if_and_62_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_7_sva_1
          & (~ (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[3])) & COMPUTE_LOOP_if_nor_2_cse
          & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1);
      COMPUTE_LOOP_if_and_63_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_0_sva_1
          & (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[3]) & COMPUTE_LOOP_if_nor_2_cse
          & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1);
      COMPUTE_LOOP_if_and_64_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_1_sva_1
          & (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[3]) & COMPUTE_LOOP_if_nor_2_cse
          & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1);
      COMPUTE_LOOP_if_and_65_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_2_sva_1
          & (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[3]) & COMPUTE_LOOP_if_nor_2_cse
          & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1);
      COMPUTE_LOOP_if_and_66_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_3_sva_1
          & (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[3]) & COMPUTE_LOOP_if_nor_2_cse
          & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1);
      COMPUTE_LOOP_if_and_67_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_4_sva_1
          & (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[3]) & COMPUTE_LOOP_if_nor_2_cse
          & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1);
      COMPUTE_LOOP_if_and_68_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_5_sva_1
          & (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[3]) & COMPUTE_LOOP_if_nor_2_cse
          & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1);
      COMPUTE_LOOP_if_and_69_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_6_sva_1
          & (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[3]) & COMPUTE_LOOP_if_nor_2_cse
          & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1);
      COMPUTE_LOOP_if_and_70_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_7_sva_1
          & (CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0[3]) & COMPUTE_LOOP_if_nor_2_cse
          & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_i_4_0_sva_1_1_3_0 <= 4'b0000;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2_1_1 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_i_and_2_cse ) begin
      CALC_SOFTMAX_LOOP_i_4_0_sva_1_1_3_0 <= CALC_SOFTMAX_LOOP_acc_1_tmp[3:0];
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2_1_1 <= ~ (CALC_SOFTMAX_LOOP_acc_1_tmp[4]);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_plm_in_tmp_data_lpi_1 <= 512'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_tmp_138) | and_44_cse | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1
        | and_dcpl_183 | (~ main_stage_v_1) | lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1))
        ) begin
      COMPUTE_LOOP_plm_in_tmp_data_lpi_1 <= plm_in_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_0 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_1 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_56_cse ) begin
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_1 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_mx0w0,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1, and_dcpl_171);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_0 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_mx0w0,
          reg_lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_cse, and_dcpl_171);
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_1 <= MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
          CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_68_nl, and_dcpl_177);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1 <= 1'b0;
    end
    else if ( core_wen & (and_656_cse | and_654_cse) ) begin
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1 <= MUX_s_1_2_2((~ exitL_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1),
          lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st, and_654_cse);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_196 & and_dcpl_195 & or_94_cse) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1)
        ) begin
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1 <= MUX_s_1_2_2(COMPUTE_LOOP_if_asn_sft_lpi_1_mx0,
          exit_COMPUTE_LOOP_lpi_1_dfm_4, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_2 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_193 & main_stage_v_1) | main_stage_v_2_mx0c1)
        ) begin
      main_stage_v_2 <= ~ main_stage_v_2_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_3 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_116 & main_stage_v_2) | main_stage_v_3_mx0c1)
        ) begin
      main_stage_v_3 <= ~ main_stage_v_3_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_1 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_3 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_59_cse ) begin
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_1;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_3 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_2;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_0 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_2 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_1 <= 1'b0;
      CALC_EXP_LOOP_and_svs_st_3 <= 1'b0;
      CALC_EXP_LOOP_and_svs_st_2 <= 1'b0;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_1_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_3 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_3 <= 1'b0;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_1_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_2 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_itm_1 <= 4'b0000;
      COMPUTE_LOOP_if_and_55_itm_3 <= 1'b0;
      COMPUTE_LOOP_if_and_56_itm_3 <= 1'b0;
      COMPUTE_LOOP_if_and_57_itm_3 <= 1'b0;
      COMPUTE_LOOP_if_and_58_itm_3 <= 1'b0;
      COMPUTE_LOOP_if_and_59_itm_3 <= 1'b0;
      COMPUTE_LOOP_if_and_60_itm_3 <= 1'b0;
      COMPUTE_LOOP_if_and_61_itm_3 <= 1'b0;
      COMPUTE_LOOP_if_and_62_itm_3 <= 1'b0;
      COMPUTE_LOOP_if_and_63_itm_3 <= 1'b0;
      COMPUTE_LOOP_if_and_64_itm_3 <= 1'b0;
      COMPUTE_LOOP_if_and_65_itm_3 <= 1'b0;
      COMPUTE_LOOP_if_and_66_itm_3 <= 1'b0;
      COMPUTE_LOOP_if_and_67_itm_3 <= 1'b0;
      COMPUTE_LOOP_if_and_68_itm_3 <= 1'b0;
      COMPUTE_LOOP_if_and_69_itm_3 <= 1'b0;
      COMPUTE_LOOP_if_and_70_itm_3 <= 1'b0;
      COMPUTE_LOOP_if_and_71_itm_2 <= 1'b0;
      COMPUTE_LOOP_if_and_55_itm_2 <= 1'b0;
      COMPUTE_LOOP_if_and_56_itm_2 <= 1'b0;
      COMPUTE_LOOP_if_and_57_itm_2 <= 1'b0;
      COMPUTE_LOOP_if_and_58_itm_2 <= 1'b0;
      COMPUTE_LOOP_if_and_59_itm_2 <= 1'b0;
      COMPUTE_LOOP_if_and_60_itm_2 <= 1'b0;
      COMPUTE_LOOP_if_and_61_itm_2 <= 1'b0;
      COMPUTE_LOOP_if_and_62_itm_2 <= 1'b0;
      COMPUTE_LOOP_if_and_63_itm_2 <= 1'b0;
      COMPUTE_LOOP_if_and_64_itm_2 <= 1'b0;
      COMPUTE_LOOP_if_and_65_itm_2 <= 1'b0;
      COMPUTE_LOOP_if_and_66_itm_2 <= 1'b0;
      COMPUTE_LOOP_if_and_67_itm_2 <= 1'b0;
      COMPUTE_LOOP_if_and_68_itm_2 <= 1'b0;
      COMPUTE_LOOP_if_and_69_itm_2 <= 1'b0;
      COMPUTE_LOOP_if_and_70_itm_2 <= 1'b0;
      COMPUTE_LOOP_if_and_71_itm_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_2 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_3 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_2 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_84_cse ) begin
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_2 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_1;
      CALC_EXP_LOOP_and_svs_st_3 <= CALC_EXP_LOOP_and_svs_st_2;
      CALC_EXP_LOOP_and_svs_st_2 <= reg_CALC_EXP_LOOP_and_svs_1_cse;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3 <= lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2;
      CALC_SOFTMAX_LOOP_equal_tmp_1_3 <= CALC_SOFTMAX_LOOP_equal_tmp_1_2;
      CALC_SOFTMAX_LOOP_equal_tmp_3 <= CALC_SOFTMAX_LOOP_equal_tmp_2;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_3 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_2;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2 <= lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1;
      CALC_SOFTMAX_LOOP_equal_tmp_1_2 <= CALC_SOFTMAX_LOOP_equal_tmp_1_1;
      CALC_SOFTMAX_LOOP_equal_tmp_2 <= CALC_SOFTMAX_LOOP_equal_tmp_1;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_2 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_itm_1 <= CALC_SOFTMAX_LOOP_i_4_0_lpi_1_3_0;
      COMPUTE_LOOP_if_and_55_itm_3 <= COMPUTE_LOOP_if_and_55_itm_2;
      COMPUTE_LOOP_if_and_56_itm_3 <= COMPUTE_LOOP_if_and_56_itm_2;
      COMPUTE_LOOP_if_and_57_itm_3 <= COMPUTE_LOOP_if_and_57_itm_2;
      COMPUTE_LOOP_if_and_58_itm_3 <= COMPUTE_LOOP_if_and_58_itm_2;
      COMPUTE_LOOP_if_and_59_itm_3 <= COMPUTE_LOOP_if_and_59_itm_2;
      COMPUTE_LOOP_if_and_60_itm_3 <= COMPUTE_LOOP_if_and_60_itm_2;
      COMPUTE_LOOP_if_and_61_itm_3 <= COMPUTE_LOOP_if_and_61_itm_2;
      COMPUTE_LOOP_if_and_62_itm_3 <= COMPUTE_LOOP_if_and_62_itm_2;
      COMPUTE_LOOP_if_and_63_itm_3 <= COMPUTE_LOOP_if_and_63_itm_2;
      COMPUTE_LOOP_if_and_64_itm_3 <= COMPUTE_LOOP_if_and_64_itm_2;
      COMPUTE_LOOP_if_and_65_itm_3 <= COMPUTE_LOOP_if_and_65_itm_2;
      COMPUTE_LOOP_if_and_66_itm_3 <= COMPUTE_LOOP_if_and_66_itm_2;
      COMPUTE_LOOP_if_and_67_itm_3 <= COMPUTE_LOOP_if_and_67_itm_2;
      COMPUTE_LOOP_if_and_68_itm_3 <= COMPUTE_LOOP_if_and_68_itm_2;
      COMPUTE_LOOP_if_and_69_itm_3 <= COMPUTE_LOOP_if_and_69_itm_2;
      COMPUTE_LOOP_if_and_70_itm_3 <= COMPUTE_LOOP_if_and_70_itm_2;
      COMPUTE_LOOP_if_and_71_itm_2 <= COMPUTE_LOOP_if_and_71_itm_1;
      COMPUTE_LOOP_if_and_55_itm_2 <= COMPUTE_LOOP_if_and_55_itm_1;
      COMPUTE_LOOP_if_and_56_itm_2 <= COMPUTE_LOOP_if_and_56_itm_1;
      COMPUTE_LOOP_if_and_57_itm_2 <= COMPUTE_LOOP_if_and_57_itm_1;
      COMPUTE_LOOP_if_and_58_itm_2 <= COMPUTE_LOOP_if_and_58_itm_1;
      COMPUTE_LOOP_if_and_59_itm_2 <= COMPUTE_LOOP_if_and_59_itm_1;
      COMPUTE_LOOP_if_and_60_itm_2 <= COMPUTE_LOOP_if_and_60_itm_1;
      COMPUTE_LOOP_if_and_61_itm_2 <= COMPUTE_LOOP_if_and_61_itm_1;
      COMPUTE_LOOP_if_and_62_itm_2 <= COMPUTE_LOOP_if_and_62_itm_1;
      COMPUTE_LOOP_if_and_63_itm_2 <= COMPUTE_LOOP_if_and_63_itm_1;
      COMPUTE_LOOP_if_and_64_itm_2 <= COMPUTE_LOOP_if_and_64_itm_1;
      COMPUTE_LOOP_if_and_65_itm_2 <= COMPUTE_LOOP_if_and_65_itm_1;
      COMPUTE_LOOP_if_and_66_itm_2 <= COMPUTE_LOOP_if_and_66_itm_1;
      COMPUTE_LOOP_if_and_67_itm_2 <= COMPUTE_LOOP_if_and_67_itm_1;
      COMPUTE_LOOP_if_and_68_itm_2 <= COMPUTE_LOOP_if_and_68_itm_1;
      COMPUTE_LOOP_if_and_69_itm_2 <= COMPUTE_LOOP_if_and_69_itm_1;
      COMPUTE_LOOP_if_and_70_itm_2 <= COMPUTE_LOOP_if_and_70_itm_1;
      COMPUTE_LOOP_if_and_71_itm_1 <= reg_CALC_EXP_LOOP_and_svs_1_cse & (~(CALC_SOFTMAX_LOOP_equal_tmp_1
          | CALC_SOFTMAX_LOOP_equal_tmp_1_1)) & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1);
      CALC_SOFTMAX_LOOP_and_12_psp_2 <= CALC_SOFTMAX_LOOP_and_12_psp_1;
      CALC_SOFTMAX_LOOP_and_13_psp_2 <= CALC_SOFTMAX_LOOP_and_13_psp_1;
      CALC_SOFTMAX_LOOP_and_14_psp_2 <= CALC_SOFTMAX_LOOP_and_14_psp_1;
      CALC_SOFTMAX_LOOP_and_15_psp_2 <= CALC_SOFTMAX_LOOP_and_15_psp_1;
      CALC_SOFTMAX_LOOP_and_16_psp_2 <= CALC_SOFTMAX_LOOP_and_16_psp_1;
      CALC_SOFTMAX_LOOP_and_17_psp_2 <= CALC_SOFTMAX_LOOP_and_17_psp_1;
      CALC_SOFTMAX_LOOP_and_18_psp_2 <= CALC_SOFTMAX_LOOP_and_18_psp_1;
      CALC_SOFTMAX_LOOP_and_19_psp_2 <= CALC_SOFTMAX_LOOP_and_19_psp_1;
      CALC_SOFTMAX_LOOP_and_20_psp_2 <= CALC_SOFTMAX_LOOP_and_20_psp_1;
      CALC_SOFTMAX_LOOP_and_21_psp_2 <= CALC_SOFTMAX_LOOP_and_21_psp_1;
      CALC_SOFTMAX_LOOP_and_22_psp_2 <= CALC_SOFTMAX_LOOP_and_22_psp_1;
      CALC_SOFTMAX_LOOP_and_23_psp_2 <= CALC_SOFTMAX_LOOP_and_23_psp_1;
      CALC_SOFTMAX_LOOP_and_24_psp_2 <= CALC_SOFTMAX_LOOP_and_24_psp_1;
      CALC_SOFTMAX_LOOP_and_25_psp_2 <= CALC_SOFTMAX_LOOP_and_25_psp_1;
      CALC_SOFTMAX_LOOP_and_26_psp_2 <= CALC_SOFTMAX_LOOP_and_26_psp_1;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_3 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_2;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_2 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_1;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_3 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_2;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_2 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_4 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & or_84_cse & main_stage_v_3) | main_stage_v_4_mx0c1)
        ) begin
      main_stage_v_4 <= ~ main_stage_v_4_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_EXP_LOOP_and_svs_st_4 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_4 <= 1'b0;
      CALC_EXP_LOOP_and_svs_st_5 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_5 <= 1'b0;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2
          <= 71'b00000000000000000000000000000000000000000000000000000000000000000000000;
      CALC_EXP_LOOP_and_svs_st_6 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_6 <= 1'b0;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3
          <= 71'b00000000000000000000000000000000000000000000000000000000000000000000000;
      CALC_EXP_LOOP_and_svs_st_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_mux_40_itm_4 <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_7 <= 1'b0;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_2_7_2 <= 6'b000000;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_2_1_0 <= 2'b00;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_4
          <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_0 <= 1'b0;
      COMPUTE_LOOP_if_and_71_itm_7 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_8 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_9 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_10 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_11 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_12 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_13 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_14_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_14_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_14 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_15_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_15_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_15 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_16_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_16_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_16 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_17_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_17_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_17 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_18_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_18_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_19 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_19_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_19_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_19 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_20 <= 1'b0;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1
          <= 71'b00000000000000000000000000000000000000000000000000000000000000000000000;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_3
          <= 1'b0;
      COMPUTE_LOOP_if_and_71_itm_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp_17 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_17 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_17 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_17 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_17 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_17 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_17 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_17 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_17 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_17 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_17 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_17 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_17 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_17 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_17 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_18 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_19 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_19 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19 <= 1'b0;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_18_10_itm_1
          <= 9'b000000000;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm_1
          <= 10'b0000000000;
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_18_12_itm_1
          <= 7'b0000000;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_4 <= 1'b0;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_2
          <= 1'b0;
      CALC_SOFTMAX_LOOP_mux_40_itm_2 <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
      COMPUTE_LOOP_if_and_71_itm_5 <= 1'b0;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_sva_1 <= 7'b0000000;
      CALC_SOFTMAX_LOOP_equal_tmp_18 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_17 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_18 <= 1'b0;
      CALC_SOFTMAX_LOOP_mux_40_itm_1 <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
      COMPUTE_LOOP_if_and_71_itm_4 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_1_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_17 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_17 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_16 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_17 <= 1'b0;
      COMPUTE_LOOP_if_and_71_itm_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_itm_2 <= 4'b0000;
      COMPUTE_LOOP_if_and_70_itm_4 <= 1'b0;
      COMPUTE_LOOP_if_and_69_itm_4 <= 1'b0;
      COMPUTE_LOOP_if_and_68_itm_4 <= 1'b0;
      COMPUTE_LOOP_if_and_67_itm_4 <= 1'b0;
      COMPUTE_LOOP_if_and_66_itm_4 <= 1'b0;
      COMPUTE_LOOP_if_and_65_itm_4 <= 1'b0;
      COMPUTE_LOOP_if_and_64_itm_4 <= 1'b0;
      COMPUTE_LOOP_if_and_63_itm_4 <= 1'b0;
      COMPUTE_LOOP_if_and_62_itm_4 <= 1'b0;
      COMPUTE_LOOP_if_and_61_itm_4 <= 1'b0;
      COMPUTE_LOOP_if_and_60_itm_4 <= 1'b0;
      COMPUTE_LOOP_if_and_59_itm_4 <= 1'b0;
      COMPUTE_LOOP_if_and_58_itm_4 <= 1'b0;
      COMPUTE_LOOP_if_and_57_itm_4 <= 1'b0;
      COMPUTE_LOOP_if_and_56_itm_4 <= 1'b0;
      COMPUTE_LOOP_if_and_55_itm_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_16 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_15 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_15 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_14 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_14 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_13 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_13 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_12 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_12 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_11 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_11 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_10 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_10 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_9 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_9 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_8 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_8 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_7 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_7 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_6 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_6 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_5 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_equal_tmp_5 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_4 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_5 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_4 <= 1'b0;
    end
    else if ( CALC_EXP_LOOP_and_3_cse ) begin
      CALC_EXP_LOOP_and_svs_st_4 <= CALC_EXP_LOOP_and_svs_st_3;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_4 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_3;
      CALC_EXP_LOOP_and_svs_st_5 <= CALC_EXP_LOOP_and_svs_st_4;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_5 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_4;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2
          <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1;
      CALC_EXP_LOOP_and_svs_st_6 <= CALC_EXP_LOOP_and_svs_st_5;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_6 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_5;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3
          <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2;
      CALC_EXP_LOOP_and_svs_st_7 <= CALC_EXP_LOOP_and_svs_st_6;
      CALC_SOFTMAX_LOOP_mux_40_itm_4 <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_2_69_0[66:0];
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_7 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_6;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_2_7_2 <= ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_7_2;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_2_1_0 <= ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_1_0;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_4
          <= ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_3;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_0;
      COMPUTE_LOOP_if_and_71_itm_7 <= COMPUTE_LOOP_if_and_71_itm_6;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_8 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_7;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_9 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_8;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_10 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_9;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_11 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_10;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_12 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_11;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_13 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_12;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_14_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_14_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_14 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_13;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_15_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_14_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_15_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_14_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_15 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_14;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_16_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_15_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_16_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_15_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_16 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_15;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_17_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_16_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_17_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_16_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_17 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_16;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_18_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_17_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_18_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_17_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_18 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_17;
      CALC_SOFTMAX_LOOP_and_26_psp_18 <= CALC_SOFTMAX_LOOP_and_26_psp_17;
      CALC_SOFTMAX_LOOP_and_25_psp_18 <= CALC_SOFTMAX_LOOP_and_25_psp_17;
      CALC_SOFTMAX_LOOP_and_24_psp_18 <= CALC_SOFTMAX_LOOP_and_24_psp_17;
      CALC_SOFTMAX_LOOP_and_23_psp_18 <= CALC_SOFTMAX_LOOP_and_23_psp_17;
      CALC_SOFTMAX_LOOP_and_22_psp_18 <= CALC_SOFTMAX_LOOP_and_22_psp_17;
      CALC_SOFTMAX_LOOP_and_21_psp_18 <= CALC_SOFTMAX_LOOP_and_21_psp_17;
      CALC_SOFTMAX_LOOP_and_20_psp_18 <= CALC_SOFTMAX_LOOP_and_20_psp_17;
      CALC_SOFTMAX_LOOP_and_19_psp_18 <= CALC_SOFTMAX_LOOP_and_19_psp_17;
      CALC_SOFTMAX_LOOP_and_18_psp_18 <= CALC_SOFTMAX_LOOP_and_18_psp_17;
      CALC_SOFTMAX_LOOP_and_17_psp_18 <= CALC_SOFTMAX_LOOP_and_17_psp_17;
      CALC_SOFTMAX_LOOP_and_16_psp_18 <= CALC_SOFTMAX_LOOP_and_16_psp_17;
      CALC_SOFTMAX_LOOP_and_15_psp_18 <= CALC_SOFTMAX_LOOP_and_15_psp_17;
      CALC_SOFTMAX_LOOP_and_14_psp_18 <= CALC_SOFTMAX_LOOP_and_14_psp_17;
      CALC_SOFTMAX_LOOP_and_13_psp_18 <= CALC_SOFTMAX_LOOP_and_13_psp_17;
      CALC_SOFTMAX_LOOP_and_12_psp_18 <= CALC_SOFTMAX_LOOP_and_12_psp_17;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_19 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_18;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_19_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_18_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_19_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_18_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_19 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_18;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_20 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_19;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1
          <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_3
          <= ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_2;
      COMPUTE_LOOP_if_and_71_itm_6 <= COMPUTE_LOOP_if_and_71_itm_5;
      CALC_SOFTMAX_LOOP_and_12_psp_17 <= CALC_SOFTMAX_LOOP_and_12_psp_16;
      CALC_SOFTMAX_LOOP_and_13_psp_17 <= CALC_SOFTMAX_LOOP_and_13_psp_16;
      CALC_SOFTMAX_LOOP_and_14_psp_17 <= CALC_SOFTMAX_LOOP_and_14_psp_16;
      CALC_SOFTMAX_LOOP_and_15_psp_17 <= CALC_SOFTMAX_LOOP_and_15_psp_16;
      CALC_SOFTMAX_LOOP_and_16_psp_17 <= CALC_SOFTMAX_LOOP_and_16_psp_16;
      CALC_SOFTMAX_LOOP_and_17_psp_17 <= CALC_SOFTMAX_LOOP_and_17_psp_16;
      CALC_SOFTMAX_LOOP_and_18_psp_17 <= CALC_SOFTMAX_LOOP_and_18_psp_16;
      CALC_SOFTMAX_LOOP_and_19_psp_17 <= CALC_SOFTMAX_LOOP_and_19_psp_16;
      CALC_SOFTMAX_LOOP_and_20_psp_17 <= CALC_SOFTMAX_LOOP_and_20_psp_16;
      CALC_SOFTMAX_LOOP_and_21_psp_17 <= CALC_SOFTMAX_LOOP_and_21_psp_16;
      CALC_SOFTMAX_LOOP_and_22_psp_17 <= CALC_SOFTMAX_LOOP_and_22_psp_16;
      CALC_SOFTMAX_LOOP_and_23_psp_17 <= CALC_SOFTMAX_LOOP_and_23_psp_16;
      CALC_SOFTMAX_LOOP_and_24_psp_17 <= CALC_SOFTMAX_LOOP_and_24_psp_16;
      CALC_SOFTMAX_LOOP_and_25_psp_17 <= CALC_SOFTMAX_LOOP_and_25_psp_16;
      CALC_SOFTMAX_LOOP_and_26_psp_17 <= CALC_SOFTMAX_LOOP_and_26_psp_16;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_18 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_17;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_19 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_18;
      CALC_SOFTMAX_LOOP_equal_tmp_19 <= CALC_SOFTMAX_LOOP_equal_tmp_18;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_18;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_18_10_itm_1
          <= ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[18:10];
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm_1
          <= ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[9:0];
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_18_12_itm_1
          <= ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt[18:12];
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_4 <= lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_2
          <= ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_1;
      CALC_SOFTMAX_LOOP_mux_40_itm_2 <= CALC_SOFTMAX_LOOP_mux_40_itm_1;
      COMPUTE_LOOP_if_and_71_itm_5 <= COMPUTE_LOOP_if_and_71_itm_4;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_sva_1 <= libraries_leading_sign_71_0_1bc993dc735dc189e3e2a7ebf4857c14bb7e_1;
      CALC_SOFTMAX_LOOP_equal_tmp_18 <= CALC_SOFTMAX_LOOP_equal_tmp_17;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_18 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_17;
      CALC_SOFTMAX_LOOP_and_12_psp_16 <= CALC_SOFTMAX_LOOP_and_12_psp_15;
      CALC_SOFTMAX_LOOP_and_13_psp_16 <= CALC_SOFTMAX_LOOP_and_13_psp_15;
      CALC_SOFTMAX_LOOP_and_14_psp_16 <= CALC_SOFTMAX_LOOP_and_14_psp_15;
      CALC_SOFTMAX_LOOP_and_15_psp_16 <= CALC_SOFTMAX_LOOP_and_15_psp_15;
      CALC_SOFTMAX_LOOP_and_16_psp_16 <= CALC_SOFTMAX_LOOP_and_16_psp_15;
      CALC_SOFTMAX_LOOP_and_17_psp_16 <= CALC_SOFTMAX_LOOP_and_17_psp_15;
      CALC_SOFTMAX_LOOP_and_18_psp_16 <= CALC_SOFTMAX_LOOP_and_18_psp_15;
      CALC_SOFTMAX_LOOP_and_19_psp_16 <= CALC_SOFTMAX_LOOP_and_19_psp_15;
      CALC_SOFTMAX_LOOP_and_20_psp_16 <= CALC_SOFTMAX_LOOP_and_20_psp_15;
      CALC_SOFTMAX_LOOP_and_21_psp_16 <= CALC_SOFTMAX_LOOP_and_21_psp_15;
      CALC_SOFTMAX_LOOP_and_22_psp_16 <= CALC_SOFTMAX_LOOP_and_22_psp_15;
      CALC_SOFTMAX_LOOP_and_23_psp_16 <= CALC_SOFTMAX_LOOP_and_23_psp_15;
      CALC_SOFTMAX_LOOP_and_24_psp_16 <= CALC_SOFTMAX_LOOP_and_24_psp_15;
      CALC_SOFTMAX_LOOP_and_25_psp_16 <= CALC_SOFTMAX_LOOP_and_25_psp_15;
      CALC_SOFTMAX_LOOP_and_26_psp_16 <= CALC_SOFTMAX_LOOP_and_26_psp_15;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_17 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_16;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_18 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_17;
      CALC_SOFTMAX_LOOP_mux_40_itm_1 <= MUX_v_67_16_2(COMPUTE_LOOP_if_mux_187_nl,
          COMPUTE_LOOP_if_mux_185_nl, COMPUTE_LOOP_if_mux_183_nl, COMPUTE_LOOP_if_mux_181_nl,
          COMPUTE_LOOP_if_mux_179_nl, COMPUTE_LOOP_if_mux_177_nl, COMPUTE_LOOP_if_mux_175_nl,
          COMPUTE_LOOP_if_mux_173_nl, COMPUTE_LOOP_if_mux_171_nl, COMPUTE_LOOP_if_mux_169_nl,
          COMPUTE_LOOP_if_mux_167_nl, COMPUTE_LOOP_if_mux_165_nl, COMPUTE_LOOP_if_mux_163_nl,
          COMPUTE_LOOP_if_mux_161_nl, COMPUTE_LOOP_if_mux_159_nl, COMPUTE_LOOP_if_mux_157_nl,
          CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_itm_2);
      COMPUTE_LOOP_if_and_71_itm_4 <= COMPUTE_LOOP_if_and_71_itm_3;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_4 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_3;
      CALC_SOFTMAX_LOOP_equal_tmp_4 <= CALC_SOFTMAX_LOOP_equal_tmp_3;
      CALC_SOFTMAX_LOOP_equal_tmp_1_4 <= CALC_SOFTMAX_LOOP_equal_tmp_1_3;
      CALC_SOFTMAX_LOOP_equal_tmp_17 <= CALC_SOFTMAX_LOOP_equal_tmp_16;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_17 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_16;
      CALC_SOFTMAX_LOOP_and_12_psp_15 <= CALC_SOFTMAX_LOOP_and_12_psp_14;
      CALC_SOFTMAX_LOOP_and_13_psp_15 <= CALC_SOFTMAX_LOOP_and_13_psp_14;
      CALC_SOFTMAX_LOOP_and_14_psp_15 <= CALC_SOFTMAX_LOOP_and_14_psp_14;
      CALC_SOFTMAX_LOOP_and_15_psp_15 <= CALC_SOFTMAX_LOOP_and_15_psp_14;
      CALC_SOFTMAX_LOOP_and_16_psp_15 <= CALC_SOFTMAX_LOOP_and_16_psp_14;
      CALC_SOFTMAX_LOOP_and_17_psp_15 <= CALC_SOFTMAX_LOOP_and_17_psp_14;
      CALC_SOFTMAX_LOOP_and_18_psp_15 <= CALC_SOFTMAX_LOOP_and_18_psp_14;
      CALC_SOFTMAX_LOOP_and_19_psp_15 <= CALC_SOFTMAX_LOOP_and_19_psp_14;
      CALC_SOFTMAX_LOOP_and_20_psp_15 <= CALC_SOFTMAX_LOOP_and_20_psp_14;
      CALC_SOFTMAX_LOOP_and_21_psp_15 <= CALC_SOFTMAX_LOOP_and_21_psp_14;
      CALC_SOFTMAX_LOOP_and_22_psp_15 <= CALC_SOFTMAX_LOOP_and_22_psp_14;
      CALC_SOFTMAX_LOOP_and_23_psp_15 <= CALC_SOFTMAX_LOOP_and_23_psp_14;
      CALC_SOFTMAX_LOOP_and_24_psp_15 <= CALC_SOFTMAX_LOOP_and_24_psp_14;
      CALC_SOFTMAX_LOOP_and_25_psp_15 <= CALC_SOFTMAX_LOOP_and_25_psp_14;
      CALC_SOFTMAX_LOOP_and_26_psp_15 <= CALC_SOFTMAX_LOOP_and_26_psp_14;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_16 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_15;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_17 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_16;
      COMPUTE_LOOP_if_and_71_itm_3 <= COMPUTE_LOOP_if_and_71_itm_2;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_itm_2 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_itm_1;
      COMPUTE_LOOP_if_and_70_itm_4 <= COMPUTE_LOOP_if_and_70_itm_3;
      COMPUTE_LOOP_if_and_69_itm_4 <= COMPUTE_LOOP_if_and_69_itm_3;
      COMPUTE_LOOP_if_and_68_itm_4 <= COMPUTE_LOOP_if_and_68_itm_3;
      COMPUTE_LOOP_if_and_67_itm_4 <= COMPUTE_LOOP_if_and_67_itm_3;
      COMPUTE_LOOP_if_and_66_itm_4 <= COMPUTE_LOOP_if_and_66_itm_3;
      COMPUTE_LOOP_if_and_65_itm_4 <= COMPUTE_LOOP_if_and_65_itm_3;
      COMPUTE_LOOP_if_and_64_itm_4 <= COMPUTE_LOOP_if_and_64_itm_3;
      COMPUTE_LOOP_if_and_63_itm_4 <= COMPUTE_LOOP_if_and_63_itm_3;
      COMPUTE_LOOP_if_and_62_itm_4 <= COMPUTE_LOOP_if_and_62_itm_3;
      COMPUTE_LOOP_if_and_61_itm_4 <= COMPUTE_LOOP_if_and_61_itm_3;
      COMPUTE_LOOP_if_and_60_itm_4 <= COMPUTE_LOOP_if_and_60_itm_3;
      COMPUTE_LOOP_if_and_59_itm_4 <= COMPUTE_LOOP_if_and_59_itm_3;
      COMPUTE_LOOP_if_and_58_itm_4 <= COMPUTE_LOOP_if_and_58_itm_3;
      COMPUTE_LOOP_if_and_57_itm_4 <= COMPUTE_LOOP_if_and_57_itm_3;
      COMPUTE_LOOP_if_and_56_itm_4 <= COMPUTE_LOOP_if_and_56_itm_3;
      COMPUTE_LOOP_if_and_55_itm_4 <= COMPUTE_LOOP_if_and_55_itm_3;
      CALC_SOFTMAX_LOOP_equal_tmp_16 <= CALC_SOFTMAX_LOOP_equal_tmp_15;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_16 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_15;
      CALC_SOFTMAX_LOOP_and_12_psp_14 <= CALC_SOFTMAX_LOOP_and_12_psp_13;
      CALC_SOFTMAX_LOOP_and_13_psp_14 <= CALC_SOFTMAX_LOOP_and_13_psp_13;
      CALC_SOFTMAX_LOOP_and_14_psp_14 <= CALC_SOFTMAX_LOOP_and_14_psp_13;
      CALC_SOFTMAX_LOOP_and_15_psp_14 <= CALC_SOFTMAX_LOOP_and_15_psp_13;
      CALC_SOFTMAX_LOOP_and_16_psp_14 <= CALC_SOFTMAX_LOOP_and_16_psp_13;
      CALC_SOFTMAX_LOOP_and_17_psp_14 <= CALC_SOFTMAX_LOOP_and_17_psp_13;
      CALC_SOFTMAX_LOOP_and_18_psp_14 <= CALC_SOFTMAX_LOOP_and_18_psp_13;
      CALC_SOFTMAX_LOOP_and_19_psp_14 <= CALC_SOFTMAX_LOOP_and_19_psp_13;
      CALC_SOFTMAX_LOOP_and_20_psp_14 <= CALC_SOFTMAX_LOOP_and_20_psp_13;
      CALC_SOFTMAX_LOOP_and_21_psp_14 <= CALC_SOFTMAX_LOOP_and_21_psp_13;
      CALC_SOFTMAX_LOOP_and_22_psp_14 <= CALC_SOFTMAX_LOOP_and_22_psp_13;
      CALC_SOFTMAX_LOOP_and_23_psp_14 <= CALC_SOFTMAX_LOOP_and_23_psp_13;
      CALC_SOFTMAX_LOOP_and_24_psp_14 <= CALC_SOFTMAX_LOOP_and_24_psp_13;
      CALC_SOFTMAX_LOOP_and_25_psp_14 <= CALC_SOFTMAX_LOOP_and_25_psp_13;
      CALC_SOFTMAX_LOOP_and_26_psp_14 <= CALC_SOFTMAX_LOOP_and_26_psp_13;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_15 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_14;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_16 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_15;
      CALC_SOFTMAX_LOOP_equal_tmp_15 <= CALC_SOFTMAX_LOOP_equal_tmp_14;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_15 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_14;
      CALC_SOFTMAX_LOOP_and_12_psp_13 <= CALC_SOFTMAX_LOOP_and_12_psp_12;
      CALC_SOFTMAX_LOOP_and_13_psp_13 <= CALC_SOFTMAX_LOOP_and_13_psp_12;
      CALC_SOFTMAX_LOOP_and_14_psp_13 <= CALC_SOFTMAX_LOOP_and_14_psp_12;
      CALC_SOFTMAX_LOOP_and_15_psp_13 <= CALC_SOFTMAX_LOOP_and_15_psp_12;
      CALC_SOFTMAX_LOOP_and_16_psp_13 <= CALC_SOFTMAX_LOOP_and_16_psp_12;
      CALC_SOFTMAX_LOOP_and_17_psp_13 <= CALC_SOFTMAX_LOOP_and_17_psp_12;
      CALC_SOFTMAX_LOOP_and_18_psp_13 <= CALC_SOFTMAX_LOOP_and_18_psp_12;
      CALC_SOFTMAX_LOOP_and_19_psp_13 <= CALC_SOFTMAX_LOOP_and_19_psp_12;
      CALC_SOFTMAX_LOOP_and_20_psp_13 <= CALC_SOFTMAX_LOOP_and_20_psp_12;
      CALC_SOFTMAX_LOOP_and_21_psp_13 <= CALC_SOFTMAX_LOOP_and_21_psp_12;
      CALC_SOFTMAX_LOOP_and_22_psp_13 <= CALC_SOFTMAX_LOOP_and_22_psp_12;
      CALC_SOFTMAX_LOOP_and_23_psp_13 <= CALC_SOFTMAX_LOOP_and_23_psp_12;
      CALC_SOFTMAX_LOOP_and_24_psp_13 <= CALC_SOFTMAX_LOOP_and_24_psp_12;
      CALC_SOFTMAX_LOOP_and_25_psp_13 <= CALC_SOFTMAX_LOOP_and_25_psp_12;
      CALC_SOFTMAX_LOOP_and_26_psp_13 <= CALC_SOFTMAX_LOOP_and_26_psp_12;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_14 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_13;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_15 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_14;
      CALC_SOFTMAX_LOOP_equal_tmp_14 <= CALC_SOFTMAX_LOOP_equal_tmp_13;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_14 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_13;
      CALC_SOFTMAX_LOOP_and_12_psp_12 <= CALC_SOFTMAX_LOOP_and_12_psp_11;
      CALC_SOFTMAX_LOOP_and_13_psp_12 <= CALC_SOFTMAX_LOOP_and_13_psp_11;
      CALC_SOFTMAX_LOOP_and_14_psp_12 <= CALC_SOFTMAX_LOOP_and_14_psp_11;
      CALC_SOFTMAX_LOOP_and_15_psp_12 <= CALC_SOFTMAX_LOOP_and_15_psp_11;
      CALC_SOFTMAX_LOOP_and_16_psp_12 <= CALC_SOFTMAX_LOOP_and_16_psp_11;
      CALC_SOFTMAX_LOOP_and_17_psp_12 <= CALC_SOFTMAX_LOOP_and_17_psp_11;
      CALC_SOFTMAX_LOOP_and_18_psp_12 <= CALC_SOFTMAX_LOOP_and_18_psp_11;
      CALC_SOFTMAX_LOOP_and_19_psp_12 <= CALC_SOFTMAX_LOOP_and_19_psp_11;
      CALC_SOFTMAX_LOOP_and_20_psp_12 <= CALC_SOFTMAX_LOOP_and_20_psp_11;
      CALC_SOFTMAX_LOOP_and_21_psp_12 <= CALC_SOFTMAX_LOOP_and_21_psp_11;
      CALC_SOFTMAX_LOOP_and_22_psp_12 <= CALC_SOFTMAX_LOOP_and_22_psp_11;
      CALC_SOFTMAX_LOOP_and_23_psp_12 <= CALC_SOFTMAX_LOOP_and_23_psp_11;
      CALC_SOFTMAX_LOOP_and_24_psp_12 <= CALC_SOFTMAX_LOOP_and_24_psp_11;
      CALC_SOFTMAX_LOOP_and_25_psp_12 <= CALC_SOFTMAX_LOOP_and_25_psp_11;
      CALC_SOFTMAX_LOOP_and_26_psp_12 <= CALC_SOFTMAX_LOOP_and_26_psp_11;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_13 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_12;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_14 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_13;
      CALC_SOFTMAX_LOOP_equal_tmp_13 <= CALC_SOFTMAX_LOOP_equal_tmp_12;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_13 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_12;
      CALC_SOFTMAX_LOOP_and_12_psp_11 <= CALC_SOFTMAX_LOOP_and_12_psp_10;
      CALC_SOFTMAX_LOOP_and_13_psp_11 <= CALC_SOFTMAX_LOOP_and_13_psp_10;
      CALC_SOFTMAX_LOOP_and_14_psp_11 <= CALC_SOFTMAX_LOOP_and_14_psp_10;
      CALC_SOFTMAX_LOOP_and_15_psp_11 <= CALC_SOFTMAX_LOOP_and_15_psp_10;
      CALC_SOFTMAX_LOOP_and_16_psp_11 <= CALC_SOFTMAX_LOOP_and_16_psp_10;
      CALC_SOFTMAX_LOOP_and_17_psp_11 <= CALC_SOFTMAX_LOOP_and_17_psp_10;
      CALC_SOFTMAX_LOOP_and_18_psp_11 <= CALC_SOFTMAX_LOOP_and_18_psp_10;
      CALC_SOFTMAX_LOOP_and_19_psp_11 <= CALC_SOFTMAX_LOOP_and_19_psp_10;
      CALC_SOFTMAX_LOOP_and_20_psp_11 <= CALC_SOFTMAX_LOOP_and_20_psp_10;
      CALC_SOFTMAX_LOOP_and_21_psp_11 <= CALC_SOFTMAX_LOOP_and_21_psp_10;
      CALC_SOFTMAX_LOOP_and_22_psp_11 <= CALC_SOFTMAX_LOOP_and_22_psp_10;
      CALC_SOFTMAX_LOOP_and_23_psp_11 <= CALC_SOFTMAX_LOOP_and_23_psp_10;
      CALC_SOFTMAX_LOOP_and_24_psp_11 <= CALC_SOFTMAX_LOOP_and_24_psp_10;
      CALC_SOFTMAX_LOOP_and_25_psp_11 <= CALC_SOFTMAX_LOOP_and_25_psp_10;
      CALC_SOFTMAX_LOOP_and_26_psp_11 <= CALC_SOFTMAX_LOOP_and_26_psp_10;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_12 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_11;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_13 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_12;
      CALC_SOFTMAX_LOOP_equal_tmp_12 <= CALC_SOFTMAX_LOOP_equal_tmp_11;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_12 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_11;
      CALC_SOFTMAX_LOOP_and_12_psp_10 <= CALC_SOFTMAX_LOOP_and_12_psp_9;
      CALC_SOFTMAX_LOOP_and_13_psp_10 <= CALC_SOFTMAX_LOOP_and_13_psp_9;
      CALC_SOFTMAX_LOOP_and_14_psp_10 <= CALC_SOFTMAX_LOOP_and_14_psp_9;
      CALC_SOFTMAX_LOOP_and_15_psp_10 <= CALC_SOFTMAX_LOOP_and_15_psp_9;
      CALC_SOFTMAX_LOOP_and_16_psp_10 <= CALC_SOFTMAX_LOOP_and_16_psp_9;
      CALC_SOFTMAX_LOOP_and_17_psp_10 <= CALC_SOFTMAX_LOOP_and_17_psp_9;
      CALC_SOFTMAX_LOOP_and_18_psp_10 <= CALC_SOFTMAX_LOOP_and_18_psp_9;
      CALC_SOFTMAX_LOOP_and_19_psp_10 <= CALC_SOFTMAX_LOOP_and_19_psp_9;
      CALC_SOFTMAX_LOOP_and_20_psp_10 <= CALC_SOFTMAX_LOOP_and_20_psp_9;
      CALC_SOFTMAX_LOOP_and_21_psp_10 <= CALC_SOFTMAX_LOOP_and_21_psp_9;
      CALC_SOFTMAX_LOOP_and_22_psp_10 <= CALC_SOFTMAX_LOOP_and_22_psp_9;
      CALC_SOFTMAX_LOOP_and_23_psp_10 <= CALC_SOFTMAX_LOOP_and_23_psp_9;
      CALC_SOFTMAX_LOOP_and_24_psp_10 <= CALC_SOFTMAX_LOOP_and_24_psp_9;
      CALC_SOFTMAX_LOOP_and_25_psp_10 <= CALC_SOFTMAX_LOOP_and_25_psp_9;
      CALC_SOFTMAX_LOOP_and_26_psp_10 <= CALC_SOFTMAX_LOOP_and_26_psp_9;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_11 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_10;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_12 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_11;
      CALC_SOFTMAX_LOOP_equal_tmp_11 <= CALC_SOFTMAX_LOOP_equal_tmp_10;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_11 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_10;
      CALC_SOFTMAX_LOOP_and_12_psp_9 <= CALC_SOFTMAX_LOOP_and_12_psp_8;
      CALC_SOFTMAX_LOOP_and_13_psp_9 <= CALC_SOFTMAX_LOOP_and_13_psp_8;
      CALC_SOFTMAX_LOOP_and_14_psp_9 <= CALC_SOFTMAX_LOOP_and_14_psp_8;
      CALC_SOFTMAX_LOOP_and_15_psp_9 <= CALC_SOFTMAX_LOOP_and_15_psp_8;
      CALC_SOFTMAX_LOOP_and_16_psp_9 <= CALC_SOFTMAX_LOOP_and_16_psp_8;
      CALC_SOFTMAX_LOOP_and_17_psp_9 <= CALC_SOFTMAX_LOOP_and_17_psp_8;
      CALC_SOFTMAX_LOOP_and_18_psp_9 <= CALC_SOFTMAX_LOOP_and_18_psp_8;
      CALC_SOFTMAX_LOOP_and_19_psp_9 <= CALC_SOFTMAX_LOOP_and_19_psp_8;
      CALC_SOFTMAX_LOOP_and_20_psp_9 <= CALC_SOFTMAX_LOOP_and_20_psp_8;
      CALC_SOFTMAX_LOOP_and_21_psp_9 <= CALC_SOFTMAX_LOOP_and_21_psp_8;
      CALC_SOFTMAX_LOOP_and_22_psp_9 <= CALC_SOFTMAX_LOOP_and_22_psp_8;
      CALC_SOFTMAX_LOOP_and_23_psp_9 <= CALC_SOFTMAX_LOOP_and_23_psp_8;
      CALC_SOFTMAX_LOOP_and_24_psp_9 <= CALC_SOFTMAX_LOOP_and_24_psp_8;
      CALC_SOFTMAX_LOOP_and_25_psp_9 <= CALC_SOFTMAX_LOOP_and_25_psp_8;
      CALC_SOFTMAX_LOOP_and_26_psp_9 <= CALC_SOFTMAX_LOOP_and_26_psp_8;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_10 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_9;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_11 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_10;
      CALC_SOFTMAX_LOOP_equal_tmp_10 <= CALC_SOFTMAX_LOOP_equal_tmp_9;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_10 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_9;
      CALC_SOFTMAX_LOOP_and_12_psp_8 <= CALC_SOFTMAX_LOOP_and_12_psp_7;
      CALC_SOFTMAX_LOOP_and_13_psp_8 <= CALC_SOFTMAX_LOOP_and_13_psp_7;
      CALC_SOFTMAX_LOOP_and_14_psp_8 <= CALC_SOFTMAX_LOOP_and_14_psp_7;
      CALC_SOFTMAX_LOOP_and_15_psp_8 <= CALC_SOFTMAX_LOOP_and_15_psp_7;
      CALC_SOFTMAX_LOOP_and_16_psp_8 <= CALC_SOFTMAX_LOOP_and_16_psp_7;
      CALC_SOFTMAX_LOOP_and_17_psp_8 <= CALC_SOFTMAX_LOOP_and_17_psp_7;
      CALC_SOFTMAX_LOOP_and_18_psp_8 <= CALC_SOFTMAX_LOOP_and_18_psp_7;
      CALC_SOFTMAX_LOOP_and_19_psp_8 <= CALC_SOFTMAX_LOOP_and_19_psp_7;
      CALC_SOFTMAX_LOOP_and_20_psp_8 <= CALC_SOFTMAX_LOOP_and_20_psp_7;
      CALC_SOFTMAX_LOOP_and_21_psp_8 <= CALC_SOFTMAX_LOOP_and_21_psp_7;
      CALC_SOFTMAX_LOOP_and_22_psp_8 <= CALC_SOFTMAX_LOOP_and_22_psp_7;
      CALC_SOFTMAX_LOOP_and_23_psp_8 <= CALC_SOFTMAX_LOOP_and_23_psp_7;
      CALC_SOFTMAX_LOOP_and_24_psp_8 <= CALC_SOFTMAX_LOOP_and_24_psp_7;
      CALC_SOFTMAX_LOOP_and_25_psp_8 <= CALC_SOFTMAX_LOOP_and_25_psp_7;
      CALC_SOFTMAX_LOOP_and_26_psp_8 <= CALC_SOFTMAX_LOOP_and_26_psp_7;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_9 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_8;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_10 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_9;
      CALC_SOFTMAX_LOOP_equal_tmp_9 <= CALC_SOFTMAX_LOOP_equal_tmp_8;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_9 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_8;
      CALC_SOFTMAX_LOOP_and_12_psp_7 <= CALC_SOFTMAX_LOOP_and_12_psp_6;
      CALC_SOFTMAX_LOOP_and_13_psp_7 <= CALC_SOFTMAX_LOOP_and_13_psp_6;
      CALC_SOFTMAX_LOOP_and_14_psp_7 <= CALC_SOFTMAX_LOOP_and_14_psp_6;
      CALC_SOFTMAX_LOOP_and_15_psp_7 <= CALC_SOFTMAX_LOOP_and_15_psp_6;
      CALC_SOFTMAX_LOOP_and_16_psp_7 <= CALC_SOFTMAX_LOOP_and_16_psp_6;
      CALC_SOFTMAX_LOOP_and_17_psp_7 <= CALC_SOFTMAX_LOOP_and_17_psp_6;
      CALC_SOFTMAX_LOOP_and_18_psp_7 <= CALC_SOFTMAX_LOOP_and_18_psp_6;
      CALC_SOFTMAX_LOOP_and_19_psp_7 <= CALC_SOFTMAX_LOOP_and_19_psp_6;
      CALC_SOFTMAX_LOOP_and_20_psp_7 <= CALC_SOFTMAX_LOOP_and_20_psp_6;
      CALC_SOFTMAX_LOOP_and_21_psp_7 <= CALC_SOFTMAX_LOOP_and_21_psp_6;
      CALC_SOFTMAX_LOOP_and_22_psp_7 <= CALC_SOFTMAX_LOOP_and_22_psp_6;
      CALC_SOFTMAX_LOOP_and_23_psp_7 <= CALC_SOFTMAX_LOOP_and_23_psp_6;
      CALC_SOFTMAX_LOOP_and_24_psp_7 <= CALC_SOFTMAX_LOOP_and_24_psp_6;
      CALC_SOFTMAX_LOOP_and_25_psp_7 <= CALC_SOFTMAX_LOOP_and_25_psp_6;
      CALC_SOFTMAX_LOOP_and_26_psp_7 <= CALC_SOFTMAX_LOOP_and_26_psp_6;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_8 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_7;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_9 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_8;
      CALC_SOFTMAX_LOOP_equal_tmp_8 <= CALC_SOFTMAX_LOOP_equal_tmp_7;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_8 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_7;
      CALC_SOFTMAX_LOOP_and_12_psp_6 <= CALC_SOFTMAX_LOOP_and_12_psp_5;
      CALC_SOFTMAX_LOOP_and_13_psp_6 <= CALC_SOFTMAX_LOOP_and_13_psp_5;
      CALC_SOFTMAX_LOOP_and_14_psp_6 <= CALC_SOFTMAX_LOOP_and_14_psp_5;
      CALC_SOFTMAX_LOOP_and_15_psp_6 <= CALC_SOFTMAX_LOOP_and_15_psp_5;
      CALC_SOFTMAX_LOOP_and_16_psp_6 <= CALC_SOFTMAX_LOOP_and_16_psp_5;
      CALC_SOFTMAX_LOOP_and_17_psp_6 <= CALC_SOFTMAX_LOOP_and_17_psp_5;
      CALC_SOFTMAX_LOOP_and_18_psp_6 <= CALC_SOFTMAX_LOOP_and_18_psp_5;
      CALC_SOFTMAX_LOOP_and_19_psp_6 <= CALC_SOFTMAX_LOOP_and_19_psp_5;
      CALC_SOFTMAX_LOOP_and_20_psp_6 <= CALC_SOFTMAX_LOOP_and_20_psp_5;
      CALC_SOFTMAX_LOOP_and_21_psp_6 <= CALC_SOFTMAX_LOOP_and_21_psp_5;
      CALC_SOFTMAX_LOOP_and_22_psp_6 <= CALC_SOFTMAX_LOOP_and_22_psp_5;
      CALC_SOFTMAX_LOOP_and_23_psp_6 <= CALC_SOFTMAX_LOOP_and_23_psp_5;
      CALC_SOFTMAX_LOOP_and_24_psp_6 <= CALC_SOFTMAX_LOOP_and_24_psp_5;
      CALC_SOFTMAX_LOOP_and_25_psp_6 <= CALC_SOFTMAX_LOOP_and_25_psp_5;
      CALC_SOFTMAX_LOOP_and_26_psp_6 <= CALC_SOFTMAX_LOOP_and_26_psp_5;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_7 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_6;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_8 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_7;
      CALC_SOFTMAX_LOOP_equal_tmp_7 <= CALC_SOFTMAX_LOOP_equal_tmp_6;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_7 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_6;
      CALC_SOFTMAX_LOOP_and_12_psp_5 <= CALC_SOFTMAX_LOOP_and_12_psp_4;
      CALC_SOFTMAX_LOOP_and_13_psp_5 <= CALC_SOFTMAX_LOOP_and_13_psp_4;
      CALC_SOFTMAX_LOOP_and_14_psp_5 <= CALC_SOFTMAX_LOOP_and_14_psp_4;
      CALC_SOFTMAX_LOOP_and_15_psp_5 <= CALC_SOFTMAX_LOOP_and_15_psp_4;
      CALC_SOFTMAX_LOOP_and_16_psp_5 <= CALC_SOFTMAX_LOOP_and_16_psp_4;
      CALC_SOFTMAX_LOOP_and_17_psp_5 <= CALC_SOFTMAX_LOOP_and_17_psp_4;
      CALC_SOFTMAX_LOOP_and_18_psp_5 <= CALC_SOFTMAX_LOOP_and_18_psp_4;
      CALC_SOFTMAX_LOOP_and_19_psp_5 <= CALC_SOFTMAX_LOOP_and_19_psp_4;
      CALC_SOFTMAX_LOOP_and_20_psp_5 <= CALC_SOFTMAX_LOOP_and_20_psp_4;
      CALC_SOFTMAX_LOOP_and_21_psp_5 <= CALC_SOFTMAX_LOOP_and_21_psp_4;
      CALC_SOFTMAX_LOOP_and_22_psp_5 <= CALC_SOFTMAX_LOOP_and_22_psp_4;
      CALC_SOFTMAX_LOOP_and_23_psp_5 <= CALC_SOFTMAX_LOOP_and_23_psp_4;
      CALC_SOFTMAX_LOOP_and_24_psp_5 <= CALC_SOFTMAX_LOOP_and_24_psp_4;
      CALC_SOFTMAX_LOOP_and_25_psp_5 <= CALC_SOFTMAX_LOOP_and_25_psp_4;
      CALC_SOFTMAX_LOOP_and_26_psp_5 <= CALC_SOFTMAX_LOOP_and_26_psp_4;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_6 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_5;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_7 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_6;
      CALC_SOFTMAX_LOOP_equal_tmp_6 <= CALC_SOFTMAX_LOOP_equal_tmp_5;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_6 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_5;
      CALC_SOFTMAX_LOOP_and_12_psp_4 <= CALC_SOFTMAX_LOOP_and_12_psp_3;
      CALC_SOFTMAX_LOOP_and_13_psp_4 <= CALC_SOFTMAX_LOOP_and_13_psp_3;
      CALC_SOFTMAX_LOOP_and_14_psp_4 <= CALC_SOFTMAX_LOOP_and_14_psp_3;
      CALC_SOFTMAX_LOOP_and_15_psp_4 <= CALC_SOFTMAX_LOOP_and_15_psp_3;
      CALC_SOFTMAX_LOOP_and_16_psp_4 <= CALC_SOFTMAX_LOOP_and_16_psp_3;
      CALC_SOFTMAX_LOOP_and_17_psp_4 <= CALC_SOFTMAX_LOOP_and_17_psp_3;
      CALC_SOFTMAX_LOOP_and_18_psp_4 <= CALC_SOFTMAX_LOOP_and_18_psp_3;
      CALC_SOFTMAX_LOOP_and_19_psp_4 <= CALC_SOFTMAX_LOOP_and_19_psp_3;
      CALC_SOFTMAX_LOOP_and_20_psp_4 <= CALC_SOFTMAX_LOOP_and_20_psp_3;
      CALC_SOFTMAX_LOOP_and_21_psp_4 <= CALC_SOFTMAX_LOOP_and_21_psp_3;
      CALC_SOFTMAX_LOOP_and_22_psp_4 <= CALC_SOFTMAX_LOOP_and_22_psp_3;
      CALC_SOFTMAX_LOOP_and_23_psp_4 <= CALC_SOFTMAX_LOOP_and_23_psp_3;
      CALC_SOFTMAX_LOOP_and_24_psp_4 <= CALC_SOFTMAX_LOOP_and_24_psp_3;
      CALC_SOFTMAX_LOOP_and_25_psp_4 <= CALC_SOFTMAX_LOOP_and_25_psp_3;
      CALC_SOFTMAX_LOOP_and_26_psp_4 <= CALC_SOFTMAX_LOOP_and_26_psp_3;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_5 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_4;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_6 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_5;
      CALC_SOFTMAX_LOOP_equal_tmp_5 <= CALC_SOFTMAX_LOOP_equal_tmp_4;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_5 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_4;
      CALC_SOFTMAX_LOOP_and_12_psp_3 <= CALC_SOFTMAX_LOOP_and_12_psp_2;
      CALC_SOFTMAX_LOOP_and_13_psp_3 <= CALC_SOFTMAX_LOOP_and_13_psp_2;
      CALC_SOFTMAX_LOOP_and_14_psp_3 <= CALC_SOFTMAX_LOOP_and_14_psp_2;
      CALC_SOFTMAX_LOOP_and_15_psp_3 <= CALC_SOFTMAX_LOOP_and_15_psp_2;
      CALC_SOFTMAX_LOOP_and_16_psp_3 <= CALC_SOFTMAX_LOOP_and_16_psp_2;
      CALC_SOFTMAX_LOOP_and_17_psp_3 <= CALC_SOFTMAX_LOOP_and_17_psp_2;
      CALC_SOFTMAX_LOOP_and_18_psp_3 <= CALC_SOFTMAX_LOOP_and_18_psp_2;
      CALC_SOFTMAX_LOOP_and_19_psp_3 <= CALC_SOFTMAX_LOOP_and_19_psp_2;
      CALC_SOFTMAX_LOOP_and_20_psp_3 <= CALC_SOFTMAX_LOOP_and_20_psp_2;
      CALC_SOFTMAX_LOOP_and_21_psp_3 <= CALC_SOFTMAX_LOOP_and_21_psp_2;
      CALC_SOFTMAX_LOOP_and_22_psp_3 <= CALC_SOFTMAX_LOOP_and_22_psp_2;
      CALC_SOFTMAX_LOOP_and_23_psp_3 <= CALC_SOFTMAX_LOOP_and_23_psp_2;
      CALC_SOFTMAX_LOOP_and_24_psp_3 <= CALC_SOFTMAX_LOOP_and_24_psp_2;
      CALC_SOFTMAX_LOOP_and_25_psp_3 <= CALC_SOFTMAX_LOOP_and_25_psp_2;
      CALC_SOFTMAX_LOOP_and_26_psp_3 <= CALC_SOFTMAX_LOOP_and_26_psp_2;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_4 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_3;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_5 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_4;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_4 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_3;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_5 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & main_stage_v_4) | main_stage_v_5_mx0c1)
        ) begin
      main_stage_v_5 <= ~ main_stage_v_5_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_6 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & main_stage_v_5) | main_stage_v_6_mx0c1)
        ) begin
      main_stage_v_6 <= ~ main_stage_v_6_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_7 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & main_stage_v_6) | main_stage_v_7_mx0c1)
        ) begin
      main_stage_v_7 <= ~ main_stage_v_7_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_8 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & main_stage_v_7) | main_stage_v_8_mx0c1)
        ) begin
      main_stage_v_8 <= ~ main_stage_v_8_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_1
          <= 11'b00000000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm_1
          <= 10'b0000000000;
    end
    else if ( ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse
        ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_1
          <= MUX_v_11_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_mx0w0,
          ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm,
          and_dcpl_301);
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm_1
          <= MUX_v_10_2_2((ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[9:0]),
          ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm,
          and_dcpl_301);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_9 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & main_stage_v_8) | main_stage_v_9_mx0c1)
        ) begin
      main_stage_v_9 <= ~ main_stage_v_9_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_10 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & main_stage_v_9) | main_stage_v_10_mx0c1)
        ) begin
      main_stage_v_10 <= ~ main_stage_v_10_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_11 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & main_stage_v_10) | main_stage_v_11_mx0c1)
        ) begin
      main_stage_v_11 <= ~ main_stage_v_11_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_12 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & main_stage_v_11) | main_stage_v_12_mx0c1)
        ) begin
      main_stage_v_12 <= ~ main_stage_v_12_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_13 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & main_stage_v_12) | main_stage_v_13_mx0c1)
        ) begin
      main_stage_v_13 <= ~ main_stage_v_13_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_14 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & main_stage_v_13) | main_stage_v_14_mx0c1)
        ) begin
      main_stage_v_14 <= ~ main_stage_v_14_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_15 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & main_stage_v_14) | main_stage_v_15_mx0c1)
        ) begin
      main_stage_v_15 <= ~ main_stage_v_15_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_16 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & main_stage_v_15) | main_stage_v_16_mx0c1)
        ) begin
      main_stage_v_16 <= ~ main_stage_v_16_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_17 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & main_stage_v_16) | main_stage_v_17_mx0c1)
        ) begin
      main_stage_v_17 <= ~ main_stage_v_17_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_18 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & main_stage_v_17) | main_stage_v_18_mx0c1)
        ) begin
      main_stage_v_18 <= ~ main_stage_v_18_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_19 <= 1'b0;
    end
    else if ( core_wen & (and_tmp_67 | main_stage_v_19_mx0c1) ) begin
      main_stage_v_19 <= ~ main_stage_v_19_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_plm_out_tmp_data_0_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_21 | or_dcpl_89 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19
        | (~ CALC_SOFTMAX_LOOP_and_26_psp_18))) ) begin
      COMPUTE_LOOP_plm_out_tmp_data_0_lpi_1 <= CALC_SOFTMAX_LOOP_mul_cmp_z[91:60];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_plm_out_tmp_data_14_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_21 | or_dcpl_89 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19
        | (~ CALC_SOFTMAX_LOOP_and_25_psp_18))) ) begin
      COMPUTE_LOOP_plm_out_tmp_data_14_lpi_1 <= CALC_SOFTMAX_LOOP_mul_cmp_z[91:60];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_plm_out_tmp_data_1_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_21 | or_dcpl_89 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19
        | (~ CALC_SOFTMAX_LOOP_and_24_psp_18))) ) begin
      COMPUTE_LOOP_plm_out_tmp_data_1_lpi_1 <= CALC_SOFTMAX_LOOP_mul_cmp_z[91:60];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_plm_out_tmp_data_13_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_21 | or_dcpl_89 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19
        | (~ CALC_SOFTMAX_LOOP_and_23_psp_18))) ) begin
      COMPUTE_LOOP_plm_out_tmp_data_13_lpi_1 <= CALC_SOFTMAX_LOOP_mul_cmp_z[91:60];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_plm_out_tmp_data_2_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_21 | or_dcpl_89 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19
        | (~ CALC_SOFTMAX_LOOP_and_22_psp_18))) ) begin
      COMPUTE_LOOP_plm_out_tmp_data_2_lpi_1 <= CALC_SOFTMAX_LOOP_mul_cmp_z[91:60];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_plm_out_tmp_data_12_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_21 | or_dcpl_89 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19
        | (~ CALC_SOFTMAX_LOOP_and_21_psp_18))) ) begin
      COMPUTE_LOOP_plm_out_tmp_data_12_lpi_1 <= CALC_SOFTMAX_LOOP_mul_cmp_z[91:60];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_plm_out_tmp_data_3_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_21 | or_dcpl_89 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19
        | (~ CALC_SOFTMAX_LOOP_and_20_psp_18))) ) begin
      COMPUTE_LOOP_plm_out_tmp_data_3_lpi_1 <= CALC_SOFTMAX_LOOP_mul_cmp_z[91:60];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_plm_out_tmp_data_11_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_21 | or_dcpl_89 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19
        | (~ CALC_SOFTMAX_LOOP_and_19_psp_18))) ) begin
      COMPUTE_LOOP_plm_out_tmp_data_11_lpi_1 <= CALC_SOFTMAX_LOOP_mul_cmp_z[91:60];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_plm_out_tmp_data_4_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_21 | or_dcpl_89 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19
        | (~ CALC_SOFTMAX_LOOP_and_18_psp_18))) ) begin
      COMPUTE_LOOP_plm_out_tmp_data_4_lpi_1 <= CALC_SOFTMAX_LOOP_mul_cmp_z[91:60];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_plm_out_tmp_data_10_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_21 | or_dcpl_89 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19
        | (~ CALC_SOFTMAX_LOOP_and_17_psp_18))) ) begin
      COMPUTE_LOOP_plm_out_tmp_data_10_lpi_1 <= CALC_SOFTMAX_LOOP_mul_cmp_z[91:60];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_plm_out_tmp_data_5_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_21 | or_dcpl_89 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19
        | (~ CALC_SOFTMAX_LOOP_and_16_psp_18))) ) begin
      COMPUTE_LOOP_plm_out_tmp_data_5_lpi_1 <= CALC_SOFTMAX_LOOP_mul_cmp_z[91:60];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_plm_out_tmp_data_9_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_21 | or_dcpl_89 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19
        | (~ CALC_SOFTMAX_LOOP_and_15_psp_18))) ) begin
      COMPUTE_LOOP_plm_out_tmp_data_9_lpi_1 <= CALC_SOFTMAX_LOOP_mul_cmp_z[91:60];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_plm_out_tmp_data_6_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_21 | or_dcpl_89 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19
        | (~ CALC_SOFTMAX_LOOP_and_14_psp_18))) ) begin
      COMPUTE_LOOP_plm_out_tmp_data_6_lpi_1 <= CALC_SOFTMAX_LOOP_mul_cmp_z[91:60];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_plm_out_tmp_data_8_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_21 | or_dcpl_89 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19
        | (~ CALC_SOFTMAX_LOOP_and_13_psp_18))) ) begin
      COMPUTE_LOOP_plm_out_tmp_data_8_lpi_1 <= CALC_SOFTMAX_LOOP_mul_cmp_z[91:60];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_plm_out_tmp_data_7_lpi_1 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_21 | or_dcpl_89 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_19
        | (~ CALC_SOFTMAX_LOOP_and_12_psp_18))) ) begin
      COMPUTE_LOOP_plm_out_tmp_data_7_lpi_1 <= CALC_SOFTMAX_LOOP_mul_cmp_z[91:60];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_20 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & main_stage_v_19) | main_stage_v_20_mx0c1)
        ) begin
      main_stage_v_20 <= ~ main_stage_v_20_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_20 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_20_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_20_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_20 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_i_and_3_cse ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_20 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_19;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_20_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_19_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_20_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_19_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_20 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_19;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_21 <= 1'b0;
    end
    else if ( core_wen & ((or_dcpl_27 & or_dcpl_16 & main_stage_v_20) | main_stage_v_21_mx0c1)
        ) begin
      main_stage_v_21 <= ~ main_stage_v_21_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_21 <= 1'b0;
    end
    else if ( core_wen & (~(and_dcpl_131 | and_44_cse | (~ main_stage_v_20))) ) begin
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_21 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_20;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm
          <= 10'b0000000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm
          <= 11'b00000000000;
    end
    else if ( ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse
        ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm
          <= ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[9:0];
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm
          <= ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1 <= 1'b0;
      reg_lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_cse <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_62_cse ) begin
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st <= ~ exitL_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_mx0w0;
      reg_lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_cse <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      SUM_EXP_LOOP_i_4_0_lpi_1_3_0 <= 4'b0000;
    end
    else if ( core_wen & (~ or_dcpl_14) ) begin
      SUM_EXP_LOOP_i_4_0_lpi_1_3_0 <= SUM_EXP_LOOP_i_4_0_sva_2[3:0];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_EXP_LOOP_i_4_0_lpi_1_3_0 <= 4'b0000;
    end
    else if ( core_wen & (~(COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1 | or_dcpl_14))
        ) begin
      CALC_EXP_LOOP_i_4_0_lpi_1_3_0 <= MUX_v_4_2_2((CALC_EXP_LOOP_i_4_0_sva_2[3:0]),
          CALC_EXP_LOOP_i_4_0_lpi_1_dfm_3_0_mx0w0, COMPUTE_LOOP_if_COMPUTE_LOOP_if_nor_nl);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_7_2 <= 6'b000000;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_1_0 <= 2'b00;
    end
    else if ( ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_and_cse ) begin
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_7_2 <= MUX_v_6_2_2(ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_7_2_mx0w0,
          ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_7_2, and_tmp_129);
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_1_0 <= MUX_v_2_2_2((~
          (ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_sva_1[1:0])),
          ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_0, and_tmp_129);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1
          <= 10'b0000000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1
          <= 8'b00000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_69_57_9_0_itm_1
          <= 10'b0000000000;
    end
    else if ( ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse
        ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1
          <= MUX_v_10_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_mx0w0,
          ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm,
          and_dcpl_426);
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1
          <= MUX_v_8_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_mx0w0,
          ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm,
          and_dcpl_426);
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_69_57_9_0_itm_1
          <= MUX_v_10_2_2((operator_71_0_false_AC_TRN_AC_WRAP_lshift_itm[66:57]),
          ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_69_57_9_0_itm,
          and_dcpl_426);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_7_2 <= 6'b000000;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_0 <= 2'b00;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm
          <= 10'b0000000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_69_57_9_0_itm
          <= 10'b0000000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm
          <= 8'b00000000;
    end
    else if ( ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_and_2_cse )
        begin
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_7_2 <= ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_7_2_mx0w0;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_0 <= ~ (ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_sva_1[1:0]);
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm
          <= ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_mx0w0;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_69_57_9_0_itm
          <= operator_71_0_false_AC_TRN_AC_WRAP_lshift_itm[66:57];
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm
          <= ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_2_itm_1
          <= 3'b000;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_3_itm_1
          <= 7'b0000000;
    end
    else if ( ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_8_cse
        ) begin
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_2_itm_1
          <= MUX1HOT_v_3_4_2(3'b011, 3'b100, 3'b101, 3'b110, {ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_4_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_5_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_6_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_7_cse});
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_3_itm_1
          <= MUX1HOT_v_7_4_2(7'b1111110, 7'b1000000, 7'b0100110, 7'b0110111, {ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_4_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_5_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_6_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_7_cse});
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1
          <= 71'b00000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~(COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_4 | (~ or_143_cse)
        | and_44_cse | (~ main_stage_v_4))) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1
          <= MUX_v_71_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1_dfm_1,
          COMPUTE_LOOP_if_COMPUTE_LOOP_if_nor_2_nl);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_2_69_0
          <= 70'b0000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((and_dcpl_25 & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1))
        | mux_271_rgt) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_2_69_0
          <= MUX_v_70_2_2((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1[69:0]),
          ({3'b000 , CALC_SOFTMAX_LOOP_mux_101_nl}), mux_271_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_1
          <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_25 & (~(COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_4
        | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_1)) & CALC_EXP_LOOP_and_svs_st_4)
        | and_606_rgt) ) begin
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_1
          <= MUX_s_1_2_2(ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0,
          ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm,
          and_606_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_15_lpi_1
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ or_143_cse) | and_44_cse | or_dcpl_158)) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_15_lpi_1
          <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_14_lpi_1
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ or_143_cse) | and_44_cse | or_dcpl_161)) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_14_lpi_1
          <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_13_lpi_1
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ or_143_cse) | and_44_cse | or_dcpl_164)) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_13_lpi_1
          <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_12_lpi_1
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ or_143_cse) | and_44_cse | or_dcpl_167)) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_12_lpi_1
          <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_11_lpi_1
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ or_143_cse) | and_44_cse | or_dcpl_170)) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_11_lpi_1
          <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_10_lpi_1
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ or_143_cse) | and_44_cse | or_dcpl_173)) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_10_lpi_1
          <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_9_lpi_1
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ or_143_cse) | and_44_cse | or_dcpl_176)) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_9_lpi_1
          <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_8_lpi_1
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ or_143_cse) | and_44_cse | or_dcpl_179)) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_8_lpi_1
          <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_7_lpi_1
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ or_143_cse) | and_44_cse | or_dcpl_182)) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_7_lpi_1
          <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_6_lpi_1
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ or_143_cse) | and_44_cse | or_dcpl_185)) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_6_lpi_1
          <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_5_lpi_1
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ or_143_cse) | and_44_cse | or_dcpl_188)) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_5_lpi_1
          <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_4_lpi_1
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ or_143_cse) | and_44_cse | or_dcpl_191)) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_4_lpi_1
          <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_3_lpi_1
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ or_143_cse) | and_44_cse | or_dcpl_194)) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_3_lpi_1
          <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_2_lpi_1
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ or_143_cse) | and_44_cse | or_dcpl_197)) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_2_lpi_1
          <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_1_lpi_1
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ or_143_cse) | and_44_cse | or_dcpl_200)) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_1_lpi_1
          <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_0_lpi_1
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ or_143_cse) | and_44_cse | or_dcpl_203)) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_0_lpi_1
          <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm
          <= 1'b0;
    end
    else if ( core_wen & (~(or_dcpl_156 | (~(main_stage_v_4 & CALC_EXP_LOOP_and_svs_st_4))))
        ) begin
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm
          <= ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_and_12_psp_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_26_psp_1 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_401_cse ) begin
      CALC_SOFTMAX_LOOP_and_12_psp_1 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_and_12_psp_mx0w0,
          CALC_SOFTMAX_LOOP_and_12_psp, and_dcpl_436);
      CALC_SOFTMAX_LOOP_and_13_psp_1 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_and_13_psp_mx0w0,
          CALC_SOFTMAX_LOOP_and_13_psp, and_dcpl_436);
      CALC_SOFTMAX_LOOP_and_14_psp_1 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_and_14_psp_mx0w0,
          CALC_SOFTMAX_LOOP_and_14_psp, and_dcpl_436);
      CALC_SOFTMAX_LOOP_and_15_psp_1 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_and_15_psp_mx0w0,
          CALC_SOFTMAX_LOOP_and_15_psp, and_dcpl_436);
      CALC_SOFTMAX_LOOP_and_16_psp_1 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_and_16_psp_mx0w0,
          CALC_SOFTMAX_LOOP_and_16_psp, and_dcpl_436);
      CALC_SOFTMAX_LOOP_and_17_psp_1 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_and_17_psp_mx0w0,
          CALC_SOFTMAX_LOOP_and_17_psp, and_dcpl_436);
      CALC_SOFTMAX_LOOP_and_18_psp_1 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_and_18_psp_mx0w0,
          CALC_SOFTMAX_LOOP_and_18_psp, and_dcpl_436);
      CALC_SOFTMAX_LOOP_and_19_psp_1 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_and_19_psp_mx0w0,
          CALC_SOFTMAX_LOOP_and_19_psp, and_dcpl_436);
      CALC_SOFTMAX_LOOP_and_20_psp_1 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_and_20_psp_mx0w0,
          CALC_SOFTMAX_LOOP_and_20_psp, and_dcpl_436);
      CALC_SOFTMAX_LOOP_and_21_psp_1 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_and_21_psp_mx0w0,
          CALC_SOFTMAX_LOOP_and_21_psp, and_dcpl_436);
      CALC_SOFTMAX_LOOP_and_22_psp_1 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_and_22_psp_mx0w0,
          CALC_SOFTMAX_LOOP_and_22_psp, and_dcpl_436);
      CALC_SOFTMAX_LOOP_and_23_psp_1 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_and_23_psp_mx0w0,
          CALC_SOFTMAX_LOOP_and_23_psp, and_dcpl_436);
      CALC_SOFTMAX_LOOP_and_24_psp_1 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_and_24_psp_mx0w0,
          CALC_SOFTMAX_LOOP_and_24_psp, and_dcpl_436);
      CALC_SOFTMAX_LOOP_and_25_psp_1 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_and_25_psp_mx0w0,
          CALC_SOFTMAX_LOOP_and_25_psp, and_dcpl_436);
      CALC_SOFTMAX_LOOP_and_26_psp_1 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_and_26_psp_mx0w0,
          CALC_SOFTMAX_LOOP_and_26_psp, and_dcpl_436);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_1 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_187 & and_dcpl_195) | CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_1_mx0c1)
        ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_1 <= MUX_s_1_2_2((CALC_SOFTMAX_LOOP_acc_1_tmp[4]),
          CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm, CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_and_26_psp <= 1'b0;
      CALC_SOFTMAX_LOOP_and_25_psp <= 1'b0;
      CALC_SOFTMAX_LOOP_and_24_psp <= 1'b0;
      CALC_SOFTMAX_LOOP_and_23_psp <= 1'b0;
      CALC_SOFTMAX_LOOP_and_22_psp <= 1'b0;
      CALC_SOFTMAX_LOOP_and_21_psp <= 1'b0;
      CALC_SOFTMAX_LOOP_and_20_psp <= 1'b0;
      CALC_SOFTMAX_LOOP_and_19_psp <= 1'b0;
      CALC_SOFTMAX_LOOP_and_18_psp <= 1'b0;
      CALC_SOFTMAX_LOOP_and_17_psp <= 1'b0;
      CALC_SOFTMAX_LOOP_and_16_psp <= 1'b0;
      CALC_SOFTMAX_LOOP_and_15_psp <= 1'b0;
      CALC_SOFTMAX_LOOP_and_14_psp <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_psp <= 1'b0;
      CALC_SOFTMAX_LOOP_and_12_psp <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_416_cse ) begin
      CALC_SOFTMAX_LOOP_and_26_psp <= CALC_SOFTMAX_LOOP_and_26_psp_mx0w0;
      CALC_SOFTMAX_LOOP_and_25_psp <= CALC_SOFTMAX_LOOP_and_25_psp_mx0w0;
      CALC_SOFTMAX_LOOP_and_24_psp <= CALC_SOFTMAX_LOOP_and_24_psp_mx0w0;
      CALC_SOFTMAX_LOOP_and_23_psp <= CALC_SOFTMAX_LOOP_and_23_psp_mx0w0;
      CALC_SOFTMAX_LOOP_and_22_psp <= CALC_SOFTMAX_LOOP_and_22_psp_mx0w0;
      CALC_SOFTMAX_LOOP_and_21_psp <= CALC_SOFTMAX_LOOP_and_21_psp_mx0w0;
      CALC_SOFTMAX_LOOP_and_20_psp <= CALC_SOFTMAX_LOOP_and_20_psp_mx0w0;
      CALC_SOFTMAX_LOOP_and_19_psp <= CALC_SOFTMAX_LOOP_and_19_psp_mx0w0;
      CALC_SOFTMAX_LOOP_and_18_psp <= CALC_SOFTMAX_LOOP_and_18_psp_mx0w0;
      CALC_SOFTMAX_LOOP_and_17_psp <= CALC_SOFTMAX_LOOP_and_17_psp_mx0w0;
      CALC_SOFTMAX_LOOP_and_16_psp <= CALC_SOFTMAX_LOOP_and_16_psp_mx0w0;
      CALC_SOFTMAX_LOOP_and_15_psp <= CALC_SOFTMAX_LOOP_and_15_psp_mx0w0;
      CALC_SOFTMAX_LOOP_and_14_psp <= CALC_SOFTMAX_LOOP_and_14_psp_mx0w0;
      CALC_SOFTMAX_LOOP_and_13_psp <= CALC_SOFTMAX_LOOP_and_13_psp_mx0w0;
      CALC_SOFTMAX_LOOP_and_12_psp <= CALC_SOFTMAX_LOOP_and_12_psp_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm <= 1'b0;
    end
    else if ( core_wen & (~(mux_282_nl | or_tmp_152)) ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_4_itm <= CALC_SOFTMAX_LOOP_acc_1_tmp[4];
    end
  end
  assign COMPUTE_LOOP_if_mux_107_nl = MUX_v_32_2_2((plm_in_rsci_idat_mxwt[31:0]),
      (COMPUTE_LOOP_plm_in_tmp_data_lpi_1[31:0]), lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign COMPUTE_LOOP_if_mux_109_nl = MUX_v_32_2_2((plm_in_rsci_idat_mxwt[63:32]),
      (COMPUTE_LOOP_plm_in_tmp_data_lpi_1[63:32]), lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign COMPUTE_LOOP_if_mux_110_nl = MUX_v_32_2_2((plm_in_rsci_idat_mxwt[95:64]),
      (COMPUTE_LOOP_plm_in_tmp_data_lpi_1[95:64]), lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign COMPUTE_LOOP_if_mux_111_nl = MUX_v_32_2_2((plm_in_rsci_idat_mxwt[127:96]),
      (COMPUTE_LOOP_plm_in_tmp_data_lpi_1[127:96]), lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign COMPUTE_LOOP_if_mux_112_nl = MUX_v_32_2_2((plm_in_rsci_idat_mxwt[159:128]),
      (COMPUTE_LOOP_plm_in_tmp_data_lpi_1[159:128]), lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign COMPUTE_LOOP_if_mux_113_nl = MUX_v_32_2_2((plm_in_rsci_idat_mxwt[191:160]),
      (COMPUTE_LOOP_plm_in_tmp_data_lpi_1[191:160]), lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign COMPUTE_LOOP_if_mux_114_nl = MUX_v_32_2_2((plm_in_rsci_idat_mxwt[223:192]),
      (COMPUTE_LOOP_plm_in_tmp_data_lpi_1[223:192]), lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign COMPUTE_LOOP_if_mux_115_nl = MUX_v_32_2_2((plm_in_rsci_idat_mxwt[255:224]),
      (COMPUTE_LOOP_plm_in_tmp_data_lpi_1[255:224]), lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign COMPUTE_LOOP_if_mux_116_nl = MUX_v_32_2_2((plm_in_rsci_idat_mxwt[287:256]),
      (COMPUTE_LOOP_plm_in_tmp_data_lpi_1[287:256]), lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign COMPUTE_LOOP_if_mux_117_nl = MUX_v_32_2_2((plm_in_rsci_idat_mxwt[319:288]),
      (COMPUTE_LOOP_plm_in_tmp_data_lpi_1[319:288]), lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign COMPUTE_LOOP_if_mux_118_nl = MUX_v_32_2_2((plm_in_rsci_idat_mxwt[351:320]),
      (COMPUTE_LOOP_plm_in_tmp_data_lpi_1[351:320]), lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign COMPUTE_LOOP_if_mux_119_nl = MUX_v_32_2_2((plm_in_rsci_idat_mxwt[383:352]),
      (COMPUTE_LOOP_plm_in_tmp_data_lpi_1[383:352]), lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign COMPUTE_LOOP_if_mux_120_nl = MUX_v_32_2_2((plm_in_rsci_idat_mxwt[415:384]),
      (COMPUTE_LOOP_plm_in_tmp_data_lpi_1[415:384]), lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign COMPUTE_LOOP_if_mux_121_nl = MUX_v_32_2_2((plm_in_rsci_idat_mxwt[447:416]),
      (COMPUTE_LOOP_plm_in_tmp_data_lpi_1[447:416]), lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign COMPUTE_LOOP_if_mux_122_nl = MUX_v_32_2_2((plm_in_rsci_idat_mxwt[479:448]),
      (COMPUTE_LOOP_plm_in_tmp_data_lpi_1[479:448]), lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign COMPUTE_LOOP_if_mux_123_nl = MUX_v_32_2_2((plm_in_rsci_idat_mxwt[511:480]),
      (COMPUTE_LOOP_plm_in_tmp_data_lpi_1[511:480]), lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1);
  assign CALC_SOFTMAX_LOOP_mux_410_nl = MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
      (COMPUTE_LOOP_acc_1_tmp[4]), CALC_SOFTMAX_LOOP_acc_1_tmp[4]);
  assign CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_89_nl = MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
      CALC_SOFTMAX_LOOP_mux_410_nl, CALC_SOFTMAX_LOOP_equal_tmp_mx0w0);
  assign and_706_nl = COMPUTE_LOOP_if_asn_sft_lpi_1 & or_143_cse;
  assign mux_219_nl = MUX_s_1_2_2(and_706_nl, nor_43_cse, exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm);
  assign nor_44_nl = ~(or_tmp_247 | or_tmp_328);
  assign nor_45_nl = ~(or_tmp_244 | or_tmp_328);
  assign mux_216_nl = MUX_s_1_2_2(nor_44_nl, nor_45_nl, CALC_SOFTMAX_LOOP_equal_tmp_1_1);
  assign mux_217_nl = MUX_s_1_2_2(mux_216_nl, nor_43_cse, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign nor_47_nl = ~((~ or_tmp_5) | COMPUTE_LOOP_if_acc_itm_32_1 | (~ or_143_cse));
  assign mux_218_nl = MUX_s_1_2_2(mux_217_nl, nor_47_nl, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_220_nl = MUX_s_1_2_2(mux_219_nl, mux_218_nl, main_stage_v_1);
  assign nor_48_nl = ~((~ or_tmp_179) | COMPUTE_LOOP_if_acc_itm_32_1 | (~ or_143_cse));
  assign mux_221_nl = MUX_s_1_2_2(mux_220_nl, nor_48_nl, or_tmp_152);
  assign CALC_EXP_LOOP_not_6_nl = ~ CALC_EXP_LOOP_and_svs_mx0w0;
  assign CALC_SOFTMAX_LOOP_mux_21_nl = MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
      (COMPUTE_LOOP_acc_1_tmp[4]), CALC_SOFTMAX_LOOP_acc_1_tmp[4]);
  assign CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_68_nl = MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
      CALC_SOFTMAX_LOOP_mux_21_nl, CALC_SOFTMAX_LOOP_equal_tmp_mx0w0);
  assign COMPUTE_LOOP_if_mux_187_nl = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_0_lpi_1,
      or_dcpl_203);
  assign COMPUTE_LOOP_if_mux_185_nl = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_1_lpi_1,
      or_dcpl_200);
  assign COMPUTE_LOOP_if_mux_183_nl = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_2_lpi_1,
      or_dcpl_197);
  assign COMPUTE_LOOP_if_mux_181_nl = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_3_lpi_1,
      or_dcpl_194);
  assign COMPUTE_LOOP_if_mux_179_nl = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_4_lpi_1,
      or_dcpl_191);
  assign COMPUTE_LOOP_if_mux_177_nl = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_5_lpi_1,
      or_dcpl_188);
  assign COMPUTE_LOOP_if_mux_175_nl = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_6_lpi_1,
      or_dcpl_185);
  assign COMPUTE_LOOP_if_mux_173_nl = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_7_lpi_1,
      or_dcpl_182);
  assign COMPUTE_LOOP_if_mux_171_nl = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_8_lpi_1,
      or_dcpl_179);
  assign COMPUTE_LOOP_if_mux_169_nl = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_9_lpi_1,
      or_dcpl_176);
  assign COMPUTE_LOOP_if_mux_167_nl = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_10_lpi_1,
      or_dcpl_173);
  assign COMPUTE_LOOP_if_mux_165_nl = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_11_lpi_1,
      or_dcpl_170);
  assign COMPUTE_LOOP_if_mux_163_nl = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_12_lpi_1,
      or_dcpl_167);
  assign COMPUTE_LOOP_if_mux_161_nl = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_13_lpi_1,
      or_dcpl_164);
  assign COMPUTE_LOOP_if_mux_159_nl = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_14_lpi_1,
      or_dcpl_161);
  assign COMPUTE_LOOP_if_mux_157_nl = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_15_lpi_1,
      or_dcpl_158);
  assign COMPUTE_LOOP_if_COMPUTE_LOOP_if_nor_nl = ~(COMPUTE_LOOP_if_nor_2_cse | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx1);
  assign COMPUTE_LOOP_if_COMPUTE_LOOP_if_nor_2_nl = ~((~(CALC_SOFTMAX_LOOP_equal_tmp_4
      | CALC_SOFTMAX_LOOP_equal_tmp_1_4)) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_4);
  assign CALC_SOFTMAX_LOOP_mux_101_nl = MUX_v_67_2_2(CALC_SOFTMAX_LOOP_mux_40_itm_2,
      (ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_2_69_0[66:0]),
      or_dcpl_21);
  assign or_747_nl = COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1 | mux_tmp_271;
  assign mux_281_nl = MUX_s_1_2_2(or_tmp_416, or_747_nl, main_stage_v_1);
  assign or_746_nl = or_238_cse | mux_tmp_271;
  assign or_742_nl = (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0;
  assign mux_282_nl = MUX_s_1_2_2(mux_281_nl, or_746_nl, or_742_nl);

  function automatic [2:0] MUX1HOT_v_3_4_2;
    input [2:0] input_3;
    input [2:0] input_2;
    input [2:0] input_1;
    input [2:0] input_0;
    input [3:0] sel;
    reg [2:0] result;
  begin
    result = input_0 & {3{sel[0]}};
    result = result | ( input_1 & {3{sel[1]}});
    result = result | ( input_2 & {3{sel[2]}});
    result = result | ( input_3 & {3{sel[3]}});
    MUX1HOT_v_3_4_2 = result;
  end
  endfunction


  function automatic [3:0] MUX1HOT_v_4_3_2;
    input [3:0] input_2;
    input [3:0] input_1;
    input [3:0] input_0;
    input [2:0] sel;
    reg [3:0] result;
  begin
    result = input_0 & {4{sel[0]}};
    result = result | ( input_1 & {4{sel[1]}});
    result = result | ( input_2 & {4{sel[2]}});
    MUX1HOT_v_4_3_2 = result;
  end
  endfunction


  function automatic [6:0] MUX1HOT_v_7_4_2;
    input [6:0] input_3;
    input [6:0] input_2;
    input [6:0] input_1;
    input [6:0] input_0;
    input [3:0] sel;
    reg [6:0] result;
  begin
    result = input_0 & {7{sel[0]}};
    result = result | ( input_1 & {7{sel[1]}});
    result = result | ( input_2 & {7{sel[2]}});
    result = result | ( input_3 & {7{sel[3]}});
    MUX1HOT_v_7_4_2 = result;
  end
  endfunction


  function automatic [0:0] MUX_s_1_2_2;
    input [0:0] input_0;
    input [0:0] input_1;
    input [0:0] sel;
    reg [0:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function automatic [9:0] MUX_v_10_2_2;
    input [9:0] input_0;
    input [9:0] input_1;
    input [0:0] sel;
    reg [9:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_10_2_2 = result;
  end
  endfunction


  function automatic [9:0] MUX_v_10_8_2;
    input [9:0] input_0;
    input [9:0] input_1;
    input [9:0] input_2;
    input [9:0] input_3;
    input [9:0] input_4;
    input [9:0] input_5;
    input [9:0] input_6;
    input [9:0] input_7;
    input [2:0] sel;
    reg [9:0] result;
  begin
    case (sel)
      3'b000 : begin
        result = input_0;
      end
      3'b001 : begin
        result = input_1;
      end
      3'b010 : begin
        result = input_2;
      end
      3'b011 : begin
        result = input_3;
      end
      3'b100 : begin
        result = input_4;
      end
      3'b101 : begin
        result = input_5;
      end
      3'b110 : begin
        result = input_6;
      end
      default : begin
        result = input_7;
      end
    endcase
    MUX_v_10_8_2 = result;
  end
  endfunction


  function automatic [10:0] MUX_v_11_2_2;
    input [10:0] input_0;
    input [10:0] input_1;
    input [0:0] sel;
    reg [10:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_11_2_2 = result;
  end
  endfunction


  function automatic [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input [0:0] sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function automatic [31:0] MUX_v_32_16_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [31:0] input_2;
    input [31:0] input_3;
    input [31:0] input_4;
    input [31:0] input_5;
    input [31:0] input_6;
    input [31:0] input_7;
    input [31:0] input_8;
    input [31:0] input_9;
    input [31:0] input_10;
    input [31:0] input_11;
    input [31:0] input_12;
    input [31:0] input_13;
    input [31:0] input_14;
    input [31:0] input_15;
    input [3:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      4'b0000 : begin
        result = input_0;
      end
      4'b0001 : begin
        result = input_1;
      end
      4'b0010 : begin
        result = input_2;
      end
      4'b0011 : begin
        result = input_3;
      end
      4'b0100 : begin
        result = input_4;
      end
      4'b0101 : begin
        result = input_5;
      end
      4'b0110 : begin
        result = input_6;
      end
      4'b0111 : begin
        result = input_7;
      end
      4'b1000 : begin
        result = input_8;
      end
      4'b1001 : begin
        result = input_9;
      end
      4'b1010 : begin
        result = input_10;
      end
      4'b1011 : begin
        result = input_11;
      end
      4'b1100 : begin
        result = input_12;
      end
      4'b1101 : begin
        result = input_13;
      end
      4'b1110 : begin
        result = input_14;
      end
      default : begin
        result = input_15;
      end
    endcase
    MUX_v_32_16_2 = result;
  end
  endfunction


  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [0:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction


  function automatic [2:0] MUX_v_3_4_2;
    input [2:0] input_0;
    input [2:0] input_1;
    input [2:0] input_2;
    input [2:0] input_3;
    input [1:0] sel;
    reg [2:0] result;
  begin
    case (sel)
      2'b00 : begin
        result = input_0;
      end
      2'b01 : begin
        result = input_1;
      end
      2'b10 : begin
        result = input_2;
      end
      default : begin
        result = input_3;
      end
    endcase
    MUX_v_3_4_2 = result;
  end
  endfunction


  function automatic [3:0] MUX_v_4_2_2;
    input [3:0] input_0;
    input [3:0] input_1;
    input [0:0] sel;
    reg [3:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_4_2_2 = result;
  end
  endfunction


  function automatic [4:0] MUX_v_5_4_2;
    input [4:0] input_0;
    input [4:0] input_1;
    input [4:0] input_2;
    input [4:0] input_3;
    input [1:0] sel;
    reg [4:0] result;
  begin
    case (sel)
      2'b00 : begin
        result = input_0;
      end
      2'b01 : begin
        result = input_1;
      end
      2'b10 : begin
        result = input_2;
      end
      default : begin
        result = input_3;
      end
    endcase
    MUX_v_5_4_2 = result;
  end
  endfunction


  function automatic [66:0] MUX_v_67_16_2;
    input [66:0] input_0;
    input [66:0] input_1;
    input [66:0] input_2;
    input [66:0] input_3;
    input [66:0] input_4;
    input [66:0] input_5;
    input [66:0] input_6;
    input [66:0] input_7;
    input [66:0] input_8;
    input [66:0] input_9;
    input [66:0] input_10;
    input [66:0] input_11;
    input [66:0] input_12;
    input [66:0] input_13;
    input [66:0] input_14;
    input [66:0] input_15;
    input [3:0] sel;
    reg [66:0] result;
  begin
    case (sel)
      4'b0000 : begin
        result = input_0;
      end
      4'b0001 : begin
        result = input_1;
      end
      4'b0010 : begin
        result = input_2;
      end
      4'b0011 : begin
        result = input_3;
      end
      4'b0100 : begin
        result = input_4;
      end
      4'b0101 : begin
        result = input_5;
      end
      4'b0110 : begin
        result = input_6;
      end
      4'b0111 : begin
        result = input_7;
      end
      4'b1000 : begin
        result = input_8;
      end
      4'b1001 : begin
        result = input_9;
      end
      4'b1010 : begin
        result = input_10;
      end
      4'b1011 : begin
        result = input_11;
      end
      4'b1100 : begin
        result = input_12;
      end
      4'b1101 : begin
        result = input_13;
      end
      4'b1110 : begin
        result = input_14;
      end
      default : begin
        result = input_15;
      end
    endcase
    MUX_v_67_16_2 = result;
  end
  endfunction


  function automatic [66:0] MUX_v_67_2_2;
    input [66:0] input_0;
    input [66:0] input_1;
    input [0:0] sel;
    reg [66:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_67_2_2 = result;
  end
  endfunction


  function automatic [5:0] MUX_v_6_2_2;
    input [5:0] input_0;
    input [5:0] input_1;
    input [0:0] sel;
    reg [5:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_6_2_2 = result;
  end
  endfunction


  function automatic [69:0] MUX_v_70_2_2;
    input [69:0] input_0;
    input [69:0] input_1;
    input [0:0] sel;
    reg [69:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_70_2_2 = result;
  end
  endfunction


  function automatic [70:0] MUX_v_71_2_2;
    input [70:0] input_0;
    input [70:0] input_1;
    input [0:0] sel;
    reg [70:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_71_2_2 = result;
  end
  endfunction


  function automatic [7:0] MUX_v_8_2_2;
    input [7:0] input_0;
    input [7:0] input_1;
    input [0:0] sel;
    reg [7:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_8_2_2 = result;
  end
  endfunction


  function automatic [7:0] MUX_v_8_8_2;
    input [7:0] input_0;
    input [7:0] input_1;
    input [7:0] input_2;
    input [7:0] input_3;
    input [7:0] input_4;
    input [7:0] input_5;
    input [7:0] input_6;
    input [7:0] input_7;
    input [2:0] sel;
    reg [7:0] result;
  begin
    case (sel)
      3'b000 : begin
        result = input_0;
      end
      3'b001 : begin
        result = input_1;
      end
      3'b010 : begin
        result = input_2;
      end
      3'b011 : begin
        result = input_3;
      end
      3'b100 : begin
        result = input_4;
      end
      3'b101 : begin
        result = input_5;
      end
      3'b110 : begin
        result = input_6;
      end
      default : begin
        result = input_7;
      end
    endcase
    MUX_v_8_8_2 = result;
  end
  endfunction


  function automatic [90:0] MUX_v_91_2_2;
    input [90:0] input_0;
    input [90:0] input_1;
    input [0:0] sel;
    reg [90:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_91_2_2 = result;
  end
  endfunction


  function automatic [0:0] readslicef_33_1_32;
    input [32:0] vector;
    reg [32:0] tmp;
  begin
    tmp = vector >> 32;
    readslicef_33_1_32 = tmp[0:0];
  end
  endfunction


  function automatic [10:0] conv_s2u_9_11 ;
    input [8:0]  vector ;
  begin
    conv_s2u_9_11 = {{2{vector[8]}}, vector};
  end
  endfunction


  function automatic [10:0] conv_u2s_10_11 ;
    input [9:0]  vector ;
  begin
    conv_u2s_10_11 =  {1'b0, vector};
  end
  endfunction


  function automatic [4:0] conv_u2u_4_5 ;
    input [3:0]  vector ;
  begin
    conv_u2u_4_5 = {1'b0, vector};
  end
  endfunction


  function automatic [10:0] conv_u2u_9_11 ;
    input [8:0]  vector ;
  begin
    conv_u2u_9_11 = {{2{1'b0}}, vector};
  end
  endfunction


  function automatic [18:0] conv_u2u_19_19 ;
    input [18:0]  vector ;
  begin
    conv_u2u_19_19 = vector;
  end
  endfunction


  function automatic [32:0] conv_u2u_32_33 ;
    input [31:0]  vector ;
  begin
    conv_u2u_32_33 = {1'b0, vector};
  end
  endfunction


  function automatic [70:0] conv_u2u_67_71 ;
    input [66:0]  vector ;
  begin
    conv_u2u_67_71 = {{4{1'b0}}, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store_core (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, plm_out_rsc_dat,
      plm_out_rsc_vld, plm_out_rsc_rdy, dma_write_ctrl_rsc_dat, dma_write_ctrl_rsc_vld,
      dma_write_ctrl_rsc_rdy, dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy,
      done_rsc_rdy, done_rsc_vld
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  input [511:0] plm_out_rsc_dat;
  input plm_out_rsc_vld;
  output plm_out_rsc_rdy;
  output [66:0] dma_write_ctrl_rsc_dat;
  output dma_write_ctrl_rsc_vld;
  input dma_write_ctrl_rsc_rdy;
  output [63:0] dma_write_chnl_rsc_dat;
  output dma_write_chnl_rsc_vld;
  input dma_write_chnl_rsc_rdy;
  input done_rsc_rdy;
  output done_rsc_vld;


  // Interconnect Declarations
  wire core_wen;
  wire conf_info_rsci_bawt;
  reg conf_info_rsci_iswt0;
  wire core_wten;
  wire conf_info_rsci_wen_comp;
  reg conf_info_rsci_irdy_core_psct;
  wire conf_info_rsci_ivld;
  wire conf_info_rsci_ivld_oreg;
  wire [31:0] conf_info_rsci_idat_mxwt;
  wire plm_out_rsci_bawt;
  wire plm_out_rsci_wen_comp;
  wire plm_out_rsci_ivld;
  wire plm_out_rsci_ivld_oreg;
  wire [511:0] plm_out_rsci_idat_mxwt;
  wire dma_write_ctrl_rsci_bawt;
  wire dma_write_ctrl_rsci_irdy_mxwt;
  wire dma_write_chnl_rsci_bawt;
  wire dma_write_chnl_rsci_wen_comp;
  wire done_rsci_bawt;
  wire done_rsci_wen_comp;
  reg [27:0] dma_write_ctrl_rsci_idat_31_4;
  reg [31:0] dma_write_chnl_rsci_idat_31_0;
  wire [1:0] fsm_output;
  wire [4:0] STORE_BATCH_LOOP_acc_2_tmp;
  wire [5:0] nl_STORE_BATCH_LOOP_acc_2_tmp;
  wire [4:0] STORE_INNER_LOOP_acc_1_tmp;
  wire [5:0] nl_STORE_INNER_LOOP_acc_1_tmp;
  wire or_tmp_14;
  wire and_tmp_4;
  wire or_tmp_23;
  wire or_tmp_116;
  wire or_tmp_127;
  wire and_dcpl_3;
  wire or_dcpl_2;
  wire or_dcpl_3;
  wire and_tmp_72;
  wire and_dcpl_9;
  wire and_dcpl_11;
  wire mux_tmp_139;
  wire nand_tmp_10;
  wire and_tmp_79;
  wire or_dcpl_4;
  wire and_dcpl_13;
  wire mux_tmp_141;
  wire and_tmp_81;
  wire or_tmp_189;
  wire and_tmp_82;
  wire or_tmp_191;
  wire mux_tmp_145;
  wire and_dcpl_19;
  wire and_dcpl_23;
  wire or_tmp_201;
  wire and_dcpl_26;
  wire and_dcpl_29;
  wire and_dcpl_30;
  wire and_dcpl_31;
  wire and_dcpl_34;
  wire and_dcpl_36;
  wire or_dcpl_19;
  wire and_dcpl_41;
  wire and_dcpl_44;
  wire and_dcpl_50;
  wire and_dcpl_55;
  wire and_dcpl_60;
  wire and_dcpl_64;
  wire and_dcpl_69;
  wire and_dcpl_73;
  wire or_dcpl_29;
  wire and_tmp_97;
  wire or_tmp_230;
  wire mux_tmp_187;
  wire and_dcpl_76;
  wire or_tmp_231;
  wire and_dcpl_81;
  wire and_dcpl_82;
  wire or_dcpl_37;
  wire and_dcpl_93;
  wire and_tmp_103;
  wire and_dcpl_96;
  wire or_tmp_252;
  wire or_tmp_258;
  wire and_dcpl_101;
  wire or_14_cse;
  wire and_244_cse;
  wire main_stage_en_4;
  wire lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx0w0;
  wire lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx0w0;
  wire lfst_exit_STORE_INNER_LOOP_lpi_1_1_mx0;
  wire lfst_exit_STORE_INNER_LOOP_lpi_1_0_mx0;
  wire exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_mx1;
  wire exitL_exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_1;
  reg exit_STORE_BATCH_LOOP_lpi_1_dfm_3;
  reg exitL_exit_STORE_BATCH_LOOP_sva;
  reg STORE_BATCH_LOOP_asn_itm;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1;
  reg STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1;
  reg main_stage_v_1;
  wire lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_3_1_1;
  wire lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_3_0_1;
  reg STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_2_1_1;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_1;
  wire STORE_INNER_LOOP_and_2_ssc_1;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_0;
  reg STORE_INNER_LOOP_or_tmp_1;
  reg exit_STORE_CTRL_LOOP_sva_st_1;
  reg main_stage_v_2;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0;
  reg exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_3;
  reg main_stage_v_3;
  wire lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx1;
  wire lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx1;
  reg STORE_INNER_LOOP_equal_tmp_1;
  reg STORE_BATCH_LOOP_if_and_itm_1;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_0;
  reg STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2;
  reg exitL_exit_STORE_INNER_LOOP_lpi_1_dfm;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_1;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_0;
  reg STORE_BATCH_LOOP_if_asn_sft_lpi_1;
  reg exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_2;
  reg reg_done_rsci_ivld_core_psct_cse;
  reg reg_dma_write_chnl_rsci_ivld_core_psct_cse;
  reg reg_dma_write_ctrl_rsci_ivld_core_psct_cse;
  reg reg_plm_out_rsci_irdy_core_psct_cse;
  wire and_320_cse;
  wire or_83_cse;
  wire and_125_cse;
  wire STORE_INNER_LOOP_and_9_cse;
  wire or_34_cse;
  wire and_58_cse;
  wire and_63_cse;
  wire nor_90_cse;
  wire nor_62_cse;
  wire nor_68_cse;
  wire and_301_cse;
  wire nor_71_cse;
  wire mux_21_cse;
  wire and_214_cse;
  wire mux_221_cse;
  wire nand_52_cse;
  wire mux_123_cse;
  wire and_59_cse;
  wire mux_226_cse;
  wire mux_220_cse;
  wire or_429_tmp;
  wire STORE_BATCH_LOOP_if_and_2_tmp;
  wire and_334_cse;
  wire mux_245_itm;
  reg [27:0] STORE_BATCH_LOOP_acc_3_psp_lpi_1;
  reg [511:0] STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1;
  reg [31:0] batch_lpi_1_dfm;
  reg exit_STORE_CTRL_LOOP_sva_st;
  reg exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_1;
  reg [3:0] STORE_BATCH_LOOP_b_4_0_lpi_1_3_0;
  reg [3:0] STORE_INNER_LOOP_i_4_0_lpi_1_3_0;
  reg [3:0] STORE_INNER_LOOP_i_4_0_sva_1_1_3_0;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_0;
  wire dma_write_ctrl_rsci_idat_31_4_mx0c1;
  wire [511:0] STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0;
  wire [3:0] STORE_INNER_LOOP_i_4_0_lpi_1_3_0_mx0w0;
  wire exit_STORE_BATCH_LOOP_lpi_1_dfm_3_mx0c1;
  wire exit_STORE_BATCH_LOOP_lpi_1_dfm_3_mx1;
  wire STORE_BATCH_LOOP_b_4_0_lpi_1_3_0_mx0c1;
  wire STORE_BATCH_LOOP_if_asn_sft_lpi_1_mx0;
  wire [31:0] batch_lpi_1_dfm_mx1;
  wire main_stage_v_1_mx0c1;
  wire lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1_mx0c1;
  wire STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1;
  wire main_stage_v_2_mx0c1;
  wire exit_STORE_CTRL_LOOP_sva_st_1_mx0c1;
  wire main_stage_v_3_mx0c1;
  wire exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_1_mx0c1;
  wire [3:0] STORE_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_1;
  wire exit_STORE_BATCH_LOOP_lpi_1_dfm_4;
  wire [27:0] STORE_BATCH_LOOP_acc_3_psp_sva_1;
  wire [28:0] nl_STORE_BATCH_LOOP_acc_3_psp_sva_1;
  wire and_324_cse;
  wire STORE_INNER_LOOP_and_20_cse;
  wire STORE_INNER_LOOP_i_and_cse;
  wire STORE_BATCH_LOOP_if_and_6_cse;
  wire STORE_INNER_LOOP_and_25_cse;
  wire STORE_BATCH_LOOP_if_acc_itm_32_1;

  wire[0:0] mux_147_nl;
  wire[0:0] nand_45_nl;
  wire[0:0] mux_146_nl;
  wire[0:0] mux_145_nl;
  wire[0:0] mux_144_nl;
  wire[0:0] mux_143_nl;
  wire[0:0] mux_142_nl;
  wire[0:0] or_402_nl;
  wire[0:0] mux_141_nl;
  wire[0:0] mux_140_nl;
  wire[0:0] mux_139_nl;
  wire[0:0] or_404_nl;
  wire[0:0] mux_138_nl;
  wire[0:0] or_405_nl;
  wire[0:0] nand_47_nl;
  wire[0:0] mux_137_nl;
  wire[0:0] nand_48_nl;
  wire[0:0] or_407_nl;
  wire[0:0] or_408_nl;
  wire[0:0] and_306_nl;
  wire[0:0] nor_81_nl;
  wire[0:0] mux_135_nl;
  wire[0:0] mux_151_nl;
  wire[0:0] nor_79_nl;
  wire[0:0] nor_80_nl;
  wire[0:0] mux_165_nl;
  wire[0:0] mux_164_nl;
  wire[0:0] mux_163_nl;
  wire[0:0] nor_64_nl;
  wire[0:0] mux_162_nl;
  wire[0:0] mux_161_nl;
  wire[0:0] mux_160_nl;
  wire[0:0] and_323_nl;
  wire[0:0] mux_159_nl;
  wire[0:0] or_231_nl;
  wire[0:0] mux_158_nl;
  wire[0:0] and_117_nl;
  wire[0:0] and_116_nl;
  wire[0:0] STORE_INNER_LOOP_mux_29_nl;
  wire[0:0] mux_198_nl;
  wire[0:0] mux_205_nl;
  wire[0:0] or_293_nl;
  wire[0:0] and_216_nl;
  wire[0:0] mux_224_nl;
  wire[0:0] mux_223_nl;
  wire[0:0] mux_222_nl;
  wire[0:0] mux_241_nl;
  wire[0:0] or_365_nl;
  wire[0:0] or_364_nl;
  wire[0:0] STORE_INNER_LOOP_mux_6_nl;
  wire[0:0] asn_STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_nand_nl;
  wire[0:0] nor_103_nl;
  wire[0:0] and_336_nl;
  wire[0:0] STORE_INNER_LOOP_mux_28_nl;
  wire[0:0] and_192_nl;
  wire[0:0] mux_204_nl;
  wire[0:0] or_290_nl;
  wire[0:0] mux_203_nl;
  wire[0:0] and_302_nl;
  wire[0:0] STORE_BATCH_LOOP_if_STORE_BATCH_LOOP_if_STORE_BATCH_LOOP_if_or_nl;
  wire[0:0] STORE_BATCH_LOOP_not_12_nl;
  wire[32:0] STORE_BATCH_LOOP_if_acc_nl;
  wire[33:0] nl_STORE_BATCH_LOOP_if_acc_nl;
  wire[3:0] STORE_INNER_LOOP_i_mux_nl;
  wire[0:0] STORE_INNER_LOOP_mux_27_nl;
  wire[0:0] or_28_nl;
  wire[0:0] or_26_nl;
  wire[0:0] or_201_nl;
  wire[0:0] or_200_nl;
  wire[0:0] mux_78_nl;
  wire[0:0] nor_nl;
  wire[0:0] nor_105_nl;
  wire[0:0] or_213_nl;
  wire[0:0] and_109_nl;
  wire[0:0] mux_153_nl;
  wire[0:0] mux_152_nl;
  wire[0:0] or_221_nl;
  wire[0:0] mux_155_nl;
  wire[0:0] mux_156_nl;
  wire[0:0] and_181_nl;
  wire[0:0] mux_195_nl;
  wire[0:0] mux_194_nl;
  wire[0:0] mux_193_nl;
  wire[0:0] mux_192_nl;
  wire[0:0] mux_197_nl;
  wire[0:0] mux_201_nl;
  wire[0:0] nor_77_nl;
  wire[0:0] nor_78_nl;
  wire[0:0] mux_200_nl;
  wire[0:0] and_303_nl;
  wire[0:0] mux_199_nl;
  wire[0:0] and_188_nl;
  wire[0:0] mux_210_nl;
  wire[0:0] nor_75_nl;
  wire[0:0] nor_76_nl;
  wire[0:0] mux_209_nl;
  wire[0:0] mux_208_nl;
  wire[0:0] mux_218_nl;
  wire[0:0] mux_217_nl;
  wire[0:0] mux_216_nl;
  wire[0:0] mux_215_nl;
  wire[0:0] mux_212_nl;
  wire[0:0] nor_69_nl;
  wire[0:0] mux_230_nl;
  wire[0:0] mux_229_nl;
  wire[0:0] mux_228_nl;
  wire[0:0] mux_227_nl;
  wire[0:0] nor_72_nl;
  wire[0:0] mux_244_nl;
  wire[0:0] mux_243_nl;
  wire[0:0] or_371_nl;
  wire[0:0] mux_122_nl;
  wire[0:0] and_69_nl;
  wire[0:0] mux_121_nl;
  wire[0:0] mux_120_nl;
  wire[0:0] mux_119_nl;
  wire[0:0] mux_118_nl;
  wire[0:0] mux_117_nl;
  wire[0:0] and_68_nl;
  wire[0:0] and_67_nl;
  wire[0:0] mux_116_nl;
  wire[0:0] mux_115_nl;
  wire[0:0] and_65_nl;
  wire[0:0] and_64_nl;
  wire[0:0] and_60_nl;
  wire[0:0] mux_124_nl;
  wire[0:0] mux_206_nl;
  wire[0:0] nor_53_nl;
  wire[0:0] mux_235_nl;
  wire[0:0] mux_234_nl;
  wire[0:0] mux_233_nl;
  wire[0:0] mux_236_nl;
  wire[0:0] nor_67_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [0:0] nl_store_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg;
  assign nl_store_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg = and_dcpl_64
      & and_dcpl_3 & (fsm_output[1]);
  wire [0:0] nl_store_core_plm_out_rsci_inst_plm_out_rsci_oswt_unreg;
  assign nl_store_core_plm_out_rsci_inst_plm_out_rsci_oswt_unreg = and_dcpl_44 &
      exit_STORE_CTRL_LOOP_sva_st_1 & plm_out_rsci_bawt & and_dcpl_55;
  wire [66:0] nl_store_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat;
  assign nl_store_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat = {35'b01100000000000000000000000000010000
      , dma_write_ctrl_rsci_idat_31_4 , 4'b0000};
  wire [0:0] nl_store_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg;
  assign nl_store_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg =
      and_dcpl_44 & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0) & dma_write_chnl_rsci_bawt
      & and_dcpl_36;
  wire [63:0] nl_store_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat;
  assign nl_store_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat = {32'b11011110101011011011111011101111
      , dma_write_chnl_rsci_idat_31_0};
  esp_acc_softmax_cxx_catapult_store_core_wait_dp store_core_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsci_ivld(conf_info_rsci_ivld),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg),
      .plm_out_rsci_ivld(plm_out_rsci_ivld),
      .plm_out_rsci_ivld_oreg(plm_out_rsci_ivld_oreg)
    );
  esp_acc_softmax_cxx_catapult_store_core_conf_info_rsci store_core_conf_info_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .core_wen(core_wen),
      .conf_info_rsci_oswt_unreg(nl_store_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg[0:0]),
      .conf_info_rsci_bawt(conf_info_rsci_bawt),
      .conf_info_rsci_iswt0(conf_info_rsci_iswt0),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_irdy_core_psct(conf_info_rsci_irdy_core_psct),
      .conf_info_rsci_ivld(conf_info_rsci_ivld),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_catapult_store_core_plm_out_rsci store_core_plm_out_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsc_dat(plm_out_rsc_dat),
      .plm_out_rsc_vld(plm_out_rsc_vld),
      .plm_out_rsc_rdy(plm_out_rsc_rdy),
      .core_wen(core_wen),
      .plm_out_rsci_oswt_unreg(nl_store_core_plm_out_rsci_inst_plm_out_rsci_oswt_unreg[0:0]),
      .plm_out_rsci_bawt(plm_out_rsci_bawt),
      .plm_out_rsci_iswt0(reg_plm_out_rsci_irdy_core_psct_cse),
      .plm_out_rsci_wen_comp(plm_out_rsci_wen_comp),
      .plm_out_rsci_ivld(plm_out_rsci_ivld),
      .plm_out_rsci_ivld_oreg(plm_out_rsci_ivld_oreg),
      .plm_out_rsci_idat_mxwt(plm_out_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_catapult_store_core_dma_write_ctrl_rsci store_core_dma_write_ctrl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_write_ctrl_rsc_dat(dma_write_ctrl_rsc_dat),
      .dma_write_ctrl_rsc_vld(dma_write_ctrl_rsc_vld),
      .dma_write_ctrl_rsc_rdy(dma_write_ctrl_rsc_rdy),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dma_write_ctrl_rsci_oswt_unreg(and_dcpl_50),
      .dma_write_ctrl_rsci_bawt(dma_write_ctrl_rsci_bawt),
      .dma_write_ctrl_rsci_iswt0(reg_dma_write_ctrl_rsci_ivld_core_psct_cse),
      .dma_write_ctrl_rsci_irdy_mxwt(dma_write_ctrl_rsci_irdy_mxwt),
      .dma_write_ctrl_rsci_idat(nl_store_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat[66:0])
    );
  esp_acc_softmax_cxx_catapult_store_core_dma_write_chnl_rsci store_core_dma_write_chnl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_write_chnl_rsc_dat(dma_write_chnl_rsc_dat),
      .dma_write_chnl_rsc_vld(dma_write_chnl_rsc_vld),
      .dma_write_chnl_rsc_rdy(dma_write_chnl_rsc_rdy),
      .core_wen(core_wen),
      .dma_write_chnl_rsci_oswt_unreg(nl_store_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg[0:0]),
      .dma_write_chnl_rsci_bawt(dma_write_chnl_rsci_bawt),
      .dma_write_chnl_rsci_iswt0(reg_dma_write_chnl_rsci_ivld_core_psct_cse),
      .dma_write_chnl_rsci_wen_comp(dma_write_chnl_rsci_wen_comp),
      .dma_write_chnl_rsci_idat(nl_store_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat[63:0])
    );
  esp_acc_softmax_cxx_catapult_store_core_done_rsci store_core_done_rsci_inst (
      .clk(clk),
      .rst(rst),
      .done_rsc_rdy(done_rsc_rdy),
      .done_rsc_vld(done_rsc_vld),
      .core_wen(core_wen),
      .done_rsci_oswt_unreg(and_dcpl_29),
      .done_rsci_bawt(done_rsci_bawt),
      .done_rsci_iswt0(reg_done_rsci_ivld_core_psct_cse),
      .done_rsci_wen_comp(done_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_catapult_store_core_staller store_core_staller_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .plm_out_rsci_wen_comp(plm_out_rsci_wen_comp),
      .dma_write_chnl_rsci_wen_comp(dma_write_chnl_rsci_wen_comp),
      .done_rsci_wen_comp(done_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_catapult_store_core_core_fsm store_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  assign nand_45_nl = ~(STORE_BATCH_LOOP_asn_itm & and_tmp_72);
  assign or_402_nl = (~ lfst_exit_STORE_INNER_LOOP_lpi_1_1) | lfst_exit_STORE_INNER_LOOP_lpi_1_0
      | STORE_BATCH_LOOP_if_asn_sft_lpi_1 | nand_52_cse;
  assign mux_142_nl = MUX_s_1_2_2(or_402_nl, or_tmp_127, exitL_exit_STORE_INNER_LOOP_lpi_1_dfm);
  assign or_405_nl = (~ or_tmp_23) | STORE_BATCH_LOOP_if_acc_itm_32_1 | (~ and_tmp_4);
  assign nand_47_nl = ~(or_tmp_23 & (STORE_BATCH_LOOP_acc_2_tmp[4]) & (STORE_INNER_LOOP_acc_1_tmp[4])
      & and_tmp_4);
  assign mux_138_nl = MUX_s_1_2_2(or_405_nl, nand_47_nl, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_2_1_1);
  assign or_404_nl = and_320_cse | mux_138_nl;
  assign nand_48_nl = ~(dma_write_ctrl_rsci_irdy_mxwt & dma_write_ctrl_rsci_bawt
      & (STORE_BATCH_LOOP_acc_2_tmp[4]) & (STORE_INNER_LOOP_acc_1_tmp[4]) & and_tmp_4);
  assign mux_137_nl = MUX_s_1_2_2(nand_48_nl, nand_52_cse, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1);
  assign mux_139_nl = MUX_s_1_2_2(or_404_nl, mux_137_nl, STORE_INNER_LOOP_or_tmp_1);
  assign mux_140_nl = MUX_s_1_2_2(mux_139_nl, or_tmp_127, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign or_407_nl = (~ or_14_cse) | STORE_BATCH_LOOP_if_acc_itm_32_1 | (~ and_tmp_4);
  assign mux_141_nl = MUX_s_1_2_2(mux_140_nl, or_407_nl, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_143_nl = MUX_s_1_2_2(mux_142_nl, mux_141_nl, main_stage_v_1);
  assign or_408_nl = (~ or_34_cse) | STORE_BATCH_LOOP_if_acc_itm_32_1 | (~ and_tmp_4);
  assign mux_144_nl = MUX_s_1_2_2(mux_143_nl, or_408_nl, exit_STORE_BATCH_LOOP_lpi_1_dfm_3);
  assign and_306_nl = or_34_cse & STORE_BATCH_LOOP_if_acc_itm_32_1 & and_tmp_4;
  assign mux_145_nl = MUX_s_1_2_2(mux_144_nl, and_306_nl, exitL_exit_STORE_BATCH_LOOP_sva);
  assign nor_81_nl = ~(exitL_exit_STORE_BATCH_LOOP_sva | and_tmp_72);
  assign mux_146_nl = MUX_s_1_2_2(mux_145_nl, nor_81_nl, STORE_BATCH_LOOP_asn_itm);
  assign mux_147_nl = MUX_s_1_2_2(nand_45_nl, mux_146_nl, main_stage_en_4);
  assign and_324_cse = core_wen & (~(mux_147_nl & (fsm_output[1])));
  assign and_125_cse = STORE_BATCH_LOOP_if_acc_itm_32_1 & mux_21_cse;
  assign and_320_cse = lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_1 & lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_0;
  assign STORE_INNER_LOOP_i_and_cse = core_wen & (~(or_dcpl_29 | (and_dcpl_73 & (~
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1)) | (~ main_stage_v_1)));
  assign or_34_cse = (~ main_stage_v_1) | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1
      | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1 | dma_write_ctrl_rsci_bawt;
  assign or_83_cse = (~ STORE_BATCH_LOOP_asn_itm) | conf_info_rsci_bawt;
  assign nor_90_cse = ~(exit_STORE_BATCH_LOOP_lpi_1_dfm_3 | exitL_exit_STORE_BATCH_LOOP_sva);
  assign STORE_INNER_LOOP_and_9_cse = core_wen & (~ (fsm_output[0]));
  assign STORE_INNER_LOOP_and_20_cse = core_wen & (~ or_dcpl_4);
  assign nor_62_cse = ~(STORE_BATCH_LOOP_if_asn_sft_lpi_1 | (~ mux_21_cse));
  assign and_214_cse = STORE_BATCH_LOOP_if_acc_itm_32_1 & and_tmp_103;
  assign and_216_nl = (and_320_cse | STORE_INNER_LOOP_or_tmp_1 | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_2_1_1
      | STORE_BATCH_LOOP_if_acc_itm_32_1) & and_tmp_103;
  assign mux_221_cse = MUX_s_1_2_2(and_216_nl, and_125_cse, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_220_cse = MUX_s_1_2_2(and_214_cse, and_125_cse, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign STORE_BATCH_LOOP_if_and_6_cse = core_wen & (~ or_dcpl_29);
  assign or_365_nl = exitL_exit_STORE_INNER_LOOP_lpi_1_dfm | STORE_BATCH_LOOP_if_asn_sft_lpi_1;
  assign or_364_nl = or_tmp_231 | (~ or_tmp_189);
  assign mux_241_nl = MUX_s_1_2_2(or_365_nl, or_364_nl, main_stage_v_1);
  assign STORE_INNER_LOOP_and_25_cse = STORE_INNER_LOOP_and_9_cse & (~(mux_241_nl
      | or_tmp_14));
  assign asn_STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_nand_nl = ~(main_stage_v_2
      & STORE_BATCH_LOOP_if_and_itm_1);
  assign STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0 = MUX_v_512_2_2(plm_out_rsci_idat_mxwt,
      STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1, asn_STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_nand_nl);
  assign and_334_cse = (~ dma_write_ctrl_rsci_irdy_mxwt) & STORE_INNER_LOOP_or_tmp_1;
  assign or_429_tmp = and_334_cse | and_320_cse | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign STORE_BATCH_LOOP_if_and_2_tmp = STORE_INNER_LOOP_equal_tmp_1 & (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign nor_103_nl = ~(STORE_BATCH_LOOP_if_and_2_tmp | or_429_tmp);
  assign and_336_nl = STORE_BATCH_LOOP_if_and_2_tmp & (~ or_429_tmp);
  assign STORE_INNER_LOOP_i_4_0_lpi_1_3_0_mx0w0 = MUX1HOT_v_4_3_2((signext_4_1(~
      dma_write_ctrl_rsci_irdy_mxwt)), STORE_INNER_LOOP_i_4_0_sva_1_1_3_0, STORE_INNER_LOOP_i_4_0_lpi_1_3_0,
      {nor_103_nl , and_336_nl , or_429_tmp});
  assign STORE_INNER_LOOP_mux_28_nl = MUX_s_1_2_2(exit_STORE_BATCH_LOOP_lpi_1_dfm_4,
      (STORE_BATCH_LOOP_acc_2_tmp[4]), STORE_INNER_LOOP_acc_1_tmp[4]);
  assign and_302_nl = lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_2_1_1 & (~ and_320_cse);
  assign mux_203_nl = MUX_s_1_2_2(and_302_nl, dma_write_ctrl_rsci_irdy_mxwt, STORE_INNER_LOOP_or_tmp_1);
  assign or_290_nl = or_tmp_231 | (~ mux_203_nl);
  assign mux_204_nl = MUX_s_1_2_2(or_tmp_230, or_290_nl, main_stage_v_1);
  assign and_192_nl = (~ mux_204_nl) & nor_90_cse;
  assign exit_STORE_BATCH_LOOP_lpi_1_dfm_3_mx1 = MUX_s_1_2_2(exit_STORE_BATCH_LOOP_lpi_1_dfm_4,
      STORE_INNER_LOOP_mux_28_nl, and_192_nl);
  assign lfst_exit_STORE_INNER_LOOP_lpi_1_1_mx0 = MUX_s_1_2_2(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_3_1_1,
      lfst_exit_STORE_INNER_LOOP_lpi_1_1, or_dcpl_37);
  assign lfst_exit_STORE_INNER_LOOP_lpi_1_0_mx0 = MUX_s_1_2_2(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_3_0_1,
      lfst_exit_STORE_INNER_LOOP_lpi_1_0, or_dcpl_37);
  assign STORE_BATCH_LOOP_if_asn_sft_lpi_1_mx0 = MUX_s_1_2_2(STORE_BATCH_LOOP_if_asn_sft_lpi_1,
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1, main_stage_v_1);
  assign batch_lpi_1_dfm_mx1 = MUX_v_32_2_2(batch_lpi_1_dfm, conf_info_rsci_idat_mxwt,
      exitL_exit_STORE_BATCH_LOOP_sva);
  assign STORE_BATCH_LOOP_if_STORE_BATCH_LOOP_if_STORE_BATCH_LOOP_if_or_nl = (~(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_3_1_1
      | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_3_0_1)) | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_mx1 = MUX_s_1_2_2(exitL_exit_STORE_INNER_LOOP_lpi_1_dfm,
      STORE_BATCH_LOOP_if_STORE_BATCH_LOOP_if_STORE_BATCH_LOOP_if_or_nl, main_stage_v_1);
  assign lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx0w0 = lfst_exit_STORE_INNER_LOOP_lpi_1_1_mx0
      & (~ exitL_exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_1);
  assign lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx0w0 = lfst_exit_STORE_INNER_LOOP_lpi_1_0_mx0
      & (~ exitL_exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_1);
  assign lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx1 = MUX_s_1_2_2(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1,
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx0w0, mux_245_itm);
  assign lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx1 = MUX_s_1_2_2(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_0,
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx0w0, mux_245_itm);
  assign STORE_BATCH_LOOP_not_12_nl = ~ exitL_exit_STORE_BATCH_LOOP_sva;
  assign STORE_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_1 = MUX_v_4_2_2(4'b0000, STORE_BATCH_LOOP_b_4_0_lpi_1_3_0,
      STORE_BATCH_LOOP_not_12_nl);
  assign exit_STORE_BATCH_LOOP_lpi_1_dfm_4 = (~ STORE_BATCH_LOOP_if_acc_itm_32_1)
      & exitL_exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_1;
  assign nl_STORE_BATCH_LOOP_if_acc_nl = ({29'b10000000000000000000000000000 , STORE_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_1})
      + conv_u2u_32_33(~ batch_lpi_1_dfm_mx1) + 33'b000000000000000000000000000000001;
  assign STORE_BATCH_LOOP_if_acc_nl = nl_STORE_BATCH_LOOP_if_acc_nl[32:0];
  assign STORE_BATCH_LOOP_if_acc_itm_32_1 = readslicef_33_1_32(STORE_BATCH_LOOP_if_acc_nl);
  assign nl_STORE_BATCH_LOOP_acc_2_tmp = conv_u2u_4_5(STORE_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_1)
      + 5'b00001;
  assign STORE_BATCH_LOOP_acc_2_tmp = nl_STORE_BATCH_LOOP_acc_2_tmp[4:0];
  assign STORE_INNER_LOOP_i_mux_nl = MUX_v_4_2_2(STORE_INNER_LOOP_i_4_0_lpi_1_3_0,
      STORE_INNER_LOOP_i_4_0_lpi_1_3_0_mx0w0, main_stage_v_1);
  assign nl_STORE_INNER_LOOP_acc_1_tmp = conv_u2u_4_5(STORE_INNER_LOOP_i_mux_nl)
      + 5'b00001;
  assign STORE_INNER_LOOP_acc_1_tmp = nl_STORE_INNER_LOOP_acc_1_tmp[4:0];
  assign exitL_exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_1 = exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_mx1
      | exit_STORE_BATCH_LOOP_lpi_1_dfm_3 | exitL_exit_STORE_BATCH_LOOP_sva;
  assign nl_STORE_BATCH_LOOP_acc_3_psp_sva_1 = (batch_lpi_1_dfm_mx1[27:0]) + conv_u2u_4_28(STORE_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_1);
  assign STORE_BATCH_LOOP_acc_3_psp_sva_1 = nl_STORE_BATCH_LOOP_acc_3_psp_sva_1[27:0];
  assign STORE_INNER_LOOP_mux_27_nl = MUX_s_1_2_2(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_2_1_1,
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_1, and_320_cse);
  assign lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_3_1_1 = (STORE_INNER_LOOP_mux_27_nl
      & (~ and_334_cse)) | STORE_INNER_LOOP_and_2_ssc_1;
  assign lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_3_0_1 = (and_320_cse & (~ STORE_INNER_LOOP_and_2_ssc_1))
      | and_334_cse;
  assign STORE_INNER_LOOP_and_2_ssc_1 = dma_write_ctrl_rsci_irdy_mxwt & STORE_INNER_LOOP_or_tmp_1;
  assign main_stage_en_4 = or_83_cse & (dma_write_ctrl_rsci_bawt | (~((~(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1
      | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1)) & main_stage_v_1))) & (plm_out_rsci_bawt
      | (~(exit_STORE_CTRL_LOOP_sva_st_1 & ((lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0
      & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1)) | (~(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1
      | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0))) & (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2)
      & main_stage_v_2))) & (dma_write_chnl_rsci_bawt | (~(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1
      & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0) & (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2)
      & main_stage_v_2))) & (done_rsci_bawt | (~(exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_3
      & main_stage_v_3)));
  assign or_14_cse = dma_write_ctrl_rsci_bawt | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1
      | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1;
  assign or_tmp_14 = exitL_exit_STORE_BATCH_LOOP_sva | exit_STORE_BATCH_LOOP_lpi_1_dfm_3;
  assign or_28_nl = plm_out_rsci_bawt | (~ exit_STORE_CTRL_LOOP_sva_st_1) | (~ main_stage_v_2)
      | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2;
  assign or_26_nl = dma_write_chnl_rsci_bawt | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0
      | (~ main_stage_v_2) | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2;
  assign mux_21_cse = MUX_s_1_2_2(or_28_nl, or_26_nl, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1);
  assign and_tmp_4 = ((~ main_stage_v_3) | (~ exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_3)
      | done_rsci_bawt) & mux_21_cse;
  assign or_tmp_23 = lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1 | dma_write_ctrl_rsci_bawt;
  assign or_tmp_116 = STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1;
  assign or_tmp_127 = STORE_BATCH_LOOP_if_acc_itm_32_1 | (~ and_tmp_4);
  assign nand_52_cse = ~((STORE_BATCH_LOOP_acc_2_tmp[4]) & (STORE_INNER_LOOP_acc_1_tmp[4])
      & and_tmp_4);
  assign and_dcpl_3 = conf_info_rsci_bawt & STORE_BATCH_LOOP_asn_itm;
  assign or_dcpl_2 = done_rsci_bawt | (~ exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_3);
  assign or_dcpl_3 = or_dcpl_2 | (~ main_stage_v_3);
  assign and_58_cse = (STORE_BATCH_LOOP_if_acc_itm_32_1 | (~ main_stage_en_4)) &
      mux_21_cse;
  assign and_63_cse = (~((STORE_BATCH_LOOP_acc_2_tmp[4]) & (STORE_INNER_LOOP_acc_1_tmp[4])
      & main_stage_en_4)) & mux_21_cse;
  assign and_tmp_72 = or_34_cse & conf_info_rsci_bawt & and_tmp_4;
  assign and_dcpl_9 = (~ conf_info_rsci_bawt) & STORE_BATCH_LOOP_asn_itm;
  assign and_dcpl_11 = (~ done_rsci_bawt) & exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_3
      & main_stage_v_3;
  assign or_201_nl = plm_out_rsci_bawt | (~ exit_STORE_CTRL_LOOP_sva_st_1) | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2;
  assign or_200_nl = dma_write_chnl_rsci_bawt | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0
      | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2;
  assign mux_tmp_139 = MUX_s_1_2_2(or_201_nl, or_200_nl, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1);
  assign nand_tmp_10 = ~(main_stage_v_2 & (~ mux_tmp_139));
  assign and_tmp_79 = or_34_cse & nand_tmp_10;
  assign or_dcpl_4 = (~ and_tmp_79) | and_dcpl_11;
  assign nor_nl = ~(plm_out_rsci_bawt | (~ exit_STORE_CTRL_LOOP_sva_st_1));
  assign nor_105_nl = ~(dma_write_chnl_rsci_bawt | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0);
  assign mux_78_nl = MUX_s_1_2_2(nor_nl, nor_105_nl, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1);
  assign and_dcpl_13 = mux_78_nl & (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2)
      & main_stage_v_2;
  assign or_213_nl = dma_write_ctrl_rsci_irdy_mxwt | (~(dma_write_ctrl_rsci_bawt
      & nand_tmp_10));
  assign mux_tmp_141 = MUX_s_1_2_2(or_213_nl, and_dcpl_13, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1);
  assign and_tmp_81 = or_14_cse & nand_tmp_10;
  assign or_tmp_189 = STORE_INNER_LOOP_or_tmp_1 | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_2_1_1;
  assign and_tmp_82 = or_tmp_23 & nand_tmp_10;
  assign or_tmp_191 = and_320_cse | (~ and_tmp_82);
  assign and_109_nl = exitL_exit_STORE_INNER_LOOP_lpi_1_dfm & nand_tmp_10;
  assign or_221_nl = or_tmp_189 | or_tmp_191;
  assign mux_152_nl = MUX_s_1_2_2(or_221_nl, and_dcpl_13, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_153_nl = MUX_s_1_2_2((~ mux_152_nl), and_tmp_81, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_tmp_145 = MUX_s_1_2_2(and_109_nl, mux_153_nl, main_stage_v_1);
  assign mux_155_nl = MUX_s_1_2_2(mux_tmp_145, and_tmp_79, or_tmp_14);
  assign and_dcpl_19 = mux_155_nl & or_dcpl_3;
  assign mux_156_nl = MUX_s_1_2_2(mux_tmp_145, and_tmp_79, exit_STORE_BATCH_LOOP_lpi_1_dfm_3);
  assign and_dcpl_23 = mux_156_nl & or_dcpl_3 & or_83_cse;
  assign or_tmp_201 = and_320_cse | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_2_1_1 |
      (~ and_125_cse);
  assign and_dcpl_26 = mux_tmp_139 & or_dcpl_3;
  assign and_dcpl_29 = done_rsci_bawt & exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_3 &
      main_stage_v_3;
  assign and_dcpl_30 = (~(mux_tmp_139 & main_stage_v_2 & exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_2))
      & and_dcpl_29;
  assign and_dcpl_31 = (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1) & main_stage_v_1;
  assign and_dcpl_34 = nand_tmp_10 & or_dcpl_3;
  assign and_dcpl_36 = lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1 & main_stage_v_2;
  assign or_dcpl_19 = STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 | (~ main_stage_v_1);
  assign and_dcpl_41 = ((~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1) | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_0
      | or_dcpl_19) & or_dcpl_3 & (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2)
      & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0) & dma_write_chnl_rsci_bawt
      & and_dcpl_36;
  assign and_dcpl_44 = or_dcpl_3 & (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2);
  assign and_dcpl_50 = and_dcpl_34 & dma_write_ctrl_rsci_bawt & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1)
      & and_dcpl_31;
  assign and_dcpl_55 = (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1) & main_stage_v_2;
  assign and_dcpl_60 = ((~ dma_write_ctrl_rsci_bawt) | (~ dma_write_ctrl_rsci_irdy_mxwt)
      | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1 | or_dcpl_19) & or_dcpl_3 & (~
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2) & exit_STORE_CTRL_LOOP_sva_st_1
      & plm_out_rsci_bawt & and_dcpl_55;
  assign and_dcpl_64 = and_tmp_79 & or_dcpl_3;
  assign and_dcpl_69 = and_dcpl_34 & (or_tmp_23 | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_dcpl_73 = ~(dma_write_ctrl_rsci_bawt | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1);
  assign or_dcpl_29 = and_dcpl_13 | and_dcpl_11;
  assign and_tmp_97 = and_320_cse & and_tmp_82;
  assign or_tmp_230 = lfst_exit_STORE_INNER_LOOP_lpi_1_0 | (~ lfst_exit_STORE_INNER_LOOP_lpi_1_1)
      | exitL_exit_STORE_INNER_LOOP_lpi_1_dfm | STORE_BATCH_LOOP_if_asn_sft_lpi_1;
  assign and_181_nl = or_tmp_230 & nand_tmp_10;
  assign mux_192_nl = MUX_s_1_2_2(and_tmp_82, and_tmp_97, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_2_1_1);
  assign mux_193_nl = MUX_s_1_2_2(mux_192_nl, (~ mux_tmp_141), STORE_INNER_LOOP_or_tmp_1);
  assign mux_194_nl = MUX_s_1_2_2(mux_193_nl, nand_tmp_10, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_195_nl = MUX_s_1_2_2(mux_194_nl, and_tmp_81, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_tmp_187 = MUX_s_1_2_2(and_181_nl, mux_195_nl, main_stage_v_1);
  assign mux_197_nl = MUX_s_1_2_2(mux_tmp_187, and_tmp_79, or_tmp_14);
  assign and_dcpl_76 = mux_197_nl & or_dcpl_3;
  assign or_tmp_231 = STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1;
  assign nor_77_nl = ~(or_tmp_230 | and_dcpl_13);
  assign and_303_nl = lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_2_1_1 & (~ or_tmp_191);
  assign and_188_nl = dma_write_ctrl_rsci_bawt & dma_write_ctrl_rsci_irdy_mxwt &
      nand_tmp_10;
  assign mux_199_nl = MUX_s_1_2_2(and_188_nl, nand_tmp_10, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1);
  assign mux_200_nl = MUX_s_1_2_2(and_303_nl, mux_199_nl, STORE_INNER_LOOP_or_tmp_1);
  assign nor_78_nl = ~(or_tmp_231 | (~ mux_200_nl));
  assign mux_201_nl = MUX_s_1_2_2(nor_77_nl, nor_78_nl, main_stage_v_1);
  assign and_dcpl_81 = mux_201_nl & or_dcpl_3;
  assign and_dcpl_82 = and_dcpl_81 & or_83_cse;
  assign or_dcpl_37 = STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 | (~ main_stage_v_1);
  assign nor_75_nl = ~(exitL_exit_STORE_INNER_LOOP_lpi_1_dfm | and_dcpl_13);
  assign mux_208_nl = MUX_s_1_2_2(and_tmp_97, and_tmp_82, or_tmp_189);
  assign mux_209_nl = MUX_s_1_2_2(mux_208_nl, nand_tmp_10, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign nor_76_nl = ~(STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 | (~ mux_209_nl));
  assign mux_210_nl = MUX_s_1_2_2(nor_75_nl, nor_76_nl, main_stage_v_1);
  assign and_dcpl_93 = mux_210_nl & or_dcpl_3;
  assign and_tmp_103 = or_tmp_23 & mux_21_cse;
  assign mux_216_nl = MUX_s_1_2_2(nor_62_cse, and_125_cse, exitL_exit_STORE_INNER_LOOP_lpi_1_dfm);
  assign mux_215_nl = MUX_s_1_2_2(mux_221_cse, mux_220_cse, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_217_nl = MUX_s_1_2_2(mux_216_nl, mux_215_nl, main_stage_v_1);
  assign mux_212_nl = MUX_s_1_2_2(and_214_cse, and_125_cse, or_dcpl_19);
  assign mux_218_nl = MUX_s_1_2_2(mux_217_nl, mux_212_nl, or_tmp_14);
  assign and_dcpl_96 = mux_218_nl & or_dcpl_3;
  assign or_tmp_252 = STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 | exit_STORE_BATCH_LOOP_lpi_1_dfm_3;
  assign or_tmp_258 = exit_STORE_BATCH_LOOP_lpi_1_dfm_3 | exitL_exit_STORE_INNER_LOOP_lpi_1_dfm;
  assign nor_68_cse = ~(STORE_BATCH_LOOP_if_acc_itm_32_1 | (~ mux_21_cse));
  assign and_301_cse = STORE_BATCH_LOOP_if_asn_sft_lpi_1 & mux_21_cse;
  assign nor_71_cse = ~((~ or_14_cse) | STORE_BATCH_LOOP_if_acc_itm_32_1 | (~ mux_21_cse));
  assign nor_69_nl = ~(and_320_cse | STORE_INNER_LOOP_or_tmp_1 | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_2_1_1
      | (~ or_tmp_23) | STORE_BATCH_LOOP_if_acc_itm_32_1 | (~ mux_21_cse));
  assign mux_226_cse = MUX_s_1_2_2(nor_69_nl, nor_68_cse, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_228_nl = MUX_s_1_2_2(and_301_cse, nor_68_cse, exitL_exit_STORE_INNER_LOOP_lpi_1_dfm);
  assign mux_227_nl = MUX_s_1_2_2(mux_226_cse, nor_71_cse, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_229_nl = MUX_s_1_2_2(mux_228_nl, mux_227_nl, main_stage_v_1);
  assign nor_72_nl = ~((~((~ main_stage_v_1) | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1
      | dma_write_ctrl_rsci_bawt | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1))
      | STORE_BATCH_LOOP_if_acc_itm_32_1 | (~ mux_21_cse));
  assign mux_230_nl = MUX_s_1_2_2(mux_229_nl, nor_72_nl, or_tmp_14);
  assign and_dcpl_101 = mux_230_nl & or_dcpl_3;
  assign mux_243_nl = MUX_s_1_2_2((~ STORE_BATCH_LOOP_if_asn_sft_lpi_1), STORE_BATCH_LOOP_if_acc_itm_32_1,
      exitL_exit_STORE_INNER_LOOP_lpi_1_dfm);
  assign or_371_nl = STORE_BATCH_LOOP_if_acc_itm_32_1 | (~(STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1
      | (~(or_tmp_189 | and_320_cse))));
  assign mux_244_nl = MUX_s_1_2_2(mux_243_nl, or_371_nl, main_stage_v_1);
  assign mux_245_itm = MUX_s_1_2_2(mux_244_nl, STORE_BATCH_LOOP_if_acc_itm_32_1,
      or_tmp_14);
  assign and_69_nl = ((~ lfst_exit_STORE_INNER_LOOP_lpi_1_1) | lfst_exit_STORE_INNER_LOOP_lpi_1_0
      | STORE_BATCH_LOOP_if_asn_sft_lpi_1 | (~ (STORE_BATCH_LOOP_acc_2_tmp[4])) |
      (~ (STORE_INNER_LOOP_acc_1_tmp[4])) | (~ main_stage_en_4)) & mux_21_cse;
  assign mux_122_nl = MUX_s_1_2_2(and_69_nl, and_58_cse, exitL_exit_STORE_INNER_LOOP_lpi_1_dfm);
  assign and_68_nl = or_tmp_23 & and_58_cse;
  assign and_67_nl = or_tmp_23 & and_63_cse;
  assign mux_117_nl = MUX_s_1_2_2(and_68_nl, and_67_nl, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_2_1_1);
  assign mux_118_nl = MUX_s_1_2_2(mux_117_nl, and_tmp_103, and_320_cse);
  assign and_65_nl = dma_write_ctrl_rsci_bawt & mux_21_cse;
  assign and_64_nl = dma_write_ctrl_rsci_bawt & and_63_cse;
  assign mux_115_nl = MUX_s_1_2_2(and_65_nl, and_64_nl, dma_write_ctrl_rsci_irdy_mxwt);
  assign mux_116_nl = MUX_s_1_2_2(mux_115_nl, and_63_cse, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1);
  assign mux_119_nl = MUX_s_1_2_2(mux_118_nl, mux_116_nl, STORE_INNER_LOOP_or_tmp_1);
  assign mux_120_nl = MUX_s_1_2_2(mux_119_nl, and_58_cse, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_60_nl = or_14_cse & and_58_cse;
  assign mux_121_nl = MUX_s_1_2_2(mux_120_nl, and_60_nl, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_123_cse = MUX_s_1_2_2(mux_122_nl, mux_121_nl, main_stage_v_1);
  assign and_59_cse = or_34_cse & and_58_cse;
  assign mux_124_nl = MUX_s_1_2_2(mux_123_cse, and_59_cse, or_tmp_14);
  assign and_244_cse = mux_124_nl & or_dcpl_3 & and_dcpl_3 & (fsm_output[1]);
  assign dma_write_ctrl_rsci_idat_31_4_mx0c1 = (and_dcpl_19 & or_83_cse & STORE_BATCH_LOOP_if_acc_itm_32_1
      & (fsm_output[1])) | (and_dcpl_23 & STORE_BATCH_LOOP_if_acc_itm_32_1 & (~ exitL_exit_STORE_BATCH_LOOP_sva));
  assign exit_STORE_BATCH_LOOP_lpi_1_dfm_3_mx0c1 = and_dcpl_82 & nor_90_cse;
  assign nor_53_nl = ~(exitL_exit_STORE_BATCH_LOOP_sva | exit_STORE_BATCH_LOOP_lpi_1_dfm_3
      | (~ (STORE_INNER_LOOP_acc_1_tmp[4])));
  assign mux_206_nl = MUX_s_1_2_2(and_tmp_79, mux_tmp_187, nor_53_nl);
  assign STORE_BATCH_LOOP_b_4_0_lpi_1_3_0_mx0c1 = mux_206_nl & or_dcpl_3 & or_83_cse;
  assign main_stage_v_1_mx0c1 = and_dcpl_69 & and_dcpl_9 & main_stage_v_1;
  assign mux_234_nl = MUX_s_1_2_2(and_301_cse, nor_68_cse, or_tmp_258);
  assign mux_233_nl = MUX_s_1_2_2(mux_226_cse, nor_71_cse, or_tmp_252);
  assign mux_235_nl = MUX_s_1_2_2(mux_234_nl, mux_233_nl, main_stage_v_1);
  assign lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1_mx0c1 = (and_dcpl_101 & or_83_cse
      & (fsm_output[1])) | (mux_235_nl & or_dcpl_3 & or_83_cse & (~ exitL_exit_STORE_BATCH_LOOP_sva));
  assign STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1 = (and_dcpl_19 & or_83_cse
      & (fsm_output[1])) | (and_dcpl_23 & (~ exitL_exit_STORE_BATCH_LOOP_sva));
  assign nor_67_nl = ~(or_14_cse | (~ mux_tmp_139));
  assign mux_236_nl = MUX_s_1_2_2(mux_tmp_139, nor_67_nl, main_stage_v_1);
  assign main_stage_v_2_mx0c1 = mux_236_nl & or_dcpl_3 & main_stage_v_2;
  assign exit_STORE_CTRL_LOOP_sva_st_1_mx0c1 = and_dcpl_34 & or_tmp_116 & main_stage_v_1;
  assign main_stage_v_3_mx0c1 = (~(mux_tmp_139 & main_stage_v_2)) & or_dcpl_2 & main_stage_v_3;
  assign exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_1_mx0c1 = and_dcpl_81 & nor_90_cse;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_iswt0 <= 1'b0;
      conf_info_rsci_irdy_core_psct <= 1'b0;
    end
    else if ( and_324_cse ) begin
      conf_info_rsci_iswt0 <= (~(and_244_cse | (mux_135_nl & or_dcpl_3 & and_dcpl_3
          & (~ exitL_exit_STORE_BATCH_LOOP_sva)))) | (fsm_output[0]);
      conf_info_rsci_irdy_core_psct <= ~ and_244_cse;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exitL_exit_STORE_BATCH_LOOP_sva <= 1'b1;
    end
    else if ( core_wen & (~(or_dcpl_4 | and_dcpl_9 | (fsm_output[0]))) ) begin
      exitL_exit_STORE_BATCH_LOOP_sva <= exit_STORE_BATCH_LOOP_lpi_1_dfm_3_mx1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_chnl_rsci_idat_31_0 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(and_dcpl_13 | and_dcpl_11 | (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1)
        | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_0 | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1
        | (~ main_stage_v_1))) ) begin
      dma_write_chnl_rsci_idat_31_0 <= MUX_v_32_16_2((STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0[31:0]),
          (STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0[63:32]), (STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0[95:64]),
          (STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0[127:96]), (STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0[159:128]),
          (STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0[191:160]), (STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0[223:192]),
          (STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0[255:224]), (STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0[287:256]),
          (STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0[319:288]), (STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0[351:320]),
          (STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0[383:352]), (STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0[415:384]),
          (STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0[447:416]), (STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0[479:448]),
          (STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0[511:480]), STORE_INNER_LOOP_i_4_0_lpi_1_3_0);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_ctrl_rsci_idat_31_4 <= 28'b0000000000000000000000000000;
    end
    else if ( core_wen & ((mux_151_nl & or_dcpl_3 & or_83_cse & nor_90_cse) | dma_write_ctrl_rsci_idat_31_4_mx0c1)
        ) begin
      dma_write_ctrl_rsci_idat_31_4 <= MUX_v_28_2_2(STORE_BATCH_LOOP_acc_3_psp_lpi_1,
          STORE_BATCH_LOOP_acc_3_psp_sva_1, dma_write_ctrl_rsci_idat_31_4_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_done_rsci_ivld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_26 & main_stage_v_2 & exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_2)
        | and_dcpl_30) ) begin
      reg_done_rsci_ivld_core_psct_cse <= ~ and_dcpl_30;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_dma_write_chnl_rsci_ivld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_34 & lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1
        & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_0) & and_dcpl_31) | and_dcpl_41)
        ) begin
      reg_dma_write_chnl_rsci_ivld_core_psct_cse <= ~ and_dcpl_41;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_dma_write_ctrl_rsci_ivld_core_psct_cse <= 1'b0;
      STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1 <= 512'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
      lfst_exit_STORE_INNER_LOOP_lpi_1_1 <= 1'b0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_0 <= 1'b0;
      STORE_BATCH_LOOP_if_asn_sft_lpi_1 <= 1'b0;
    end
    else if ( core_wen ) begin
      reg_dma_write_ctrl_rsci_ivld_core_psct_cse <= mux_165_nl & or_dcpl_3 & or_83_cse
          & (fsm_output[1]);
      STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1 <= STORE_BATCH_LOOP_if_1_plm_tmp_data_lpi_1_mx0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_1 <= lfst_exit_STORE_INNER_LOOP_lpi_1_1_mx0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_0 <= lfst_exit_STORE_INNER_LOOP_lpi_1_0_mx0;
      STORE_BATCH_LOOP_if_asn_sft_lpi_1 <= STORE_BATCH_LOOP_if_asn_sft_lpi_1_mx0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_plm_out_rsci_irdy_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_34 & dma_write_ctrl_rsci_bawt & dma_write_ctrl_rsci_irdy_mxwt
        & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1) & and_dcpl_31) | and_dcpl_60)
        ) begin
      reg_plm_out_rsci_irdy_core_psct_cse <= ~ and_dcpl_60;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_BATCH_LOOP_asn_itm <= 1'b1;
    end
    else if ( core_wen & ((main_stage_en_4 & (fsm_output[1])) | (main_stage_v_1 &
        main_stage_en_4)) ) begin
      STORE_BATCH_LOOP_asn_itm <= exit_STORE_BATCH_LOOP_lpi_1_dfm_3_mx1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_INNER_LOOP_i_4_0_lpi_1_3_0 <= 4'b0000;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1 <= 1'b0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0 <= 1'b0;
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2 <= 1'b0;
    end
    else if ( STORE_INNER_LOOP_i_and_cse ) begin
      STORE_INNER_LOOP_i_4_0_lpi_1_3_0 <= STORE_INNER_LOOP_i_4_0_lpi_1_3_0_mx0w0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1 <= lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0 <= lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_0;
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2 <= STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_76 & or_83_cse & (fsm_output[1])) | (mux_198_nl
        & or_dcpl_3 & or_83_cse & (~ exitL_exit_STORE_BATCH_LOOP_sva)) | exit_STORE_BATCH_LOOP_lpi_1_dfm_3_mx0c1)
        ) begin
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3 <= MUX_s_1_2_2(exit_STORE_BATCH_LOOP_lpi_1_dfm_4,
          STORE_INNER_LOOP_mux_29_nl, exit_STORE_BATCH_LOOP_lpi_1_dfm_3_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_BATCH_LOOP_acc_3_psp_lpi_1 <= 28'b0000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_205_nl) & nor_90_cse)) ) begin
      STORE_BATCH_LOOP_acc_3_psp_lpi_1 <= STORE_BATCH_LOOP_acc_3_psp_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_BATCH_LOOP_b_4_0_lpi_1_3_0 <= 4'b0000;
    end
    else if ( core_wen & ((and_dcpl_82 & (STORE_INNER_LOOP_acc_1_tmp[4]) & (~ exit_STORE_BATCH_LOOP_lpi_1_dfm_3)
        & (~ exitL_exit_STORE_BATCH_LOOP_sva)) | STORE_BATCH_LOOP_b_4_0_lpi_1_3_0_mx0c1)
        ) begin
      STORE_BATCH_LOOP_b_4_0_lpi_1_3_0 <= MUX_v_4_2_2((STORE_BATCH_LOOP_acc_2_tmp[3:0]),
          STORE_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_1, STORE_BATCH_LOOP_b_4_0_lpi_1_3_0_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      batch_lpi_1_dfm <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & exitL_exit_STORE_BATCH_LOOP_sva ) begin
      batch_lpi_1_dfm <= conf_info_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exitL_exit_STORE_INNER_LOOP_lpi_1_dfm <= 1'b0;
    end
    else if ( STORE_INNER_LOOP_and_9_cse ) begin
      exitL_exit_STORE_INNER_LOOP_lpi_1_dfm <= exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_mx1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_1 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_64 & or_83_cse & (fsm_output[1])) | main_stage_v_1_mx0c1)
        ) begin
      main_stage_v_1 <= ~ main_stage_v_1_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 <= 1'b0;
    end
    else if ( core_wen & (((~ main_stage_v_1) & and_dcpl_93 & nor_90_cse) | and_dcpl_19)
        ) begin
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 <= MUX_s_1_2_2(STORE_BATCH_LOOP_if_asn_sft_lpi_1,
          exit_STORE_BATCH_LOOP_lpi_1_dfm_4, and_dcpl_19);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_INNER_LOOP_or_tmp_1 <= 1'b0;
      STORE_INNER_LOOP_equal_tmp_1 <= 1'b0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_2_1_1 <= 1'b0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_1 <= 1'b0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_0 <= 1'b0;
    end
    else if ( STORE_INNER_LOOP_and_20_cse ) begin
      STORE_INNER_LOOP_or_tmp_1 <= (lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx1 &
          (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx1)) | (~(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx1
          | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx1));
      STORE_INNER_LOOP_equal_tmp_1 <= lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx0w0
          & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx0w0);
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_2_1_1 <= ~ (STORE_INNER_LOOP_acc_1_tmp[4]);
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_1 <= lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx0w0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_0 <= lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_INNER_LOOP_i_4_0_sva_1_1_3_0 <= 4'b0000;
    end
    else if ( core_wen & (~(or_dcpl_29 | (and_dcpl_73 & main_stage_v_1))) ) begin
      STORE_INNER_LOOP_i_4_0_sva_1_1_3_0 <= STORE_INNER_LOOP_acc_1_tmp[3:0];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_96 & or_83_cse & (fsm_output[1])) | (mux_224_nl
        & or_dcpl_3 & or_83_cse & (~ exitL_exit_STORE_BATCH_LOOP_sva)) | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1_mx0c1)
        ) begin
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1 <= MUX_s_1_2_2(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx0w0,
          lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_0 <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_96 | and_dcpl_101) ) begin
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_0 <= MUX_s_1_2_2(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx0w0,
          lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_0, and_dcpl_101);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_93 & or_83_cse & nor_90_cse) | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1)
        ) begin
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 <= MUX_s_1_2_2(STORE_BATCH_LOOP_if_asn_sft_lpi_1_mx0,
          exit_STORE_BATCH_LOOP_lpi_1_dfm_4, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_2 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_69 & main_stage_v_1) | main_stage_v_2_mx0c1)
        ) begin
      main_stage_v_2 <= ~ main_stage_v_2_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_STORE_CTRL_LOOP_sva_st_1 <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_50 | exit_STORE_CTRL_LOOP_sva_st_1_mx0c1) ) begin
      exit_STORE_CTRL_LOOP_sva_st_1 <= MUX_s_1_2_2(dma_write_ctrl_rsci_irdy_mxwt,
          exit_STORE_CTRL_LOOP_sva_st, exit_STORE_CTRL_LOOP_sva_st_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_BATCH_LOOP_if_and_itm_1 <= 1'b0;
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_2 <= 1'b0;
    end
    else if ( STORE_BATCH_LOOP_if_and_6_cse ) begin
      STORE_BATCH_LOOP_if_and_itm_1 <= dma_write_ctrl_rsci_irdy_mxwt & (~(STORE_INNER_LOOP_equal_tmp_1
          | and_320_cse | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1));
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_2 <= exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_3 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_26 & main_stage_v_2) | main_stage_v_3_mx0c1)
        ) begin
      main_stage_v_3 <= ~ main_stage_v_3_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_3 <= 1'b0;
    end
    else if ( core_wen & (~((~ mux_tmp_139) | and_dcpl_11 | (~ main_stage_v_2)))
        ) begin
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_3 <= exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_2;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_STORE_CTRL_LOOP_sva_st <= 1'b0;
    end
    else if ( STORE_INNER_LOOP_and_9_cse & (~(or_tmp_116 | (~ main_stage_v_1))) )
        begin
      exit_STORE_CTRL_LOOP_sva_st <= dma_write_ctrl_rsci_irdy_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1 <= 1'b0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_0 <= 1'b0;
    end
    else if ( STORE_INNER_LOOP_and_25_cse ) begin
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1 <= lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx0w0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_0 <= lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_1 <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_76 | exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_1_mx0c1)
        ) begin
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_1 <= MUX_s_1_2_2(exit_STORE_BATCH_LOOP_lpi_1_dfm_4,
          STORE_INNER_LOOP_mux_6_nl, exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_1_mx0c1);
    end
  end
  assign mux_135_nl = MUX_s_1_2_2(mux_123_cse, and_59_cse, exit_STORE_BATCH_LOOP_lpi_1_dfm_3);
  assign nor_79_nl = ~(lfst_exit_STORE_INNER_LOOP_lpi_1_1 | exitL_exit_STORE_INNER_LOOP_lpi_1_dfm
      | STORE_BATCH_LOOP_if_asn_sft_lpi_1 | and_dcpl_13);
  assign nor_80_nl = ~(STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1
      | (~ STORE_INNER_LOOP_or_tmp_1) | mux_tmp_141);
  assign mux_151_nl = MUX_s_1_2_2(nor_79_nl, nor_80_nl, main_stage_v_1);
  assign nor_64_nl = ~(lfst_exit_STORE_INNER_LOOP_lpi_1_1 | STORE_BATCH_LOOP_if_asn_sft_lpi_1
      | (~ mux_21_cse));
  assign mux_163_nl = MUX_s_1_2_2(nor_64_nl, and_125_cse, exitL_exit_STORE_INNER_LOOP_lpi_1_dfm);
  assign or_231_nl = dma_write_ctrl_rsci_irdy_mxwt | (~ mux_21_cse);
  assign mux_159_nl = MUX_s_1_2_2(or_tmp_201, or_231_nl, STORE_INNER_LOOP_or_tmp_1);
  assign and_323_nl = dma_write_ctrl_rsci_bawt & (~ mux_159_nl);
  assign mux_158_nl = MUX_s_1_2_2((~ or_tmp_201), mux_21_cse, STORE_INNER_LOOP_or_tmp_1);
  assign mux_160_nl = MUX_s_1_2_2(and_323_nl, mux_158_nl, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1);
  assign mux_161_nl = MUX_s_1_2_2(mux_160_nl, and_125_cse, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_117_nl = or_14_cse & STORE_BATCH_LOOP_if_acc_itm_32_1 & mux_21_cse;
  assign mux_162_nl = MUX_s_1_2_2(mux_161_nl, and_117_nl, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_164_nl = MUX_s_1_2_2(mux_163_nl, mux_162_nl, main_stage_v_1);
  assign and_116_nl = or_34_cse & STORE_BATCH_LOOP_if_acc_itm_32_1 & mux_21_cse;
  assign mux_165_nl = MUX_s_1_2_2(mux_164_nl, and_116_nl, or_tmp_14);
  assign STORE_INNER_LOOP_mux_29_nl = MUX_s_1_2_2(exit_STORE_BATCH_LOOP_lpi_1_dfm_4,
      (STORE_BATCH_LOOP_acc_2_tmp[4]), STORE_INNER_LOOP_acc_1_tmp[4]);
  assign mux_198_nl = MUX_s_1_2_2(mux_tmp_187, and_tmp_79, exit_STORE_BATCH_LOOP_lpi_1_dfm_3);
  assign or_293_nl = or_tmp_231 | (~ STORE_INNER_LOOP_or_tmp_1);
  assign mux_205_nl = MUX_s_1_2_2(exitL_exit_STORE_INNER_LOOP_lpi_1_dfm, or_293_nl,
      main_stage_v_1);
  assign mux_223_nl = MUX_s_1_2_2(nor_62_cse, and_125_cse, or_tmp_258);
  assign mux_222_nl = MUX_s_1_2_2(mux_221_cse, mux_220_cse, or_tmp_252);
  assign mux_224_nl = MUX_s_1_2_2(mux_223_nl, mux_222_nl, main_stage_v_1);
  assign STORE_INNER_LOOP_mux_6_nl = MUX_s_1_2_2(exit_STORE_BATCH_LOOP_lpi_1_dfm_4,
      (STORE_BATCH_LOOP_acc_2_tmp[4]), STORE_INNER_LOOP_acc_1_tmp[4]);

  function automatic [3:0] MUX1HOT_v_4_3_2;
    input [3:0] input_2;
    input [3:0] input_1;
    input [3:0] input_0;
    input [2:0] sel;
    reg [3:0] result;
  begin
    result = input_0 & {4{sel[0]}};
    result = result | ( input_1 & {4{sel[1]}});
    result = result | ( input_2 & {4{sel[2]}});
    MUX1HOT_v_4_3_2 = result;
  end
  endfunction


  function automatic [0:0] MUX_s_1_2_2;
    input [0:0] input_0;
    input [0:0] input_1;
    input [0:0] sel;
    reg [0:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function automatic [27:0] MUX_v_28_2_2;
    input [27:0] input_0;
    input [27:0] input_1;
    input [0:0] sel;
    reg [27:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_28_2_2 = result;
  end
  endfunction


  function automatic [31:0] MUX_v_32_16_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [31:0] input_2;
    input [31:0] input_3;
    input [31:0] input_4;
    input [31:0] input_5;
    input [31:0] input_6;
    input [31:0] input_7;
    input [31:0] input_8;
    input [31:0] input_9;
    input [31:0] input_10;
    input [31:0] input_11;
    input [31:0] input_12;
    input [31:0] input_13;
    input [31:0] input_14;
    input [31:0] input_15;
    input [3:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      4'b0000 : begin
        result = input_0;
      end
      4'b0001 : begin
        result = input_1;
      end
      4'b0010 : begin
        result = input_2;
      end
      4'b0011 : begin
        result = input_3;
      end
      4'b0100 : begin
        result = input_4;
      end
      4'b0101 : begin
        result = input_5;
      end
      4'b0110 : begin
        result = input_6;
      end
      4'b0111 : begin
        result = input_7;
      end
      4'b1000 : begin
        result = input_8;
      end
      4'b1001 : begin
        result = input_9;
      end
      4'b1010 : begin
        result = input_10;
      end
      4'b1011 : begin
        result = input_11;
      end
      4'b1100 : begin
        result = input_12;
      end
      4'b1101 : begin
        result = input_13;
      end
      4'b1110 : begin
        result = input_14;
      end
      default : begin
        result = input_15;
      end
    endcase
    MUX_v_32_16_2 = result;
  end
  endfunction


  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [0:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction


  function automatic [3:0] MUX_v_4_2_2;
    input [3:0] input_0;
    input [3:0] input_1;
    input [0:0] sel;
    reg [3:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_4_2_2 = result;
  end
  endfunction


  function automatic [511:0] MUX_v_512_2_2;
    input [511:0] input_0;
    input [511:0] input_1;
    input [0:0] sel;
    reg [511:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_512_2_2 = result;
  end
  endfunction


  function automatic [0:0] readslicef_33_1_32;
    input [32:0] vector;
    reg [32:0] tmp;
  begin
    tmp = vector >> 32;
    readslicef_33_1_32 = tmp[0:0];
  end
  endfunction


  function automatic [3:0] signext_4_1;
    input [0:0] vector;
  begin
    signext_4_1= {{3{vector[0]}}, vector};
  end
  endfunction


  function automatic [4:0] conv_u2u_4_5 ;
    input [3:0]  vector ;
  begin
    conv_u2u_4_5 = {1'b0, vector};
  end
  endfunction


  function automatic [27:0] conv_u2u_4_28 ;
    input [3:0]  vector ;
  begin
    conv_u2u_4_28 = {{24{1'b0}}, vector};
  end
  endfunction


  function automatic [32:0] conv_u2u_32_33 ;
    input [31:0]  vector ;
  begin
    conv_u2u_32_33 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core (
  clk, rst, acc_done_rsc_vld, config_done_cns_rdy, config_done_cns_vld, load_done_cns_rdy,
      load_done_cns_vld, compute_done_cns_rdy, compute_done_cns_vld, store_done_cns_rdy,
      store_done_cns_vld
);
  input clk;
  input rst;
  output acc_done_rsc_vld;
  output config_done_cns_rdy;
  input config_done_cns_vld;
  output load_done_cns_rdy;
  input load_done_cns_vld;
  output compute_done_cns_rdy;
  input compute_done_cns_vld;
  output store_done_cns_rdy;
  input store_done_cns_vld;



  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core softmax_cxx_catapult_core_core_inst
      (
      .clk(clk),
      .rst(rst),
      .acc_done_rsc_vld(acc_done_rsc_vld),
      .config_done_cns_rdy(config_done_cns_rdy),
      .config_done_cns_vld(config_done_cns_vld),
      .load_done_cns_rdy(load_done_cns_rdy),
      .load_done_cns_vld(load_done_cns_vld),
      .compute_done_cns_rdy(compute_done_cns_rdy),
      .compute_done_cns_vld(compute_done_cns_vld),
      .store_done_cns_rdy(store_done_cns_rdy),
      .store_done_cns_vld(store_done_cns_vld)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_config
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_config (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, plm_conf_load_rsc_dat,
      plm_conf_load_rsc_vld, plm_conf_load_rsc_rdy, plm_conf_compute_rsc_dat, plm_conf_compute_rsc_vld,
      plm_conf_compute_rsc_rdy, plm_conf_store_rsc_dat, plm_conf_store_rsc_vld, plm_conf_store_rsc_rdy,
      done_rsc_rdy, done_rsc_vld
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  output [31:0] plm_conf_load_rsc_dat;
  output plm_conf_load_rsc_vld;
  input plm_conf_load_rsc_rdy;
  output [31:0] plm_conf_compute_rsc_dat;
  output plm_conf_compute_rsc_vld;
  input plm_conf_compute_rsc_rdy;
  output [31:0] plm_conf_store_rsc_dat;
  output plm_conf_store_rsc_vld;
  input plm_conf_store_rsc_rdy;
  input done_rsc_rdy;
  output done_rsc_vld;



  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_config_core config_core_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .plm_conf_load_rsc_dat(plm_conf_load_rsc_dat),
      .plm_conf_load_rsc_vld(plm_conf_load_rsc_vld),
      .plm_conf_load_rsc_rdy(plm_conf_load_rsc_rdy),
      .plm_conf_compute_rsc_dat(plm_conf_compute_rsc_dat),
      .plm_conf_compute_rsc_vld(plm_conf_compute_rsc_vld),
      .plm_conf_compute_rsc_rdy(plm_conf_compute_rsc_rdy),
      .plm_conf_store_rsc_dat(plm_conf_store_rsc_dat),
      .plm_conf_store_rsc_vld(plm_conf_store_rsc_vld),
      .plm_conf_store_rsc_rdy(plm_conf_store_rsc_rdy),
      .done_rsc_rdy(done_rsc_rdy),
      .done_rsc_vld(done_rsc_vld)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_load
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_load (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, plm_in_rsc_dat,
      plm_in_rsc_vld, plm_in_rsc_rdy, dma_read_ctrl_rsc_dat, dma_read_ctrl_rsc_vld,
      dma_read_ctrl_rsc_rdy, dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy,
      done_rsc_rdy, done_rsc_vld
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  output [511:0] plm_in_rsc_dat;
  output plm_in_rsc_vld;
  input plm_in_rsc_rdy;
  output [66:0] dma_read_ctrl_rsc_dat;
  output dma_read_ctrl_rsc_vld;
  input dma_read_ctrl_rsc_rdy;
  input [63:0] dma_read_chnl_rsc_dat;
  input dma_read_chnl_rsc_vld;
  output dma_read_chnl_rsc_rdy;
  input done_rsc_rdy;
  output done_rsc_vld;



  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_load_core load_core_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .plm_in_rsc_dat(plm_in_rsc_dat),
      .plm_in_rsc_vld(plm_in_rsc_vld),
      .plm_in_rsc_rdy(plm_in_rsc_rdy),
      .dma_read_ctrl_rsc_dat(dma_read_ctrl_rsc_dat),
      .dma_read_ctrl_rsc_vld(dma_read_ctrl_rsc_vld),
      .dma_read_ctrl_rsc_rdy(dma_read_ctrl_rsc_rdy),
      .dma_read_chnl_rsc_dat(dma_read_chnl_rsc_dat),
      .dma_read_chnl_rsc_vld(dma_read_chnl_rsc_vld),
      .dma_read_chnl_rsc_rdy(dma_read_chnl_rsc_rdy),
      .done_rsc_rdy(done_rsc_rdy),
      .done_rsc_vld(done_rsc_vld)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_compute
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_compute (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, plm_in_rsc_dat,
      plm_in_rsc_vld, plm_in_rsc_rdy, plm_out_rsc_dat, plm_out_rsc_vld, plm_out_rsc_rdy,
      done_rsc_rdy, done_rsc_vld
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  input [511:0] plm_in_rsc_dat;
  input plm_in_rsc_vld;
  output plm_in_rsc_rdy;
  output [511:0] plm_out_rsc_dat;
  output plm_out_rsc_vld;
  input plm_out_rsc_rdy;
  input done_rsc_rdy;
  output done_rsc_vld;


  // Interconnect Declarations
  wire [66:0] CALC_SOFTMAX_LOOP_mul_cmp_a;
  wire [90:0] CALC_SOFTMAX_LOOP_mul_cmp_b;
  wire CALC_SOFTMAX_LOOP_mul_cmp_en;
  wire [91:0] CALC_SOFTMAX_LOOP_mul_cmp_z;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_mgc_mul_pipe #(.width_a(32'sd67),
  .signd_a(32'sd0),
  .width_b(32'sd91),
  .signd_b(32'sd0),
  .width_z(32'sd92),
  .clock_edge(32'sd1),
  .enable_active(32'sd1),
  .a_rst_active(32'sd0),
  .s_rst_active(32'sd0),
  .stages(32'sd11),
  .n_inreg(32'sd2)) CALC_SOFTMAX_LOOP_mul_cmp (
      .a(CALC_SOFTMAX_LOOP_mul_cmp_a),
      .b(CALC_SOFTMAX_LOOP_mul_cmp_b),
      .clk(clk),
      .en(CALC_SOFTMAX_LOOP_mul_cmp_en),
      .a_rst(1'b1),
      .s_rst(rst),
      .z(CALC_SOFTMAX_LOOP_mul_cmp_z)
    );
  esp_acc_softmax_cxx_catapult_compute_core compute_core_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .plm_in_rsc_dat(plm_in_rsc_dat),
      .plm_in_rsc_vld(plm_in_rsc_vld),
      .plm_in_rsc_rdy(plm_in_rsc_rdy),
      .plm_out_rsc_dat(plm_out_rsc_dat),
      .plm_out_rsc_vld(plm_out_rsc_vld),
      .plm_out_rsc_rdy(plm_out_rsc_rdy),
      .done_rsc_rdy(done_rsc_rdy),
      .done_rsc_vld(done_rsc_vld),
      .CALC_SOFTMAX_LOOP_mul_cmp_a(CALC_SOFTMAX_LOOP_mul_cmp_a),
      .CALC_SOFTMAX_LOOP_mul_cmp_b(CALC_SOFTMAX_LOOP_mul_cmp_b),
      .CALC_SOFTMAX_LOOP_mul_cmp_en(CALC_SOFTMAX_LOOP_mul_cmp_en),
      .CALC_SOFTMAX_LOOP_mul_cmp_z(CALC_SOFTMAX_LOOP_mul_cmp_z)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_store
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_store (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, plm_out_rsc_dat,
      plm_out_rsc_vld, plm_out_rsc_rdy, dma_write_ctrl_rsc_dat, dma_write_ctrl_rsc_vld,
      dma_write_ctrl_rsc_rdy, dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy,
      done_rsc_rdy, done_rsc_vld
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  input [511:0] plm_out_rsc_dat;
  input plm_out_rsc_vld;
  output plm_out_rsc_rdy;
  output [66:0] dma_write_ctrl_rsc_dat;
  output dma_write_ctrl_rsc_vld;
  input dma_write_ctrl_rsc_rdy;
  output [63:0] dma_write_chnl_rsc_dat;
  output dma_write_chnl_rsc_vld;
  input dma_write_chnl_rsc_rdy;
  input done_rsc_rdy;
  output done_rsc_vld;



  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_store_core store_core_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .plm_out_rsc_dat(plm_out_rsc_dat),
      .plm_out_rsc_vld(plm_out_rsc_vld),
      .plm_out_rsc_rdy(plm_out_rsc_rdy),
      .dma_write_ctrl_rsc_dat(dma_write_ctrl_rsc_dat),
      .dma_write_ctrl_rsc_vld(dma_write_ctrl_rsc_vld),
      .dma_write_ctrl_rsc_rdy(dma_write_ctrl_rsc_rdy),
      .dma_write_chnl_rsc_dat(dma_write_chnl_rsc_dat),
      .dma_write_chnl_rsc_vld(dma_write_chnl_rsc_vld),
      .dma_write_chnl_rsc_rdy(dma_write_chnl_rsc_rdy),
      .done_rsc_rdy(done_rsc_rdy),
      .done_rsc_vld(done_rsc_vld)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_struct
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_struct (
  clk, rst, conf_info_rsc_dat_batch, conf_info_rsc_vld, conf_info_rsc_rdy, dma_read_ctrl_rsc_dat_size,
      dma_read_ctrl_rsc_dat_length, dma_read_ctrl_rsc_dat_index, dma_read_ctrl_rsc_vld,
      dma_read_ctrl_rsc_rdy, dma_write_ctrl_rsc_dat_size, dma_write_ctrl_rsc_dat_length,
      dma_write_ctrl_rsc_dat_index, dma_write_ctrl_rsc_vld, dma_write_ctrl_rsc_rdy,
      dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy, dma_write_chnl_rsc_dat,
      dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy, acc_done_rsc_vld
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat_batch;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  output [2:0] dma_read_ctrl_rsc_dat_size;
  output [31:0] dma_read_ctrl_rsc_dat_length;
  output [31:0] dma_read_ctrl_rsc_dat_index;
  output dma_read_ctrl_rsc_vld;
  input dma_read_ctrl_rsc_rdy;
  output [2:0] dma_write_ctrl_rsc_dat_size;
  output [31:0] dma_write_ctrl_rsc_dat_length;
  output [31:0] dma_write_ctrl_rsc_dat_index;
  output dma_write_ctrl_rsc_vld;
  input dma_write_ctrl_rsc_rdy;
  input [63:0] dma_read_chnl_rsc_dat;
  input dma_read_chnl_rsc_vld;
  output dma_read_chnl_rsc_rdy;
  output [63:0] dma_write_chnl_rsc_dat;
  output dma_write_chnl_rsc_vld;
  input dma_write_chnl_rsc_rdy;
  output acc_done_rsc_vld;


  // Interconnect Declarations
  wire [31:0] plm_conf_load_rsc_dat_nconfig_inst;
  wire plm_conf_load_rsc_rdy_nconfig_inst;
  wire [31:0] plm_conf_compute_rsc_dat_nconfig_inst;
  wire plm_conf_compute_rsc_rdy_nconfig_inst;
  wire [31:0] plm_conf_store_rsc_dat_nconfig_inst;
  wire plm_conf_store_rsc_rdy_nconfig_inst;
  wire done_rsc_rdy_nconfig_inst;
  wire [31:0] conf_info_rsc_dat_nload_inst;
  wire conf_info_rsc_vld_nload_inst;
  wire [511:0] plm_in_rsc_dat_nload_inst;
  wire plm_in_rsc_rdy_nload_inst;
  wire [66:0] dma_read_ctrl_rsc_dat_nload_inst;
  wire done_rsc_rdy_nload_inst;
  wire [31:0] conf_info_rsc_dat_ncompute_inst;
  wire conf_info_rsc_vld_ncompute_inst;
  wire [511:0] plm_in_rsc_dat_ncompute_inst;
  wire plm_in_rsc_vld_ncompute_inst;
  wire [511:0] plm_out_rsc_dat_ncompute_inst;
  wire plm_out_rsc_rdy_ncompute_inst;
  wire done_rsc_rdy_ncompute_inst;
  wire [31:0] conf_info_rsc_dat_nstore_inst;
  wire conf_info_rsc_vld_nstore_inst;
  wire [511:0] plm_out_rsc_dat_nstore_inst;
  wire plm_out_rsc_vld_nstore_inst;
  wire [66:0] dma_write_ctrl_rsc_dat_nstore_inst;
  wire [63:0] dma_write_chnl_rsc_dat_nstore_inst;
  wire done_rsc_rdy_nstore_inst;
  wire config_done_cns_vld_nsoftmax_cxx_catapult_core_inst;
  wire load_done_cns_vld_nsoftmax_cxx_catapult_core_inst;
  wire compute_done_cns_vld_nsoftmax_cxx_catapult_core_inst;
  wire store_done_cns_vld_nsoftmax_cxx_catapult_core_inst;
  wire conf_info_rsc_rdy_nconfig_inst_bud;
  wire plm_conf_load_rsc_vld_nconfig_inst_bud;
  wire conf_info_rsc_rdy_nload_inst_bud;
  wire plm_conf_compute_rsc_vld_nconfig_inst_bud;
  wire conf_info_rsc_rdy_ncompute_inst_bud;
  wire plm_conf_store_rsc_vld_nconfig_inst_bud;
  wire conf_info_rsc_rdy_nstore_inst_bud;
  wire done_rsc_vld_nconfig_inst_bud;
  wire config_done_cns_rdy_nsoftmax_cxx_catapult_core_inst_bud;
  wire plm_in_rsc_vld_nload_inst_bud;
  wire plm_in_rsc_rdy_ncompute_inst_bud;
  wire dma_read_ctrl_rsc_vld_nload_inst_bud;
  wire dma_read_chnl_rsc_rdy_nload_inst_bud;
  wire done_rsc_vld_nload_inst_bud;
  wire load_done_cns_rdy_nsoftmax_cxx_catapult_core_inst_bud;
  wire plm_out_rsc_vld_ncompute_inst_bud;
  wire plm_out_rsc_rdy_nstore_inst_bud;
  wire done_rsc_vld_ncompute_inst_bud;
  wire compute_done_cns_rdy_nsoftmax_cxx_catapult_core_inst_bud;
  wire dma_write_ctrl_rsc_vld_nstore_inst_bud;
  wire dma_write_chnl_rsc_vld_nstore_inst_bud;
  wire done_rsc_vld_nstore_inst_bud;
  wire store_done_cns_rdy_nsoftmax_cxx_catapult_core_inst_bud;
  wire acc_done_rsc_vld_nsoftmax_cxx_catapult_core_inst_bud;
  wire plm_conf_load_unc_2;
  wire plm_conf_load_idle;
  wire plm_conf_compute_unc_2;
  wire plm_conf_compute_idle;
  wire plm_conf_store_unc_2;
  wire plm_conf_store_idle;
  wire plm_in_unc_2;
  wire plm_in_idle;
  wire plm_out_unc_2;
  wire plm_out_idle;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_pipe_v5 #(.rscid(32'sd37),
  .width(32'sd32),
  .sz_width(32'sd1),
  .fifo_sz(32'sd3),
  .log2_sz(32'sd2),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_conf_load_cns_pipe (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .din_rdy(plm_conf_load_rsc_rdy_nconfig_inst),
      .din_vld(plm_conf_load_rsc_vld_nconfig_inst_bud),
      .din(plm_conf_load_rsc_dat_nconfig_inst),
      .dout_rdy(conf_info_rsc_rdy_nload_inst_bud),
      .dout_vld(conf_info_rsc_vld_nload_inst),
      .dout(conf_info_rsc_dat_nload_inst),
      .sz(plm_conf_load_unc_2),
      .sz_req(1'b0),
      .is_idle(plm_conf_load_idle)
    );
  esp_acc_softmax_cxx_catapult_ccs_pipe_v5 #(.rscid(32'sd38),
  .width(32'sd32),
  .sz_width(32'sd1),
  .fifo_sz(32'sd21),
  .log2_sz(32'sd5),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_conf_compute_cns_pipe (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .din_rdy(plm_conf_compute_rsc_rdy_nconfig_inst),
      .din_vld(plm_conf_compute_rsc_vld_nconfig_inst_bud),
      .din(plm_conf_compute_rsc_dat_nconfig_inst),
      .dout_rdy(conf_info_rsc_rdy_ncompute_inst_bud),
      .dout_vld(conf_info_rsc_vld_ncompute_inst),
      .dout(conf_info_rsc_dat_ncompute_inst),
      .sz(plm_conf_compute_unc_2),
      .sz_req(1'b0),
      .is_idle(plm_conf_compute_idle)
    );
  esp_acc_softmax_cxx_catapult_ccs_pipe_v5 #(.rscid(32'sd39),
  .width(32'sd32),
  .sz_width(32'sd1),
  .fifo_sz(32'sd3),
  .log2_sz(32'sd2),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_conf_store_cns_pipe (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .din_rdy(plm_conf_store_rsc_rdy_nconfig_inst),
      .din_vld(plm_conf_store_rsc_vld_nconfig_inst_bud),
      .din(plm_conf_store_rsc_dat_nconfig_inst),
      .dout_rdy(conf_info_rsc_rdy_nstore_inst_bud),
      .dout_vld(conf_info_rsc_vld_nstore_inst),
      .dout(conf_info_rsc_dat_nstore_inst),
      .sz(plm_conf_store_unc_2),
      .sz_req(1'b0),
      .is_idle(plm_conf_store_idle)
    );
  esp_acc_softmax_cxx_catapult_ccs_sync_pipe_v1 #(.rscid(32'sd40)) config_done_cns_pipe
      (
      .dout_rdy(done_rsc_vld_nconfig_inst_bud),
      .dout_vld(done_rsc_rdy_nconfig_inst),
      .din_vld(config_done_cns_rdy_nsoftmax_cxx_catapult_core_inst_bud),
      .din_rdy(config_done_cns_vld_nsoftmax_cxx_catapult_core_inst)
    );
  esp_acc_softmax_cxx_catapult_ccs_pipe_v5 #(.rscid(32'sd35),
  .width(32'sd512),
  .sz_width(32'sd1),
  .fifo_sz(32'sd21),
  .log2_sz(32'sd5),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_in_cns_pipe (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .din_rdy(plm_in_rsc_rdy_nload_inst),
      .din_vld(plm_in_rsc_vld_nload_inst_bud),
      .din(plm_in_rsc_dat_nload_inst),
      .dout_rdy(plm_in_rsc_rdy_ncompute_inst_bud),
      .dout_vld(plm_in_rsc_vld_ncompute_inst),
      .dout(plm_in_rsc_dat_ncompute_inst),
      .sz(plm_in_unc_2),
      .sz_req(1'b0),
      .is_idle(plm_in_idle)
    );
  esp_acc_softmax_cxx_catapult_ccs_sync_pipe_v1 #(.rscid(32'sd41)) load_done_cns_pipe
      (
      .dout_rdy(done_rsc_vld_nload_inst_bud),
      .dout_vld(done_rsc_rdy_nload_inst),
      .din_vld(load_done_cns_rdy_nsoftmax_cxx_catapult_core_inst_bud),
      .din_rdy(load_done_cns_vld_nsoftmax_cxx_catapult_core_inst)
    );
  esp_acc_softmax_cxx_catapult_ccs_pipe_v5 #(.rscid(32'sd36),
  .width(32'sd512),
  .sz_width(32'sd1),
  .fifo_sz(32'sd3),
  .log2_sz(32'sd2),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_out_cns_pipe (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .din_rdy(plm_out_rsc_rdy_ncompute_inst),
      .din_vld(plm_out_rsc_vld_ncompute_inst_bud),
      .din(plm_out_rsc_dat_ncompute_inst),
      .dout_rdy(plm_out_rsc_rdy_nstore_inst_bud),
      .dout_vld(plm_out_rsc_vld_nstore_inst),
      .dout(plm_out_rsc_dat_nstore_inst),
      .sz(plm_out_unc_2),
      .sz_req(1'b0),
      .is_idle(plm_out_idle)
    );
  esp_acc_softmax_cxx_catapult_ccs_sync_pipe_v1 #(.rscid(32'sd42)) compute_done_cns_pipe
      (
      .dout_rdy(done_rsc_vld_ncompute_inst_bud),
      .dout_vld(done_rsc_rdy_ncompute_inst),
      .din_vld(compute_done_cns_rdy_nsoftmax_cxx_catapult_core_inst_bud),
      .din_rdy(compute_done_cns_vld_nsoftmax_cxx_catapult_core_inst)
    );
  esp_acc_softmax_cxx_catapult_ccs_sync_pipe_v1 #(.rscid(32'sd43)) store_done_cns_pipe
      (
      .dout_rdy(done_rsc_vld_nstore_inst_bud),
      .dout_vld(done_rsc_rdy_nstore_inst),
      .din_vld(store_done_cns_rdy_nsoftmax_cxx_catapult_core_inst_bud),
      .din_rdy(store_done_cns_vld_nsoftmax_cxx_catapult_core_inst)
    );
  esp_acc_softmax_cxx_catapult_config config_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat_batch),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy_nconfig_inst_bud),
      .plm_conf_load_rsc_dat(plm_conf_load_rsc_dat_nconfig_inst),
      .plm_conf_load_rsc_vld(plm_conf_load_rsc_vld_nconfig_inst_bud),
      .plm_conf_load_rsc_rdy(plm_conf_load_rsc_rdy_nconfig_inst),
      .plm_conf_compute_rsc_dat(plm_conf_compute_rsc_dat_nconfig_inst),
      .plm_conf_compute_rsc_vld(plm_conf_compute_rsc_vld_nconfig_inst_bud),
      .plm_conf_compute_rsc_rdy(plm_conf_compute_rsc_rdy_nconfig_inst),
      .plm_conf_store_rsc_dat(plm_conf_store_rsc_dat_nconfig_inst),
      .plm_conf_store_rsc_vld(plm_conf_store_rsc_vld_nconfig_inst_bud),
      .plm_conf_store_rsc_rdy(plm_conf_store_rsc_rdy_nconfig_inst),
      .done_rsc_rdy(done_rsc_rdy_nconfig_inst),
      .done_rsc_vld(done_rsc_vld_nconfig_inst_bud)
    );
  esp_acc_softmax_cxx_catapult_load load_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat_nload_inst),
      .conf_info_rsc_vld(conf_info_rsc_vld_nload_inst),
      .conf_info_rsc_rdy(conf_info_rsc_rdy_nload_inst_bud),
      .plm_in_rsc_dat(plm_in_rsc_dat_nload_inst),
      .plm_in_rsc_vld(plm_in_rsc_vld_nload_inst_bud),
      .plm_in_rsc_rdy(plm_in_rsc_rdy_nload_inst),
      .dma_read_ctrl_rsc_dat(dma_read_ctrl_rsc_dat_nload_inst),
      .dma_read_ctrl_rsc_vld(dma_read_ctrl_rsc_vld_nload_inst_bud),
      .dma_read_ctrl_rsc_rdy(dma_read_ctrl_rsc_rdy),
      .dma_read_chnl_rsc_dat(dma_read_chnl_rsc_dat),
      .dma_read_chnl_rsc_vld(dma_read_chnl_rsc_vld),
      .dma_read_chnl_rsc_rdy(dma_read_chnl_rsc_rdy_nload_inst_bud),
      .done_rsc_rdy(done_rsc_rdy_nload_inst),
      .done_rsc_vld(done_rsc_vld_nload_inst_bud)
    );
  esp_acc_softmax_cxx_catapult_compute compute_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat_ncompute_inst),
      .conf_info_rsc_vld(conf_info_rsc_vld_ncompute_inst),
      .conf_info_rsc_rdy(conf_info_rsc_rdy_ncompute_inst_bud),
      .plm_in_rsc_dat(plm_in_rsc_dat_ncompute_inst),
      .plm_in_rsc_vld(plm_in_rsc_vld_ncompute_inst),
      .plm_in_rsc_rdy(plm_in_rsc_rdy_ncompute_inst_bud),
      .plm_out_rsc_dat(plm_out_rsc_dat_ncompute_inst),
      .plm_out_rsc_vld(plm_out_rsc_vld_ncompute_inst_bud),
      .plm_out_rsc_rdy(plm_out_rsc_rdy_ncompute_inst),
      .done_rsc_rdy(done_rsc_rdy_ncompute_inst),
      .done_rsc_vld(done_rsc_vld_ncompute_inst_bud)
    );
  esp_acc_softmax_cxx_catapult_store store_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat_nstore_inst),
      .conf_info_rsc_vld(conf_info_rsc_vld_nstore_inst),
      .conf_info_rsc_rdy(conf_info_rsc_rdy_nstore_inst_bud),
      .plm_out_rsc_dat(plm_out_rsc_dat_nstore_inst),
      .plm_out_rsc_vld(plm_out_rsc_vld_nstore_inst),
      .plm_out_rsc_rdy(plm_out_rsc_rdy_nstore_inst_bud),
      .dma_write_ctrl_rsc_dat(dma_write_ctrl_rsc_dat_nstore_inst),
      .dma_write_ctrl_rsc_vld(dma_write_ctrl_rsc_vld_nstore_inst_bud),
      .dma_write_ctrl_rsc_rdy(dma_write_ctrl_rsc_rdy),
      .dma_write_chnl_rsc_dat(dma_write_chnl_rsc_dat_nstore_inst),
      .dma_write_chnl_rsc_vld(dma_write_chnl_rsc_vld_nstore_inst_bud),
      .dma_write_chnl_rsc_rdy(dma_write_chnl_rsc_rdy),
      .done_rsc_rdy(done_rsc_rdy_nstore_inst),
      .done_rsc_vld(done_rsc_vld_nstore_inst_bud)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core softmax_cxx_catapult_core_inst
      (
      .clk(clk),
      .rst(rst),
      .acc_done_rsc_vld(acc_done_rsc_vld_nsoftmax_cxx_catapult_core_inst_bud),
      .config_done_cns_rdy(config_done_cns_rdy_nsoftmax_cxx_catapult_core_inst_bud),
      .config_done_cns_vld(config_done_cns_vld_nsoftmax_cxx_catapult_core_inst),
      .load_done_cns_rdy(load_done_cns_rdy_nsoftmax_cxx_catapult_core_inst_bud),
      .load_done_cns_vld(load_done_cns_vld_nsoftmax_cxx_catapult_core_inst),
      .compute_done_cns_rdy(compute_done_cns_rdy_nsoftmax_cxx_catapult_core_inst_bud),
      .compute_done_cns_vld(compute_done_cns_vld_nsoftmax_cxx_catapult_core_inst),
      .store_done_cns_rdy(store_done_cns_rdy_nsoftmax_cxx_catapult_core_inst_bud),
      .store_done_cns_vld(store_done_cns_vld_nsoftmax_cxx_catapult_core_inst)
    );
  assign conf_info_rsc_rdy = conf_info_rsc_rdy_nconfig_inst_bud;
  assign dma_read_ctrl_rsc_dat_index = dma_read_ctrl_rsc_dat_nload_inst[31:0];
  assign dma_read_ctrl_rsc_dat_length = dma_read_ctrl_rsc_dat_nload_inst[63:32];
  assign dma_read_ctrl_rsc_dat_size = dma_read_ctrl_rsc_dat_nload_inst[66:64];
  assign dma_write_ctrl_rsc_dat_index = dma_write_ctrl_rsc_dat_nstore_inst[31:0];
  assign dma_write_ctrl_rsc_dat_length = dma_write_ctrl_rsc_dat_nstore_inst[63:32];
  assign dma_write_ctrl_rsc_dat_size = dma_write_ctrl_rsc_dat_nstore_inst[66:64];
  assign dma_read_ctrl_rsc_vld = dma_read_ctrl_rsc_vld_nload_inst_bud;
  assign dma_read_chnl_rsc_rdy = dma_read_chnl_rsc_rdy_nload_inst_bud;
  assign dma_write_ctrl_rsc_vld = dma_write_ctrl_rsc_vld_nstore_inst_bud;
  assign dma_write_chnl_rsc_vld = dma_write_chnl_rsc_vld_nstore_inst_bud;
  assign dma_write_chnl_rsc_dat = dma_write_chnl_rsc_dat_nstore_inst;
  assign acc_done_rsc_vld = acc_done_rsc_vld_nsoftmax_cxx_catapult_core_inst_bud;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    softmax_cxx_catapult_hier_fx32_dma64
// ------------------------------------------------------------------


module softmax_cxx_catapult_hier_fx32_dma64 (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, dma_read_ctrl_rsc_dat,
      dma_read_ctrl_rsc_vld, dma_read_ctrl_rsc_rdy, dma_write_ctrl_rsc_dat, dma_write_ctrl_rsc_vld,
      dma_write_ctrl_rsc_rdy, dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy,
      dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy, acc_done_rsc_vld
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  output [66:0] dma_read_ctrl_rsc_dat;
  output dma_read_ctrl_rsc_vld;
  input dma_read_ctrl_rsc_rdy;
  output [66:0] dma_write_ctrl_rsc_dat;
  output dma_write_ctrl_rsc_vld;
  input dma_write_ctrl_rsc_rdy;
  input [63:0] dma_read_chnl_rsc_dat;
  input dma_read_chnl_rsc_vld;
  output dma_read_chnl_rsc_rdy;
  output [63:0] dma_write_chnl_rsc_dat;
  output dma_write_chnl_rsc_vld;
  input dma_write_chnl_rsc_rdy;
  output acc_done_rsc_vld;


  // Interconnect Declarations
  wire [2:0] dma_read_ctrl_rsc_dat_size;
  wire [31:0] dma_read_ctrl_rsc_dat_length;
  wire [31:0] dma_read_ctrl_rsc_dat_index;
  wire [2:0] dma_write_ctrl_rsc_dat_size;
  wire [31:0] dma_write_ctrl_rsc_dat_length;
  wire [31:0] dma_write_ctrl_rsc_dat_index;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_struct softmax_cxx_catapult_struct_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat_batch(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .dma_read_ctrl_rsc_dat_size(dma_read_ctrl_rsc_dat_size),
      .dma_read_ctrl_rsc_dat_length(dma_read_ctrl_rsc_dat_length),
      .dma_read_ctrl_rsc_dat_index(dma_read_ctrl_rsc_dat_index),
      .dma_read_ctrl_rsc_vld(dma_read_ctrl_rsc_vld),
      .dma_read_ctrl_rsc_rdy(dma_read_ctrl_rsc_rdy),
      .dma_write_ctrl_rsc_dat_size(dma_write_ctrl_rsc_dat_size),
      .dma_write_ctrl_rsc_dat_length(dma_write_ctrl_rsc_dat_length),
      .dma_write_ctrl_rsc_dat_index(dma_write_ctrl_rsc_dat_index),
      .dma_write_ctrl_rsc_vld(dma_write_ctrl_rsc_vld),
      .dma_write_ctrl_rsc_rdy(dma_write_ctrl_rsc_rdy),
      .dma_read_chnl_rsc_dat(dma_read_chnl_rsc_dat),
      .dma_read_chnl_rsc_vld(dma_read_chnl_rsc_vld),
      .dma_read_chnl_rsc_rdy(dma_read_chnl_rsc_rdy),
      .dma_write_chnl_rsc_dat(dma_write_chnl_rsc_dat),
      .dma_write_chnl_rsc_vld(dma_write_chnl_rsc_vld),
      .dma_write_chnl_rsc_rdy(dma_write_chnl_rsc_rdy),
      .acc_done_rsc_vld(acc_done_rsc_vld)
    );
  assign dma_read_ctrl_rsc_dat = {dma_read_ctrl_rsc_dat_size , dma_read_ctrl_rsc_dat_length
      , dma_read_ctrl_rsc_dat_index};
  assign dma_write_ctrl_rsc_dat = {dma_write_ctrl_rsc_dat_size , dma_write_ctrl_rsc_dat_length
      , dma_write_ctrl_rsc_dat_index};
endmodule



