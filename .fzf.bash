# Setup fzf
# ---------
[[ -d /usr/local/opt/fzf/shell ]] || return 

if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
fi

# Auto-completion
# ---------------
FZF_COMPLETION_TRIGGER='``'
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/usr/local/opt/fzf/shell/key-bindings.bash"

source ~/thm-dotfiles/files/fzf.bash

