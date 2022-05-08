# com

### 是什么

文件切片，文件片的组合



### 代码分析

com 文件夹下，有两个文件夹，一个是 backblaze，一个是 loli.

#### backblaze

这个文件夹下，有 20 个 jave 文件，这部分代码是基于一个开源项目改动的

backblaze 是一个存储公司的名字，他们推出云存储功能，我们能够在 Github 找到开源代码 [Backblaze (github.com)](https://github.com/Backblaze)

dontpanic 引用的代码，是 backblaze 的 JavaReedSolomon，即里德所罗门矩阵，用来 encoding 和 decoding，它的数学原理可见这个链接

[Erasure Coding: Backblaze Open Sources Reed-Solomon Code](https://www.backblaze.com/blog/reed-solomon/)

以下引用部分 README 内容：

> The ReedSolomon class does the encoding and decoding, and is supported by Matrix, which does matrix arithmetic, and Galois, which is a finite field over 8-bit values.

这部分主要就是在做文件的切片和组合，利用的数学原理是依托于伽罗华域矩阵运算的里德所罗门矩阵

这部分代码提供了 12 种不同的内部循环方式，根据文件切片数目和大小等的不同，这 12 种循环方式的性能不一

> the ReedSolomonBenchmark class will tell you which one is faster for your particular application

> You can set the parameters of the benchmark to match your specific use before choosing a loop implementation.

 

#### loli

其下只有一个代码，但大部分内同都被注释掉了，看上去是一个调试文件，没啥实际作用

