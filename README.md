总体方法
使用tmux+zshell+nvim开发
1. 代码都在本地编辑。copilot，颜色高亮等功能都需要本地编辑器支持。且本地编辑速度快。
2. 测试方法：1）本地提交，2）远程提交：notebook操作，需要用iron连接到ipython kernal，3）远程提交：通过mutagen将本地代码自动同步到远程。
3. 本地不存储训练和测试数据，便于数据共享，减少本地和远程数据同步压力。

工具介绍
tmux：一个终端复用工具，可以在一个终端窗口中运行多个会话，支持分屏和会话管理。
zshell：一个强大的shell，支持插件和主题，提供更好的用户体验。
stow：一个符号链接管理工具，可以将配置文件链接到合适的位置，便于配置管理。
mutagen：一个文件同步工具，可以在本地和远程之间自动同步文件，支持增量同步和双向同步。
nvim：一个现代化的文本编辑器，支持插件和主题，提供更好的用户体验。

本地运行：tmux+zshell(重配置)+nvim(重配置)+mutagen，通过stow管理配置文件。
远程运行：zshell(轻配置)+nvim(轻配置)，通过stow管理配置文件。

无网的远程安装方法
stow
下载并解压，进入对应目录 https://ftp.gnu.org/gnu/stow/stow-2.4.1.tar.gz
./configure --prefix=$HOME/.local
make
make install

zshell
查看本机系统，找到对应的安装包，并安装在home/local下, 避免sudo权限问题
下载并解压，进入对应目录 https://sourceforge.net/projects/zsh/files/zsh/
运行 ./Util/preconfig
运行 ./configure --prefix=$HOME/.local
运行 make make install
zsh在 local/bin/zsh

nvim
https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage
ln -s "$(pwd)/nvim-linux-x86_64.appimage" ~/.local/bin/nvim

配置方法

mutagen
mutagen.yml仅在每个需要同步的目录下创建一次，因为创建会比较慢，最好是人工来。

zshell
bullet train的 theme在oh-my-shell下
需要在每台机器单独运行 conda init zsh，把钩子写入zshrc
插件通过git下载，放到 .oh-my-zsh/custom/plugins 注意先把 .git删了 在.zshrc中加入 plugins+=( zsh-syntax-highlighting )
远程把git关掉要zshell太慢 git config --global oh-my-zsh.hide-status 1

在当前默认shell的启动项里加入，以便自动启动zsh
export LD_LIBRARY_PATH="$HOME/.local/lib64:$HOME/.local/lib:$LD_LIBRARY_PATH"
export PATH="$HOME/.local/bin:$PATH"
exec zsh -l

tmux
.tmux.conf

nvim
chaj都放到 .local/share/nvim/site/pack/jinqiu/start/

都粘贴到系统剪切板,远程的剪切板和本地隔离, 通过OSC52可以将远程的内容同步到本地，但没找到把本地同步到远程的方法。本地复制的内容只能ctrl+V到远程

notebook
1. 需要有一个可以运行的ipython kernal。
2. 需要用iron通过jupyter console连接到ipython kernal。这个是纯本地配置。
3. 如果需要远程连接到ipython kernal，需要把远程的kernal.json文件放到本地，再把ssh tunnel建立。
