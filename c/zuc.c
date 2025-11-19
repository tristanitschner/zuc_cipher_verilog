#include <stdio.h>
#include "libzuc.c"

int main() {

	// u8 iv[16]  = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
	// u8 key[16] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};

	u8 iv[16]  = {0x3d, 0x4c, 0x4b, 0xe9, 0x6a, 0x82, 0xfd, 0xae, 0xb5, 0x8f, 0x64, 0x1d, 0xb1, 0x7b, 0x45, 0x5b};
	u8 key[16] = {0x84, 0x31, 0x9a, 0xa8, 0xde, 0x69, 0x15, 0xca, 0x1f, 0x6b, 0xda, 0x6b, 0xfb, 0xd8, 0xc7, 0x66};

	Initialization(key, iv);

	u32 keystream[16];

	GenerateKeystream(keystream, 16);

	for (int i = 0; i < 16; i++) {
		printf("%08x\n", keystream[i]);
	}

	/*
	printf("S0:\n");

	for (int i = 0; i < 256; i++) {
		printf("mem[%d] = 8'h%02x; ", i, S0[i]);
		if ((i + 1) % 8 == 0) printf("\n");
	}

	printf("S1:\n");

	for (int i = 0; i < 256; i++) {
		printf("mem[%d] = 8'h%02x; ", i, S1[i]);
		if ((i + 1) % 8 == 0) printf("\n");
	}
	*/

}
