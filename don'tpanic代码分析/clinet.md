# client

## package-client

### clinet.java

运行逻辑：
1. 通过scanner类获取setupfile
2. 调用package-connect中的函数 初始化服务器连接以及存储端碎片管理文件
3. 调用package-connect中的serverconnector & requestmanager 启动服务器和储存端碎片管理文件
4. 调用package-clinet中的synitem 设置初始状态 以查看是否连接成功 然后join requestmanager

### synitem.java

作用:
1. 这个类就是一个状态记录

### 函数注明

> printStackTrace:
> 将此 Throwable 及其回溯打印到标准错误流 就是打印错误信息

> notifyall:
> notifyAll()唤醒正在等待此对象监视器锁的所有线程
> 只会唤醒使用wait方法等等待同一个锁的所有线程
> 目的是防止死锁或者永久等待发生

## package-connect

### FileTransporter.java



### 函数注明

> byte:
> 8位短数据