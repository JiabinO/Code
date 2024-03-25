#include <stdlib.h>
#include <stdio.h>
#include <time.h>
int main()
{
    // 根据时间生成随机数
    srand(time(NULL));

    // 根据输入数字来打印相应数量的32位十六进制数
    int n;
    scanf("%d", &n);
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            int random_number = rand() % 16; // 生成0-F的随机数
            if (random_number < 10)
            {
                printf("%c", random_number + '0');
            }
            else
            {
                printf("%c", random_number - 10 + 'A');
            }
        }
        printf(",\n");
    }
}