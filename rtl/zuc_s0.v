// SPDX-License-Identifier: GPL-2.0-only
// Copyright (C) 2025 Tristan Itschner
`default_nettype none
`timescale 1 ns / 1 ps

module zuc_s0 # (
    parameter ram_style = "distributed",
    parameter sync = 1
) (
    input wire clk,
    input wire rd,
    input  wire [7:0] x0,
    output wire [7:0] y0,
    input  wire [7:0] x1,
    output wire [7:0] y1
);

(* ram_style = ram_style *)
reg [7:0] mem [0:255];

initial begin
    mem[0]   = 8'h3e; mem[1]   = 8'h72; mem[2]   = 8'h5b; mem[3]   = 8'h47; mem[4]   = 8'hca; mem[5]   = 8'he0; mem[6]   = 8'h00; mem[7]   = 8'h33;
    mem[8]   = 8'h04; mem[9]   = 8'hd1; mem[10]  = 8'h54; mem[11]  = 8'h98; mem[12]  = 8'h09; mem[13]  = 8'hb9; mem[14]  = 8'h6d; mem[15]  = 8'hcb;
    mem[16]  = 8'h7b; mem[17]  = 8'h1b; mem[18]  = 8'hf9; mem[19]  = 8'h32; mem[20]  = 8'haf; mem[21]  = 8'h9d; mem[22]  = 8'h6a; mem[23]  = 8'ha5;
    mem[24]  = 8'hb8; mem[25]  = 8'h2d; mem[26]  = 8'hfc; mem[27]  = 8'h1d; mem[28]  = 8'h08; mem[29]  = 8'h53; mem[30]  = 8'h03; mem[31]  = 8'h90;
    mem[32]  = 8'h4d; mem[33]  = 8'h4e; mem[34]  = 8'h84; mem[35]  = 8'h99; mem[36]  = 8'he4; mem[37]  = 8'hce; mem[38]  = 8'hd9; mem[39]  = 8'h91;
    mem[40]  = 8'hdd; mem[41]  = 8'hb6; mem[42]  = 8'h85; mem[43]  = 8'h48; mem[44]  = 8'h8b; mem[45]  = 8'h29; mem[46]  = 8'h6e; mem[47]  = 8'hac;
    mem[48]  = 8'hcd; mem[49]  = 8'hc1; mem[50]  = 8'hf8; mem[51]  = 8'h1e; mem[52]  = 8'h73; mem[53]  = 8'h43; mem[54]  = 8'h69; mem[55]  = 8'hc6;
    mem[56]  = 8'hb5; mem[57]  = 8'hbd; mem[58]  = 8'hfd; mem[59]  = 8'h39; mem[60]  = 8'h63; mem[61]  = 8'h20; mem[62]  = 8'hd4; mem[63]  = 8'h38;
    mem[64]  = 8'h76; mem[65]  = 8'h7d; mem[66]  = 8'hb2; mem[67]  = 8'ha7; mem[68]  = 8'hcf; mem[69]  = 8'hed; mem[70]  = 8'h57; mem[71]  = 8'hc5;
    mem[72]  = 8'hf3; mem[73]  = 8'h2c; mem[74]  = 8'hbb; mem[75]  = 8'h14; mem[76]  = 8'h21; mem[77]  = 8'h06; mem[78]  = 8'h55; mem[79]  = 8'h9b;
    mem[80]  = 8'he3; mem[81]  = 8'hef; mem[82]  = 8'h5e; mem[83]  = 8'h31; mem[84]  = 8'h4f; mem[85]  = 8'h7f; mem[86]  = 8'h5a; mem[87]  = 8'ha4;
    mem[88]  = 8'h0d; mem[89]  = 8'h82; mem[90]  = 8'h51; mem[91]  = 8'h49; mem[92]  = 8'h5f; mem[93]  = 8'hba; mem[94]  = 8'h58; mem[95]  = 8'h1c;
    mem[96]  = 8'h4a; mem[97]  = 8'h16; mem[98]  = 8'hd5; mem[99]  = 8'h17; mem[100] = 8'ha8; mem[101] = 8'h92; mem[102] = 8'h24; mem[103] = 8'h1f;
    mem[104] = 8'h8c; mem[105] = 8'hff; mem[106] = 8'hd8; mem[107] = 8'hae; mem[108] = 8'h2e; mem[109] = 8'h01; mem[110] = 8'hd3; mem[111] = 8'had;
    mem[112] = 8'h3b; mem[113] = 8'h4b; mem[114] = 8'hda; mem[115] = 8'h46; mem[116] = 8'heb; mem[117] = 8'hc9; mem[118] = 8'hde; mem[119] = 8'h9a;
    mem[120] = 8'h8f; mem[121] = 8'h87; mem[122] = 8'hd7; mem[123] = 8'h3a; mem[124] = 8'h80; mem[125] = 8'h6f; mem[126] = 8'h2f; mem[127] = 8'hc8;
    mem[128] = 8'hb1; mem[129] = 8'hb4; mem[130] = 8'h37; mem[131] = 8'hf7; mem[132] = 8'h0a; mem[133] = 8'h22; mem[134] = 8'h13; mem[135] = 8'h28;
    mem[136] = 8'h7c; mem[137] = 8'hcc; mem[138] = 8'h3c; mem[139] = 8'h89; mem[140] = 8'hc7; mem[141] = 8'hc3; mem[142] = 8'h96; mem[143] = 8'h56;
    mem[144] = 8'h07; mem[145] = 8'hbf; mem[146] = 8'h7e; mem[147] = 8'hf0; mem[148] = 8'h0b; mem[149] = 8'h2b; mem[150] = 8'h97; mem[151] = 8'h52;
    mem[152] = 8'h35; mem[153] = 8'h41; mem[154] = 8'h79; mem[155] = 8'h61; mem[156] = 8'ha6; mem[157] = 8'h4c; mem[158] = 8'h10; mem[159] = 8'hfe;
    mem[160] = 8'hbc; mem[161] = 8'h26; mem[162] = 8'h95; mem[163] = 8'h88; mem[164] = 8'h8a; mem[165] = 8'hb0; mem[166] = 8'ha3; mem[167] = 8'hfb;
    mem[168] = 8'hc0; mem[169] = 8'h18; mem[170] = 8'h94; mem[171] = 8'hf2; mem[172] = 8'he1; mem[173] = 8'he5; mem[174] = 8'he9; mem[175] = 8'h5d;
    mem[176] = 8'hd0; mem[177] = 8'hdc; mem[178] = 8'h11; mem[179] = 8'h66; mem[180] = 8'h64; mem[181] = 8'h5c; mem[182] = 8'hec; mem[183] = 8'h59;
    mem[184] = 8'h42; mem[185] = 8'h75; mem[186] = 8'h12; mem[187] = 8'hf5; mem[188] = 8'h74; mem[189] = 8'h9c; mem[190] = 8'haa; mem[191] = 8'h23;
    mem[192] = 8'h0e; mem[193] = 8'h86; mem[194] = 8'hab; mem[195] = 8'hbe; mem[196] = 8'h2a; mem[197] = 8'h02; mem[198] = 8'he7; mem[199] = 8'h67;
    mem[200] = 8'he6; mem[201] = 8'h44; mem[202] = 8'ha2; mem[203] = 8'h6c; mem[204] = 8'hc2; mem[205] = 8'h93; mem[206] = 8'h9f; mem[207] = 8'hf1;
    mem[208] = 8'hf6; mem[209] = 8'hfa; mem[210] = 8'h36; mem[211] = 8'hd2; mem[212] = 8'h50; mem[213] = 8'h68; mem[214] = 8'h9e; mem[215] = 8'h62;
    mem[216] = 8'h71; mem[217] = 8'h15; mem[218] = 8'h3d; mem[219] = 8'hd6; mem[220] = 8'h40; mem[221] = 8'hc4; mem[222] = 8'he2; mem[223] = 8'h0f;
    mem[224] = 8'h8e; mem[225] = 8'h83; mem[226] = 8'h77; mem[227] = 8'h6b; mem[228] = 8'h25; mem[229] = 8'h05; mem[230] = 8'h3f; mem[231] = 8'h0c;
    mem[232] = 8'h30; mem[233] = 8'hea; mem[234] = 8'h70; mem[235] = 8'hb7; mem[236] = 8'ha1; mem[237] = 8'he8; mem[238] = 8'ha9; mem[239] = 8'h65;
    mem[240] = 8'h8d; mem[241] = 8'h27; mem[242] = 8'h1a; mem[243] = 8'hdb; mem[244] = 8'h81; mem[245] = 8'hb3; mem[246] = 8'ha0; mem[247] = 8'hf4;
    mem[248] = 8'h45; mem[249] = 8'h7a; mem[250] = 8'h19; mem[251] = 8'hdf; mem[252] = 8'hee; mem[253] = 8'h78; mem[254] = 8'h34; mem[255] = 8'h60;
end

generate if (sync) begin : gen_sync

    reg [7:0] r_mem0;
    reg [7:0] r_mem1;

    always @(posedge clk) begin
        if (rd) begin
            r_mem0 <= mem[x0];
            r_mem1 <= mem[x1];
        end
    end

    assign y0 = r_mem0;
    assign y1 = r_mem1;

end else begin : gen_async

    assign y0 = mem[x0];
    assign y1 = mem[x1];

end endgenerate

endmodule
