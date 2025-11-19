// SPDX-License-Identifier: GPL-2.0-only
// Copyright (C) 2025 Tristan Itschner
`default_nettype none
`timescale 1 ns / 1 ps

module zuc #(
    parameter sbox_ram_style = "auto",
    parameter sbox_sync      = 1,
    parameter uw             = 1
) (
    input wire clk,

    input  wire          s_valid,
    output wire          s_ready,
    input  wire          s_init,
    input  wire [127:0]  s_iv,
    input  wire [127:0]  s_key,
    input  wire [uw-1:0] s_user,

    output wire          m_valid,
    input  wire          m_ready,
    output wire [31:0]   m_data,
    output wire [uw-1:0] m_user
);

integer i, j;
genvar gi;

reg [30:0] lfsr [0:15];
initial for (i = 0; i < 16; i = i + 1) lfsr[i] = 0;

wire [31:0] f_r1;
wire [31:0] f_r2;

reg r_init = 0;

wire [15:0] ek_d[0:15];
assign ek_d[0]  = 16'h44D7;
assign ek_d[1]  = 16'h26BC;
assign ek_d[2]  = 16'h626B;
assign ek_d[3]  = 16'h135E;
assign ek_d[4]  = 16'h5789;
assign ek_d[5]  = 16'h35E2;
assign ek_d[6]  = 16'h7135;
assign ek_d[7]  = 16'h09AF;
assign ek_d[8]  = 16'h4D78;
assign ek_d[9]  = 16'h2F13;
assign ek_d[10] = 16'h6BC4;
assign ek_d[11] = 16'h1AF1;
assign ek_d[12] = 16'h5E26;
assign ek_d[13] = 16'h3C4D;
assign ek_d[14] = 16'h789A;
assign ek_d[15] = 16'h47AC;

function [30:0] rot31(input [30:0] x, input [4:0] k);
    rot31 = (((x) << k) | ((x) >> (31 - k))) ;
endfunction

wire [30:0] f0 = lfsr[0];
wire [30:0] v0 = rot31(lfsr[0], 8);
wire [30:0] v1 = rot31(lfsr[4], 20);
wire [30:0] v2 = rot31(lfsr[10], 21);
wire [30:0] v3 = rot31(lfsr[13], 17);
wire [30:0] v4 = rot31(lfsr[15], 15);

wire [30:0] u;

wire [30:0] f_total_mod;

generate if (0) begin : gen_tree

    wire [30:0] temp0;
    wire        carry0;
    wire [30:0] temp1;
    wire        carry1;
    wire [30:0] temp2;
    wire        carry2;
    wire [30:0] temp3;

    assign {carry0, temp0} = f0 + v0;
    assign {carry1, temp1} = v1 + v2;
    assign {carry2, temp2} = v3 + v4;
    assign temp3 = r_init ? u : 0;

    wire [30:0] temp4;
    wire        carry4;
    wire [30:0] temp5;
    wire        carry5;

    assign {carry4, temp4} = temp0 + temp1 + carry0 + carry1;
    assign {carry5, temp5} = temp2 + temp3 + carry2;

    wire [30:0] temp6;
    wire        carry6;

    assign {carry6, temp6} = temp4 + temp5 + carry4 + carry5;

    assign f_total_mod = temp6 + carry6;

end else begin : gen_alt

    wire [2:0] carry;
    wire [30:0] sum;

    assign {carry, sum} = f0 + v0 + v1 + v2 + v3 + v4;

    wire carry2;
    wire [30:0] sum2;

    assign {carry2, sum2} = sum + carry + (r_init ? u : 0);

    assign f_total_mod = sum2 + carry2;

end endgenerate

wire [31:0] brc_x [0:3];

