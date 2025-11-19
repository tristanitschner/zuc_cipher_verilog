// SPDX-License-Identifier: GPL-2.0-only
// Copyright (C) 2025 Tristan Itschner
`default_nettype none
`timescale 1 ns / 1 ps

module zuc_tb;

parameter sync             = 0;
parameter testcase         = 4;
parameter debug_trace      = 1;
parameter debug_output     = 0;
parameter toggle_reception = 1;

initial begin
    if (debug_trace) begin
        $dumpfile("zuc_tb.vcd");
        $dumpvars(0, zuc_tb);
    end
end

reg clk = 1;
initial forever #1 clk = !clk;

wire         s_valid;
wire         s_ready;
wire         s_init;
wire [127:0] s_iv;
wire [127:0] s_key;
wire         m_valid;
wire         m_ready;
wire [31:0]  m_data;

zuc #(
    .sbox_sync (sync)
) zuc_inst (
    .clk     (clk),
    .s_valid (s_valid),
    .s_ready (s_ready),
    .s_init  (s_init),
    .s_iv    (s_iv),
    .s_key   (s_key),
    .m_valid (m_valid),
    .m_ready (m_ready),
    .m_data  (m_data)
);

reg r_init = 0;
always @(posedge clk) begin
    if (!r_init) begin
        if (s_valid && s_ready) begin
            r_init <= 1;
        end
    end
end

assign s_init = !r_init;

assign s_valid = 1;

reg [31:0] m_count = 0;

always @(posedge clk) begin
    if (m_valid && m_ready) begin
        m_count <= m_count + 1;
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

    assign s_key = 0;
    assign s_iv  = 0;

    always @(posedge clk) begin
        if (m_valid) begin
            if (m_count == 0) assert(m_data == 32'h27bede74);
            if (m_count == 1) assert(m_data == 32'h018082da);
        end
    end

end endgenerate

/******************************************************************************/
generate if (testcase == 2) begin : testcase_2

    assign s_key = {128{1'b1}};
    assign s_iv  = {128{1'b1}};

    always @(posedge clk) begin
        if (m_valid) begin
            if (m_count == 0) assert(m_data == 32'h0657cfa0);
            if (m_count == 1) assert(m_data == 32'h7096398b);
        end
    end

end endgenerate

/******************************************************************************/
generate if (testcase == 3) begin : testcase_3

    assign s_key = bswap128(128'h3d_4c_4b_e9_6a_82_fd_ae_b5_8f_64_1d_b1_7b_45_5b);
    assign s_iv  = bswap128(128'h84_31_9a_a8_de_69_15_ca_1f_6b_da_6b_fb_d8_c7_66);

    always @(posedge clk) begin
        if (m_valid) begin
            if (m_count == 0) assert(m_data == 32'h14f1c272);
            if (m_count == 1) assert(m_data == 32'h3279c419);
        end
    end

end endgenerate

/******************************************************************************/
generate if (testcase == 4) begin : testcase_4

    assign s_key = bswap128(128'h4d_32_0b_fa_d4_c2_85_bf_d6_b8_bd_00_f3_9d_8b_41);
    assign s_iv  = bswap128(128'h52_95_9d_ab_a0_bf_17_6e_ce_2d_c3_15_04_9e_b5_74);

    always @(posedge clk) begin
        if (m_valid) begin
            if (m_count == 0)    assert(m_data == 32'hed4400e7);
            if (m_count == 1)    assert(m_data == 32'h0633e5c5);
            if (m_count == 1999) assert(m_data == 32'h7a574cdb);
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
    end

end endgenerate

initial begin
    #10000;
    $display("Received %d words.", m_count);
    $finish;
end

endmodule
