# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/mk/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="instantos"
ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_AUTOCONNECT=false

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME="instantos"
ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_AUTOCONNECT=false
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

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
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git common-aliases archlinux autojump instantos zsh-z)
[ -n "$DISPLAY" ] && plugins+=(tmux)

source $ZSH/oh-my-zsh.sh

# Source tmux config
tmux source-file ~/.config/tmux/.tmux.conf

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

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# clang
export PATH="/opt/clang-format-static:$PATH"

#lit
export PATH="~/Documents/repos/lit/bin:$PATH"

# appimage
export PATH="/home/mk/.cache/appimage:$PATH"

# vulkan
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json

VULKAN_SDK="/home/mk/.local/share/vulkan/x86_64"
export VULKAN_SDK
export PATH="$VULKAN_SDK/bin:$PATH"
export LD_LIBRARY_PATH=$VULKAN_SDK/lib
export VK_LAYER_PATH=$VULKAN_SDK/etc/vulkan/explicit_layer.d

# rust
# export CARGO_HOME="/home/mk/.config/cargo"
# export RUSTUP_HOME="/home/mk/.config/rustup"

prompt_context() {}
# fish like syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export BAT_THEME="ansi-dark"

function spell() {
  bash "/home/mk/Documents/spell.sh $1"
}

# open ~/.zshrc in using the default editor specified in $EDITOR
alias ec="$EDITOR $XDG_CONFIG_HOME/zsh/.zshrc"

# source ~/.zshrc
alias sc="source $XDG_CONFIG_HOME/zsh/.zshrc"

alias yas="yay -S --noconfirm"

alias ze="z -e"

alias yar="yay -Rcns"

alias ads="~/Documents/androidshare.sh"

alias bd="~/Documents/brightness.sh down"

alias bu="~/Documents/brightness.sh up"

alias eb="sudo nvim /usr/bin/instantstatus"

alias v="nvim"

alias la="exa --icons -l -a"

alias du="dust"

# podman
alias docker="podman"

# sonar
export SONAR_SCANNER_HOME="/opt/sonar-scanner"
export PATH="${PATH}:${SONAR_SCANNER_HOME}/bin"

# add dotnet script
export PATH="$PATH:/home/mk/.dotnet/tools"

up-directory() {
    builtin cd .. && zle reset-prompt
}

zle -N up-directory
bindkey '^x' up-directory

alias opennewterm="st >/dev/null 2>&1 & disown"
zle -N opennewterm
bindkey -s '^y' "opennewterm\n"

[ -f $XDG_CONFIG_HOME/fzf/.fzf.zsh ] && source $XDG_CONFIG_HOME/fzf/.fzf.zsh


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
