# This tmux statusbar config was created by tmuxline.vim
# on Thu, 05 Oct 2017

setw -g pane-border-format "  #[fg=colour#{?pane_active,31,242}]#[fg=black,bg=colour#{?pane_active,31,242}]-- #{pane_index} #[fg=colour#{?pane_active,244,238}]#[fg=black]#[bg=colour#{?pane_active,244,238}]#{pane_title}#[default]#[fg=colour#{?pane_active,244,238}]  "
set -g status-justify "centre"
set -g status "on"
set -g status-attr "none"
set -g message-command-bg "colour31"
set -g status-left-length "100"
set -g pane-active-border-fg "colour31"
set -g pane-border-fg "colour238"
set -g status-bg "colour234"
set -g message-command-fg "colour231"
set -g message-bg "colour31"
set -g status-left-attr "none"
set -g status-right-attr "none"
set -g status-right-length "100"
set -g message-fg "colour231"
setw -g window-status-fg "colour250"
setw -g window-status-attr "none"
setw -g window-status-activity-bg "colour234"
setw -g window-status-activity-attr "underscore"
setw -g window-status-activity-fg "colour250"
setw -g window-status-separator ""
setw -g window-status-bg "colour234"
set -g status-left "#[fg=colour16,bg=colour254,bold][#(uname -n | cut -d. -f1 | tr a-z A-Z)]#[fg=colour254,bg=colour234,nobold,nounderscore,noitalics]"
set -g status-right "#[fg=colour232,bg=colour234,nobold,nounderscore,noitalics]#[fg=colour250,bg=colour232] #[fg=colour236,bg=colour232]#[fg=colour247,bg=colour236] #[bold,fg=colour202]#S#[nobold,fg=colour252]  #{?mouse,MSE ,}#[fg=colour252,bg=colour236,nobold]#[fg=colour235,bg=colour252]#{cpu_percentage}"
setw -g window-status-format "#[fg=colour234,bg=colour238]#[bg=colour238,fg=colour254]#F #W#[fg=colour238,bg=colour234]#[default]"
setw -g window-status-current-format "#[fg=colour234,bg=colour31,nobold,nounderscore,noitalics]#[fg=colour231,bg=colour31,bold] #W #[fg=colour31,bg=colour234,nobold,nounderscore,noitalics]"
