总体方法
使用tmux+zshell+nvim开发，本repo可以实现本地和远程在无联网状态下快速配置

思路，先安装tmux zshell nvim，再通过stow配置

远程安装stow
下载并解压，进入对应目录 https://ftp.gnu.org/gnu/stow/stow-2.4.1.tar.gz
./configure --prefix=$HOME/.local
make
make install
它可以把当前文件通过link同步到合适的位置
在远程要把git关掉要不太慢 git config --global oh-my-zsh.hide-status 1

远程安装 zshell
查看本机系统，找到对应的安装包，并安装在home/local下, 避免sudo权限问题
下载并解压，进入对应目录 https://sourceforge.net/projects/zsh/files/zsh/
运行 ./Util/preconfig
运行 ./configure --prefix=$HOME/.local
运行 make make install
zsh在 local/bin/zsh

在当前默认shell的启动项里加入
export LD_LIBRARY_PATH="$HOME/.local/lib64:$HOME/.local/lib:$LD_LIBRARY_PATH"
export PATH="$HOME/.local/bin:$PATH"
exec zsh -l

配置zshell
bullet train的 theme在oh-my-shell下
需要在每台机器单独运行 conda init zsh，把钩子写入zshrc

zsh 插件安装
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git zsh-syntax-highlighting
放到 .oh-my-zsh/custom/plugins
注意先把 .git删了
在.zshrc中加入
plugins+=( zsh-syntax-highlighting )

安装tmux
只需要在本地电脑安装，配置文件是.tmux.conf


远程安装nvim
https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage
ln -s "$(pwd)/nvim-linux-x86_64.appimage" ~/.local/bin/nvim

安装nvim插件
都放到 ~/.local/share/nvim/site/pack/jinqiu/start/v

ssh 端粘贴到系统剪切板
只用纯终端的 OSC52+DCS 就能搞定跨 SSH、tmux 的剪贴板同步使用vim-oscyank
