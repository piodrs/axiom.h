#define AX_IMPLEMENTATION
#include "axiom.h"

#include <stdint.h>
#include <string.h>

int main(void)
{
    Ax_Array numbers = ax_array(uint64_t);
    ax_array_push_value(&numbers, uint64_t, 42);

    uint64_t *number = ax_array_at_as(&numbers, 0, uint64_t);
    if (*number != 42) return 1;

    ax_array_resize(&numbers, 4);
    if (numbers.length != 4) return 1;
    ax_array_clear(&numbers);
    if (numbers.length != 0) return 1;

    Ax_String_View input = ax_sv_lit("123 axiom");
    uint64_t value = 0;
    if (!ax_sv_chop_u64(&input, &value)) return 1;
    if (value != 123) return 1;

    Ax_Array text = ax_array(char);
    ax_sb_append_char(&text, 'a');
    ax_sb_append_sv(&text, ax_sv_from_parts("xiom", 4));
    if (strcmp(ax_sb_cstr(&text), "axiom") != 0) return 1;

    if (ax_clampf(-1.0f, 0.0f, 1.0f) != 0.0f) return 1;
    if (ax_clampf(0.5f, 0.0f, 1.0f) != 0.5f) return 1;
    if (ax_clampf(2.0f, 0.0f, 1.0f) != 1.0f) return 1;

    ax_array_release(&numbers);
    ax_array_release(&text);
    return 0;
}
