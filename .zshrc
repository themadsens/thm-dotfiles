# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/fm/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Appends every command to the history file once it is executed
setopt inc_append_history
# Reloads the history whenever you use it
setopt share_history


# CASE_SENSITIVE="true"
HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_TITLE="true"
# ENABLE_CORRECTION="true"
# COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="yyyy-mm-dd"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
bower
brew
command-not-found
dircycle
gitfast
sudo
svn
web-search
)

source $ZSH/oh-my-zsh.sh

source ~/thm-dotfiles/.sh-common

precmd() {
}

#source '/Users/fm/.zplugin/bin/zplugin.zsh'
#autoload -Uz _zplugin
#(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin's installer chunk
#zplugin load psprint zsh-navigation-tools


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
