#-------------------------------------------------------------------------------
# References:
#-------------------------------------------------------------------------------
# Color table - https://jonasjacek.github.io/colors/
# Wincent's dotfiles - https://github.com/wincent/wincent/blob/d6c52ed552/aspects/dotfiles/files/.zshrc
# https://github.com/vincentbernat/zshrc/blob/d66fd6b6ea5b3c899efb7f36141e3c8eb7ce348b/rc/vcs.zsh
# sourcing autoloaded functions:
# https://unix.stackexchange.com/questions/33255/how-to-define-and-load-your-own-shell-function-in-zsh
# Git prompt script: https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh

zmodload zsh/datetime

# Create a hash table for globally stashing variables without polluting main
# scope with a bunch of identifiers.
typeset -A __DOTS

__DOTS[ITALIC_ON]=$'\e[3m'
__DOTS[ITALIC_OFF]=$'\e[23m'

# ZSH only and most performant way to check existence of an executable
# https://www.topbug.net/blog/2016/10/11/speed-test-check-the-existence-of-a-command-in-bash-and-zsh/
exists() { (( $+commands[$1] )); }

_comp_options+=(globdots) # Include hidden files.

if exists brew; then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi
# Add the zsh directory to the autoload dirs
fpath+=($ZDOTDIR/zsh-functions)

# Init completions
autoload -Uz compinit
compinit

source $ZDOTDIR/plugins.zsh
#-------------------------------------------------------------------------------
#           SOURCE PLUGINS
#-------------------------------------------------------------------------------
# These should be source *BEFORE* setting up hooks
zsh_add_plugin    "zsh-users/zsh-syntax-highlighting"
zsh_add_plugin    "zsh-users/zsh-autosuggestions"
zsh_add_plugin    "zsh-users/zsh-completions"
zsh_add_plugin    "djui/alias-tips"
zsh_add_plugin    "MichaelAquilina/zsh-auto-notify" "auto-notify.plugin"
zsh_add_plugin    "hlissner/zsh-autopair"
zsh_source_plugin "last-working-dir/last-working-dir"
autoload zmv # builtin zsh rename command
#-------------------------------------------------------------------------------
#               COMPLETION
#-------------------------------------------------------------------------------
# Completion for kitty
if [[ "$TERM" == "xterm-kitty" ]]; then
  kitty + complete setup zsh | source /dev/stdin
fi

# Colorize completions using default `ls` colors.
zstyle ':completion:*' list-colors ''

# Enable keyboard navigation of completions in menu
# (not just tab/shift-tab but cursor keys as well):
zstyle ':completion:*' menu select
zmodload zsh/complist

# use the vi navigation keys in menu completion
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# persistent reshahing i.e puts new executables in the $path
# if no command is set typing in a line will cd by default
zstyle ':completion:*' rehash true

# Allow completion of ..<Tab> to ../ and beyond.
zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(..) ]] && reply=(..)'

# Categorize completion suggestions with headings:
zstyle ':completion:*' group-name ''
# Style the group names
zstyle ':completion:*' format %F{magenta}%B%U%{$__DOTS[ITALIC_ON]%}%d%{$__DOTS[ITALIC_OFF]%}%b%u%f

# Added by running `compinstall`
zstyle ':completion:*' expand suffix
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' list-suffixes true
# End of lines added by compinstall

# Make completion:
# (stolen from Wincent)
# - Try exact (case-sensitive) match first.
# - Then fall back to case-insensitive.
# - Accept abbreviations after . or _ or - (ie. f.b -> foo.bar).
# - Substring complete (ie. bar -> foobar).
zstyle ':completion:*' matcher-list '' '+m:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}' '+m:{_-}={-_}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
#-------------------------------------------------------------------------------
#               OPTIONS
#-------------------------------------------------------------------------------
setopt AUTO_CD
setopt RM_STAR_WAIT
setopt CORRECT                  # command auto-correction
setopt COMPLETE_ALIASES
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt AUTOPARAMSLASH            # tab completing directory appends a slash
setopt SHARE_HISTORY             # Share your history across all your terminal windows
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits
setopt AUTO_PUSHD                # Push the current directory visited on the stack.
setopt PUSHD_IGNORE_DUPS         # Do not store duplicates in the stack.
setopt PUSHD_SILENT              # Do not print the directory stack after pushd or popd.

