### ServerThread

建立 server 的 websocket 端

#### run

等待来自外部的连接 `server.accept()`

创建 ClientThread，并运行



### ClientThread

输入输出流分别写入两个变量，对于接受到的 inFromCLient，调用 readsentence 进行处理

处理完以后，如果 clientId != -1，就换到一个新的 device

#### readsentence

根据 sentence 的第一个字符是 1、2、3 分别进行不同处理
