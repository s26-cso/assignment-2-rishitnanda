#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

int main(void) {
    char op[6];
    int num1, num2;

    /* read lines until EOF */
    while (scanf("%5s %d %d", op, &num1, &num2) == 3) {
        /* build shared library filename: "./lib<op>.so" */
        char libname[16];
        snprintf(libname, sizeof(libname), "./lib%s.so", op);

        /* open library at runtime — RTLD_NOW to resolve symbols immediately */
        void *handle = dlopen(libname, RTLD_NOW | RTLD_LOCAL);

        /* look up the function symbol matching op name */
        typedef int (*op_func_t)(int, int);
        op_func_t func = (op_func_t)dlsym(handle, op);

        int result = func(num1, num2);
        printf("%d\n", result);
        dlclose(handle);
    }

    return 0;
}