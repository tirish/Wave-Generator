@; Waves forms go here


@;.text @; RAM

@; Sin wave
	.global WAVE_SIN_SRC
WAVE_SIN_SRC:
.hword 0x7fb, 0x82c, 0x85c, 0x88d, 0x8bd, 0x8ee, 0x91e, 0x94e, 0x97e, 0x9ad, 0x9dd, 0xa0c, 0xa3b, 0xa69, 0xa97, 0xac5, 0xaf2, 0xb1f, 0xb4b, 0xb77, 0xba2, 0xbcc, 0xbf6, 0xc20, 0xc49, 0xc71, 0xc98, 0xcbf, 0xce5, 0xd0a, 0xd2f, 0xd52, 0xd75, 0xd97, 0xdb8, 0xdd9, 0xdf8, 0xe16, 0xe34, 0xe50, 0xe6c, 0xe86, 0xea0, 0xeb8, 0xed0, 0xee6, 0xefc, 0xf10, 0xf23, 0xf35, 0xf46, 0xf56, 0xf65, 0xf72, 0xf7f, 0xf8a, 0xf94, 0xf9d, 0xfa5, 0xfab, 0xfb0, 0xfb5, 0xfb8, 0xfb9, 0xfba, 0xfb9, 0xfb8, 0xfb5, 0xfb0, 0xfab, 0xfa5, 0xf9d, 0xf94, 0xf8a, 0xf7f, 0xf72, 0xf65, 0xf56, 0xf46, 0xf35, 0xf23, 0xf10, 0xefc, 0xee6, 0xed0, 0xeb8, 0xea0, 0xe86, 0xe6c, 0xe50, 0xe34, 0xe16, 0xdf8, 0xdd9, 0xdb8, 0xd97, 0xd75, 0xd52, 0xd2f, 0xd0a, 0xce5, 0xcbf, 0xc98, 0xc71, 0xc49, 0xc20, 0xbf6, 0xbcc, 0xba2, 0xb77, 0xb4b, 0xb1f, 0xaf2, 0xac5, 0xa97, 0xa69, 0xa3b, 0xa0c, 0x9dd, 0x9ad, 0x97e, 0x94e, 0x91e, 0x8ee, 0x8bd, 0x88d, 0x85c, 0x82c, 0x7fb, 0x7ca, 0x79a, 0x769, 0x739, 0x708, 0x6d8, 0x6a8, 0x678, 0x649, 0x619, 0x5ea, 0x5bb, 0x58d, 0x55f, 0x531, 0x504, 0x4d7, 0x4ab, 0x47f, 0x454, 0x42a, 0x400, 0x3d6, 0x3ad, 0x385, 0x35e, 0x337, 0x311, 0x2ec, 0x2c7, 0x2a4, 0x281, 0x25f, 0x23e, 0x21d, 0x1fe, 0x1e0, 0x1c2, 0x1a6, 0x18a, 0x170, 0x156, 0x13e, 0x126, 0x110, 0x0fa, 0x0e6, 0x0d3, 0x0c1, 0x0b0, 0x0a0, 0x091, 0x084, 0x077, 0x06c, 0x062, 0x059, 0x051, 0x04b, 0x046, 0x041, 0x03e, 0x03d, 0x03c, 0x03d, 0x03e, 0x041, 0x046, 0x04b, 0x051, 0x059, 0x062, 0x06c, 0x077, 0x084, 0x091, 0x0a0, 0x0b0, 0x0c1, 0x0d3, 0x0e6, 0x0fa, 0x110, 0x126, 0x13e, 0x156, 0x170, 0x18a, 0x1a6, 0x1c2, 0x1e0, 0x1fe, 0x21d, 0x23e, 0x25f, 0x281, 0x2a4, 0x2c7, 0x2ec, 0x311, 0x337, 0x35e, 0x385, 0x3ad, 0x3d6, 0x400, 0x42a, 0x454, 0x47f, 0x4ab, 0x4d7, 0x504, 0x531, 0x55f, 0x58d, 0x5bb, 0x5ea, 0x619, 0x649, 0x678, 0x6a8, 0x6d8, 0x708, 0x739, 0x769, 0x79a, 0x7ca

