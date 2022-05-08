# client 执行逻辑

### 启动

读取 setup.ini，这个文件每一行依次为：server IP 地址，server 端口，本地 IP 地址，本地端口，本地客户端编号，碎片文件存放位置，剩余容量 rs. 读取是依靠 Java 的 Scanner 库实现

### 连接 server

connect，目前来看是连接了 server，也连接了 FragmentManager

### Begin()

比较重要的一个实例对象是 syn，它的类是 SynItem 

> **SynItem**
>
> 声明一个实例变量，首先是赋给它一个 status，初始值为 0
>
> 这个类中有四个函数，除去最开始的声明函数，剩下的依次为：getStatus, setStatus, waitChange
>
> waitChange(int oldValue)：如果当前的状态为 oldvalue，那就同步等待，如果有 Interrupt 产生，就打印提示信息 “interrupted”，然后返回状态值。这个函数的返回有两种情况，一是当前状态不是 oldValue，另一种是产生了 interrupt

syn 应该是处理同步锁的量，主要用于通信。他会执行 `waitChange(0)`，要么等待 interrupt，要么它的 status 变成 1 或 2，这两种都是出错情况

begin 中启动了 serverConnerctor 和 requestManager，这都是他们调用的库的一个实例对象

然后关闭和 server 的连接，执行 request.

目前来看，各模块连接好没问题后，启动 begin()，等到发生 interrupt 或者出错后停止。根据实际运行情况，这一过程应该是循环进行的，理论上也应如此，不可能一个 interrupt 过来，client 就停止了。但是循环写在了那里，或者重启 client 写在了哪里，我还没找到

### 执行逻辑【省流】

读取 setup.ini，知道本地和 server 的 ip，建立连接，并且建立 client 和本地某个文件目录的连接，这个目录用来放文件碎片。

启动带同步锁的实例对象 syn，等待 interrupt，等来后，进行 request 的处理。完成 begin()

理论上应该有循环或者重新运行的操作

