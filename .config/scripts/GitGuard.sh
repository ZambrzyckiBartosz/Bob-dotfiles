#!/bin/bash

PROJECTS_DIR="/home/bob/Git-Projects"

dirty_repos=0
unpushed_repos=0
uninitialized_repos=0
details=""

for repo_dir in "$PROJECTS_DIR"/*/; do
    [ -d "$repo_dir" ] || continue
    
    repo_name=$(basename "$repo_dir")
    
    if [ ! -d "$repo_dir/.git" ]; then
        ((uninitialized_repos++))
        details+="$repo_name (Not a Git repo - run git init)  "
        continue
    fi

    cd "$repo_dir" || continue

    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        ((dirty_repos++))
        details+="$repo_name (Unsaved changes)   "
    fi

    if git rev-parse --abbrev-ref @{u} > /dev/null 2>&1; then
        unpushed=$(git rev-list --count @{u}..HEAD 2>/dev/null)
        if [ "$unpushed" -gt 0 ]; then
            ((unpushed_repos++))
            details+="$repo_name ($unpushed to push)  "
        fi
    else
        if [ -n "$(git log -1 2>/dev/null)" ]; then
            ((unpushed_repos++))
            details+="$repo_name (Not pushed to GitHub yet)  "
        fi
    fi
done

total_issues=$((dirty_repos + unpushed_repos + uninitialized_repos))

if [ "$total_issues" -gt 0 ]; then
    tooltip="Remember to fix:\r${details}"
    echo "{\"text\": \" ${total_issues}\", \"tooltip\": \"$tooltip\", \"class\": \"warning\"}"
else
    echo "{\"text\": \"\", \"tooltip\": \"All committed!\", \"class\": \"clean\"}"
fi