# Keep a ton of history.
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=$ZDOTDIR/.zsh_history

#-------------------------------------------------------------------------------
#               VI-MODE
#-------------------------------------------------------------------------------
# @see: https://thevaluable.dev/zsh-install-configure-mouseless/
bindkey -v # enables vi mode, using -e = emacs
export KEYTIMEOUT=1

# Add vi-mode text objects e.g. da" ca(
autoload -Uz select-bracketed select-quoted
zle -N select-quoted
zle -N select-bracketed
for km in viopp visual; do
  bindkey -M $km -- '-' vi-up-line-or-history
  for c in {a,i}${(s..)^:-\'\"\`\|,./:;=+@}; do
    bindkey -M $km $c select-quoted
  done
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $km $c select-bracketed
  done
done

# Mimic tpope's vim-surround
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -M vicmd cs change-surround
bindkey -M vicmd ds delete-surround
bindkey -M vicmd ys add-surround
bindkey -M visual S add-surround

# https://superuser.com/questions/151803/how-do-i-customize-zshs-vim-mode
# http://pawelgoscicki.com/archives/2012/09/vi-mode-indicator-in-zsh-prompt/
vim_ins_mode=""
vim_cmd_mode="%F{green} %f"
vim_mode=$vim_ins_mode

function zle-keymap-select {
  vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
  set-prompt
  zle && zle reset-prompt
}
zle -N zle-keymap-select

function zle-line-finish {
  vim_mode=$vim_ins_mode
}
zle -N zle-line-finish

# When you C-c in CMD mode and you'd be prompted with CMD mode indicator,
# while in fact you would be in INS mode Fixed by catching SIGINT (C-c),
# set vim_mode to INS and then repropagate the SIGINT,
# so if anything else depends on it, we will not break it
function TRAPINT() {
  vim_mode=$vim_ins_mode
  return $(( 128 + $1 ))
}

cursor_mode() {
  # See https://ttssh2.osdn.jp/manual/4/en/usage/tips/vim.html for cursor shapes
  cursor_block='\e[2 q'
  cursor_beam='\e[6 q'

  function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] ||
        [[ $1 = 'block' ]]; then
        echo -ne $cursor_block
    elif [[ ${KEYMAP} == main ]] ||
        [[ ${KEYMAP} == viins ]] ||
        [[ ${KEYMAP} = '' ]] ||
        [[ $1 = 'beam' ]]; then
        echo -ne $cursor_beam
    fi
  }

  zle-line-init() {
    echo -ne $cursor_beam
  }

  zle -N zle-keymap-select
  zle -N zle-line-init
}

cursor_mode
#-------------------------------------------------------------------------------
#               Version control
#-------------------------------------------------------------------------------
# vcs_info is a zsh native module for getting git info into your
# prompt. It's not as fast as using git directly in some cases
# but easy and well documented.
# http://zsh.sourceforge.net/Doc/Release/User-Contributions.html
# %c - git staged
# %u - git untracked
# %b - git branch
# %r - git repo
autoload -Uz vcs_info

# Using named colors means that the prompt automatically adapts to how these
# are set by the current terminal theme
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "%F{green} ●%f"
zstyle ':vcs_info:*' unstagedstr "%F{red} ✗%f"
zstyle ':vcs_info:*' use-simple true
zstyle ':vcs_info:git+set-message:*' hooks git-untracked git-stash
zstyle ':vcs_info:git*:*' actionformats '(%B%F{red}%b|%a%c%u%%b%f) '
zstyle ':vcs_info:git:*' formats "%F{249}(%f%F{blue}%{$__DOTS[ITALIC_ON]%}%b%{$__DOTS[ITALIC_OFF]%}%f%F{249})%f%c%u"

__in_git() {
    [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == "true" ]]
}

# TODO: these functions should not be run outside of a git repository
# this function adds a hook to the git vcs_info backend that depending
# they can also be quite slow...
# on the output of the git command adds an indicator to the the vcs info
# use --directory and --no-empty-directory to speed up command
# https://stackoverflow.com/questions/11122410/fastest-way-to-get-git-status-in-bash
function +vi-git-untracked() {
  emulate -L zsh
  if __in_git; then
    if [[ -n $(git ls-files --directory --no-empty-directory --exclude-standard --others 2> /dev/null) ]]; then
      hook_com[unstaged]+="%F{blue} %f"
    fi
  fi
}

