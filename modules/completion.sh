# ╔════════════════════════════════════════════════════════╗
# ║  completion.sh — fzf-tab + Zsh Completion             ║
# ╚════════════════════════════════════════════════════════╝

autoload -Uz compinit && compinit

# ── Genel ────────────────────────────────────────────────
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'
zstyle ':completion:*:warnings'     format '%F{red}── eşleşme yok ──%f'
zstyle ':completion:*:messages'     format '%F{green}── %d ──%f'
zstyle ':completion:*:corrections'  format '%F{orange}── %d (hata: %e) ──%f'

# Gruplar halinde göster
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

# ── fzf-tab ──────────────────────────────────────────────
# Genel önizleme
zstyle ':fzf-tab:*' fzf-flags \
  '--height=60%' \
  '--layout=reverse' \
  '--border=rounded' \
  '--color=bg+:#3c3836,bg:#282828,hl:#928374,fg:#ebdbb2,hl+:#fb4934,prompt:#fabd2f,pointer:#fb4934'

# cd → dizin ağacı önizleme
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'eza --tree --icons --color=always --level=2 $realpath 2>/dev/null | head -30'

# ls, eza → dosya önizleme
zstyle ':fzf-tab:complete:(ls|eza|la|ll|lt):*' fzf-preview \
  'bat --color=always --style=numbers $realpath 2>/dev/null || eza --icons --color=always $realpath'

# cat, bat, nvim, vim → dosya içeriği önizleme
zstyle ':fzf-tab:complete:(cat|bat|nvim|vim|v|nano|micro):*' fzf-preview \
  'bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null'

# rm, mv, cp → dosya önizleme
zstyle ':fzf-tab:complete:(rm|mv|cp):*' fzf-preview \
  'bat --color=always $realpath 2>/dev/null || eza --icons --color=always $realpath'

# git → branch/commit önizleme
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
  'git diff $word | bat --color=always -l diff'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
  'git log --oneline --graph --color=always $word 2>/dev/null | head -20'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
  'git show --color=always $word | head -30'

# kill → process bilgisi
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-header -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags \
  '--preview-window=down:3:wrap'

# systemctl → servis durumu (opsiyonel)
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview \
  'SYSTEMD_COLORS=1 systemctl status $word 2>/dev/null | head -20'

# export, unset → değer önizleme
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview \
  'echo ${(P)word}'

# man → sayfa önizleme
zstyle ':fzf-tab:complete:man:*' fzf-preview \
  'man $word 2>/dev/null | bat --color=always -l man | head -50'

# Tab ile seç, Shift+Tab ile çoklu seç
zstyle ':fzf-tab:*' fzf-bindings 'tab:accept' 'shift-tab:toggle+down'
zstyle ':fzf-tab:*' switch-group ',' '.'
