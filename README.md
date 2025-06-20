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

stow
下载并解压，进入对应目录 https://ftp.gnu.org/gnu/stow/stow-2.4.1.tar.gz


./configure --prefix=$HOME/.local
make
make install

配置zshrc
bullet train的 theme在oh-my-shell下

需要在每台机器单独运行 conda init zsh，把钩子写入zshrc


zsh 插件
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git zsh-syntax-highlighting
放到 .oh-my-zsh/custom/plugins
注意先把 .git删了
在.zshrc中加入
plugins+=( zsh-syntax-highlighting )
