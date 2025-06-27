# ClashX HTTP 代理端口
export HTTP_PROXY="http://127.0.0.1:7890"
export HTTPS_PROXY="http://127.0.0.1:7890"
# ClashX SOCKS5 代理端口
export ALL_PROXY="socks5://127.0.0.1:7891"

# If you come from bash you might have to change your $PATH.
export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/local/sbin:$HOME/bin:$PATH
export PATH=/opt/homebrew/opt/mysql@5.7/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh
export VG_NAME=lexus-quest-9
export PD_NAME=adhoc04-sjc1
export TZ=/usr/share/zoneinfo/Asia/Shanghai

export PATH="/usr/local/opt/mysql-client/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
# export PATH="/Users/dengjinqiu/opt/anaconda3/bin:$PATH"  # commented out by conda initialize
export PATH="/usr/local/bin:$PATH"

export JAVA_HOME=$(/usr/libexec/java_home)
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles

# 检查并启动到 cpu-ea 的 Jupyter 隧道
function ensure_ea_tunnel() {
  # 检测本地是否已有监听 57499 端口的进程
  if lsof -iTCP:57499 -sTCP:LISTEN >/dev/null 2>&1; then
    # Tunnel 已存在
    :
  else
    echo "▶️ 为连接远程jupyter kernal 启动 cpu-ea SSH 隧道..."
    ssh -fN \
      -L 57499:127.0.0.1:57499 \
      -L 45013:127.0.0.1:45013 \
      -L 58863:127.0.0.1:58863 \
      -L 45395:127.0.0.1:45395 \
      -L 37653:127.0.0.1:37653 \
      cpu-ea
  fi
}

# 只对交互式、且非 SSH 会话 生效
if [[ $- == *i* ]] && [[ -z "$SSH_CONNECTION" ]]; then
  ensure_ea_tunnel
fi

# 在 SSH 会话且脚本未运行时，后台启动 gpu_matrix_multi.py
if [[ -n "$SSH_CONNECTION" ]] && ! pgrep -f "gpu_matrix_multi\.py" >/dev/null; then
  echo "▶️ 启动 gpu_matrix_multi.py 后台任务..."
  nohup python "$HOME/gpu_matrix_multi.py" >/dev/null 2>&1 &
fi

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#
# theme bullet-train
# 如果是 SSH 会话，覆盖成红色背景
if [[ -n $SSH_CONNECTION ]]; then
  export BULLETTRAIN_IS_SSH_CLIENT=1
  export BULLETTRAIN_CONTEXT_BG=216
  export BULLETTRAIN_CONTEXT_FG=0
fi

ZSH_THEME="bullet-train"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    vim-mode
    vi-mode
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-history-substring-search
)

source $ZSH/oh-my-zsh.sh
# 直接把 context() 重写，只显示 hostname
context() {
  echo -n "$BULLETTRAIN_CONTEXT_HOSTNAME"
}

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias vim='nvim'

# 开启 vi 模式
bindkey -v

# 1) 定义一个 ZLE 钩子函数，根据当前 keymap 切换光标
function zle-keymap-select {
  case $KEYMAP in
    vicmd)  # Normal 模式，用方块
      echo -ne '\e[2 q'
      ;;
    viins|main)  # Insert 模式，用竖线
      echo -ne '\e[6 q'
      ;;
  esac
  # 重绘 prompt，确保新光标生效
  zle reset-prompt
}
# 把上面的函数关联给 zle
zle -N zle-keymap-select

# 2) 在每次新的 line 编辑开始时也触发一次（比如刚打开 shell）
function zle-line-init {
  zle-keymap-select
}
zle -N zle-line-init


bindkey '^n' autosuggest-accept
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=6'

# 加载颜色支持
autoload -Uz colors && colors

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/dengjinqiu/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/dengjinqiu/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/dengjinqiu/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/dengjinqiu/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
