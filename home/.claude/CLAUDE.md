# Global Claude Code Preferences

These preferences apply to all Claude Code sessions. Individual projects may have their own CLAUDE.md with project-specific instructions that supplement or override these.

## Code Style Priorities

1. **Make it work** - Functionality first
2. **Make it readable** - I'm a data scientist, not a software engineer. Prefer straightforward code over clever abstractions. If a less experienced Python user would struggle to follow it, simplify it. However, if the task genuinely requires something more complex or a different language/library/framework, use it - this is context about my background, not a limitation on your tools.
3. **Production quality when free** - Add type hints, error handling, etc. only when it doesn't add complexity or inflate token usage

## Preferences

- **Testing**: Use pytest
- **Simplicity over abstraction**: Three similar lines > one clever function
- **Comments**: Only where logic isn't obvious from reading the code
- **Suggest improvements**: Feel free to propose features, config options, or improvements I didn't ask for - just explain why and get my confirmation before implementing
- **Targeted changes**: Match the scope of every edit exactly to what was asked — don't apply improvements broadly when a specific location was requested. Before replacing working code with an optimization, verify the new version produces identical output.
- **Tool availability**: Before recommending or installing any CLI tool, verify it exists and is installable (`brew info <tool>`). Check version compatibility with existing setup (e.g. plugin names, config syntax) before making changes.
- **Shell config changes**: When editing shell config files, benchmark startup time before and after (`for i in $(seq 1 5); do time zsh -i -c exit; done`) and report any regression.
- **Diagnose first**: When the root cause of an issue isn't obvious, diagnose and present findings before attempting a fix.

## Communication

- **Verbosity**: Adaptive - brief for simple things, detailed for complex or new concepts
- **Asking vs assuming**: Make reasonable assumptions for small, easy-to-undo changes. Ask before big decisions or anything hard to reverse.

## Search Tools

`ack`, `ag`, and `rg` are all installed. The built-in `Grep` tool already uses ripgrep, so prefer it for most searches. Drop to Bash only when:
- Piping to other tools (`rg ... | fzf`, `rg ... | bat`)
- Need `ag` specifically for searching compressed files (`.gz`, `.xz`)
- Need `ack` for boolean logic (`--and`, `--or`, `--not`)
- Need `rg` JSON output (`rg --json`)

Never use plain `grep` — always prefer `rg` if dropping to Bash.

## Workflow

- **Package manager**: No strong preference - use whatever fits the project
- **Git commits**: Casual but clear (no conventional commits required)
