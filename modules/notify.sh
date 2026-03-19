_cmd_start_time=0
_cmd_current=""
preexec() { _cmd_start_time=$SECONDS; _cmd_current="$1"; }
precmd() {
  local exit_code=$? elapsed=$(( SECONDS - _cmd_start_time ))
  if (( _cmd_start_time > 0 && elapsed >= 10 )); then
    local icon="✔" text="Tamamlandı"
    (( exit_code != 0 )) && icon="✗" && text="Hata (kod: $exit_code)"
    termux-notification --title "${icon} ${text} — ${elapsed}s" --content "$_cmd_current" --vibrate 300 --priority high 2>/dev/null
  fi
  _cmd_start_time=0; _cmd_current=""
}
