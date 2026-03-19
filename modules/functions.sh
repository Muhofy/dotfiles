# ╔════════════════════════════════════════════════════════╗
# ║  functions.sh — Tüm Fonksiyonlar                      ║
# ╚════════════════════════════════════════════════════════╝

# ── Genel ────────────────────────────────────────────────
mkcd() { mkdir -pv "$1" && cd "$1"; }

ex() {
  if [ ! -f "$1" ]; then echo "'$1' dosya değil."; return 1; fi
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;; *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;; *.zip)     unzip "$1"   ;;
    *.7z)      7z x "$1"    ;; *.rar)     unrar x "$1" ;;
    *.tar)     tar xf "$1"  ;; *) echo "Bilinmiyor: $1" ;;
  esac
}

note()      { echo "$(date '+%Y-%m-%d %H:%M'): $*" >> "$HOME/.notes"; echo "✔ Kaydedildi."; }
notes()     { [ -f "$HOME/.notes" ] && bat "$HOME/.notes" || echo "Henüz not yok."; }
note-clear(){ > "$HOME/.notes" && echo "✔ Notlar temizlendi."; }

# ── FZF ──────────────────────────────────────────────────
fo() {
  local file
  file=$(fd --type f --hidden --exclude .git | fzf \
    --preview 'bat --color=always --style=numbers {}')
  [ -n "$file" ] && nvim "$file"
}

fcd() {
  local dir
  dir=$(fd --type d --hidden --exclude .git | fzf \
    --preview 'eza --tree --icons --color=always {} | head -30')
  [ -n "$dir" ] && cd "$dir"
}

fkill() {
  local pid
  pid=$(ps aux | fzf --header='Öldür' | awk '{print $2}')
  [ -n "$pid" ] && kill -"${1:-9}" "$pid" && echo "✔ Killed: $pid"
}

fgco() {
  local branch
  branch=$(git branch -a | fzf \
    --preview 'git log --oneline --graph {}' | tr -d '* ' | \
    sed 's/remotes\/origin\///')
  [ -n "$branch" ] && git checkout "$branch"
}

# ── Git ──────────────────────────────────────────────────
gccd() { git clone --depth=1 "$1" && cd "$(basename "$1" .git)"; }

gitlog() {
  git log --graph --abbrev-commit --decorate \
    --format=format:'%C(bold yellow)%h%C(reset) %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)— %an%C(reset)%C(bold red)%d%C(reset)' \
    --all
}

gwhat() { git diff --stat "${1:-HEAD~1}" HEAD; }

# Git quick commit
gcommit() {
  local untracked unstaged total msg
  untracked=$(git ls-files --others --exclude-standard 2>/dev/null)
  unstaged=$(git diff --name-only 2>/dev/null)
  if [ -z "$untracked$unstaged" ] && ! git diff --cached --quiet 2>/dev/null; then
    echo "✗ Commit edilecek bir şey yok."
    return 1
  fi
  git add -A
  total=$(git diff --cached --name-only | wc -l | tr -d ' ')
  printf "💬 Mesaj (%s dosya): " "$total"
  read -r msg </dev/tty
  [ -z "$msg" ] && echo "✗ Mesaj boş." && return 1
  git commit -m "$msg"
}

# ── Hacking ──────────────────────────────────────────────
ipinfo()   { curl -s "https://ipinfo.io/${1:-}/json" | jq; }

sweep() {
  local net="${1:?Usage: sweep 192.168.1}"
  nmap -sn "${net}.0/24" | grep "Nmap scan report" | awk '{print $NF}' | tr -d '()'
}

portscan() { nmap -T4 --open -p- "${1:?Usage: portscan <host>}"; }

httpcheck() {
  curl -s -o /dev/null -w "\nStatus:  %{http_code}\nTime:    %{time_total}s\nSize:    %{size_download} bytes\nIP:      %{remote_ip}\n" "${1:?Usage: httpcheck <url>}"
}

dnscheck() {
  local d="${1:?Usage: dnscheck <domain>}"
  echo "── A ──";     dig A "$d" +short
  echo "── MX ─";    dig MX "$d" +short
  echo "── NS ─";    dig NS "$d" +short
  echo "── TXT ─";   dig TXT "$d" +short
}

hashit() {
  echo "MD5:    $(echo -n "$1" | md5sum | cut -d' ' -f1)"
  echo "SHA1:   $(echo -n "$1" | sha1sum | cut -d' ' -f1)"
  echo "SHA256: $(echo -n "$1" | sha256sum | cut -d' ' -f1)"
}

genpass() { tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c "${1:-32}"; echo; }
urlencode() { python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))"; }
urldecode() { python3 -c "import urllib.parse; print(urllib.parse.unquote('$1'))"; }
listen()   { nc -lvnp "${1:-4444}"; }

# ── Termux API ───────────────────────────────────────────
copy()     { [ -z "$1" ] && termux-clipboard-set "$(cat)" || termux-clipboard-set "$*"; echo "✔ Kopyalandı."; }
paste()    { termux-clipboard-get; }
clipshow() { termux-clipboard-get | bat -l txt --paging=never; }
clipclear(){ termux-clipboard-set "" && echo "✔ Temizlendi."; }
copyfile() { [ -f "$1" ] && termux-clipboard-set "$(cat "$1")" && echo "✔ Kopyalandı." || echo "✗ Dosya yok."; }

vol()      { termux-volume | jq '.[] | "\(.stream): \(.volume)/\(.max_volume)"' -r; }
volset()   { termux-volume "$1" "$2" && echo "✔ $1 → $2"; }
mute()     { termux-volume ring 0; termux-volume notification 0; termux-volume music 0; echo "🔇 Sessiz."; }
unmute()   { termux-volume ring 7; termux-volume notification 7; termux-volume music 10; echo "🔊 Açık."; }

wifiinfo() {
  local i; i=$(termux-wifi-connectioninfo)
  echo "\n  📶 WiFi"
  echo "  SSID   : $(echo "$i" | jq -r '.ssid')"
  echo "  IP     : $(echo "$i" | jq -r '.ip')"
  echo "  Sinyal : $(echo "$i" | jq -r '.rssi') dBm"
  echo "  Hız    : $(echo "$i" | jq -r '.link_speed_mbps') Mbps\n"
}

wifiscan() { termux-wifi-scaninfo | jq '.[] | "\(.ssid) — \(.level) dBm"' -r | sort; }
extip()    { echo "🌐 $(curl -s --max-time 5 ifconfig.me)"; }

qrscan() {
  local tmp="$HOME/.qr_tmp.jpg"
  termux-camera-image -c 0 "$tmp" && zbarimg --raw "$tmp" 2>/dev/null || echo "✗ Okunamadı."
  rm -f "$tmp"
}

qrgen()  { qrencode -t ANSIUTF8 "${*:?Usage: qrgen <metin>}"; }
photo()  { local o="${1:-$HOME/photo_$(date +%Y%m%d_%H%M%S).jpg}"; termux-camera-image -c 0 "$o" && echo "✔ $o"; }
alert()  { termux-notification --title "Termux" --content "${1:-Bitti!}" --vibrate 500; }
bgrun()  { "$@" && alert "✔ Bitti: $*" || alert "✗ Hata: $*" & }
