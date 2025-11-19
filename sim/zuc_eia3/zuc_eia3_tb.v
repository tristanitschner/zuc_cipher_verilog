// SPDX-License-Identifier: GPL-2.0-only
// Copyright (C) 2025 Tristan Itschner
`default_nettype none
`timescale 1 ns / 1 ps

module zuc_eia3_tb;

parameter sync = 0;
parameter testcase         = 5;
parameter debug_output     = 1;
parameter debug_trace      = 1;
parameter toggle_sending   = 1;
parameter toggle_reception = 1;

localparam bw = 1;
localparam kw = 32/bw;

initial begin
    if (debug_trace) begin
        $dumpfile("zuc_eia3_tb.vcd");
        $dumpvars(0, zuc_eia3_tb);
    end
end

reg clk = 1;
initial forever #1 clk = !clk;


wire         s_ctl_valid;
wire         s_ctl_ready;
wire [31:0]  s_ctl_count;
wire [4:0]   s_ctl_bearer;
wire         s_ctl_direction;
wire [127:0] s_ctl_ik;

wire          s_valid;
wire          s_ready;
wire          s_last;
wire [31:0]   s_data;
wire [kw-1:0] s_keep;

wire          m_valid;
wire          m_ready;
wire [31:0]   m_mac;

zuc_eia3 #(
    .sbox_ram_style ("distributed"),
    .sbox_sync      (sync),
    .bw             (bw)
) zuc_eia3_inst (
    .clk             (clk),
    .s_ctl_valid     (s_ctl_valid),
    .s_ctl_ready     (s_ctl_ready),
    .s_ctl_count     (s_ctl_count),
    .s_ctl_bearer    (s_ctl_bearer),
    .s_ctl_direction (s_ctl_direction),
    .s_ctl_ik        (s_ctl_ik),
    .s_valid         (s_valid),
    .s_ready         (s_ready),
    .s_last          (s_last),
    .s_data          (s_data),
    .s_keep          (s_keep),
    .m_valid         (m_valid),
    .m_ready         (m_ready),
    .m_mac           (m_mac)
);

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

function [127:0] bswap128(input [127:0] x);
    integer i;
    begin
        for (i = 0; i < 16; i = i + 1) begin
            bswap128[8*(i+1)-1-:8] = x[8*(16-i)-1-:8];
        end
    end
endfunction

