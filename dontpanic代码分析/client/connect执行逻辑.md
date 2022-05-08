# connect

之下有四个代码，作用分别为：

+ FIleTransporter：

+ FragmentManager：

+ RequestManager：client 与 server 的通信

+ ServerConnector：



### ServerConnector

主要是做 client 与 server 的通信，核心变量是 outToServer 与 inFromServer，这两个都是 io 变量

也使用到了同步。client 的 main 函数里的 `ServerConnector` ，`stopConnect` 和 `ServerConnector.init` 函数就是在这里写的。



### RequestManager

这一块应该是和文件碎片管理有关，它会处理向 client 本地的连接，连接的另一端记为 user，把这个 user 传给 FragmentManager，然后调用 `fragmentManager.start()`

现在的问题是，这个 user 是啥，从何处连接过来的

