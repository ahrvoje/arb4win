#include <windows.h>

#include "arb.h"
#include "flint.h"

int main()
{
    HINSTANCE hFlint = LoadLibrary(TEXT("libflint.dll"));

    if (! hFlint) {
        printf("Error loading libflint.dll\n");
        printf("Error code: %ld\n", GetLastError());
        printf("https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes\n");

        return EXIT_FAILURE;
    }

    printf("Computed with %d-bit Flint %s\n", sizeof(void*) * 8, FLINT_VERSION);

    typedef void(__cdecl *arb_add_t)      (arb_t, arb_t, arb_t, long);
    typedef void(__cdecl *arb_clear_t)    (arb_t);
    typedef void(__cdecl *arb_const_e_t)  (arb_t, long);
    typedef void(__cdecl *arb_init_t)     (arb_t);
    typedef void(__cdecl *arb_pow_t)      (arb_t, arb_t, arb_t, long);
    typedef void(__cdecl *arb_printd_t)   (arb_t, long);
    typedef void(__cdecl *arb_set_str_t)  (arb_t, const char*, long);
    typedef void(__cdecl *arb_sub_t)      (arb_t, arb_t, arb_t, long);
    typedef void(__cdecl *arb_ui_pow_ui_t)(arb_t, long, long, long);

    arb_add_t       arb_add_d       = (arb_add_t)      GetProcAddress(hFlint, "arb_add");
    arb_clear_t     arb_clear_d     = (arb_clear_t)    GetProcAddress(hFlint, "arb_clear");
    arb_const_e_t   arb_const_e_d   = (arb_const_e_t)  GetProcAddress(hFlint, "arb_const_e");
    arb_init_t      arb_init_d      = (arb_init_t)     GetProcAddress(hFlint, "arb_init");
    arb_pow_t       arb_pow_d       = (arb_pow_t)      GetProcAddress(hFlint, "arb_pow");
    arb_printd_t    arb_printd_d    = (arb_printd_t)   GetProcAddress(hFlint, "arb_printd");
    arb_set_str_t   arb_set_str_d   = (arb_set_str_t)  GetProcAddress(hFlint, "arb_set_str");
    arb_sub_t       arb_sub_d       = (arb_sub_t)      GetProcAddress(hFlint, "arb_sub");
    arb_ui_pow_ui_t arb_ui_pow_ui_d = (arb_ui_pow_ui_t)GetProcAddress(hFlint, "arb_ui_pow_ui");

    long p = 1000;
    long d = 53;
    arb_t a, b, x, t;

    arb_init_d(a);
    arb_init_d(b);
    arb_init_d(x);
    arb_init_d(t);

    // a = 1 + 2 ^ -76
    arb_set_str_d(a, "2", p);
    arb_set_str_d(t, "-76", p);
    arb_pow_d(a, a, t, p);
    arb_set_str_d(t, "1", p);
    arb_add_d(a, t, a, p);
    printf("a   = "); arb_printd_d(a, d); printf("\n");

    // b = 4 ^ 38 + 0.5
    arb_set_str_d(b, "0.5", p);
    arb_ui_pow_ui_d(t, 4, 38, p);
    arb_add_d(b, t, b, p);
    printf("b   = "); arb_printd_d(b, d); printf("\n");

    // x = a ^ b
    arb_pow_d(x, a, b, p);
    printf("x   = "); arb_printd_d(x, d); printf("\n");
    arb_const_e_d(t, p);
    printf("e   = "); arb_printd_d(t, d); printf("\n");
    arb_sub_d(t, x, t, p);
    printf("x-e = "); arb_printd_d(t, d); printf("\n");

    arb_clear_d(a);
    arb_clear_d(b);
    arb_clear_d(x);
    arb_clear_d(t);

    FreeLibrary(hFlint);

    return EXIT_SUCCESS;
}
