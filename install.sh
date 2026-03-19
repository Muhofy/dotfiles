#!/data/data/com.termux/files/usr/bin/bash
# ╔════════════════════════════════════════════════════════╗
# ║  install.sh — Muhofy's Termux Kurulum                 ║
# ║  Kullanım: bash install.sh                            ║
# ╚════════════════════════════════════════════════════════╝

set -euo pipefail

Y='\033[1;33m' G='\033[1;32m' R='\033[0;31m' C='\033[0;36m' X='\033[0m'
ok()      { echo -e "${G}[✔]${X} $*"; }
err()     { echo -e "${R}[✗]${X} $*"; }
section() { echo -e "\n${Y}══ $* ══${X}\n"; }

echo -e "\n${Y}  ███╗   ███╗██╗   ██╗██╗  ██╗ ██████╗ ███████╗██╗   ██╗${X}"
echo -e "${Y}  ████╗ ████║██║   ██║██║  ██║██╔═══██╗██╔════╝╚██╗ ██╔╝${X}"
echo -e "${Y}  ██╔████╔██║██║   ██║███████║██║   ██║█████╗   ╚████╔╝ ${X}"
echo -e "${Y}  ██║╚██╔╝██║██║   ██║██╔══██║██║   ██║██╔══╝    ╚██╔╝  ${X}"
echo -e "${Y}  ██║ ╚═╝ ██║╚██████╔╝██║  ██║╚██████╔╝██║        ██║   ${X}"
echo -e "${Y}  ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝        ╚═╝  ${X}"
echo -e "\n  ${C}Termux Kurulum Başlıyor...${X}\n"

DOTFILES="$HOME/dotfiles"
MODULES="$HOME/.termux-config/modules"
BIN="$HOME/bin"

# ══════════════════════════════════════════════════════════
# 1. CORE PAKETLER
# ══════════════════════════════════════════════════════════
section "Core Paketler"
pkg update -y && pkg upgrade -y
pkg install -y \
  zsh git curl wget \
  neovim tmux \
  fzf ripgrep fd bat eza \
  htop btop ncdu jq \
  python nodejs-lts \
  termux-api termux-tools \
  openssh zoxide starship \
  nmap netcat-openbsd dnsutils whois \
  tcpdump openssl-tool socat
ok "Core paketler kuruldu."

# ══════════════════════════════════════════════════════════
# 2. OH-MY-ZSH
# ══════════════════════════════════════════════════════════
section "Oh-My-Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "Oh-My-Zsh kuruldu."
else
  ok "Oh-My-Zsh zaten var."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

declare -A PLUGINS=(
  ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
  ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
  ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
  ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search"
  ["fzf-tab"]="https://github.com/Aloxaf/fzf-tab"
)

for plugin in "${!PLUGINS[@]}"; do
  dir="$ZSH_CUSTOM/plugins/$plugin"
  [ -d "$dir" ] || git clone --depth=1 "${PLUGINS[$plugin]}" "$dir"
  ok "$plugin kuruldu."
done

# ══════════════════════════════════════════════════════════
# 3. DOTFILES
# ══════════════════════════════════════════════════════════
section "Dotfiles"
if [ ! -d "$DOTFILES" ]; then
  git clone --depth=1 git@github.com:Muhofy/dotfiles.git "$DOTFILES"
  ok "Dotfiles klonlandı."
else
  git -C "$DOTFILES" pull
  ok "Dotfiles güncellendi."
fi

# ══════════════════════════════════════════════════════════
# 4. KLASÖRLER
# ══════════════════════════════════════════════════════════
section "Klasörler"
mkdir -p ~/.termux-config/{modules,configs,layouts,bin}
mkdir -p ~/.config
mkdir -p ~/bin
mkdir -p ~/projects
mkdir -p ~/.wordlists
ok "Klasörler oluşturuldu."

# ══════════════════════════════════════════════════════════
# 5. CONFIG DOSYALARI
# ══════════════════════════════════════════════════════════
section "Config Dosyaları"

# .zshrc
cp "$DOTFILES/.zshrc" "$HOME/.zshrc"
ok ".zshrc kopyalandı."

# starship.toml
cp "$DOTFILES/starship.toml" "$HOME/.config/starship.toml"
ok "starship.toml kopyalandı."

# .tmux.conf
cp "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
ok ".tmux.conf kopyalandı."

# Modüller
cp "$DOTFILES/modules/"* "$MODULES/"
ok "Modüller kopyalandı."

# Bin scriptleri
cp "$DOTFILES/bin/"* "$HOME/.termux-config/bin/"
chmod +x "$HOME/.termux-config/bin/"*
ok "Bin scriptleri kopyalandı."

# Layouts
cp "$DOTFILES/layouts/"* "$HOME/.termux-config/layouts/"
chmod +x "$HOME/.termux-config/layouts/"*
ok "Layouts kopyalandı."

# Symlink — dev komutu
ln -sf "$HOME/.termux-config/bin/dev" "$HOME/bin/dev"
ok "dev symlink oluşturuldu."

# ══════════════════════════════════════════════════════════
# 6. TERMUX TEMA
# ══════════════════════════════════════════════════════════
section "Termux Tema"
mkdir -p "$HOME/.termux"

cat > "$HOME/.termux/colors.properties" << 'EOF'
background=#282828
foreground=#ebdbb2
cursor=#ebdbb2
color0=#282828
color1=#cc241d
color2=#98971a
color3=#d79921
color4=#458588
color5=#b16286
color6=#689d6a
color7=#a89984
color8=#928374
color9=#fb4934
color10=#b8bb26
color11=#fabd2f
color12=#83a598
color13=#d3869b
color14=#8ec07c
color15=#ebdbb2
