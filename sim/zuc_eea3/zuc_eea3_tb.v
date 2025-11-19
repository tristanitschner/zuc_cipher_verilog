// SPDX-License-Identifier: GPL-2.0-only
// Copyright (C) 2025 Tristan Itschner
`default_nettype none
`timescale 1 ns / 1 ps

module zuc_eea3_tb;

/******************************************************************************/
// general

parameter sync             = 0;
parameter testcase         = 5;
parameter debug_output     = 1;
parameter debug_trace      = 1;
parameter toggle_sending   = 0;
parameter toggle_reception = 0;

localparam bw = 1;
localparam kw = 32/bw;

initial begin
    if (debug_trace) begin
        $dumpfile("zuc_eea3_tb.vcd");
        $dumpvars(0, zuc_eea3_tb);
    end
end

reg clk = 1;
initial forever #1 clk = !clk;

/******************************************************************************/
// dut

wire         s_ctl_valid;
wire         s_ctl_ready;
wire [31:0]  s_ctl_count;
wire [4:0]   s_ctl_bearer;
wire         s_ctl_direction;
wire [127:0] s_ctl_ck;

wire          s_valid;
wire          s_ready;
wire          s_last;
wire [31:0]   s_data;
wire [kw-1:0] s_keep;

wire          m_valid;
wire          m_ready;
wire          m_last;
wire [31:0]   m_data;
wire [kw-1:0] m_keep;

zuc_eea3 #(
    .sbox_ram_style ("distributed"),
    .sbox_sync      (sync),
    .bw             (bw)
) zuc_eea3_inst (
    .clk             (clk),
    .s_ctl_valid     (s_ctl_valid),
    .s_ctl_ready     (s_ctl_ready),
    .s_ctl_count     (s_ctl_count),
    .s_ctl_bearer    (s_ctl_bearer),
    .s_ctl_direction (s_ctl_direction),
    .s_ctl_ck        (s_ctl_ck),
    .s_valid         (s_valid),
    .s_ready         (s_ready),
    .s_last          (s_last),
    .s_data          (s_data),
    .s_keep          (s_keep),
    .m_valid         (m_valid),
    .m_ready         (m_ready),
    .m_last          (m_last),
    .m_data          (m_data),
    .m_keep          (m_keep)
);

/******************************************************************************/
// drive dut

reg r_valid = 0;
reg r_ctl_valid = 0;

always @(posedge clk) begin
    r_valid <= $random;
    r_ctl_valid <= $random;
end

assign s_valid     = toggle_sending ? r_valid     : 1;
assign s_ctl_valid = toggle_sending ? r_ctl_valid : 1;

reg [31:0] s_count = 0;

always @(posedge clk) begin
    if (s_valid && s_ready) begin
        if (s_last) begin
            s_count <= 0;
        end else begin
            s_count <= s_count + 1;
        end
    end
end

reg [31:0] m_count = 0;

always @(posedge clk) begin
    if (m_valid && m_ready) begin
        if (m_last) begin
            m_count <= 0;
        end else begin
            m_count <= m_count + 1;
        end
    end
end

function [127:0] bswap128(input [127:0] x);
    integer i;
    begin
        for (i = 0; i < 16; i = i + 1) begin
            bswap128[8*(i+1)-1-:8] = x[8*(16-i)-1-:8];
        end
    end
endfunction

