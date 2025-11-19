// SPDX-License-Identifier: GPL-2.0-only
// Copyright (C) 2025 Tristan Itschner
`default_nettype none
`timescale 1 ns / 1 ps

module zuc_eia3 #(
    parameter sbox_ram_style = "distributed",
    parameter sbox_sync = 0,
    parameter bw = 8,
    localparam kw = 32/bw
) (
    input wire clk,

    input  wire         s_ctl_valid,
    output wire         s_ctl_ready,
    input  wire [31:0]  s_ctl_count,
    input  wire [4:0]   s_ctl_bearer,
    input  wire         s_ctl_direction,
    input  wire [127:0] s_ctl_ik,

    input  wire          s_valid,
    output wire          s_ready,
    input  wire          s_last,
    input  wire [31:0]   s_data,
    input  wire [kw-1:0] s_keep,

    output wire        m_valid,
    input  wire        m_ready,
    output wire [31:0] m_mac
);

localparam uw = 1;

wire          zc_s_ctl_valid;
wire          zc_s_ctl_ready;
wire [127:0]  zc_s_ctl_iv;
wire [127:0]  zc_s_ctl_key;
wire          zc_s_valid;
wire          zc_s_ready;
wire          zc_s_last;
wire [uw-1:0] zc_s_user;
wire          zc_m_valid;
wire          zc_m_ready;
wire [31:0]   zc_m_cipher;
wire [uw-1:0] zc_m_user;

zuc_ctl #(
    .sbox_ram_style (sbox_ram_style),
    .sbox_sync      (sbox_sync),
    .uw             (uw)
) zuc_ctl (
    .clk (clk),
    .s_ctl_valid (zc_s_ctl_valid),
    .s_ctl_ready (zc_s_ctl_ready),
    .s_ctl_iv    (zc_s_ctl_iv),
    .s_ctl_key   (zc_s_ctl_key),
    .s_valid     (zc_s_valid),
    .s_ready     (zc_s_ready),
    .s_last      (zc_s_last),
    .s_user      (zc_s_user),
    .m_valid     (zc_m_valid),
    .m_ready     (zc_m_ready),
    .m_cipher    (zc_m_cipher),
    .m_user      (zc_m_user)
);

assign zc_s_ctl_iv[7:0]   = s_ctl_count[31:24];
assign zc_s_ctl_iv[15:8]  = s_ctl_count[23:16];
assign zc_s_ctl_iv[23:16] = s_ctl_count[15:8];
assign zc_s_ctl_iv[31:24] = s_ctl_count[7:0];
assign zc_s_ctl_iv[39:32] = {s_ctl_bearer,1'b0,2'b0};
assign zc_s_ctl_iv[47:40] = 8'h0;
assign zc_s_ctl_iv[55:48] = 8'h0;
assign zc_s_ctl_iv[63:56] = 8'h0;

assign zc_s_ctl_iv[64+7:64+0]   = s_ctl_count[31:24] ^ {s_ctl_direction, 7'b0};
assign zc_s_ctl_iv[64+15:64+8]  = s_ctl_count[23:16];
assign zc_s_ctl_iv[64+23:64+16] = s_ctl_count[15:8];
assign zc_s_ctl_iv[64+31:64+24] = s_ctl_count[7:0];
assign zc_s_ctl_iv[64+39:64+32] = {s_ctl_bearer,1'b0,2'b0};
assign zc_s_ctl_iv[64+47:64+40] = 8'h0;
assign zc_s_ctl_iv[64+55:64+48] = {s_ctl_direction,7'h0};
assign zc_s_ctl_iv[64+63:64+56] = 8'h0;

assign zc_s_ctl_key = s_ctl_ik;

assign zc_s_ctl_valid = s_ctl_valid;
assign s_ctl_ready = zc_s_ctl_ready;

reg r_s_extra = 0;
reg r_s_extra2 = 0;

always @(posedge clk) begin
    if (zc_s_valid && zc_s_ready) begin
        r_s_extra <= s_valid && s_ready && s_last;
        r_s_extra2 <= r_s_extra;
    end
end

wire extra = r_s_extra || r_s_extra2;

wire block_s;

assign zc_s_valid = extra || (s_valid && !block_s);
assign s_ready = !extra && (zc_s_ready && !block_s);
assign zc_s_last = r_s_extra2;
assign zc_s_user = r_s_extra2;

wire zrd_ready;

wire          i_m_valid;
wire          i_m_ready;
wire          i_m_last;
wire [31:0]   i_m_data;
wire [kw-1:0] i_m_keep;

zuc_regslice_chain #(
    .dw     (1 + 32 + kw),
    .length (2)
) zuc_regslice_inst_data (
    .clk (clk),
    .full    (),
    .s_valid (s_valid && s_ready),
    .s_ready (zrd_ready),
    .s_data  ({s_last, s_data, s_keep}),
    .m_valid (i_m_valid),
    .m_ready (i_m_ready),
    .m_data  ({i_m_last, i_m_data, i_m_keep})
);

assign block_s = !zrd_ready;

/******************************************************************************/

wire        dw_m_valid;
wire        dw_m_ready;
wire        dw_m_last;
wire [63:0] dw_m_data;

zuc_dw zuc_dw_inst (
    .clk (clk),
    .s_valid (zc_m_valid),
    .s_ready (zc_m_ready),
    .s_last  (zc_m_user),
    .s_data  (zc_m_cipher),
    .m_valid (dw_m_valid),
    .m_ready (dw_m_ready),
    .m_last  (dw_m_last),
    .m_data  (dw_m_data)
);

wire both_valid = i_m_valid && dw_m_valid;

reg [31:0] t = 0;

integer i;
reg [31:0] t_next; /* wire */

reg [$clog2(kw)-1:0] keep_count;
always @(*) begin
    keep_count = 0;
    for (i = 0; i < kw; i = i + 1) begin
        if (i_m_keep[i]) begin
            keep_count = keep_count + 1;
        end
    end
end

always @(*) begin
    t_next = t;
    for (i = 0; i < 32; i = i + 1) begin
        if (i_m_data[31-i]) begin
            t_next = t_next ^ (dw_m_data >> (32-i));
        end
    end
    if (i_m_last) begin
        t_next = t_next ^ (dw_m_data >> (32-(keep_count*bw))); // TODO
    end
    if (dw_m_last) begin
        t_next = t;
        t_next = t_next ^ dw_m_data;
    end
end

always @(posedge clk) begin
    if (both_valid) begin
        t <= t_next;
    end
    if (m_valid && m_ready) begin
        t <= 0;
    end
end

assign m_valid = dw_m_last && dw_m_valid;
assign m_mac = t_next;

assign i_m_ready = both_valid;
assign dw_m_ready = dw_m_last ? m_ready : both_valid;

endmodule
