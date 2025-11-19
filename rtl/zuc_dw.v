// SPDX-License-Identifier: GPL-2.0-only
// Copyright (C) 2025 Tristan Itschner
`default_nettype none
`timescale 1 ns / 1 ps

module zuc_dw (
    input wire clk,

    input  wire        s_valid,
    output wire        s_ready,
    input  wire        s_last,
    input  wire [31:0] s_data,

    output wire        m_valid,
    input  wire        m_ready,
    output wire        m_last,
    output wire [63:0] m_data
);

reg r_first = 1;
always @(posedge clk) begin
    if (s_valid && s_ready) begin
        r_first <= s_last;
    end
end

reg [31:0] r_data;
always @(posedge clk) begin
    if (s_valid && s_ready) begin
        r_data <= s_data;
    end
end

assign m_data = {r_data, s_data};

assign s_ready = r_first || m_ready;
assign m_valid = !r_first && s_valid;
assign m_last = s_last;

endmodule
