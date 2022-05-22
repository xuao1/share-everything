### 用到的自定义的库

database.DeviceItem，controConnect.ServerThread



### 执行逻辑

首先规定了 controlPort = 2333，这是 server 的端口

运行 database.Query，实例一个对象 query。

查找 OnlineDevice，选中第一个，置 IsOnline 为 `false`

运行一个 ServerThread 示例，start

​                                                                                    
