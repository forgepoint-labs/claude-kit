#!/bin/bash
# Installs the separation-audit script as a git pre-commit hook.
# Run once after cloning the repo.

set -e

HOOK_DIR=".git/hooks"
HOOK_FILE="$HOOK_DIR/pre-commit"
AUDIT_SCRIPT=".github/scripts/separation-audit.sh"

if [ ! -d "$HOOK_DIR" ]; then
  echo "❌ Not inside a git repo (no .git/hooks directory found)."
  exit 1
fi

if [ ! -f "$AUDIT_SCRIPT" ]; then
  echo "❌ $AUDIT_SCRIPT not found."
  exit 1
fi

cat > "$HOOK_FILE" <<'EOF'
#!/bin/bash
# Pre-commit hook: block AGC / client content from reaching the public repo.
bash "$(git rev-parse --show-toplevel)/.github/scripts/separation-audit.sh" staged
EOF

chmod +x "$HOOK_FILE"
chmod +x "$AUDIT_SCRIPT"

echo "✅ Pre-commit hook installed at $HOOK_FILE"
echo "   Runs $AUDIT_SCRIPT on every commit."