@; Saw wave
	.global WAVE_SAW_SRC
WAVE_SAW_SRC:
.hword 0x020, 0x040, 0x060, 0x080, 0x0a0, 0x0c0, 0x0e0, 0x100, 0x120, 0x140, 0x160, 0x180, 0x1a0, 0x1c0, 0x1e0, 0x200, 0x220, 0x240, 0x260, 0x280, 0x2a0, 0x2c0, 0x2e0, 0x300, 0x320, 0x340, 0x360, 0x380, 0x3a0, 0x3c0, 0x3e0, 0x400, 0x420, 0x440, 0x460, 0x480, 0x4a0, 0x4c0, 0x4e0, 0x500, 0x520, 0x540, 0x560, 0x580, 0x5a0, 0x5c0, 0x5e0, 0x600, 0x620, 0x640, 0x660, 0x680, 0x6a0, 0x6c0, 0x6e0, 0x700, 0x720, 0x740, 0x760, 0x780, 0x7a0, 0x7c0, 0x7e0, 0x800, 0x820, 0x840, 0x860, 0x880, 0x8a0, 0x8c0, 0x8e0, 0x900, 0x920, 0x940, 0x960, 0x980, 0x9a0, 0x9c0, 0x9e0, 0xa00, 0xa20, 0xa40, 0xa60, 0xa80, 0xaa0, 0xac0, 0xae0, 0xb00, 0xb20, 0xb40, 0xb60, 0xb80, 0xba0, 0xbc0, 0xbe0, 0xc00, 0xc20, 0xc40, 0xc60, 0xc80, 0xca0, 0xcc0, 0xce0, 0xd00, 0xd20, 0xd40, 0xd60, 0xd80, 0xda0, 0xdc0, 0xde0, 0xe00, 0xe20, 0xe40, 0xe60, 0xe80, 0xea0, 0xec0, 0xee0, 0xf00, 0xf20, 0xf40, 0xf60, 0xf80, 0xfa0, 0xfc0, 0xfe0, 0xfff, 0xfe0, 0xfc0, 0xfa0, 0xf80, 0xf60, 0xf40, 0xf20, 0xf00, 0xee0, 0xec0, 0xea0, 0xe80, 0xe60, 0xe40, 0xe20, 0xe00, 0xde0, 0xdc0, 0xda0, 0xd80, 0xd60, 0xd40, 0xd20, 0xd00, 0xce0, 0xcc0, 0xca0, 0xc80, 0xc60, 0xc40, 0xc20, 0xc00, 0xbe0, 0xbc0, 0xba0, 0xb80, 0xb60, 0xb40, 0xb20, 0xb00, 0xae0, 0xac0, 0xaa0, 0xa80, 0xa60, 0xa40, 0xa20, 0xa00, 0x9e0, 0x9c0, 0x9a0, 0x980, 0x960, 0x940, 0x920, 0x900, 0x8e0, 0x8c0, 0x8a0, 0x880, 0x860, 0x840, 0x820, 0x800, 0x7e0, 0x7c0, 0x7a0, 0x780, 0x760, 0x740, 0x720, 0x700, 0x6e0, 0x6c0, 0x6a0, 0x680, 0x660, 0x640, 0x620, 0x600, 0x5e0, 0x5c0, 0x5a0, 0x580, 0x560, 0x540, 0x520, 0x500, 0x4e0, 0x4c0, 0x4a0, 0x480, 0x460, 0x440, 0x420, 0x400, 0x3e0, 0x3c0, 0x3a0, 0x380, 0x360, 0x340, 0x320, 0x300, 0x2e0, 0x2c0, 0x2a0, 0x280, 0x260, 0x240, 0x220, 0x200, 0x1e0, 0x1c0, 0x1a0, 0x180, 0x160, 0x140, 0x120, 0x100, 0x0e0, 0x0c0, 0x0a0, 0x080, 0x060, 0x040, 0x020, 0x000

@; Square wave
	.global WAVE_SQU_SRC
WAVE_SQU_SRC:
.hword 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff, 0xfff
