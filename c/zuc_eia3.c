/*
 * NOTE: this code is based on sample code from:
 *
 * Specification of the 3GPP Confidentiality and Integrity Algorithms 128-EEA3 &
 * 128-EIA3.
 * Document 1: 128-EEA3 and 128-EIA3 Specifications.
 * Specification of the 3GPP Confidentiality and Integrity Algorithms 128-EEA3 &
 * 128-EIA3.
 * Document 2: ZUC Specification.
 * Specification of the 3GPP Confidentiality and Integrity Algorithms 128-EEA3 &
 * 128-EIA3.
 * Document 3: Implementor’s Test Data.
 */

#include "libzuc.c"

#include <stdlib.h>
#include <stdio.h>

typedef unsigned char u8;
typedef unsigned int u32;

u32 GET_WORD(u32 * DATA, u32 i)
{
	u32 WORD, ti;
	ti = i % 32;
	if (ti == 0) {
		WORD = DATA[i/32];
	}
	else {
		WORD = (DATA[i/32]<<ti) | (DATA[i/32+1]>>(32-ti));
	}
	return WORD;
}

u8 GET_BIT(u32 * DATA, u32 i)
{
	return (DATA[i/32] & (1<<(31-(i%32)))) ? 1 : 0;
}

void EIA3(u8* IK,u32 COUNT,u32 DIRECTION,u32 BEARER,u32 LENGTH,u32* M,u32* MAC)
{
	u32 *z, N, L, T, i;
	u8 IV[16];
	IV[0] = (COUNT>>24) & 0xFF;
	IV[1] = (COUNT>>16) & 0xFF;
	IV[2] = (COUNT>>8) & 0xFF;
	IV[3] = COUNT & 0xFF;
	IV[4] = (BEARER << 3) & 0xF8;
	IV[5] = IV[6] = IV[7] = 0;

	IV[8] = ((COUNT>>24) & 0xFF) ^ ((DIRECTION&1)<<7);
	IV[9] = (COUNT>>16) & 0xFF;
	IV[10] = (COUNT>>8) & 0xFF;
	IV[11] = COUNT & 0xFF;
	IV[12] = IV[4];
	IV[13] = IV[5];
	IV[14] = IV[6] ^ ((DIRECTION&1)<<7);
	IV[15] = IV[7];
	N = LENGTH + 64;
	L = (N + 31) / 32;
	z = (u32 *) malloc(L*sizeof(u32));
	ZUC(IK, IV, z, L);
	T = 0;
	for (i=0; i<LENGTH; i++) {
		if (GET_BIT(M,i)) {
			T ^= GET_WORD(z,i);
			printf("%u: or with %08x\n", i, T);
		}
	}
	T ^= GET_WORD(z,LENGTH);
	printf("f1: or with %08x\n", T);
	*MAC = T ^ z[L-1];
	printf("f2: or with %08x\n", *MAC);
	free(z);
}

int main() {

	/*
	u8 ik[16] = {0xc9, 0xe6, 0xce, 0xc4, 0x60, 0x7c, 0x72, 0xdb, 0x00, 0x0a, 0xef, 0xa8, 0x83, 0x85, 0xab, 0x0a};
	u32 count = 0xa94059da;
	u32 direction = 1;
	u32 bearer = 0xa;
	u32 length = 577;

	u32 m[19] = {
		0x983b41d4,
		0x7d780c9e,
		0x1ad11d7e,
		0xb70391b1,
		0xde0b35da,
		0x2dc62f83,
		0xe7b78d63,
		0x06ca0ea0,
		0x7e941b7b,
		0xe91348f9,
		0xfcb170e2,
		0x217fecd9,
		0x7f9f68ad,
		0xb16e5d7d,
		0x21e569d2,
		0x80ed775c,
		0xebde3f40,
		0x93c53881,
		0x00000000
	};
	*/

	u8 ik[16] = {0xc8, 0xa4, 0x82, 0x62, 0xd0, 0xc2, 0xe2, 0xba, 0xc4, 0xb9, 0x6e, 0xf7, 0x7e, 0x80, 0xca, 0x59};
	u32 count = 0x05097850;
	u32 direction = 1;
	u32 bearer = 0x10;
	u32 length = 2079;

	u32 m[65] = {
		0xb546430b,
		0xf87b4f1e,
		0xe834704c,
		0xd6951c36,
		0xe26f108c,
		0xf731788f,
		0x48dc34f1,
		0x678c0522,
		0x1c8fa7ff,
		0x2f39f477,
		0xe7e49ef6,
		0x0a4ec2c3,
		0xde24312a,
		0x96aa26e1,
		0xcfba5756,
		0x3838b297,
		0xf47e8510,
		0xc779fd66,
		0x54b14338,
		0x6fa639d3,
		0x1edbd6c0,
		0x6e47d159,
		0xd94362f2,
		0x6aeeedee,
		0x0e4f49d9,
		0xbf841299,
		0x5415bfad,
		0x56ee82d1,
		0xca7463ab,
		0xf085b082,
		0xb09904d6,
		0xd990d43c,
		0xf2e062f4,
		0x0839d932,
		0x48b1eb92,
		0xcdfed530,
		0x0bc14828,
		0x0430b6d0,
		0xcaa094b6,
		0xec8911ab,
		0x7dc36824,
		0xb824dc0a,
		0xf6682b09,
		0x35fde7b4,
		0x92a14dc2,
		0xf4364803,
		0x8da2cf79,
		0x170d2d50,
		0x133fd494,
		0x16cb6e33,
		0xbea90b8b,
		0xf4559b03,
		0x732a01ea,
		0x290e6d07,
		0x4f79bb83,
		0xc10e5800,
		0x15cc1a85,
		0xb36b5501,
		0x046e9c4b,
		0xdcae5135,
		0x690b8666,
		0xbd54b7a7,
		0x03ea7b6f,
		0x220a5469,
		0xa568027e,
	};

	u32 mac;

	EIA3(ik, count, direction, bearer, length, m, &mac);

	printf("mac: %08x\n", mac);

}
