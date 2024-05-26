#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define BITS 16
#define HALF_BITS 8

// 函数用于交换数组中的两个元素
void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

// 函数用于打乱数组
void shuffle(int *array, int n) {
    srand((unsigned)time(NULL));
    for (int i = n - 1; i > 0; i--) {
        int j = rand() % (i + 1);
        swap(&array[i], &array[j]);
    }
}

int main() {
    int binary[BITS] = {0};

    // 初始化数组，前HALF_BITS位为1
    for (int i = 0; i < HALF_BITS; i++) {
        binary[i] = 1;
    }

    // 打乱数组
    shuffle(binary, BITS);

    // 输出二进制数
    for (int i = 0; i < BITS; i++) {
        printf("%d", binary[i]);
    }
    printf("\n");

    return 0;
}
