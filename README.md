总体方法
使用tmux+zshell+nvim开发，本repo可以实现本地和远程在无联网状态下快速配置

思路，先安装tmux zshell nvim，再通过stow配置

安装
zshell
查看本机系统，找到对应的安装包，并安装在home/local下
下载并解压，进入对应目录 https://sourceforge.net/projects/zsh/files/zsh/
运行 ./Util/preconfig
运行 ./configure --prefix=$HOME/.local
运行 make make install
zsh在 local/bin/zsh

export LD_LIBRARY_PATH="$HOME/.local/lib64:$HOME/.local/lib:$LD_LIBRARY_PATH"
export PATH="$HOME/.local/bin:$PATH"
exec zsh -l


