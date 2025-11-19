// SPDX-License-Identifier: GPL-2.0-only
// Copyright (C) 2025 Tristan Itschner
`default_nettype none
`timescale 1 ns / 1 ps

module zuc_ctl #(
    parameter sbox_ram_style = "distributed",
    parameter sbox_sync = 0,
    parameter uw = 1
) (
    input wire clk,

    input  wire          s_ctl_valid,
    output wire          s_ctl_ready,
    input  wire [127:0]  s_ctl_iv,
    input  wire [127:0]  s_ctl_key,

    input  wire          s_valid,
    output wire          s_ready,
    input  wire          s_last,
    input  wire [uw-1:0] s_user,

    output wire          m_valid,
    input  wire          m_ready,
    output wire [31:0]   m_cipher,
    output wire [uw-1:0] m_user
);

wire          zuc_s_valid;
wire          zuc_s_ready;
wire          zuc_s_init;
wire [127:0]  zuc_s_iv;
wire [127:0]  zuc_s_key;
wire [uw-1:0] zuc_s_user;
wire          zuc_m_valid;
wire          zuc_m_ready;
wire [31:0]   zuc_m_data;
wire [uw-1:0] zuc_m_user;

zuc #(
    .sbox_ram_style (sbox_ram_style),
    .sbox_sync      (sbox_sync),
    .uw             (uw)
) zuc_inst(
    .clk (clk),
    .s_valid (zuc_s_valid),
    .s_ready (zuc_s_ready),
    .s_init  (zuc_s_init),
    .s_iv    (zuc_s_iv),
    .s_key   (zuc_s_key),
    .s_user  (zuc_s_user),
    .m_valid (zuc_m_valid),
    .m_ready (zuc_m_ready),
    .m_data  (zuc_m_data),
    .m_user  (zuc_m_user)
);

reg r_ctl = 1;
always @(posedge clk) begin
    if (r_ctl) begin
        if (s_ctl_valid && s_ctl_ready) begin
            r_ctl <= 0;
        end
    end else begin
        if (s_valid && s_ready && s_last) begin
            r_ctl <= 1;
        end
    end
end

assign zuc_s_valid = r_ctl ? s_ctl_valid : s_valid;
assign s_ctl_ready = r_ctl && zuc_s_ready;
assign s_ready = !r_ctl && zuc_s_ready;
assign zuc_s_init = r_ctl;
assign zuc_s_iv = s_ctl_iv;
assign zuc_s_key = s_ctl_key;
assign zuc_s_user = s_user;

assign m_valid = zuc_m_valid;
assign zuc_m_ready = m_ready;
assign m_cipher = zuc_m_data;
assign m_user = zuc_m_user;

endmodule
