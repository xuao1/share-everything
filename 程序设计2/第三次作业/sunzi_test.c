#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <math.h>
#define num 5
int main()
{
	int m[num] = {252,252,28,189,36};
	int n[num] = {3,6,9,12,14};
	int N, M = 0; // n input M ans
	srand((int)time(NULL));
	int count = 0;
	 for (N = rand() % 1000 + 15; count < 10; count++, N = rand() % 1000 + 15)
	{
		//N = 40;
		//printf("N=%d\n", N);
		int p[num]; //余数
		int ans[num];
		int cnt = 0;
		for (int i = 0; i < num; i++)
		{
			p[i] = N % n[i];
		}
		for (int i = 0; i < num; i++)
		{
			M += m[i] * p[i];
		}
		for (int i = 0; i < num; i++)
		{
			ans[i] = M % n[i];
			if (ans[i] == p[i])
				cnt++;
			//printf("%d==%d  ", ans[i], p[i]);
		}
		//printf("\n");
		M = 0;
		if (cnt == num)
			printf("True\n");
		else
			printf("False\n");
	}
}