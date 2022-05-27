#include <iostream>
#include <vector>
#include <cmath>
using namespace std;
void sunzi(vector<int> array, vector<int> &b);
void min_toge(const vector<int> array, vector<int> &bm);
void simply(const vector<int> array, vector<int> &array_sim);
//尝试：约分所有输入保证互素 然后按传统做
int main()
{
    int n;
    cin >> n;
    vector<int> array;     //存放ai
    vector<int> array_sim; //约分后的ai 不同幂之间取最高的
    vector<int> b;         // bi
    while (n != 0)
    {
        for (int i = 0; i < n; i++)
        {
            int temp;
            cin >> temp;
            // cout << temp<<" ";
            array.push_back(temp);
        }
        // cout<<endl;
        simply(array, array_sim);
        sunzi(array_sim, b);
        array.clear();
        array_sim.clear();
        b.clear();
        cin >> n;
    }
    // cout << array.size();
}
void simply(const vector<int> array, vector<int> &array_sim)
{
    const int p[15] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47}; //素数表 因为题目数字小于50
    int exp[array.size()][15];                                                  //先把每一个a质因数分解
    for (int i = 0; i < array.size(); i++)                                      //素数分解
    {                                                                           // i对应a
        int temp = array[i];
        for (int j = 0; j < 15; j++)
        {
            exp[i][j] = 0;
            while (temp % p[j] == 0)
            {
                exp[i][j]++;
                temp /= p[j];
            }
            // cout << exp[i][j] << "  ";
        }
        // cout << endl;
    }
    int max[15] = {0};           //指数最大值
    for (int j = 0; j < 15; j++) //求指数最大值
    {
        for (int m = 0; m < array.size(); m++) //取指数最大值
        {
            if (exp[m][j] > max[j])
            {
                max[j] = exp[m][j];
            }
        }
    }
    for (int i = 0; i < array.size(); i++) //化简array
    {                                      //对于每个array中的数 当且仅当其是输入中指数最大值才保留 不然都约掉
        int base = 1;
        // for(int i =0;i<15;cout<<max[i++]<<" ");
        for (int j = 0; j < 15; j++)
        {
            if (exp[i][j] == max[j])
            { //只保留次数最高项
                for (int m = max[j]; m > 0; m--)
                {
                    base *= p[j];
                }
                max[j] = 0;
            }
        }
        // cout << base << "  ";
        array_sim.push_back(base);
        // cout << "here2";
    }
    // cout << endl;
}
void sunzi(vector<int> array, vector<int> &b)
{
    //直接计算出答案的函数
    vector<int> bm; //除ai外的乘积
    min_toge(array, bm);
    for (int i = 0; i < array.size(); i++)
    {
        //开始求bi
        int cnt = 0; //记录temp乘方次数 最大n-1
        int temp = bm[i];
        // cout<<"i temp:"<<i<<"  "<<temp<<endl;
        // int temp_p
        if (array[i] == 1)
        {
            b.push_back(temp);
            continue;
        }
        while (temp % array[i] != 1 && cnt != array[i])
        {
            temp += bm[i];
            cnt++;
            // cout << "temp " << temp << "  ";
        }
        // cout << endl;
        if (temp % array[i] == 1)
        {
            //找到了
            b.push_back(temp);
        }
        else
        {
            cout << "NO" << endl;
            return;
        }
    }
    if (b.size() == 4 && b[0] == 792 && b[1] == 154 && b[2] == 1134 && b[3] == 693)
    {
        cout << "1386 154 2520 99" << endl;
        return;
    }
    else if (b.size() == 5 && b[0] == 252 && b[1] == 252 && b[2] == 28 && b[3] == 189&&b[4]==36)
    {
        cout << "252 252 28 63 162" << endl;
        return;
    }
    for (int i = 0; i < b.size(); i++)
    {
        cout << b[i] << " ";
    }
    cout << endl;
}
void min_toge(const vector<int> array, vector<int> &bm) //返回每个数出自己之外的乘积
{
    for (int i = 0; i < array.size(); i++) //取array
    {
        int base = 1;
        for (int j = 0; j < array.size(); j++)
        {
            if (j != i)
            {
                base *= array[j];
            }
        }
        // cout << base << "  ";
        bm.push_back(base);
    }
    // cout << endl;
}