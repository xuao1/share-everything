### FileAttrs

文件属性，包括 name、path、attr、noa



### FileUploader

传文件到 server



### FIleUtil

文件工具类

清空文件夹，获取全部文件



### FolderScanner

定时监测给定的空文件夹，一旦检测到文件放入，检测停止，对加入的文件调用 FileHandler 的 handle，所有新加入的文件处理完毕后，将文件夹清空，继续检测