---
description: Audit dotfiles for dead code, broken tools, and startup regressions using parallel agents
---

Perform a comprehensive dotfiles audit using parallel sub-agents. Launch all three agents simultaneously, then synthesize their findings into a single prioritized report before making any changes.

**Agent 1 — Dead code & unused aliases**
Search the dotfiles directory for:
- Aliases that reference commands not installed (`which <cmd>`)
- Sourced files that don't exist on disk
- Commented-out blocks that have been dead for a long time
- Duplicate alias/function definitions

**Agent 2 — Tool & compatibility check**
For every CLI tool referenced in shell configs:
- Verify it's installed (`which <tool>`)
- If not installed, check Homebrew availability (`brew info <tool>`)
- Check plugin names match the current oh-my-zsh version
- Flag anything that would error on a fresh shell

**Agent 3 — Startup performance**
- Benchmark shell startup: `for i in $(seq 1 5); do time zsh -i -c exit; done`
- Identify slow components by selectively commenting out major sections and re-timing
- Report which plugins/tools are the biggest contributors
- Establish a baseline time to compare against after any changes

After all three agents complete, present a single prioritized list of findings. **Do not make any changes until the user reviews the report and confirms.**
