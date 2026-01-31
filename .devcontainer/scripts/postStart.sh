#!/usr/bin/env bash
set -euo pipefail

SOCK=/tmp/ssh-agent.sock
PID=/tmp/ssh-agent-socat.pid
LOG=/tmp/ssh-agent-socat.log

rm -f "$SOCK"

if [ -f "$PID" ] && kill -0 "$(cat "$PID")" 2>/dev/null; then
  kill "$(cat "$PID")" || true
fi
rm -f "$PID"

nohup socat \
  UNIX-LISTEN:"$SOCK",fork,mode=660,user=node,group=node \
  UNIX-CONNECT:/run/host-services/ssh-auth.sock \
  >"$LOG" 2>&1 &

echo $! > "$PID"
