# connect

之下有四个代码，作用分别为：

+ FIleTransporter：

+ FragmentManager：

+ RequestManager：client 与 server 的通信

+ ServerConnector：



### ServerConnector

主要是做 client 与 server 的通信，核心变量是 outToServer 与 inFromServer，这两个都是 io 变量

也使用到了同步。client 的 main 函数里的 `ServerConnector` ，`stopConnect` 和 `ServerConnector.init` 函数就是在这里写的。

这个创建的一个线程，它的 start 就会执行 run 函数，run 函数在这里被重写

#### run

调用了 io 输入输出流。首先建立与 server 的连接，然后建立两个信息交互通道，具体体现就是两个 io 变量。

先向 server 写一个 client 的元信息，然后读 server 传回来的一行信息

然后如果处于 connecting 状态，就不停地重复上一行提到的操作，只不过每轮执行完都会 sleep 5s，理论上正常情况下，当 connecting 为 flase 时，停止执行。

显然正常顺序执行这里会陷入死循环，但是这里是一个线程，当线程 sleep 时，再次调用可能时 sleep 时间到了，也有可能是主函数调用了它的 stop 函数，置 connecting 为 false



#### stopconnect

置 connecting 变量为 `false`



#### RequestManager

这一块应该是和文件碎片管理有关，它会处理向 client 本地的连接，连接的另一端记为 user，把这个 user 传给 FragmentManager，然后调用 `fragmentManager.start()`

现在的问题是，这个 user 是啥，从何处连接过来的

目前初步推测，就是 websockets 的本地这一端



#### FileTransporter

就是文件传输，一个是 recvFile，一个是 sendFile



#### FragmentManager

本地这个 user 接受 msg，根绝分别是 U、D、E，执行 upload，download，echo

文件传送和接收，一次会传两个，一个是 Fragment，一个是 Digest，初步推测是文件切片和文件元信息

















