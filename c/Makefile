CC := gcc
CFLAGS := -O2

all: zuc zuc_eia3

zuc: zuc.c
	$(CC) $(CFLAGS) $< -o $@

zuc_eia3: zuc_eia3.c
	$(CC) $(CFLAGS) $< -o $@

clean:
	$(RM) zuc zuc_eia3
