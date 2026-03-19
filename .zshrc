# ╔════════════════════════════════════════════════════════╗
# ║  .zshrc — Muhofy Edition (Modüler)                    ║
# ╚════════════════════════════════════════════════════════╝

# ── Oh-My-Zsh ────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  zsh-history-substring-search
  fzf-tab
  extract
  z
  sudo
  command-not-found
  colorize
  cp
)

source $ZSH/oh-my-zsh.sh

# ── Exports ──────────────────────────────────────────────
export USER=muhofy
export EDITOR=nvim
export VISUAL=nvim
export PAGER="bat --paging=auto"
export LANG=en_US.UTF-8
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
export BAT_THEME="gruvbox-dark"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="
  --height=50% --layout=reverse --border=rounded
  --color=bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#928374
  --color=fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934
  --color=marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934
  --preview 'bat --color=always --style=numbers {}'
  --preview-window=right:50%:wrap
"

# ── History ──────────────────────────────────────────────
export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST

# ── Completion ───────────────────────────────────────────

# ── Keybindings ──────────────────────────────────────────
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P'   history-substring-search-up
bindkey '^N'   history-substring-search-down
bindkey '^R'   history-incremental-search-backward

# ── Autosuggestions ──────────────────────────────────────
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#665c54"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# ── Syntax Highlighting ──────────────────────────────────
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#b8bb26,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#fabd2f,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#83a598'
ZSH_HIGHLIGHT_STYLES[function]='fg=#8ec07c'
ZSH_HIGHLIGHT_STYLES[path]='fg=#ebdbb2,underline'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#fb4934,bold'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#b8bb26'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#b8bb26'

# ── Modüller ─────────────────────────────────────────────
MODULES="$HOME/.termux-config/modules"
source "$MODULES/completion.sh"
source "$MODULES/aliases.sh"
source "$MODULES/functions.sh"
source "$MODULES/notify.sh"

# ── Son Dizin ────────────────────────────────────────────
LAST_DIR_FILE="$HOME/.last_dir"
chpwd() { pwd > "$LAST_DIR_FILE"; }
[ -f "$LAST_DIR_FILE" ] && cd "$(cat "$LAST_DIR_FILE")" 2>/dev/null

# ── Karşılama ────────────────────────────────────────────
_termux_welcome() {
  local Y='\033[1;33m' G='\033[1;32m' B='\033[1;34m' R='\033[0;31m' W='\033[1;37m' X='\033[0m'
  local ram_total ram_avail ram_used
  ram_total=$(awk '/MemTotal/    {printf "%.0f", $2/1024}' /proc/meminfo)
  ram_avail=$(awk '/MemAvailable/{printf "%.0f", $2/1024}' /proc/meminfo)
  ram_used=$((ram_total - ram_avail))
  local dir="${PWD/$HOME/~}"
  local pkgs=$(dpkg -l 2>/dev/null | tail -n+5 | wc -l)

  echo ""
  echo -e "${Y}  ███╗   ███╗██╗   ██╗██╗  ██╗ ██████╗ ███████╗██╗   ██╗${X}"
  echo -e "${Y}  ████╗ ████║██║   ██║██║  ██║██╔═══██╗██╔════╝╚██╗ ██╔╝${X}"
  echo -e "${Y}  ██╔████╔██║██║   ██║███████║██║   ██║█████╗   ╚████╔╝ ${X}"
  echo -e "${Y}  ██║╚██╔╝██║██║   ██║██╔══██║██║   ██║██╔══╝    ╚██╔╝  ${X}"
  echo -e "${Y}  ██║ ╚═╝ ██║╚██████╔╝██║  ██║╚██████╔╝██║        ██║   ${X}"
  echo -e "${Y}  ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝        ╚═╝  ${X}"
  echo ""
  echo -e "  ${W}📅${X}  ${B}$(date '+%d %B %Y — %H:%M')${X}"
  echo -e "  ${W}📂${X}  ${G}${dir}${X}"
  echo -e "  ${W}🧠${X}  RAM: ${R}${ram_used}MB${X} kullanılan / ${G}${ram_avail}MB${X} boş"
  echo -e "  ${W}📦${X}  ${pkgs} paket kurulu"
  echo -e "  ${W}🐚${X}  $(zsh --version | cut -d' ' -f1-2)"
  echo ""
}
_termux_welcome

# ── Zoxide ───────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ── Starship ─────────────────────────────────────────────
eval "$(starship init zsh)"
source "$MODULES/hacking.sh"