/******************************************************************************/
generate if (testcase == 1) begin : testcase_1

    assign s_ctl_ik = bswap128(128'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00);
    assign s_ctl_count = 32'h0;
    assign s_ctl_bearer = 5'h0;
    assign s_ctl_direction = 0;

    assign s_data = 0;

    assign s_keep = 32'b1;

    assign s_last = s_count == 0;

    always @(posedge clk) begin
        if (m_valid) begin
            assert(m_mac == 32'hc8a9595e);
        end
    end

end endgenerate

/******************************************************************************/
generate if (testcase == 2) begin : testcase_2

    assign s_ctl_ik = bswap128(128'h47_05_41_25_56_1e_b2_dd_a9_40_59_da_05_09_78_50);
    assign s_ctl_count = 32'h561eb2dd;
    assign s_ctl_bearer = 5'h14;
    assign s_ctl_direction = 0;

    assign s_data = 0;

    assign s_keep = s_last ? 32'b11_1111_1111_1111_1111_1111_1111 : {32{1'b1}};

    assign s_last = s_count == 2;

    always @(posedge clk) begin
        if (m_valid) begin
            assert(m_mac == 32'h6719a088);
        end
    end

end endgenerate

/******************************************************************************/
generate if (testcase == 3) begin : testcase_3

    assign s_ctl_ik = bswap128(128'hc9_e6_ce_c4_60_7c_72_db_00_0a_ef_a8_83_85_ab_0a);
    assign s_ctl_count = 32'ha94059da;
    assign s_ctl_bearer = 5'ha;
    assign s_ctl_direction = 1;

    assign s_data =
        s_count == 0  ? 32'h983b41d4 :
        s_count == 1  ? 32'h7d780c9e :
        s_count == 2  ? 32'h1ad11d7e :
        s_count == 3  ? 32'hb70391b1 :
        s_count == 4  ? 32'hde0b35da :
        s_count == 5  ? 32'h2dc62f83 :
        s_count == 6  ? 32'he7b78d63 :
        s_count == 7  ? 32'h06ca0ea0 :
        s_count == 8  ? 32'h7e941b7b :
        s_count == 9  ? 32'he91348f9 :
        s_count == 10 ? 32'hfcb170e2 :
        s_count == 11 ? 32'h217fecd9 :
        s_count == 12 ? 32'h7f9f68ad :
        s_count == 13 ? 32'hb16e5d7d :
        s_count == 14 ? 32'h21e569d2 :
        s_count == 15 ? 32'h80ed775c :
        s_count == 16 ? 32'hebde3f40 :
        s_count == 17 ? 32'h93c53881 :
        s_count == 18 ? 32'h00000000 : 32'bx;

    assign s_keep = s_last ? 32'b1 : {32{1'b1}};

    assign s_last = s_count == 18;

    always @(posedge clk) begin
        if (m_valid) begin
            assert(m_mac == 32'hfae8ff0b);
        end
    end

end endgenerate

/******************************************************************************/
generate if (testcase == 4) begin : testcase_4

    assign s_ctl_ik = bswap128(128'hc8_a4_82_62_d0_c2_e2_ba_c4_b9_6e_f7_7e_80_ca_59);
    assign s_ctl_count = 32'h05097850;
    assign s_ctl_bearer = 5'h10;
    assign s_ctl_direction = 1;

    assign s_data =
        s_count == 0 ? 32'hb546430b :
        s_count == 1 ? 32'hf87b4f1e :
        s_count == 2 ? 32'he834704c :
        s_count == 3 ? 32'hd6951c36 :
        s_count == 4 ? 32'he26f108c :
        s_count == 5 ? 32'hf731788f :
        s_count == 6 ? 32'h48dc34f1 :
        s_count == 7 ? 32'h678c0522 :
        s_count == 8 ? 32'h1c8fa7ff :
        s_count == 9 ? 32'h2f39f477 :
        s_count == 10 ? 32'he7e49ef6 :
        s_count == 11 ? 32'h0a4ec2c3 :
        s_count == 12 ? 32'hde24312a :
        s_count == 13 ? 32'h96aa26e1 :
        s_count == 14 ? 32'hcfba5756 :
        s_count == 15 ? 32'h3838b297 :
        s_count == 16 ? 32'hf47e8510 :
        s_count == 17 ? 32'hc779fd66 :
        s_count == 18 ? 32'h54b14338 :
        s_count == 19 ? 32'h6fa639d3 :
        s_count == 20 ? 32'h1edbd6c0 :
        s_count == 21 ? 32'h6e47d159 :
        s_count == 22 ? 32'hd94362f2 :
        s_count == 23 ? 32'h6aeeedee :
        s_count == 24 ? 32'h0e4f49d9 :
        s_count == 25 ? 32'hbf841299 :
        s_count == 26 ? 32'h5415bfad :
        s_count == 27 ? 32'h56ee82d1 :
        s_count == 28 ? 32'hca7463ab :
        s_count == 29 ? 32'hf085b082 :
        s_count == 30 ? 32'hb09904d6 :
        s_count == 31 ? 32'hd990d43c :
        s_count == 32 ? 32'hf2e062f4 :
        s_count == 33 ? 32'h0839d932 :
        s_count == 34 ? 32'h48b1eb92 :
        s_count == 35 ? 32'hcdfed530 :
        s_count == 36 ? 32'h0bc14828 :
        s_count == 37 ? 32'h0430b6d0 :
        s_count == 38 ? 32'hcaa094b6 :
        s_count == 39 ? 32'hec8911ab :
        s_count == 40 ? 32'h7dc36824 :
        s_count == 41 ? 32'hb824dc0a :
        s_count == 42 ? 32'hf6682b09 :
        s_count == 43 ? 32'h35fde7b4 :
        s_count == 44 ? 32'h92a14dc2 :
        s_count == 45 ? 32'hf4364803 :
        s_count == 46 ? 32'h8da2cf79 :
        s_count == 47 ? 32'h170d2d50 :
        s_count == 48 ? 32'h133fd494 :
        s_count == 49 ? 32'h16cb6e33 :
        s_count == 50 ? 32'hbea90b8b :
        s_count == 51 ? 32'hf4559b03 :
        s_count == 52 ? 32'h732a01ea :
        s_count == 53 ? 32'h290e6d07 :
        s_count == 54 ? 32'h4f79bb83 :
        s_count == 55 ? 32'hc10e5800 :
        s_count == 56 ? 32'h15cc1a85 :
        s_count == 57 ? 32'hb36b5501 :
        s_count == 58 ? 32'h046e9c4b :
        s_count == 59 ? 32'hdcae5135 :
        s_count == 60 ? 32'h690b8666 :
        s_count == 61 ? 32'hbd54b7a7 :
        s_count == 62 ? 32'h03ea7b6f :
        s_count == 63 ? 32'h220a5469 :
        s_count == 64 ? 32'ha568027e : 32'bx;

    assign s_keep = s_last ? 32'b0111_1111_1111_1111_1111_1111_1111_1111 : {32{1'b1}};

    assign s_last = s_count == 64;

    always @(posedge clk) begin
        if (m_valid) begin
            assert(m_mac == 32'h004ac4d6);
        end
    end

end endgenerate

/******************************************************************************/
generate if (testcase == 5) begin : testcase_5

    assign s_ctl_ik = bswap128(128'h6b_8b_08_ee_79_e0_b5_98_2d_6d_12_8e_a9_f2_20_cb);
    assign s_ctl_count = 32'h561eb2dd;
    assign s_ctl_bearer = 5'h1c;
    assign s_ctl_direction = 0;

    assign s_data =
        s_count == 0 ? 32'h5bad7247 :
        s_count == 1 ? 32'h10ba1c56 :
        s_count == 2 ? 32'hd5a315f8 :
        s_count == 3 ? 32'hd40f6e09 :
        s_count == 4 ? 32'h3780be8e :
        s_count == 5 ? 32'h8de07b69 :
        s_count == 6 ? 32'h92432018 :
        s_count == 7 ? 32'he08ed96a :
        s_count == 8 ? 32'h5734af8b :
        s_count == 9 ? 32'had8a575d :
        s_count == 10 ? 32'h3a1f162f :
        s_count == 11 ? 32'h85045cc7 :
        s_count == 12 ? 32'h70925571 :
        s_count == 13 ? 32'hd9f5b94e :
        s_count == 14 ? 32'h454a77c1 :
        s_count == 15 ? 32'h6e72936b :
        s_count == 16 ? 32'hf016ae15 :
        s_count == 17 ? 32'h7499f054 :
        s_count == 18 ? 32'h3b5d52ca :
        s_count == 19 ? 32'ha6dbeab6 :
        s_count == 20 ? 32'h97d2bb73 :
        s_count == 21 ? 32'he41b8075 :
        s_count == 22 ? 32'hdce79b4b :
        s_count == 23 ? 32'h86044f66 :
        s_count == 24 ? 32'h1d4485a5 :
        s_count == 25 ? 32'h43dd7860 :
        s_count == 26 ? 32'h6e0419e8 :
        s_count == 27 ? 32'h059859d3 :
        s_count == 28 ? 32'hcb2b67ce :
        s_count == 29 ? 32'h0977603f :
        s_count == 30 ? 32'h81ff839e :
        s_count == 31 ? 32'h33185954 :
        s_count == 32 ? 32'h4cfbc8d0 :
        s_count == 33 ? 32'h0fef1a4c :
        s_count == 34 ? 32'h8510fb54 :
        s_count == 35 ? 32'h7d6b06c6 :
        s_count == 36 ? 32'h11ef44f1 :
        s_count == 37 ? 32'hbce107cf :
        s_count == 38 ? 32'ha45a06aa :
        s_count == 39 ? 32'hb360152b :
        s_count == 40 ? 32'h28dc1ebe :
        s_count == 41 ? 32'h6f7fe09b :
        s_count == 42 ? 32'h0516f9a5 :
        s_count == 43 ? 32'hb02a1bd8 :
        s_count == 44 ? 32'h4bb0181e :
        s_count == 45 ? 32'h2e89e19b :
        s_count == 46 ? 32'hd8125930 :
        s_count == 47 ? 32'hd178682f :
        s_count == 48 ? 32'h3862dc51 :
        s_count == 49 ? 32'hb636f04e :
        s_count == 50 ? 32'h720c47c3 :
        s_count == 51 ? 32'hce51ad70 :
        s_count == 52 ? 32'hd94b9b22 :
        s_count == 53 ? 32'h55fbae90 :
        s_count == 54 ? 32'h6549f499 :
        s_count == 55 ? 32'hf8c6d399 :
        s_count == 56 ? 32'h47ed5e5d :
        s_count == 57 ? 32'hf8e2def1 :
        s_count == 58 ? 32'h13253e7b :
        s_count == 59 ? 32'h08d0a76b :
        s_count == 60 ? 32'h6bfc68c8 :
        s_count == 61 ? 32'h12f375c7 :
        s_count == 62 ? 32'h9b8fe5fd :
        s_count == 63 ? 32'h85976aa6 :
        s_count == 64 ? 32'hd46b4a23 :
        s_count == 65 ? 32'h39d8ae51 :
        s_count == 66 ? 32'h47f680fb :
        s_count == 67 ? 32'he70f978b :
        s_count == 68 ? 32'h38effd7b :
        s_count == 69 ? 32'h2f7866a2 :
        s_count == 70 ? 32'h2554e193 :
        s_count == 71 ? 32'ha94e98a6 :
        s_count == 72 ? 32'h8b74bd25 :
        s_count == 73 ? 32'hbb2b3f5f :
        s_count == 74 ? 32'hb0a5fd59 :
        s_count == 75 ? 32'h887f9ab6 :
        s_count == 76 ? 32'h8159b717 :
        s_count == 77 ? 32'h8d5b7b67 :
        s_count == 78 ? 32'h7cb546bf :
        s_count == 79 ? 32'h41eadca2 :
        s_count == 80 ? 32'h16fc1085 :
        s_count == 81 ? 32'h0128f8bd :
        s_count == 82 ? 32'hef5c8d89 :
        s_count == 83 ? 32'hf96afa4f :
        s_count == 84 ? 32'ha8b54885 :
        s_count == 85 ? 32'h565ed838 :
        s_count == 86 ? 32'ha950fee5 :
        s_count == 87 ? 32'hf1c3b0a4 :
        s_count == 88 ? 32'hf6fb71e5 :
        s_count == 89 ? 32'h4dfd169e :
        s_count == 90 ? 32'h82cecc72 :
        s_count == 91 ? 32'h66c850e6 :
        s_count == 92 ? 32'h7c5ef0ba :
        s_count == 93 ? 32'h960f5214 :
        s_count == 94 ? 32'h060e71eb :
        s_count == 95 ? 32'h172a75fc :
        s_count == 96 ? 32'h1486835c :
        s_count == 97 ? 32'hbea65344 :
        s_count == 98 ? 32'h65b055c9 :
        s_count == 99 ? 32'h6a72e410 :
        s_count == 100 ? 32'h52241823 :
        s_count == 101 ? 32'h25d83041 :
        s_count == 102 ? 32'h4b40214d :
        s_count == 103 ? 32'haa8091d2 :
        s_count == 104 ? 32'he0fb010a :
        s_count == 105 ? 32'he15c6de9 :
        s_count == 106 ? 32'h0850973b :
        s_count == 107 ? 32'hdf1e423b :
        s_count == 108 ? 32'he148a237 :
        s_count == 109 ? 32'hb87a0c9f :
        s_count == 110 ? 32'h34d4b476 :
        s_count == 111 ? 32'h05b803d7 :
        s_count == 112 ? 32'h43a86a90 :
        s_count == 113 ? 32'h399a4af3 :
        s_count == 114 ? 32'h96d3a120 :
        s_count == 115 ? 32'h0a62f3d9 :
        s_count == 116 ? 32'h507962e8 :
        s_count == 117 ? 32'he5bee6d3 :
        s_count == 118 ? 32'hda2bb3f7 :
        s_count == 119 ? 32'h237664ac :
        s_count == 120 ? 32'h7a292823 :
        s_count == 121 ? 32'h900bc635 :
        s_count == 122 ? 32'h03b29e80 :
        s_count == 123 ? 32'hd63f6067 :
        s_count == 124 ? 32'hbf8e1716 :
        s_count == 125 ? 32'hac25beba :
        s_count == 126 ? 32'h350deb62 :
        s_count == 127 ? 32'ha99fe031 :
        s_count == 128 ? 32'h85eb4f69 :
        s_count == 129 ? 32'h937ecd38 :
        s_count == 130 ? 32'h7941fda5 :
        s_count == 131 ? 32'h44ba67db :
        s_count == 132 ? 32'h09117749 :
        s_count == 133 ? 32'h38b01827 :
        s_count == 134 ? 32'hbcc69c92 :
        s_count == 135 ? 32'hb3f772a9 :
        s_count == 136 ? 32'hd2859ef0 :
        s_count == 137 ? 32'h03398b1f :
        s_count == 138 ? 32'h6bbad7b5 :
        s_count == 139 ? 32'h74f7989a :
        s_count == 140 ? 32'h1d10b2df :
        s_count == 141 ? 32'h798e0dbf :
        s_count == 142 ? 32'h30d65874 :
        s_count == 143 ? 32'h64d24878 :
        s_count == 144 ? 32'hcd00c0ea :
        s_count == 145 ? 32'hee8a1a0c :
        s_count == 146 ? 32'hc753a279 :
        s_count == 147 ? 32'h79e11b41 :
        s_count == 148 ? 32'hdb1de3d5 :
        s_count == 149 ? 32'h038afaf4 :
        s_count == 150 ? 32'h9f5c682c :
        s_count == 151 ? 32'h3748d8a3 :
        s_count == 152 ? 32'ha9ec54e6 :
        s_count == 153 ? 32'ha371275f :
        s_count == 154 ? 32'h1683510f :
        s_count == 155 ? 32'h8e4f9093 :
        s_count == 156 ? 32'h8f9ab6e1 :
        s_count == 157 ? 32'h34c2cfdf :
        s_count == 158 ? 32'h4841cba8 :
        s_count == 159 ? 32'h8e0cff2b :
        s_count == 160 ? 32'h0bcc8e6a :
        s_count == 161 ? 32'hdcb71109 :
        s_count == 162 ? 32'hb5198fec :
        s_count == 163 ? 32'hf1bb7e5c :
        s_count == 164 ? 32'h531aca50 :
        s_count == 165 ? 32'ha56a8a3b :
        s_count == 166 ? 32'h6de59862 :
        s_count == 167 ? 32'hd41fa113 :
        s_count == 168 ? 32'hd9cd9578 :
        s_count == 169 ? 32'h08f08571 :
        s_count == 170 ? 32'hd9a4bb79 :
        s_count == 171 ? 32'h2af271f6 :
        s_count == 172 ? 32'hcc6dbb8d :
        s_count == 173 ? 32'hc7ec36e3 :
        s_count == 174 ? 32'h6be1ed30 :
        s_count == 175 ? 32'h8164c31c :
        s_count == 176 ? 32'h7c0afc54 :
        s_count == 177 ? 32'h1c000000 : 32'hx;

    assign s_keep = s_last ? 32'b11_1111 : {32{1'b1}};

    assign s_last = s_count == 177;

    always @(posedge clk) begin
        if (m_valid) begin
            assert(m_mac == 32'h0ca12792);
        end
    end

end endgenerate



reg r_ready = 0;
always @(posedge clk) begin
    r_ready <= $random;
end

assign m_ready = toggle_reception ? r_ready : 1;

generate if (debug_output) begin : debug_prints

    // TODO: replace with packet count
    always @(posedge clk) begin
        if (m_valid && m_ready) begin
            $display("%08x", m_mac);
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