function +vi-git-stash() {
  local stash_icon=""
  emulate -L zsh
  if __in_git; then
    if [[ -n $(git rev-list --walk-reflogs --count refs/stash 2> /dev/null) ]]; then
      hook_com[unstaged]+=" %F{yellow}$stash_icon%f "
    fi
  fi
}

autoload -Uz fill_line && fill_line
#-------------------------------------------------------------------------------
#               Prompt
#-------------------------------------------------------------------------------
# Sets PROMPT and RPROMPT.
#
# %F...%f - - foreground color
# toggle color based on success %F{%(?.green.red)}
# %F{a_color} - color specifier
# %B..%b - bold
# %* - reset highlight
# %j - background jobs
#
# Requires: prompt_percent and no_prompt_subst.
function set-prompt() {
  emulate -L zsh
  # directory(branch)                     10:51
  # ❯  █
  #
  # icon options =  ❯   
  #
  # Top left:     directory(gitbranch) ● ●
  # Top right:    Time
  # Bottom left:  ➜
  # Bottom right: empty
  local dots_prompt_icon="%F{magenta}➜ %f"
  local dots_prompt_failure_icon="%F{red}✘ %f"
  local execution_time="%F{yellow}%{$__DOTS[ITALIC_ON]%}${cmd_exec_time}%{$__DOTS[ITALIC_OFF]%}%f "

  local placeholder="(%F{blue}%{$__DOTS[ITALIC_ON]%}…%{$__DOTS[ITALIC_OFF]%}%f)"
  local top_left="%B%F{10}%1~%f%b${_git_status_prompt:-$placeholder}"
  local top_right="${vim_mode}${execution_time}%F{240}%*%f"
  local bottom_left="%(1j.%F{cyan}%j✦%f .)%(?.${dots_prompt_icon}.${dots_prompt_failure_icon})"

  PROMPT="$(fill_line "$top_left" "$top_right")"$'\n'$bottom_left
}

# Correction prompt
export SPROMPT="correct %F{red}'%R'%f to %F{red}'%r'%f [%B%Uy%u%bes, %B%Un%u%bo, %B%Ue%u%bdit, %B%Ua%u%bbort]? "

setopt noprompt{bang,subst} prompt{cr,percent,sp}
#-------------------------------------------------------------------------------
#           Execution time
#-------------------------------------------------------------------------------
# Inspired by https://github.com/sindresorhus/pure/blob/81dd496eb380aa051494f93fd99322ec796ec4c2/pure.zsh#L47
#
# Turns seconds into human readable time.
# 165392 => 1d 21h 56m 32s
# https://github.com/sindresorhus/pretty-time-zsh
__human_time_to_var() {
  local human total_seconds=$1 var=$2
  local days=$(( total_seconds / 60 / 60 / 24 ))
  local hours=$(( total_seconds / 60 / 60 % 24 ))
  local minutes=$(( total_seconds / 60 % 60 ))
  local seconds=$(( total_seconds % 60 ))
  (( days > 0 )) && human+="${days}d "
  (( hours > 0 )) && human+="${hours}h "
  (( minutes > 0 )) && human+="${minutes}m "
  human+="${seconds}s"

  # Store human readable time in a variable as specified by the caller
  typeset -g "${var}"="${human}"
}

# Stores (into cmd_exec_time) the execution
# time of the last command if set threshold was exceeded.
__check_cmd_exec_time() {
  integer elapsed
  (( elapsed = EPOCHSECONDS - ${cmd_timestamp:-$EPOCHSECONDS} ))
  typeset -g cmd_exec_time=
  (( elapsed > 1 )) && {
    __human_time_to_var $elapsed "cmd_exec_time"
  }
}

__timings_preexec() {
  emulate -L zsh
  typeset -g cmd_timestamp=$EPOCHSECONDS
}

