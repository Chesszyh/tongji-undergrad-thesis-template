> 文章原地址：https://tug.org/texlive/quickinstall.html

# TeX Live - Unix 快速安装

如果您不想费心阅读完整的安装文档，只想在类 Unix 系统上安装 TeX Live 的所有内容，下面是一个最简化的步骤。

*   对于 macOS (以及 MacOSX)，我们建议安装 [MacTeX](https://tug.org/mactex/)，它有一个原生的 Mac 安装程序，并且包含了 TeX Live 的所有内容 (以及一些 Mac 特有的附加功能)。
*   对于 Cygwin，以下适用于类 Unix 系统的说明同样适用，但在开始安装之前，请确保您已满足 [Cygwin 的先决条件](https://tug.org/texlive/acquire-netinstall.html#cygwin)。
*   对于 ChromeOS，以下说明也适用，但在开始安装之前，请确保您已满足 [ChromeOS 的先决条件](https://tug.org/texlive/acquire-netinstall.html#chromeos)。
*   对于 Android，其他网页描述了该过程：[texlive-on-android](https://github.com/TeXLive/texlive-on-android/wiki), [termux-TeX_Live](https://github.com/termux/termux-packages/tree/master/packages/texlive)。
*   对于 iOS，另一个网页：[TeX Live for iPhone](https://github.com/holzschu/a-shell/blob/master/docs/TeXLive.md)。
*   Windows 用户：请参阅 [TeX Live on Windows](https://tug.org/texlive/windows.html) 页面。

## tl;dr: Unix(ish)

在除 Windows 外的任何系统上进行非交互式默认安装：

````bash
cd /tmp # 您选择的工作目录
# 下载:
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
# 或者:
curl -L -o install-tl-unx.tar.gz https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
# (或通过您喜欢的任何其他方法)
zcat < install-tl-unx.tar.gz | tar xf - # 注意该命令行末尾的 -
cd install-tl-2*
perl ./install-tl --no-interaction # 以 root 身份或使用可写的目标路径
# 可能需要几个小时才能运行
# 最后，将 /usr/local/texlive/YYYY/bin/PLATFORM 添加到您的 PATH 环境变量中，
# 例如：/usr/local/texlive/2025/bin/x86_64-linux
````

更改默认设置：

*   默认纸张大小为 a4。如果您希望默认值为 letter，请将 `--paper=letter` 添加到 `install-tl` 命令中。
*   默认情况下，所有内容都会被安装 (7+GB)。
    *   要安装较小的 scheme (组件集合)，请将 `--scheme=scheme` 传递给 `install-tl`。例如，`--scheme=small` 对应于 MacTeX 的 BasicTeX 变体。
    *   要省略文档或源文件的安装，请分别将 `--no-doc-install` `--no-src-install` 传递给 `install-tl`。
*   要更改主要的安装目录 (很少需要)，请将 `--texdir=/your/install/dir` 添加到 `install-tl`。要更改每个用户目录的位置 (TEXMFHOME 和其他目录将被找到的地方)，请指定 `--texuserdir=/your/dir`。
*   要更改任何其他设置，请省略 `--no-interaction`。然后您将进入一个交互式安装菜单。

## tl;dr: Mac

Unix 的安装说明同样适用。如果您更喜欢原生的 Mac 安装程序，请改用 [MacTeX](https://tug.org/mactex/)。

## tl;dr: Windows

1.  下载 [https://mirror.ctan.org/systems/texlive/tlnet/install-tl-windows.exe](https://mirror.ctan.org/systems/texlive/tlnet/install-tl-windows.exe)
2.  执行新下载的 `install-tl-windows.exe`。
3.  根据需要更改设置并安装。
4.  [其他 Windows 特定信息](https://tug.org/texlive/windows.html)。

本页的其余部分更详细地解释了上述内容。

## 安装前：下载、清理

您不需要移除先前版本的安装，也不需要移除任何系统提供的 TeX；多个 TL 版本可以在同一系统上共存而不会发生冲突。

一个[单独的页面](https://tug.org/texlive/acquire.html)描述了获取软件的各种方法。归结起来，要么从 TeX 用户组获取 DVD (理想情况下是通过成为会员)，要么通过各种方式下载。除了 Windows，您的系统必须提供标准的 Perl 安装以及通常的核心模块。(对于 Windows，TeX Live 自带 Perl。)

对于通过下载进行的常规安装，如果您没有 LWP Perl 包，我们强烈建议您安装它。

如果您在先前尝试失败后重新安装，请务必彻底移除失败的安装。默认情况下，在类 Unix 系统上，这些目录会是：

````bash
rm -rf /usr/local/texlive/2025
rm -rf ~/.texlive2025
````

## 运行安装程序

您不需要 root (Windows 上的管理员) 权限来安装、使用或管理 TeX Live。实际上，我们建议以普通用户身份安装它，除非在 macOS 上，通常以管理员身份安装。(关于[共享安装的信息](https://tug.org/texlive/doc/texlive-en/texlive-en.html#tlshared))。与往常一样，您需要有权写入目标目录，但 TeX Live 本身并不关心您是否是 root。

一旦您拥有 TeX Live 发行版，运行 `install-tl` 脚本进行安装 (在 Windows 上是 `install-tl-windows`)，如下所示：

````bash
cd /your/unpacked/directory
perl install-tl
# [... 省略消息 ...]
# Enter command: i
# [... 完成后，请参阅下面的安装后步骤 ...]
````

要更改安装目录或其他选项，请阅读提示和说明。默认设置是安装到以发行年份命名的并行目录中，这样任何给定的发行版都可以独立运行，只需调整搜索路径即可。

## 安装程序界面：文本、GUI、批处理

安装程序支持文本、图形和批处理界面：

*   `install-tl -gui text`
    使用纯文本界面 (命令行) 模式。这是类 Unix 系统 (包括 Mac) 上的默认设置。
*   `install-tl -gui`
    是默认的图形 GUI。启动时它提供的选项很少，但有一个“高级”按钮可以进行更多配置。这是 Windows 和 Mac 上的默认设置。它需要 Tcl/Tk，MacOS Monterey 之前的版本中包含此组件，Windows 版本也提供此组件。
*   `install-tl --profile=profile`
    执行批处理 (无人值守) 安装。要创建这样的配置文件，最简单的方法是使用安装程序在任何成功安装结束时写入的 `tlpkg/texlive.profile` 文件。

有关所有安装程序选项的信息，请运行 `install-tl --help`，或参阅 [install-tl 文档页面](https://tug.org/texlive/doc/install-tl.html)。

## 选择下载主机

根据安装方法，复制所有文件可能需要一个小时或更长时间。如果您通过网络下载，默认情况下会自动选择附近的 CTAN 镜像。如果遇到问题，我们建议选择一个特定的镜像，然后运行 `install-tl --location https://mirror.example.org/ctan/path/systems/texlive/tlnet`，而不是依赖自动重定向。

## 安装后：设置 PATH

安装完成后，您必须将 TeX Live 二进制文件的目录添加到您的 PATH 环境变量中——Windows 除外，Windows 安装程序会处理这个问题。安装程序会显示应添加的确切行。例如，对于 Bourne 兼容的 shell (例如，在 `~/.profile` 或 `~/.bashrc` 中)：

````bash
PATH=/usr/local/texlive/2025/bin/x86_64-linux:$PATH
````

请使用适合您的 shell 的初始化文件和语法，以及您的安装目录和二进制平台名称，而不是 `x86_64-linux`。编辑初始化文件后，注销并重新登录。

如果您在一台机器上有多个 TeX 安装，则需要更改搜索路径以在它们之间切换——MacOSX 除外。

## 安装后：设置默认纸张大小

默认情况下，程序配置为 A4 纸张大小。要将默认纸张大小设置为 8.5x11 英寸的 letter 纸张，您可以在 i(nstalling) 之前使用“o”菜单选项，或者在安装后 (并设置 PATH 后) 运行 `tlmgr paper letter`。

## 测试

成功安装后，请尝试处理简单的测试文档，例如 `latex small2e`。

如果您正在寻找用于编辑文件的前端：TeX Live 在 Windows 上安装 TeXworks，MacTeX 安装 TeXShop。还有大量[专用的 TeX 编辑器](https://tug.org/interest.html#editors)可供选择。此外，任何纯文本编辑器都可以工作。

## 获取更新

如果您想在安装后从 CTAN 更新软件包，请参阅这些[使用 tlmgr 的示例](https://tug.org/texlive/doc/tlmgr.html#EXAMPLES)。这不是必需的，甚至不一定推荐；您需要根据自己的具体情况决定是否需要持续更新。

通常，主要二进制文件在 TeX Live 的主要版本之间不会更新。如果您想获取尚未正式发布的 LuaTeX 和其他软件包和程序的更新，它们可能在 [TLContrib 仓库](https://contrib.texlive.info/)中提供，或者您可能需要自己编译源代码。

## 报告问题

有关错误报告信息，请参阅[已知问题页面](https://tug.org/texlive/bugs.html)。并请检查[文档](https://tug.org/texlive/doc.html)。
