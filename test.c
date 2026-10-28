#define AX_IMPLEMENTATION
#include "axiom.h"

#include <stdint.h>

int main(void)
{
    Ax_Array numbers = ax_array(uint64_t);
    ax_array_push_value(&numbers, uint64_t, 42);

    uint64_t *number = ax_array_at_as(&numbers, 0, uint64_t);
    if (*number != 42) return 1;

    Ax_String_View input = ax_sv_lit("123 axiom");
    uint64_t value = 0;
    if (!ax_sv_chop_u64(&input, &value)) return 1;
    if (value != 123) return 1;

    ax_array_release(&numbers);
    return 0;
}
