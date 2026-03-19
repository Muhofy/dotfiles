#!/data/data/com.termux/files/usr/bin/bash
# ╔════════════════════════════════════════════════════════╗
# ║  Hacking Toolkit Kurulum — Muhofy Edition             ║
# ╚════════════════════════════════════════════════════════╝

set -euo pipefail
G='\033[1;32m' Y='\033[1;33m' R='\033[0;31m' X='\033[0m'
ok()  { echo -e "${G}[✔]${X} $*"; }
war() { echo -e "${Y}[!]${X} $*"; }
err() { echo -e "${R}[✗]${X} $*"; }

echo -e "\n${Y}  ██╗  ██╗ █████╗  ██████╗██╗  ██╗${X}"
echo -e "${Y}  ██║  ██║██╔══██╗██╔════╝██║ ██╔╝${X}"
echo -e "${Y}  ███████║███████║██║     █████╔╝ ${X}"
echo -e "${Y}  ██╔══██║██╔══██║██║     ██╔═██╗ ${X}"
echo -e "${Y}  ██║  ██║██║  ██║╚██████╗██║  ██╗${X}"
echo -e "${Y}  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝${X}\n"

# ── Repo ─────────────────────────────────────────────────
pkg update -y

# ── Ağ Tarama ────────────────────────────────────────────
echo -e "\n${Y}── Ağ Tarama ──${X}"
pkg install -y nmap netcat-openbsd dnsutils whois traceroute
ok "nmap, netcat, dns araçları kuruldu."

# ── Web Testi ────────────────────────────────────────────
echo -e "\n${Y}── Web Testi ──${X}"
pkg install -y python
pip3 install sqlmap --quiet
pkg install -y curl wget
ok "sqlmap, curl, wget kuruldu."

# Nikto (perl tabanlı)
if ! command -v nikto &>/dev/null; then
  pkg install -y perl git
  git clone --depth=1 https://github.com/sullo/nikto "$HOME/.tools/nikto" 2>/dev/null || true
  ln -sf "$HOME/.tools/nikto/program/nikto.pl" "$HOME/bin/nikto"
  chmod +x "$HOME/bin/nikto"
  ok "nikto kuruldu."
fi

# ── Parola Kırma ─────────────────────────────────────────
echo -e "\n${Y}── Parola Kırma ──${X}"
pkg install -y hydra hashcat john
ok "hydra, hashcat, john kuruldu."

# ── OSINT ────────────────────────────────────────────────
echo -e "\n${Y}── OSINT ──${X}"
pkg install -y whois dnsutils
pip3 install theHarvester --quiet 2>/dev/null || war "theHarvester pip ile kurulamadı, manuel dene."
pip3 install shodan --quiet
ok "whois, dig, shodan kuruldu."

# ── Kablosuz ─────────────────────────────────────────────
echo -e "\n${Y}── Kablosuz ──${X}"
war "aircrack-ng Termux'ta root gerektirir."
war "Root varsa: pkg install root-repo && pkg install aircrack-ng"
pkg install -y wireless-tools 2>/dev/null || true

# ── Wordlist ─────────────────────────────────────────────
echo -e "\n${Y}── Wordlist ──${X}"
mkdir -p "$HOME/.wordlists"
if [ ! -f "$HOME/.wordlists/rockyou.txt" ]; then
  war "rockyou.txt indiriliyor (~134MB)..."
  curl -L "https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt" \
    -o "$HOME/.wordlists/rockyou.txt" 2>/dev/null && ok "rockyou.txt hazır." || \
    war "rockyou.txt indirilemedi, manuel indir."
fi

# ── Reverse Shell ────────────────────────────────────────
echo -e "\n${Y}── Reverse Shell ──${X}"
pkg install -y netcat-openbsd socat
ok "netcat, socat kuruldu."

# ── Diğer ────────────────────────────────────────────────
echo -e "\n${Y}── Diğer Araçlar ──${X}"
pkg install -y tcpdump openssl-tool binutils
pip3 install impacket --quiet 2>/dev/null || war "impacket kurulamadı."
ok "tcpdump, openssl, binutils kuruldu."

echo -e "\n${G}╔══════════════════════════════════╗${X}"
echo -e "${G}║  ✔ Hacking Toolkit Hazır!        ║${X}"
echo -e "${G}╚══════════════════════════════════╝${X}\n"
