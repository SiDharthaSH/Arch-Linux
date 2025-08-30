# ~/.bashrc
#-------------------------------------------------------------------------------
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# aliases for basic colored output
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# flexing arch logo
fastfetch

# using starship for prompt
eval "$(starship init bash)"
