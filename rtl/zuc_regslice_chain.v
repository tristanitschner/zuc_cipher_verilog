// SPDX-License-Identifier: GPL-2.0-only
// Copyright (C) 2025 Tristan Itschner
`default_nettype none
`timescale 1 ns / 1 ps

module zuc_regslice_chain #(
    parameter dw     = 32,
    parameter length = 10
) (
    input wire clk,

    output wire [length-1:0] full,

    input  wire          s_valid,
    output wire          s_ready,
    input  wire [dw-1:0] s_data,

    output wire          m_valid,
    input  wire          m_ready,
    output wire [dw-1:0] m_data
);

genvar gi;

wire          i_valid [0:length];
wire          i_ready [0:length];
wire [dw-1:0] i_data  [0:length];

assign i_valid[0] = s_valid;
assign s_ready    = i_ready[0];
assign i_data[0]  = s_data;

generate for (gi = 0; gi < length; gi = gi + 1) begin

    zuc_regslice #(
        .dw (dw)
    ) regslice_inst (
        .clk (clk),

        .flush (1'b0),
        .full  (full[gi]),

        .s_valid (i_valid [gi]),
        .s_ready (i_ready [gi]),
        .s_data  (i_data  [gi]),

        .m_valid (i_valid [gi+1]),
        .m_ready (i_ready [gi+1]),
        .m_data  (i_data  [gi+1])
    );

end endgenerate

assign m_valid         = i_valid[length];
assign i_ready[length] = m_ready;
assign m_data          = i_data[length];

endmodule
