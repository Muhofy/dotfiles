#!/data/data/com.termux/files/usr/bin/bash
# ╔════════════════════════════════════════════════════════╗
# ║  auto-update.sh — Otomatik Güncelleme                 ║
# ╚════════════════════════════════════════════════════════╝

G='\033[1;32m' Y='\033[1;33m' C='\033[0;36m' X='\033[0m'
ok()      { echo -e "${G}[✔]${X} $*"; }
section() { echo -e "\n${Y}══ $* ══${X}"; }

LOG="$HOME/.update-log"
echo "── $(date '+%Y-%m-%d %H:%M') ──" >> "$LOG"

# ── pkg ──────────────────────────────────────────────────
section "pkg"
pkg update -y >> "$LOG" 2>&1 && \
pkg upgrade -y >> "$LOG" 2>&1 && ok "pkg güncellendi." || echo "pkg hata."

# ── pip ──────────────────────────────────────────────────
section "pip"
pip3 list --outdated --format=freeze 2>/dev/null | \
  grep -v '^\-e' | cut -d= -f1 | \
  xargs -r pip3 install -U --quiet && ok "pip güncellendi."

# ── npm ──────────────────────────────────────────────────
section "npm"
npm update -g --quiet 2>/dev/null && ok "npm güncellendi."

# ── oh-my-zsh ────────────────────────────────────────────
section "oh-my-zsh"
zsh "$ZSH/tools/upgrade.sh" >> "$LOG" 2>&1 && ok "oh-my-zsh güncellendi."

# ── dotfiles ─────────────────────────────────────────────
section "dotfiles"
if [ -d "$HOME/dotfiles" ]; then
  git -C "$HOME/dotfiles" pull --quiet && ok "dotfiles güncellendi."
fi

# ── Bildirim ─────────────────────────────────────────────
termux-notification \
  --title "✔ Güncelleme Tamamlandı" \
  --content "pkg, pip, npm, omz güncellendi." \
  --vibrate 300 2>/dev/null

echo -e "\n${G}✔ Her şey güncellendi!${X}\n"
