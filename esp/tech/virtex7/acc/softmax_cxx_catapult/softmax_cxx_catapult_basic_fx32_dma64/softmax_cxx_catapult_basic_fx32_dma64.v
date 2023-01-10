
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

//------> /tools/calypto/CATAPULT_10.5c/Mgc_home/pkgs/ccs_xilinx/hdl/BLOCK_1R1W_RBW.v 
// Memory Type:            BLOCK
// Operating Mode:         Simple Dual Port (2-Port)
// Clock Mode:             Single Clock
// 
// RTL Code RW Resolution: RBW
// Catapult RW Resolution: RBW
// 
// HDL Work Library:       Xilinx_RAMS_lib
// Component Name:         BLOCK_1R1W_RBW
// Latency = 1:            RAM with no registers on inputs or outputs
//         = 2:            adds embedded register on RAM output
//         = 3:            adds fabric registers to non-clock input RAM pins
//         = 4:            adds fabric register to output (driven by embedded register from latency=2)

module BLOCK_1R1W_RBW #(
  parameter addr_width = 8 ,
  parameter data_width = 7 ,
  parameter depth = 256 ,
  parameter latency = 1 
  
)( clk,clken,d,q,radr,wadr,we);

  input  clk;
  input  clken;
  input [data_width-1:0] d;
  output [data_width-1:0] q;
  input [addr_width-1:0] radr;
  input [addr_width-1:0] wadr;
  input  we;
  
  (* ram_style = "block" *)
  reg [data_width-1:0] mem [depth-1:0];// synthesis syn_ramstyle="block"
  
  reg [data_width-1:0] ramq;
  
  // Port Map
  // readA :: CLOCK clk ENABLE clken DATA_OUT q ADDRESS radr
  // writeA :: CLOCK clk ENABLE clken DATA_IN d ADDRESS wadr WRITE_ENABLE we

  generate
    // Register all non-clock inputs (latency < 3)
    if (latency > 2 ) begin
      reg [addr_width-1:0] radr_reg;
      reg [data_width-1:0] d_reg;
      reg [addr_width-1:0] wadr_reg;
      reg we_reg;
      
      always @(posedge clk) begin
        if (clken) begin
          radr_reg <= radr;
        end
      end
      always @(posedge clk) begin
        if (clken) begin
          d_reg <= d;
          wadr_reg <= wadr;
          we_reg <= we;
        end
      end
      
    // Access memory with registered inputs
      always @(posedge clk) begin
        if (clken) begin
            ramq <= mem[radr_reg];
            if (we_reg) begin
              mem[wadr_reg] <= d_reg;
            end
        end
      end
      
    end // END register inputs

    else begin
    // latency = 1||2: Access memory with non-registered inputs
      always @(posedge clk) begin
        if (clken) begin
            ramq <= mem[radr];
            if (we) begin
              mem[wadr] <= d;
            end
        end
      end
      
    end
  endgenerate //END input port generate 

  generate
    // latency=1: sequential RAM outputs drive module outputs
    if (latency == 1) begin
      assign q = ramq;
      
    end

    else if (latency == 2 || latency == 3) begin
    // latency=2: sequential (RAM output => tmp register => module output)
      reg [data_width-1:0] tmpq;
      
      always @(posedge clk) begin
        if (clken) begin
          tmpq <= ramq;
        end
      end
      
      assign q = tmpq;
      
    end
    else if (latency == 4) begin
    // latency=4: (RAM => tmp1 register => tmp2 fabric register => module output)
      reg [data_width-1:0] tmp1q;
      
      reg [data_width-1:0] tmp2q;
      
      always @(posedge clk) begin
        if (clken) begin
          tmp1q <= ramq;
        end
      end
      
      always @(posedge clk) begin
        if (clken) begin
          tmp2q <= tmp1q;
        end
      end
      
      assign q = tmp2q;
      
    end
    else begin
      //Add error check if latency > 4 or add N-pipeline regs
    end
  endgenerate //END output port generate

endmodule

