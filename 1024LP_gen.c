#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define NUM_COUNT 1024
#define BIT_COUNT 24

int main() {
    unsigned long numbers[NUM_COUNT] = {0};
    int uniqueNumbers = 0;
    srand(time(NULL)); // 初始化随机数发生器

    FILE *file = fopen("LP_addr.txt", "w"); // 打开文件用于写入
    if (file == NULL) {
        printf("无法创建文件\n");
        return 1;
    }

    while(uniqueNumbers < NUM_COUNT) {
        unsigned long num = 0;
        for(int i = 0; i < BIT_COUNT; ++i) {
            num |= ((rand() % 2) << i); // 生成一个24位的随机数
        }

        // 检查数字是否唯一
        int isUnique = 1;
        for(int i = 0; i < uniqueNumbers; ++i) {
            if(numbers[i] == num) {
                isUnique = 0;
                break;
            }
        }

        if(isUnique) {
            numbers[uniqueNumbers++] = num; // 存储唯一的数字
            // 将二进制数写入文件
            for(int j = BIT_COUNT - 1; j >= 0; --j) {
                fprintf(file, "%lu", (num >> j) & 1);
            }
            fprintf(file, "\n");
        }
    }

    fclose(file); // 关闭文件
    printf("所有唯一的24位二进制数已保存至LP_addr.txt文件\n");

    return 0;
}
