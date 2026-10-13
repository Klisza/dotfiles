#### ~/.zshrc #############################################################
# Interactive Zsh configuration, adapted from ~/.bashrc
############################################################################

###---------------------------------------------------------------------###
### 0. ONLY CONTINUE FOR INTERACTIVE SHELLS
###---------------------------------------------------------------------###

[[ -o interactive ]] || return


###---------------------------------------------------------------------###
### 1. BASIC ENVIRONMENT / EXPORTS
###---------------------------------------------------------------------###

# Core programs
export BROWSER="firefox"
export EDITOR="nvim"
export VISUAL="nvim"
export CSCOPE_EDITOR="nvim"

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

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

# Tool paths
export PATH="/usr/bin/flutter/bin:$PATH"
export PATH="/usr/local/texlive/2025/bin/x86_64-linux:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# mpc
export MPD_HOST="$HOME/.mpd/socket"

# Colored ls/grep/less with ~/.dir_colors
if (( $+commands[dircolors] )); then
    [[ -r "$HOME/.dir_colors" ]] && eval "$(dircolors "$HOME/.dir_colors")"
fi


###---------------------------------------------------------------------###
### 2. ALIASES
###---------------------------------------------------------------------###

# dotfiles git wrapper
alias config='/usr/bin/git -C /home/kuba/Documents/dotfiles'

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

# Archive extractor: ex <file>
ex() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1"    ;;
            *.tar.gz)  tar xzf "$1"    ;;
            *.bz2)     bunzip2 "$1"    ;;
            *.rar)     unrar x "$1"    ;;
            *.gz)      gunzip "$1"     ;;
            *.tar)     tar xf "$1"     ;;
            *.tbz2)    tar xjf "$1"    ;;
            *.tgz)     tar xzf "$1"    ;;
            *.zip)     unzip "$1"      ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7za x "$1"      ;;
            *.deb)     ar x "$1"       ;;
            *.tar.xz)  tar xf "$1"     ;;
            *.tar.zst) unzstd "$1"     ;;
            *)         print -r -- "'$1' cannot be extracted via ex()" ;;
        esac
    else
        print -r -- "'$1' is not a valid file"
    fi
}

# Random prompt note (not currently used in PROMPT)
prompt_comment() {
    local dir="$HOME/.local/share/promptcomments"
    local message

    message="$(find "$dir" -maxdepth 1 -type f -name '*.txt' 2>/dev/null | shuf -n1)"
    [[ -n "$message" ]] && cat -- "$message"
}

# Lightweight git status for the prompt.
# Markers: ! ahead, ? untracked, + added, * modified, - deleted, > renamed
__git_info() {
    git rev-parse --is-inside-work-tree &>/dev/null || return

    local porcelain branch_line branch ahead marks
    local has_untracked has_added has_modified has_deleted has_renamed

    porcelain="$(git status --porcelain --branch 2>/dev/null)" || return
    branch_line="${porcelain%%$'\n'*}"
    branch_line="${branch_line#\#\# }"
    branch="${branch_line%% *}"
    branch="${branch%%...*}"

    [[ "$branch_line" == *ahead* ]] && ahead=" !"
    print -r -- "$porcelain" | grep -q '^?? '  && has_untracked=" ?"
    print -r -- "$porcelain" | grep -q '^[AM]  ' && has_added=" +"
    print -r -- "$porcelain" | grep -q '^.[M] '  && has_modified=" *"
    print -r -- "$porcelain" | grep -qE '^(D.|.D) ' && has_deleted=" -"
    print -r -- "$porcelain" | grep -q '^R[ ]'   && has_renamed=" >"

    marks="${ahead}${has_untracked}${has_added}${has_modified}${has_deleted}${has_renamed}"
    printf '%s [%s ]' "$branch" "$marks"
}


###---------------------------------------------------------------------###
### 4. PROMPT
###---------------------------------------------------------------------###

# Re-evaluate command substitutions every time the prompt is drawn.
setopt PROMPT_SUBST
PROMPT=$'%F{yellow}$(__git_info)%F{blue}\n%B%F{blue} \U000F08C7 %b%F{white} %~ %F{cyan}\uF054\uF460%f '


###---------------------------------------------------------------------###
### 5. COMPLETION / DEV ENV
###---------------------------------------------------------------------###

# Extra completion definitions.
fpath=("$HOME/.zsh/plugins/zsh-completions/src" $fpath)

autoload -Uz compinit
compinit


# ----------------------------------------------------------------------
# Directory-aware command history
# ----------------------------------------------------------------------

# Records:
#   - command
#   - current directory
#   - exit status
#   - time
#   - host/session
source "$HOME/.zsh/plugins/zsh-histdb/sqlite-history.zsh"


# Prefer frequently-used commands from THIS directory.
#
# If no matching command exists in this directory, fall back to the
# most frequently-used matching command elsewhere.
_zsh_autosuggest_strategy_histdb_top() {
    local query="
        select commands.argv
        from history
        left join commands on history.command_id = commands.rowid
        left join places on history.place_id = places.rowid
        where commands.argv LIKE '$(sql_escape "$1")%'
        group by commands.argv, places.dir
        order by
            places.dir != '$(sql_escape "$PWD")',
            count(*) desc
        limit 1
    "

    suggestion=$(_histdb_query "$query")
}


# Autosuggestions
# 1. Prefer commands you've used frequently in this directory.
# 2. Fall back to Zsh's real context-aware completion system.
ZSH_AUTOSUGGEST_STRATEGY=(histdb_top completion)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

source "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Tab completion
setopt MENU_COMPLETE

bindkey '^I' menu-complete
[[ -n "$terminfo[kcbt]" ]] &&
    bindkey "$terminfo[kcbt]" reverse-menu-complete


# Accept one autosuggestion word
bindkey '^[f' forward-word


# Lazy-load nvm
__load_nvm() {
    unfunction node npm npx nvm 2>/dev/null
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
}

node() { __load_nvm; node "$@"; }
npm()  { __load_nvm; npm "$@"; }
npx()  { __load_nvm; npx "$@"; }
nvm()  { __load_nvm; nvm "$@"; }

###---------------------------------------------------------------------###
### 6. TOOLS / INTEGRATIONS
###---------------------------------------------------------------------###

if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi

###---------------------------------------------------------------------###
### 7. POMODORO
###---------------------------------------------------------------------###

typeset -A pomo_options=(
    work  45
    break 10
)

pomodoro() {
    local val="$1"

    if [[ -n "$val" && -n "${pomo_options[$val]}" ]]; then
        print -r -- "$val" | lolcat
        timer "${pomo_options[$val]}m"
        spd-say "$val session done"
    else
        print -ru2 -- "Unknown pomodoro type: $val"
    fi
}

alias wo='pomodoro work'
alias br='pomodoro break'

############################################################################
# End of ~/.zshrc
############################################################################
