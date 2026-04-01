#!/bin/bash

# Read JSON input
input=$(cat)

# Parse all fields in a single jq call — outputs shell assignments, eval sets variables
eval "$(jq -r '
  "cwd="                  + (.workspace.current_dir | @sh),
  "total_input="          + ((.context_window.total_input_tokens // 0) | tostring),
  "total_output="         + ((.context_window.total_output_tokens // 0) | tostring),
  "used_percentage="      + ((.context_window.used_percentage // "") | tostring),
  "remaining_percentage=" + ((.context_window.remaining_percentage // "") | tostring),
  "cache_read="           + ((.context_window.current_usage.cache_read_input_tokens // "") | tostring),
  "cache_creation="       + ((.context_window.current_usage.cache_creation_input_tokens // "") | tostring),
  "total_cost="           + ((.cost.total_cost_usd // "") | tostring),
  "model="                + ((.model.display_name // "") | @sh),
  "session_name="         + ((.session_name // "") | @sh),
  "vim_mode="             + ((.vim.mode // "") | @sh),
  "worktree_branch="      + ((.worktree.branch // "") | @sh),
  "worktree_original_branch=" + ((.worktree.original_branch // "") | @sh),
  "agent_name="           + ((.agent.name // "") | @sh),
  "added_dirs_count="     + ((.workspace.added_dirs | length) | tostring),
  "transcript_path="      + ((.transcript_path // "") | @sh)
' <<< "$input")"

# Get hostname (short form)
hostname=$(hostname -s)

# Get directory basename (pure bash, no subprocess)
dirbasename="${cwd##*/}"

# Check if current directory is a symlink
symlink_info=""
if [ -L "$cwd" ]; then
    linkdir=$(readlink "$cwd")
    symlink_info=" -> $linkdir"
fi

# Get git branch if in a git repository
git_branch=""
if git -C "$cwd" --no-optional-locks rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks symbolic-ref HEAD 2>/dev/null)
    branch="${branch#refs/heads/}"
    if [ -n "$branch" ]; then
        git_branch=" ($branch)"
    fi
fi

# Build token usage display (raw counts, no redundant "ctx: X% used" — bar handles that)
token_info=""
if [ -n "$used_percentage" ]; then
    total_input_fmt=$(printf "%'d" "$total_input" 2>/dev/null || echo "$total_input")
    total_output_fmt=$(printf "%'d" "$total_output" 2>/dev/null || echo "$total_output")
    token_info=$(printf " | tokens: in=%s out=%s" "$total_input_fmt" "$total_output_fmt")
fi

# Compute context remaining for color-coded bar (fall back to 100 - used_percentage)
remaining_int=""
if [ -n "$remaining_percentage" ] && [ "$remaining_percentage" != "" ]; then
    remaining_int=$(printf "%.0f" "$remaining_percentage")
elif [ -n "$used_percentage" ]; then
    remaining_int=$(( 100 - ${used_percentage%.*} ))
fi

# Build cache display: read count + hit rate (hit rate stored separately for coloring)
cache_info=""
cache_hit_rate=""
if [ -n "$cache_read" ] && [ "$cache_read" -gt 0 ] 2>/dev/null; then
    if [ "$cache_read" -ge 1000 ]; then
        cache_k=$(( cache_read / 1000 ))
        cache_str="${cache_k}k read"
    else
        cache_str="${cache_read} read"
    fi
    if [ -n "$cache_creation" ] && [ "$cache_creation" -gt 0 ] 2>/dev/null; then
        total_cache=$(( cache_read + cache_creation ))
        cache_hit_rate=$(( cache_read * 100 / total_cache ))
        cache_info=$(printf " | cache: %s (%d%% hit)" "$cache_str" "$cache_hit_rate")
    else
        cache_info=$(printf " | cache: %s" "$cache_str")
    fi
fi

# Build transcript stats (message count, session age, tokens/msg)
transcript_info=""
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    msg_count=$(wc -l < "$transcript_path" 2>/dev/null)
    msg_count="${msg_count// /}"
    birth_epoch=$(stat -f "%SB" -t "%s" "$transcript_path" 2>/dev/null)
    now_epoch=$(date +%s)
    if [ -n "$birth_epoch" ]; then
        age_secs=$(( now_epoch - birth_epoch ))
        if [ "$age_secs" -ge 3600 ]; then
            age_fmt=$(printf "%dh%dm" $(( age_secs / 3600 )) $(( (age_secs % 3600) / 60 )))
        else
            age_fmt=$(printf "%dm" $(( age_secs / 60 )))
        fi
    else
        age_fmt=""
    fi
    total_tokens=$(( total_input + total_output ))
    if [ -n "$msg_count" ] && [ "$msg_count" -gt 0 ]; then
        tpm=$(( total_tokens / msg_count ))
        tpm_fmt="${tpm}t/msg"
    else
        tpm_fmt=""
    fi
    parts=""
    [ -n "$msg_count" ] && parts="${msg_count}msgs"
    [ -n "$age_fmt" ] && parts="${parts} · ${age_fmt}"
    [ -n "$tpm_fmt" ] && parts="${parts} · ${tpm_fmt}"
    [ -n "$parts" ] && transcript_info=" | ${parts}"
fi

# Build cost display
cost_info=""
if [ -n "$total_cost" ] && [ "$total_cost" != "0" ]; then
    cost_info=$(printf " | cost: \$%.2f" "$total_cost")
fi

# Build the status line with colors
printf "%s " "$hostname"
printf "\033[0;32m%s\033[0m" "$dirbasename"
if [ -n "$symlink_info" ]; then
    printf "\033[0;36m%s\033[0m" "$symlink_info"
fi
if [ -n "$git_branch" ]; then
    printf "\033[0;31m%s\033[0m" "$git_branch"
fi
if [ -n "$worktree_branch" ]; then
    printf " \033[0;36m[worktree: %s]\033[0m" "$worktree_branch"
fi
if [ -n "$worktree_original_branch" ]; then
    printf " \033[0;36m(from: %s)\033[0m" "$worktree_original_branch"
fi
if [ -n "$agent_name" ]; then
    printf " \033[0;35m[agent: %s]\033[0m" "$agent_name"
fi
if [ -n "$model" ]; then
    printf " \033[0;34m| %s\033[0m" "$model"
fi
if [ -n "$session_name" ]; then
    printf " \033[0;35m\"%s\"\033[0m" "$session_name"
fi
if [ -n "$token_info" ]; then
    printf "\033[0;33m%s\033[0m" "$token_info"
fi
if [ -n "$remaining_int" ]; then
    used_int=$(( 100 - remaining_int ))
    filled=$(( used_int / 10 ))
    empty=$(( 10 - filled ))
    bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done
    if [ "$remaining_int" -le 15 ]; then
        printf " \033[0;31m[%s] %d%%\033[0m" "$bar" "$used_int"
    elif [ "$remaining_int" -le 35 ]; then
        printf " \033[0;33m[%s] %d%%\033[0m" "$bar" "$used_int"
    else
        printf " \033[0;32m[%s] %d%%\033[0m" "$bar" "$used_int"
    fi
fi
if [ -n "$cache_info" ]; then
    if [ -n "$cache_hit_rate" ] && [ "$cache_hit_rate" -le 15 ]; then
        printf "\033[0;31m%s\033[0m" "$cache_info"
    elif [ -n "$cache_hit_rate" ] && [ "$cache_hit_rate" -le 35 ]; then
        printf "\033[0;33m%s\033[0m" "$cache_info"
    else
        printf "\033[0;36m%s\033[0m" "$cache_info"
    fi
fi
if [ -n "$vim_mode" ]; then
    printf " \033[0;33m[%s]\033[0m" "$vim_mode"
fi
if [ -n "$cost_info" ]; then
    printf "\033[0;35m%s\033[0m" "$cost_info"
fi
if [ "$added_dirs_count" -gt 0 ] 2>/dev/null; then
    printf " \033[0;36m+%d dirs\033[0m" "$added_dirs_count"
fi
if [ -n "$transcript_info" ]; then
    printf "\033[0;37m%s\033[0m" "$transcript_info"
fi
