// SPDX-License-Identifier: GPL-2.0-only
// Copyright (C) 2025 Tristan Itschner
`default_nettype none
`timescale 1 ns / 1 ps

module zuc_eea3 #(
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
    input  wire [127:0] s_ctl_ck,

    input  wire          s_valid,
    output wire          s_ready,
    input  wire          s_last,
    input  wire [31:0]   s_data,
    input  wire [kw-1:0] s_keep,

    output wire          m_valid,
    input  wire          m_ready,
    output wire          m_last,
    output wire [31:0]   m_data,
    output wire [kw-1:0] m_keep
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
assign zc_s_ctl_iv[39:32] = {s_ctl_bearer,s_ctl_direction,2'b0};
assign zc_s_ctl_iv[47:40] = 8'h0;
assign zc_s_ctl_iv[55:48] = 8'h0;
assign zc_s_ctl_iv[63:56] = 8'h0;

assign zc_s_ctl_iv[64+7:64+0]   = s_ctl_count[31:24];
assign zc_s_ctl_iv[64+15:64+8]  = s_ctl_count[23:16];
assign zc_s_ctl_iv[64+23:64+16] = s_ctl_count[15:8];
assign zc_s_ctl_iv[64+31:64+24] = s_ctl_count[7:0];
assign zc_s_ctl_iv[64+39:64+32] = {s_ctl_bearer,s_ctl_direction,2'b0};
assign zc_s_ctl_iv[64+47:64+40] = 8'h0;
assign zc_s_ctl_iv[64+55:64+48] = 8'h0;
assign zc_s_ctl_iv[64+63:64+56] = 8'h0;

assign zc_s_ctl_key = s_ctl_ck;

/******************************************************************************/
// register stage

wire          rs_s_valid;
wire          rs_s_ready;

wire          rs_m_valid;
wire          rs_m_ready;
wire          rs_m_last;
wire [31:0]   rs_m_data;
wire [kw-1:0] rs_m_keep;

zuc_regslice #(
    .dw (1 + 32 + kw)
) zuc_regslice_inst (
    .clk (clk),
    .full    (),
    .flush   (1'b0),
    .s_valid (rs_s_valid),
    .s_ready (rs_s_ready),
    .s_data  ({s_last, s_data, s_keep}),
    .m_valid (rs_m_valid),
    .m_ready (rs_m_ready),
    .m_data  ({rs_m_last, rs_m_data, rs_m_keep})
);

/******************************************************************************/
// channel muxing

assign zc_s_ctl_valid = s_ctl_valid;
assign s_ctl_ready = zc_s_ctl_ready;

wire block_s = !(zc_s_ready && rs_s_ready);

assign zc_s_valid = s_valid && !block_s;
assign rs_s_valid = s_valid && !block_s;
assign s_ready = !block_s;

assign zc_s_last = s_last;
assign zc_s_user = 1'bx;

wire m_block = !(zc_m_valid && rs_m_valid);

assign m_valid = zc_m_valid && rs_m_valid;
assign rs_m_ready = !m_block && m_ready;
assign zc_m_ready = !m_block && m_ready;

function [31:0] mask(input [31:0] x, input [kw-1:0] keep);
    integer i;
    begin
        for (i = 0; i < kw; i = i + 1) begin
            if (keep[i]) begin
                mask[bw*(i+1)-1-:bw] = x[bw*(i+1)-1-:bw];
            end else begin
                mask[bw*(i+1)-1-:bw] = 8'h00;
            end
        end
    end
endfunction

assign m_data = mask(rs_m_data ^ zc_m_cipher, rs_m_keep);
assign m_keep = rs_m_keep;
assign m_last = rs_m_last;

endmodule
