#!/usr/bin/env bash
# Install the persona review panel for Claude Code and Codex.
# 1) installs the six upstream persona skills (alchaincyf, MIT) with the skills CLI
# 2) copies the panel skill and the reviewer agents from this repo
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
UPSTREAM=(feynman-skill steve-jobs-skill karpathy-skill ilya-sutskever-skill zhang-yiming-skill elon-musk-skill)

for repo in "${UPSTREAM[@]}"; do
  npx -y skills add "alchaincyf/$repo" -g -a claude-code -a codex -s '*' -y
done

mkdir -p ~/.agents/skills ~/.claude/skills ~/.claude/agents/personas ~/.codex/agents
cp -R "$REPO/skills/persona-panel" ~/.agents/skills/
ln -sfn ../../.agents/skills/persona-panel ~/.claude/skills/persona-panel
cp "$REPO"/agents/claude/*.md ~/.claude/agents/personas/
cp "$REPO"/agents/codex/*.toml ~/.codex/agents/

echo "Done. Restart Claude Code / Codex, then say: 评审团，让乔布斯和费曼审一下 <文件>"
