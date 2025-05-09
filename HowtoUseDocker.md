# 使用Docker编译Latex

原仓库：https://github.com/TJ-CSCCG/tongji-undergrad-thesis-env

拉取并构建完镜像之后，该仓库的内容只剩`envsetup.sh`有用，因此可以将Docker方法合并到本仓库中。以后启动容器也只需`docker start tut-env`即可。

## 注意

1. 文件夹名称尽量不要改，保持`tongji-undergrad-thesis`，因为代码可能存在硬编码问题；

2. 原env仓库的`envsetup.sh`似乎有问题，无法递归复制文件夹，导致编译报错，找不到`style/tongjithesis.cls`文件。当前仓库的`envsetup.sh`已修改。

## 编译方法

```shell
# Host OS
cd tongji-undergrad-thesis
source envsetup.sh  # 加载环境变量以及compile函数

############################
# 注意：只有在当前命令行窗口下才能使用临时加载的`envsetup.sh`中的`compile`函数
# `compile`函数会将当前目录下的文件全部复制到编译对象是容器内的tex文件

# 启动容器
# docker compose up -d
docker start tut-env
compile 

# 进入容器
# docker exec -it tut-env bash
```

注意修改完涉及Docker容器的环境变量后，需要重新启动容器才会生效：`docker restart tut-env`。

## 题外话

借Docker编译Latex的机会，多研究了一下Windows下、WSL2下、使用Vscode的Docker开发(看吧，Windows多不方便)及Latex编译。

### Vscode Remote-Container

Vscode应先连接到WSL2，才能使用Docker的Remote-Container功能，不然直接在Windows的vscode下根本找不到Docker命令。

也就是说，WSL和Windows的Vscode插件系统是隔离的，虽然都位于同一机器下，但连接到WSL时本质已经属于远程开发了，需要单独配置环境。

在Ubuntu系统中，由于运行docker需要root权限，普通用户本地调用vscode的docker插件无法获取镜像文件，需要将该用户加入到docker的组中，使用非root的方式运行，或者直接用root用户运行vscode。

### Latex编译

#### 使用`update-tlmgr-latest.sh`更新`tlmgr`工具

Texlive安装一般自带`update-tlmgr-latest.sh`脚本，但同济的这个模板仓库使用了精简安装(如scheme-infraonly)，找不到这个脚本，

参考：https://www.tug.org/texlive/upgrade.html

#### 安装宏包

`style`下的`tongjithesis.cls`文件是同济的模板文件(第三方)，`circle