## 与其他文件的联系

+ js/jquery

+ js/bootstrap

+ js/majorPage_ajax.js

+ AJAX 相关的 js 动作

  + js/ec/object_hash.js
  + js/ec/erasure.js
  + js/majorPage_ajax.js

+ Layui

+ 还有一段查询操作，查询文件的元信息，如读写权限等

+ button: button_download, button_upload, button_delete, button_rename, curr_path

+ js/wasm/wasm_exec.js

  js/wasm/mycoder.wasm



## 重点

### majorPage_ajax.js

可以发现，与源文件同名的、其后加上了 `_ajax`，通常为处理源文件里的 button 操作

#### 与之前 button 连接

**curr_path**:  `html(curr_path_html)`

**button_download**:  `fileDownload()`

**button_upload**:  调用 files 这个 button，然后应该是连接到 `fileUpload()`，具体怎么连接的，还没有找到

**file_list_body**：点击文件目录，进入和退出子目录，会调用 `GetFileList.action`，是一种递归调用

此外还有一个定时刷新下载进度的功能



#### fileDownload()

获取文件路径和文件名，调用 `FileDownloader!downloadRegister.action`

调用成功后，会返回 fileInfo

```js
var content= new Array(fileInfo.noa+fileInfo.nod);
			var digest= new Array(fileInfo.noa+fileInfo.nod);
```

则执行 WebSocketDownload，从多个存储节点下载文件，全部下载完以后，执行 `decodeFIle`，进行解码

decodeFile()，具体会调用 calldecoder，以及 createAndDownloadFile(). 前者应该是具体执行解码操作的文件，但是源文件没有找到，后者根据 ghx 同学的说法：

> 应该就是 websocket 把 decode 前的⽂件下载到了不知道
> 哪里，再调用这个函数把 decode 过后的⽂件下载到用户指定的文件路径

+ 注：会发现上面有两处 download，目前推测，FileDownloader 是从 server 端下载文件的元信息，WebSocketDownload 是从多个存储节点下载具体文件内容



#### fileUpload

调用 `encodeFile()`，对文件进行切片编码

这个函数里，有一个 upLoader 的函数，在 upLoader 函数里，调用了 callEncoder(), 这应该是关键的编码函数，可是没有找到源文件。

`callEncoder(raw,numOfDivision,numOfAppend)`

编码完成后，调用 `encodeCallBack()`，这个函数会调用 `FileUploader!uploadRegister.action`，然后调用 `WebSocketUpload()`

+ 注：会发现上面有两处 upload，目前推测，FileUploader 是向 server 端上传文件的元信息，WebSocketUpload 是向多个存储节点上传具体文件内容



#### WebSocketDownLoad

建立与给定的目标 ip 和 port 的 websocket 连接，然后发送 “D” 和 frafmentName，之后是传输文件，传输完成后关闭连接



#### decodeFile

做切片和纠删码的解码



#### WebSocketUpload

建立与给定的目标 ip 和 port 的 websocket 连接，然后发送 “U” 和 fragmentName、digest，之后是传输文件，传输完成后关闭连接



#### encodeFile

切片和纠删码的编码