//------> ./softmax_cxx_catapult.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    10.5c/896140 Production Release
//  HLS Date:       Sun Sep  6 22:45:38 PDT 2020
// 
//  Generated by:   perenno@esp
//  Generated date: Wed Jul 27 11:25:17 2022
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_8_4_32_16_16_32_1_gen
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_8_4_32_16_16_32_1_gen
    (
  clken, q, radr, we, d, wadr, clken_d, d_d, q_d, radr_d, wadr_d, we_d, writeA_w_ram_ir_internal_WMASK_B_d,
      readA_r_ram_ir_internal_RMASK_B_d
);
  output clken;
  input [31:0] q;
  output [3:0] radr;
  output we;
  output [31:0] d;
  output [3:0] wadr;
  input clken_d;
  input [31:0] d_d;
  output [31:0] q_d;
  input [3:0] radr_d;
  input [3:0] wadr_d;
  input we_d;
  input writeA_w_ram_ir_internal_WMASK_B_d;
  input readA_r_ram_ir_internal_RMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign clken = (clken_d);
  assign q_d = q;
  assign radr = (radr_d);
  assign we = (writeA_w_ram_ir_internal_WMASK_B_d);
  assign d = (d_d);
  assign wadr = (wadr_d);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_fsm (
  clk, rst, core_wen, fsm_output, BATCH_LOOP_C_0_tr0
);
  input clk;
  input rst;
  input core_wen;
  output [3:0] fsm_output;
  reg [3:0] fsm_output;
  input BATCH_LOOP_C_0_tr0;


  // FSM State Type Declaration for esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_fsm_1
  parameter
    core_rlp_C_0 = 2'd0,
    main_C_0 = 2'd1,
    BATCH_LOOP_C_0 = 2'd2,
    main_C_1 = 2'd3;

  reg [1:0] state_var;
  reg [1:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 4'b0010;
        state_var_NS = BATCH_LOOP_C_0;
      end
      BATCH_LOOP_C_0 : begin
        fsm_output = 4'b0100;
        if ( BATCH_LOOP_C_0_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = BATCH_LOOP_C_0;
        end
      end
      main_C_1 : begin
        fsm_output = 4'b1000;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 4'b0001;
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_staller
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_staller (
  clk, rst, core_wen, core_wten, conf_info_rsci_wen_comp, dma_read_chnl_rsci_wen_comp,
      dma_write_chnl_rsci_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  input conf_info_rsci_wen_comp;
  input dma_read_chnl_rsci_wen_comp;
  input dma_write_chnl_rsci_wen_comp;


  // Interconnect Declarations
  reg core_wten_reg;


  // Interconnect Declarations for Component Instantiations 
  assign core_wen = conf_info_rsci_wen_comp & dma_read_chnl_rsci_wen_comp & dma_write_chnl_rsci_wen_comp;
  assign core_wten = core_wten_reg;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      core_wten_reg <= 1'b0;
    end
    else begin
      core_wten_reg <= ~ core_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_mgc_mul_15_0_32_1_47_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_mgc_mul_15_0_32_1_47_wait_ctrl
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_mgc_mul_15_0_32_1_47_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_mgc_mul_15_0_32_1_47_wait_dp
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp_mgc_mul_pipe_67_0_91_0_92_1_1_0_0_11_2_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp_mgc_mul_pipe_67_0_91_0_92_1_1_0_0_11_2_wait_dp
    (
  clk, rst, CALC_SOFTMAX_LOOP_mul_cmp_bawt, CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt, CALC_SOFTMAX_LOOP_mul_cmp_biwt,
      CALC_SOFTMAX_LOOP_mul_cmp_bdwt, CALC_SOFTMAX_LOOP_mul_cmp_z
);
  input clk;
  input rst;
  output CALC_SOFTMAX_LOOP_mul_cmp_bawt;
  output [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt;
  input CALC_SOFTMAX_LOOP_mul_cmp_biwt;
  input CALC_SOFTMAX_LOOP_mul_cmp_bdwt;
  input [91:0] CALC_SOFTMAX_LOOP_mul_cmp_z;


  // Interconnect Declarations
  reg [3:0] CALC_SOFTMAX_LOOP_mul_cmp_bcwt;
  wire [4:0] nl_CALC_SOFTMAX_LOOP_mul_cmp_bcwt;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_11_91_60;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_10_91_60;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_9_91_60;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_8_91_60;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_7_91_60;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_6_91_60;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_5_91_60;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_4_91_60;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_3_91_60;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_2_91_60;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_1_91_60;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_91_60;

  wire[1:0] CALC_SOFTMAX_LOOP_acc_1_nl;
  wire[2:0] nl_CALC_SOFTMAX_LOOP_acc_1_nl;

  // Interconnect Declarations for Component Instantiations 
  assign CALC_SOFTMAX_LOOP_mul_cmp_bawt = CALC_SOFTMAX_LOOP_mul_cmp_biwt | (CALC_SOFTMAX_LOOP_mul_cmp_bcwt!=4'b0000);
  assign CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt = MUX_v_32_13_2((CALC_SOFTMAX_LOOP_mul_cmp_z[91:60]),
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_91_60, CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_1_91_60,
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_2_91_60, CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_3_91_60,
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_4_91_60, CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_5_91_60,
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_6_91_60, CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_7_91_60,
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_8_91_60, CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_9_91_60,
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_10_91_60, CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_11_91_60,
      CALC_SOFTMAX_LOOP_mul_cmp_bcwt);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_mul_cmp_bcwt <= 4'b0000;
    end
    else begin
      CALC_SOFTMAX_LOOP_mul_cmp_bcwt <= nl_CALC_SOFTMAX_LOOP_mul_cmp_bcwt[3:0];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_91_60 <= 32'b00000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_1_91_60 <= 32'b00000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_2_91_60 <= 32'b00000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_3_91_60 <= 32'b00000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_4_91_60 <= 32'b00000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_5_91_60 <= 32'b00000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_6_91_60 <= 32'b00000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_7_91_60 <= 32'b00000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_8_91_60 <= 32'b00000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_9_91_60 <= 32'b00000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_10_91_60 <= 32'b00000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_11_91_60 <= 32'b00000000000000000000000000000000;
    end
    else if ( CALC_SOFTMAX_LOOP_mul_cmp_biwt ) begin
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_91_60 <= CALC_SOFTMAX_LOOP_mul_cmp_z[91:60];
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_1_91_60 <= CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_91_60;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_2_91_60 <= CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_1_91_60;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_3_91_60 <= CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_2_91_60;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_4_91_60 <= CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_3_91_60;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_5_91_60 <= CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_4_91_60;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_6_91_60 <= CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_5_91_60;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_7_91_60 <= CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_6_91_60;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_8_91_60 <= CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_7_91_60;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_9_91_60 <= CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_8_91_60;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_10_91_60 <= CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_9_91_60;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_11_91_60 <= CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_10_91_60;
    end
  end
  assign nl_CALC_SOFTMAX_LOOP_acc_1_nl = conv_s2s_1_2(CALC_SOFTMAX_LOOP_mul_cmp_bdwt)
      + conv_u2s_1_2(CALC_SOFTMAX_LOOP_mul_cmp_biwt);
  assign CALC_SOFTMAX_LOOP_acc_1_nl = nl_CALC_SOFTMAX_LOOP_acc_1_nl[1:0];
  assign nl_CALC_SOFTMAX_LOOP_mul_cmp_bcwt  = conv_s2u_2_4(CALC_SOFTMAX_LOOP_acc_1_nl)
      + CALC_SOFTMAX_LOOP_mul_cmp_bcwt;

  function automatic [31:0] MUX_v_32_13_2;
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
      default : begin
        result = input_12;
      end
    endcase
    MUX_v_32_13_2 = result;
  end
  endfunction


  function automatic [1:0] conv_s2s_1_2 ;
    input [0:0]  vector ;
  begin
    conv_s2s_1_2 = {vector[0], vector};
  end
  endfunction


  function automatic [3:0] conv_s2u_2_4 ;
    input [1:0]  vector ;
  begin
    conv_s2u_2_4 = {{2{vector[1]}}, vector};
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp_mgc_mul_pipe_67_0_91_0_92_1_1_0_0_11_2_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp_mgc_mul_pipe_67_0_91_0_92_1_1_0_0_11_2_wait_ctrl
    (
  clk, rst, core_wen, core_wten, CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg, CALC_SOFTMAX_LOOP_mul_cmp_iswt11,
      CALC_SOFTMAX_LOOP_mul_cmp_biwt, CALC_SOFTMAX_LOOP_mul_cmp_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg;
  input CALC_SOFTMAX_LOOP_mul_cmp_iswt11;
  output CALC_SOFTMAX_LOOP_mul_cmp_biwt;
  output CALC_SOFTMAX_LOOP_mul_cmp_bdwt;


  // Interconnect Declarations
  reg CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt10;
  reg CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt9;
  reg CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt8;
  reg CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt7;
  reg CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt6;
  reg CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt5;
  reg CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt4;
  reg CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt3;
  reg CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt2;
  reg CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt1;
  reg CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt0;
  reg [3:0] CALC_SOFTMAX_LOOP_mul_cmp_icwt;
  wire [4:0] nl_CALC_SOFTMAX_LOOP_mul_cmp_icwt;

  wire[1:0] CALC_SOFTMAX_LOOP_acc_nl;
  wire[2:0] nl_CALC_SOFTMAX_LOOP_acc_nl;

  // Interconnect Declarations for Component Instantiations 
  assign CALC_SOFTMAX_LOOP_mul_cmp_bdwt = CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg &
      core_wen;
  assign CALC_SOFTMAX_LOOP_mul_cmp_biwt = CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt0
      | (CALC_SOFTMAX_LOOP_mul_cmp_icwt!=4'b0000);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt10 <= 1'b0;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt9 <= 1'b0;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt8 <= 1'b0;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt7 <= 1'b0;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt6 <= 1'b0;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt5 <= 1'b0;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt4 <= 1'b0;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt3 <= 1'b0;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt2 <= 1'b0;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt1 <= 1'b0;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt0 <= 1'b0;
      CALC_SOFTMAX_LOOP_mul_cmp_icwt <= 4'b0000;
    end
    else begin
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt10 <= (~ core_wten)
          & CALC_SOFTMAX_LOOP_mul_cmp_iswt11;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt9 <= CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt10;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt8 <= CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt9;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt7 <= CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt8;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt6 <= CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt7;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt5 <= CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt6;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt4 <= CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt5;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt3 <= CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt4;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt2 <= CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt3;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt1 <= CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt2;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt0 <= CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt1;
      CALC_SOFTMAX_LOOP_mul_cmp_icwt <= nl_CALC_SOFTMAX_LOOP_mul_cmp_icwt[3:0];
    end
  end
  assign nl_CALC_SOFTMAX_LOOP_acc_nl = conv_s2s_1_2(CALC_SOFTMAX_LOOP_mul_cmp_biwt)
      + conv_u2s_1_2(CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt0);
  assign CALC_SOFTMAX_LOOP_acc_nl = nl_CALC_SOFTMAX_LOOP_acc_nl[1:0];
  assign nl_CALC_SOFTMAX_LOOP_mul_cmp_icwt  = conv_s2u_2_4(CALC_SOFTMAX_LOOP_acc_nl)
      + CALC_SOFTMAX_LOOP_mul_cmp_icwt;

  function automatic [1:0] conv_s2s_1_2 ;
    input [0:0]  vector ;
  begin
    conv_s2s_1_2 = {vector[0], vector};
  end
  endfunction


  function automatic [3:0] conv_s2u_2_4 ;
    input [1:0]  vector ;
  begin
    conv_s2u_2_4 = {{2{vector[1]}}, vector};
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_dp
    (
  clk, rst, plm_out_data_rsci_q_d, plm_out_data_rsci_bawt, plm_out_data_rsci_q_d_mxwt,
      plm_out_data_rsci_biwt, plm_out_data_rsci_bdwt, plm_out_data_rsci_biwt_1, plm_out_data_rsci_bdwt_2
);
  input clk;
  input rst;
  input [31:0] plm_out_data_rsci_q_d;
  output plm_out_data_rsci_bawt;
  output [31:0] plm_out_data_rsci_q_d_mxwt;
  input plm_out_data_rsci_biwt;
  input plm_out_data_rsci_bdwt;
  input plm_out_data_rsci_biwt_1;
  input plm_out_data_rsci_bdwt_2;


  // Interconnect Declarations
  reg plm_out_data_rsci_bcwt;
  reg plm_out_data_rsci_bcwt_1;
  reg [31:0] plm_out_data_rsci_q_d_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_data_rsci_bawt = plm_out_data_rsci_biwt | plm_out_data_rsci_bcwt;
  assign plm_out_data_rsci_q_d_mxwt = MUX_v_32_2_2(plm_out_data_rsci_q_d, plm_out_data_rsci_q_d_bfwt,
      plm_out_data_rsci_bcwt_1);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_data_rsci_bcwt <= 1'b0;
      plm_out_data_rsci_bcwt_1 <= 1'b0;
    end
    else begin
      plm_out_data_rsci_bcwt <= ~((~(plm_out_data_rsci_bcwt | plm_out_data_rsci_biwt))
          | plm_out_data_rsci_bdwt);
      plm_out_data_rsci_bcwt_1 <= ~((~(plm_out_data_rsci_bcwt_1 | plm_out_data_rsci_biwt_1))
          | plm_out_data_rsci_bdwt_2);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_data_rsci_q_d_bfwt <= 32'b00000000000000000000000000000000;
    end
    else if ( plm_out_data_rsci_biwt_1 ) begin
      plm_out_data_rsci_q_d_bfwt <= plm_out_data_rsci_q_d;
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_ctrl
    (
  core_wen, core_wten, plm_out_data_rsci_oswt_unreg, plm_out_data_rsci_iswt0, plm_out_data_rsci_oswt_unreg_1,
      plm_out_data_rsci_iswt0_1, plm_out_data_rsci_biwt, plm_out_data_rsci_bdwt,
      plm_out_data_rsci_biwt_1, plm_out_data_rsci_bdwt_2, plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct,
      plm_out_data_rsci_we_d_core_sct_pff, plm_out_data_rsci_iswt0_pff, plm_out_data_rsci_iswt0_1_pff
);
  input core_wen;
  input core_wten;
  input plm_out_data_rsci_oswt_unreg;
  input plm_out_data_rsci_iswt0;
  input plm_out_data_rsci_oswt_unreg_1;
  input plm_out_data_rsci_iswt0_1;
  output plm_out_data_rsci_biwt;
  output plm_out_data_rsci_bdwt;
  output plm_out_data_rsci_biwt_1;
  output plm_out_data_rsci_bdwt_2;
  output plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
  output plm_out_data_rsci_we_d_core_sct_pff;
  input plm_out_data_rsci_iswt0_pff;
  input plm_out_data_rsci_iswt0_1_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_data_rsci_bdwt = plm_out_data_rsci_oswt_unreg & core_wen;
  assign plm_out_data_rsci_biwt = (~ core_wten) & plm_out_data_rsci_iswt0;
  assign plm_out_data_rsci_bdwt_2 = plm_out_data_rsci_oswt_unreg_1 & core_wen;
  assign plm_out_data_rsci_biwt_1 = (~ core_wten) & plm_out_data_rsci_iswt0_1;
  assign plm_out_data_rsci_we_d_core_sct_pff = plm_out_data_rsci_iswt0_pff & core_wen;
  assign plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct = plm_out_data_rsci_iswt0_1_pff
      & core_wen;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_wait_dp (
  clk, rst, ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z,
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg
);
  input clk;
  input rst;
  input [46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z;
  output [46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg;
  reg [46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg;



  // Interconnect Declarations for Component Instantiations 
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg
          <= 47'b00000000000000000000000000000000000000000000000;
    end
    else begin
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg
          <= ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_acc_done_rsci_acc_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_acc_done_rsci_acc_done_wait_ctrl
    (
  core_wten, acc_done_rsci_iswt0, acc_done_rsci_ivld_core_sct
);
  input core_wten;
  input acc_done_rsci_iswt0;
  output acc_done_rsci_ivld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign acc_done_rsci_ivld_core_sct = acc_done_rsci_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_chnl_rsci_dma_write_chnl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_chnl_rsci_dma_write_chnl_wait_dp
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_chnl_rsci_dma_read_chnl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_chnl_rsci_dma_read_chnl_wait_dp
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_conf_info_rsci_conf_info_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_conf_info_rsci_conf_info_wait_dp
    (
  clk, rst, conf_info_rsci_oswt, conf_info_rsci_wen_comp, conf_info_rsci_idat_mxwt,
      conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt, conf_info_rsci_idat
);
  input clk;
  input rst;
  input conf_info_rsci_oswt;
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
  assign conf_info_rsci_wen_comp = (~ conf_info_rsci_oswt) | conf_info_rsci_biwt
      | conf_info_rsci_bcwt;
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_conf_info_rsci_conf_info_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_conf_info_rsci_conf_info_wait_ctrl
    (
  core_wen, conf_info_rsci_oswt, conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt,
      conf_info_rsci_irdy_core_sct, conf_info_rsci_ivld
);
  input core_wen;
  input conf_info_rsci_oswt;
  output conf_info_rsci_biwt;
  output conf_info_rsci_bdwt;
  input conf_info_rsci_bcwt;
  output conf_info_rsci_irdy_core_sct;
  input conf_info_rsci_ivld;


  // Interconnect Declarations
  wire conf_info_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_bdwt = conf_info_rsci_oswt & core_wen;
  assign conf_info_rsci_biwt = conf_info_rsci_ogwt & conf_info_rsci_ivld;
  assign conf_info_rsci_ogwt = conf_info_rsci_oswt & (~ conf_info_rsci_bcwt);
  assign conf_info_rsci_irdy_core_sct = conf_info_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp
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
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_mgc_mul_15_0_32_1_47_wait_dp
      softmax_cxx_catapult_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_mgc_mul_15_0_32_1_47_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt_pconst),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_biwt(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_biwt),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bdwt(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bdwt)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_mgc_mul_15_0_32_1_47_wait_ctrl
      softmax_cxx_catapult_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_mgc_mul_15_0_32_1_47_wait_ctrl_inst
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp
    (
  clk, rst, core_wen, core_wten, CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg, CALC_SOFTMAX_LOOP_mul_cmp_bawt,
      CALC_SOFTMAX_LOOP_mul_cmp_iswt11, CALC_SOFTMAX_LOOP_mul_cmp_a_core, CALC_SOFTMAX_LOOP_mul_cmp_b_core,
      CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg;
  output CALC_SOFTMAX_LOOP_mul_cmp_bawt;
  input CALC_SOFTMAX_LOOP_mul_cmp_iswt11;
  input [66:0] CALC_SOFTMAX_LOOP_mul_cmp_a_core;
  input [90:0] CALC_SOFTMAX_LOOP_mul_cmp_b_core;
  output [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt;


  // Interconnect Declarations
  wire CALC_SOFTMAX_LOOP_mul_cmp_biwt;
  wire CALC_SOFTMAX_LOOP_mul_cmp_bdwt;
  wire [91:0] CALC_SOFTMAX_LOOP_mul_cmp_z;
  wire [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt_pconst;


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
      .a(CALC_SOFTMAX_LOOP_mul_cmp_a_core),
      .b(CALC_SOFTMAX_LOOP_mul_cmp_b_core),
      .clk(clk),
      .en(1'b1),
      .a_rst(1'b1),
      .s_rst(rst),
      .z(CALC_SOFTMAX_LOOP_mul_cmp_z)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp_mgc_mul_pipe_67_0_91_0_92_1_1_0_0_11_2_wait_ctrl
      softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp_mgc_mul_pipe_67_0_91_0_92_1_1_0_0_11_2_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg(CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg),
      .CALC_SOFTMAX_LOOP_mul_cmp_iswt11(CALC_SOFTMAX_LOOP_mul_cmp_iswt11),
      .CALC_SOFTMAX_LOOP_mul_cmp_biwt(CALC_SOFTMAX_LOOP_mul_cmp_biwt),
      .CALC_SOFTMAX_LOOP_mul_cmp_bdwt(CALC_SOFTMAX_LOOP_mul_cmp_bdwt)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp_mgc_mul_pipe_67_0_91_0_92_1_1_0_0_11_2_wait_dp
      softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp_mgc_mul_pipe_67_0_91_0_92_1_1_0_0_11_2_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .CALC_SOFTMAX_LOOP_mul_cmp_bawt(CALC_SOFTMAX_LOOP_mul_cmp_bawt),
      .CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt(CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt_pconst),
      .CALC_SOFTMAX_LOOP_mul_cmp_biwt(CALC_SOFTMAX_LOOP_mul_cmp_biwt),
      .CALC_SOFTMAX_LOOP_mul_cmp_bdwt(CALC_SOFTMAX_LOOP_mul_cmp_bdwt),
      .CALC_SOFTMAX_LOOP_mul_cmp_z(CALC_SOFTMAX_LOOP_mul_cmp_z)
    );
  assign CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt = CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt_pconst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_plm_out_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_plm_out_data_rsci_1
    (
  clk, rst, plm_out_data_rsci_q_d, plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d,
      core_wen, core_wten, plm_out_data_rsci_oswt_unreg, plm_out_data_rsci_bawt,
      plm_out_data_rsci_iswt0, plm_out_data_rsci_oswt_unreg_1, plm_out_data_rsci_iswt0_1,
      plm_out_data_rsci_q_d_mxwt, plm_out_data_rsci_we_d_pff, plm_out_data_rsci_iswt0_pff,
      plm_out_data_rsci_iswt0_1_pff
);
  input clk;
  input rst;
  input [31:0] plm_out_data_rsci_q_d;
  output plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  input core_wen;
  input core_wten;
  input plm_out_data_rsci_oswt_unreg;
  output plm_out_data_rsci_bawt;
  input plm_out_data_rsci_iswt0;
  input plm_out_data_rsci_oswt_unreg_1;
  input plm_out_data_rsci_iswt0_1;
  output [31:0] plm_out_data_rsci_q_d_mxwt;
  output plm_out_data_rsci_we_d_pff;
  input plm_out_data_rsci_iswt0_pff;
  input plm_out_data_rsci_iswt0_1_pff;


  // Interconnect Declarations
  wire plm_out_data_rsci_biwt;
  wire plm_out_data_rsci_bdwt;
  wire plm_out_data_rsci_biwt_1;
  wire plm_out_data_rsci_bdwt_2;
  wire plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
  wire plm_out_data_rsci_we_d_core_sct_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_ctrl
      softmax_cxx_catapult_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_out_data_rsci_oswt_unreg(plm_out_data_rsci_oswt_unreg),
      .plm_out_data_rsci_iswt0(plm_out_data_rsci_iswt0),
      .plm_out_data_rsci_oswt_unreg_1(plm_out_data_rsci_oswt_unreg_1),
      .plm_out_data_rsci_iswt0_1(plm_out_data_rsci_iswt0_1),
      .plm_out_data_rsci_biwt(plm_out_data_rsci_biwt),
      .plm_out_data_rsci_bdwt(plm_out_data_rsci_bdwt),
      .plm_out_data_rsci_biwt_1(plm_out_data_rsci_biwt_1),
      .plm_out_data_rsci_bdwt_2(plm_out_data_rsci_bdwt_2),
      .plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct(plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct),
      .plm_out_data_rsci_we_d_core_sct_pff(plm_out_data_rsci_we_d_core_sct_iff),
      .plm_out_data_rsci_iswt0_pff(plm_out_data_rsci_iswt0_pff),
      .plm_out_data_rsci_iswt0_1_pff(plm_out_data_rsci_iswt0_1_pff)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_dp
      softmax_cxx_catapult_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_data_rsci_q_d(plm_out_data_rsci_q_d),
      .plm_out_data_rsci_bawt(plm_out_data_rsci_bawt),
      .plm_out_data_rsci_q_d_mxwt(plm_out_data_rsci_q_d_mxwt),
      .plm_out_data_rsci_biwt(plm_out_data_rsci_biwt),
      .plm_out_data_rsci_bdwt(plm_out_data_rsci_bdwt),
      .plm_out_data_rsci_biwt_1(plm_out_data_rsci_biwt_1),
      .plm_out_data_rsci_bdwt_2(plm_out_data_rsci_bdwt_2)
    );
  assign plm_out_data_rsci_we_d_pff = plm_out_data_rsci_we_d_core_sct_iff;
  assign plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d = plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_acc_done_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_acc_done_rsci (
  acc_done_rsc_vld, core_wten, acc_done_rsci_iswt0
);
  output acc_done_rsc_vld;
  input core_wten;
  input acc_done_rsci_iswt0;


  // Interconnect Declarations
  wire acc_done_rsci_ivld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_catapult_ccs_sync_out_vld_v1 #(.rscid(32'sd6)) acc_done_rsci
      (
      .vld(acc_done_rsc_vld),
      .ivld(acc_done_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_acc_done_rsci_acc_done_wait_ctrl
      softmax_cxx_catapult_core_acc_done_rsci_acc_done_wait_ctrl_inst (
      .core_wten(core_wten),
      .acc_done_rsci_iswt0(acc_done_rsci_iswt0),
      .acc_done_rsci_ivld_core_sct(acc_done_rsci_ivld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_chnl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_chnl_rsci
    (
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
  esp_acc_softmax_cxx_catapult_ccs_out_wait_v1 #(.rscid(32'sd5),
  .width(32'sd64)) dma_write_chnl_rsci (
      .irdy(dma_write_chnl_rsci_irdy),
      .ivld(dma_write_chnl_rsci_ivld_core_sct),
      .idat(nl_dma_write_chnl_rsci_idat[63:0]),
      .rdy(dma_write_chnl_rsc_rdy),
      .vld(dma_write_chnl_rsc_vld),
      .dat(dma_write_chnl_rsc_dat)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl
      softmax_cxx_catapult_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .dma_write_chnl_rsci_oswt_unreg(dma_write_chnl_rsci_oswt_unreg),
      .dma_write_chnl_rsci_iswt0(dma_write_chnl_rsci_iswt0),
      .dma_write_chnl_rsci_irdy(dma_write_chnl_rsci_irdy),
      .dma_write_chnl_rsci_biwt(dma_write_chnl_rsci_biwt),
      .dma_write_chnl_rsci_bdwt(dma_write_chnl_rsci_bdwt),
      .dma_write_chnl_rsci_bcwt(dma_write_chnl_rsci_bcwt),
      .dma_write_chnl_rsci_ivld_core_sct(dma_write_chnl_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_chnl_rsci_dma_write_chnl_wait_dp
      softmax_cxx_catapult_core_dma_write_chnl_rsci_dma_write_chnl_wait_dp_inst (
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_chnl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_chnl_rsci
    (
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
  esp_acc_softmax_cxx_catapult_ccs_in_wait_v1 #(.rscid(32'sd4),
  .width(32'sd64)) dma_read_chnl_rsci (
      .rdy(dma_read_chnl_rsc_rdy),
      .vld(dma_read_chnl_rsc_vld),
      .dat(dma_read_chnl_rsc_dat),
      .irdy(dma_read_chnl_rsci_irdy_core_sct),
      .ivld(dma_read_chnl_rsci_ivld),
      .idat(dma_read_chnl_rsci_idat)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl
      softmax_cxx_catapult_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl_inst (
      .core_wen(core_wen),
      .dma_read_chnl_rsci_oswt_unreg(dma_read_chnl_rsci_oswt_unreg),
      .dma_read_chnl_rsci_iswt0(dma_read_chnl_rsci_iswt0),
      .dma_read_chnl_rsci_biwt(dma_read_chnl_rsci_biwt),
      .dma_read_chnl_rsci_bdwt(dma_read_chnl_rsci_bdwt),
      .dma_read_chnl_rsci_bcwt(dma_read_chnl_rsci_bcwt),
      .dma_read_chnl_rsci_irdy_core_sct(dma_read_chnl_rsci_irdy_core_sct),
      .dma_read_chnl_rsci_ivld(dma_read_chnl_rsci_ivld)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_chnl_rsci_dma_read_chnl_wait_dp
      softmax_cxx_catapult_core_dma_read_chnl_rsci_dma_read_chnl_wait_dp_inst (
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_ctrl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_ctrl_rsci
    (
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
  esp_acc_softmax_cxx_catapult_ccs_out_wait_v1 #(.rscid(32'sd3),
  .width(32'sd67)) dma_write_ctrl_rsci (
      .irdy(dma_write_ctrl_rsci_irdy),
      .ivld(dma_write_ctrl_rsci_biwt),
      .idat(nl_dma_write_ctrl_rsci_idat[66:0]),
      .rdy(dma_write_ctrl_rsc_rdy),
      .vld(dma_write_ctrl_rsc_vld),
      .dat(dma_write_ctrl_rsc_dat)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl
      softmax_cxx_catapult_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dma_write_ctrl_rsci_oswt_unreg(dma_write_ctrl_rsci_oswt_unreg),
      .dma_write_ctrl_rsci_iswt0(dma_write_ctrl_rsci_iswt0),
      .dma_write_ctrl_rsci_biwt(dma_write_ctrl_rsci_biwt),
      .dma_write_ctrl_rsci_bdwt(dma_write_ctrl_rsci_bdwt)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp
      softmax_cxx_catapult_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp_inst (
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_ctrl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_ctrl_rsci
    (
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
  esp_acc_softmax_cxx_catapult_ccs_out_wait_v1 #(.rscid(32'sd2),
  .width(32'sd67)) dma_read_ctrl_rsci (
      .irdy(dma_read_ctrl_rsci_irdy),
      .ivld(dma_read_ctrl_rsci_biwt),
      .idat(nl_dma_read_ctrl_rsci_idat[66:0]),
      .rdy(dma_read_ctrl_rsc_rdy),
      .vld(dma_read_ctrl_rsc_vld),
      .dat(dma_read_ctrl_rsc_dat)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl
      softmax_cxx_catapult_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl_inst (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dma_read_ctrl_rsci_oswt_unreg(dma_read_ctrl_rsci_oswt_unreg),
      .dma_read_ctrl_rsci_iswt0(dma_read_ctrl_rsci_iswt0),
      .dma_read_ctrl_rsci_biwt(dma_read_ctrl_rsci_biwt),
      .dma_read_ctrl_rsci_bdwt(dma_read_ctrl_rsci_bdwt)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp
      softmax_cxx_catapult_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp_inst (
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
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_conf_info_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_conf_info_rsci (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, core_wen, conf_info_rsci_oswt,
      conf_info_rsci_wen_comp, conf_info_rsci_idat_mxwt
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  input core_wen;
  input conf_info_rsci_oswt;
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
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_conf_info_rsci_conf_info_wait_ctrl
      softmax_cxx_catapult_core_conf_info_rsci_conf_info_wait_ctrl_inst (
      .core_wen(core_wen),
      .conf_info_rsci_oswt(conf_info_rsci_oswt),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_irdy_core_sct(conf_info_rsci_irdy_core_sct),
      .conf_info_rsci_ivld(conf_info_rsci_ivld)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_conf_info_rsci_conf_info_wait_dp
      softmax_cxx_catapult_core_conf_info_rsci_conf_info_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsci_oswt(conf_info_rsci_oswt),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_idat(conf_info_rsci_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, dma_read_ctrl_rsc_dat,
      dma_read_ctrl_rsc_vld, dma_read_ctrl_rsc_rdy, dma_write_ctrl_rsc_dat, dma_write_ctrl_rsc_vld,
      dma_write_ctrl_rsc_rdy, dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy,
      dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy, acc_done_rsc_vld,
      plm_out_data_rsci_d_d, plm_out_data_rsci_q_d, plm_out_data_rsci_radr_d, plm_out_data_rsci_wadr_d,
      plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d, plm_out_data_rsci_we_d_pff
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
  output [31:0] plm_out_data_rsci_d_d;
  input [31:0] plm_out_data_rsci_q_d;
  output [3:0] plm_out_data_rsci_radr_d;
  output [3:0] plm_out_data_rsci_wadr_d;
  output plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  output plm_out_data_rsci_we_d_pff;


  // Interconnect Declarations
  wire core_wen;
  wire core_wten;
  wire conf_info_rsci_wen_comp;
  wire [31:0] conf_info_rsci_idat_mxwt;
  wire dma_read_ctrl_rsci_bawt;
  wire dma_read_ctrl_rsci_irdy_mxwt;
  wire dma_write_ctrl_rsci_bawt;
  wire dma_write_ctrl_rsci_irdy_mxwt;
  wire dma_read_chnl_rsci_bawt;
  wire dma_read_chnl_rsci_wen_comp;
  wire [31:0] dma_read_chnl_rsci_idat_mxwt;
  wire dma_write_chnl_rsci_bawt;
  wire dma_write_chnl_rsci_wen_comp;
  wire plm_out_data_rsci_bawt;
  wire [31:0] plm_out_data_rsci_q_d_mxwt;
  wire CALC_SOFTMAX_LOOP_mul_cmp_bawt;
  reg CALC_SOFTMAX_LOOP_mul_cmp_iswt11;
  wire [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt;
  reg [31:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_b_core;
  wire [46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z;
  wire ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt;
  wire [46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg;
  wire [18:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt;
  reg [3:0] dma_read_ctrl_rsci_idat_7_4;
  reg [27:0] dma_write_ctrl_rsci_idat_31_4;
  reg [31:0] dma_write_chnl_rsci_idat_31_0;
  wire [3:0] fsm_output;
  wire BATCH_LOOP_nor_22_tmp;
  wire [4:0] BATCH_LOOP_acc_2_tmp;
  wire [5:0] nl_BATCH_LOOP_acc_2_tmp;
  wire [4:0] STORE_LOOP_acc_1_tmp;
  wire [5:0] nl_STORE_LOOP_acc_1_tmp;
  wire BATCH_LOOP_and_22_tmp;
  wire [1:0] STORE_LOOP_mux_55_tmp;
  wire [1:0] STORE_LOOP_mux1h_104_tmp;
  wire BATCH_LOOP_and_21_tmp;
  wire or_tmp_16;
  wire or_tmp_25;
  wire not_tmp_41;
  wire not_tmp_46;
  wire and_tmp_12;
  wire or_dcpl_11;
  wire and_dcpl_41;
  wire and_dcpl_42;
  wire or_tmp_151;
  wire mux_tmp_224;
  wire or_tmp_161;
  wire mux_tmp_225;
  wire mux_tmp_228;
  wire mux_tmp_229;
  wire mux_tmp_230;
  wire mux_tmp_232;
  wire mux_tmp_234;
  wire mux_tmp_237;
  wire mux_tmp_242;
  wire mux_tmp_247;
  wire not_tmp_96;
  wire or_tmp_172;
  wire or_tmp_173;
  wire or_tmp_174;
  wire or_tmp_175;
  wire nor_tmp_41;
  wire mux_tmp_250;
  wire mux_tmp_253;
  wire mux_tmp_254;
  wire mux_tmp_256;
  wire nand_tmp_21;
  wire mux_tmp_265;
  wire and_tmp_37;
  wire mux_tmp_268;
  wire mux_tmp_271;
  wire mux_tmp_272;
  wire mux_tmp_274;
  wire and_tmp_38;
  wire nand_tmp_25;
  wire mux_tmp_284;
  wire mux_tmp_285;
  wire and_dcpl_43;
  wire and_dcpl_46;
  wire not_tmp_113;
  wire mux_tmp_298;
  wire mux_tmp_299;
  wire mux_tmp_300;
  wire and_tmp_41;
  wire mux_tmp_301;
  wire mux_tmp_302;
  wire mux_tmp_303;
  wire mux_tmp_304;
  wire mux_tmp_305;
  wire mux_tmp_306;
  wire mux_tmp_307;
  wire mux_tmp_308;
  wire mux_tmp_309;
  wire and_tmp_50;
  wire mux_tmp_310;
  wire and_tmp_51;
  wire mux_tmp_311;
  wire and_tmp_52;
  wire mux_tmp_312;
  wire and_tmp_53;
  wire mux_tmp_313;
  wire and_tmp_54;
  wire mux_tmp_314;
  wire mux_tmp_315;
  wire and_dcpl_57;
  wire and_dcpl_91;
  wire and_tmp_64;
  wire not_tmp_152;
  wire or_tmp_242;
  wire mux_tmp_402;
  wire mux_tmp_406;
  wire mux_tmp_409;
  wire mux_tmp_411;
  wire mux_tmp_413;
  wire mux_tmp_416;
  wire mux_tmp_426;
  wire and_dcpl_105;
  wire and_dcpl_106;
  wire mux_tmp_427;
  wire or_dcpl_50;
  wire or_dcpl_59;
  wire or_dcpl_72;
  wire and_dcpl_114;
  wire or_dcpl_78;
  wire or_dcpl_85;
  wire or_dcpl_91;
  wire and_dcpl_169;
  wire mux_tmp_428;
  wire or_dcpl_98;
  wire not_tmp_211;
  wire or_tmp_271;
  wire not_tmp_217;
  wire mux_tmp_449;
  wire or_tmp_291;
  wire or_tmp_299;
  wire or_tmp_300;
  wire mux_tmp_467;
  wire or_tmp_303;
  wire and_tmp_87;
  wire mux_tmp_469;
  wire mux_tmp_470;
  wire mux_tmp_472;
  wire or_tmp_308;
  wire mux_tmp_475;
  wire or_tmp_313;
  wire or_tmp_316;
  wire mux_tmp_486;
  wire mux_tmp_487;
  wire mux_tmp_489;
  wire or_tmp_321;
  wire mux_tmp_499;
  wire mux_tmp_501;
  wire and_dcpl_197;
  wire and_tmp_108;
  wire and_dcpl_201;
  wire and_tmp_109;
  wire and_tmp_113;
  wire and_tmp_128;
  wire and_dcpl_204;
  wire mux_tmp_663;
  wire and_dcpl_291;
  wire and_dcpl_304;
  wire and_dcpl_309;
  wire and_dcpl_313;
  wire and_dcpl_317;
  wire or_tmp_446;
  wire mux_tmp_732;
  wire and_dcpl_329;
  wire and_tmp_360;
  wire and_tmp_362;
  wire and_dcpl_332;
  wire or_tmp_454;
  wire or_tmp_496;
  wire nand_tmp_39;
  wire mux_tmp_799;
  wire mux_tmp_801;
  wire and_dcpl_343;
  wire and_tmp_543;
  wire mux_tmp_952;
  wire and_dcpl_418;
  wire mux_tmp_954;
  wire or_tmp_587;
  wire or_tmp_591;
  wire or_tmp_598;
  wire or_tmp_608;
  wire or_tmp_642;
  wire or_tmp_651;
  wire or_tmp_680;
  wire or_tmp_740;
  wire or_tmp_817;
  wire STORE_LOOP_STORE_LOOP_STORE_LOOP_and_cse_mx0w1;
  wire exit_BATCH_LOOP_lpi_2_dfm_mx0w0;
  wire STORE_LOOP_equal_tmp_2_mx0w0;
  wire [4:0] LOAD_LOOP_i_4_0_sva_2;
  wire [5:0] nl_LOAD_LOOP_i_4_0_sva_2;
  wire [4:0] CALC_EXP_LOOP_i_4_0_sva_2;
  wire [5:0] nl_CALC_EXP_LOOP_i_4_0_sva_2;
  wire [4:0] SUM_EXP_LOOP_i_4_0_sva_2;
  wire [5:0] nl_SUM_EXP_LOOP_i_4_0_sva_2;
  wire [3:0] SUM_EXP_LOOP_i_4_0_lpi_2_3_0_mx1;
  wire [3:0] CALC_EXP_LOOP_i_4_0_lpi_2_3_0_mx1;
  wire [3:0] LOAD_LOOP_i_4_0_lpi_2_3_0_mx1;
  wire lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0;
  wire exitL_exit_STORE_LOOP_sva_mx1;
  wire lfst_exit_STORE_LOOP_lpi_2_2_mx1;
  wire STORE_LOOP_or_tmp_1;
  reg STORE_LOOP_equal_tmp_2_1;
  wire STORE_LOOP_nor_tmp_1;
  wire STORE_LOOP_equal_tmp_mx0w0;
  wire STORE_LOOP_equal_tmp_3;
  reg exit_BATCH_LOOP_lpi_2_dfm_1;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2;
  wire STORE_LOOP_and_38_ssc_1;
  wire STORE_LOOP_and_34_ssc_1;
  wire STORE_LOOP_and_36_ssc_1;
  wire CALC_SOFTMAX_LOOP_and_svs_1;
  wire exit_STORE_CTRL_LOOP_lpi_2_dfm_4;
  reg exit_STORE_CTRL_LOOP_lpi_2;
  reg [4:0] CALC_SOFTMAX_LOOP_i_4_0_sva_1_1;
  wire [5:0] nl_CALC_SOFTMAX_LOOP_i_4_0_sva_1_1;
  reg exit_CALC_SOFTMAX_LOOP_lpi_2;
  wire STORE_LOOP_STORE_LOOP_and_cse_1;
  reg STORE_LOOP_STORE_LOOP_and_6_itm_1;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_3;
  reg BATCH_LOOP_stage_v_3;
  reg CALC_SOFTMAX_LOOP_asn_itm_19;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_19;
  reg BATCH_LOOP_stage_old_v_19;
  reg CALC_SOFTMAX_LOOP_asn_itm_20;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_20;
  reg BATCH_LOOP_stage_old_v_20;
  reg BATCH_LOOP_stage_v_21;
  wire BATCH_LOOP_BATCH_LOOP_or_cse_1;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_21_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_21_1_0;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_21;
  wire [3:0] CALC_SOFTMAX_LOOP_i_4_0_lpi_2_3_0_mx1;
  reg [70:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2;
  wire [66:0] operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
  reg STORE_LOOP_equal_tmp_3_1;
  reg exit_BATCH_LOOP_lpi_2_dfm_4;
  wire [70:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
  wire [71:0] nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
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
  reg [3:0] CALC_EXP_LOOP_i_4_0_sva_1_1_3_0;
  reg [3:0] CALC_EXP_LOOP_i_4_0_lpi_2_3_0;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2;
  reg exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3;
  reg [4:0] STORE_LOOP_i_4_0_sva_1_1;
  reg STORE_LOOP_asn_51_itm_1;
  reg CALC_SOFTMAX_LOOP_asn_itm_18;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_18;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_18_2;
  reg BATCH_LOOP_stage_0_21;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_18_1_0;
  reg BATCH_LOOP_stage_v_18;
  reg BATCH_LOOP_stage_0_19;
  reg BATCH_LOOP_stage_0_20;
  reg CALC_SOFTMAX_LOOP_asn_19_itm_1;
  reg exitL_exit_STORE_LOOP_sva;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_2;
  reg STORE_LOOP_STORE_LOOP_and_10_itm_1;
  reg BATCH_LOOP_stage_v_2;
  reg BATCH_LOOP_stage_0_3;
  reg BATCH_LOOP_stage_0_18;
  reg BATCH_LOOP_stage_v_17;
  reg BATCH_LOOP_stage_0_17;
  reg BATCH_LOOP_stage_v_16;
  reg BATCH_LOOP_stage_0_16;
  reg BATCH_LOOP_stage_v_15;
  reg BATCH_LOOP_stage_0_15;
  reg BATCH_LOOP_stage_v_14;
  reg BATCH_LOOP_stage_0_14;
  reg BATCH_LOOP_stage_v_13;
  reg BATCH_LOOP_stage_0_13;
  reg BATCH_LOOP_stage_v_12;
  reg BATCH_LOOP_stage_0_12;
  reg BATCH_LOOP_stage_v_11;
  reg BATCH_LOOP_stage_0_11;
  reg BATCH_LOOP_stage_v_10;
  reg BATCH_LOOP_stage_0_10;
  reg BATCH_LOOP_stage_v_9;
  reg BATCH_LOOP_stage_0_9;
  reg BATCH_LOOP_stage_v_8;
  reg BATCH_LOOP_stage_0_8;
  reg BATCH_LOOP_stage_v_7;
  reg BATCH_LOOP_stage_0_7;
  reg BATCH_LOOP_stage_v_6;
  reg BATCH_LOOP_stage_0_6;
  reg BATCH_LOOP_stage_v_5;
  reg BATCH_LOOP_stage_0_5;
  reg BATCH_LOOP_stage_v_4;
  reg BATCH_LOOP_stage_0_4;
  reg BATCH_LOOP_stage_0_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_17_1_0;
  reg CALC_SOFTMAX_LOOP_asn_itm_17;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_17_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_17;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_16_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_16_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_16;
  reg CALC_SOFTMAX_LOOP_asn_itm_7;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_7;
  reg LOAD_LOOP_and_1_svs_st_7;
  reg [70:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3;
  reg LOAD_LOOP_and_1_svs_st_6;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_1_0;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_6;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_2;
  reg [70:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_4;
  reg STORE_LOOP_asn_51_itm_4;
  reg CALC_SOFTMAX_LOOP_asn_itm_3;
  reg STORE_LOOP_and_61_itm_3;
  reg STORE_LOOP_and_60_itm_3;
  reg STORE_LOOP_and_63_itm_3;
  reg STORE_LOOP_and_59_itm_3;
  reg STORE_LOOP_and_58_itm_3;
  reg STORE_LOOP_and_65_itm_3;
  reg STORE_LOOP_and_57_itm_3;
  reg STORE_LOOP_and_66_itm_3;
  reg STORE_LOOP_and_56_itm_3;
  reg STORE_LOOP_and_67_itm_3;
  reg STORE_LOOP_and_55_itm_3;
  reg STORE_LOOP_and_54_itm_3;
  reg STORE_LOOP_and_69_itm_3;
  reg STORE_LOOP_and_42_itm_4;
  reg STORE_LOOP_and_62_itm_3;
  reg STORE_LOOP_and_64_itm_3;
  reg STORE_LOOP_and_68_itm_3;
  reg BATCH_LOOP_stage_v;
  reg BATCH_LOOP_stage_0;
  reg STORE_LOOP_asn_51_itm_8;
  reg CALC_SOFTMAX_LOOP_asn_itm_1;
  reg LOAD_LOOP_and_1_svs_8;
  wire STORE_LOOP_and_39_itm_mx0w0;
  wire [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0;
  wire STORE_LOOP_and_45_cse_1;
  wire STORE_LOOP_or_51_itm_mx0w0;
  wire or_204_cse;
  reg reg_CALC_SOFTMAX_LOOP_mul_cmp_oswt_cse;
  reg reg_plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse;
  reg reg_acc_done_rsci_ivld_core_psct_cse;
  reg reg_dma_write_chnl_rsci_ivld_core_psct_cse;
  reg reg_dma_read_chnl_rsci_irdy_core_psct_cse;
  reg reg_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_iswt1_cse;
  reg reg_dma_write_ctrl_rsci_ivld_core_psct_cse;
  reg reg_dma_read_ctrl_rsci_ivld_core_psct_cse;
  reg reg_conf_info_rsci_irdy_core_psct_cse;
  wire STORE_LOOP_and_100_cse;
  wire CALC_SOFTMAX_LOOP_and_cse;
  wire CALC_SOFTMAX_LOOP_and_40_cse;
  wire STORE_LOOP_and_106_cse;
  wire LOAD_LOOP_i_and_cse;
  wire BATCH_LOOP_and_26_cse;
  wire CALC_SOFTMAX_LOOP_and_41_cse;
  wire or_194_cse;
  wire STORE_LOOP_and_110_cse;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_and_cse;
  wire STORE_LOOP_and_113_cse;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_and_cse;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_39_cse;
  reg [3:0] reg_CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_cse;
  wire CALC_SOFTMAX_LOOP_and_43_cse;
  wire CALC_EXP_LOOP_i_and_cse;
  wire CALC_SOFTMAX_LOOP_i_and_2_cse;
  wire LOAD_LOOP_and_4_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse;
  wire or_50_cse;
  wire or_622_cse;
  wire or_623_cse;
  wire or_624_cse;
  wire nor_142_cse;
  wire CALC_SOFTMAX_LOOP_and_47_cse;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_and_6_cse;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_and_7_cse;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_7_cse;
  wire STORE_LOOP_and_137_cse;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_5_cse;
  wire or_9_cse;
  wire or_24_cse;
  wire and_1785_cse;
  wire or_26_cse;
  wire or_114_cse;
  wire or_67_cse;
  wire and_1778_cse;
  wire and_1783_cse;
  wire nor_42_cse;
  wire or_29_cse;
  wire or_46_cse;
  wire and_416_cse;
  wire and_439_cse;
  wire and_572_cse;
  wire and_591_cse;
  wire and_609_cse;
  wire and_1790_cse;
  wire mux_499_cse;
  wire or_394_cse;
  wire or_392_cse;
  wire and_1761_cse;
  wire [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_and_3_rgt;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_42_rgt;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_45_rgt;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_48_rgt;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_51_rgt;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_54_rgt;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_57_rgt;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_60_rgt;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_63_rgt;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_66_rgt;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_69_rgt;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_72_rgt;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_75_rgt;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_78_rgt;
  wire and_1742_cse;
  wire nor_196_cse;
  wire STORE_LOOP_i_or_1_cse;
  wire mux_416_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_mx0c1;
  wire mux_600_cse;
  wire and_391_cse;
  wire and_390_cse;
  wire and_389_cse;
  wire and_388_cse;
  wire and_387_cse;
  wire and_386_cse;
  wire and_385_cse;
  wire mux_281_cse;
  wire and_617_cse;
  wire and_72_cse;
  wire nand_24_cse;
  wire and_877_cse;
  wire mux_949_cse;
  wire mux_948_cse;
  wire mux_947_cse;
  wire mux_946_cse;
  wire mux_510_cse;
  wire mux_530_cse;
  wire mux_277_cse;
  wire mux_312_cse;
  wire nor_153_cse;
  wire and_745_cse;
  reg [31:0] plm_out_data_rsci_d_d_reg;
  wire [31:0] CALC_SOFTMAX_LOOP_mux_1_rmff;
  reg [3:0] plm_out_data_rsci_radr_d_reg;
  wire [3:0] STORE_LOOP_i_mux_rmff;
  reg [3:0] plm_out_data_rsci_wadr_d_reg;
  wire [3:0] CALC_SOFTMAX_LOOP_i_mux_rmff;
  wire plm_out_data_rsci_we_d_iff;
  wire and_1015_rmff;
  wire plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_1017_rmff;
  wire and_1009_rmff;
  wire mux_415_cse;
  reg [66:0] CALC_SOFTMAX_LOOP_mux_itm_4;
  reg [90:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2;
  wire or_dcpl_126;
  reg exit_LOAD_CTRL_LOOP_sva_3;
  reg STORE_LOOP_and_39_itm_3;
  reg STORE_LOOP_or_51_itm_3;
  wire or_1066_tmp;
  wire STORE_LOOP_and_92_tmp;
  wire or_1062_tmp;
  wire or_1059_tmp;
  wire STORE_LOOP_and_35_cse;
  wire STORE_LOOP_and_33_cse;
  wire and_1813_cse;
  wire and_1814_cse;
  wire [90:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_or_1_itm;
  wire [90:0] operator_91_21_false_AC_TRN_AC_WRAP_rshift_itm;
  wire [69:0] operator_71_0_false_AC_TRN_AC_WRAP_lshift_itm;
  wire mux_338_itm;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_7_lpi_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_8_lpi_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_6_lpi_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_9_lpi_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_5_lpi_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_10_lpi_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_4_lpi_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_11_lpi_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_3_lpi_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_12_lpi_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_2_lpi_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_13_lpi_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_1_lpi_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_14_lpi_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_0_lpi_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_15_lpi_2;
  reg [27:0] BATCH_LOOP_acc_3_psp_lpi_2;
  reg [31:0] batch_sva;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_0_lpi_2_dfm_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_1_lpi_2_dfm_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_2_lpi_2_dfm_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_3_lpi_2_dfm_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_4_lpi_2_dfm_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_5_lpi_2_dfm_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_6_lpi_2_dfm_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_7_lpi_2_dfm_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_8_lpi_2_dfm_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_9_lpi_2_dfm_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_10_lpi_2_dfm_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_11_lpi_2_dfm_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_12_lpi_2_dfm_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_13_lpi_2_dfm_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_14_lpi_2_dfm_2;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_15_lpi_2_dfm_2;
  reg [70:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2;
  reg [90:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3;
  reg [27:0] BATCH_LOOP_acc_3_psp_lpi_2_dfm_2;
  reg exit_STORE_CTRL_LOOP_lpi_2_dfm_3;
  reg BATCH_LOOP_stage_old_v_1;
  reg [7:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_69_57_9_0_itm;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm;
  reg [10:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm;
  reg [5:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_acc_itm;
  reg [1:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_slc_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_1_0_itm;
  reg ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm;
  reg CALC_SOFTMAX_LOOP_asn_itm;
  reg [66:0] CALC_SOFTMAX_LOOP_mux_itm;
  reg CALC_SOFTMAX_LOOP_asn_19_itm;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm;
  reg exit_LOAD_CTRL_LOOP_sva_1;
  reg exit_LOAD_CTRL_LOOP_sva_2;
  reg STORE_LOOP_equal_tmp_1;
  reg STORE_LOOP_equal_tmp_2;
  reg LOAD_LOOP_and_1_svs_3;
  reg LOAD_LOOP_and_1_svs_4;
  reg LOAD_LOOP_and_1_svs_5;
  reg LOAD_LOOP_and_1_svs_6;
  reg LOAD_LOOP_and_1_svs_7;
  reg [70:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1;
  reg exit_BATCH_LOOP_lpi_2_dfm_3;
  reg [6:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_sva_1;
  reg [2:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_2_itm_1;
  reg [6:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_3_itm_1;
  reg [8:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_sdt_18_0_itm_1;
  reg [9:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_sdt_18_0_1_itm_1;
  reg [6:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_18_12_itm_1;
  reg [7:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_69_57_9_0_itm_1;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1;
  reg [10:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_1;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm_1;
  reg [5:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1;
  reg [1:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_slc_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_1_0_itm_1;
  reg [3:0] BATCH_LOOP_b_slc_BATCH_LOOP_b_4_0_3_0_1_itm_1;
  reg ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_1;
  reg ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_2;
  reg ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_3;
  reg ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_4;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_itm_1;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_itm_2;
  reg [66:0] CALC_SOFTMAX_LOOP_mux_itm_1;
  reg [66:0] CALC_SOFTMAX_LOOP_mux_itm_2;
  reg [66:0] CALC_SOFTMAX_LOOP_mux_itm_3;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_2;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_3;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_4;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_5;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_6;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_7;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_8;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_9;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_10;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_11;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_12;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_13;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_14;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_15;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_16;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_17;
  reg [3:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_18;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_1;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_2;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_3;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_4;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_5;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_6;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_7;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_8;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_9;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_10;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_11;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_12;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_13;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_14;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_15;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_16;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_17;
  reg [3:0] STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_18;
  reg STORE_LOOP_and_54_itm_1;
  reg STORE_LOOP_and_54_itm_2;
  reg STORE_LOOP_and_55_itm_1;
  reg STORE_LOOP_and_55_itm_2;
  reg STORE_LOOP_and_56_itm_1;
  reg STORE_LOOP_and_56_itm_2;
  reg STORE_LOOP_and_57_itm_1;
  reg STORE_LOOP_and_57_itm_2;
  reg STORE_LOOP_and_58_itm_1;
  reg STORE_LOOP_and_58_itm_2;
  reg STORE_LOOP_and_59_itm_1;
  reg STORE_LOOP_and_59_itm_2;
  reg STORE_LOOP_and_60_itm_1;
  reg STORE_LOOP_and_60_itm_2;
  reg STORE_LOOP_and_61_itm_1;
  reg STORE_LOOP_and_61_itm_2;
  reg STORE_LOOP_and_62_itm_1;
  reg STORE_LOOP_and_62_itm_2;
  reg STORE_LOOP_and_63_itm_1;
  reg STORE_LOOP_and_63_itm_2;
  reg STORE_LOOP_and_64_itm_1;
  reg STORE_LOOP_and_64_itm_2;
  reg STORE_LOOP_and_65_itm_1;
  reg STORE_LOOP_and_65_itm_2;
  reg STORE_LOOP_and_66_itm_1;
  reg STORE_LOOP_and_66_itm_2;
  reg STORE_LOOP_and_67_itm_1;
  reg STORE_LOOP_and_67_itm_2;
  reg STORE_LOOP_and_68_itm_1;
  reg STORE_LOOP_and_68_itm_2;
  reg STORE_LOOP_and_69_itm_1;
  reg STORE_LOOP_and_69_itm_2;
  reg STORE_LOOP_and_39_itm_1;
  reg STORE_LOOP_and_39_itm_2;
  reg STORE_LOOP_or_51_itm_1;
  reg STORE_LOOP_or_51_itm_2;
  reg STORE_LOOP_and_42_itm_1;
  reg STORE_LOOP_and_42_itm_2;
  reg STORE_LOOP_and_42_itm_3;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_5;
  reg LOAD_LOOP_and_1_svs_st_2;
  reg LOAD_LOOP_and_1_svs_st_3;
  reg LOAD_LOOP_and_1_svs_st_4;
  reg LOAD_LOOP_and_1_svs_st_5;
  reg [70:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_8;
  reg CALC_SOFTMAX_LOOP_asn_itm_2;
  reg CALC_SOFTMAX_LOOP_asn_itm_4;
  reg CALC_SOFTMAX_LOOP_asn_itm_5;
  reg CALC_SOFTMAX_LOOP_asn_itm_6;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_9;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_10;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_11;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_12;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_13;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_14;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_15;
  reg CALC_SOFTMAX_LOOP_asn_itm_8;
  reg CALC_SOFTMAX_LOOP_asn_itm_9;
  reg CALC_SOFTMAX_LOOP_asn_itm_10;
  reg CALC_SOFTMAX_LOOP_asn_itm_11;
  reg CALC_SOFTMAX_LOOP_asn_itm_12;
  reg CALC_SOFTMAX_LOOP_asn_itm_13;
  reg CALC_SOFTMAX_LOOP_asn_itm_14;
  reg CALC_SOFTMAX_LOOP_asn_itm_15;
  reg CALC_SOFTMAX_LOOP_asn_itm_16;
  reg STORE_LOOP_asn_51_itm_2;
  reg STORE_LOOP_asn_51_itm_3;
  reg STORE_LOOP_asn_51_itm_5;
  reg STORE_LOOP_asn_51_itm_6;
  reg STORE_LOOP_asn_51_itm_7;
  reg BATCH_LOOP_stage_0_1;
  reg [3:0] LOAD_LOOP_i_4_0_lpi_2_3_0;
  reg [3:0] SUM_EXP_LOOP_i_4_0_lpi_2_3_0;
  reg [3:0] CALC_SOFTMAX_LOOP_i_4_0_lpi_2_3_0;
  reg [3:0] STORE_LOOP_i_4_0_lpi_2_3_0;
  reg [3:0] BATCH_LOOP_b_4_0_sva_3_0;
  reg [3:0] LOAD_LOOP_i_4_0_lpi_2_dfm_2_3_0;
  reg [3:0] CALC_EXP_LOOP_i_4_0_lpi_2_dfm_2_3_0;
  reg [3:0] SUM_EXP_LOOP_i_4_0_lpi_2_dfm_2_3_0;
  reg [3:0] CALC_SOFTMAX_LOOP_i_4_0_lpi_2_dfm_3_3_0;
  reg [3:0] STORE_LOOP_i_4_0_lpi_2_dfm_2_3_0;
  reg [5:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_7_2;
  reg [1:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_0;
  reg [3:0] SUM_EXP_LOOP_i_4_0_sva_1_1_3_0;
  reg [69:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_2_69_0;
  reg [3:0] LOAD_LOOP_i_4_0_sva_1_1_3_0;
  reg [5:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_7_2;
  reg [1:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_8_2;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_13_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_13_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_14_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_14_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_15_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_15_1_0;
  wire lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx1w0;
  wire [10:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_mx0w0;
  wire [11:0] nl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_mx0w0;
  wire [5:0] ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0;
  wire [6:0] nl_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0;
  wire [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_mx0w0;
  wire [7:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_mx0w0;
  wire ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0;
  wire [66:0] CALC_SOFTMAX_LOOP_mux_itm_mx0w0;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_7_lpi_2_dfm_2_mx0c1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_6_lpi_2_dfm_2_mx0c1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_9_lpi_2_dfm_2_mx0c1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_5_lpi_2_dfm_2_mx0c1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_4_lpi_2_dfm_2_mx0c1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_11_lpi_2_dfm_2_mx0c1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_3_lpi_2_dfm_2_mx0c1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_12_lpi_2_dfm_2_mx0c1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_2_lpi_2_dfm_2_mx0c1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_13_lpi_2_dfm_2_mx0c1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_1_lpi_2_dfm_2_mx0c1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_0_lpi_2_dfm_2_mx0c1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_15_lpi_2_dfm_2_mx0c1;
  wire [3:0] CALC_EXP_LOOP_i_4_0_lpi_2_dfm_2_3_0_mx0w0;
  wire [70:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2_mx0w0;
  wire [3:0] SUM_EXP_LOOP_i_4_0_lpi_2_dfm_2_3_0_mx0w0;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3_mx0c1;
  wire STORE_LOOP_mux1h_33_mx0w1;
  wire BATCH_LOOP_acc_3_psp_lpi_2_dfm_2_mx0c1;
  wire STORE_LOOP_mux1h_34_mx0w1;
  wire [3:0] LOAD_LOOP_i_4_0_lpi_2_dfm_2_3_0_mx0w0;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_8_lpi_2_dfm_2_mx0c1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_10_lpi_2_dfm_2_mx0c1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_14_lpi_2_dfm_2_mx0c1;
  wire BATCH_LOOP_stage_v_mx0c1;
  wire BATCH_LOOP_stage_v_2_mx0c0;
  wire BATCH_LOOP_stage_v_3_mx0c0;
  wire BATCH_LOOP_stage_v_4_mx0c0;
  wire BATCH_LOOP_stage_v_5_mx0c0;
  wire BATCH_LOOP_stage_v_6_mx0c0;
  wire BATCH_LOOP_stage_v_7_mx0c0;
  wire BATCH_LOOP_stage_v_8_mx0c0;
  wire BATCH_LOOP_stage_v_9_mx0c0;
  wire BATCH_LOOP_stage_v_10_mx0c0;
  wire BATCH_LOOP_stage_v_11_mx0c0;
  wire BATCH_LOOP_stage_v_12_mx0c0;
  wire [27:0] BATCH_LOOP_acc_3_psp_lpi_2_mx1;
  wire exit_STORE_CTRL_LOOP_lpi_2_mx1;
  wire exit_CALC_SOFTMAX_LOOP_lpi_2_mx1;
  wire [1:0] lfst_exit_STORE_LOOP_lpi_2_1_0_mx0;
  wire [3:0] STORE_LOOP_i_4_0_lpi_2_3_0_mx1;
  wire STORE_LOOP_and_40_cse_mx0w0;
  wire [27:0] BATCH_LOOP_acc_3_psp_sva_1;
  wire [28:0] nl_BATCH_LOOP_acc_3_psp_sva_1;
  wire lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1;
  wire STORE_LOOP_or_34_cse_1;
  wire [3:0] STORE_LOOP_i_4_0_lpi_2_dfm_1_3_0_1;
  wire BATCH_LOOP_BATCH_LOOP_or_51_cse_1;
  wire BATCH_LOOP_BATCH_LOOP_or_6_cse_1;
  wire BATCH_LOOP_BATCH_LOOP_or_4_cse_1;
  wire [18:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire signed [19:0] nl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire [3:0] CALC_SOFTMAX_LOOP_i_4_0_lpi_2_dfm_2_3_0_1;
  wire [18:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire [6:0] libraries_leading_sign_71_0_1bc993dc735dc189e3e2a7ebf4857c14bb7e_1;
  wire STORE_LOOP_and_195_rgt;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_and_6_rgt;
  wire and_1001_rgt;
  wire CALC_SOFTMAX_LOOP_and_65_cse;
  reg reg_LOAD_LOOP_and_1_svs_1_cse;
  reg reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse;
  wire BATCH_LOOP_if_acc_itm_32_1;

  wire[0:0] mux_311_nl;
  wire[0:0] mux_310_nl;
  wire[0:0] mux_309_nl;
  wire[0:0] mux_308_nl;
  wire[0:0] mux_307_nl;
  wire[0:0] mux_305_nl;
  wire[0:0] mux_304_nl;
  wire[0:0] mux_303_nl;
  wire[0:0] mux_302_nl;
  wire[0:0] and_nl;
  wire[0:0] mux_295_nl;
  wire[0:0] mux_294_nl;
  wire[0:0] mux_293_nl;
  wire[0:0] mux_292_nl;
  wire[0:0] mux_291_nl;
  wire[0:0] mux_279_nl;
  wire[0:0] nor_152_nl;
  wire[0:0] mux_264_nl;
  wire[0:0] mux_263_nl;
  wire[0:0] nor_154_nl;
  wire[0:0] mux_339_nl;
  wire[0:0] or_1067_nl;
  wire[0:0] or_735_nl;
  wire[0:0] and_205_nl;
  wire[0:0] STORE_LOOP_and_193_nl;
  wire[0:0] mux_480_nl;
  wire[0:0] mux_479_nl;
  wire[0:0] mux_478_nl;
  wire[0:0] mux_477_nl;
  wire[0:0] mux_476_nl;
  wire[0:0] mux_475_nl;
  wire[0:0] mux_474_nl;
  wire[0:0] mux_473_nl;
  wire[0:0] mux_472_nl;
  wire[0:0] mux_470_nl;
  wire[0:0] mux_469_nl;
  wire[0:0] nor_146_nl;
  wire[0:0] mux_468_nl;
  wire[0:0] mux_467_nl;
  wire[0:0] or_388_nl;
  wire[0:0] mux_466_nl;
  wire[0:0] or_387_nl;
  wire[0:0] mux_465_nl;
  wire[0:0] mux_456_nl;
  wire[0:0] mux_444_nl;
  wire[0:0] mux_593_nl;
  wire[0:0] and_384_nl;
  wire[0:0] mux_592_nl;
  wire[0:0] and_383_nl;
  wire[0:0] mux_591_nl;
  wire[0:0] and_382_nl;
  wire[0:0] mux_590_nl;
  wire[0:0] and_381_nl;
  wire[0:0] mux_589_nl;
  wire[0:0] and_380_nl;
  wire[0:0] mux_588_nl;
  wire[0:0] and_379_nl;
  wire[0:0] mux_587_nl;
  wire[0:0] and_378_nl;
  wire[0:0] mux_586_nl;
  wire[0:0] and_376_nl;
  wire[0:0] mux_585_nl;
  wire[0:0] and_375_nl;
  wire[0:0] mux_584_nl;
  wire[0:0] nor_236_nl;
  wire[0:0] and_374_nl;
  wire[0:0] mux_594_nl;
  wire[0:0] mux_595_nl;
  wire[0:0] mux_596_nl;
  wire[0:0] mux_597_nl;
  wire[0:0] mux_598_nl;
  wire[0:0] mux_599_nl;
  wire[0:0] mux_601_nl;
  wire[0:0] and_392_nl;
  wire[0:0] mux_759_nl;
  wire[0:0] nor_194_nl;
  wire[0:0] BATCH_LOOP_b_not_1_nl;
  wire[0:0] mux_826_nl;
  wire[0:0] nor_309_nl;
  wire[0:0] mux_825_nl;
  wire[0:0] mux_824_nl;
  wire[0:0] mux_822_nl;
  wire[0:0] mux_821_nl;
  wire[0:0] mux_820_nl;
  wire[0:0] mux_819_nl;
  wire[0:0] or_54_nl;
  wire[0:0] nor_310_nl;
  wire[0:0] BATCH_LOOP_mux_25_nl;
  wire[0:0] nor_301_nl;
  wire[0:0] mux_844_nl;
  wire[0:0] and_746_nl;
  wire[0:0] mux_861_nl;
  wire[0:0] and_766_nl;
  wire[0:0] mux_877_nl;
  wire[0:0] and_785_nl;
  wire[0:0] mux_892_nl;
  wire[0:0] and_803_nl;
  wire[0:0] mux_906_nl;
  wire[0:0] and_820_nl;
  wire[0:0] mux_919_nl;
  wire[0:0] and_836_nl;
  wire[0:0] mux_931_nl;
  wire[0:0] and_851_nl;
  wire[0:0] mux_942_nl;
  wire[0:0] and_865_nl;
  wire[0:0] and_872_nl;
  wire[0:0] mux_945_nl;
  wire[0:0] and_870_nl;
  wire[0:0] mux_944_nl;
  wire[0:0] and_869_nl;
  wire[0:0] mux_943_nl;
  wire[0:0] nor_125_nl;
  wire[0:0] and_868_nl;
  wire[0:0] and_873_nl;
  wire[0:0] and_874_nl;
  wire[0:0] and_875_nl;
  wire[0:0] mux_950_nl;
  wire[0:0] and_876_nl;
  wire[0:0] mux_952_nl;
  wire[0:0] and_879_nl;
  wire[0:0] and_878_nl;
  wire[0:0] mux_951_nl;
  wire[0:0] mux_961_nl;
  wire[0:0] and_891_nl;
  wire[0:0] BATCH_LOOP_mux_27_nl;
  wire[0:0] mux_728_nl;
  wire[0:0] nand_65_nl;
  wire[0:0] nand_66_nl;
  wire[0:0] BATCH_LOOP_mux_29_nl;
  wire[0:0] mux_735_nl;
  wire[0:0] nand_62_nl;
  wire[0:0] nand_63_nl;
  wire[0:0] BATCH_LOOP_mux_31_nl;
  wire[0:0] mux_741_nl;
  wire[0:0] nand_59_nl;
  wire[0:0] nand_60_nl;
  wire[0:0] BATCH_LOOP_mux_33_nl;
  wire[0:0] mux_746_nl;
  wire[0:0] nand_56_nl;
  wire[0:0] nand_57_nl;
  wire[0:0] BATCH_LOOP_mux_35_nl;
  wire[0:0] mux_754_nl;
  wire[0:0] mux_753_nl;
  wire[0:0] and_704_nl;
  wire[0:0] and_703_nl;
  wire[0:0] mux_752_nl;
  wire[0:0] and_701_nl;
  wire[0:0] mux_751_nl;
  wire[0:0] mux_750_nl;
  wire[0:0] mux_749_nl;
  wire[0:0] mux_748_nl;
  wire[0:0] BATCH_LOOP_mux_37_nl;
  wire[0:0] mux_758_nl;
  wire[0:0] mux_757_nl;
  wire[0:0] and_713_nl;
  wire[0:0] mux_756_nl;
  wire[0:0] and_711_nl;
  wire[0:0] mux_755_nl;
  wire[0:0] nor_195_nl;
  wire[0:0] BATCH_LOOP_mux_39_nl;
  wire[0:0] mux_963_nl;
  wire[0:0] nand_50_nl;
  wire[0:0] nand_51_nl;
  wire[0:0] mux_962_nl;
  wire[0:0] BATCH_LOOP_mux_41_nl;
  wire[0:0] mux_964_nl;
  wire[0:0] nand_48_nl;
  wire[0:0] nand_49_nl;
  wire[0:0] mux_966_nl;
  wire[0:0] and_1747_nl;
  wire[0:0] mux_968_nl;
  wire[0:0] and_1745_nl;
  wire[0:0] and_987_nl;
  wire[0:0] and_992_nl;
  wire[0:0] mux_970_nl;
  wire[0:0] and_1743_nl;
  wire[0:0] and_997_nl;
  wire[0:0] STORE_LOOP_mux_43_nl;
  wire[66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_15_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_79_nl;
  wire[66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_14_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_76_nl;
  wire[66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_13_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_73_nl;
  wire[66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_12_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_70_nl;
  wire[66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_11_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_67_nl;
  wire[66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_10_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_64_nl;
  wire[66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_9_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_61_nl;
  wire[66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_8_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_58_nl;
  wire[66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_2_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_32_nl;
  wire[66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_7_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_55_nl;
  wire[66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_1_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_37_nl;
  wire[66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_6_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_52_nl;
  wire[66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_5_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_49_nl;
  wire[66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_4_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_46_nl;
  wire[66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_40_nl;
  wire[66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_3_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_43_nl;
  wire[0:0] nor_305_nl;
  wire[0:0] and_1812_nl;
  wire[0:0] LOAD_LOOP_LOAD_LOOP_and_1_nl;
  wire[0:0] LOAD_LOOP_LOAD_LOOP_and_2_nl;
  wire[0:0] BATCH_LOOP_or_94_nl;
  wire[0:0] STORE_CTRL_LOOP_mux_1_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_mux_8_nl;
  wire[0:0] STORE_LOOP_STORE_LOOP_nor_8_nl;
  wire[0:0] STORE_LOOP_and_191_nl;
  wire[0:0] STORE_LOOP_mux_61_nl;
  wire[0:0] STORE_LOOP_STORE_LOOP_nor_nl;
  wire[0:0] or_620_nl;
  wire[32:0] BATCH_LOOP_if_acc_nl;
  wire[33:0] nl_BATCH_LOOP_if_acc_nl;
  wire[0:0] STORE_LOOP_mux_153_nl;
  wire[0:0] STORE_LOOP_and_94_nl;
  wire[0:0] STORE_LOOP_and_95_nl;
  wire[0:0] STORE_LOOP_or_50_nl;
  wire[1:0] STORE_LOOP_and_nl;
  wire[0:0] nor_306_nl;
  wire[0:0] and_1810_nl;
  wire[0:0] nor_307_nl;
  wire[0:0] and_1808_nl;
  wire[4:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_10_nl;
  wire[2:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_11_nl;
  wire[0:0] or_170_nl;
  wire[0:0] mux_983_nl;
  wire[0:0] or_177_nl;
  wire[0:0] or_179_nl;
  wire[0:0] mux_246_nl;
  wire[0:0] mux_248_nl;
  wire[0:0] or_178_nl;
  wire[0:0] mux_251_nl;
  wire[0:0] mux_250_nl;
  wire[0:0] mux_256_nl;
  wire[0:0] nand_20_nl;
  wire[0:0] mux_261_nl;
  wire[0:0] mux_260_nl;
  wire[0:0] mux_258_nl;
  wire[0:0] or_175_nl;
  wire[0:0] mux_254_nl;
  wire[0:0] or_176_nl;
  wire[0:0] mux_241_nl;
  wire[0:0] nand_19_nl;
  wire[0:0] or_161_nl;
  wire[0:0] or_160_nl;
  wire[0:0] or_190_nl;
  wire[0:0] mux_267_nl;
  wire[0:0] mux_266_nl;
  wire[0:0] and_97_nl;
  wire[0:0] mux_270_nl;
  wire[0:0] mux_276_nl;
  wire[0:0] mux_275_nl;
  wire[0:0] mux_274_nl;
  wire[0:0] mux_273_nl;
  wire[0:0] mux_282_nl;
  wire[0:0] mux_285_nl;
  wire[0:0] mux_284_nl;
  wire[0:0] or_195_nl;
  wire[0:0] mux_288_nl;
  wire[0:0] mux_298_nl;
  wire[0:0] mux_297_nl;
  wire[0:0] nand_23_nl;
  wire[0:0] nor_45_nl;
  wire[0:0] or_207_nl;
  wire[0:0] nor_253_nl;
  wire[0:0] and_110_nl;
  wire[0:0] and_111_nl;
  wire[0:0] and_113_nl;
  wire[0:0] and_114_nl;
  wire[0:0] and_115_nl;
  wire[0:0] and_116_nl;
  wire[0:0] and_117_nl;
  wire[0:0] and_118_nl;
  wire[0:0] and_119_nl;
  wire[0:0] and_120_nl;
  wire[0:0] and_126_nl;
  wire[0:0] mux_337_nl;
  wire[0:0] mux_335_nl;
  wire[0:0] mux_334_nl;
  wire[0:0] mux_420_nl;
  wire[0:0] or_25_nl;
  wire[0:0] mux_423_nl;
  wire[0:0] mux_425_nl;
  wire[0:0] mux_427_nl;
  wire[0:0] mux_422_nl;
  wire[0:0] mux_430_nl;
  wire[0:0] mux_429_nl;
  wire[0:0] mux_440_nl;
  wire[0:0] mux_439_nl;
  wire[0:0] mux_437_nl;
  wire[0:0] mux_436_nl;
  wire[0:0] mux_435_nl;
  wire[0:0] mux_434_nl;
  wire[0:0] nand_33_nl;
  wire[0:0] or_296_nl;
  wire[0:0] mux_454_nl;
  wire[0:0] mux_453_nl;
  wire[0:0] mux_452_nl;
  wire[0:0] or_369_nl;
  wire[0:0] mux_451_nl;
  wire[0:0] or_368_nl;
  wire[0:0] mux_450_nl;
  wire[0:0] mux_449_nl;
  wire[0:0] or_367_nl;
  wire[0:0] mux_448_nl;
  wire[0:0] or_366_nl;
  wire[0:0] mux_462_nl;
  wire[0:0] nor_246_nl;
  wire[0:0] mux_461_nl;
  wire[0:0] nor_247_nl;
  wire[0:0] mux_460_nl;
  wire[0:0] mux_459_nl;
  wire[0:0] or_377_nl;
  wire[0:0] mux_458_nl;
  wire[0:0] or_376_nl;
  wire[0:0] nor_248_nl;
  wire[0:0] nor_243_nl;
  wire[0:0] nor_245_nl;
  wire[0:0] mux_486_nl;
  wire[0:0] mux_483_nl;
  wire[0:0] nor_242_nl;
  wire[0:0] mux_489_nl;
  wire[0:0] mux_488_nl;
  wire[0:0] mux_496_nl;
  wire[0:0] mux_495_nl;
  wire[0:0] mux_494_nl;
  wire[0:0] mux_493_nl;
  wire[0:0] mux_492_nl;
  wire[0:0] mux_500_nl;
  wire[0:0] mux_503_nl;
  wire[0:0] mux_509_nl;
  wire[0:0] mux_508_nl;
  wire[0:0] mux_507_nl;
  wire[0:0] mux_506_nl;
  wire[0:0] mux_513_nl;
  wire[0:0] mux_515_nl;
  wire[0:0] mux_529_nl;
  wire[0:0] mux_528_nl;
  wire[0:0] mux_527_nl;
  wire[0:0] mux_526_nl;
  wire[0:0] mux_525_nl;
  wire[0:0] mux_524_nl;
  wire[0:0] mux_523_nl;
  wire[0:0] mux_521_nl;
  wire[0:0] mux_520_nl;
  wire[0:0] mux_519_nl;
  wire[0:0] mux_518_nl;
  wire[0:0] mux_512_nl;
  wire[0:0] mux_498_nl;
  wire[0:0] mux_481_nl;
  wire[0:0] and_1760_nl;
  wire[0:0] mux_565_nl;
  wire[0:0] and_348_nl;
  wire[0:0] mux_564_nl;
  wire[0:0] and_347_nl;
  wire[0:0] mux_563_nl;
  wire[0:0] and_346_nl;
  wire[0:0] mux_562_nl;
  wire[0:0] and_345_nl;
  wire[0:0] mux_561_nl;
  wire[0:0] and_344_nl;
  wire[0:0] mux_560_nl;
  wire[0:0] and_343_nl;
  wire[0:0] mux_559_nl;
  wire[0:0] and_342_nl;
  wire[0:0] mux_558_nl;
  wire[0:0] and_341_nl;
  wire[0:0] mux_557_nl;
  wire[0:0] and_340_nl;
  wire[0:0] mux_556_nl;
  wire[0:0] and_339_nl;
  wire[0:0] mux_555_nl;
  wire[0:0] and_338_nl;
  wire[0:0] mux_554_nl;
  wire[0:0] and_337_nl;
  wire[0:0] mux_553_nl;
  wire[0:0] and_336_nl;
  wire[0:0] mux_552_nl;
  wire[0:0] and_335_nl;
  wire[0:0] mux_551_nl;
  wire[0:0] and_333_nl;
  wire[0:0] mux_550_nl;
  wire[0:0] and_332_nl;
  wire[0:0] mux_549_nl;
  wire[0:0] nor_238_nl;
  wire[0:0] and_331_nl;
  wire[0:0] and_1758_nl;
  wire[0:0] mux_813_nl;
  wire[0:0] nand_38_nl;
  wire[0:0] mux_815_nl;
  wire[0:0] nand_40_nl;
  wire[0:0] and_1746_nl;
  wire[0:0] and_1744_nl;
  wire[0:0] mux_340_nl;
  wire[0:0] or_1049_nl;
  wire[0:0] mux_333_nl;
  wire[0:0] mux_602_nl;
  wire[0:0] nor_143_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [70:0] nl_operator_91_21_false_AC_TRN_AC_WRAP_rshift_rg_a;
  assign nl_operator_91_21_false_AC_TRN_AC_WRAP_rshift_rg_a = {ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_1
      , ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm_1
      , 50'b00000000000000000000000000000000000000000000000000};
  wire [7:0] nl_operator_91_21_false_AC_TRN_AC_WRAP_rshift_rg_s;
  assign nl_operator_91_21_false_AC_TRN_AC_WRAP_rshift_rg_s = {ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_7_2
      , ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_1_0};
  wire[10:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl;
  wire[11:0] nl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl;
  wire [20:0] nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_a;
  assign nl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl
      = conv_u2u_9_11(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_sdt_18_0_itm_1)
      + ({ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_2_itm_1
      , 1'b1 , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_3_itm_1});
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl
      = nl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl[10:0];
  assign nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_a = {ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl
      , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_sdt_18_0_1_itm_1};
  wire [6:0] nl_operator_71_0_false_AC_TRN_AC_WRAP_lshift_rg_s;
  assign nl_operator_71_0_false_AC_TRN_AC_WRAP_lshift_rg_s = ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_sva_1;
  wire [0:0] nl_softmax_cxx_catapult_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_oswt_unreg;
  assign nl_softmax_cxx_catapult_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_oswt_unreg
      = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2) & (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1]))
      & and_dcpl_43 & (fsm_output[2]);
  wire [66:0] nl_softmax_cxx_catapult_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat;
  assign nl_softmax_cxx_catapult_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat
      = {59'b01100000000000000000000000000010000000000000000000000000000 , dma_read_ctrl_rsci_idat_7_4
      , 4'b0000};
  wire [0:0] nl_softmax_cxx_catapult_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_oswt_unreg;
  assign nl_softmax_cxx_catapult_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_oswt_unreg
      = (~(CALC_SOFTMAX_LOOP_asn_19_itm_1 | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2))
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0==2'b11) & (~ exit_BATCH_LOOP_lpi_2_dfm_1)
      & BATCH_LOOP_and_21_tmp & (fsm_output[2]);
  wire [66:0] nl_softmax_cxx_catapult_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat;
  assign nl_softmax_cxx_catapult_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat
      = {35'b01100000000000000000000000000010000 , dma_write_ctrl_rsci_idat_31_4
      , 4'b0000};
  wire [0:0] nl_softmax_cxx_catapult_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg;
  assign nl_softmax_cxx_catapult_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg
      = and_dcpl_91 & (fsm_output[2]);
  wire [63:0] nl_softmax_cxx_catapult_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat;
  assign nl_softmax_cxx_catapult_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat
      = {32'b11011110101011011011111011101111 , dma_write_chnl_rsci_idat_31_0};
  wire [0:0] nl_softmax_cxx_catapult_core_plm_out_data_rsci_1_inst_plm_out_data_rsci_oswt_unreg;
  assign nl_softmax_cxx_catapult_core_plm_out_data_rsci_1_inst_plm_out_data_rsci_oswt_unreg
      = or_622_cse & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_1_0==2'b11) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_2)
      & (~(exit_BATCH_LOOP_lpi_2_dfm_st_20 | CALC_SOFTMAX_LOOP_asn_itm_20)) & plm_out_data_rsci_bawt
      & BATCH_LOOP_stage_old_v_20 & BATCH_LOOP_stage_0_21 & (fsm_output[2]);
  wire [66:0] nl_softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp_inst_CALC_SOFTMAX_LOOP_mul_cmp_a_core;
  assign nl_softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp_inst_CALC_SOFTMAX_LOOP_mul_cmp_a_core
      = CALC_SOFTMAX_LOOP_mux_itm_4;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_and_7_nl;
  wire [90:0] nl_softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp_inst_CALC_SOFTMAX_LOOP_mul_cmp_b_core;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_and_7_nl
      = LOAD_LOOP_and_1_svs_8 & STORE_LOOP_and_42_itm_4 & (~((~ BATCH_LOOP_stage_v_8)
      | STORE_LOOP_asn_51_itm_8));
  assign nl_softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp_inst_CALC_SOFTMAX_LOOP_mul_cmp_b_core
      = MUX_v_91_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2,
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_or_1_itm,
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_and_7_nl);
  wire [0:0] nl_softmax_cxx_catapult_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_inst_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_oswt_unreg;
  assign nl_softmax_cxx_catapult_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_inst_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_oswt_unreg
      = mux_tmp_315 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_3) & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[1])
      & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2) & (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[0]))
      & ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt
      & BATCH_LOOP_stage_0_4 & BATCH_LOOP_stage_v_3 & (fsm_output[2]);
  esp_acc_softmax_cxx_catapult_leading_sign_71_0  leading_sign_71_0_rg (
      .mantissa(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1),
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
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_conf_info_rsci softmax_cxx_catapult_core_conf_info_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .core_wen(core_wen),
      .conf_info_rsci_oswt(reg_conf_info_rsci_irdy_core_psct_cse),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_ctrl_rsci softmax_cxx_catapult_core_dma_read_ctrl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_read_ctrl_rsc_dat(dma_read_ctrl_rsc_dat),
      .dma_read_ctrl_rsc_vld(dma_read_ctrl_rsc_vld),
      .dma_read_ctrl_rsc_rdy(dma_read_ctrl_rsc_rdy),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dma_read_ctrl_rsci_oswt_unreg(nl_softmax_cxx_catapult_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_oswt_unreg[0:0]),
      .dma_read_ctrl_rsci_bawt(dma_read_ctrl_rsci_bawt),
      .dma_read_ctrl_rsci_iswt0(reg_dma_read_ctrl_rsci_ivld_core_psct_cse),
      .dma_read_ctrl_rsci_irdy_mxwt(dma_read_ctrl_rsci_irdy_mxwt),
      .dma_read_ctrl_rsci_idat(nl_softmax_cxx_catapult_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat[66:0])
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_ctrl_rsci softmax_cxx_catapult_core_dma_write_ctrl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_write_ctrl_rsc_dat(dma_write_ctrl_rsc_dat),
      .dma_write_ctrl_rsc_vld(dma_write_ctrl_rsc_vld),
      .dma_write_ctrl_rsc_rdy(dma_write_ctrl_rsc_rdy),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dma_write_ctrl_rsci_oswt_unreg(nl_softmax_cxx_catapult_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_oswt_unreg[0:0]),
      .dma_write_ctrl_rsci_bawt(dma_write_ctrl_rsci_bawt),
      .dma_write_ctrl_rsci_iswt0(reg_dma_write_ctrl_rsci_ivld_core_psct_cse),
      .dma_write_ctrl_rsci_irdy_mxwt(dma_write_ctrl_rsci_irdy_mxwt),
      .dma_write_ctrl_rsci_idat(nl_softmax_cxx_catapult_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat[66:0])
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_read_chnl_rsci softmax_cxx_catapult_core_dma_read_chnl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_read_chnl_rsc_dat(dma_read_chnl_rsc_dat),
      .dma_read_chnl_rsc_vld(dma_read_chnl_rsc_vld),
      .dma_read_chnl_rsc_rdy(dma_read_chnl_rsc_rdy),
      .core_wen(core_wen),
      .dma_read_chnl_rsci_oswt_unreg(and_1009_rmff),
      .dma_read_chnl_rsci_bawt(dma_read_chnl_rsci_bawt),
      .dma_read_chnl_rsci_iswt0(reg_dma_read_chnl_rsci_irdy_core_psct_cse),
      .dma_read_chnl_rsci_wen_comp(dma_read_chnl_rsci_wen_comp),
      .dma_read_chnl_rsci_idat_mxwt(dma_read_chnl_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_dma_write_chnl_rsci softmax_cxx_catapult_core_dma_write_chnl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_write_chnl_rsc_dat(dma_write_chnl_rsc_dat),
      .dma_write_chnl_rsc_vld(dma_write_chnl_rsc_vld),
      .dma_write_chnl_rsc_rdy(dma_write_chnl_rsc_rdy),
      .core_wen(core_wen),
      .dma_write_chnl_rsci_oswt_unreg(nl_softmax_cxx_catapult_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg[0:0]),
      .dma_write_chnl_rsci_bawt(dma_write_chnl_rsci_bawt),
      .dma_write_chnl_rsci_iswt0(reg_dma_write_chnl_rsci_ivld_core_psct_cse),
      .dma_write_chnl_rsci_wen_comp(dma_write_chnl_rsci_wen_comp),
      .dma_write_chnl_rsci_idat(nl_softmax_cxx_catapult_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat[63:0])
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_acc_done_rsci softmax_cxx_catapult_core_acc_done_rsci_inst
      (
      .acc_done_rsc_vld(acc_done_rsc_vld),
      .core_wten(core_wten),
      .acc_done_rsci_iswt0(reg_acc_done_rsci_ivld_core_psct_cse)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_wait_dp softmax_cxx_catapult_core_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_plm_out_data_rsci_1 softmax_cxx_catapult_core_plm_out_data_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_data_rsci_q_d(plm_out_data_rsci_q_d),
      .plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d(plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_out_data_rsci_oswt_unreg(nl_softmax_cxx_catapult_core_plm_out_data_rsci_1_inst_plm_out_data_rsci_oswt_unreg[0:0]),
      .plm_out_data_rsci_bawt(plm_out_data_rsci_bawt),
      .plm_out_data_rsci_iswt0(reg_CALC_SOFTMAX_LOOP_mul_cmp_oswt_cse),
      .plm_out_data_rsci_oswt_unreg_1(or_tmp_587),
      .plm_out_data_rsci_iswt0_1(reg_plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse),
      .plm_out_data_rsci_q_d_mxwt(plm_out_data_rsci_q_d_mxwt),
      .plm_out_data_rsci_we_d_pff(plm_out_data_rsci_we_d_iff),
      .plm_out_data_rsci_iswt0_pff(and_1015_rmff),
      .plm_out_data_rsci_iswt0_1_pff(and_1017_rmff)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp
      softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg(and_1015_rmff),
      .CALC_SOFTMAX_LOOP_mul_cmp_bawt(CALC_SOFTMAX_LOOP_mul_cmp_bawt),
      .CALC_SOFTMAX_LOOP_mul_cmp_iswt11(CALC_SOFTMAX_LOOP_mul_cmp_iswt11),
      .CALC_SOFTMAX_LOOP_mul_cmp_a_core(nl_softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp_inst_CALC_SOFTMAX_LOOP_mul_cmp_a_core[66:0]),
      .CALC_SOFTMAX_LOOP_mul_cmp_b_core(nl_softmax_cxx_catapult_core_CALC_SOFTMAX_LOOP_mul_cmp_inst_CALC_SOFTMAX_LOOP_mul_cmp_b_core[90:0]),
      .CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt(CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp
      softmax_cxx_catapult_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_b_core(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_b_core),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_oswt_unreg(nl_softmax_cxx_catapult_core_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_inst_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_oswt_unreg[0:0]),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_iswt1(reg_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_iswt1_cse),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_oreg),
      .ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_staller softmax_cxx_catapult_core_staller_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .dma_read_chnl_rsci_wen_comp(dma_read_chnl_rsci_wen_comp),
      .dma_write_chnl_rsci_wen_comp(dma_write_chnl_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core_core_fsm softmax_cxx_catapult_core_core_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output),
      .BATCH_LOOP_C_0_tr0(BATCH_LOOP_nor_22_tmp)
    );
  assign or_204_cse = (CALC_SOFTMAX_LOOP_i_4_0_sva_1_1[4]) | exit_CALC_SOFTMAX_LOOP_lpi_2;
  assign or_194_cse = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0!=2'b11) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2;
  assign and_1742_cse = or_194_cse & (~ exit_BATCH_LOOP_lpi_2_dfm_1);
  assign nor_153_cse = ~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_302_nl = MUX_s_1_2_2(mux_tmp_285, mux_tmp_284, dma_write_ctrl_rsci_irdy_mxwt);
  assign mux_303_nl = MUX_s_1_2_2(mux_302_nl, mux_tmp_285, CALC_SOFTMAX_LOOP_asn_19_itm_1);
  assign mux_304_nl = MUX_s_1_2_2(mux_303_nl, mux_tmp_284, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_305_nl = MUX_s_1_2_2(mux_tmp_285, mux_304_nl, or_204_cse);
  assign mux_307_nl = MUX_s_1_2_2(mux_305_nl, mux_tmp_285, and_1742_cse);
  assign mux_308_nl = MUX_s_1_2_2((~ mux_307_nl), mux_277_cse, BATCH_LOOP_if_acc_itm_32_1);
  assign mux_291_nl = MUX_s_1_2_2(mux_tmp_274, mux_tmp_272, dma_write_ctrl_rsci_irdy_mxwt);
  assign mux_292_nl = MUX_s_1_2_2(mux_291_nl, mux_tmp_274, CALC_SOFTMAX_LOOP_asn_19_itm_1);
  assign mux_293_nl = MUX_s_1_2_2(mux_292_nl, mux_tmp_272, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_294_nl = MUX_s_1_2_2(mux_tmp_274, mux_293_nl, or_204_cse);
  assign mux_295_nl = MUX_s_1_2_2(mux_294_nl, mux_tmp_274, or_194_cse);
  assign and_nl = BATCH_LOOP_if_acc_itm_32_1 & mux_295_nl;
  assign mux_309_nl = MUX_s_1_2_2(mux_308_nl, and_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1[1]);
  assign nor_152_nl = ~((lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1[1]) | (~ mux_277_cse));
  assign mux_279_nl = MUX_s_1_2_2(nor_152_nl, BATCH_LOOP_if_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_310_nl = MUX_s_1_2_2(mux_309_nl, mux_279_nl, STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign mux_264_nl = MUX_s_1_2_2(nor_153_cse, BATCH_LOOP_if_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_311_nl = MUX_s_1_2_2(mux_310_nl, mux_264_nl, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign nor_154_nl = ~(lfst_exit_STORE_LOOP_lpi_2_2 | (lfst_exit_STORE_LOOP_lpi_2_1_0[1]));
  assign mux_263_nl = MUX_s_1_2_2(nor_154_nl, BATCH_LOOP_if_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_312_cse = MUX_s_1_2_2(mux_311_nl, mux_263_nl, or_50_cse);
  assign and_1009_rmff = and_dcpl_46 & (fsm_output[2]);
  assign and_1015_rmff = mux_tmp_299 & BATCH_LOOP_stage_0_20 & CALC_SOFTMAX_LOOP_mul_cmp_bawt
      & (~ exit_BATCH_LOOP_lpi_2_dfm_st_19) & (~ CALC_SOFTMAX_LOOP_asn_itm_19) &
      (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_1_0==2'b11) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_2)
      & BATCH_LOOP_stage_old_v_19 & (fsm_output[2]);
  assign and_1017_rmff = mux_tmp_299 & BATCH_LOOP_stage_0_20 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_19)
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_1_0==2'b00) & lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_2
      & BATCH_LOOP_stage_old_v_19 & (fsm_output[2]);
  assign CALC_SOFTMAX_LOOP_i_mux_rmff = MUX_v_4_2_2(CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_18,
      plm_out_data_rsci_wadr_d_reg, or_tmp_608);
  assign or_735_nl = (~ (fsm_output[2])) | (~ mux_tmp_299) | (~ BATCH_LOOP_stage_0_20)
      | exit_BATCH_LOOP_lpi_2_dfm_st_19 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_1_0!=2'b00)
      | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_2) | (~ BATCH_LOOP_stage_old_v_19);
  assign STORE_LOOP_i_mux_rmff = MUX_v_4_2_2(STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_18,
      plm_out_data_rsci_radr_d_reg, or_735_nl);
  assign CALC_SOFTMAX_LOOP_mux_1_rmff = MUX_v_32_2_2(CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt,
      plm_out_data_rsci_d_d_reg, or_tmp_608);
  assign STORE_LOOP_and_100_cse = core_wen & (~((~ (fsm_output[2])) | not_tmp_152
      | not_tmp_41));
  assign CALC_SOFTMAX_LOOP_and_cse = core_wen & (~((~ (fsm_output[2])) | (~ mux_tmp_300)
      | not_tmp_46));
  assign and_205_nl = BATCH_LOOP_stage_0_21 & or_9_cse & or_622_cse;
  assign mux_416_cse = MUX_s_1_2_2(or_622_cse, and_205_nl, BATCH_LOOP_stage_old_v_20);
  assign CALC_SOFTMAX_LOOP_and_40_cse = core_wen & (fsm_output[2]) & or_624_cse &
      mux_416_cse & BATCH_LOOP_stage_0_20 & BATCH_LOOP_stage_old_v_19;
  assign STORE_LOOP_and_106_cse = core_wen & (fsm_output[2]) & mux_tmp_402 & BATCH_LOOP_stage_old_v_20
      & BATCH_LOOP_stage_0_21;
  assign LOAD_LOOP_i_and_cse = core_wen & ((fsm_output[3:2]!=2'b00));
  assign BATCH_LOOP_and_26_cse = core_wen & (fsm_output[2]) & BATCH_LOOP_and_22_tmp;
  assign STORE_LOOP_and_195_rgt = and_dcpl_106 & (fsm_output[2]);
  assign CALC_SOFTMAX_LOOP_and_41_cse = core_wen & (((~ mux_tmp_427) & BATCH_LOOP_and_22_tmp
      & (fsm_output[2])) | or_tmp_642);
  assign or_50_cse = (~ BATCH_LOOP_and_21_tmp) | STORE_LOOP_asn_51_itm_1;
  assign STORE_LOOP_and_110_cse = core_wen & ((((~ mux_tmp_426) | BATCH_LOOP_if_acc_itm_32_1)
      & BATCH_LOOP_and_22_tmp & (fsm_output[2])) | or_tmp_651);
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_and_cse = core_wen
      & (~((~ (fsm_output[2])) | (~(((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3!=71'b00000000000000000000000000000000000000000000000000000000000000000000000))
      & mux_tmp_311)) | or_dcpl_50 | exit_BATCH_LOOP_lpi_2_dfm_st_7 | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_1_0[1]))
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_2 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_1_0[0])
      | (~ LOAD_LOOP_and_1_svs_st_7)));
  assign CALC_SOFTMAX_LOOP_and_43_cse = core_wen & (~((~ (fsm_output[2])) | mux_tmp_427
      | (~ BATCH_LOOP_and_22_tmp)));
  assign STORE_LOOP_and_113_cse = core_wen & (fsm_output[2]) & (~(mux_tmp_426 & (~
      BATCH_LOOP_if_acc_itm_32_1))) & BATCH_LOOP_and_22_tmp;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_and_cse = core_wen
      & (~((~ (fsm_output[2])) | (~(((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2!=71'b00000000000000000000000000000000000000000000000000000000000000000000000))
      & mux_tmp_312)) | or_dcpl_59 | exit_BATCH_LOOP_lpi_2_dfm_st_6 | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_2
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_1_0!=2'b10) | (~ LOAD_LOOP_and_1_svs_st_6)));
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_39_cse
      = core_wen & (or_tmp_680 | (fsm_output[3]));
  assign CALC_EXP_LOOP_i_and_cse = core_wen & (fsm_output[2]) & BATCH_LOOP_and_21_tmp;
  assign CALC_SOFTMAX_LOOP_i_and_2_cse = core_wen & ((exit_BATCH_LOOP_lpi_2_dfm_1
      & BATCH_LOOP_and_21_tmp & (fsm_output[2])) | or_tmp_740);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_and_3_rgt
      = STORE_LOOP_and_42_itm_4 & ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_mx0c1;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_and_6_rgt
      = LOAD_LOOP_and_1_svs_8 & ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_and_3_rgt;
  assign nor_236_nl = ~(nor_142_cse | BATCH_LOOP_stage_old_v_20);
  assign and_374_nl = or_624_cse & or_114_cse;
  assign mux_584_nl = MUX_s_1_2_2(nor_236_nl, and_374_nl, BATCH_LOOP_stage_0_21);
  assign and_375_nl = BATCH_LOOP_stage_0_20 & mux_584_nl;
  assign mux_585_nl = MUX_s_1_2_2(or_114_cse, and_375_nl, BATCH_LOOP_stage_old_v_19);
  assign and_376_nl = BATCH_LOOP_stage_0_19 & mux_585_nl;
  assign mux_586_nl = MUX_s_1_2_2(and_tmp_64, and_376_nl, BATCH_LOOP_stage_v_18);
  assign and_378_nl = BATCH_LOOP_stage_0_18 & mux_586_nl;
  assign mux_587_nl = MUX_s_1_2_2(and_tmp_64, and_378_nl, BATCH_LOOP_stage_v_17);
  assign and_379_nl = BATCH_LOOP_stage_0_17 & mux_587_nl;
  assign mux_588_nl = MUX_s_1_2_2(and_tmp_64, and_379_nl, BATCH_LOOP_stage_v_16);
  assign and_380_nl = BATCH_LOOP_stage_0_16 & mux_588_nl;
  assign mux_589_nl = MUX_s_1_2_2(and_tmp_64, and_380_nl, BATCH_LOOP_stage_v_15);
  assign and_381_nl = BATCH_LOOP_stage_0_15 & mux_589_nl;
  assign mux_590_nl = MUX_s_1_2_2(and_tmp_64, and_381_nl, BATCH_LOOP_stage_v_14);
  assign and_382_nl = BATCH_LOOP_stage_0_14 & mux_590_nl;
  assign mux_591_nl = MUX_s_1_2_2(and_tmp_64, and_382_nl, BATCH_LOOP_stage_v_13);
  assign and_383_nl = BATCH_LOOP_stage_0_13 & mux_591_nl;
  assign mux_592_nl = MUX_s_1_2_2(and_tmp_64, and_383_nl, BATCH_LOOP_stage_v_12);
  assign and_384_nl = BATCH_LOOP_stage_0_12 & mux_592_nl;
  assign mux_593_nl = MUX_s_1_2_2(and_tmp_64, and_384_nl, BATCH_LOOP_stage_v_11);
  assign and_385_cse = BATCH_LOOP_stage_0_11 & mux_593_nl;
  assign mux_594_nl = MUX_s_1_2_2(and_tmp_64, and_385_cse, BATCH_LOOP_stage_v_10);
  assign and_386_cse = BATCH_LOOP_stage_0_10 & mux_594_nl;
  assign mux_595_nl = MUX_s_1_2_2(and_tmp_64, and_386_cse, BATCH_LOOP_stage_v_9);
  assign and_387_cse = BATCH_LOOP_stage_0_9 & mux_595_nl;
  assign mux_596_nl = MUX_s_1_2_2(and_tmp_64, and_387_cse, BATCH_LOOP_stage_v_8);
  assign and_388_cse = BATCH_LOOP_stage_0_8 & mux_596_nl;
  assign mux_597_nl = MUX_s_1_2_2(and_tmp_64, and_388_cse, BATCH_LOOP_stage_v_7);
  assign and_389_cse = BATCH_LOOP_stage_0_7 & mux_597_nl;
  assign mux_598_nl = MUX_s_1_2_2(and_tmp_64, and_389_cse, BATCH_LOOP_stage_v_6);
  assign and_390_cse = BATCH_LOOP_stage_0_6 & mux_598_nl;
  assign mux_599_nl = MUX_s_1_2_2(and_tmp_64, and_390_cse, BATCH_LOOP_stage_v_5);
  assign and_391_cse = BATCH_LOOP_stage_0_5 & mux_599_nl;
  assign mux_600_cse = MUX_s_1_2_2(and_tmp_64, and_391_cse, BATCH_LOOP_stage_v_4);
  assign and_392_nl = or_623_cse & mux_600_cse;
  assign mux_601_nl = MUX_s_1_2_2(and_tmp_64, and_392_nl, BATCH_LOOP_stage_v_3);
  assign CALC_SOFTMAX_LOOP_and_47_cse = core_wen & or_622_cse & mux_601_nl;
  assign LOAD_LOOP_and_4_cse = core_wen & and_tmp_41;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse
      = core_wen & mux_tmp_663;
  assign or_622_cse = (~ BATCH_LOOP_stage_v_21) | exit_BATCH_LOOP_lpi_2_dfm_st_21
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_21_1_0!=2'b00) | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_21_2)
      | dma_write_chnl_rsci_bawt;
  assign or_623_cse = exit_BATCH_LOOP_lpi_2_dfm_st_3 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0!=2'b10)
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2 | ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt;
  assign nor_142_cse = ~(CALC_SOFTMAX_LOOP_mul_cmp_bawt | CALC_SOFTMAX_LOOP_asn_itm_19
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_1_0!=2'b11) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_2
      | exit_BATCH_LOOP_lpi_2_dfm_st_19);
  assign or_624_cse = CALC_SOFTMAX_LOOP_mul_cmp_bawt | CALC_SOFTMAX_LOOP_asn_itm_19
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_1_0!=2'b11) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_2
      | exit_BATCH_LOOP_lpi_2_dfm_st_19;
  assign and_745_cse = BATCH_LOOP_stage_0_4 & or_623_cse & mux_600_cse;
  assign nor_125_nl = ~(nor_142_cse | BATCH_LOOP_stage_old_v_20 | (~ or_622_cse));
  assign and_868_nl = or_624_cse & and_tmp_12;
  assign mux_943_nl = MUX_s_1_2_2(nor_125_nl, and_868_nl, BATCH_LOOP_stage_0_21);
  assign and_869_nl = BATCH_LOOP_stage_0_20 & mux_943_nl;
  assign mux_944_nl = MUX_s_1_2_2(and_tmp_12, and_869_nl, BATCH_LOOP_stage_old_v_19);
  assign and_870_nl = BATCH_LOOP_stage_0_19 & mux_944_nl;
  assign mux_945_nl = MUX_s_1_2_2(and_617_cse, and_870_nl, BATCH_LOOP_stage_v_18);
  assign and_872_nl = BATCH_LOOP_stage_0_18 & mux_945_nl;
  assign mux_946_cse = MUX_s_1_2_2(and_617_cse, and_872_nl, BATCH_LOOP_stage_v_17);
  assign and_873_nl = BATCH_LOOP_stage_0_17 & mux_946_cse;
  assign mux_947_cse = MUX_s_1_2_2(and_617_cse, and_873_nl, BATCH_LOOP_stage_v_16);
  assign and_874_nl = BATCH_LOOP_stage_0_16 & mux_947_cse;
  assign mux_948_cse = MUX_s_1_2_2(and_617_cse, and_874_nl, BATCH_LOOP_stage_v_15);
  assign and_875_nl = BATCH_LOOP_stage_0_15 & mux_948_cse;
  assign mux_949_cse = MUX_s_1_2_2(and_617_cse, and_875_nl, BATCH_LOOP_stage_v_14);
  assign and_876_nl = BATCH_LOOP_stage_0_14 & mux_949_cse;
  assign mux_950_nl = MUX_s_1_2_2(and_617_cse, and_876_nl, BATCH_LOOP_stage_v_13);
  assign and_877_cse = BATCH_LOOP_stage_0_13 & mux_950_nl;
  assign nor_196_cse = ~(BATCH_LOOP_stage_old_v_20 | (~ or_622_cse));
  assign CALC_SOFTMAX_LOOP_and_65_cse = core_wen & BATCH_LOOP_and_21_tmp;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_and_6_cse = core_wen
      & mux_tmp_952;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_5_cse
      = core_wen & ((fsm_output[1]) | or_tmp_680);
  assign and_1745_nl = BATCH_LOOP_stage_v_6 & BATCH_LOOP_stage_v_7;
  assign mux_968_nl = MUX_s_1_2_2(and_tmp_41, and_tmp_52, and_1745_nl);
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_and_7_cse = core_wen
      & mux_968_nl;
  assign or_114_cse = (~ BATCH_LOOP_stage_old_v_20) | plm_out_data_rsci_bawt | CALC_SOFTMAX_LOOP_asn_itm_20
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_1_0!=2'b11) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_2
      | exit_BATCH_LOOP_lpi_2_dfm_st_20;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_7_cse
      = core_wen & mux_tmp_954;
  assign and_1743_nl = BATCH_LOOP_stage_v_4 & BATCH_LOOP_stage_v_5;
  assign mux_970_nl = MUX_s_1_2_2(and_tmp_41, and_tmp_54, and_1743_nl);
  assign STORE_LOOP_and_137_cse = core_wen & mux_970_nl;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_42_rgt
      = STORE_LOOP_and_69_itm_3 & or_tmp_680;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_45_rgt
      = STORE_LOOP_and_67_itm_3 & or_tmp_680;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_48_rgt
      = STORE_LOOP_and_66_itm_3 & or_tmp_680;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_51_rgt
      = STORE_LOOP_and_65_itm_3 & or_tmp_680;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_54_rgt
      = STORE_LOOP_and_63_itm_3 & or_tmp_680;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_57_rgt
      = STORE_LOOP_and_61_itm_3 & or_tmp_680;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_60_rgt
      = STORE_LOOP_and_60_itm_3 & or_tmp_680;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_63_rgt
      = STORE_LOOP_and_59_itm_3 & or_tmp_680;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_66_rgt
      = STORE_LOOP_and_58_itm_3 & or_tmp_680;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_69_rgt
      = STORE_LOOP_and_57_itm_3 & or_tmp_680;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_72_rgt
      = STORE_LOOP_and_56_itm_3 & or_tmp_680;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_75_rgt
      = STORE_LOOP_and_55_itm_3 & or_tmp_680;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_78_rgt
      = STORE_LOOP_and_54_itm_3 & or_tmp_680;
  assign and_1001_rgt = (or_dcpl_91 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])
      | exit_BATCH_LOOP_lpi_2_dfm_1) & BATCH_LOOP_and_21_tmp;
  assign LOAD_LOOP_i_4_0_lpi_2_3_0_mx1 = MUX_v_4_2_2(LOAD_LOOP_i_4_0_lpi_2_dfm_2_3_0_mx0w0,
      LOAD_LOOP_i_4_0_lpi_2_3_0, or_50_cse);
  assign STORE_LOOP_mux_43_nl = MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1,
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign lfst_exit_STORE_LOOP_lpi_2_2_mx1 = MUX_s_1_2_2(STORE_LOOP_mux_43_nl, lfst_exit_STORE_LOOP_lpi_2_2,
      or_50_cse);
  assign exit_BATCH_LOOP_lpi_2_dfm_mx0w0 = (~ BATCH_LOOP_if_acc_itm_32_1) & exitL_exit_STORE_LOOP_sva_mx1;
  assign STORE_LOOP_equal_tmp_2_mx0w0 = lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0 &
      (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0==2'b00);
  assign nl_STORE_LOOP_acc_1_tmp = conv_u2u_4_5(STORE_LOOP_i_4_0_lpi_2_3_0_mx1) +
      5'b00001;
  assign STORE_LOOP_acc_1_tmp = nl_STORE_LOOP_acc_1_tmp[4:0];
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx1w0 = lfst_exit_STORE_LOOP_lpi_2_2_mx1
      & (~ BATCH_LOOP_if_acc_itm_32_1);
  assign STORE_LOOP_STORE_LOOP_STORE_LOOP_and_cse_mx0w1 = (BATCH_LOOP_acc_2_tmp[4])
      & (STORE_LOOP_acc_1_tmp[4]) & STORE_LOOP_equal_tmp_2_mx0w0;
  assign nl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_mx0w0
      = conv_s2u_9_11(ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[18:10])
      + ({1'b1 , ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1});
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_mx0w0
      = nl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_mx0w0[10:0];
  assign nl_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0
      = ({1'b1 , (~ (ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_sva_1[6:2]))})
      + 6'b001101;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0
      = nl_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0[5:0];
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_mx0w0
      = MUX_v_10_8_2(10'b1111111101, 10'b1100011001, 10'b1001100100, 10'b0111010000,
      10'b0101010100, 10'b0011101011, 10'b0010010001, 10'b0001000100, operator_71_0_false_AC_TRN_AC_WRAP_lshift_itm[69:67]);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_mx0w0
      = MUX_v_8_8_2(8'b00011100, 8'b01001011, 8'b01101100, 8'b10000100, 8'b10010111,
      8'b10100110, 8'b10110011, 8'b10111100, operator_71_0_false_AC_TRN_AC_WRAP_lshift_itm[69:67]);
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0
      = ~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0!=71'b00000000000000000000000000000000000000000000000000000000000000000000000));
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_79_nl
      = STORE_LOOP_and_54_itm_3 & (~ or_dcpl_78);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_15_nl
      = MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_0_lpi_2,
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_79_nl);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_76_nl
      = STORE_LOOP_and_55_itm_3 & (~ or_dcpl_78);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_14_nl
      = MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_1_lpi_2,
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_76_nl);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_73_nl
      = STORE_LOOP_and_56_itm_3 & (~ or_dcpl_78);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_13_nl
      = MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_2_lpi_2,
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_73_nl);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_70_nl
      = STORE_LOOP_and_57_itm_3 & (~ or_dcpl_78);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_12_nl
      = MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_3_lpi_2,
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_70_nl);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_67_nl
      = STORE_LOOP_and_58_itm_3 & (~ or_dcpl_78);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_11_nl
      = MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_4_lpi_2,
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_67_nl);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_64_nl
      = STORE_LOOP_and_59_itm_3 & (~ or_dcpl_78);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_10_nl
      = MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_5_lpi_2,
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_64_nl);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_61_nl
      = STORE_LOOP_and_60_itm_3 & (~ or_dcpl_78);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_9_nl
      = MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_6_lpi_2,
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_61_nl);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_58_nl
      = STORE_LOOP_and_61_itm_3 & (~ or_dcpl_78);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_8_nl
      = MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_7_lpi_2,
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_58_nl);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_32_nl
      = STORE_LOOP_and_62_itm_3 & (~ or_dcpl_78);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_2_nl
      = MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_8_lpi_2,
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_32_nl);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_55_nl
      = STORE_LOOP_and_63_itm_3 & (~ or_dcpl_78);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_7_nl
      = MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_9_lpi_2,
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_55_nl);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_37_nl
      = STORE_LOOP_and_64_itm_3 & (~ or_dcpl_78);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_1_nl
      = MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_10_lpi_2,
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_37_nl);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_52_nl
      = STORE_LOOP_and_65_itm_3 & (~ or_dcpl_78);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_6_nl
      = MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_11_lpi_2,
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_52_nl);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_49_nl
      = STORE_LOOP_and_66_itm_3 & (~ or_dcpl_78);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_5_nl
      = MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_12_lpi_2,
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_49_nl);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_46_nl
      = STORE_LOOP_and_67_itm_3 & (~ or_dcpl_78);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_4_nl
      = MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_13_lpi_2,
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_46_nl);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_40_nl
      = STORE_LOOP_and_68_itm_3 & (~ or_dcpl_78);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_nl
      = MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_14_lpi_2,
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_40_nl);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_43_nl
      = STORE_LOOP_and_69_itm_3 & (~ or_dcpl_78);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_3_nl
      = MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_15_lpi_2,
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_43_nl);
  assign CALC_SOFTMAX_LOOP_mux_itm_mx0w0 = MUX_v_67_16_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_15_nl,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_14_nl,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_13_nl,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_12_nl,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_11_nl,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_10_nl,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_9_nl,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_8_nl,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_2_nl,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_7_nl,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_1_nl,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_6_nl,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_5_nl,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_4_nl,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_nl,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_mux_3_nl,
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_itm_2);
  assign and_1813_cse = ~(STORE_LOOP_and_45_cse_1 | or_dcpl_126);
  assign and_1814_cse = STORE_LOOP_and_45_cse_1 & (~ or_dcpl_126);
  assign CALC_EXP_LOOP_i_4_0_lpi_2_dfm_2_3_0_mx0w0 = MUX1HOT_v_4_3_2((signext_4_1(~
      dma_read_ctrl_rsci_irdy_mxwt)), CALC_EXP_LOOP_i_4_0_sva_1_1_3_0, CALC_EXP_LOOP_i_4_0_lpi_2_3_0,
      {and_1813_cse , and_1814_cse , or_dcpl_126});
  assign or_1059_tmp = (STORE_LOOP_and_39_itm_3 & (~ exit_LOAD_CTRL_LOOP_sva_3))
      | STORE_LOOP_or_51_itm_3;
  assign nor_305_nl = ~(STORE_LOOP_and_40_cse_mx0w0 | or_1059_tmp);
  assign and_1812_nl = STORE_LOOP_and_40_cse_mx0w0 & (~ or_1059_tmp);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2_mx0w0
      = MUX1HOT_v_71_3_2((signext_71_1(~ exit_LOAD_CTRL_LOOP_sva_3)), ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2,
      {nor_305_nl , and_1812_nl , or_1059_tmp});
  assign SUM_EXP_LOOP_i_4_0_lpi_2_dfm_2_3_0_mx0w0 = MUX1HOT_v_4_3_2((signext_4_1(~
      dma_read_ctrl_rsci_irdy_mxwt)), SUM_EXP_LOOP_i_4_0_sva_1_1_3_0, SUM_EXP_LOOP_i_4_0_lpi_2_3_0,
      {and_1813_cse , and_1814_cse , or_dcpl_126});
  assign LOAD_LOOP_LOAD_LOOP_and_1_nl = exit_CALC_SOFTMAX_LOOP_lpi_2 & (~ reg_LOAD_LOOP_and_1_svs_1_cse);
  assign STORE_LOOP_mux1h_33_mx0w1 = MUX1HOT_s_1_3_2(exit_CALC_SOFTMAX_LOOP_lpi_2,
      LOAD_LOOP_LOAD_LOOP_and_1_nl, or_204_cse, {STORE_LOOP_or_34_cse_1 , STORE_LOOP_equal_tmp_mx0w0
      , STORE_LOOP_equal_tmp_3});
  assign LOAD_LOOP_LOAD_LOOP_and_2_nl = exit_STORE_CTRL_LOOP_lpi_2 & (~ reg_LOAD_LOOP_and_1_svs_1_cse);
  assign STORE_LOOP_mux1h_34_mx0w1 = MUX1HOT_s_1_3_2(exit_STORE_CTRL_LOOP_lpi_2,
      LOAD_LOOP_LOAD_LOOP_and_2_nl, exit_STORE_CTRL_LOOP_lpi_2_dfm_4, {STORE_LOOP_or_34_cse_1
      , STORE_LOOP_equal_tmp_mx0w0 , STORE_LOOP_equal_tmp_3});
  assign LOAD_LOOP_i_4_0_lpi_2_dfm_2_3_0_mx0w0 = MUX1HOT_v_4_3_2((signext_4_1(~ dma_read_ctrl_rsci_irdy_mxwt)),
      LOAD_LOOP_i_4_0_sva_1_1_3_0, LOAD_LOOP_i_4_0_lpi_2_3_0, {and_1813_cse , and_1814_cse
      , or_dcpl_126});
  assign SUM_EXP_LOOP_i_4_0_lpi_2_3_0_mx1 = MUX_v_4_2_2(SUM_EXP_LOOP_i_4_0_lpi_2_dfm_2_3_0_mx0w0,
      SUM_EXP_LOOP_i_4_0_lpi_2_3_0, or_50_cse);
  assign CALC_EXP_LOOP_i_4_0_lpi_2_3_0_mx1 = MUX_v_4_2_2(CALC_EXP_LOOP_i_4_0_lpi_2_dfm_2_3_0_mx0w0,
      CALC_EXP_LOOP_i_4_0_lpi_2_3_0, or_50_cse);
  assign BATCH_LOOP_or_94_nl = or_dcpl_98 | or_50_cse;
  assign BATCH_LOOP_acc_3_psp_lpi_2_mx1 = MUX_v_28_2_2(BATCH_LOOP_acc_3_psp_sva_1,
      BATCH_LOOP_acc_3_psp_lpi_2, BATCH_LOOP_or_94_nl);
  assign STORE_CTRL_LOOP_mux_1_nl = MUX_s_1_2_2(STORE_LOOP_mux1h_34_mx0w1, exit_STORE_CTRL_LOOP_lpi_2,
      exit_BATCH_LOOP_lpi_2_dfm_1);
  assign exit_STORE_CTRL_LOOP_lpi_2_mx1 = MUX_s_1_2_2(STORE_CTRL_LOOP_mux_1_nl, exit_STORE_CTRL_LOOP_lpi_2,
      or_50_cse);
  assign CALC_SOFTMAX_LOOP_mux_8_nl = MUX_s_1_2_2(STORE_LOOP_mux1h_33_mx0w1, exit_CALC_SOFTMAX_LOOP_lpi_2,
      exit_BATCH_LOOP_lpi_2_dfm_1);
  assign exit_CALC_SOFTMAX_LOOP_lpi_2_mx1 = MUX_s_1_2_2(CALC_SOFTMAX_LOOP_mux_8_nl,
      exit_CALC_SOFTMAX_LOOP_lpi_2, or_50_cse);
  assign STORE_LOOP_STORE_LOOP_nor_8_nl = ~(exit_BATCH_LOOP_lpi_2_dfm_1 | or_50_cse);
  assign STORE_LOOP_and_191_nl = exit_BATCH_LOOP_lpi_2_dfm_1 & (~ or_50_cse);
  assign lfst_exit_STORE_LOOP_lpi_2_1_0_mx0 = MUX1HOT_v_2_3_2(lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1,
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0, lfst_exit_STORE_LOOP_lpi_2_1_0, {STORE_LOOP_STORE_LOOP_nor_8_nl
      , STORE_LOOP_and_191_nl , or_50_cse});
  assign STORE_LOOP_i_or_1_cse = exit_BATCH_LOOP_lpi_2_dfm_1 | or_50_cse;
  assign STORE_LOOP_i_4_0_lpi_2_3_0_mx1 = MUX_v_4_2_2(STORE_LOOP_i_4_0_lpi_2_dfm_1_3_0_1,
      STORE_LOOP_i_4_0_lpi_2_3_0, STORE_LOOP_i_or_1_cse);
  assign STORE_LOOP_STORE_LOOP_nor_nl = ~(lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1 |
      (lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1!=2'b00));
  assign STORE_LOOP_mux_61_nl = MUX_s_1_2_2(STORE_LOOP_STORE_LOOP_nor_nl, exitL_exit_STORE_LOOP_sva,
      STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign or_620_nl = exit_BATCH_LOOP_lpi_2_dfm_1 | STORE_LOOP_asn_51_itm_1 | (~ BATCH_LOOP_and_21_tmp);
  assign exitL_exit_STORE_LOOP_sva_mx1 = MUX_s_1_2_2(STORE_LOOP_mux_61_nl, exitL_exit_STORE_LOOP_sva,
      or_620_nl);
  assign nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2
      + conv_u2u_67_71(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0
      = nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0[70:0];
  assign CALC_SOFTMAX_LOOP_i_4_0_lpi_2_3_0_mx1 = MUX_v_4_2_2(CALC_SOFTMAX_LOOP_i_4_0_lpi_2_dfm_2_3_0_1,
      CALC_SOFTMAX_LOOP_i_4_0_lpi_2_3_0, STORE_LOOP_i_or_1_cse);
  assign STORE_LOOP_and_40_cse_mx0w0 = STORE_LOOP_equal_tmp_3_1 & (~ exit_BATCH_LOOP_lpi_2_dfm_4);
  assign STORE_LOOP_equal_tmp_mx0w0 = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1])
      & (~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2));
  assign STORE_LOOP_and_39_itm_mx0w0 = STORE_LOOP_or_tmp_1 & (~ exit_BATCH_LOOP_lpi_2_dfm_1);
  assign STORE_LOOP_or_51_itm_mx0w0 = STORE_LOOP_equal_tmp_3 | STORE_LOOP_equal_tmp_2_1
      | STORE_LOOP_nor_tmp_1 | exit_BATCH_LOOP_lpi_2_dfm_1;
  assign ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_or_1_itm
      = MUX_v_91_2_2(operator_91_21_false_AC_TRN_AC_WRAP_rshift_itm, 91'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_4);
  assign nl_LOAD_LOOP_i_4_0_sva_2 = conv_u2u_4_5(LOAD_LOOP_i_4_0_lpi_2_3_0_mx1) +
      5'b00001;
  assign LOAD_LOOP_i_4_0_sva_2 = nl_LOAD_LOOP_i_4_0_sva_2[4:0];
  assign nl_CALC_EXP_LOOP_i_4_0_sva_2 = conv_u2u_4_5(CALC_EXP_LOOP_i_4_0_lpi_2_3_0_mx1)
      + 5'b00001;
  assign CALC_EXP_LOOP_i_4_0_sva_2 = nl_CALC_EXP_LOOP_i_4_0_sva_2[4:0];
  assign nl_SUM_EXP_LOOP_i_4_0_sva_2 = conv_u2u_4_5(SUM_EXP_LOOP_i_4_0_lpi_2_3_0_mx1)
      + 5'b00001;
  assign SUM_EXP_LOOP_i_4_0_sva_2 = nl_SUM_EXP_LOOP_i_4_0_sva_2[4:0];
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0 = MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_2_mx1,
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx1w0, mux_tmp_426);
  assign nl_BATCH_LOOP_if_acc_nl = ({29'b10000000000000000000000000000 , BATCH_LOOP_b_4_0_sva_3_0})
      + conv_u2u_32_33(~ batch_sva) + 33'b000000000000000000000000000000001;
  assign BATCH_LOOP_if_acc_nl = nl_BATCH_LOOP_if_acc_nl[32:0];
  assign BATCH_LOOP_if_acc_itm_32_1 = readslicef_33_1_32(BATCH_LOOP_if_acc_nl);
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0 = MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_1_0_mx0,
      (signext_2_1(~ BATCH_LOOP_if_acc_itm_32_1)), mux_tmp_426);
  assign nl_BATCH_LOOP_acc_3_psp_sva_1 = (batch_sva[27:0]) + conv_u2u_4_28(BATCH_LOOP_b_slc_BATCH_LOOP_b_4_0_3_0_1_itm_1);
  assign BATCH_LOOP_acc_3_psp_sva_1 = nl_BATCH_LOOP_acc_3_psp_sva_1[27:0];
  assign STORE_LOOP_mux_153_nl = MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2,
      lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2, STORE_LOOP_and_38_ssc_1);
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1 = (STORE_LOOP_mux_153_nl & (~(STORE_LOOP_or_tmp_1
      | STORE_LOOP_and_34_ssc_1))) | STORE_LOOP_and_36_ssc_1;
  assign STORE_LOOP_and_35_cse = (~ CALC_SOFTMAX_LOOP_and_svs_1) & STORE_LOOP_equal_tmp_3;
  assign STORE_LOOP_and_33_cse = (~ reg_LOAD_LOOP_and_1_svs_1_cse) & STORE_LOOP_equal_tmp_mx0w0;
  assign STORE_LOOP_and_94_nl = (~ dma_read_ctrl_rsci_irdy_mxwt) & STORE_LOOP_or_tmp_1;
  assign STORE_LOOP_and_95_nl = dma_read_ctrl_rsci_irdy_mxwt & STORE_LOOP_or_tmp_1;
  assign STORE_LOOP_or_50_nl = STORE_LOOP_and_33_cse | STORE_LOOP_and_35_cse | ((~
      (STORE_LOOP_i_4_0_sva_1_1[4])) & STORE_LOOP_equal_tmp_2_1) | STORE_LOOP_nor_tmp_1;
  assign STORE_LOOP_mux1h_104_tmp = MUX1HOT_v_2_3_2(2'b01, 2'b10, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0,
      {STORE_LOOP_and_94_nl , STORE_LOOP_and_95_nl , STORE_LOOP_or_50_nl});
  assign STORE_LOOP_and_nl = STORE_LOOP_mux1h_104_tmp & (signext_2_1(~ STORE_LOOP_and_38_ssc_1))
      & (signext_2_1(~ STORE_LOOP_and_36_ssc_1));
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1 = MUX_v_2_2_2(STORE_LOOP_and_nl,
      2'b11, STORE_LOOP_and_34_ssc_1);
  assign STORE_LOOP_or_34_cse_1 = STORE_LOOP_or_tmp_1 | STORE_LOOP_equal_tmp_2_1
      | STORE_LOOP_nor_tmp_1;
  assign exit_STORE_CTRL_LOOP_lpi_2_dfm_4 = dma_write_ctrl_rsci_irdy_mxwt | exit_STORE_CTRL_LOOP_lpi_2;
  assign STORE_LOOP_equal_tmp_3 = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0==2'b11)
      & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign STORE_LOOP_or_tmp_1 = STORE_LOOP_STORE_LOOP_and_cse_1 | reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse;
  assign STORE_LOOP_nor_tmp_1 = ~(STORE_LOOP_STORE_LOOP_and_cse_1 | reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse
      | STORE_LOOP_equal_tmp_mx0w0 | STORE_LOOP_STORE_LOOP_and_6_itm_1 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0==2'b00)));
  assign STORE_LOOP_and_45_cse_1 = STORE_LOOP_equal_tmp_mx0w0 & (~ exit_BATCH_LOOP_lpi_2_dfm_1);
  assign or_1062_tmp = STORE_LOOP_and_35_cse | STORE_LOOP_nor_tmp_1 | STORE_LOOP_or_tmp_1
      | STORE_LOOP_equal_tmp_mx0w0;
  assign nor_306_nl = ~(STORE_LOOP_equal_tmp_2_1 | or_1062_tmp);
  assign and_1810_nl = STORE_LOOP_equal_tmp_2_1 & (~ or_1062_tmp);
  assign STORE_LOOP_i_4_0_lpi_2_dfm_1_3_0_1 = MUX1HOT_v_4_3_2((signext_4_1(~ CALC_SOFTMAX_LOOP_and_svs_1)),
      (STORE_LOOP_i_4_0_sva_1_1[3:0]), STORE_LOOP_i_4_0_lpi_2_3_0, {nor_306_nl ,
      and_1810_nl , or_1062_tmp});
  assign CALC_SOFTMAX_LOOP_and_svs_1 = or_204_cse & exit_STORE_CTRL_LOOP_lpi_2_dfm_4;
  assign STORE_LOOP_and_38_ssc_1 = (STORE_LOOP_i_4_0_sva_1_1[4]) & STORE_LOOP_equal_tmp_2_1;
  assign STORE_LOOP_and_34_ssc_1 = reg_LOAD_LOOP_and_1_svs_1_cse & STORE_LOOP_equal_tmp_mx0w0;
  assign STORE_LOOP_and_36_ssc_1 = CALC_SOFTMAX_LOOP_and_svs_1 & STORE_LOOP_equal_tmp_3;
  assign STORE_LOOP_STORE_LOOP_and_cse_1 = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0])
      & nor_153_cse;
  assign nl_BATCH_LOOP_acc_2_tmp = conv_u2u_4_5(BATCH_LOOP_b_4_0_sva_3_0) + 5'b00001;
  assign BATCH_LOOP_acc_2_tmp = nl_BATCH_LOOP_acc_2_tmp[4:0];
  assign BATCH_LOOP_BATCH_LOOP_or_51_cse_1 = ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt
      | (~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[1]) & (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[0]))) & (~ exit_BATCH_LOOP_lpi_2_dfm_st_3)
      & BATCH_LOOP_stage_v_3));
  assign BATCH_LOOP_BATCH_LOOP_or_6_cse_1 = CALC_SOFTMAX_LOOP_mul_cmp_bawt | (~((~
      CALC_SOFTMAX_LOOP_asn_itm_19) & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_1_0==2'b11)
      & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_2) & (~ exit_BATCH_LOOP_lpi_2_dfm_st_19)
      & BATCH_LOOP_stage_old_v_19));
  assign BATCH_LOOP_BATCH_LOOP_or_4_cse_1 = plm_out_data_rsci_bawt | (~((~ CALC_SOFTMAX_LOOP_asn_itm_20)
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_1_0==2'b11) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_2)
      & (~ exit_BATCH_LOOP_lpi_2_dfm_st_20) & BATCH_LOOP_stage_old_v_20));
  assign BATCH_LOOP_BATCH_LOOP_or_cse_1 = dma_write_chnl_rsci_bawt | (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_21_2
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_21_1_0==2'b00) & (~ exit_BATCH_LOOP_lpi_2_dfm_st_21)
      & BATCH_LOOP_stage_v_21));
  assign nl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = $signed(({1'b1 , ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1}))
      * $signed(conv_u2s_10_11(ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_69_57_9_0_itm_1));
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = nl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[18:0];
  assign or_1066_tmp = STORE_LOOP_nor_tmp_1 | STORE_LOOP_or_tmp_1 | (exit_CALC_SOFTMAX_LOOP_lpi_2
      & STORE_LOOP_equal_tmp_3) | STORE_LOOP_and_33_cse | STORE_LOOP_equal_tmp_2_1;
  assign STORE_LOOP_and_92_tmp = (~ exit_CALC_SOFTMAX_LOOP_lpi_2) & STORE_LOOP_equal_tmp_3;
  assign nor_307_nl = ~(STORE_LOOP_and_92_tmp | or_1066_tmp);
  assign and_1808_nl = STORE_LOOP_and_92_tmp & (~ or_1066_tmp);
  assign CALC_SOFTMAX_LOOP_i_4_0_lpi_2_dfm_2_3_0_1 = MUX1HOT_v_4_3_2((signext_4_1(~
      reg_LOAD_LOOP_and_1_svs_1_cse)), (CALC_SOFTMAX_LOOP_i_4_0_sva_1_1[3:0]), CALC_SOFTMAX_LOOP_i_4_0_lpi_2_3_0,
      {nor_307_nl , and_1808_nl , or_1066_tmp});
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_10_nl
      = MUX_v_5_4_2(5'b01100, 5'b01110, 5'b10001, 5'b10100, ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt[11:10]);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_11_nl
      = MUX_v_3_4_2(3'b010, 3'b110, 3'b001, 3'b101, ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt[11:10]);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = conv_u2u_19_19(({ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_10_nl
      , 1'b0 , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_11_nl})
      * (ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt[9:0]));
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_0_sva_1
      = ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_0_sva_1
      & (~ (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[2]));
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_1_sva_1
      = ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_1_sva_1
      & (~ (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[2]));
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_2_sva_1
      = ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_2_sva_1
      & (~ (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[2]));
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_3_sva_1
      = ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_3_sva_1
      & (~ (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[2]));
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_4_sva_1
      = ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_0_sva_1
      & (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[2]);
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_5_sva_1
      = ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_1_sva_1
      & (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[2]);
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_6_sva_1
      = ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_2_sva_1
      & (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[2]);
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_7_sva_1
      = ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_3_sva_1
      & (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[2]);
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_0_sva_1
      = ~((CALC_EXP_LOOP_i_4_0_lpi_2_3_0[1:0]!=2'b00));
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_1_sva_1
      = (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[1:0]==2'b01);
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_2_sva_1
      = (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[1:0]==2'b10);
  assign ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_1_3_sva_1
      = (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[1:0]==2'b11);
  assign BATCH_LOOP_nor_22_tmp = ~((~(BATCH_LOOP_stage_v_21 & BATCH_LOOP_BATCH_LOOP_or_cse_1))
      | (BATCH_LOOP_stage_0 & (mux_530_cse | (~ BATCH_LOOP_and_22_tmp))) | BATCH_LOOP_stage_0_1
      | BATCH_LOOP_stage_0_2 | BATCH_LOOP_stage_0_3 | BATCH_LOOP_stage_0_4 | BATCH_LOOP_stage_0_5
      | BATCH_LOOP_stage_0_6 | BATCH_LOOP_stage_0_7 | BATCH_LOOP_stage_0_8 | BATCH_LOOP_stage_0_9
      | BATCH_LOOP_stage_0_10 | BATCH_LOOP_stage_0_11 | BATCH_LOOP_stage_0_12 | BATCH_LOOP_stage_0_13
      | BATCH_LOOP_stage_0_14 | BATCH_LOOP_stage_0_15 | BATCH_LOOP_stage_0_16 | BATCH_LOOP_stage_0_17
      | BATCH_LOOP_stage_0_18 | BATCH_LOOP_stage_0_19 | BATCH_LOOP_stage_0_20 | BATCH_LOOP_stage_0_21);
  assign BATCH_LOOP_and_22_tmp = BATCH_LOOP_stage_v & (~(BATCH_LOOP_stage_old_v_1
      & (~ BATCH_LOOP_and_21_tmp))) & BATCH_LOOP_stage_0_1 & BATCH_LOOP_BATCH_LOOP_or_51_cse_1
      & BATCH_LOOP_BATCH_LOOP_or_6_cse_1 & BATCH_LOOP_BATCH_LOOP_or_4_cse_1 & BATCH_LOOP_BATCH_LOOP_or_cse_1;
  assign STORE_LOOP_mux_55_tmp = MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1,
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign BATCH_LOOP_and_21_tmp = BATCH_LOOP_stage_old_v_1 & (~(BATCH_LOOP_stage_v_2
      & (not_tmp_152 | not_tmp_41))) & BATCH_LOOP_stage_0_2 & (dma_read_ctrl_rsci_bawt
      | (~(((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0]) & (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1])))) | (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0!=2'b00))))) | exit_BATCH_LOOP_lpi_2_dfm_1)
      & (dma_read_chnl_rsci_bawt | (~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1])
      & (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])))
      & (~ exit_BATCH_LOOP_lpi_2_dfm_1)))) & (dma_write_ctrl_rsci_bawt | (~((~ CALC_SOFTMAX_LOOP_asn_19_itm_1)
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0==2'b11) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2)
      & (~ exit_BATCH_LOOP_lpi_2_dfm_1)))) & BATCH_LOOP_BATCH_LOOP_or_51_cse_1 &
      BATCH_LOOP_BATCH_LOOP_or_6_cse_1 & BATCH_LOOP_BATCH_LOOP_or_4_cse_1 & BATCH_LOOP_BATCH_LOOP_or_cse_1;
  assign or_9_cse = CALC_SOFTMAX_LOOP_asn_itm_20 | exit_BATCH_LOOP_lpi_2_dfm_st_20
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_2 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_1_0!=2'b11)
      | plm_out_data_rsci_bawt;
  assign or_tmp_16 = STORE_LOOP_STORE_LOOP_and_10_itm_1 | exit_BATCH_LOOP_lpi_2_dfm_1;
  assign or_24_cse = (STORE_LOOP_mux1h_104_tmp!=2'b00);
  assign and_1785_cse = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]) & reg_LOAD_LOOP_and_1_svs_1_cse;
  assign or_26_cse = (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1])) | reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse;
  assign or_tmp_25 = lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 | exitL_exit_STORE_LOOP_sva;
  assign and_1783_cse = exitL_exit_STORE_LOOP_sva & STORE_LOOP_STORE_LOOP_and_10_itm_1;
  assign or_29_cse = (lfst_exit_STORE_LOOP_lpi_2_1_0!=2'b10) | lfst_exit_STORE_LOOP_lpi_2_2
      | exitL_exit_STORE_LOOP_sva;
  assign or_46_cse = BATCH_LOOP_if_acc_itm_32_1 | (~ exitL_exit_STORE_LOOP_sva);
  assign not_tmp_41 = ~(BATCH_LOOP_stage_v_2 & BATCH_LOOP_stage_0_3);
  assign or_67_cse = (~ BATCH_LOOP_stage_old_v_19) | CALC_SOFTMAX_LOOP_mul_cmp_bawt
      | CALC_SOFTMAX_LOOP_asn_itm_19 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_1_0!=2'b11)
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_2 | exit_BATCH_LOOP_lpi_2_dfm_st_19;
  assign not_tmp_46 = ~(BATCH_LOOP_stage_0_19 & BATCH_LOOP_stage_v_18);
  assign and_tmp_12 = or_114_cse & or_622_cse;
  assign and_1790_cse = BATCH_LOOP_stage_v_17 & BATCH_LOOP_stage_0_18;
  assign and_1778_cse = BATCH_LOOP_stage_v_16 & BATCH_LOOP_stage_0_17;
  assign and_72_cse = BATCH_LOOP_stage_v_16 & BATCH_LOOP_stage_0_17 & and_tmp_12;
  assign or_dcpl_11 = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_1_0!=2'b00) | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_2)
      | exit_BATCH_LOOP_lpi_2_dfm_st_20 | (~ BATCH_LOOP_stage_old_v_20) | (~ BATCH_LOOP_stage_0_21);
  assign and_dcpl_41 = (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_21_1_0[0])) & lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_21_2
      & (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_21_1_0[1]));
  assign and_dcpl_42 = and_dcpl_41 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_21) & (~ dma_write_chnl_rsci_bawt)
      & BATCH_LOOP_stage_v_21;
  assign or_tmp_151 = (~ STORE_LOOP_STORE_LOOP_and_10_itm_1) | exitL_exit_STORE_LOOP_sva;
  assign mux_tmp_224 = MUX_s_1_2_2(or_tmp_151, and_1783_cse, or_24_cse);
  assign or_tmp_161 = (~ STORE_LOOP_STORE_LOOP_and_6_itm_1) | reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse
      | STORE_LOOP_equal_tmp_2_1 | mux_tmp_224;
  assign or_170_nl = (~ reg_LOAD_LOOP_and_1_svs_1_cse) | reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse
      | STORE_LOOP_equal_tmp_2_1 | and_1783_cse;
  assign mux_tmp_225 = MUX_s_1_2_2(or_tmp_161, or_170_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]);
  assign mux_983_nl = MUX_s_1_2_2(or_tmp_151, and_1783_cse, or_24_cse);
  assign mux_tmp_228 = MUX_s_1_2_2(mux_983_nl, or_tmp_151, STORE_LOOP_and_38_ssc_1);
  assign or_177_nl = (~ (STORE_LOOP_i_4_0_sva_1_1[4])) | (~ STORE_LOOP_equal_tmp_2_1)
      | lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2 | (~ STORE_LOOP_STORE_LOOP_and_10_itm_1)
      | exitL_exit_STORE_LOOP_sva;
  assign mux_tmp_229 = MUX_s_1_2_2(or_177_nl, mux_tmp_228, reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse);
  assign or_179_nl = lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2 | (~ STORE_LOOP_STORE_LOOP_and_10_itm_1)
      | exitL_exit_STORE_LOOP_sva;
  assign mux_tmp_230 = MUX_s_1_2_2(mux_tmp_224, or_179_nl, STORE_LOOP_and_38_ssc_1);
  assign mux_246_nl = MUX_s_1_2_2(mux_tmp_230, mux_tmp_228, reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse);
  assign mux_tmp_232 = MUX_s_1_2_2(mux_246_nl, and_1783_cse, and_1785_cse);
  assign or_178_nl = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]) | mux_tmp_228;
  assign mux_248_nl = MUX_s_1_2_2(mux_tmp_232, or_178_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign mux_tmp_234 = MUX_s_1_2_2(mux_248_nl, mux_tmp_229, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_250_nl = MUX_s_1_2_2(mux_tmp_230, mux_tmp_228, or_26_cse);
  assign mux_251_nl = MUX_s_1_2_2(mux_tmp_232, mux_250_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign mux_tmp_237 = MUX_s_1_2_2(mux_251_nl, mux_tmp_229, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_256_nl = MUX_s_1_2_2(mux_tmp_237, mux_tmp_234, dma_write_ctrl_rsci_irdy_mxwt);
  assign mux_tmp_242 = MUX_s_1_2_2(mux_256_nl, mux_tmp_237, CALC_SOFTMAX_LOOP_asn_19_itm_1);
  assign or_175_nl = lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0])
      | mux_tmp_225;
  assign mux_258_nl = MUX_s_1_2_2(mux_tmp_242, or_175_nl, exit_STORE_CTRL_LOOP_lpi_2);
  assign nand_19_nl = ~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]) & (~ or_tmp_161));
  assign mux_241_nl = MUX_s_1_2_2(mux_tmp_225, nand_19_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign or_176_nl = lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 | mux_241_nl;
  assign mux_254_nl = MUX_s_1_2_2(mux_tmp_237, or_176_nl, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_260_nl = MUX_s_1_2_2(mux_258_nl, mux_254_nl, or_194_cse);
  assign or_161_nl = exit_STORE_CTRL_LOOP_lpi_2 | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2
      | exitL_exit_STORE_LOOP_sva;
  assign mux_261_nl = MUX_s_1_2_2(mux_260_nl, or_161_nl, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign nand_20_nl = ~((STORE_LOOP_mux_55_tmp==2'b11) & (~ mux_261_nl));
  assign or_160_nl = exit_STORE_CTRL_LOOP_lpi_2 | (~ (lfst_exit_STORE_LOOP_lpi_2_1_0[0]))
      | lfst_exit_STORE_LOOP_lpi_2_2 | (~ (lfst_exit_STORE_LOOP_lpi_2_1_0[1])) |
      exitL_exit_STORE_LOOP_sva;
  assign mux_tmp_247 = MUX_s_1_2_2(nand_20_nl, or_160_nl, or_50_cse);
  assign not_tmp_96 = ~((STORE_LOOP_i_4_0_sva_1_1[4]) & STORE_LOOP_equal_tmp_2_1);
  assign or_tmp_172 = lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2 | not_tmp_96;
  assign or_tmp_173 = reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse | (~ or_tmp_172);
  assign or_tmp_174 = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2) | reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse;
  assign or_tmp_175 = or_tmp_174 | (~ or_tmp_172);
  assign nor_tmp_41 = lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2 & (STORE_LOOP_i_4_0_sva_1_1[4])
      & STORE_LOOP_equal_tmp_2_1;
  assign or_190_nl = reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse | (~ nor_tmp_41);
  assign mux_tmp_250 = MUX_s_1_2_2(or_190_nl, or_tmp_173, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_tmp_253 = MUX_s_1_2_2(mux_tmp_250, or_tmp_175, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign mux_266_nl = MUX_s_1_2_2(mux_tmp_250, or_tmp_175, reg_LOAD_LOOP_and_1_svs_1_cse);
  assign and_97_nl = lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 & or_tmp_173;
  assign mux_267_nl = MUX_s_1_2_2(mux_266_nl, and_97_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign mux_tmp_254 = MUX_s_1_2_2(mux_tmp_253, mux_267_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]);
  assign nor_42_cse = ~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]) | (~ reg_LOAD_LOOP_and_1_svs_1_cse));
  assign mux_270_nl = MUX_s_1_2_2(mux_tmp_250, or_tmp_175, nor_42_cse);
  assign mux_tmp_256 = MUX_s_1_2_2(mux_tmp_253, mux_270_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]);
  assign mux_273_nl = MUX_s_1_2_2(mux_tmp_256, mux_tmp_254, dma_write_ctrl_rsci_irdy_mxwt);
  assign mux_274_nl = MUX_s_1_2_2(mux_273_nl, mux_tmp_256, CALC_SOFTMAX_LOOP_asn_19_itm_1);
  assign mux_275_nl = MUX_s_1_2_2(mux_274_nl, mux_tmp_254, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_276_nl = MUX_s_1_2_2(mux_tmp_256, mux_275_nl, or_204_cse);
  assign mux_277_cse = MUX_s_1_2_2(mux_276_nl, mux_tmp_256, or_194_cse);
  assign nand_tmp_21 = ~(or_24_cse & not_tmp_96);
  assign mux_tmp_265 = MUX_s_1_2_2((~ or_tmp_172), nand_tmp_21, reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse);
  assign and_tmp_37 = lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 & mux_tmp_265;
  assign mux_281_cse = MUX_s_1_2_2(nor_tmp_41, or_tmp_172, or_24_cse);
  assign mux_282_nl = MUX_s_1_2_2((~ mux_281_cse), nand_tmp_21, reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse);
  assign mux_tmp_268 = MUX_s_1_2_2(mux_282_nl, mux_tmp_265, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_285_nl = MUX_s_1_2_2((~ or_tmp_172), nand_tmp_21, or_tmp_174);
  assign mux_tmp_271 = MUX_s_1_2_2(mux_tmp_268, mux_285_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign or_195_nl = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]) | reg_LOAD_LOOP_and_1_svs_1_cse;
  assign mux_284_nl = MUX_s_1_2_2(mux_tmp_268, and_tmp_37, or_195_nl);
  assign mux_tmp_272 = MUX_s_1_2_2(mux_tmp_271, mux_284_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]);
  assign mux_288_nl = MUX_s_1_2_2(mux_tmp_268, and_tmp_37, nor_42_cse);
  assign mux_tmp_274 = MUX_s_1_2_2(mux_tmp_271, mux_288_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]);
  assign nand_24_cse = ~(reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse & (~ nand_tmp_21));
  assign and_tmp_38 = lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 & nand_24_cse;
  assign nand_tmp_25 = ~(or_tmp_174 & (~ nand_tmp_21));
  assign mux_297_nl = MUX_s_1_2_2(nand_tmp_25, and_tmp_38, reg_LOAD_LOOP_and_1_svs_1_cse);
  assign nand_23_nl = ~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 & reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse
      & (~ nand_tmp_21));
  assign mux_298_nl = MUX_s_1_2_2(mux_297_nl, nand_23_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign mux_tmp_284 = MUX_s_1_2_2(nand_tmp_25, mux_298_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]);
  assign nor_45_nl = ~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0!=2'b10) | (~ reg_LOAD_LOOP_and_1_svs_1_cse));
  assign mux_tmp_285 = MUX_s_1_2_2(nand_tmp_25, and_tmp_38, nor_45_nl);
  assign and_dcpl_43 = (~ exit_BATCH_LOOP_lpi_2_dfm_1) & BATCH_LOOP_and_21_tmp;
  assign and_dcpl_46 = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2) & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0==2'b10)
      & and_dcpl_43;
  assign not_tmp_113 = ~(((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_1_0==2'b11)) |
      and_dcpl_42);
  assign or_207_nl = (~ BATCH_LOOP_stage_old_v_20) | plm_out_data_rsci_bawt | CALC_SOFTMAX_LOOP_asn_itm_20
      | exit_BATCH_LOOP_lpi_2_dfm_st_20 | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_2;
  assign mux_tmp_298 = MUX_s_1_2_2(not_tmp_113, or_622_cse, or_207_nl);
  assign nor_253_nl = ~(BATCH_LOOP_stage_old_v_20 | and_dcpl_42);
  assign mux_tmp_299 = MUX_s_1_2_2(nor_253_nl, mux_tmp_298, BATCH_LOOP_stage_0_21);
  assign and_110_nl = or_624_cse & BATCH_LOOP_stage_0_20 & mux_tmp_299;
  assign mux_tmp_300 = MUX_s_1_2_2(mux_tmp_298, and_110_nl, BATCH_LOOP_stage_old_v_19);
  assign and_tmp_41 = or_67_cse & mux_tmp_298;
  assign and_111_nl = BATCH_LOOP_stage_0_19 & mux_tmp_300;
  assign mux_tmp_301 = MUX_s_1_2_2(and_tmp_41, and_111_nl, BATCH_LOOP_stage_v_18);
  assign and_113_nl = BATCH_LOOP_stage_0_18 & mux_tmp_301;
  assign mux_tmp_302 = MUX_s_1_2_2(and_tmp_41, and_113_nl, BATCH_LOOP_stage_v_17);
  assign and_114_nl = BATCH_LOOP_stage_0_17 & mux_tmp_302;
  assign mux_tmp_303 = MUX_s_1_2_2(and_tmp_41, and_114_nl, BATCH_LOOP_stage_v_16);
  assign and_115_nl = BATCH_LOOP_stage_0_16 & mux_tmp_303;
  assign mux_tmp_304 = MUX_s_1_2_2(and_tmp_41, and_115_nl, BATCH_LOOP_stage_v_15);
  assign and_116_nl = BATCH_LOOP_stage_0_15 & mux_tmp_304;
  assign mux_tmp_305 = MUX_s_1_2_2(and_tmp_41, and_116_nl, BATCH_LOOP_stage_v_14);
  assign and_117_nl = BATCH_LOOP_stage_0_14 & mux_tmp_305;
  assign mux_tmp_306 = MUX_s_1_2_2(and_tmp_41, and_117_nl, BATCH_LOOP_stage_v_13);
  assign and_118_nl = BATCH_LOOP_stage_0_13 & mux_tmp_306;
  assign mux_tmp_307 = MUX_s_1_2_2(and_tmp_41, and_118_nl, BATCH_LOOP_stage_v_12);
  assign and_119_nl = BATCH_LOOP_stage_0_12 & mux_tmp_307;
  assign mux_tmp_308 = MUX_s_1_2_2(and_tmp_41, and_119_nl, BATCH_LOOP_stage_v_11);
  assign and_120_nl = BATCH_LOOP_stage_0_11 & mux_tmp_308;
  assign mux_tmp_309 = MUX_s_1_2_2(and_tmp_41, and_120_nl, BATCH_LOOP_stage_v_10);
  assign and_tmp_50 = BATCH_LOOP_stage_0_10 & mux_tmp_309;
  assign mux_tmp_310 = MUX_s_1_2_2(and_tmp_41, and_tmp_50, BATCH_LOOP_stage_v_9);
  assign and_tmp_51 = BATCH_LOOP_stage_0_9 & mux_tmp_310;
  assign mux_tmp_311 = MUX_s_1_2_2(and_tmp_41, and_tmp_51, BATCH_LOOP_stage_v_8);
  assign and_tmp_52 = BATCH_LOOP_stage_0_8 & mux_tmp_311;
  assign mux_tmp_312 = MUX_s_1_2_2(and_tmp_41, and_tmp_52, BATCH_LOOP_stage_v_7);
  assign and_tmp_53 = BATCH_LOOP_stage_0_7 & mux_tmp_312;
  assign mux_tmp_313 = MUX_s_1_2_2(and_tmp_41, and_tmp_53, BATCH_LOOP_stage_v_6);
  assign and_tmp_54 = BATCH_LOOP_stage_0_6 & mux_tmp_313;
  assign mux_tmp_314 = MUX_s_1_2_2(and_tmp_41, and_tmp_54, BATCH_LOOP_stage_v_5);
  assign and_126_nl = BATCH_LOOP_stage_0_5 & mux_tmp_314;
  assign mux_tmp_315 = MUX_s_1_2_2(and_tmp_41, and_126_nl, BATCH_LOOP_stage_v_4);
  assign and_dcpl_57 = BATCH_LOOP_stage_0_8 & BATCH_LOOP_stage_v_7;
  assign and_dcpl_91 = and_dcpl_41 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_21) & dma_write_chnl_rsci_bawt
      & BATCH_LOOP_stage_v_21;
  assign mux_334_nl = MUX_s_1_2_2(mux_tmp_242, mux_tmp_234, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_335_nl = MUX_s_1_2_2(mux_tmp_237, mux_334_nl, or_204_cse);
  assign mux_337_nl = MUX_s_1_2_2(mux_335_nl, mux_tmp_237, or_194_cse);
  assign mux_338_itm = MUX_s_1_2_2(mux_337_nl, or_tmp_25, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign and_tmp_64 = or_67_cse & or_114_cse;
  assign mux_415_cse = MUX_s_1_2_2(and_tmp_64, and_745_cse, BATCH_LOOP_stage_v_3);
  assign not_tmp_152 = ~(or_622_cse & mux_415_cse);
  assign or_tmp_242 = plm_out_data_rsci_bawt | CALC_SOFTMAX_LOOP_asn_itm_20 | exit_BATCH_LOOP_lpi_2_dfm_st_20
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_2;
  assign mux_tmp_402 = MUX_s_1_2_2(not_tmp_113, or_622_cse, or_tmp_242);
  assign or_25_nl = (~ (STORE_LOOP_i_4_0_sva_1_1[4])) | (~ STORE_LOOP_equal_tmp_2_1)
      | lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2;
  assign mux_420_nl = MUX_s_1_2_2(or_tmp_151, and_1783_cse, or_25_nl);
  assign mux_tmp_406 = MUX_s_1_2_2(mux_420_nl, mux_tmp_228, reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse);
  assign mux_423_nl = MUX_s_1_2_2(or_tmp_151, and_1783_cse, lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2);
  assign mux_tmp_409 = MUX_s_1_2_2(mux_tmp_224, mux_423_nl, STORE_LOOP_and_38_ssc_1);
  assign mux_425_nl = MUX_s_1_2_2(mux_tmp_409, mux_tmp_228, reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse);
  assign mux_tmp_411 = MUX_s_1_2_2(mux_425_nl, and_1783_cse, and_1785_cse);
  assign mux_422_nl = MUX_s_1_2_2(mux_tmp_228, and_1783_cse, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]);
  assign mux_427_nl = MUX_s_1_2_2(mux_tmp_411, mux_422_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign mux_tmp_413 = MUX_s_1_2_2(mux_427_nl, mux_tmp_406, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_429_nl = MUX_s_1_2_2(mux_tmp_409, mux_tmp_228, or_26_cse);
  assign mux_430_nl = MUX_s_1_2_2(mux_tmp_411, mux_429_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign mux_tmp_416 = MUX_s_1_2_2(mux_430_nl, mux_tmp_406, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_434_nl = MUX_s_1_2_2(mux_tmp_416, mux_tmp_413, dma_write_ctrl_rsci_irdy_mxwt);
  assign mux_435_nl = MUX_s_1_2_2(mux_434_nl, mux_tmp_416, CALC_SOFTMAX_LOOP_asn_19_itm_1);
  assign mux_436_nl = MUX_s_1_2_2(mux_435_nl, mux_tmp_413, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_437_nl = MUX_s_1_2_2(mux_tmp_416, mux_436_nl, or_204_cse);
  assign mux_439_nl = MUX_s_1_2_2(mux_437_nl, mux_tmp_416, or_194_cse);
  assign mux_440_nl = MUX_s_1_2_2(mux_439_nl, exitL_exit_STORE_LOOP_sva, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_tmp_426 = MUX_s_1_2_2(mux_440_nl, exitL_exit_STORE_LOOP_sva, or_50_cse);
  assign and_dcpl_105 = mux_tmp_426 & BATCH_LOOP_and_22_tmp;
  assign and_dcpl_106 = (~ mux_tmp_426) & BATCH_LOOP_and_22_tmp;
  assign nand_33_nl = ~((STORE_LOOP_mux_55_tmp==2'b11) & (~ mux_338_itm));
  assign or_296_nl = (~ (lfst_exit_STORE_LOOP_lpi_2_1_0[0])) | lfst_exit_STORE_LOOP_lpi_2_2
      | (~ (lfst_exit_STORE_LOOP_lpi_2_1_0[1])) | exitL_exit_STORE_LOOP_sva;
  assign mux_tmp_427 = MUX_s_1_2_2(nand_33_nl, or_296_nl, or_50_cse);
  assign or_dcpl_50 = ~(BATCH_LOOP_stage_0_8 & BATCH_LOOP_stage_v_7);
  assign or_dcpl_59 = ~(BATCH_LOOP_stage_0_7 & BATCH_LOOP_stage_v_6);
  assign or_dcpl_72 = ~(BATCH_LOOP_stage_0_5 & BATCH_LOOP_stage_v_4);
  assign and_dcpl_114 = BATCH_LOOP_stage_0_5 & BATCH_LOOP_stage_v_4;
  assign or_dcpl_78 = (~ BATCH_LOOP_stage_v_4) | STORE_LOOP_asn_51_itm_4;
  assign or_dcpl_85 = exit_BATCH_LOOP_lpi_2_dfm_1 | CALC_SOFTMAX_LOOP_asn_itm_1;
  assign or_dcpl_91 = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2) | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1]);
  assign and_dcpl_169 = BATCH_LOOP_stage_0_9 & BATCH_LOOP_stage_v_8;
  assign mux_tmp_428 = ~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0!=2'b10));
  assign or_dcpl_98 = (~ mux_tmp_428) | (~ reg_LOAD_LOOP_and_1_svs_1_cse) | exit_BATCH_LOOP_lpi_2_dfm_1;
  assign not_tmp_211 = MUX_s_1_2_2(mux_281_cse, (~ nand_tmp_21), reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse);
  assign or_369_nl = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]) | reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse;
  assign mux_452_nl = MUX_s_1_2_2((~ mux_281_cse), nand_tmp_21, or_369_nl);
  assign or_368_nl = reg_LOAD_LOOP_and_1_svs_1_cse | not_tmp_211;
  assign or_366_nl = dma_write_ctrl_rsci_irdy_mxwt | not_tmp_211;
  assign mux_448_nl = MUX_s_1_2_2(or_366_nl, not_tmp_211, CALC_SOFTMAX_LOOP_asn_19_itm_1);
  assign or_367_nl = exit_STORE_CTRL_LOOP_lpi_2 | mux_448_nl;
  assign mux_449_nl = MUX_s_1_2_2(not_tmp_211, or_367_nl, or_204_cse);
  assign mux_450_nl = MUX_s_1_2_2(mux_449_nl, not_tmp_211, or_194_cse);
  assign mux_451_nl = MUX_s_1_2_2(or_368_nl, mux_450_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign mux_453_nl = MUX_s_1_2_2(mux_452_nl, (~ mux_451_nl), lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]);
  assign mux_454_nl = MUX_s_1_2_2(mux_453_nl, mux_tmp_265, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign or_tmp_271 = BATCH_LOOP_if_acc_itm_32_1 | (~ mux_454_nl);
  assign not_tmp_217 = ~(reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse | (~ nor_tmp_41));
  assign nor_246_nl = ~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]) | reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse
      | (~ nor_tmp_41));
  assign nor_247_nl = ~(reg_LOAD_LOOP_and_1_svs_1_cse | reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse
      | (~ nor_tmp_41));
  assign or_376_nl = dma_write_ctrl_rsci_irdy_mxwt | not_tmp_217;
  assign mux_458_nl = MUX_s_1_2_2(or_376_nl, not_tmp_217, CALC_SOFTMAX_LOOP_asn_19_itm_1);
  assign or_377_nl = exit_STORE_CTRL_LOOP_lpi_2 | mux_458_nl;
  assign mux_459_nl = MUX_s_1_2_2(not_tmp_217, or_377_nl, or_204_cse);
  assign mux_460_nl = MUX_s_1_2_2(mux_459_nl, not_tmp_217, or_194_cse);
  assign mux_461_nl = MUX_s_1_2_2(nor_247_nl, mux_460_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign mux_462_nl = MUX_s_1_2_2(nor_246_nl, mux_461_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]);
  assign nor_248_nl = ~(reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse | (~ or_tmp_172));
  assign mux_tmp_449 = MUX_s_1_2_2(mux_462_nl, nor_248_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign or_tmp_291 = (~ BATCH_LOOP_and_21_tmp) | STORE_LOOP_asn_51_itm_1 | exit_BATCH_LOOP_lpi_2_dfm_1
      | STORE_LOOP_STORE_LOOP_and_10_itm_1;
  assign or_tmp_299 = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2) | reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse;
  assign or_tmp_300 = (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1])) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2;
  assign mux_tmp_467 = MUX_s_1_2_2(nor_153_cse, or_tmp_300, or_tmp_299);
  assign or_tmp_303 = (~ reg_LOAD_LOOP_and_1_svs_1_cse) | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]))
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2;
  assign and_tmp_87 = or_tmp_299 & or_tmp_303;
  assign mux_tmp_469 = MUX_s_1_2_2(nor_153_cse, or_tmp_300, reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse);
  assign nor_243_nl = ~(and_1785_cse | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_tmp_470 = MUX_s_1_2_2(nor_243_nl, or_tmp_303, reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse);
  assign mux_486_nl = MUX_s_1_2_2(mux_tmp_470, mux_tmp_469, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign nor_245_nl = ~((STORE_LOOP_mux1h_104_tmp!=2'b00) | (~ mux_486_nl));
  assign mux_483_nl = MUX_s_1_2_2(and_tmp_87, mux_tmp_467, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign mux_tmp_472 = MUX_s_1_2_2(nor_245_nl, mux_483_nl, STORE_LOOP_and_38_ssc_1);
  assign or_tmp_308 = or_tmp_299 | nor_153_cse;
  assign mux_489_nl = MUX_s_1_2_2(mux_tmp_470, or_tmp_174, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign nor_242_nl = ~((STORE_LOOP_mux1h_104_tmp!=2'b00) | (~ mux_489_nl));
  assign mux_488_nl = MUX_s_1_2_2(and_tmp_87, or_tmp_308, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign mux_tmp_475 = MUX_s_1_2_2(nor_242_nl, mux_488_nl, STORE_LOOP_and_38_ssc_1);
  assign mux_492_nl = MUX_s_1_2_2(mux_tmp_475, mux_tmp_472, dma_write_ctrl_rsci_irdy_mxwt);
  assign mux_493_nl = MUX_s_1_2_2(mux_492_nl, mux_tmp_475, CALC_SOFTMAX_LOOP_asn_19_itm_1);
  assign mux_494_nl = MUX_s_1_2_2(mux_493_nl, mux_tmp_472, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_495_nl = MUX_s_1_2_2(mux_tmp_475, mux_494_nl, or_204_cse);
  assign mux_496_nl = MUX_s_1_2_2(mux_495_nl, mux_tmp_475, or_194_cse);
  assign or_tmp_313 = BATCH_LOOP_if_acc_itm_32_1 | (~ mux_496_nl);
  assign or_tmp_316 = or_tmp_299 | (~ or_tmp_303);
  assign mux_tmp_486 = MUX_s_1_2_2(or_tmp_174, mux_tmp_469, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign mux_500_nl = MUX_s_1_2_2(or_tmp_316, mux_tmp_467, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign mux_tmp_487 = MUX_s_1_2_2(mux_tmp_486, mux_500_nl, STORE_LOOP_and_38_ssc_1);
  assign mux_503_nl = MUX_s_1_2_2(or_tmp_316, or_tmp_308, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign mux_tmp_489 = MUX_s_1_2_2(or_tmp_174, mux_503_nl, STORE_LOOP_and_38_ssc_1);
  assign mux_506_nl = MUX_s_1_2_2(mux_tmp_489, mux_tmp_487, dma_write_ctrl_rsci_irdy_mxwt);
  assign mux_507_nl = MUX_s_1_2_2(mux_506_nl, mux_tmp_489, CALC_SOFTMAX_LOOP_asn_19_itm_1);
  assign mux_508_nl = MUX_s_1_2_2(mux_507_nl, mux_tmp_487, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_509_nl = MUX_s_1_2_2(mux_tmp_489, mux_508_nl, or_204_cse);
  assign mux_510_cse = MUX_s_1_2_2(mux_509_nl, mux_tmp_489, or_194_cse);
  assign or_tmp_321 = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]) | (~ reg_LOAD_LOOP_and_1_svs_1_cse)
      | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1])) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2;
  assign mux_513_nl = MUX_s_1_2_2(or_tmp_321, (~ mux_tmp_486), or_24_cse);
  assign mux_tmp_499 = MUX_s_1_2_2(mux_513_nl, or_tmp_321, STORE_LOOP_and_38_ssc_1);
  assign mux_515_nl = MUX_s_1_2_2(or_tmp_321, (~ or_tmp_174), or_24_cse);
  assign mux_tmp_501 = MUX_s_1_2_2(mux_515_nl, or_tmp_321, STORE_LOOP_and_38_ssc_1);
  assign mux_499_cse = MUX_s_1_2_2((~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2), BATCH_LOOP_if_acc_itm_32_1,
      exitL_exit_STORE_LOOP_sva);
  assign or_394_cse = (STORE_LOOP_mux_55_tmp!=2'b00);
  assign or_392_cse = (lfst_exit_STORE_LOOP_lpi_2_1_0[0]) | (~ lfst_exit_STORE_LOOP_lpi_2_2)
      | (lfst_exit_STORE_LOOP_lpi_2_1_0[1]);
  assign and_1761_cse = (STORE_LOOP_acc_1_tmp[4]) & (BATCH_LOOP_acc_2_tmp[4]);
  assign mux_529_nl = MUX_s_1_2_2(or_tmp_313, or_46_cse, or_tmp_291);
  assign mux_518_nl = MUX_s_1_2_2(mux_tmp_501, mux_tmp_499, dma_write_ctrl_rsci_irdy_mxwt);
  assign mux_519_nl = MUX_s_1_2_2(mux_518_nl, mux_tmp_501, CALC_SOFTMAX_LOOP_asn_19_itm_1);
  assign mux_520_nl = MUX_s_1_2_2(mux_519_nl, mux_tmp_499, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_521_nl = MUX_s_1_2_2(mux_tmp_501, mux_520_nl, or_204_cse);
  assign mux_523_nl = MUX_s_1_2_2(mux_521_nl, mux_tmp_501, and_1742_cse);
  assign mux_524_nl = MUX_s_1_2_2((~ mux_523_nl), mux_510_cse, BATCH_LOOP_if_acc_itm_32_1);
  assign mux_512_nl = MUX_s_1_2_2(mux_510_cse, BATCH_LOOP_if_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_525_nl = MUX_s_1_2_2(mux_524_nl, mux_512_nl, STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign mux_526_nl = MUX_s_1_2_2(mux_525_nl, mux_499_cse, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_498_nl = MUX_s_1_2_2(or_tmp_313, or_46_cse, or_tmp_16);
  assign mux_527_nl = MUX_s_1_2_2(mux_526_nl, mux_498_nl, or_394_cse);
  assign and_1760_nl = exitL_exit_STORE_LOOP_sva & BATCH_LOOP_if_acc_itm_32_1;
  assign mux_481_nl = MUX_s_1_2_2(and_1760_nl, or_46_cse, or_392_cse);
  assign mux_528_nl = MUX_s_1_2_2(mux_527_nl, mux_481_nl, or_50_cse);
  assign mux_530_cse = MUX_s_1_2_2(mux_529_nl, mux_528_nl, and_1761_cse);
  assign and_dcpl_197 = BATCH_LOOP_stage_0_3 & BATCH_LOOP_stage_v_2;
  assign and_tmp_108 = or_622_cse & mux_415_cse;
  assign and_dcpl_201 = BATCH_LOOP_stage_0_4 & BATCH_LOOP_stage_v_3;
  assign and_tmp_109 = or_114_cse & or_623_cse;
  assign and_tmp_113 = or_67_cse & and_tmp_109;
  assign nor_238_nl = ~(nor_142_cse | BATCH_LOOP_stage_old_v_20 | (~ or_623_cse));
  assign and_331_nl = or_624_cse & and_tmp_109;
  assign mux_549_nl = MUX_s_1_2_2(nor_238_nl, and_331_nl, BATCH_LOOP_stage_0_21);
  assign and_332_nl = BATCH_LOOP_stage_0_20 & mux_549_nl;
  assign mux_550_nl = MUX_s_1_2_2(and_tmp_109, and_332_nl, BATCH_LOOP_stage_old_v_19);
  assign and_333_nl = BATCH_LOOP_stage_0_19 & mux_550_nl;
  assign mux_551_nl = MUX_s_1_2_2(and_tmp_113, and_333_nl, BATCH_LOOP_stage_v_18);
  assign and_335_nl = BATCH_LOOP_stage_0_18 & mux_551_nl;
  assign mux_552_nl = MUX_s_1_2_2(and_tmp_113, and_335_nl, BATCH_LOOP_stage_v_17);
  assign and_336_nl = BATCH_LOOP_stage_0_17 & mux_552_nl;
  assign mux_553_nl = MUX_s_1_2_2(and_tmp_113, and_336_nl, BATCH_LOOP_stage_v_16);
  assign and_337_nl = BATCH_LOOP_stage_0_16 & mux_553_nl;
  assign mux_554_nl = MUX_s_1_2_2(and_tmp_113, and_337_nl, BATCH_LOOP_stage_v_15);
  assign and_338_nl = BATCH_LOOP_stage_0_15 & mux_554_nl;
  assign mux_555_nl = MUX_s_1_2_2(and_tmp_113, and_338_nl, BATCH_LOOP_stage_v_14);
  assign and_339_nl = BATCH_LOOP_stage_0_14 & mux_555_nl;
  assign mux_556_nl = MUX_s_1_2_2(and_tmp_113, and_339_nl, BATCH_LOOP_stage_v_13);
  assign and_340_nl = BATCH_LOOP_stage_0_13 & mux_556_nl;
  assign mux_557_nl = MUX_s_1_2_2(and_tmp_113, and_340_nl, BATCH_LOOP_stage_v_12);
  assign and_341_nl = BATCH_LOOP_stage_0_12 & mux_557_nl;
  assign mux_558_nl = MUX_s_1_2_2(and_tmp_113, and_341_nl, BATCH_LOOP_stage_v_11);
  assign and_342_nl = BATCH_LOOP_stage_0_11 & mux_558_nl;
  assign mux_559_nl = MUX_s_1_2_2(and_tmp_113, and_342_nl, BATCH_LOOP_stage_v_10);
  assign and_343_nl = BATCH_LOOP_stage_0_10 & mux_559_nl;
  assign mux_560_nl = MUX_s_1_2_2(and_tmp_113, and_343_nl, BATCH_LOOP_stage_v_9);
  assign and_344_nl = BATCH_LOOP_stage_0_9 & mux_560_nl;
  assign mux_561_nl = MUX_s_1_2_2(and_tmp_113, and_344_nl, BATCH_LOOP_stage_v_8);
  assign and_345_nl = BATCH_LOOP_stage_0_8 & mux_561_nl;
  assign mux_562_nl = MUX_s_1_2_2(and_tmp_113, and_345_nl, BATCH_LOOP_stage_v_7);
  assign and_346_nl = BATCH_LOOP_stage_0_7 & mux_562_nl;
  assign mux_563_nl = MUX_s_1_2_2(and_tmp_113, and_346_nl, BATCH_LOOP_stage_v_6);
  assign and_347_nl = BATCH_LOOP_stage_0_6 & mux_563_nl;
  assign mux_564_nl = MUX_s_1_2_2(and_tmp_113, and_347_nl, BATCH_LOOP_stage_v_5);
  assign and_348_nl = BATCH_LOOP_stage_0_5 & mux_564_nl;
  assign mux_565_nl = MUX_s_1_2_2(and_tmp_113, and_348_nl, BATCH_LOOP_stage_v_4);
  assign and_tmp_128 = or_622_cse & mux_565_nl;
  assign and_dcpl_204 = and_tmp_108 & and_dcpl_197;
  assign and_416_cse = BATCH_LOOP_stage_0_6 & BATCH_LOOP_stage_v_5;
  assign and_439_cse = BATCH_LOOP_stage_0_7 & BATCH_LOOP_stage_v_6;
  assign and_1758_nl = BATCH_LOOP_stage_v_8 & BATCH_LOOP_stage_v_9;
  assign mux_tmp_663 = MUX_s_1_2_2(and_tmp_41, and_tmp_50, and_1758_nl);
  assign and_dcpl_291 = mux_tmp_663 & (ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3==71'b00000000000000000000000000000000000000000000000000000000000000000000000);
  assign and_572_cse = BATCH_LOOP_stage_0_10 & BATCH_LOOP_stage_v_9;
  assign and_591_cse = BATCH_LOOP_stage_0_11 & BATCH_LOOP_stage_v_10;
  assign and_609_cse = BATCH_LOOP_stage_0_12 & BATCH_LOOP_stage_v_11;
  assign and_617_cse = or_67_cse & and_tmp_12;
  assign and_dcpl_304 = BATCH_LOOP_stage_0_13 & BATCH_LOOP_stage_v_12;
  assign and_dcpl_309 = BATCH_LOOP_stage_0_14 & BATCH_LOOP_stage_v_13;
  assign and_dcpl_313 = BATCH_LOOP_stage_0_15 & BATCH_LOOP_stage_v_14;
  assign and_dcpl_317 = BATCH_LOOP_stage_0_16 & BATCH_LOOP_stage_v_15;
  assign or_tmp_446 = BATCH_LOOP_stage_v_18 | (~ and_tmp_12);
  assign mux_tmp_732 = MUX_s_1_2_2((~ or_tmp_446), and_tmp_12, BATCH_LOOP_stage_0_19);
  assign and_dcpl_329 = BATCH_LOOP_stage_0_19 & BATCH_LOOP_stage_v_18;
  assign and_tmp_360 = BATCH_LOOP_stage_0_19 & and_tmp_12;
  assign and_tmp_362 = BATCH_LOOP_stage_v_17 & BATCH_LOOP_stage_0_18 & and_tmp_12;
  assign and_dcpl_332 = BATCH_LOOP_stage_old_v_20 & BATCH_LOOP_stage_0_21;
  assign or_tmp_454 = dma_write_chnl_rsci_bawt | exit_BATCH_LOOP_lpi_2_dfm_st_21
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_21_1_0[1]) | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_21_2)
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_21_1_0[0]);
  assign or_tmp_496 = reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse | (~((~ (STORE_LOOP_i_4_0_sva_1_1[4]))
      | (~ STORE_LOOP_equal_tmp_2_1) | lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2)) | and_1783_cse;
  assign nand_tmp_39 = ~((~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]) & reg_LOAD_LOOP_and_1_svs_1_cse))
      & (~ reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse) & (STORE_LOOP_i_4_0_sva_1_1[4])
      & STORE_LOOP_equal_tmp_2_1 & lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2 & (~ and_1783_cse));
  assign nand_38_nl = ~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]) & (~ and_1783_cse));
  assign mux_813_nl = MUX_s_1_2_2(nand_tmp_39, nand_38_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign mux_tmp_799 = MUX_s_1_2_2(mux_813_nl, or_tmp_496, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign nand_40_nl = ~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]) & (~ reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse)
      & (STORE_LOOP_i_4_0_sva_1_1[4]) & STORE_LOOP_equal_tmp_2_1 & lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2
      & (~ and_1783_cse));
  assign mux_815_nl = MUX_s_1_2_2(nand_tmp_39, nand_40_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign mux_tmp_801 = MUX_s_1_2_2(mux_815_nl, or_tmp_496, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign and_dcpl_343 = BATCH_LOOP_stage_0_20 & BATCH_LOOP_stage_old_v_19;
  assign and_tmp_543 = or_624_cse & mux_416_cse;
  assign and_1746_nl = BATCH_LOOP_stage_v_7 & BATCH_LOOP_stage_v_8;
  assign mux_tmp_952 = MUX_s_1_2_2(and_tmp_41, and_tmp_51, and_1746_nl);
  assign and_dcpl_418 = mux_tmp_952 & (ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2==71'b00000000000000000000000000000000000000000000000000000000000000000000000);
  assign and_1744_nl = BATCH_LOOP_stage_v_5 & BATCH_LOOP_stage_v_6;
  assign mux_tmp_954 = MUX_s_1_2_2(and_tmp_41, and_tmp_53, and_1744_nl);
  assign or_tmp_587 = or_622_cse & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_1_0==2'b00)
      & lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_2 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_20)
      & BATCH_LOOP_stage_old_v_20 & BATCH_LOOP_stage_0_21 & (fsm_output[2]);
  assign or_tmp_591 = or_dcpl_11 & and_dcpl_91 & (fsm_output[2]);
  assign mux_333_nl = MUX_s_1_2_2(mux_tmp_237, or_tmp_25, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign or_1049_nl = (STORE_LOOP_mux_55_tmp!=2'b10) | mux_333_nl;
  assign mux_340_nl = MUX_s_1_2_2(or_1049_nl, or_29_cse, STORE_LOOP_asn_51_itm_1);
  assign or_tmp_598 = (mux_340_nl | (~ BATCH_LOOP_and_22_tmp)) & and_dcpl_46 & (fsm_output[2]);
  assign or_tmp_608 = ~((fsm_output[2]) & mux_tmp_299 & BATCH_LOOP_stage_0_20 & CALC_SOFTMAX_LOOP_mul_cmp_bawt
      & (~ exit_BATCH_LOOP_lpi_2_dfm_st_19) & (~ CALC_SOFTMAX_LOOP_asn_itm_19) &
      (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_1_0==2'b11) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_2)
      & BATCH_LOOP_stage_old_v_19);
  assign or_tmp_642 = mux_tmp_427 & BATCH_LOOP_and_22_tmp & (fsm_output[2]);
  assign or_tmp_651 = mux_tmp_426 & (~ BATCH_LOOP_if_acc_itm_32_1) & BATCH_LOOP_and_22_tmp
      & (fsm_output[2]);
  assign or_tmp_680 = mux_tmp_314 & and_dcpl_114 & (~ STORE_LOOP_asn_51_itm_4) &
      (fsm_output[2]);
  assign or_tmp_740 = (~ exit_BATCH_LOOP_lpi_2_dfm_1) & BATCH_LOOP_and_21_tmp & (fsm_output[2]);
  assign or_tmp_817 = (~ mux_530_cse) & BATCH_LOOP_and_22_tmp & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_7_lpi_2_dfm_2_mx0c1
      = mux_tmp_314 & and_dcpl_114 & (~ STORE_LOOP_and_61_itm_3) & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_6_lpi_2_dfm_2_mx0c1
      = mux_tmp_314 & and_dcpl_114 & (~ STORE_LOOP_and_60_itm_3) & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_9_lpi_2_dfm_2_mx0c1
      = mux_tmp_314 & and_dcpl_114 & (~ STORE_LOOP_and_63_itm_3) & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_5_lpi_2_dfm_2_mx0c1
      = mux_tmp_314 & and_dcpl_114 & (~ STORE_LOOP_and_59_itm_3) & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_4_lpi_2_dfm_2_mx0c1
      = mux_tmp_314 & and_dcpl_114 & (~ STORE_LOOP_and_58_itm_3) & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_11_lpi_2_dfm_2_mx0c1
      = mux_tmp_314 & and_dcpl_114 & (~ STORE_LOOP_and_65_itm_3) & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_3_lpi_2_dfm_2_mx0c1
      = mux_tmp_314 & and_dcpl_114 & (~ STORE_LOOP_and_57_itm_3) & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_12_lpi_2_dfm_2_mx0c1
      = mux_tmp_314 & and_dcpl_114 & (~ STORE_LOOP_and_66_itm_3) & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_2_lpi_2_dfm_2_mx0c1
      = mux_tmp_314 & and_dcpl_114 & (~ STORE_LOOP_and_56_itm_3) & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_13_lpi_2_dfm_2_mx0c1
      = mux_tmp_314 & and_dcpl_114 & (~ STORE_LOOP_and_67_itm_3) & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_1_lpi_2_dfm_2_mx0c1
      = mux_tmp_314 & and_dcpl_114 & (~ STORE_LOOP_and_55_itm_3) & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_0_lpi_2_dfm_2_mx0c1
      = mux_tmp_314 & and_dcpl_114 & (~ STORE_LOOP_and_54_itm_3) & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_15_lpi_2_dfm_2_mx0c1
      = mux_tmp_314 & and_dcpl_114 & (~ STORE_LOOP_and_69_itm_3) & (fsm_output[2]);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3_mx0c1
      = mux_tmp_310 & and_dcpl_169 & (~ STORE_LOOP_and_42_itm_4) & (fsm_output[2]);
  assign BATCH_LOOP_acc_3_psp_lpi_2_dfm_2_mx0c1 = or_dcpl_98 & BATCH_LOOP_and_21_tmp
      & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_8_lpi_2_dfm_2_mx0c1
      = mux_tmp_314 & and_dcpl_114 & (~ STORE_LOOP_and_62_itm_3) & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_10_lpi_2_dfm_2_mx0c1
      = mux_tmp_314 & and_dcpl_114 & (~ STORE_LOOP_and_64_itm_3) & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_14_lpi_2_dfm_2_mx0c1
      = mux_tmp_314 & and_dcpl_114 & (~ STORE_LOOP_and_68_itm_3) & (fsm_output[2]);
  assign BATCH_LOOP_stage_v_mx0c1 = (~(mux_530_cse & BATCH_LOOP_stage_0)) & BATCH_LOOP_and_22_tmp
      & (fsm_output[2]);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_mx0c1
      = mux_tmp_310 & and_dcpl_169 & (~ STORE_LOOP_asn_51_itm_8) & (fsm_output[2]);
  assign BATCH_LOOP_stage_v_2_mx0c0 = (fsm_output[1]) | (and_tmp_108 & and_dcpl_197
      & (~ BATCH_LOOP_and_21_tmp) & (fsm_output[2]));
  assign BATCH_LOOP_stage_v_3_mx0c0 = (fsm_output[1]) | (and_tmp_128 & and_dcpl_201
      & not_tmp_41 & (fsm_output[2]));
  assign nor_143_nl = ~(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[0]) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2
      | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[1])) | exit_BATCH_LOOP_lpi_2_dfm_st_3
      | (~ mux_tmp_314));
  assign mux_602_nl = MUX_s_1_2_2(mux_tmp_314, nor_143_nl, and_dcpl_201);
  assign BATCH_LOOP_stage_v_4_mx0c0 = (fsm_output[1]) | (mux_602_nl & and_dcpl_114
      & (fsm_output[2]));
  assign BATCH_LOOP_stage_v_5_mx0c0 = (fsm_output[1]) | (mux_tmp_313 & and_416_cse
      & or_dcpl_72 & (fsm_output[2]));
  assign BATCH_LOOP_stage_v_6_mx0c0 = (fsm_output[1]) | (mux_tmp_312 & and_439_cse
      & (~(BATCH_LOOP_stage_0_6 & BATCH_LOOP_stage_v_5)) & (fsm_output[2]));
  assign BATCH_LOOP_stage_v_7_mx0c0 = (fsm_output[1]) | (mux_tmp_311 & and_dcpl_57
      & or_dcpl_59 & (fsm_output[2]));
  assign BATCH_LOOP_stage_v_8_mx0c0 = (fsm_output[1]) | (mux_tmp_310 & and_dcpl_169
      & or_dcpl_50 & (fsm_output[2]));
  assign BATCH_LOOP_stage_v_9_mx0c0 = (fsm_output[1]) | (mux_tmp_309 & and_572_cse
      & (~(BATCH_LOOP_stage_0_9 & BATCH_LOOP_stage_v_8)) & (fsm_output[2]));
  assign BATCH_LOOP_stage_v_10_mx0c0 = (fsm_output[1]) | (mux_tmp_308 & and_591_cse
      & (~(BATCH_LOOP_stage_0_10 & BATCH_LOOP_stage_v_9)) & (fsm_output[2]));
  assign BATCH_LOOP_stage_v_11_mx0c0 = (fsm_output[1]) | (mux_tmp_307 & and_609_cse
      & (~(BATCH_LOOP_stage_0_11 & BATCH_LOOP_stage_v_10)) & (fsm_output[2]));
  assign BATCH_LOOP_stage_v_12_mx0c0 = (fsm_output[1]) | (mux_tmp_306 & and_dcpl_304
      & (~(BATCH_LOOP_stage_0_12 & BATCH_LOOP_stage_v_11)) & (fsm_output[2]));
  assign plm_out_data_rsci_d_d = CALC_SOFTMAX_LOOP_mux_1_rmff;
  assign plm_out_data_rsci_radr_d = STORE_LOOP_i_mux_rmff;
  assign plm_out_data_rsci_wadr_d = CALC_SOFTMAX_LOOP_i_mux_rmff;
  assign plm_out_data_rsci_we_d_pff = plm_out_data_rsci_we_d_iff;
  assign plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d = plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  assign or_dcpl_126 = (STORE_LOOP_and_39_itm_mx0w0 & (~ dma_read_ctrl_rsci_irdy_mxwt))
      | STORE_LOOP_or_51_itm_mx0w0;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_chnl_rsci_idat_31_0 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | and_dcpl_42 | or_dcpl_11)) ) begin
      dma_write_chnl_rsci_idat_31_0 <= plm_out_data_rsci_q_d_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_ctrl_rsci_idat_31_4 <= 28'b0000000000000000000000000000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | mux_tmp_247 | (~ BATCH_LOOP_and_22_tmp)))
        ) begin
      dma_write_ctrl_rsci_idat_31_4 <= BATCH_LOOP_acc_3_psp_lpi_2_mx1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_read_ctrl_rsci_idat_7_4 <= 4'b0000;
    end
    else if ( core_wen & (fsm_output[2]) & mux_312_cse & BATCH_LOOP_and_22_tmp )
        begin
      dma_read_ctrl_rsci_idat_7_4 <= BATCH_LOOP_b_4_0_sva_3_0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_iswt1_cse
          <= 1'b0;
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_b_core
          <= 32'b00000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mul_cmp_iswt11 <= 1'b0;
      reg_CALC_SOFTMAX_LOOP_mul_cmp_oswt_cse <= 1'b0;
      reg_plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse <= 1'b0;
      reg_acc_done_rsci_ivld_core_psct_cse <= 1'b0;
      reg_dma_write_ctrl_rsci_ivld_core_psct_cse <= 1'b0;
      reg_dma_read_ctrl_rsci_ivld_core_psct_cse <= 1'b0;
      reg_conf_info_rsci_irdy_core_psct_cse <= 1'b0;
      plm_out_data_rsci_wadr_d_reg <= 4'b0000;
      plm_out_data_rsci_radr_d_reg <= 4'b0000;
      plm_out_data_rsci_d_d_reg <= 32'b00000000000000000000000000000000;
      BATCH_LOOP_stage_v_13 <= 1'b0;
      BATCH_LOOP_stage_v_14 <= 1'b0;
      BATCH_LOOP_stage_v_15 <= 1'b0;
      BATCH_LOOP_stage_v_16 <= 1'b0;
      BATCH_LOOP_stage_v_17 <= 1'b0;
      BATCH_LOOP_stage_v_18 <= 1'b0;
      BATCH_LOOP_stage_v_21 <= 1'b0;
      SUM_EXP_LOOP_i_4_0_lpi_2_3_0 <= 4'b0000;
      CALC_EXP_LOOP_i_4_0_lpi_2_3_0 <= 4'b0000;
      BATCH_LOOP_acc_3_psp_lpi_2 <= 28'b0000000000000000000000000000;
      exit_STORE_CTRL_LOOP_lpi_2 <= 1'b0;
      exit_CALC_SOFTMAX_LOOP_lpi_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_1_0 <= 2'b00;
      STORE_LOOP_i_4_0_lpi_2_3_0 <= 4'b0000;
      exitL_exit_STORE_LOOP_sva <= 1'b0;
      BATCH_LOOP_stage_0_2 <= 1'b0;
      BATCH_LOOP_stage_0_14 <= 1'b0;
      BATCH_LOOP_stage_0_15 <= 1'b0;
      BATCH_LOOP_stage_0_16 <= 1'b0;
      BATCH_LOOP_stage_0_17 <= 1'b0;
      BATCH_LOOP_stage_0_18 <= 1'b0;
      BATCH_LOOP_stage_0_19 <= 1'b0;
      BATCH_LOOP_stage_0_20 <= 1'b0;
      BATCH_LOOP_stage_0_21 <= 1'b0;
      BATCH_LOOP_stage_old_v_1 <= 1'b0;
      BATCH_LOOP_stage_old_v_19 <= 1'b0;
      BATCH_LOOP_stage_old_v_20 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_4_0_lpi_2_3_0 <= 4'b0000;
    end
    else if ( core_wen ) begin
      reg_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_iswt1_cse
          <= and_1009_rmff;
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_b_core
          <= dma_read_chnl_rsci_idat_mxwt;
      CALC_SOFTMAX_LOOP_mul_cmp_iswt11 <= mux_tmp_311 & and_dcpl_57 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_7)
          & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_1_0[1]) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_2)
          & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_1_0[0]) & (~ CALC_SOFTMAX_LOOP_asn_itm_7)
          & (fsm_output[2]);
      reg_CALC_SOFTMAX_LOOP_mul_cmp_oswt_cse <= and_1015_rmff;
      reg_plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse <= and_1017_rmff;
      reg_acc_done_rsci_ivld_core_psct_cse <= BATCH_LOOP_nor_22_tmp & (fsm_output[2]);
      reg_dma_write_ctrl_rsci_ivld_core_psct_cse <= (~ mux_tmp_247) & BATCH_LOOP_and_22_tmp
          & (fsm_output[2]);
      reg_dma_read_ctrl_rsci_ivld_core_psct_cse <= mux_312_cse & BATCH_LOOP_and_22_tmp
          & (fsm_output[2]);
      reg_conf_info_rsci_irdy_core_psct_cse <= ~((fsm_output[2:1]!=2'b00));
      plm_out_data_rsci_wadr_d_reg <= CALC_SOFTMAX_LOOP_i_mux_rmff;
      plm_out_data_rsci_radr_d_reg <= STORE_LOOP_i_mux_rmff;
      plm_out_data_rsci_d_d_reg <= CALC_SOFTMAX_LOOP_mux_1_rmff;
      BATCH_LOOP_stage_v_13 <= ((BATCH_LOOP_stage_v_13 & (~(mux_tmp_305 & and_dcpl_309
          & (~(BATCH_LOOP_stage_0_13 & BATCH_LOOP_stage_v_12))))) | (mux_tmp_306
          & and_dcpl_304)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_14 <= ((BATCH_LOOP_stage_v_14 & (~(mux_tmp_304 & and_dcpl_313
          & (~(BATCH_LOOP_stage_0_14 & BATCH_LOOP_stage_v_13))))) | (mux_tmp_305
          & and_dcpl_309)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_15 <= ((BATCH_LOOP_stage_v_15 & (~(mux_tmp_303 & and_dcpl_317
          & (~(BATCH_LOOP_stage_0_15 & BATCH_LOOP_stage_v_14))))) | (mux_tmp_304
          & and_dcpl_313)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_16 <= ((BATCH_LOOP_stage_v_16 & (~(mux_tmp_302 & and_1778_cse
          & (~(BATCH_LOOP_stage_0_16 & BATCH_LOOP_stage_v_15))))) | (mux_tmp_303
          & and_dcpl_317)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_17 <= ((BATCH_LOOP_stage_v_17 & (~(mux_tmp_301 & and_1790_cse
          & (~(BATCH_LOOP_stage_0_17 & BATCH_LOOP_stage_v_16))))) | (mux_tmp_302
          & and_1778_cse)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_18 <= ((BATCH_LOOP_stage_v_18 & (~(mux_tmp_300 & and_dcpl_329
          & (~(BATCH_LOOP_stage_0_18 & BATCH_LOOP_stage_v_17))))) | (mux_tmp_301
          & and_1790_cse)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_21 <= ((BATCH_LOOP_stage_v_21 & (~ mux_759_nl)) | (mux_tmp_402
          & and_dcpl_332)) & (fsm_output[2]);
      SUM_EXP_LOOP_i_4_0_lpi_2_3_0 <= MUX_v_4_2_2(SUM_EXP_LOOP_i_4_0_lpi_2_dfm_2_3_0,
          SUM_EXP_LOOP_i_4_0_lpi_2_3_0_mx1, fsm_output[2]);
      CALC_EXP_LOOP_i_4_0_lpi_2_3_0 <= MUX_v_4_2_2(CALC_EXP_LOOP_i_4_0_lpi_2_dfm_2_3_0,
          CALC_EXP_LOOP_i_4_0_lpi_2_3_0_mx1, fsm_output[2]);
      BATCH_LOOP_acc_3_psp_lpi_2 <= MUX_v_28_2_2(BATCH_LOOP_acc_3_psp_lpi_2_dfm_2,
          BATCH_LOOP_acc_3_psp_lpi_2_mx1, fsm_output[2]);
      exit_STORE_CTRL_LOOP_lpi_2 <= MUX_s_1_2_2(exit_STORE_CTRL_LOOP_lpi_2_dfm_3,
          exit_STORE_CTRL_LOOP_lpi_2_mx1, fsm_output[2]);
      exit_CALC_SOFTMAX_LOOP_lpi_2 <= MUX_s_1_2_2(exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3,
          exit_CALC_SOFTMAX_LOOP_lpi_2_mx1, fsm_output[2]);
      lfst_exit_STORE_LOOP_lpi_2_1_0 <= lfst_exit_STORE_LOOP_lpi_2_1_0_mx0;
      STORE_LOOP_i_4_0_lpi_2_3_0 <= MUX_v_4_2_2(STORE_LOOP_i_4_0_lpi_2_dfm_2_3_0,
          STORE_LOOP_i_4_0_lpi_2_3_0_mx1, fsm_output[2]);
      exitL_exit_STORE_LOOP_sva <= exitL_exit_STORE_LOOP_sva_mx1 | (~ (fsm_output[2]));
      BATCH_LOOP_stage_0_2 <= BATCH_LOOP_mux_25_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_14 <= BATCH_LOOP_mux_27_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_15 <= BATCH_LOOP_mux_29_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_16 <= BATCH_LOOP_mux_31_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_17 <= BATCH_LOOP_mux_33_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_18 <= BATCH_LOOP_mux_35_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_19 <= BATCH_LOOP_mux_37_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_20 <= BATCH_LOOP_mux_39_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_21 <= BATCH_LOOP_mux_41_nl & (fsm_output[2]);
      BATCH_LOOP_stage_old_v_1 <= ((BATCH_LOOP_stage_old_v_1 & (~ BATCH_LOOP_and_21_tmp))
          | BATCH_LOOP_and_22_tmp) & (fsm_output[2]);
      BATCH_LOOP_stage_old_v_19 <= ((BATCH_LOOP_stage_old_v_19 & (~(and_tmp_543 &
          and_dcpl_343 & not_tmp_46))) | (mux_tmp_300 & and_dcpl_329)) & (fsm_output[2]);
      BATCH_LOOP_stage_old_v_20 <= ((BATCH_LOOP_stage_old_v_20 & (~(mux_966_nl &
          and_dcpl_332))) | (and_tmp_543 & and_dcpl_343)) & (fsm_output[2]);
      CALC_SOFTMAX_LOOP_i_4_0_lpi_2_3_0 <= MUX_v_4_2_2(CALC_SOFTMAX_LOOP_i_4_0_lpi_2_dfm_3_3_0,
          CALC_SOFTMAX_LOOP_i_4_0_lpi_2_3_0_mx1, fsm_output[2]);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_dma_write_chnl_rsci_ivld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & (or_tmp_587 | or_tmp_591) ) begin
      reg_dma_write_chnl_rsci_ivld_core_psct_cse <= ~ or_tmp_591;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_dma_read_chnl_rsci_irdy_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & (((~ mux_339_nl) & BATCH_LOOP_and_22_tmp & (fsm_output[2]))
        | or_tmp_598) ) begin
      reg_dma_read_chnl_rsci_irdy_core_psct_cse <= ~ or_tmp_598;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0 <= 2'b00;
      exit_BATCH_LOOP_lpi_2_dfm_st_3 <= 1'b0;
    end
    else if ( STORE_LOOP_and_100_cse ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_1_0;
      exit_BATCH_LOOP_lpi_2_dfm_st_3 <= exit_BATCH_LOOP_lpi_2_dfm_st_2;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_asn_itm_19 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_1_0 <= 2'b00;
      exit_BATCH_LOOP_lpi_2_dfm_st_19 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_cse ) begin
      CALC_SOFTMAX_LOOP_asn_itm_19 <= CALC_SOFTMAX_LOOP_asn_itm_18;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_18_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_18_1_0;
      exit_BATCH_LOOP_lpi_2_dfm_st_19 <= exit_BATCH_LOOP_lpi_2_dfm_st_18;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_asn_itm_20 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_1_0 <= 2'b00;
      exit_BATCH_LOOP_lpi_2_dfm_st_20 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_40_cse ) begin
      CALC_SOFTMAX_LOOP_asn_itm_20 <= CALC_SOFTMAX_LOOP_asn_itm_19;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_19_1_0;
      exit_BATCH_LOOP_lpi_2_dfm_st_20 <= exit_BATCH_LOOP_lpi_2_dfm_st_19;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_21_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_21_1_0 <= 2'b00;
      exit_BATCH_LOOP_lpi_2_dfm_st_21 <= 1'b0;
    end
    else if ( STORE_LOOP_and_106_cse ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_21_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_21_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_1_0;
      exit_BATCH_LOOP_lpi_2_dfm_st_21 <= exit_BATCH_LOOP_lpi_2_dfm_st_20;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_i_4_0_lpi_2_3_0 <= 4'b0000;
      lfst_exit_STORE_LOOP_lpi_2_2 <= 1'b0;
    end
    else if ( LOAD_LOOP_i_and_cse ) begin
      LOAD_LOOP_i_4_0_lpi_2_3_0 <= MUX_v_4_2_2(LOAD_LOOP_i_4_0_lpi_2_3_0_mx1, LOAD_LOOP_i_4_0_lpi_2_dfm_2_3_0,
          fsm_output[3]);
      lfst_exit_STORE_LOOP_lpi_2_2 <= MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_2_mx1,
          lfst_exit_STORE_LOOP_lpi_2_dfm_8_2, fsm_output[3]);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_BATCH_LOOP_lpi_2_dfm_1 <= 1'b0;
      reg_LOAD_LOOP_and_1_svs_1_cse <= 1'b0;
      STORE_LOOP_equal_tmp_2_1 <= 1'b0;
      SUM_EXP_LOOP_i_4_0_sva_1_1_3_0 <= 4'b0000;
      CALC_EXP_LOOP_i_4_0_sva_1_1_3_0 <= 4'b0000;
      LOAD_LOOP_i_4_0_sva_1_1_3_0 <= 4'b0000;
      BATCH_LOOP_b_slc_BATCH_LOOP_b_4_0_3_0_1_itm_1 <= 4'b0000;
      STORE_LOOP_i_4_0_sva_1_1 <= 5'b00000;
      CALC_SOFTMAX_LOOP_i_4_0_sva_1_1 <= 5'b00000;
      lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2 <= 1'b0;
      reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse <= 1'b0;
      STORE_LOOP_STORE_LOOP_and_6_itm_1 <= 1'b0;
      STORE_LOOP_STORE_LOOP_and_10_itm_1 <= 1'b0;
      STORE_LOOP_asn_51_itm_1 <= 1'b0;
    end
    else if ( BATCH_LOOP_and_26_cse ) begin
      exit_BATCH_LOOP_lpi_2_dfm_1 <= exit_BATCH_LOOP_lpi_2_dfm_mx0w0;
      reg_LOAD_LOOP_and_1_svs_1_cse <= (LOAD_LOOP_i_4_0_sva_2[4]) & (CALC_EXP_LOOP_i_4_0_sva_2[4])
          & (SUM_EXP_LOOP_i_4_0_sva_2[4]);
      STORE_LOOP_equal_tmp_2_1 <= STORE_LOOP_equal_tmp_2_mx0w0;
      SUM_EXP_LOOP_i_4_0_sva_1_1_3_0 <= SUM_EXP_LOOP_i_4_0_sva_2[3:0];
      CALC_EXP_LOOP_i_4_0_sva_1_1_3_0 <= CALC_EXP_LOOP_i_4_0_sva_2[3:0];
      LOAD_LOOP_i_4_0_sva_1_1_3_0 <= LOAD_LOOP_i_4_0_sva_2[3:0];
      BATCH_LOOP_b_slc_BATCH_LOOP_b_4_0_3_0_1_itm_1 <= BATCH_LOOP_b_4_0_sva_3_0;
      STORE_LOOP_i_4_0_sva_1_1 <= STORE_LOOP_acc_1_tmp;
      CALC_SOFTMAX_LOOP_i_4_0_sva_1_1 <= nl_CALC_SOFTMAX_LOOP_i_4_0_sva_1_1[4:0];
      lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2 <= BATCH_LOOP_acc_2_tmp[4];
      reg_STORE_LOOP_STORE_LOOP_nor_2_itm_1_cse <= ~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0
          | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0!=2'b00));
      STORE_LOOP_STORE_LOOP_and_6_itm_1 <= (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0==2'b11)
          & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0);
      STORE_LOOP_STORE_LOOP_and_10_itm_1 <= STORE_LOOP_STORE_LOOP_STORE_LOOP_and_cse_mx0w1;
      STORE_LOOP_asn_51_itm_1 <= STORE_LOOP_STORE_LOOP_STORE_LOOP_and_cse_mx0w1 |
          exit_BATCH_LOOP_lpi_2_dfm_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0 <= 2'b00;
    end
    else if ( core_wen & ((and_dcpl_105 & (fsm_output[2])) | STORE_LOOP_and_195_rgt)
        ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0 <= MUX_v_2_2_2((signext_2_1(~ BATCH_LOOP_if_acc_itm_32_1)),
          lfst_exit_STORE_LOOP_lpi_2_1_0_mx0, STORE_LOOP_and_195_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_asn_19_itm_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_itm_1 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_41_cse ) begin
      CALC_SOFTMAX_LOOP_asn_19_itm_1 <= MUX_s_1_2_2(exit_STORE_CTRL_LOOP_lpi_2_mx1,
          CALC_SOFTMAX_LOOP_asn_19_itm, or_tmp_642);
      CALC_SOFTMAX_LOOP_asn_itm_1 <= MUX_s_1_2_2(exit_CALC_SOFTMAX_LOOP_lpi_2_mx1,
          CALC_SOFTMAX_LOOP_asn_itm, or_tmp_642);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_105 | and_dcpl_106) & (fsm_output[2]) ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 <= MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx1w0,
          lfst_exit_STORE_LOOP_lpi_2_2_mx1, and_dcpl_106);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0 <= 2'b00;
    end
    else if ( STORE_LOOP_and_110_cse ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2 <= MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0,
          lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2, or_tmp_651);
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0 <= MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0,
          lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_0, or_tmp_651);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_7_2 <= 6'b000000;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_0 <= 2'b00;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm
          <= 10'b0000000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm
          <= 11'b00000000000;
    end
    else if ( ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_and_cse ) begin
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_7_2 <= ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_0 <= ~ ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_slc_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_1_0_itm_1;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm
          <= ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[9:0];
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm
          <= ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_asn_19_itm <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_itm <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_43_cse ) begin
      CALC_SOFTMAX_LOOP_asn_19_itm <= exit_STORE_CTRL_LOOP_lpi_2_mx1;
      CALC_SOFTMAX_LOOP_asn_itm <= exit_CALC_SOFTMAX_LOOP_lpi_2_mx1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_0 <= 2'b00;
    end
    else if ( STORE_LOOP_and_113_cse ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_slc_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_1_0_itm
          <= 2'b00;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_acc_itm <= 6'b000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm
          <= 10'b0000000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_69_57_9_0_itm
          <= 10'b0000000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm
          <= 8'b00000000;
    end
    else if ( ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_and_cse
        ) begin
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_slc_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_1_0_itm
          <= ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_sva_1[1:0];
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_acc_itm <= ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0;
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
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm
          <= 1'b0;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | (~ mux_tmp_314) | or_dcpl_72 |
        exit_BATCH_LOOP_lpi_2_dfm_st_4 | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2
        | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0!=2'b10))) ) begin
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm
          <= ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_14_lpi_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_39_cse
        & (STORE_LOOP_and_68_itm_3 | (fsm_output[3])) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_14_lpi_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_14_lpi_2_dfm_2,
          fsm_output[3]);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_10_lpi_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_39_cse
        & (STORE_LOOP_and_64_itm_3 | (fsm_output[3])) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_10_lpi_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_10_lpi_2_dfm_2,
          fsm_output[3]);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_8_lpi_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_39_cse
        & (STORE_LOOP_and_62_itm_3 | (fsm_output[3])) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_8_lpi_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_8_lpi_2_dfm_2,
          fsm_output[3]);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_mux_itm <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | (~ mux_tmp_315) | exit_BATCH_LOOP_lpi_2_dfm_st_3
        | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[1])) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2
        | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[0])) | (~(BATCH_LOOP_stage_0_4
        & BATCH_LOOP_stage_v_3)) | CALC_SOFTMAX_LOOP_asn_itm_3)) ) begin
      CALC_SOFTMAX_LOOP_mux_itm <= CALC_SOFTMAX_LOOP_mux_itm_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_cse <= 4'b0000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | or_194_cse | or_dcpl_85 | (~ BATCH_LOOP_and_21_tmp)))
        ) begin
      reg_CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_cse <= CALC_SOFTMAX_LOOP_i_4_0_lpi_2_3_0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm <= 4'b0000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | or_dcpl_91 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])
        | exit_BATCH_LOOP_lpi_2_dfm_1 | (~ BATCH_LOOP_and_21_tmp))) ) begin
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm <= STORE_LOOP_i_4_0_lpi_2_3_0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_7_lpi_2_dfm_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_314 & and_dcpl_114 & STORE_LOOP_and_61_itm_3 &
        (fsm_output[2])) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_7_lpi_2_dfm_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_7_lpi_2_dfm_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_7_lpi_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_7_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_6_lpi_2_dfm_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_314 & and_dcpl_114 & STORE_LOOP_and_60_itm_3 &
        (fsm_output[2])) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_6_lpi_2_dfm_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_6_lpi_2_dfm_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_6_lpi_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_6_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_9_lpi_2_dfm_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_314 & and_dcpl_114 & STORE_LOOP_and_63_itm_3 &
        (fsm_output[2])) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_9_lpi_2_dfm_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_9_lpi_2_dfm_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_9_lpi_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_9_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_5_lpi_2_dfm_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_314 & and_dcpl_114 & STORE_LOOP_and_59_itm_3 &
        (fsm_output[2])) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_5_lpi_2_dfm_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_5_lpi_2_dfm_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_5_lpi_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_5_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_4_lpi_2_dfm_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_314 & and_dcpl_114 & STORE_LOOP_and_58_itm_3 &
        (fsm_output[2])) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_4_lpi_2_dfm_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_4_lpi_2_dfm_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_4_lpi_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_4_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_11_lpi_2_dfm_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_314 & and_dcpl_114 & STORE_LOOP_and_65_itm_3 &
        (fsm_output[2])) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_11_lpi_2_dfm_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_11_lpi_2_dfm_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_11_lpi_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_11_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_3_lpi_2_dfm_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_314 & and_dcpl_114 & STORE_LOOP_and_57_itm_3 &
        (fsm_output[2])) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_3_lpi_2_dfm_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_3_lpi_2_dfm_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_3_lpi_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_3_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_12_lpi_2_dfm_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_314 & and_dcpl_114 & STORE_LOOP_and_66_itm_3 &
        (fsm_output[2])) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_12_lpi_2_dfm_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_12_lpi_2_dfm_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_12_lpi_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_12_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_2_lpi_2_dfm_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_314 & and_dcpl_114 & STORE_LOOP_and_56_itm_3 &
        (fsm_output[2])) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_2_lpi_2_dfm_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_2_lpi_2_dfm_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_2_lpi_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_2_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_13_lpi_2_dfm_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_314 & and_dcpl_114 & STORE_LOOP_and_67_itm_3 &
        (fsm_output[2])) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_13_lpi_2_dfm_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_13_lpi_2_dfm_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_13_lpi_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_13_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_1_lpi_2_dfm_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_314 & and_dcpl_114 & STORE_LOOP_and_55_itm_3 &
        (fsm_output[2])) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_1_lpi_2_dfm_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_1_lpi_2_dfm_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_1_lpi_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_1_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_0_lpi_2_dfm_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_314 & and_dcpl_114 & STORE_LOOP_and_54_itm_3 &
        (fsm_output[2])) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_0_lpi_2_dfm_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_0_lpi_2_dfm_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_0_lpi_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_0_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_15_lpi_2_dfm_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_314 & and_dcpl_114 & STORE_LOOP_and_69_itm_3 &
        (fsm_output[2])) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_15_lpi_2_dfm_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_15_lpi_2_dfm_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_15_lpi_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_15_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_EXP_LOOP_i_4_0_lpi_2_dfm_2_3_0 <= 4'b0000;
      SUM_EXP_LOOP_i_4_0_lpi_2_dfm_2_3_0 <= 4'b0000;
      LOAD_LOOP_i_4_0_lpi_2_dfm_2_3_0 <= 4'b0000;
    end
    else if ( CALC_EXP_LOOP_i_and_cse ) begin
      CALC_EXP_LOOP_i_4_0_lpi_2_dfm_2_3_0 <= CALC_EXP_LOOP_i_4_0_lpi_2_dfm_2_3_0_mx0w0;
      SUM_EXP_LOOP_i_4_0_lpi_2_dfm_2_3_0 <= SUM_EXP_LOOP_i_4_0_lpi_2_dfm_2_3_0_mx0w0;
      LOAD_LOOP_i_4_0_lpi_2_dfm_2_3_0 <= LOAD_LOOP_i_4_0_lpi_2_dfm_2_3_0_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2
          <= 71'b00000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | (~ mux_tmp_314) | or_dcpl_72))
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2
          <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3
          <= 91'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_310 & and_dcpl_169 & STORE_LOOP_and_42_itm_4 &
        (fsm_output[2])) | ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3_mx0c1)
        ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3
          <= MUX_v_91_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2,
          ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_or_1_itm,
          STORE_LOOP_and_193_nl);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_i_4_0_lpi_2_dfm_3_3_0 <= 4'b0000;
      exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3 <= 1'b0;
      exit_STORE_CTRL_LOOP_lpi_2_dfm_3 <= 1'b0;
      STORE_LOOP_i_4_0_lpi_2_dfm_2_3_0 <= 4'b0000;
      lfst_exit_STORE_LOOP_lpi_2_dfm_8_2 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_i_and_2_cse ) begin
      CALC_SOFTMAX_LOOP_i_4_0_lpi_2_dfm_3_3_0 <= MUX_v_4_2_2(CALC_SOFTMAX_LOOP_i_4_0_lpi_2_3_0,
          CALC_SOFTMAX_LOOP_i_4_0_lpi_2_dfm_2_3_0_1, or_tmp_740);
      exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3 <= MUX_s_1_2_2(exit_CALC_SOFTMAX_LOOP_lpi_2,
          STORE_LOOP_mux1h_33_mx0w1, or_tmp_740);
      exit_STORE_CTRL_LOOP_lpi_2_dfm_3 <= MUX_s_1_2_2(exit_STORE_CTRL_LOOP_lpi_2,
          STORE_LOOP_mux1h_34_mx0w1, or_tmp_740);
      STORE_LOOP_i_4_0_lpi_2_dfm_2_3_0 <= MUX_v_4_2_2(STORE_LOOP_i_4_0_lpi_2_3_0,
          STORE_LOOP_i_4_0_lpi_2_dfm_1_3_0_1, or_tmp_740);
      lfst_exit_STORE_LOOP_lpi_2_dfm_8_2 <= MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2,
          lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1, or_tmp_740);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_acc_3_psp_lpi_2_dfm_2 <= 28'b0000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_428 & reg_LOAD_LOOP_and_1_svs_1_cse & (~ exit_BATCH_LOOP_lpi_2_dfm_1)
        & BATCH_LOOP_and_21_tmp & (fsm_output[2])) | BATCH_LOOP_acc_3_psp_lpi_2_dfm_2_mx0c1)
        ) begin
      BATCH_LOOP_acc_3_psp_lpi_2_dfm_2 <= MUX_v_28_2_2(BATCH_LOOP_acc_3_psp_sva_1,
          BATCH_LOOP_acc_3_psp_lpi_2, BATCH_LOOP_acc_3_psp_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_8_lpi_2_dfm_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_314 & and_dcpl_114 & STORE_LOOP_and_62_itm_3 &
        (fsm_output[2])) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_8_lpi_2_dfm_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_8_lpi_2_dfm_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_8_lpi_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_8_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_10_lpi_2_dfm_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_314 & and_dcpl_114 & STORE_LOOP_and_64_itm_3 &
        (fsm_output[2])) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_10_lpi_2_dfm_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_10_lpi_2_dfm_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_10_lpi_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_10_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_14_lpi_2_dfm_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_tmp_314 & and_dcpl_114 & STORE_LOOP_and_68_itm_3 &
        (fsm_output[2])) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_14_lpi_2_dfm_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_14_lpi_2_dfm_2
          <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_14_lpi_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_14_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (mux_480_nl & BATCH_LOOP_stage_0 & (fsm_output[2]))
        | BATCH_LOOP_stage_v_mx0c1) ) begin
      BATCH_LOOP_stage_v <= ~ BATCH_LOOP_stage_v_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2
          <= 91'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((fsm_output[1]) | ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_mx0c1)
        & ((~ ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_mx0c1)
        | ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_and_3_rgt)
        & ((~ ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_and_3_rgt)
        | ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_and_6_rgt)
        ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2
          <= MUX_v_91_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3,
          ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_or_1_itm,
          ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_and_6_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_2 <= 1'b0;
    end
    else if ( core_wen & (BATCH_LOOP_stage_v_2_mx0c0 | (BATCH_LOOP_and_21_tmp & (fsm_output[2])))
        ) begin
      BATCH_LOOP_stage_v_2 <= ~ BATCH_LOOP_stage_v_2_mx0c0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_3 <= 1'b0;
    end
    else if ( core_wen & (BATCH_LOOP_stage_v_3_mx0c0 | (and_dcpl_204 & (fsm_output[2])))
        ) begin
      BATCH_LOOP_stage_v_3 <= ~ BATCH_LOOP_stage_v_3_mx0c0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_asn_itm_3 <= 1'b0;
      STORE_LOOP_asn_51_itm_3 <= 1'b0;
      exit_LOAD_CTRL_LOOP_sva_2 <= 1'b0;
      STORE_LOOP_equal_tmp_2 <= 1'b0;
      exit_BATCH_LOOP_lpi_2_dfm_3 <= 1'b0;
      STORE_LOOP_and_39_itm_2 <= 1'b0;
      STORE_LOOP_or_51_itm_2 <= 1'b0;
      LOAD_LOOP_and_1_svs_3 <= 1'b0;
      STORE_LOOP_and_54_itm_2 <= 1'b0;
      STORE_LOOP_and_55_itm_2 <= 1'b0;
      STORE_LOOP_and_56_itm_2 <= 1'b0;
      STORE_LOOP_and_57_itm_2 <= 1'b0;
      STORE_LOOP_and_58_itm_2 <= 1'b0;
      STORE_LOOP_and_59_itm_2 <= 1'b0;
      STORE_LOOP_and_60_itm_2 <= 1'b0;
      STORE_LOOP_and_61_itm_2 <= 1'b0;
      STORE_LOOP_and_62_itm_2 <= 1'b0;
      STORE_LOOP_and_63_itm_2 <= 1'b0;
      STORE_LOOP_and_64_itm_2 <= 1'b0;
      STORE_LOOP_and_65_itm_2 <= 1'b0;
      STORE_LOOP_and_66_itm_2 <= 1'b0;
      STORE_LOOP_and_67_itm_2 <= 1'b0;
      STORE_LOOP_and_68_itm_2 <= 1'b0;
      STORE_LOOP_and_69_itm_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_2 <= 4'b0000;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_2 <= 4'b0000;
    end
    else if ( CALC_SOFTMAX_LOOP_and_47_cse ) begin
      CALC_SOFTMAX_LOOP_asn_itm_3 <= CALC_SOFTMAX_LOOP_asn_itm_2;
      STORE_LOOP_asn_51_itm_3 <= STORE_LOOP_asn_51_itm_2;
      exit_LOAD_CTRL_LOOP_sva_2 <= exit_LOAD_CTRL_LOOP_sva_1;
      STORE_LOOP_equal_tmp_2 <= STORE_LOOP_equal_tmp_1;
      exit_BATCH_LOOP_lpi_2_dfm_3 <= exit_BATCH_LOOP_lpi_2_dfm_st_2;
      STORE_LOOP_and_39_itm_2 <= STORE_LOOP_and_39_itm_1;
      STORE_LOOP_or_51_itm_2 <= STORE_LOOP_or_51_itm_1;
      LOAD_LOOP_and_1_svs_3 <= LOAD_LOOP_and_1_svs_st_2;
      STORE_LOOP_and_54_itm_2 <= STORE_LOOP_and_54_itm_1;
      STORE_LOOP_and_55_itm_2 <= STORE_LOOP_and_55_itm_1;
      STORE_LOOP_and_56_itm_2 <= STORE_LOOP_and_56_itm_1;
      STORE_LOOP_and_57_itm_2 <= STORE_LOOP_and_57_itm_1;
      STORE_LOOP_and_58_itm_2 <= STORE_LOOP_and_58_itm_1;
      STORE_LOOP_and_59_itm_2 <= STORE_LOOP_and_59_itm_1;
      STORE_LOOP_and_60_itm_2 <= STORE_LOOP_and_60_itm_1;
      STORE_LOOP_and_61_itm_2 <= STORE_LOOP_and_61_itm_1;
      STORE_LOOP_and_62_itm_2 <= STORE_LOOP_and_62_itm_1;
      STORE_LOOP_and_63_itm_2 <= STORE_LOOP_and_63_itm_1;
      STORE_LOOP_and_64_itm_2 <= STORE_LOOP_and_64_itm_1;
      STORE_LOOP_and_65_itm_2 <= STORE_LOOP_and_65_itm_1;
      STORE_LOOP_and_66_itm_2 <= STORE_LOOP_and_66_itm_1;
      STORE_LOOP_and_67_itm_2 <= STORE_LOOP_and_67_itm_1;
      STORE_LOOP_and_68_itm_2 <= STORE_LOOP_and_68_itm_1;
      STORE_LOOP_and_69_itm_2 <= STORE_LOOP_and_69_itm_1;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_2 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_itm_1;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_2 <= STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_4 <= 1'b0;
    end
    else if ( core_wen & (BATCH_LOOP_stage_v_4_mx0c0 | (and_tmp_128 & and_dcpl_201
        & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_v_4 <= ~ BATCH_LOOP_stage_v_4_mx0c0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_and_1_svs_st_4 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0 <= 2'b00;
      STORE_LOOP_asn_51_itm_4 <= 1'b0;
      exit_BATCH_LOOP_lpi_2_dfm_st_4 <= 1'b0;
      LOAD_LOOP_and_1_svs_st_5 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_1_0 <= 2'b00;
      exit_BATCH_LOOP_lpi_2_dfm_st_5 <= 1'b0;
      LOAD_LOOP_and_1_svs_st_6 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_1_0 <= 2'b00;
      exit_BATCH_LOOP_lpi_2_dfm_st_6 <= 1'b0;
      LOAD_LOOP_and_1_svs_st_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_mux_itm_4 <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_asn_itm_7 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_1_0 <= 2'b00;
      exit_BATCH_LOOP_lpi_2_dfm_st_7 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_1_0 <= 2'b00;
      STORE_LOOP_asn_51_itm_8 <= 1'b0;
      exit_BATCH_LOOP_lpi_2_dfm_st_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_18 <= 4'b0000;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1
          <= 71'b00000000000000000000000000000000000000000000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mux_itm_3 <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_asn_itm_6 <= 1'b0;
      STORE_LOOP_asn_51_itm_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_17 <= 4'b0000;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_17 <= 4'b0000;
      exit_BATCH_LOOP_lpi_2_dfm_st_18 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_18_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_18_1_0 <= 2'b00;
      CALC_SOFTMAX_LOOP_asn_itm_18 <= 1'b0;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_sdt_18_0_itm_1
          <= 9'b000000000;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_2_itm_1
          <= 3'b000;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_3_itm_1
          <= 7'b0000000;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_sdt_18_0_1_itm_1
          <= 10'b0000000000;
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_18_12_itm_1
          <= 7'b0000000;
      CALC_SOFTMAX_LOOP_mux_itm_2 <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_asn_itm_5 <= 1'b0;
      STORE_LOOP_asn_51_itm_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_16 <= 4'b0000;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_16 <= 4'b0000;
      exit_BATCH_LOOP_lpi_2_dfm_st_17 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_17_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_17_1_0 <= 2'b00;
      CALC_SOFTMAX_LOOP_asn_itm_17 <= 1'b0;
      CALC_SOFTMAX_LOOP_mux_itm_1 <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_asn_itm_4 <= 1'b0;
      exit_LOAD_CTRL_LOOP_sva_3 <= 1'b0;
      STORE_LOOP_and_39_itm_3 <= 1'b0;
      STORE_LOOP_or_51_itm_3 <= 1'b0;
      STORE_LOOP_asn_51_itm_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_15 <= 4'b0000;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_15 <= 4'b0000;
      exit_BATCH_LOOP_lpi_2_dfm_st_16 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_16_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_16_1_0 <= 2'b00;
      CALC_SOFTMAX_LOOP_asn_itm_16 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_itm_2 <= 4'b0000;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_14 <= 4'b0000;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_14 <= 4'b0000;
      exit_BATCH_LOOP_lpi_2_dfm_st_15 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_15_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_15_1_0 <= 2'b00;
      CALC_SOFTMAX_LOOP_asn_itm_15 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_13 <= 4'b0000;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_13 <= 4'b0000;
      exit_BATCH_LOOP_lpi_2_dfm_st_14 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_14_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_14_1_0 <= 2'b00;
      CALC_SOFTMAX_LOOP_asn_itm_14 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_12 <= 4'b0000;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_12 <= 4'b0000;
      exit_BATCH_LOOP_lpi_2_dfm_st_13 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_13_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_13_1_0 <= 2'b00;
      CALC_SOFTMAX_LOOP_asn_itm_13 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_11 <= 4'b0000;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_11 <= 4'b0000;
      exit_BATCH_LOOP_lpi_2_dfm_st_12 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0 <= 2'b00;
      CALC_SOFTMAX_LOOP_asn_itm_12 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_10 <= 4'b0000;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_10 <= 4'b0000;
      exit_BATCH_LOOP_lpi_2_dfm_st_11 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0 <= 2'b00;
      CALC_SOFTMAX_LOOP_asn_itm_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_9 <= 4'b0000;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_9 <= 4'b0000;
      exit_BATCH_LOOP_lpi_2_dfm_st_10 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0 <= 2'b00;
      CALC_SOFTMAX_LOOP_asn_itm_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_8 <= 4'b0000;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_8 <= 4'b0000;
      exit_BATCH_LOOP_lpi_2_dfm_st_9 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_1_0 <= 2'b00;
      CALC_SOFTMAX_LOOP_asn_itm_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_7 <= 4'b0000;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_7 <= 4'b0000;
      CALC_SOFTMAX_LOOP_asn_itm_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_6 <= 4'b0000;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_6 <= 4'b0000;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_5 <= 4'b0000;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_5 <= 4'b0000;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_4 <= 4'b0000;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_4 <= 4'b0000;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_3 <= 4'b0000;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_3 <= 4'b0000;
    end
    else if ( LOAD_LOOP_and_4_cse ) begin
      LOAD_LOOP_and_1_svs_st_4 <= LOAD_LOOP_and_1_svs_st_3;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0;
      STORE_LOOP_asn_51_itm_4 <= STORE_LOOP_asn_51_itm_3;
      exit_BATCH_LOOP_lpi_2_dfm_st_4 <= exit_BATCH_LOOP_lpi_2_dfm_st_3;
      LOAD_LOOP_and_1_svs_st_5 <= LOAD_LOOP_and_1_svs_st_4;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0;
      exit_BATCH_LOOP_lpi_2_dfm_st_5 <= exit_BATCH_LOOP_lpi_2_dfm_st_4;
      LOAD_LOOP_and_1_svs_st_6 <= LOAD_LOOP_and_1_svs_st_5;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_1_0;
      exit_BATCH_LOOP_lpi_2_dfm_st_6 <= exit_BATCH_LOOP_lpi_2_dfm_st_5;
      LOAD_LOOP_and_1_svs_st_7 <= LOAD_LOOP_and_1_svs_st_6;
      CALC_SOFTMAX_LOOP_mux_itm_4 <= CALC_SOFTMAX_LOOP_mux_itm_3;
      CALC_SOFTMAX_LOOP_asn_itm_7 <= CALC_SOFTMAX_LOOP_asn_itm_6;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_1_0;
      exit_BATCH_LOOP_lpi_2_dfm_st_7 <= exit_BATCH_LOOP_lpi_2_dfm_st_6;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_1_0;
      STORE_LOOP_asn_51_itm_8 <= STORE_LOOP_asn_51_itm_7;
      exit_BATCH_LOOP_lpi_2_dfm_st_8 <= exit_BATCH_LOOP_lpi_2_dfm_st_7;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_18 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_17;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1
          <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
      CALC_SOFTMAX_LOOP_mux_itm_3 <= CALC_SOFTMAX_LOOP_mux_itm_2;
      CALC_SOFTMAX_LOOP_asn_itm_6 <= CALC_SOFTMAX_LOOP_asn_itm_5;
      STORE_LOOP_asn_51_itm_7 <= STORE_LOOP_asn_51_itm_6;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_17 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_16;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_17 <= STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_16;
      exit_BATCH_LOOP_lpi_2_dfm_st_18 <= exit_BATCH_LOOP_lpi_2_dfm_st_17;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_18_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_17_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_18_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_17_1_0;
      CALC_SOFTMAX_LOOP_asn_itm_18 <= CALC_SOFTMAX_LOOP_asn_itm_17;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_sdt_18_0_itm_1
          <= ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[18:10];
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_2_itm_1
          <= MUX_v_3_4_2(3'b011, 3'b100, 3'b101, 3'b110, ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt[11:10]);
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_3_itm_1
          <= MUX_v_7_4_2(7'b1111110, 7'b1000000, 7'b0100110, 7'b0110111, ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt[11:10]);
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_sdt_18_0_1_itm_1
          <= ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[9:0];
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_18_12_itm_1
          <= ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_z_mxwt[18:12];
      CALC_SOFTMAX_LOOP_mux_itm_2 <= CALC_SOFTMAX_LOOP_mux_itm_1;
      CALC_SOFTMAX_LOOP_asn_itm_5 <= CALC_SOFTMAX_LOOP_asn_itm_4;
      STORE_LOOP_asn_51_itm_6 <= STORE_LOOP_asn_51_itm_5;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_16 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_15;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_16 <= STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_15;
      exit_BATCH_LOOP_lpi_2_dfm_st_17 <= exit_BATCH_LOOP_lpi_2_dfm_st_16;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_17_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_16_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_17_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_16_1_0;
      CALC_SOFTMAX_LOOP_asn_itm_17 <= CALC_SOFTMAX_LOOP_asn_itm_16;
      CALC_SOFTMAX_LOOP_mux_itm_1 <= MUX_v_67_2_2(CALC_SOFTMAX_LOOP_mux_itm_mx0w0,
          CALC_SOFTMAX_LOOP_mux_itm, and_992_nl);
      CALC_SOFTMAX_LOOP_asn_itm_4 <= CALC_SOFTMAX_LOOP_asn_itm_3;
      exit_LOAD_CTRL_LOOP_sva_3 <= exit_LOAD_CTRL_LOOP_sva_2;
      STORE_LOOP_and_39_itm_3 <= STORE_LOOP_and_39_itm_2;
      STORE_LOOP_or_51_itm_3 <= STORE_LOOP_or_51_itm_2;
      STORE_LOOP_asn_51_itm_5 <= STORE_LOOP_asn_51_itm_4;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_15 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_14;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_15 <= STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_14;
      exit_BATCH_LOOP_lpi_2_dfm_st_16 <= exit_BATCH_LOOP_lpi_2_dfm_st_15;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_16_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_15_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_16_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_15_1_0;
      CALC_SOFTMAX_LOOP_asn_itm_16 <= CALC_SOFTMAX_LOOP_asn_itm_15;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_itm_2 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_itm_1;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_14 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_13;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_14 <= STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_13;
      exit_BATCH_LOOP_lpi_2_dfm_st_15 <= exit_BATCH_LOOP_lpi_2_dfm_st_14;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_15_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_14_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_15_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_14_1_0;
      CALC_SOFTMAX_LOOP_asn_itm_15 <= CALC_SOFTMAX_LOOP_asn_itm_14;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_13 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_12;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_13 <= STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_12;
      exit_BATCH_LOOP_lpi_2_dfm_st_14 <= exit_BATCH_LOOP_lpi_2_dfm_st_13;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_14_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_13_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_14_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_13_1_0;
      CALC_SOFTMAX_LOOP_asn_itm_14 <= CALC_SOFTMAX_LOOP_asn_itm_13;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_12 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_11;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_12 <= STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_11;
      exit_BATCH_LOOP_lpi_2_dfm_st_13 <= exit_BATCH_LOOP_lpi_2_dfm_st_12;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_13_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_13_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0;
      CALC_SOFTMAX_LOOP_asn_itm_13 <= CALC_SOFTMAX_LOOP_asn_itm_12;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_11 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_10;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_11 <= STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_10;
      exit_BATCH_LOOP_lpi_2_dfm_st_12 <= exit_BATCH_LOOP_lpi_2_dfm_st_11;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0;
      CALC_SOFTMAX_LOOP_asn_itm_12 <= CALC_SOFTMAX_LOOP_asn_itm_11;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_10 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_9;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_10 <= STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_9;
      exit_BATCH_LOOP_lpi_2_dfm_st_11 <= exit_BATCH_LOOP_lpi_2_dfm_st_10;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0;
      CALC_SOFTMAX_LOOP_asn_itm_11 <= CALC_SOFTMAX_LOOP_asn_itm_10;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_9 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_8;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_9 <= STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_8;
      exit_BATCH_LOOP_lpi_2_dfm_st_10 <= exit_BATCH_LOOP_lpi_2_dfm_st_9;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_1_0;
      CALC_SOFTMAX_LOOP_asn_itm_10 <= CALC_SOFTMAX_LOOP_asn_itm_9;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_8 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_7;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_8 <= STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_7;
      exit_BATCH_LOOP_lpi_2_dfm_st_9 <= exit_BATCH_LOOP_lpi_2_dfm_st_8;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_1_0;
      CALC_SOFTMAX_LOOP_asn_itm_9 <= CALC_SOFTMAX_LOOP_asn_itm_8;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_7 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_6;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_7 <= STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_6;
      CALC_SOFTMAX_LOOP_asn_itm_8 <= CALC_SOFTMAX_LOOP_asn_itm_7;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_6 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_5;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_6 <= STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_5;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_5 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_4;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_5 <= STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_4;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_4 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_3;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_4 <= STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_3;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_3 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_itm_2;
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_3 <= STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_2;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_5 <= 1'b0;
    end
    else if ( core_wen & (BATCH_LOOP_stage_v_5_mx0c0 | (mux_tmp_314 & and_dcpl_114
        & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_v_5 <= ~ BATCH_LOOP_stage_v_5_mx0c0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_6 <= 1'b0;
    end
    else if ( core_wen & (BATCH_LOOP_stage_v_6_mx0c0 | (mux_tmp_313 & and_416_cse
        & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_v_6 <= ~ BATCH_LOOP_stage_v_6_mx0c0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2
          <= 71'b00000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & mux_tmp_313 ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2
          <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_7 <= 1'b0;
    end
    else if ( core_wen & (BATCH_LOOP_stage_v_7_mx0c0 | (mux_tmp_312 & and_439_cse
        & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_v_7 <= ~ BATCH_LOOP_stage_v_7_mx0c0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3
          <= 71'b00000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & mux_tmp_312 ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_3
          <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_2;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_8 <= 1'b0;
    end
    else if ( core_wen & (BATCH_LOOP_stage_v_8_mx0c0 | (mux_tmp_311 & and_dcpl_57
        & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_v_8 <= ~ BATCH_LOOP_stage_v_8_mx0c0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_1
          <= 11'b00000000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm_1
          <= 10'b0000000000;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_7_2 <= 6'b000000;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_1_0 <= 2'b00;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_4
          <= 1'b0;
      LOAD_LOOP_and_1_svs_8 <= 1'b0;
      STORE_LOOP_and_42_itm_4 <= 1'b0;
    end
    else if ( ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse
        ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_1
          <= MUX_v_11_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm_mx0w0,
          ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_acc_itm,
          and_dcpl_291);
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm_1
          <= MUX_v_10_2_2((ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[9:0]),
          ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm,
          and_dcpl_291);
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_7_2 <= MUX_v_6_2_2(ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1,
          ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_7_2, and_dcpl_291);
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_1_0 <= MUX_v_2_2_2((~
          ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_slc_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_1_0_itm_1),
          ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_conc_itm_1_0, and_dcpl_291);
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_4
          <= ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_3;
      LOAD_LOOP_and_1_svs_8 <= LOAD_LOOP_and_1_svs_7;
      STORE_LOOP_and_42_itm_4 <= STORE_LOOP_and_42_itm_3;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_9 <= 1'b0;
    end
    else if ( core_wen & (BATCH_LOOP_stage_v_9_mx0c0 | (mux_tmp_310 & and_dcpl_169
        & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_v_9 <= ~ BATCH_LOOP_stage_v_9_mx0c0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_10 <= 1'b0;
    end
    else if ( core_wen & (BATCH_LOOP_stage_v_10_mx0c0 | (mux_tmp_309 & and_572_cse
        & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_v_10 <= ~ BATCH_LOOP_stage_v_10_mx0c0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_11 <= 1'b0;
    end
    else if ( core_wen & (BATCH_LOOP_stage_v_11_mx0c0 | (mux_tmp_308 & and_591_cse
        & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_v_11 <= ~ BATCH_LOOP_stage_v_11_mx0c0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_12 <= 1'b0;
    end
    else if ( core_wen & (BATCH_LOOP_stage_v_12_mx0c0 | (mux_tmp_307 & and_609_cse
        & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_v_12 <= ~ BATCH_LOOP_stage_v_12_mx0c0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_18 <= 4'b0000;
    end
    else if ( core_wen & mux_tmp_298 ) begin
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_18 <= STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_17;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      batch_sva <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~ (fsm_output[2])) ) begin
      batch_sva <= conf_info_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | or_tmp_817) ) begin
      BATCH_LOOP_stage_0 <= ~ or_tmp_817;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_b_4_0_sva_3_0 <= 4'b0000;
    end
    else if ( core_wen & ((fsm_output[1]) | (mux_826_nl & (STORE_LOOP_acc_1_tmp[4])
        & (~ (BATCH_LOOP_acc_2_tmp[4])) & BATCH_LOOP_and_22_tmp & (fsm_output[2])))
        ) begin
      BATCH_LOOP_b_4_0_sva_3_0 <= MUX_v_4_2_2(4'b0000, (BATCH_LOOP_acc_2_tmp[3:0]),
          BATCH_LOOP_b_not_1_nl);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_1 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | or_tmp_817 | (mux_530_cse & BATCH_LOOP_and_22_tmp
        & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_0_1 <= (BATCH_LOOP_stage_0 & (~ or_tmp_817)) | (fsm_output[1]);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_3 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | ((and_dcpl_204 | BATCH_LOOP_and_21_tmp)
        & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_0_3 <= BATCH_LOOP_stage_0_2 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_4 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (or_622_cse & mux_844_nl & (fsm_output[2])))
        ) begin
      BATCH_LOOP_stage_0_4 <= BATCH_LOOP_stage_0_3 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_5 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (or_622_cse & mux_861_nl & (fsm_output[2])))
        ) begin
      BATCH_LOOP_stage_0_5 <= BATCH_LOOP_stage_0_4 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_6 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (or_622_cse & mux_877_nl & (fsm_output[2])))
        ) begin
      BATCH_LOOP_stage_0_6 <= BATCH_LOOP_stage_0_5 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_7 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (or_622_cse & mux_892_nl & (fsm_output[2])))
        ) begin
      BATCH_LOOP_stage_0_7 <= BATCH_LOOP_stage_0_6 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_8 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (or_622_cse & mux_906_nl & (fsm_output[2])))
        ) begin
      BATCH_LOOP_stage_0_8 <= BATCH_LOOP_stage_0_7 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_9 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (or_622_cse & mux_919_nl & (fsm_output[2])))
        ) begin
      BATCH_LOOP_stage_0_9 <= BATCH_LOOP_stage_0_8 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_10 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (or_622_cse & mux_931_nl & (fsm_output[2])))
        ) begin
      BATCH_LOOP_stage_0_10 <= BATCH_LOOP_stage_0_9 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_11 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (or_622_cse & mux_942_nl & (fsm_output[2])))
        ) begin
      BATCH_LOOP_stage_0_11 <= BATCH_LOOP_stage_0_10 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_12 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (mux_952_nl & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_0_12 <= BATCH_LOOP_stage_0_11 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_13 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (mux_961_nl & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_0_13 <= BATCH_LOOP_stage_0_12 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_asn_itm_2 <= 1'b0;
      exit_BATCH_LOOP_lpi_2_dfm_st_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_1_0 <= 2'b00;
      LOAD_LOOP_and_1_svs_st_2 <= 1'b0;
      STORE_LOOP_asn_51_itm_2 <= 1'b0;
      exit_LOAD_CTRL_LOOP_sva_1 <= 1'b0;
      STORE_LOOP_equal_tmp_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_itm_1 <= 4'b0000;
      STORE_LOOP_and_39_itm_1 <= 1'b0;
      STORE_LOOP_or_51_itm_1 <= 1'b0;
      STORE_LOOP_and_54_itm_1 <= 1'b0;
      STORE_LOOP_and_55_itm_1 <= 1'b0;
      STORE_LOOP_and_56_itm_1 <= 1'b0;
      STORE_LOOP_and_57_itm_1 <= 1'b0;
      STORE_LOOP_and_58_itm_1 <= 1'b0;
      STORE_LOOP_and_59_itm_1 <= 1'b0;
      STORE_LOOP_and_60_itm_1 <= 1'b0;
      STORE_LOOP_and_61_itm_1 <= 1'b0;
      STORE_LOOP_and_62_itm_1 <= 1'b0;
      STORE_LOOP_and_63_itm_1 <= 1'b0;
      STORE_LOOP_and_64_itm_1 <= 1'b0;
      STORE_LOOP_and_65_itm_1 <= 1'b0;
      STORE_LOOP_and_66_itm_1 <= 1'b0;
      STORE_LOOP_and_67_itm_1 <= 1'b0;
      STORE_LOOP_and_68_itm_1 <= 1'b0;
      STORE_LOOP_and_69_itm_1 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_65_cse ) begin
      CALC_SOFTMAX_LOOP_asn_itm_2 <= CALC_SOFTMAX_LOOP_asn_itm_1;
      exit_BATCH_LOOP_lpi_2_dfm_st_2 <= exit_BATCH_LOOP_lpi_2_dfm_1;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0;
      LOAD_LOOP_and_1_svs_st_2 <= reg_LOAD_LOOP_and_1_svs_1_cse;
      STORE_LOOP_asn_51_itm_2 <= STORE_LOOP_asn_51_itm_1;
      exit_LOAD_CTRL_LOOP_sva_1 <= dma_read_ctrl_rsci_irdy_mxwt;
      STORE_LOOP_equal_tmp_1 <= STORE_LOOP_equal_tmp_mx0w0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_itm_1 <= MUX_v_4_2_2(CALC_SOFTMAX_LOOP_i_4_0_lpi_2_3_0,
          reg_CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_4_0_3_0_1_cse, and_997_nl);
      STORE_LOOP_and_39_itm_1 <= STORE_LOOP_and_39_itm_mx0w0;
      STORE_LOOP_or_51_itm_1 <= STORE_LOOP_or_51_itm_mx0w0;
      STORE_LOOP_and_54_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_0_sva_1
          & (~ (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[3])) & STORE_LOOP_equal_tmp_mx0w0 &
          (~ exit_BATCH_LOOP_lpi_2_dfm_1);
      STORE_LOOP_and_55_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_1_sva_1
          & (~ (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[3])) & STORE_LOOP_equal_tmp_mx0w0 &
          (~ exit_BATCH_LOOP_lpi_2_dfm_1);
      STORE_LOOP_and_56_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_2_sva_1
          & (~ (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[3])) & STORE_LOOP_equal_tmp_mx0w0 &
          (~ exit_BATCH_LOOP_lpi_2_dfm_1);
      STORE_LOOP_and_57_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_3_sva_1
          & (~ (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[3])) & STORE_LOOP_equal_tmp_mx0w0 &
          (~ exit_BATCH_LOOP_lpi_2_dfm_1);
      STORE_LOOP_and_58_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_4_sva_1
          & (~ (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[3])) & STORE_LOOP_equal_tmp_mx0w0 &
          (~ exit_BATCH_LOOP_lpi_2_dfm_1);
      STORE_LOOP_and_59_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_5_sva_1
          & (~ (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[3])) & STORE_LOOP_equal_tmp_mx0w0 &
          (~ exit_BATCH_LOOP_lpi_2_dfm_1);
      STORE_LOOP_and_60_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_6_sva_1
          & (~ (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[3])) & STORE_LOOP_equal_tmp_mx0w0 &
          (~ exit_BATCH_LOOP_lpi_2_dfm_1);
      STORE_LOOP_and_61_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_7_sva_1
          & (~ (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[3])) & STORE_LOOP_equal_tmp_mx0w0 &
          (~ exit_BATCH_LOOP_lpi_2_dfm_1);
      STORE_LOOP_and_62_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_0_sva_1
          & (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[3]) & STORE_LOOP_equal_tmp_mx0w0 & (~
          exit_BATCH_LOOP_lpi_2_dfm_1);
      STORE_LOOP_and_63_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_1_sva_1
          & (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[3]) & STORE_LOOP_equal_tmp_mx0w0 & (~
          exit_BATCH_LOOP_lpi_2_dfm_1);
      STORE_LOOP_and_64_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_2_sva_1
          & (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[3]) & STORE_LOOP_equal_tmp_mx0w0 & (~
          exit_BATCH_LOOP_lpi_2_dfm_1);
      STORE_LOOP_and_65_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_3_sva_1
          & (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[3]) & STORE_LOOP_equal_tmp_mx0w0 & (~
          exit_BATCH_LOOP_lpi_2_dfm_1);
      STORE_LOOP_and_66_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_4_sva_1
          & (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[3]) & STORE_LOOP_equal_tmp_mx0w0 & (~
          exit_BATCH_LOOP_lpi_2_dfm_1);
      STORE_LOOP_and_67_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_5_sva_1
          & (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[3]) & STORE_LOOP_equal_tmp_mx0w0 & (~
          exit_BATCH_LOOP_lpi_2_dfm_1);
      STORE_LOOP_and_68_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_6_sva_1
          & (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[3]) & STORE_LOOP_equal_tmp_mx0w0 & (~
          exit_BATCH_LOOP_lpi_2_dfm_1);
      STORE_LOOP_and_69_itm_1 <= ac_math_ac_shift_left_21_1_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_and_stg_2_7_sva_1
          & (CALC_EXP_LOOP_i_4_0_lpi_2_3_0[3]) & STORE_LOOP_equal_tmp_mx0w0 & (~
          exit_BATCH_LOOP_lpi_2_dfm_1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_and_1_svs_st_3 <= 1'b0;
    end
    else if ( core_wen & ((~ BATCH_LOOP_stage_v_3) | ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_cmp_bawt
        | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[0]) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2
        | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[1])) | exit_BATCH_LOOP_lpi_2_dfm_st_3)
        & and_tmp_41 ) begin
      LOAD_LOOP_and_1_svs_st_3 <= LOAD_LOOP_and_1_svs_st_2;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_3
          <= 1'b0;
      LOAD_LOOP_and_1_svs_7 <= 1'b0;
      STORE_LOOP_and_42_itm_3 <= 1'b0;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1 <= 6'b000000;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_slc_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_1_0_itm_1
          <= 2'b00;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1
          <= 10'b0000000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1
          <= 8'b00000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_69_57_9_0_itm_1
          <= 10'b0000000000;
    end
    else if ( ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_and_6_cse )
        begin
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_3
          <= ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_2;
      LOAD_LOOP_and_1_svs_7 <= LOAD_LOOP_and_1_svs_6;
      STORE_LOOP_and_42_itm_3 <= STORE_LOOP_and_42_itm_2;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1 <= MUX_v_6_2_2(ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0,
          ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_acc_itm, and_dcpl_418);
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_slc_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_1_0_itm_1
          <= MUX_v_2_2_2((ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_sva_1[1:0]),
          ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_qif_slc_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_1_0_itm,
          and_dcpl_418);
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1
          <= MUX_v_10_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_mx0w0,
          ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm,
          and_dcpl_418);
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1
          <= MUX_v_8_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_mx0w0,
          ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm,
          and_dcpl_418);
      ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_69_57_9_0_itm_1
          <= MUX_v_10_2_2((operator_71_0_false_AC_TRN_AC_WRAP_lshift_itm[66:57]),
          ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_normalized_fixed_69_57_9_0_itm,
          and_dcpl_418);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2
          <= 71'b00000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_5_cse
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2
          <= MUX_v_71_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2_mx0w0,
          or_tmp_680);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_2
          <= 1'b0;
      LOAD_LOOP_and_1_svs_6 <= 1'b0;
      STORE_LOOP_and_42_itm_2 <= 1'b0;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_sva_1 <= 7'b0000000;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_2_69_0
          <= 70'b0000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_and_7_cse )
        begin
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_2
          <= ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_1;
      LOAD_LOOP_and_1_svs_6 <= LOAD_LOOP_and_1_svs_5;
      STORE_LOOP_and_42_itm_2 <= STORE_LOOP_and_42_itm_1;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_leading_1_6_0_sva_1 <= libraries_leading_sign_71_0_1bc993dc735dc189e3e2a7ebf4857c14bb7e_1;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_2_69_0
          <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1[69:0];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1
          <= 71'b00000000000000000000000000000000000000000000000000000000000000000000000;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_1
          <= 1'b0;
      LOAD_LOOP_and_1_svs_5 <= 1'b0;
      STORE_LOOP_and_42_itm_1 <= 1'b0;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_7_cse
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1
          <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
      ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_1
          <= MUX_s_1_2_2(ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0,
          ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_71_51_false_AC_TRN_AC_WRAP_expret_nor_itm,
          and_987_nl);
      LOAD_LOOP_and_1_svs_5 <= LOAD_LOOP_and_1_svs_4;
      STORE_LOOP_and_42_itm_1 <= STORE_LOOP_and_40_cse_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_LOOP_equal_tmp_3_1 <= 1'b0;
      exit_BATCH_LOOP_lpi_2_dfm_4 <= 1'b0;
      LOAD_LOOP_and_1_svs_4 <= 1'b0;
      STORE_LOOP_and_69_itm_3 <= 1'b0;
      STORE_LOOP_and_68_itm_3 <= 1'b0;
      STORE_LOOP_and_67_itm_3 <= 1'b0;
      STORE_LOOP_and_66_itm_3 <= 1'b0;
      STORE_LOOP_and_65_itm_3 <= 1'b0;
      STORE_LOOP_and_64_itm_3 <= 1'b0;
      STORE_LOOP_and_63_itm_3 <= 1'b0;
      STORE_LOOP_and_62_itm_3 <= 1'b0;
      STORE_LOOP_and_61_itm_3 <= 1'b0;
      STORE_LOOP_and_60_itm_3 <= 1'b0;
      STORE_LOOP_and_59_itm_3 <= 1'b0;
      STORE_LOOP_and_58_itm_3 <= 1'b0;
      STORE_LOOP_and_57_itm_3 <= 1'b0;
      STORE_LOOP_and_56_itm_3 <= 1'b0;
      STORE_LOOP_and_55_itm_3 <= 1'b0;
      STORE_LOOP_and_54_itm_3 <= 1'b0;
    end
    else if ( STORE_LOOP_and_137_cse ) begin
      STORE_LOOP_equal_tmp_3_1 <= STORE_LOOP_equal_tmp_2;
      exit_BATCH_LOOP_lpi_2_dfm_4 <= exit_BATCH_LOOP_lpi_2_dfm_3;
      LOAD_LOOP_and_1_svs_4 <= LOAD_LOOP_and_1_svs_3;
      STORE_LOOP_and_69_itm_3 <= STORE_LOOP_and_69_itm_2;
      STORE_LOOP_and_68_itm_3 <= STORE_LOOP_and_68_itm_2;
      STORE_LOOP_and_67_itm_3 <= STORE_LOOP_and_67_itm_2;
      STORE_LOOP_and_66_itm_3 <= STORE_LOOP_and_66_itm_2;
      STORE_LOOP_and_65_itm_3 <= STORE_LOOP_and_65_itm_2;
      STORE_LOOP_and_64_itm_3 <= STORE_LOOP_and_64_itm_2;
      STORE_LOOP_and_63_itm_3 <= STORE_LOOP_and_63_itm_2;
      STORE_LOOP_and_62_itm_3 <= STORE_LOOP_and_62_itm_2;
      STORE_LOOP_and_61_itm_3 <= STORE_LOOP_and_61_itm_2;
      STORE_LOOP_and_60_itm_3 <= STORE_LOOP_and_60_itm_2;
      STORE_LOOP_and_59_itm_3 <= STORE_LOOP_and_59_itm_2;
      STORE_LOOP_and_58_itm_3 <= STORE_LOOP_and_58_itm_2;
      STORE_LOOP_and_57_itm_3 <= STORE_LOOP_and_57_itm_2;
      STORE_LOOP_and_56_itm_3 <= STORE_LOOP_and_56_itm_2;
      STORE_LOOP_and_55_itm_3 <= STORE_LOOP_and_55_itm_2;
      STORE_LOOP_and_54_itm_3 <= STORE_LOOP_and_54_itm_2;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_15_lpi_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_5_cse
        & ((~ or_tmp_680) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_42_rgt)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_15_lpi_2
          <= MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_15_lpi_2_dfm_2,
          operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_42_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_13_lpi_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_5_cse
        & ((~ or_tmp_680) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_45_rgt)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_13_lpi_2
          <= MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_13_lpi_2_dfm_2,
          operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_45_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_12_lpi_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_5_cse
        & ((~ or_tmp_680) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_48_rgt)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_12_lpi_2
          <= MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_12_lpi_2_dfm_2,
          operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_48_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_11_lpi_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_5_cse
        & ((~ or_tmp_680) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_51_rgt)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_11_lpi_2
          <= MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_11_lpi_2_dfm_2,
          operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_51_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_9_lpi_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_5_cse
        & ((~ or_tmp_680) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_54_rgt)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_9_lpi_2
          <= MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_9_lpi_2_dfm_2,
          operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_54_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_7_lpi_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_5_cse
        & ((~ or_tmp_680) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_57_rgt)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_7_lpi_2
          <= MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_7_lpi_2_dfm_2,
          operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_57_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_6_lpi_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_5_cse
        & ((~ or_tmp_680) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_60_rgt)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_6_lpi_2
          <= MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_6_lpi_2_dfm_2,
          operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_60_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_5_lpi_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_5_cse
        & ((~ or_tmp_680) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_63_rgt)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_5_lpi_2
          <= MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_5_lpi_2_dfm_2,
          operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_63_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_4_lpi_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_5_cse
        & ((~ or_tmp_680) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_66_rgt)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_4_lpi_2
          <= MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_4_lpi_2_dfm_2,
          operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_66_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_3_lpi_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_5_cse
        & ((~ or_tmp_680) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_69_rgt)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_3_lpi_2
          <= MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_3_lpi_2_dfm_2,
          operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_69_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_2_lpi_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_5_cse
        & ((~ or_tmp_680) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_72_rgt)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_2_lpi_2
          <= MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_2_lpi_2_dfm_2,
          operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_72_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_1_lpi_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_5_cse
        & ((~ or_tmp_680) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_75_rgt)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_1_lpi_2
          <= MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_1_lpi_2_dfm_2,
          operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_75_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_0_lpi_2
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_5_cse
        & ((~ or_tmp_680) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_78_rgt)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_0_lpi_2
          <= MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_0_lpi_2_dfm_2,
          operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_16U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_and_78_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_1 <= 4'b0000;
    end
    else if ( core_wen & ((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2 & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0==2'b00)
        & and_dcpl_43) | and_1001_rgt) ) begin
      STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm_1 <= MUX_v_4_2_2(STORE_LOOP_i_4_0_lpi_2_3_0,
          STORE_LOOP_i_slc_STORE_LOOP_i_4_0_3_0_itm, and_1001_rgt);
    end
  end
  assign nor_194_nl = ~(or_tmp_242 | (~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_20_1_0==2'b11)
      & or_tmp_454)));
  assign mux_759_nl = MUX_s_1_2_2(or_tmp_454, nor_194_nl, and_dcpl_332);
  assign nor_301_nl = ~(BATCH_LOOP_and_21_tmp | BATCH_LOOP_and_22_tmp);
  assign BATCH_LOOP_mux_25_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_1, BATCH_LOOP_stage_0_2,
      nor_301_nl);
  assign nand_65_nl = ~(BATCH_LOOP_stage_v_12 & BATCH_LOOP_stage_0_13 & and_617_cse);
  assign nand_66_nl = ~(BATCH_LOOP_stage_0_14 & mux_949_cse);
  assign mux_728_nl = MUX_s_1_2_2(nand_65_nl, nand_66_nl, BATCH_LOOP_stage_v_13);
  assign BATCH_LOOP_mux_27_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_13, BATCH_LOOP_stage_0_14,
      mux_728_nl);
  assign nand_62_nl = ~(BATCH_LOOP_stage_v_13 & BATCH_LOOP_stage_0_14 & and_617_cse);
  assign nand_63_nl = ~(BATCH_LOOP_stage_0_15 & mux_948_cse);
  assign mux_735_nl = MUX_s_1_2_2(nand_62_nl, nand_63_nl, BATCH_LOOP_stage_v_14);
  assign BATCH_LOOP_mux_29_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_14, BATCH_LOOP_stage_0_15,
      mux_735_nl);
  assign nand_59_nl = ~(BATCH_LOOP_stage_v_14 & BATCH_LOOP_stage_0_15 & and_617_cse);
  assign nand_60_nl = ~(BATCH_LOOP_stage_0_16 & mux_947_cse);
  assign mux_741_nl = MUX_s_1_2_2(nand_59_nl, nand_60_nl, BATCH_LOOP_stage_v_15);
  assign BATCH_LOOP_mux_31_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_15, BATCH_LOOP_stage_0_16,
      mux_741_nl);
  assign nand_56_nl = ~(BATCH_LOOP_stage_v_15 & BATCH_LOOP_stage_0_16 & and_617_cse);
  assign nand_57_nl = ~(BATCH_LOOP_stage_0_17 & mux_946_cse);
  assign mux_746_nl = MUX_s_1_2_2(nand_56_nl, nand_57_nl, BATCH_LOOP_stage_v_16);
  assign BATCH_LOOP_mux_33_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_16, BATCH_LOOP_stage_0_17,
      mux_746_nl);
  assign and_704_nl = BATCH_LOOP_stage_0_18 & mux_tmp_732;
  assign mux_753_nl = MUX_s_1_2_2(and_72_cse, and_704_nl, BATCH_LOOP_stage_v_17);
  assign mux_748_nl = MUX_s_1_2_2(and_tmp_12, nor_196_cse, BATCH_LOOP_stage_v_18);
  assign mux_749_nl = MUX_s_1_2_2((~ or_tmp_446), mux_748_nl, BATCH_LOOP_stage_0_19);
  assign mux_750_nl = MUX_s_1_2_2(mux_749_nl, mux_tmp_732, BATCH_LOOP_stage_0_21);
  assign mux_751_nl = MUX_s_1_2_2((~ or_tmp_446), mux_750_nl, BATCH_LOOP_stage_0_20);
  assign and_701_nl = BATCH_LOOP_stage_0_18 & mux_751_nl;
  assign mux_752_nl = MUX_s_1_2_2(and_72_cse, and_701_nl, BATCH_LOOP_stage_v_17);
  assign and_703_nl = or_624_cse & mux_752_nl;
  assign mux_754_nl = MUX_s_1_2_2(mux_753_nl, and_703_nl, BATCH_LOOP_stage_old_v_19);
  assign BATCH_LOOP_mux_35_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_18, BATCH_LOOP_stage_0_17,
      mux_754_nl);
  assign mux_757_nl = MUX_s_1_2_2(and_tmp_362, and_tmp_360, BATCH_LOOP_stage_v_18);
  assign nor_195_nl = ~((~ BATCH_LOOP_stage_0_19) | BATCH_LOOP_stage_old_v_20 | (~
      or_622_cse));
  assign mux_755_nl = MUX_s_1_2_2(nor_195_nl, and_tmp_360, BATCH_LOOP_stage_0_21);
  assign and_711_nl = BATCH_LOOP_stage_0_20 & mux_755_nl;
  assign mux_756_nl = MUX_s_1_2_2(and_tmp_362, and_711_nl, BATCH_LOOP_stage_v_18);
  assign and_713_nl = or_624_cse & mux_756_nl;
  assign mux_758_nl = MUX_s_1_2_2(mux_757_nl, and_713_nl, BATCH_LOOP_stage_old_v_19);
  assign BATCH_LOOP_mux_37_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_19, BATCH_LOOP_stage_0_18,
      mux_758_nl);
  assign nand_50_nl = ~(BATCH_LOOP_stage_v_18 & BATCH_LOOP_stage_0_19 & and_tmp_12);
  assign mux_962_nl = MUX_s_1_2_2(nor_196_cse, and_tmp_12, BATCH_LOOP_stage_0_21);
  assign nand_51_nl = ~(BATCH_LOOP_stage_0_20 & or_624_cse & mux_962_nl);
  assign mux_963_nl = MUX_s_1_2_2(nand_50_nl, nand_51_nl, BATCH_LOOP_stage_old_v_19);
  assign BATCH_LOOP_mux_39_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_19, BATCH_LOOP_stage_0_20,
      mux_963_nl);
  assign nand_48_nl = ~(BATCH_LOOP_stage_old_v_19 & BATCH_LOOP_stage_0_20 & or_624_cse
      & or_622_cse);
  assign nand_49_nl = ~(BATCH_LOOP_stage_0_21 & or_9_cse & or_622_cse);
  assign mux_964_nl = MUX_s_1_2_2(nand_48_nl, nand_49_nl, BATCH_LOOP_stage_old_v_20);
  assign BATCH_LOOP_mux_41_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_20, BATCH_LOOP_stage_0_21,
      mux_964_nl);
  assign and_1747_nl = (~(or_624_cse & BATCH_LOOP_stage_0_20)) & mux_tmp_402;
  assign mux_966_nl = MUX_s_1_2_2(mux_tmp_402, and_1747_nl, BATCH_LOOP_stage_old_v_19);
  assign or_1067_nl = (STORE_LOOP_mux_55_tmp!=2'b10) | mux_338_itm;
  assign mux_339_nl = MUX_s_1_2_2(or_1067_nl, or_29_cse, or_50_cse);
  assign nl_CALC_SOFTMAX_LOOP_i_4_0_sva_1_1  = conv_u2u_4_5(CALC_SOFTMAX_LOOP_i_4_0_lpi_2_3_0_mx1)
      + 5'b00001;
  assign STORE_LOOP_and_193_nl = LOAD_LOOP_and_1_svs_8 & (~ ac_math_ac_reciprocal_pwl_AC_TRN_71_51_false_AC_TRN_AC_WRAP_91_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3_mx0c1);
  assign mux_478_nl = MUX_s_1_2_2(or_tmp_271, or_46_cse, or_tmp_291);
  assign nor_146_nl = ~(reg_LOAD_LOOP_and_1_svs_1_cse | (~ nand_tmp_21));
  assign or_387_nl = dma_write_ctrl_rsci_irdy_mxwt | nand_tmp_21;
  assign mux_466_nl = MUX_s_1_2_2(or_387_nl, nand_tmp_21, CALC_SOFTMAX_LOOP_asn_19_itm_1);
  assign or_388_nl = exit_STORE_CTRL_LOOP_lpi_2 | mux_466_nl;
  assign mux_467_nl = MUX_s_1_2_2(nand_tmp_21, or_388_nl, or_204_cse);
  assign mux_468_nl = MUX_s_1_2_2(mux_467_nl, nand_tmp_21, or_194_cse);
  assign mux_469_nl = MUX_s_1_2_2(nor_146_nl, mux_468_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[0]);
  assign mux_470_nl = MUX_s_1_2_2(nand_tmp_21, mux_469_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]);
  assign mux_472_nl = MUX_s_1_2_2(mux_470_nl, nand_24_cse, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_473_nl = MUX_s_1_2_2(mux_472_nl, mux_tmp_449, BATCH_LOOP_if_acc_itm_32_1);
  assign mux_465_nl = MUX_s_1_2_2((~ mux_tmp_449), BATCH_LOOP_if_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_474_nl = MUX_s_1_2_2((~ mux_473_nl), mux_465_nl, STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign mux_475_nl = MUX_s_1_2_2(mux_474_nl, mux_499_cse, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_456_nl = MUX_s_1_2_2(or_tmp_271, or_46_cse, or_tmp_16);
  assign mux_476_nl = MUX_s_1_2_2(mux_475_nl, mux_456_nl, or_394_cse);
  assign mux_444_nl = MUX_s_1_2_2(or_392_cse, BATCH_LOOP_if_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_477_nl = MUX_s_1_2_2(mux_476_nl, mux_444_nl, or_50_cse);
  assign mux_479_nl = MUX_s_1_2_2(mux_478_nl, mux_477_nl, and_1761_cse);
  assign mux_480_nl = MUX_s_1_2_2((~ BATCH_LOOP_stage_v), mux_479_nl, BATCH_LOOP_and_22_tmp);
  assign and_992_nl = (CALC_SOFTMAX_LOOP_asn_itm_3 | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[0]))
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2 | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[1]))
      | exit_BATCH_LOOP_lpi_2_dfm_st_3) & and_tmp_41;
  assign BATCH_LOOP_b_not_1_nl = ~ (fsm_output[1]);
  assign mux_819_nl = MUX_s_1_2_2(mux_tmp_801, mux_tmp_799, dma_write_ctrl_rsci_irdy_mxwt);
  assign mux_820_nl = MUX_s_1_2_2(mux_819_nl, mux_tmp_801, CALC_SOFTMAX_LOOP_asn_19_itm_1);
  assign mux_821_nl = MUX_s_1_2_2(mux_820_nl, mux_tmp_799, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_822_nl = MUX_s_1_2_2(mux_tmp_801, mux_821_nl, or_204_cse);
  assign mux_824_nl = MUX_s_1_2_2(mux_822_nl, mux_tmp_801, or_194_cse);
  assign or_54_nl = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2) | exitL_exit_STORE_LOOP_sva;
  assign mux_825_nl = MUX_s_1_2_2(mux_824_nl, or_54_nl, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign nor_309_nl = ~((STORE_LOOP_mux_55_tmp!=2'b00) | mux_825_nl);
  assign nor_310_nl = ~((lfst_exit_STORE_LOOP_lpi_2_1_0[0]) | (~ lfst_exit_STORE_LOOP_lpi_2_2)
      | (lfst_exit_STORE_LOOP_lpi_2_1_0[1]) | exitL_exit_STORE_LOOP_sva);
  assign mux_826_nl = MUX_s_1_2_2(nor_309_nl, nor_310_nl, or_50_cse);
  assign and_746_nl = and_dcpl_197 & and_tmp_64;
  assign mux_844_nl = MUX_s_1_2_2(and_746_nl, and_745_cse, BATCH_LOOP_stage_v_3);
  assign and_766_nl = or_623_cse & BATCH_LOOP_stage_v_3 & BATCH_LOOP_stage_0_4 &
      and_tmp_64;
  assign mux_861_nl = MUX_s_1_2_2(and_766_nl, and_391_cse, BATCH_LOOP_stage_v_4);
  assign and_785_nl = and_dcpl_114 & and_tmp_64;
  assign mux_877_nl = MUX_s_1_2_2(and_785_nl, and_390_cse, BATCH_LOOP_stage_v_5);
  assign and_803_nl = and_416_cse & and_tmp_64;
  assign mux_892_nl = MUX_s_1_2_2(and_803_nl, and_389_cse, BATCH_LOOP_stage_v_6);
  assign and_820_nl = and_439_cse & and_tmp_64;
  assign mux_906_nl = MUX_s_1_2_2(and_820_nl, and_388_cse, BATCH_LOOP_stage_v_7);
  assign and_836_nl = and_dcpl_57 & and_tmp_64;
  assign mux_919_nl = MUX_s_1_2_2(and_836_nl, and_387_cse, BATCH_LOOP_stage_v_8);
  assign and_851_nl = and_dcpl_169 & and_tmp_64;
  assign mux_931_nl = MUX_s_1_2_2(and_851_nl, and_386_cse, BATCH_LOOP_stage_v_9);
  assign and_865_nl = and_572_cse & and_tmp_64;
  assign mux_942_nl = MUX_s_1_2_2(and_865_nl, and_385_cse, BATCH_LOOP_stage_v_10);
  assign and_879_nl = and_591_cse & and_617_cse;
  assign mux_951_nl = MUX_s_1_2_2(and_617_cse, and_877_cse, BATCH_LOOP_stage_v_12);
  assign and_878_nl = BATCH_LOOP_stage_0_12 & mux_951_nl;
  assign mux_952_nl = MUX_s_1_2_2(and_879_nl, and_878_nl, BATCH_LOOP_stage_v_11);
  assign and_891_nl = and_609_cse & and_617_cse;
  assign mux_961_nl = MUX_s_1_2_2(and_891_nl, and_877_cse, BATCH_LOOP_stage_v_12);
  assign and_997_nl = (or_194_cse | or_dcpl_85) & BATCH_LOOP_and_21_tmp;
  assign and_987_nl = ((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0!=2'b10) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2
      | exit_BATCH_LOOP_lpi_2_dfm_st_4) & mux_tmp_954;

  function automatic [0:0] MUX1HOT_s_1_3_2;
    input [0:0] input_2;
    input [0:0] input_1;
    input [0:0] input_0;
    input [2:0] sel;
    reg [0:0] result;
  begin
    result = input_0 & {1{sel[0]}};
    result = result | ( input_1 & {1{sel[1]}});
    result = result | ( input_2 & {1{sel[2]}});
    MUX1HOT_s_1_3_2 = result;
  end
  endfunction


  function automatic [1:0] MUX1HOT_v_2_3_2;
    input [1:0] input_2;
    input [1:0] input_1;
    input [1:0] input_0;
    input [2:0] sel;
    reg [1:0] result;
  begin
    result = input_0 & {2{sel[0]}};
    result = result | ( input_1 & {2{sel[1]}});
    result = result | ( input_2 & {2{sel[2]}});
    MUX1HOT_v_2_3_2 = result;
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


  function automatic [70:0] MUX1HOT_v_71_3_2;
    input [70:0] input_2;
    input [70:0] input_1;
    input [70:0] input_0;
    input [2:0] sel;
    reg [70:0] result;
  begin
    result = input_0 & {71{sel[0]}};
    result = result | ( input_1 & {71{sel[1]}});
    result = result | ( input_2 & {71{sel[2]}});
    MUX1HOT_v_71_3_2 = result;
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


  function automatic [6:0] MUX_v_7_4_2;
    input [6:0] input_0;
    input [6:0] input_1;
    input [6:0] input_2;
    input [6:0] input_3;
    input [1:0] sel;
    reg [6:0] result;
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
    MUX_v_7_4_2 = result;
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


  function automatic [1:0] signext_2_1;
    input [0:0] vector;
  begin
    signext_2_1= {{1{vector[0]}}, vector};
  end
  endfunction


  function automatic [3:0] signext_4_1;
    input [0:0] vector;
  begin
    signext_4_1= {{3{vector[0]}}, vector};
  end
  endfunction


  function automatic [70:0] signext_71_1;
    input [0:0] vector;
  begin
    signext_71_1= {{70{vector[0]}}, vector};
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


  function automatic [27:0] conv_u2u_4_28 ;
    input [3:0]  vector ;
  begin
    conv_u2u_4_28 = {{24{1'b0}}, vector};
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
  wire [31:0] plm_out_data_rsci_d_d;
  wire [31:0] plm_out_data_rsci_q_d;
  wire [3:0] plm_out_data_rsci_radr_d;
  wire [3:0] plm_out_data_rsci_wadr_d;
  wire plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  wire plm_out_data_rsc_clken;
  wire [31:0] plm_out_data_rsc_q;
  wire [3:0] plm_out_data_rsc_radr;
  wire plm_out_data_rsc_we;
  wire [31:0] plm_out_data_rsc_d;
  wire [3:0] plm_out_data_rsc_wadr;
  wire [66:0] dma_read_ctrl_rsc_dat;
  wire [66:0] dma_write_ctrl_rsc_dat;
  wire plm_out_data_rsci_we_d_iff;


  // Interconnect Declarations for Component Instantiations 
  BLOCK_1R1W_RBW #(.addr_width(32'sd4),
  .data_width(32'sd32),
  .depth(32'sd16),
  .latency(32'sd1)) plm_out_data_rsc_comp (
      .clk(clk),
      .clken(plm_out_data_rsc_clken),
      .d(plm_out_data_rsc_d),
      .q(plm_out_data_rsc_q),
      .radr(plm_out_data_rsc_radr),
      .wadr(plm_out_data_rsc_wadr),
      .we(plm_out_data_rsc_we)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_8_4_32_16_16_32_1_gen
      plm_out_data_rsci (
      .clken(plm_out_data_rsc_clken),
      .q(plm_out_data_rsc_q),
      .radr(plm_out_data_rsc_radr),
      .we(plm_out_data_rsc_we),
      .d(plm_out_data_rsc_d),
      .wadr(plm_out_data_rsc_wadr),
      .clken_d(1'b1),
      .d_d(plm_out_data_rsci_d_d),
      .q_d(plm_out_data_rsci_q_d),
      .radr_d(plm_out_data_rsci_radr_d),
      .wadr_d(plm_out_data_rsci_wadr_d),
      .we_d(plm_out_data_rsci_we_d_iff),
      .writeA_w_ram_ir_internal_WMASK_B_d(plm_out_data_rsci_we_d_iff),
      .readA_r_ram_ir_internal_RMASK_B_d(plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d)
    );
  esp_acc_softmax_cxx_catapult_softmax_cxx_catapult_core softmax_cxx_catapult_core_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat_batch),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .dma_read_ctrl_rsc_dat(dma_read_ctrl_rsc_dat),
      .dma_read_ctrl_rsc_vld(dma_read_ctrl_rsc_vld),
      .dma_read_ctrl_rsc_rdy(dma_read_ctrl_rsc_rdy),
      .dma_write_ctrl_rsc_dat(dma_write_ctrl_rsc_dat),
      .dma_write_ctrl_rsc_vld(dma_write_ctrl_rsc_vld),
      .dma_write_ctrl_rsc_rdy(dma_write_ctrl_rsc_rdy),
      .dma_read_chnl_rsc_dat(dma_read_chnl_rsc_dat),
      .dma_read_chnl_rsc_vld(dma_read_chnl_rsc_vld),
      .dma_read_chnl_rsc_rdy(dma_read_chnl_rsc_rdy),
      .dma_write_chnl_rsc_dat(dma_write_chnl_rsc_dat),
      .dma_write_chnl_rsc_vld(dma_write_chnl_rsc_vld),
      .dma_write_chnl_rsc_rdy(dma_write_chnl_rsc_rdy),
      .acc_done_rsc_vld(acc_done_rsc_vld),
      .plm_out_data_rsci_d_d(plm_out_data_rsci_d_d),
      .plm_out_data_rsci_q_d(plm_out_data_rsci_q_d),
      .plm_out_data_rsci_radr_d(plm_out_data_rsci_radr_d),
      .plm_out_data_rsci_wadr_d(plm_out_data_rsci_wadr_d),
      .plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d(plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d),
      .plm_out_data_rsci_we_d_pff(plm_out_data_rsci_we_d_iff)
    );
  assign dma_read_ctrl_rsc_dat_index = dma_read_ctrl_rsc_dat[31:0];
  assign dma_read_ctrl_rsc_dat_length = dma_read_ctrl_rsc_dat[63:32];
  assign dma_read_ctrl_rsc_dat_size = dma_read_ctrl_rsc_dat[66:64];
  assign dma_write_ctrl_rsc_dat_index = dma_write_ctrl_rsc_dat[31:0];
  assign dma_write_ctrl_rsc_dat_length = dma_write_ctrl_rsc_dat[63:32];
  assign dma_write_ctrl_rsc_dat_size = dma_write_ctrl_rsc_dat[66:64];
endmodule

// ------------------------------------------------------------------
//  Design Unit:    softmax_cxx_catapult_basic_fx32_dma64
// ------------------------------------------------------------------


module softmax_cxx_catapult_basic_fx32_dma64 (
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



