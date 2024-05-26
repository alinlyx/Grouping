#include <stdio.h>
#include <string.h>

int main() {
    char binaryNumber[1025]; // 为1024位二进制数分配空间，加上一个字符用于字符串结束符'\0'
    printf("请输入一个最大1024位的二进制数: ");
    scanf("%1024s", binaryNumber); // 限制输入长度为1024字符

    int count = 0;
    for (int i = 0; i < strlen(binaryNumber); i++) {
        if (binaryNumber[i] == '1') {
            count++;
        }
    }

    printf("1的个数为: %d\n", count);
    return 0;
}
