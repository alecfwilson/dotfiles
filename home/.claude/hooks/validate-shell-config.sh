#!/bin/bash
# PostToolUse hook: comprehensive shell config health check after Edit/Write.
# Silent on success (zero token cost). Reports syntax errors, startup crashes,
# and startup time regressions.

file_path=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // empty')

# Only act on shell config files
case "$file_path" in
  *.zsh|*.zshrc|*.zprofile|*.zshenv|*.bashrc|*.bash_profile|*.sh) ;;
  *) exit 0 ;;
esac

[ -f "$file_path" ] || exit 0

failures=()

# 1. Syntax check — fast, no side effects
syntax_out=$(zsh -n "$file_path" 2>&1)
[ -n "$syntax_out" ] && failures+=("Syntax error: $syntax_out")

# 2. Full interactive startup — catches runtime errors that syntax check misses.
#    Timing is checked only for main entry point files to avoid ~0.5s overhead
#    on every incidental .sh edit.
start_ms=$(python3 -c "import time; print(int(time.time()*1000))")
if ! zsh -i -c exit >/dev/null 2>&1; then
    failures+=("Shell startup failed after edit — zsh exited non-zero")
fi
end_ms=$(python3 -c "import time; print(int(time.time()*1000))")

case "$file_path" in
  */.zshrc|*/.zprofile|*/.zshenv)
    startup_ms=$(( end_ms - start_ms ))
    if [ "$startup_ms" -gt 500 ]; then
        failures+=("Startup regression: ${startup_ms}ms (threshold: 500ms)")
    fi
    ;;
esac

# Silent on success. Only speak up when something is wrong.
if [ ${#failures[@]} -gt 0 ]; then
    echo "⚠ Shell config issue in ${file_path##*/}:"
    for f in "${failures[@]}"; do
        echo "  • $f"
    done
    exit 1
fi
