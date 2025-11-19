// SPDX-License-Identifier: GPL-2.0-only
// Copyright (C) 2025 Tristan Itschner
`default_nettype none
`timescale 1 ns / 1 ps

module zuc_regslice #(
    parameter dw = 10
) (
    input wire clk,

    output wire full,
    input  wire flush,

    input  wire          s_valid,
    output wire          s_ready,
    input  wire [dw-1:0] s_data,

    output wire          m_valid,
    input  wire          m_ready,
    output wire [dw-1:0] m_data
);

wire s_fire = s_valid && s_ready;
wire m_fire = m_valid && m_ready;

reg r_valid = 0;

always @(posedge clk) begin
    case ({s_fire, m_fire})
        2'b10: r_valid <= 1;
        2'b01: r_valid <= 0;
        default: ;
    endcase
    if (flush) begin
        r_valid <= 0;
    end
end

assign m_valid = r_valid;
assign s_ready = !r_valid || (r_valid && m_fire);
assign full = r_valid;

reg [dw-1:0] r_data = 0;

always @(posedge clk) begin
    if (s_fire) begin
        r_data <= s_data;
    end
end

assign m_data = r_data;

endmodule
