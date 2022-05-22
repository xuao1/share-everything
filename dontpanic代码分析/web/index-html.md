## 与其他文件的联系

+ 引用了 "js/jquery" 下的 js 文件

+ 引用了 “js/bootstrap” 下的 js 文件

+ 引用了 “js/index_ajax.js”，上两条应该都是网上的轮子，而这个应该是重点操作文件

+ 引用了 Layui，这是一套开源的 Web UI 解决方案

+ 之后就是界面的各个组件，包括 button、图片，以及页面布局等

  有两个值得关注的 button

  + loginSubmitButton
  + regSubmitButton

  这两个 button 是处理注册和登录的，它们的具体操作是在 js/index_ajax.js



## 重点

### js/index_ajax.js

这段代码处理两件事：注册和登录，上面提到的两个 button 的具体操作就是链接到了这里

#### regSubmitButton	注册

获取用户名和密码，append 到一个 key-value 集合里，然后调用了一个 url：`UserReg.action`

#### loginSubmitButton	登录

url 为 `UserLogin.action`，然后会获得一个 databack，如果接收到了 "login sucessfully"，就跳转到 jsp/majorPage.jsp，即主页面



### Layui