assign brc_x[0] = (({1'b0,lfsr[15]} & 32'h7FFF8000) << 1)  | ({1'b0,lfsr[14]} &  32'hFFFF);
assign brc_x[1] = (({1'b0,lfsr[11]} & 32'hFFFF)     << 16) | ({1'b0,lfsr[9]}  >> 15);
assign brc_x[2] = (({1'b0,lfsr[7]}  & 32'hFFFF)     << 16) | ({1'b0,lfsr[5]}  >> 15);
assign brc_x[3] = (({1'b0,lfsr[2]}  & 32'hFFFF)     << 16) | ({1'b0,lfsr[0]}  >> 15);

function [31:0] rot(input [31:0] a, input [4:0] k);
    rot = (((a) << k) | ((a) >> (32 - k)));
endfunction

function [31:0] l1(input [31:0] X);
    l1 =  (X ^ rot(X, 2) ^ rot(X, 10) ^ rot(X, 18) ^ rot(X, 24));
endfunction

function [31:0] l2(input [31:0] X);
    l2 = (X ^ rot(X, 8) ^ rot(X, 14) ^ rot(X, 22) ^ rot(X, 30));
endfunction

function [31:0] makeu32(input [7:0] a, input [7:0] b, input [7:0] c, input [7:0] d);
    makeu32 = {a, b, c, d};
endfunction

function [30:0] makeu31(input [7:0] a, input [15:0] b, input [7:0] c);
    makeu31 = (((a) << 23) | ((b) << 8) | (c));
endfunction

wire [31:0] f, w, w1, w2, x, y;

assign w = (brc_x[0] ^ f_r1) + f_r2;
assign w1 = f_r1 + brc_x[1];
assign w2 = f_r2 ^ brc_x[2];
assign x = l1((w1 << 16) | (w2 >> 16));
assign y = l2((w2 << 16) | (w1 >> 16));

wire sbox_rd;

wire [7:0] f_r1_s0_x0 = x[31:24];
wire [7:0] f_r1_s0_y0;
wire [7:0] f_r1_s0_x1 = x[15:8];
wire [7:0] f_r1_s0_y1;

zuc_s0 # (
    .ram_style (sbox_ram_style),
    .sync      (sbox_sync)
) zuc_s0_r1_inst (
    .clk (clk),
    .rd  (sbox_rd),
    .x0  (f_r1_s0_x0),
    .y0  (f_r1_s0_y0),
    .x1  (f_r1_s0_x1),
    .y1  (f_r1_s0_y1)
);

wire [7:0] f_r1_s1_x0 = x[23:16];
wire [7:0] f_r1_s1_y0;
wire [7:0] f_r1_s1_x1 = x[7:0];
wire [7:0] f_r1_s1_y1;

zuc_s1 # (
    .ram_style (sbox_ram_style),
    .sync      (sbox_sync)
) zuc_s1_r1_inst (
    .clk (clk),
    .rd  (sbox_rd),
    .x0  (f_r1_s1_x0),
    .y0  (f_r1_s1_y0),
    .x1  (f_r1_s1_x1),
    .y1  (f_r1_s1_y1)
);

wire [31:0] f_r1_next = makeu32(f_r1_s0_y0, f_r1_s1_y0, f_r1_s0_y1, f_r1_s1_y1);

wire [7:0] f_r2_s0_x0 = y[31:24];
wire [7:0] f_r2_s0_y0;
wire [7:0] f_r2_s0_x1 = y[15:8];
wire [7:0] f_r2_s0_y1;

zuc_s0 # (
    .ram_style (sbox_ram_style),
    .sync      (sbox_sync)
) zuc_s0_r2_inst (
    .clk (clk),
    .rd  (sbox_rd),
    .x0  (f_r2_s0_x0),
    .y0  (f_r2_s0_y0),
    .x1  (f_r2_s0_x1),
    .y1  (f_r2_s0_y1)
);

wire [7:0] f_r2_s1_x0 = y[23:16];
wire [7:0] f_r2_s1_y0;
wire [7:0] f_r2_s1_x1 = y[7:0];
wire [7:0] f_r2_s1_y1;

zuc_s1 # (
    .ram_style (sbox_ram_style),
    .sync      (sbox_sync)
) zuc_s1_r2_inst (
    .clk (clk),
    .rd  (sbox_rd),
    .x0  (f_r2_s1_x0),
    .y0  (f_r2_s1_y0),
    .x1  (f_r2_s1_x1),
    .y1  (f_r2_s1_y1)
);

wire [31:0] f_r2_next = makeu32(f_r2_s0_y0, f_r2_s1_y0, f_r2_s0_y1, f_r2_s1_y1);

assign f = w;

assign u = f[31:1];

/******************************************************************************/
// init logic

wire do_init;
wire init_done;
always @(posedge clk) begin
    if (init_done) begin
        r_init <= 0;
    end
    if (do_init) begin
        r_init <= 1;
    end
end

reg [4:0] init_counter = 0;
always @(posedge clk) begin
    init_counter <= init_counter + 1;
    if (do_init) begin
        init_counter <= 0;
    end
end

assign do_init = s_valid && s_ready && s_init;
assign init_done = &(init_counter);

/******************************************************************************/
// stage logic

wire s_fire = s_valid && s_ready;
wire m_fire = m_valid && m_ready;

reg r_valid = 0;
always @(posedge clk) begin
    case ({s_fire, m_fire})
        2'b10: r_valid <= 1;
        2'b01: r_valid <= 0;
    endcase
    if (do_init || r_init) begin
        r_valid <= 0;
    end
end

reg [uw-1:0] r_user;
always @(posedge clk) begin
    if (s_fire) begin
        r_user <= s_user;
    end
end

assign s_ready = (!r_valid || (r_valid && m_fire)) && !r_init;
assign m_valid = r_valid;
assign m_user = r_user;

/******************************************************************************/
// lfsr logic

wire [7:0] iv  [0:15];
wire [7:0] key [0:15];

generate for (gi = 0; gi < 16; gi = gi + 1) begin
    assign iv  [gi] = s_iv  [8*(gi+1)-1-:8];
    assign key [gi] = s_key [8*(gi+1)-1-:8];
end endgenerate


always @(posedge clk) begin
    if  (do_init) begin
        for (j = 0; j < 16; j = j + 1) begin
            lfsr[j] <= makeu31(key[j], ek_d[j], iv[j]);
        end
    end else if (r_init || s_fire) begin
        for (j = 0; j < 15; j = j + 1) begin
            lfsr[j] <= lfsr[j+1];
        end
        lfsr[15] <= f_total_mod;
    end
end

/******************************************************************************/
// f_r logic

generate if (sbox_sync) begin : gen_sync

    reg [31:0] c_f_r1; /* wire */
    reg [31:0] c_f_r2; /* wire */

    assign sbox_rd = r_init || s_fire;

    always @(*) begin
        if (r_init && !(|(init_counter))) begin
            c_f_r1 = 0;
            c_f_r2 = 0;
        end else begin
            c_f_r1 = f_r1_next;
            c_f_r2 = f_r2_next;
        end
    end

    assign f_r1 = c_f_r1;
    assign f_r2 = c_f_r2;

end else begin : gen_async

    reg [31:0] r_f_r1;
    reg [31:0] r_f_r2;

    always @(posedge clk) begin
        if (do_init) begin
            r_f_r1 <= 0;
            r_f_r2 <= 0;
        end else if (r_init || s_fire) begin
            r_f_r1 <= f_r1_next;
            r_f_r2 <= f_r2_next;
        end
    end

    assign f_r1 = r_f_r1;
    assign f_r2 = r_f_r2;

end endgenerate

/******************************************************************************/
// output data

assign m_data = f ^ brc_x[3];

endmodule