__timings_precmd() {
  __check_cmd_exec_time
  unset cmd_timestamp
}
#-------------------------------------------------------------------------------
#           HOOKS
#-------------------------------------------------------------------------------
autoload -Uz add-zsh-hook
# Async prompt in Zsh
# Rather than using zpty (a pseudo terminal) under the hood
# as is the case with zsh-async this method forks a process sends
# it the command to evaluate which is written to a file descriptor
#
# *fd - file descriptor
#
# https://www.zsh.org/mla/users/2018/msg00424.html
# https://github.com/sorin-ionescu/prezto/pull/1805/files#diff-6a24e7644c4c0969110e86872283ec82L79
# https://github.com/zsh-users/zsh-autosuggestions/pull/338/files
__async_vcs_start() {
  # Close the last file descriptor to invalidate old requests
  if [[ -n "$__prompt_async_fd" ]] && { true <&$__prompt_async_fd } 2>/dev/null; then
    exec {__prompt_async_fd}<&-
    zle -F $__prompt_async_fd
  fi
  # fork a process to fetch the vcs status and open a pipe to read from it
  exec {__prompt_async_fd}< <(
    __async_vcs_info $PWD
  )

  # When the fd is readable, call the response handler
  zle -F "$__prompt_async_fd" __async_vcs_info_done
}

__async_vcs_info() {
  cd -q "$1"
  vcs_info
  print ${vcs_info_msg_0_}
}

# Called when new data is ready to be read from the pipe
__async_vcs_info_done() {
  # Read everything from the fd
  _git_status_prompt="$(<&$1)"
  # check if vcs info is returned, if not set the prompt
  # to a non visible character to clear the placeholder
  # NOTE: -z returns true if a string value has a length of 0
  if [[ -z $_git_status_prompt ]]; then
    _git_status_prompt=" "
  fi
  # remove the handler and close the file descriptor
  zle -F "$1"
  exec {1}<&-
  # reset the prompt
  set-prompt
  zle && zle reset-prompt
}

# When the terminal is resized, the shell receives a SIGWINCH signal.
# So redraw the prompt in a trap.
# https://unix.stackexchange.com/questions/360600/reload-zsh-when-resizing-terminator-window
#
# Resource: [TRAP functions]
# http://zsh.sourceforge.net/Doc/Release/Functions.html#Trap-Functions
function TRAPWINCH () {
  set-prompt
  zle && zle reset-prompt
}

add-zsh-hook precmd () {
  __timings_precmd
  __async_vcs_start # start async job to populate git info
  set-prompt
}

add-zsh-hook chpwd () {
  _git_status_prompt="" # clear current vcs_info
  chpwd_last_working_dir
}


add-zsh-hook preexec () {
  __timings_preexec
}
#-------------------------------------------------------------------------------
#   LOCAL SCRIPTS
#-------------------------------------------------------------------------------
# source all zsh and sh files
for script in $ZDOTDIR/scripts/*; do
  source $script
done

# reference - https://unix.stackexchange.com/questions/252166/how-to-configure-zshrc-for-specfic-os
case `uname` in
  Darwin)
    source "$DOTFILES/macos/init.sh"
    ;;
  Linux)
    source "$DOTFILES/linux/init.sh"
    ;;
esac
#-------------------------------------------------------------------------------
#  PLUGINS
#-------------------------------------------------------------------------------
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=241'
ZSH_AUTOSUGGEST_USE_ASYNC=1

# ZSH only and most performant way to check existence of an executable
# https://www.topbug.net/blog/2016/10/11/speed-test-check-the-existence-of-a-command-in-bash-and-zsh/
exists() { (( $+commands[$1] )); }

# TODO: also need to check for the existence of ~/.fzf/
if [ ! -f ~/.fzf.zsh ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
fi
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if exists hub; then
  eval "$(hub alias -s)" # Aliases 'hub' to git
fi

if [[ ! "$(exists nvr)" && "$(exists pip3)" ]]; then
  pip3 install neovim-remote
fi

if exists thefuck; then
  eval $(thefuck --alias)
fi

if exists zoxide; then
  eval "$(zoxide init zsh)"
fi

# NOTE: this needs to load here as it must happen after homebrew is intialized
# which happens in the .zprofile after the .zshenv has already been read
if exists pyenv; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

if [[ -n $KITTY_INSTALLATION_DIR ]]; then
  export KITTY_SHELL_INTEGRATION="enabled"
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
  kitty-integration
  unfunction kitty-integration
fi
#-------------------------------------------------------------------------------
#               MAPPINGS
#-------------------------------------------------------------------------------
export KEYTIMEOUT=1
bindkey ‘^R’ history-incremental-search-backward
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^U' autosuggest-accept
bindkey '^]' clear-screen
# Edit line in vim with v whilst in normal mod in vi mode
autoload -Uz edit-command-line;
zle -N edit-command-line
bindkey -M vicmd v edit-command-line
