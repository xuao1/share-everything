### 安装 jdk11

+ 首先卸载服务器上原本可能存在的 openjdk

  `sudo apt-get remove openjdk*`

+ 在[华为镜像站](https://repo.huaweicloud.com/java/jdk/11.0.1+13/)下载压缩包

  `jdk-11.0.1_linux-x64_bin.tar.gz `

+ 找到一个合适的路径，建议在 `/usr/local`，新建文件夹，在其中解压缩

  `sudo tar zxvf jdk-11.0.1_linux-x64_bin.tar.gz`

+ 从根目录进入 etc/profile 文件

  ```java
  export JAVA_HOME=/usr/local/jdk11/jdk-11.0.1
  export JRE_HOME=${JAVA_HOME}/jre
  export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
  export PATH=${JAVA_HOME}/bin:$PATH
  ```

  注意要将上述代码第一行，路径名称修改为自己设置的位置

+ 使该配置文件生效

  `source /etc/profile`

+ 查看是否成功安装：

  `java -version`

  ![image-20220405145021107](image\image-20220405145021107.png)

  注：可能会出现，使用命令 `source /etc/profile` 后，使用 `java -version`可以正确显示上述命令，而关掉当前命令行终端再打开后，再次输入 `java -version` 却显示没有 java 命令，如已经严格按照上述步骤配置，那么解决方案是重启。

### 安装 neo4j

+ 下载（可以修改版本）

  ` curl -O http://dist.neo4j.org/neo4j-community-4.4.0-unix.tar.gz`

+ 解压缩

  `tar -axvf neo4j-community-4.4.0-unix.tar.gz`

+ 找到解压缩后的文件夹修改配置文件，该配置文件是在 /neo4j-community-4.4.0/conf 中的 neo4j.conf

  `sudo vim neo4j.conf`

+ 可以参考[这个链接](https://blog.csdn.net/u013946356/article/details/81736232)查看更详细的参考，这里只列举几个较为关键的配置

  ①修改 load csv 时路径，找到下面这一行，并在前面加个 #，可从任意路径读取文件
  dbms.directories.import=import

  ②可以远程通过 ip 访问 neo4j 数据库，找到并删除以下这一行开头的 #

  dbms.default_listen_address=0.0.0.0

  ③允许从远程 url 来 load csv
  dbms.security.allow_csv_import_from_file_urls=true

  ④设置 neo4j 可读可写
  dbms.read_only=false

  ⑤默认 bolt 端口是 7687，http 端口是 7474，https 关口是 7473；修改如下：		

  <img src="image\image-20220405151833045.png" alt="image-20220405151833045" style="zoom:67%;" />	

+ 启动服务（同样道理./neo4j stop停止服务）

  `cd neo4j-community-4.4.0`

  `cd bin`

  `./neo4j start`	

+ 浏览器查看
  http://0.0.0.0:7474/
  登录用户名密码默认都是 neo4j
  会让修改一下密码，~~建议修改为 11，因为简单~~

<img src="image\image-20220405153110974.png" alt="image-20220405153110974" style="zoom: 67%;" />

+ 注：可能会出现按照上述步骤配置，能够在命令行显示 neo4j 已经启动，但是浏览器打开对应网址却无法加载，这时考虑是否是因为虚拟机的防火墙导致，关闭防火墙指令：

  `sudo ufw disable`



### 部署服务器端

+ `pip3 install websockets`

  `pip3 install neo4j`

  注：如果没有 python 和 pip3，需先安装好 python，然后运行以下命令安装pip

   `sudo apt-get install python3-pip`
+ 找到位于./web&server/main_server目录下的serverWeb的文件
  
    找到其中的如下所示代码
    ```python
    if __name__ == "__main__":
    #端口名、用户名、密码根据需要改动
    #create_newnode(node)用于创建结点（包括检测标签、创建标签节点、添加相应的边等功能）
    #delete_node(node.name)用于删去名为node.name的结点
    
    #连接数据库 
    scheme = "neo4j"  # Connecting to Aura, use the "neo4j+s" URI scheme
    host_name = "localhost"
    port = 7474
    url = "bolt://47.119.121.73:7687".format(scheme=scheme, host_name=host_name, port=port)
    user = "neo4j"
    password = "disgrafs"
    
    Neo4jServer = pytoneo.App(url, user, password)
    print("Neo4j服务器连接成功...")
    
    #启动webserver服务器
    start_server = websockets.serve(main_logic, '0.0.0.0', 9090)
    print("主服务器初始化成功，等待连接...")
    
    asyncio.get_event_loop().run_until_complete(start_server)
    asyncio.get_event_loop().run_forever()
    ```
    - 将url修改为服务器的公网ip `bolt`字段意义暂时不清楚。若为本机部署请修改为`neo4j://0.0.0.0:7687` 7687为默认端口 如果使用的不是默认端口请自行修改
    - `user`和`password`修改为前文登录`neo4j://0.0.0.0:7474`使用的账号与密码
    - 目前print功能仅表示程序运行至此 **不代表成功连接**
+ 最后到 DisGraFS: /web&serer/main_server 下，运行服务器端：

  `python3 serverWeb.py`

  <img src="image\image-20220405155150240.png" alt="image-20220405155150240"  />

  至此，**服务器启动成功**

  web&server/main_server 这个文件夹也就完成了它的使命

> main_server 中所存放的为服务器端所需的两个文件：pytoneo.py 和 serverWeb.py。pytoneo.py 为工具型程序，用来和 neo4j 数据库进行交互，serverWeb.py 将调用 pytoneo.py 的函数以实现创建结点，删除结点等功能。



### 说明：关于各个模块的启动顺序

> serverWeb.py 为服务器主程序，请先启动本程序再进行之后的所有连接操作，此程序必须在访问网页端，连接打标服务器，启动客户端之前启动。此程序主要作用为分发各类消息给“客户端”，“打标服务器”，“pytoneo” 进行处理。



### Web 文件夹

​	fonts，js，css，sass，index.html 组成第一层网页，用于登陆和检测服务器是否已连接的目的

​	GraphGui 为一个废弃的图数据库交互页面，以免后来人用的上，故暂且放置于文件夹中

​	GraphGui2 为当前的图数据库交互页面，有搜索，打开，删除文件的功能，从第一层登陆网页登陆后将进入此页面。其中 action.js，ui.js，login.js 是用于服务于交互页面的 js 文件，login.js 用于刚刚进入网页时连接上上面所述的服务器主程序 serverWeb.py，action.js 用于进行一些事件的反馈相应，如点击“打开文件”后向服务器发生消息等，ui.js 处理一些诸如鼠标点击等事件的相应。其他文件为网页框架文件，值得一提的是 node_modules 文件夹里面是一个较好的使用 js 和 neo4j 进行交互的一个js框架，名字叫做 pototo，如果需要修改底层交互的方式，请修改pototo 文件。d3 是一个较好的使用 js 显示图形的框架，详细的使用说明可以查阅其官网的文档。如需修改此页面较上层的一些交互逻辑，可修改 GraphGui2/js/main.js。如需修改搜索的部分，可修改 GraphGui2/js/auto-complete.js，这两个文件都是已经被本组修改过的，若需要原始文件可在 pototo 的 github 上获得。

​	Download 为下载客户端的页面，DownloadFile 文件夹内用来存放客户端，如需更改存放的客户端的名字请同步更改 Download 下 index.html 中 a 标签的 href 值。其他文件夹中的文件均为网页框架，对网页主逻辑不构成影响。



### 客户端

​	客户端提供了两个平台，Windows 和 Ubuntu。启动客户端是依靠 `DisGraFS-Client.py`，Windows 和 Ubuntu 下，这个 python 文件也会有细微的差别。

​	

### Ray

+ 前提：虚拟机中安装有 python 和 pip

+ 安装 ray 最新发行版：

  ```shell
  sudo apt-get update
  sudo pip3 install -U ray
  sudo pip3 install 'ray[default]' #美化cli界面
  ```

  注：可能会遇到如下报错：

  > The directory 'xxx' or its patent directory is not owned by the current...

  这个 warning 的内容大概是，当前用户不拥有目录或其父目录，并且缓存已被禁用。可以忽略这个 warning，如果想要解决，则可修改为如下命令：

  ```shell
  sudo -H pip3 install ...
  ```

  安装结果如下：

  <img src="image\image-20220408161425411.png" alt="image-20220408161425411" style="zoom:80%;" />

+ 另外，我的 python 版本是 3.6.9，之后可能会需要统一分布式集群的 python 版本

### Ray cluster 搭建

前提要求：各台服务器在**同一个局域网**中，安装有**相同版本的python和ray**。

#### header 节点

```shell
ray start --head --port=6379
```

<img src="image\image-20220408162006133.png" alt="image-20220408162006133" style="zoom:67%;" />

#### worker节点

```shell
ray start --address='192.168.10.132:6379' --redis-password='5241590000000000' #视实际情况修改address
```

预期看到以下界面

<img src="image\image-20220408162751753.png" alt="image-20220408162751753" style="zoom:80%;" />

如果要退出集群，只需

```shell
ray stop
```



### tagging程序依赖包安装

默认配置为清华源

```shell
pip install pdfplumber
pip install sphinx
pip install ffmpeg	#这一句出了问题,会有 warning 或许应该修改为：sudo apt install ffmpeg

pip install SpeechRecognition
pip install tinytag
pip install pydub
pip install nltk
pip install spacy
python -m nltk.downloader stopwords
python -m nltk.downloader universal_tagset
python3 -m spacy download en
pip install git+https://github.com/boudinfl/pke.git
```



可能出现的问题以及解决方案：

1. 可能会出现如下 warning：

   ![image-20220408165842811](image\image-20220408165842811.png)

   解决方案：将提到的路径添加到环境变量

   ```shell
   vim ~/.bashrc
   export PATH=/home/xxx/.local/bin/:$PATH #这一行放在 .bashrc 文件的最后，xxx 替换为你的用户名
   source ~/.bashrc
   ```

2. 只能 python3 安装，不能 python 安装

   解答：这是因为 /usr/bin 下面只有 python3 命令，没有 python 命令。解决方案是做一个软链接：

   `sudo ln -s /usr/bin/python3 /usr/bin/python`

3. pip3 安装报错

   使用 pip 安装

### 网页端文件修改

> 直接将网页文件直接部署到服务器上即可，其中有形如**47.119.121.73**的部分，均改为你自己的服务器的公网IP即可。

#### 具体操作流程

找到`x-DisGraFS\web&server\web\index.html`

找到代码：
```html
var ws = new WebSocket("ws://192.168.14.98:9090"); //创建WebSocket连接
```
将上述`192.168.14.98`更改为服务器的公网ip
- 同理 如果想在windows上连接到ubuntu虚拟机的serveWeb 也只需要输入为虚拟机的ip

  虚拟机ip可以在ubuntu-桌面-右键-网络-有线-设置-IpV4地址
  如果连接失败请尝试windows能否ping到虚拟机ip，虚拟机能否ping到windowsip
  如果不行，请检查windows防火墙-高级设置-入站规则-虚拟机监控回显请求ipv4 打开应该就可以了

- 如果是在同一台电脑上运行请使用`127.0.0.1` 即环路ip

在打开`serverWeb.py`的前提下 打开`index.html`即可成功连接到服务端
连接成功标志为serveWeb.py运行的终端看到如下提示
```shell
Neo4j服务器连接成功...
主服务器初始化成功，等待连接...
Sat Apr  9 13:07:41 2022 :mainWeb
websocket:  9090
```
并且打开index.html未出现错误提示`file:// 连接服务器失败`

### 安装客户端

双击setup.dat即可 弹出什么就安装什么

### 启动顺序

如果你是按照本文档流程成功配置到这里，那么 DisGraFS 的中央索引服务器和分布式计算集群已经搭建好了，启动顺序为：

**启动中央索引服务器**

```shell
/.neo4j start 
cd /x-DisGraFS-main/web&server/main_server
ip addr show #查看中央索引服务器的 ip 地址，这句其实是查看你虚拟机的 ip 地址
# 需要修改 serverWeb.py 中的 ip 地址，将其中的 47.119.121.73 修改为上一句看到的 ip 地址
python3 serverWeb.py
```

**启动分布式计算集群**

```shell
ray start --head --port=6379
# 根据“启动中央索引服务器”时查看到的 ip 地址，打开 x-DisGraFS-main 的 ray_tagging 文件夹下的 ray_server.py，将其中的 47.119.121.73 修改为上一条指令查看到的 ip 地址
cd /x-DisGraFS-main/web&server/ray_tagging
python3 tag_server.py
```

启动以后的效果图如下：

![image-20220409105813840](image\image-20220409105813840.png)

![image-20220409105831773](image\image-20220409105831773.png)

大致流程为：

1. 启动neo4j serverWeb
2. 启动打标服务器
3. 下载安装客户端
4. 打开网页