function [kw-1:0] count2keep(input integer count);
    integer i;
    begin
        count2keep = 0;
        for (i = 0; i < kw; i = i + 1) begin
            if (i < count) begin
                count2keep[31-i] = 1;
            end
        end
        if (count == 0) begin
            count2keep = {kw{1'b1}};
        end
    end
endfunction

/******************************************************************************/
generate if (testcase == 1) begin : testcase_1

    localparam length    = 193;
    localparam remainder = length % 32;
    localparam words     = length/32 + (|(remainder) ? 1 : 0);

    assign s_ctl_ck = bswap128(128'h17_3d_14_ba_50_03_73_1d_7a_60_04_94_70_f0_0a_29);
    assign s_ctl_count = 32'h66035492;
    assign s_ctl_bearer = 5'hf;
    assign s_ctl_direction = 0;

    assign s_data =
        s_count == 0 ? 32'h6cf65340 :
        s_count == 1 ? 32'h735552ab :
        s_count == 2 ? 32'h0c9752fa :
        s_count == 3 ? 32'h6f9025fe :
        s_count == 4 ? 32'h0bd675d9 :
        s_count == 5 ? 32'h005875b2 :
        s_count == 6 ? 32'h00000000 : 32'hxxxxxxxx;

    assign s_keep = s_last ? count2keep(remainder) : {kw{1'b1}};

    assign s_last = s_count == words-1;

    always @(posedge clk) begin
        if (m_valid) begin
            if (m_count == 0) assert(m_data == 32'ha6c85fc6);
            if (m_count == 1) assert(m_data == 32'h6afb8533);
            if (m_count == 2) assert(m_data == 32'haafc2518);
            if (m_count == 3) assert(m_data == 32'hdfe78494);
            if (m_count == 4) assert(m_data == 32'h0ee1e4b0);
            if (m_count == 5) assert(m_data == 32'h30238cc8);
            if (m_count == 6) assert(m_data == 32'h00000000);
            assert(m_count < 7);
        end
    end

end endgenerate

/******************************************************************************/
generate if (testcase == 2) begin : testcase_2

    localparam length    = 800;
    localparam remainder = length % 32;
    localparam words     = length/32 + (|(remainder) ? 1 : 0);

    assign s_ctl_ck = bswap128(128'he5_bd_3e_a0_eb_55_ad_e8_66_c6_ac_58_bd_54_30_2a);
    assign s_ctl_count = 32'h56823;
    assign s_ctl_bearer = 5'h18;
    assign s_ctl_direction = 1;

    assign s_data =
        s_count == 0  ? 32'h14a8ef69 :
        s_count == 1  ? 32'h3d678507 :
        s_count == 2  ? 32'hbbe7270a :
        s_count == 3  ? 32'h7f67ff50 :
        s_count == 4  ? 32'h06c3525b :
        s_count == 5  ? 32'h9807e467 :
        s_count == 6  ? 32'hc4e56000 :
        s_count == 7  ? 32'hba338f5d :
        s_count == 8  ? 32'h42955903 :
        s_count == 9  ? 32'h67518222 :
        s_count == 10 ? 32'h46c80d3b :
        s_count == 11 ? 32'h38f07f4b :
        s_count == 12 ? 32'he2d8ff58 :
        s_count == 13 ? 32'h05f51322 :
        s_count == 14 ? 32'h29bde93b :
        s_count == 15 ? 32'hbbdcaf38 :
        s_count == 16 ? 32'h2bf1ee97 :
        s_count == 17 ? 32'h2fbf9977 :
        s_count == 18 ? 32'hbada8945 :
        s_count == 19 ? 32'h847a2a6c :
        s_count == 20 ? 32'h9ad34a66 :
        s_count == 21 ? 32'h7554e04d :
        s_count == 22 ? 32'h1f7fa2c3 :
        s_count == 23 ? 32'h3241bd8f :
        s_count == 24 ? 32'h01ba220d : 32'hxxxxxxxx;

    assign s_last = s_count == words-1;

    assign s_keep = s_last ? count2keep(remainder) : {kw{1'b1}};

    always @(posedge clk) begin
        if (m_valid) begin
            if (m_count == 0)  assert(m_data == 32'h131d43e0);
            if (m_count == 1)  assert(m_data == 32'hdea1be5c);
            if (m_count == 2)  assert(m_data == 32'h5a1bfd97);
            if (m_count == 3)  assert(m_data == 32'h1d852cbf);
            if (m_count == 4)  assert(m_data == 32'h712d7b4f);
            if (m_count == 5)  assert(m_data == 32'h57961fea);
            if (m_count == 6)  assert(m_data == 32'h3208afa8);
            if (m_count == 7)  assert(m_data == 32'hbca433f4);
            if (m_count == 8)  assert(m_data == 32'h56ad09c7);
            if (m_count == 9)  assert(m_data == 32'h417e58bc);
            if (m_count == 10) assert(m_data == 32'h69cf8866);
            if (m_count == 11) assert(m_data == 32'hd1353f74);
            if (m_count == 12) assert(m_data == 32'h865e8078);
            if (m_count == 13) assert(m_data == 32'h1d202dfb);
            if (m_count == 14) assert(m_data == 32'h3ecff7fc);
            if (m_count == 15) assert(m_data == 32'hbc3b190f);
            if (m_count == 16) assert(m_data == 32'he82a204e);
            if (m_count == 17) assert(m_data == 32'hd0e350fc);
            if (m_count == 18) assert(m_data == 32'h0f6f2613);
            if (m_count == 19) assert(m_data == 32'hb2f2bca6);
            if (m_count == 20) assert(m_data == 32'hdf5a473a);
            if (m_count == 21) assert(m_data == 32'h57a4a00d);
            if (m_count == 22) assert(m_data == 32'h985ebad8);
            if (m_count == 23) assert(m_data == 32'h80d6f238);
            if (m_count == 25) assert(m_data == 32'h64a07b01);
            assert(m_count < 26);
        end
    end

end endgenerate

/******************************************************************************/
generate if (testcase == 3) begin : testcase_3

    localparam length    = 1570;
    localparam remainder = length % 32;
    localparam words     = length/32 + (|(remainder) ? 1 : 0);

    assign s_ctl_ck = bswap128(128'hd4_55_2a_8f_d6_e6_1c_c8_1a_20_09_14_1a_29_c1_0b);
    assign s_ctl_count = 32'h76452ec1;
    assign s_ctl_bearer = 5'h2;
    assign s_ctl_direction = 1;

    assign s_data =
        s_count == 0  ? 32'h38f07f4b :
        s_count == 1  ? 32'he2d8ff58 :
        s_count == 2  ? 32'h05f51322 :
        s_count == 3  ? 32'h29bde93b :
        s_count == 4  ? 32'hbbdcaf38 :
        s_count == 5  ? 32'h2bf1ee97 :
        s_count == 6  ? 32'h2fbf9977 :
        s_count == 7  ? 32'hbada8945 :
        s_count == 8  ? 32'h847a2a6c :
        s_count == 9  ? 32'h9ad34a66 :
        s_count == 10 ? 32'h7554e04d :
        s_count == 11 ? 32'h1f7fa2c3 :
        s_count == 12 ? 32'h3241bd8f :
        s_count == 13 ? 32'h01ba220d :
        s_count == 14 ? 32'h3ca4ec41 :
        s_count == 15 ? 32'he074595f :
        s_count == 16 ? 32'h54ae2b45 :
        s_count == 17 ? 32'h4fd97143 :
        s_count == 18 ? 32'h20436019 :
        s_count == 19 ? 32'h65cca85c :
        s_count == 20 ? 32'h2417ed6c :
        s_count == 21 ? 32'hbec3bada :
        s_count == 22 ? 32'h84fc8a57 :
        s_count == 23 ? 32'h9aea7837 :
        s_count == 24 ? 32'hb0271177 :
        s_count == 25 ? 32'h242a64dc :
        s_count == 26 ? 32'h0a9de71a :
        s_count == 27 ? 32'h8edee86c :
        s_count == 28 ? 32'ha3d47d03 :
        s_count == 29 ? 32'h3d6bf539 :
        s_count == 30 ? 32'h804eca86 :
        s_count == 31 ? 32'hc584a905 :
        s_count == 32 ? 32'h2de46ad3 :
        s_count == 33 ? 32'hfced6554 :
        s_count == 34 ? 32'h3bd90207 :
        s_count == 35 ? 32'h372b27af :
        s_count == 36 ? 32'hb79234f5 :
        s_count == 37 ? 32'hff43ea87 :
        s_count == 38 ? 32'h0820e2c2 :
        s_count == 39 ? 32'hb78a8aae :
        s_count == 40 ? 32'h61cce52a :
        s_count == 41 ? 32'h0515e348 :
        s_count == 42 ? 32'hd196664a :
        s_count == 43 ? 32'h3456b182 :
        s_count == 44 ? 32'ha07c406e :
        s_count == 45 ? 32'h4a207912 :
        s_count == 46 ? 32'h71cfeda1 :
        s_count == 47 ? 32'h65d535ec :
        s_count == 48 ? 32'h5ea2d4df :
        s_count == 49 ? 32'h40000000 : 32'hxxxxxxxx;

    assign s_last = s_count == words-1;

    assign s_keep = s_last ? count2keep(remainder) : {kw{1'b1}};

    always @(posedge clk) begin
        if (m_valid) begin
            if (m_count == 0)  assert(m_data == 32'h8383b022);
            if (m_count == 1)  assert(m_data == 32'h9fcc0b9d);
            if (m_count == 2)  assert(m_data == 32'h2295ec41);
            if (m_count == 3)  assert(m_data == 32'hc977e9c2);
            if (m_count == 4)  assert(m_data == 32'hbb72e220);
            if (m_count == 5)  assert(m_data == 32'h378141f9);
            if (m_count == 6)  assert(m_data == 32'hc8318f3a);
            if (m_count == 7)  assert(m_data == 32'h270dfbcd);
            if (m_count == 8)  assert(m_data == 32'hee6411c2);
            if (m_count == 9)  assert(m_data == 32'hb3044f17);
            if (m_count == 10) assert(m_data == 32'h6dc6e00f);
            if (m_count == 11) assert(m_data == 32'h8960f97a);
            if (m_count == 12) assert(m_data == 32'hfacd131a);
            if (m_count == 13) assert(m_data == 32'hd6a3b49b);
            if (m_count == 14) assert(m_data == 32'h16b7babc);
            if (m_count == 15) assert(m_data == 32'hf2a509eb);
            if (m_count == 16) assert(m_data == 32'hb16a75dc);
            if (m_count == 17) assert(m_data == 32'hab14ff27);
            if (m_count == 18) assert(m_data == 32'h5dbeeea1);
            if (m_count == 19) assert(m_data == 32'ha2b155f9);
            if (m_count == 20) assert(m_data == 32'hd52c2645);
            if (m_count == 21) assert(m_data == 32'h2d0187c3);
            if (m_count == 22) assert(m_data == 32'h10a4ee55);
            if (m_count == 23) assert(m_data == 32'hbeaa78ab);
            if (m_count == 24) assert(m_data == 32'h4024615b);
            if (m_count == 25) assert(m_data == 32'ha9f5d5ad);
            if (m_count == 26) assert(m_data == 32'hc7728f73);
            if (m_count == 27) assert(m_data == 32'h560671f0);
            if (m_count == 28) assert(m_data == 32'h13e5e550);
            if (m_count == 29) assert(m_data == 32'h085d3291);
            if (m_count == 30) assert(m_data == 32'hdf7d5fec);
            if (m_count == 31) assert(m_data == 32'hedded559);
            if (m_count == 32) assert(m_data == 32'h641b6c2f);
            if (m_count == 33) assert(m_data == 32'h585233bc);
            if (m_count == 34) assert(m_data == 32'h71e9602b);
            if (m_count == 35) assert(m_data == 32'hd2305855);
            if (m_count == 36) assert(m_data == 32'hbbd25ffa);
            if (m_count == 37) assert(m_data == 32'h7f17ecbc);
            if (m_count == 38) assert(m_data == 32'h042daae3);
            if (m_count == 39) assert(m_data == 32'h8c1f57ad);
            if (m_count == 40) assert(m_data == 32'h8e8ebd37);
            if (m_count == 41) assert(m_data == 32'h346f71be);
            if (m_count == 42) assert(m_data == 32'hfdbb7432);
            if (m_count == 43) assert(m_data == 32'he0e0bb2c);
            if (m_count == 44) assert(m_data == 32'hfc09bcd9);
            if (m_count == 45) assert(m_data == 32'h6570cb0c);
            if (m_count == 46) assert(m_data == 32'h0c39df5e);
            if (m_count == 47) assert(m_data == 32'h29294e82);
            if (m_count == 48) assert(m_data == 32'h703a637f);
            if (m_count == 49) assert(m_data == 32'h80000000);
            assert(m_count < 50);
        end
    end

end endgenerate

/******************************************************************************/
generate if (testcase == 4) begin : testcase_4

    localparam length    = 2798;
    localparam remainder = length % 32;
    localparam words     = length/32 + (|(remainder) ? 1 : 0);

    assign s_ctl_ck = bswap128(128'hdb_84_b4_fb_cc_da_56_3b_66_22_7b_fe_45_6f_0f_77);
    assign s_ctl_count = 32'he4850fe1;
    assign s_ctl_bearer = 5'h10;
    assign s_ctl_direction = 1;

    assign s_data =
        s_count == 0  ? 32'he539f3b8 :
        s_count == 1  ? 32'h973240da :
        s_count == 2  ? 32'h03f2b8aa :
        s_count == 3  ? 32'h05ee0a00 :
        s_count == 4  ? 32'hdbafc0e1 :
        s_count == 5  ? 32'h82055dfe :
        s_count == 6  ? 32'h3d7383d9 :
        s_count == 7  ? 32'h2cef40e9 :
        s_count == 8  ? 32'h2928605d :
        s_count == 9  ? 32'h52d05f4f :
        s_count == 10 ? 32'h9018a1f1 :
        s_count == 11 ? 32'h89ae3997 :
        s_count == 12 ? 32'hce19155f :
        s_count == 13 ? 32'hb1221db8 :
        s_count == 14 ? 32'hbb0951a8 :
        s_count == 15 ? 32'h53ad852c :
        s_count == 16 ? 32'he16cff07 :
        s_count == 17 ? 32'h382c93a1 :
        s_count == 18 ? 32'h57de00dd :
        s_count == 19 ? 32'hb125c753 :
        s_count == 20 ? 32'h9fd85045 :
        s_count == 21 ? 32'he4ee07e0 :
        s_count == 22 ? 32'hc43f9e9d :
        s_count == 23 ? 32'h6f414fc4 :
        s_count == 24 ? 32'hd1c62917 :
        s_count == 25 ? 32'h813f74c0 :
        s_count == 26 ? 32'h0fc83f3e :
        s_count == 27 ? 32'h2ed7c45b :
        s_count == 28 ? 32'ha5835264 :
        s_count == 29 ? 32'hb43e0b20 :
        s_count == 30 ? 32'hafda6b30 :
        s_count == 31 ? 32'h53bfb642 :
        s_count == 32 ? 32'h3b7fce25 :
        s_count == 33 ? 32'h479ff5f1 :
        s_count == 34 ? 32'h39dd9b5b :
        s_count == 35 ? 32'h995558e2 :
        s_count == 36 ? 32'ha56be18d :
        s_count == 37 ? 32'hd581cd01 :
        s_count == 38 ? 32'h7c735e6f :
        s_count == 39 ? 32'h0d0d97c4 :
        s_count == 40 ? 32'hddc1d1da :
        s_count == 41 ? 32'h70c6db4a :
        s_count == 42 ? 32'h12cc9277 :
        s_count == 43 ? 32'h8e2fbbd6 :
        s_count == 44 ? 32'hf3ba52af :
        s_count == 45 ? 32'h91c9c6b6 :
        s_count == 46 ? 32'h4e8da4f7 :
        s_count == 47 ? 32'ha2c266d0 :
        s_count == 48 ? 32'h2d001753 :
        s_count == 49 ? 32'hdf089603 :
        s_count == 50 ? 32'h93c5d568 :
        s_count == 51 ? 32'h88bf49eb :
        s_count == 52 ? 32'h5c16d9a8 :
        s_count == 53 ? 32'h0427a416 :
        s_count == 54 ? 32'hbcb597df :
        s_count == 55 ? 32'h5bfe6f13 :
        s_count == 56 ? 32'h890a07ee :
        s_count == 57 ? 32'h1340e647 :
        s_count == 58 ? 32'h6b0d9aa8 :
        s_count == 59 ? 32'hf822ab0f :
        s_count == 60 ? 32'hd1ab0d20 :
        s_count == 61 ? 32'h4f40b7ce :
        s_count == 62 ? 32'h6f2e136e :
        s_count == 63 ? 32'hb67485e5 :
        s_count == 64 ? 32'h07804d50 :
        s_count == 65 ? 32'h4588ad37 :
        s_count == 66 ? 32'hffd81656 :
        s_count == 67 ? 32'h8b2dc403 :
        s_count == 68 ? 32'h11dfb654 :
        s_count == 69 ? 32'hcdead47e :
        s_count == 70 ? 32'h2385c343 :
        s_count == 71 ? 32'h6203dd83 :
        s_count == 72 ? 32'h6f9c64d9 :
        s_count == 73 ? 32'h7462ad5d :
        s_count == 74 ? 32'hfa63b5cf :
        s_count == 75 ? 32'he08acb95 :
        s_count == 76 ? 32'h32866f5c :
        s_count == 77 ? 32'ha787566f :
        s_count == 78 ? 32'hca93e6b1 :
        s_count == 79 ? 32'h693ee15c :
        s_count == 80 ? 32'hf6f7a2d6 :
        s_count == 81 ? 32'h89d97417 :
        s_count == 82 ? 32'h98dc1c23 :
        s_count == 83 ? 32'h8e1be650 :
        s_count == 84 ? 32'h733b18fb :
        s_count == 85 ? 32'h34ff880e :
        s_count == 86 ? 32'h16bbd21b :
        s_count == 87 ? 32'h47ac0000 : 32'hxxxxxxxx;

    assign s_last = s_count == words-1;

    assign s_keep = s_last ? count2keep(remainder) : {kw{1'b1}};

    always @(posedge clk) begin
        if (m_valid) begin
            if (m_count == 0)  assert(m_data == 32'h4bbfa91b);
            if (m_count == 1)  assert(m_data == 32'ha25d47db);
            if (m_count == 2)  assert(m_data == 32'h9a9f190d);
            if (m_count == 3)  assert(m_data == 32'h962a19ab);
            if (m_count == 4)  assert(m_data == 32'h323926b3);
            if (m_count == 5)  assert(m_data == 32'h51fbd39e);
            if (m_count == 6)  assert(m_data == 32'h351e05da);
            if (m_count == 7)  assert(m_data == 32'h8b8925e3);
            if (m_count == 8)  assert(m_data == 32'h0b1cce0d);
            if (m_count == 9)  assert(m_data == 32'h12211010);
            if (m_count == 10) assert(m_data == 32'h95815cc7);
            if (m_count == 11) assert(m_data == 32'hcb631950);
            if (m_count == 12) assert(m_data == 32'h9ec0d679);
            if (m_count == 13) assert(m_data == 32'h40491987);
            if (m_count == 14) assert(m_data == 32'he13f0aff);
            if (m_count == 15) assert(m_data == 32'hac332aa6);
            if (m_count == 16) assert(m_data == 32'haa64626d);
            if (m_count == 17) assert(m_data == 32'h3e9a1917);
            if (m_count == 18) assert(m_data == 32'h519e0b97);
            if (m_count == 19) assert(m_data == 32'hb655c6a1);
            if (m_count == 20) assert(m_data == 32'h65e44ca9);
            if (m_count == 21) assert(m_data == 32'hfeac0790);
            if (m_count == 22) assert(m_data == 32'hd2a321ad);
            if (m_count == 23) assert(m_data == 32'h3d86b79c);
            if (m_count == 24) assert(m_data == 32'h5138739f);
            if (m_count == 25) assert(m_data == 32'ha38d887e);
            if (m_count == 26) assert(m_data == 32'hc7def449);
            if (m_count == 27) assert(m_data == 32'hce8abdd3);
            if (m_count == 28) assert(m_data == 32'he7f8dc4c);
            if (m_count == 29) assert(m_data == 32'ha9e7b733);
            if (m_count == 30) assert(m_data == 32'h14ad310f);
            if (m_count == 31) assert(m_data == 32'h9025e619);
            if (m_count == 32) assert(m_data == 32'h46b3a56d);
            if (m_count == 33) assert(m_data == 32'hc649ec0d);
            if (m_count == 34) assert(m_data == 32'ha0d63943);
            if (m_count == 35) assert(m_data == 32'hdff592cf);
            if (m_count == 36) assert(m_data == 32'h962a7efb);
            if (m_count == 37) assert(m_data == 32'h2c8524e3);
            if (m_count == 38) assert(m_data == 32'h5a2a6e78);
            if (m_count == 39) assert(m_data == 32'h79d62604);
            if (m_count == 40) assert(m_data == 32'hef268695);
            if (m_count == 41) assert(m_data == 32'hfa400302);
            if (m_count == 42) assert(m_data == 32'h7e22e608);
            if (m_count == 43) assert(m_data == 32'h30775220);
            if (m_count == 44) assert(m_data == 32'h64bd4a5b);
            if (m_count == 45) assert(m_data == 32'h906b5f53);
            if (m_count == 46) assert(m_data == 32'h1274f235);
            if (m_count == 47) assert(m_data == 32'hed506cff);
            if (m_count == 48) assert(m_data == 32'h0154c754);
            if (m_count == 49) assert(m_data == 32'h928a0ce5);
            if (m_count == 50) assert(m_data == 32'h476f2cb1);
            if (m_count == 51) assert(m_data == 32'h020a1222);
            if (m_count == 52) assert(m_data == 32'hd32c1455);
            if (m_count == 53) assert(m_data == 32'hecaef1e3);
            if (m_count == 54) assert(m_data == 32'h68fb344d);
            if (m_count == 55) assert(m_data == 32'h1735bfbe);
            if (m_count == 56) assert(m_data == 32'hdeb71d0a);
            if (m_count == 57) assert(m_data == 32'h33a2a54b);
            if (m_count == 58) assert(m_data == 32'h1da5a294);
            if (m_count == 59) assert(m_data == 32'he679144d);
            if (m_count == 60) assert(m_data == 32'hdf11eb1a);
            if (m_count == 61) assert(m_data == 32'h3de8cf0c);
            if (m_count == 62) assert(m_data == 32'hc0619179);
            if (m_count == 63) assert(m_data == 32'h74f35c1d);
            if (m_count == 64) assert(m_data == 32'h9ca0ac81);
            if (m_count == 65) assert(m_data == 32'h807f8fcc);
            if (m_count == 66) assert(m_data == 32'he6199a6c);
            if (m_count == 67) assert(m_data == 32'h7712da86);
            if (m_count == 68) assert(m_data == 32'h5021b04c);
            if (m_count == 69) assert(m_data == 32'he0439516);
            if (m_count == 70) assert(m_data == 32'hf1a526cc);
            if (m_count == 71) assert(m_data == 32'hda9fd9ab);
            if (m_count == 72) assert(m_data == 32'hbd53c3a6);
            if (m_count == 73) assert(m_data == 32'h84f9ae1e);
            if (m_count == 74) assert(m_data == 32'h7ee6b11d);
            if (m_count == 75) assert(m_data == 32'ha138ea82);
            if (m_count == 76) assert(m_data == 32'h6c5516b5);
            if (m_count == 77) assert(m_data == 32'haadf1abb);
            if (m_count == 78) assert(m_data == 32'he36fa7ff);
            if (m_count == 79) assert(m_data == 32'hf92e3a11);
            if (m_count == 80) assert(m_data == 32'h76064e8d);
            if (m_count == 81) assert(m_data == 32'h95f2e488);
            if (m_count == 82) assert(m_data == 32'h2b5500b9);
            if (m_count == 83) assert(m_data == 32'h3228b219);
            if (m_count == 84) assert(m_data == 32'h4a475c1a);
            if (m_count == 85) assert(m_data == 32'h27f63f9f);
            if (m_count == 86) assert(m_data == 32'hfd264989);
            if (m_count == 87) assert(m_data == 32'ha1bc0000);
            assert(m_count < 88);
        end
    end
end endgenerate

/******************************************************************************/
generate if (testcase == 5) begin : testcase_5

    localparam length    = 4019;
    localparam remainder = length % 32;
    localparam words     = length/32 + (|(remainder) ? 1 : 0);

    assign s_ctl_ck = bswap128(128'he1_3f_ed_21_b4_6e_4e_7e_c3_12_53_b2_bb_17_b3_e0);
    assign s_ctl_count = 32'h2738cdaa;
    assign s_ctl_bearer = 5'h1a;
    assign s_ctl_direction = 0;

    assign s_data =
        s_count == 0   ? 32'h8d74e20d :
        s_count == 1   ? 32'h54894e06 :
        s_count == 2   ? 32'hd3cb13cb :
        s_count == 3   ? 32'h3933065e :
        s_count == 4   ? 32'h8674be62 :
        s_count == 5   ? 32'hadb1c72b :
        s_count == 6   ? 32'h3a646965 :
        s_count == 7   ? 32'hab63cb7b :
        s_count == 8   ? 32'h7854dfdc :
        s_count == 9   ? 32'h27e84929 :
        s_count == 10  ? 32'hf49c64b8 :
        s_count == 11  ? 32'h72a490b1 :
        s_count == 12  ? 32'h3f957b64 :
        s_count == 13  ? 32'h827e71f4 :
        s_count == 14  ? 32'h1fbd4269 :
        s_count == 15  ? 32'ha42c97f8 :
        s_count == 16  ? 32'h24537027 :
        s_count == 17  ? 32'hf86e9f4a :
        s_count == 18  ? 32'hd82d1df4 :
        s_count == 19  ? 32'h51690fdd :
        s_count == 20  ? 32'h98b6d03f :
        s_count == 21  ? 32'h3a0ebe3a :
        s_count == 22  ? 32'h312d6b84 :
        s_count == 23  ? 32'h0ba5a182 :
        s_count == 24  ? 32'h0b2a2c97 :
        s_count == 25  ? 32'h09c090d2 :
        s_count == 26  ? 32'h45ed267c :
        s_count == 27  ? 32'hf845ae41 :
        s_count == 28  ? 32'hfa975d33 :
        s_count == 29  ? 32'h33ac3009 :
        s_count == 30  ? 32'hfd40eba9 :
        s_count == 31  ? 32'heb5b8857 :
        s_count == 32  ? 32'h14b768b6 :
        s_count == 33  ? 32'h97138baf :
        s_count == 34  ? 32'h21380eca :
        s_count == 35  ? 32'h49f644d4 :
        s_count == 36  ? 32'h8689e421 :
        s_count == 37  ? 32'h5760b906 :
        s_count == 38  ? 32'h739f0d2b :
        s_count == 39  ? 32'h3f091133 :
        s_count == 40  ? 32'hca15d981 :
        s_count == 41  ? 32'hcbe401ba :
        s_count == 42  ? 32'hf72d05ac :
        s_count == 43  ? 32'he05cccb2 :
        s_count == 44  ? 32'hd297f4ef :
        s_count == 45  ? 32'h6a5f58d9 :
        s_count == 46  ? 32'h1246cfa7 :
        s_count == 47  ? 32'h7215b892 :
        s_count == 48  ? 32'hab441d52 :
        s_count == 49  ? 32'h78452795 :
        s_count == 50  ? 32'hccb7f5d7 :
        s_count == 51  ? 32'h9057a1c4 :
        s_count == 52  ? 32'hf77f80d4 :
        s_count == 53  ? 32'h6db2033c :
        s_count == 54  ? 32'hb79bedf8 :
        s_count == 55  ? 32'he60551ce :
        s_count == 56  ? 32'h10c667f6 :
        s_count == 57  ? 32'h2a97abaf :
        s_count == 58  ? 32'habbcd677 :
        s_count == 59  ? 32'h2018df96 :
        s_count == 60  ? 32'ha282ea73 :
        s_count == 61  ? 32'h7ce2cb33 :
        s_count == 62  ? 32'h1211f60d :
        s_count == 63  ? 32'h5354ce78 :
        s_count == 64  ? 32'hf9918d9c :
        s_count == 65  ? 32'h206ca042 :
        s_count == 66  ? 32'hc9b62387 :
        s_count == 67  ? 32'hdd709604 :
        s_count == 68  ? 32'ha50af16d :
        s_count == 69  ? 32'h8d35a890 :
        s_count == 70  ? 32'h6be484cf :
        s_count == 71  ? 32'h2e74a928 :
        s_count == 72  ? 32'h99403643 :
        s_count == 73  ? 32'h53249b27 :
        s_count == 74  ? 32'hb4c9ae29 :
        s_count == 75  ? 32'heddfc7da :
        s_count == 76  ? 32'h6418791a :
        s_count == 77  ? 32'h4e7baa06 :
        s_count == 78  ? 32'h60fa6451 :
        s_count == 79  ? 32'h1f2d685c :
        s_count == 80  ? 32'hc3a5ff70 :
        s_count == 81  ? 32'he0d2b742 :
        s_count == 82  ? 32'h92e3b8a0 :
        s_count == 83  ? 32'hcd6b04b1 :
        s_count == 84  ? 32'hc790b8ea :
        s_count == 85  ? 32'hd2703708 :
        s_count == 86  ? 32'h540dea2f :
        s_count == 87  ? 32'hc09c3da7 :
        s_count == 88  ? 32'h70f65449 :
        s_count == 89  ? 32'he84d817a :
        s_count == 90  ? 32'h4f551055 :
        s_count == 91  ? 32'he19ab850 :
        s_count == 92  ? 32'h18a0028b :
        s_count == 93  ? 32'h71a144d9 :
        s_count == 94  ? 32'h6791e9a3 :
        s_count == 95  ? 32'h57793350 :
        s_count == 96  ? 32'h4eee0060 :
        s_count == 97  ? 32'h340c69d2 :
        s_count == 98  ? 32'h74e1bf9d :
        s_count == 99  ? 32'h805dcbcc :
        s_count == 100 ? 32'h1a6faa97 :
        s_count == 101 ? 32'h6800b6ff :
        s_count == 102 ? 32'h2b671dc4 :
        s_count == 103 ? 32'h63652fa8 :
        s_count == 104 ? 32'ha33ee509 :
        s_count == 105 ? 32'h74c1c21b :
        s_count == 106 ? 32'he01eabb2 :
        s_count == 107 ? 32'h16743026 :
        s_count == 108 ? 32'h9d72ee51 :
        s_count == 109 ? 32'h1c9dde30 :
        s_count == 110 ? 32'h797c9a25 :
        s_count == 111 ? 32'hd86ce74f :
        s_count == 112 ? 32'h5b961be5 :
        s_count == 113 ? 32'hfdfb6807 :
        s_count == 114 ? 32'h814039e7 :
        s_count == 115 ? 32'h137636bd :
        s_count == 116 ? 32'h1d7fa9e0 :
        s_count == 117 ? 32'h9efd2007 :
        s_count == 118 ? 32'h505906a5 :
        s_count == 119 ? 32'hac45dfde :
        s_count == 120 ? 32'hed7757bb :
        s_count == 121 ? 32'hee745749 :
        s_count == 122 ? 32'hc2963335 :
        s_count == 123 ? 32'h0bee0ea6 :
        s_count == 124 ? 32'hf409df45 :
        s_count == 125 ? 32'h80160000 : 32'hxxxxxxxx;

    assign s_last = s_count == words-1;

    assign s_keep = s_last ? count2keep(remainder) : {kw{1'b1}};

    always @(posedge clk) begin
        if (m_valid) begin
            if (m_count == 0)   assert(m_data == 32'h94eaa4aa);
            if (m_count == 1)   assert(m_data == 32'h30a57137);
            if (m_count == 2)   assert(m_data == 32'hddf09b97);
            if (m_count == 3)   assert(m_data == 32'hb25618a2);
            if (m_count == 4)   assert(m_data == 32'h0a13e2f1);
            if (m_count == 5)   assert(m_data == 32'h0fa5bf81);
            if (m_count == 6)   assert(m_data == 32'h61a879cc);
            if (m_count == 7)   assert(m_data == 32'h2ae797a6);
            if (m_count == 8)   assert(m_data == 32'hb4cf2d9d);
            if (m_count == 9)   assert(m_data == 32'hf31debb9);
            if (m_count == 10)  assert(m_data == 32'h905ccfec);
            if (m_count == 11)  assert(m_data == 32'h97de605d);
            if (m_count == 12)  assert(m_data == 32'h21c61ab8);
            if (m_count == 13)  assert(m_data == 32'h531b7f3c);
            if (m_count == 14)  assert(m_data == 32'h9da5f039);
            if (m_count == 15)  assert(m_data == 32'h31f8a064);
            if (m_count == 16)  assert(m_data == 32'h2de48211);
            if (m_count == 17)  assert(m_data == 32'hf5f52ffe);
            if (m_count == 18)  assert(m_data == 32'ha10f392a);
            if (m_count == 19)  assert(m_data == 32'h04766998);
            if (m_count == 20)  assert(m_data == 32'h5da454a2);
            if (m_count == 21)  assert(m_data == 32'h8f080961);
            if (m_count == 22)  assert(m_data == 32'ha6c2b62d);
            if (m_count == 23)  assert(m_data == 32'haa17f33c);
            if (m_count == 24)  assert(m_data == 32'hd60a4971);
            if (m_count == 25)  assert(m_data == 32'hf48d2d90);
            if (m_count == 26)  assert(m_data == 32'h9394a55f);
            if (m_count == 27)  assert(m_data == 32'h48117ace);
            if (m_count == 28)  assert(m_data == 32'h43d708e6);
            if (m_count == 29)  assert(m_data == 32'hb77d3dc4);
            if (m_count == 30)  assert(m_data == 32'h6d8bc017);
            if (m_count == 31)  assert(m_data == 32'hd4d1abb7);
            if (m_count == 32)  assert(m_data == 32'h7b7428c0);
            if (m_count == 33)  assert(m_data == 32'h42b06f2f);
            if (m_count == 34)  assert(m_data == 32'h99d8d07c);
            if (m_count == 35)  assert(m_data == 32'h9879d996);
            if (m_count == 36)  assert(m_data == 32'h00127a31);
            if (m_count == 37)  assert(m_data == 32'h985f1099);
            if (m_count == 38)  assert(m_data == 32'hbbd7d6c1);
            if (m_count == 39)  assert(m_data == 32'h519ede8f);
            if (m_count == 40)  assert(m_data == 32'h5eeb4a61);
            if (m_count == 41)  assert(m_data == 32'h0b349ac0);
            if (m_count == 42)  assert(m_data == 32'h1ea23506);
            if (m_count == 43)  assert(m_data == 32'h91756bd1);
            if (m_count == 44)  assert(m_data == 32'h05c974a5);
            if (m_count == 45)  assert(m_data == 32'h3eddb35d);
            if (m_count == 46)  assert(m_data == 32'h1d4100b0);
            if (m_count == 47)  assert(m_data == 32'h12e522ab);
            if (m_count == 48)  assert(m_data == 32'h41f4c5f2);
            if (m_count == 49)  assert(m_data == 32'hfde76b59);
            if (m_count == 50)  assert(m_data == 32'hcb8b96d8);
            if (m_count == 51)  assert(m_data == 32'h85cfe408);
            if (m_count == 52)  assert(m_data == 32'h0d1328a0);
            if (m_count == 53)  assert(m_data == 32'hd636cc0e);
            if (m_count == 54)  assert(m_data == 32'hdc05800b);
            if (m_count == 55)  assert(m_data == 32'h76acca8f);
            if (m_count == 56)  assert(m_data == 32'hef672084);
            if (m_count == 57)  assert(m_data == 32'hd1f52a8b);
            if (m_count == 58)  assert(m_data == 32'hbd8e0993);
            if (m_count == 59)  assert(m_data == 32'h320992c7);
            if (m_count == 60)  assert(m_data == 32'hffbae17c);
            if (m_count == 61)  assert(m_data == 32'h408441e0);
            if (m_count == 62)  assert(m_data == 32'hee883fc8);
            if (m_count == 63)  assert(m_data == 32'ha8b05e22);
            if (m_count == 64)  assert(m_data == 32'hf5ff7f8d);
            if (m_count == 65)  assert(m_data == 32'h1b48c74c);
            if (m_count == 66)  assert(m_data == 32'h468c467a);
            if (m_count == 67)  assert(m_data == 32'h028f09fd);
            if (m_count == 68)  assert(m_data == 32'h7ce91109);
            if (m_count == 69)  assert(m_data == 32'ha570a2d5);
            if (m_count == 70)  assert(m_data == 32'hc4d5f4fa);
            if (m_count == 71)  assert(m_data == 32'h18c5dd3e);
            if (m_count == 72)  assert(m_data == 32'h4562afe2);
            if (m_count == 73)  assert(m_data == 32'h4ef77190);
            if (m_count == 74)  assert(m_data == 32'h1f59af64);
            if (m_count == 75)  assert(m_data == 32'h5898acef);
            if (m_count == 76)  assert(m_data == 32'h088abae0);
            if (m_count == 77)  assert(m_data == 32'h7e92d52e);
            if (m_count == 78)  assert(m_data == 32'hb2de5504);
            if (m_count == 79)  assert(m_data == 32'h5bb1b7c4);
            if (m_count == 80)  assert(m_data == 32'h164ef2d7);
            if (m_count == 81)  assert(m_data == 32'ha6cac15e);
            if (m_count == 82)  assert(m_data == 32'heb926d7e);
            if (m_count == 83)  assert(m_data == 32'ha2f08b66);
            if (m_count == 84)  assert(m_data == 32'he1f759f3);
            if (m_count == 85)  assert(m_data == 32'haee44614);
            if (m_count == 86)  assert(m_data == 32'h725aa3c7);
            if (m_count == 87)  assert(m_data == 32'h482b3084);
            if (m_count == 88)  assert(m_data == 32'h4c143ff8);
            if (m_count == 89)  assert(m_data == 32'h5b53f1e5);
            if (m_count == 90)  assert(m_data == 32'h83c50125);
            if (m_count == 91)  assert(m_data == 32'h7dddd096);
            if (m_count == 92)  assert(m_data == 32'hb81268da);
            if (m_count == 93)  assert(m_data == 32'ha303f172);
            if (m_count == 94)  assert(m_data == 32'h34c23335);
            if (m_count == 95)  assert(m_data == 32'h41f0bb8e);
            if (m_count == 96)  assert(m_data == 32'h190648c5);
            if (m_count == 97)  assert(m_data == 32'h807c866d);
            if (m_count == 98)  assert(m_data == 32'h71932286);
            if (m_count == 99)  assert(m_data == 32'h09adb948);
            if (m_count == 100) assert(m_data == 32'h686f7de2);
            if (m_count == 101) assert(m_data == 32'h94a802cc);
            if (m_count == 102) assert(m_data == 32'h38f7fe52);
            if (m_count == 103) assert(m_data == 32'h08f5ea31);
            if (m_count == 104) assert(m_data == 32'h96d0167b);
            if (m_count == 105) assert(m_data == 32'h9bdd02f0);
            if (m_count == 106) assert(m_data == 32'hd2a5221c);
            if (m_count == 107) assert(m_data == 32'ha508f893);
            if (m_count == 108) assert(m_data == 32'haf5c4b4b);
            if (m_count == 109) assert(m_data == 32'hb9f4f520);
            if (m_count == 110) assert(m_data == 32'hfd84289b);
            if (m_count == 111) assert(m_data == 32'h3dbe7e61);
            if (m_count == 112) assert(m_data == 32'h497a7e2a);
            if (m_count == 113) assert(m_data == 32'h584037ea);
            if (m_count == 114) assert(m_data == 32'h637b6981);
            if (m_count == 115) assert(m_data == 32'h127174af);
            if (m_count == 116) assert(m_data == 32'h57b471df);
            if (m_count == 117) assert(m_data == 32'h4b2768fd);
            if (m_count == 118) assert(m_data == 32'h79c1540f);
            if (m_count == 119) assert(m_data == 32'hb3edf2ea);
            if (m_count == 120) assert(m_data == 32'h22cb69be);
            if (m_count == 121) assert(m_data == 32'hc0cf8d93);
            if (m_count == 122) assert(m_data == 32'h3d9c6fdd);
            if (m_count == 123) assert(m_data == 32'h645e8505);
            if (m_count == 124) assert(m_data == 32'h91cca3d6);
            if (m_count == 125) assert(m_data == 32'h2c0cc000);
            assert(m_count < 126);
        end
    end

end endgenerate



reg r_ready = 0;
always @(posedge clk) begin
    r_ready <= $random;
end

assign m_ready = toggle_reception ? r_ready : 1;

generate if (debug_output) begin : debug_prints

    always @(posedge clk) begin
        if (m_valid && m_ready) begin
            $display("%08x", m_data);
        end
        if (m_last) begin
            $display("LAST");
        end
    end

end endgenerate

reg [31:0] m_beats = 0;
always @(posedge clk) begin
    if (m_valid && m_ready) begin
        m_beats <= m_beats + 1;
    end
end

initial begin
    #10000;
    $display("Received %d words.", m_beats);
    $finish;
end

endmodule
