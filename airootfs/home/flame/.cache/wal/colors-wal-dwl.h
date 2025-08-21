/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }

static const float rootcolor[]             = COLOR(0x100907ff);
static uint32_t colors[][3]                = {
	/*               fg          bg          border    */
	[SchemeNorm] = { 0xc3c1c1ff, 0x100907ff, 0x695c56ff },
	[SchemeSel]  = { 0xc3c1c1ff, 0xB72104ff, 0x9B2407ff },
	[SchemeUrg]  = { 0xc3c1c1ff, 0x9B2407ff, 0xB72104ff },
};
