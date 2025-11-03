#### ~/.bashrc #############################################################
# Interactive Bash configuration for sam
# Organized: 2025-11-03
############################################################################

###---------------------------------------------------------------------###
### 0. ONLY CONTINUE FOR INTERACTIVE SHELLS
###---------------------------------------------------------------------###

case $- in
    *i*) ;;        # interactive -> continue
      *) return;;  # non-interactive -> bail early for speed
esac


###---------------------------------------------------------------------###
### 1. BASIC ENVIRONMENT / EXPORTS
###---------------------------------------------------------------------###

# Core programs
export BROWSER="firefox"
export EDITOR="nvim"
export VISUAL="nvim"
export CSCOPE_EDITOR="nvim"

# History
export HISTFILE="$HOME/.bash_history"
HISTSIZE=10000
# SAVEHIST=10000  # (zsh-style, unused in bash)

# Less config + colors
export LESSHISTFILE=-
export LESS_TERMCAP_mb=$'\e[1;36m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[1;37m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;34m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;34m'

# Default search command for fzf
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'

# libvirt default URI
export LIBVIRT_DEFAULT_URI='qemu:///system'

# GPG/tty
export GPG_TTY="$(tty)"

# nvm dir (actual loading is lazy, see below)
export NVM_DIR="$HOME/.nvm"

# flutter path
export PATH="/usr/bin/flutter/bin:$PATH"

# colored ls/grep/less with ~/.dir_colors
eval "$(dircolors ~/.dir_colors)"


###---------------------------------------------------------------------###
### 2. ALIASES
###---------------------------------------------------------------------###

# dotfiles git wrapper
alias config='/usr/bin/git --git-dir=/home/sam/.dotfiles/ --work-tree=/home/sam'

# quality of life
alias vim='nvim'
alias ls='ls --color=auto'
alias ll='ls -alh --color=auto'
alias grep='grep --color=auto'
alias clear='printf "\033c"'

# system info
alias neofetch='fastfetch'
alias fetch='fastfetch'

# disk usage of current dir (1 level)
alias lss='du -ah --max-depth 1'

# regenerate grub config and reinstall
alias grubup='sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck && sudo grub-mkconfig -o /boot/grub/grub.cfg'


###---------------------------------------------------------------------###
### 3. FUNCTIONS
###---------------------------------------------------------------------###

# 3.1 Archive extractor: ex <file>
ex() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"   ;;
            *.tar.gz)    tar xzf "$1"   ;;
            *.bz2)       bunzip2 "$1"   ;;
            *.rar)       unrar x "$1"   ;;
            *.gz)        gunzip "$1"    ;;
            *.tar)       tar xf "$1"    ;;
            *.tbz2)      tar xjf "$1"   ;;
            *.tgz)       tar xzf "$1"   ;;
            *.zip)       unzip "$1"     ;;
            *.Z)         uncompress "$1";;
            *.7z)        7za e x "$1"   ;;
            *.deb)       ar x "$1"      ;;
            *.tar.xz)    tar xf "$1"    ;;
            *.tar.zst)   unzstd "$1"    ;;
            *)           echo "'$1' cannot be extracted via ex()";;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# 3.2 Random prompt note (not currently used in PS1)
prompt_comment() {
    local DIR="$HOME/.local/share/promptcomments/"
    local MESSAGE
    MESSAGE="$(find "$DIR"/*.txt | shuf -n1 2>/dev/null)"
    [ -n "$MESSAGE" ] && cat "$MESSAGE"
}

# 3.3 Lightweight git status for prompt
# Output format e.g.: "main [ ! ? * ]"
# markers:
#   ! = branch ahead of remote
#   ? = untracked
#   + = added
#   * = modified
#   - = deleted
#   > = renamed
__git_info() {
    # Are we in a git repo?
    git rev-parse --is-inside-work-tree &>/dev/null || return

    local porcelain branch_line branch ahead marks
    local has_untracked has_added has_modified has_deleted has_renamed

    porcelain="$(git status --porcelain --branch 2>/dev/null)" || return

    # First line of --branch looks like:
    # "## main" OR "## main...origin/main [ahead 2]"
    branch_line="${porcelain%%$'\n'*}"
    branch_line="${branch_line#\#\# }"     # strip leading "## "
    branch="${branch_line%% *}"            # up to first space

    # ahead?
    if [[ "$branch_line" == *"ahead"* ]]; then
        ahead=" !"
    else
        ahead=""
    fi

    # scan body once for status flags
    if echo "$porcelain" | grep -q '^?? '; then
        has_untracked=" ?"
    fi
    if echo "$porcelain" | grep -q '^[AM]  '; then
        # staged added/modified = treat as added
        has_added=" +"
    fi
    if echo "$porcelain" | grep -q '^.[M] '; then
        # modified in working tree
        has_modified=" *"
    fi
    if echo "$porcelain" | grep -q '^[ D]D '; then
        has_deleted=" -"
    fi
    if echo "$porcelain" | grep -q '^R[ ]'; then
        has_renamed=" >"
    fi

    marks="${ahead}${has_untracked}${has_added}${has_modified}${has_deleted}${has_renamed}"

    printf '%s [%s ]' "$branch" "$marks"
}


###---------------------------------------------------------------------###
### 4. PROMPT
###---------------------------------------------------------------------###
# Colors/icons preserved from your original PS1.
# Two-line prompt:
#   Line1: branch + git dirty markers
#   Line2: icon + cwd + arrow
#
# Note: \[ \] around escape codes tells bash that those chars don't take up cursor width.

PS1="\[\e[1;33m\]\$(__git_info)\[\033[34m\]\n\[\033[1;34m\] 󰣇 \[\e[1;37m\] \w \[\e[1;36m\]\[\e[0;37m\] "


###---------------------------------------------------------------------###
### 5. DEV ENV / COMPLETIONS
###---------------------------------------------------------------------###

# --- Lazy-load nvm ----------------------------------------------------#
# We don't source nvm.sh at startup (which is slow).
# Instead, first time you run node/npm/npx/nvm, we load it and then
# forward the call.

__load_nvm() {
    # remove the shim functions to avoid recursion
    unset -f node npm npx nvm

    # now source nvm
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        . "$NVM_DIR/nvm.sh"
    fi
    if [ -s "$NVM_DIR/bash_completion" ]; then
        . "$NVM_DIR/bash_completion"
    fi
}

node() { __load_nvm; node "$@"; }
npm()  { __load_nvm; npm "$@"; }
npx()  { __load_nvm; npx "$@"; }
nvm()  { __load_nvm; nvm "$@"; }

# If you actually prefer eager load (old default):
# [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
# [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"


###---------------------------------------------------------------------###
### 6. TOOLS / INTEGRATIONS
###---------------------------------------------------------------------###

# google-cloud-cli gcloud (optional)
# source /etc/profile.d/google-cloud-cli.sh

# zoxide (smart cd). Adds 'z' etc.
eval "$(zoxide init bash)"


###---------------------------------------------------------------------###
### 7. OPTIONAL / REFERENCE (commented out)
###---------------------------------------------------------------------###

# NPM_PACKAGES="${HOME}/.npm-packages"
# export PATH="$PATH:$NPM_PACKAGES/bin"
# export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"

# CDPATH can cause 'cd foo' to jump around from other dirs, which some people hate.
# export CDPATH=".:$HOME:$HOME/.config/:$HOME/.local/:$HOME/.local/share/:$HOME/.local/programs"

############################################################################
# End of ~/.bashrc
############################################################################
