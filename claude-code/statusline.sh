#!/bin/bash
# Claude Code status line.
#
# Reads the statusLine JSON payload on stdin and prints one line:
#
#   repo (branch)  [ctx:15%] [5h:7%] [wk:62%]  ⟳ Wed 9am  Opus 5:xhigh
#
# The three chips are proportional bars: the label sits on a fixed-width block
# whose left portion is filled to the usage percentage. Colour tracks severity,
# so a glance at hue is enough — the number is for when you care about the exact
# figure.
#
# Field names come from the statusLine schema shipped in the CLI itself. Two of
# them are optional in ways that matter: `context_window.used_percentage` is null
# until the first API response, and `rate_limits` is absent entirely for
# non-subscribers and before the first response. Each chip is skipped rather
# than shown as 0% when its source is missing — a bar reading empty and a bar
# reading "unknown" are different claims.

set -uo pipefail

input=$(cat)

# One field per line, accumulated by a read loop. Deliberately not `read` over
# @tsv: tab is an IFS-whitespace character, so bash collapses a run of tabs into
# one delimiter and an empty field (no branch, no effort) silently shifts
# everything after it. Deliberately not `mapfile` either — macOS ships bash 3.2,
# which does not have it.
f=()
while IFS= read -r line; do f+=("$line"); done < <(
  printf '%s' "$input" | jq -r '
    [ (.workspace.current_dir // .cwd // ""),
      (.worktree.branch // ""),
      (.model.display_name // "?"),
      (.effort.level // ""),
      (.context_window.used_percentage // "-"),
      (.rate_limits.five_hour.used_percentage // "-"),
      (.rate_limits.five_hour.resets_at // "-"),
      (.rate_limits.seven_day.used_percentage // "-")
    ] | map(tostring) | .[]' 2>/dev/null
)

cwd=${f[0]-}
branch=${f[1]-}
model=${f[2]-?}
effort=${f[3]-}
ctx=${f[4]--}
h5=${f[5]--}
h5_reset=${f[6]--}
d7=${f[7]--}
[ -n "$model" ] || model="?"

# ── colours ───────────────────────────────────────────────────────────────────
DIM=$'\033[2m'
RST=$'\033[0m'
BLUE=$'\033[38;5;75m'
CYAN=$'\033[38;5;80m'
GREY=$'\033[38;5;245m'

# Chip: a fixed-width block, left portion filled to $2 percent.
# $1 label, $2 percentage (or "-" to skip)
chip() {
  local label=$1 pct=$2 width=11
  [ "$pct" = "-" ] && return 0

  pct=${pct%.*}
  [ -z "$pct" ] && pct=0
  ((pct < 0)) && pct=0
  ((pct > 100)) && pct=100

  local fill_bg text_fg
  if ((pct >= 85)); then
    fill_bg=167 # red
  elif ((pct >= 60)); then
    fill_bg=179 # amber
  else
    fill_bg=114 # green
  fi
  text_fg=235

  local text
  text=$(printf ' %s:%s%%' "$label" "$pct")
  # Pad to width; truncate if a three-digit percentage overflows.
  text=$(printf '%-*.*s' "$width" "$width" "$text")

  local n=$(((pct * width + 50) / 100))
  printf '\033[48;5;%sm\033[38;5;%sm%s\033[0m\033[48;5;238m\033[38;5;250m%s\033[0m' \
    "$fill_bg" "$text_fg" "${text:0:n}" "${text:n}"
}

# ── location ──────────────────────────────────────────────────────────────────
name=""
if [ -n "$cwd" ]; then
  name=$(basename "$cwd")
  if [ -z "$branch" ]; then
    branch=$(git -C "$cwd" symbolic-ref --quiet --short HEAD 2>/dev/null ||
      git -C "$cwd" rev-parse --short HEAD 2>/dev/null || true)
  fi
fi

out=""
[ -n "$name" ] && out+="${BLUE}${name}${RST}"
[ -n "$branch" ] && out+=" ${DIM}(${branch})${RST}"

# ── bars ──────────────────────────────────────────────────────────────────────
for spec in "ctx:$ctx" "5h:$h5" "wk:$d7"; do
  bar=$(chip "${spec%%:*}" "${spec#*:}")
  [ -n "$bar" ] && out+=" $bar"
done

# ── reset clock ───────────────────────────────────────────────────────────────
# The 5-hour window is the one that bites first, so it is the clock worth having.
if [ "$h5_reset" != "-" ]; then
  when=$(date -r "${h5_reset%.*}" '+%a %-I%p' 2>/dev/null ||
    date -d "@${h5_reset%.*}" '+%a %-I%p' 2>/dev/null || true)
  # Lowercase only the meridiem suffix — a blanket tr would also eat the M in "Mon".
  [ -n "$when" ] && out+=" ${GREY}↻ $(printf '%s' "$when" | sed 's/AM$/am/; s/PM$/pm/')${RST}"
fi

# ── model ─────────────────────────────────────────────────────────────────────
out+=" ${CYAN}${model}${RST}"
[ -n "$effort" ] && out+="${DIM}:${effort}${RST}"

printf '%s' "$out"
