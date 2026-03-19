#!/data/data/com.termux/files/usr/bin/bash
# Proje layoutu:
# ┌─────────────────┬──────────┐
# │                 │   git    │
# │     nvim        ├──────────┤
# │                 │ terminal │
# └─────────────────┴──────────┘

SESSION="proje"
DIR="${1:-$(pwd)}"

tmux has-session -t "$SESSION" 2>/dev/null && tmux attach -t "$SESSION" && exit

tmux new-session -d -s "$SESSION" -c "$DIR"

# Sol panel — nvim
tmux send-keys -t "$SESSION" "nvim ." Enter

# Sağ üst — git
tmux split-window -h -c "$DIR"
tmux send-keys -t "$SESSION" "git log --oneline --graph --all | head -20" Enter

# Sağ alt — terminal
tmux split-window -v -c "$DIR"

# Sol panele odaklan
tmux select-pane -t "$SESSION":1.1

tmux attach -t "$SESSION"
