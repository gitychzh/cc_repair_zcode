#!/usr/bin/env bash
# ZCode 一键健康检查
# 用法: bash scripts/healthcheck-zcode.sh
# 快速诊断 ZCode 环境，不需要完整 E2E 测试

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

echo "=== ZCode Health Check ==="
echo ""

# 1. Node.js
if command -v node &>/dev/null; then
  NODE_VER=$(node --version)
  NODE_MAJOR=$(echo "$NODE_VER" | sed 's/v\([0-9]*\).*/\1/')
  if [ "$NODE_MAJOR" -ge 22 ]; then
    pass "Node.js $NODE_VER (>= 22.19)"
  else
    fail "Node.js $NODE_VER (need >= 22.19)"
  fi
else
  fail "Node.js not found"
  exit 1
fi

# 2. zcode installed
if command -v zcode &>/dev/null; then
  ZCODE_VER=$(zcode --version 2>&1 | head -1)
  pass "zcode installed: $ZCODE_VER"
else
  fail "zcode not on PATH"
  exit 1
fi

# 3. Config exists
CONFIG_PATH="$HOME/.zcode/cli/config.json"
if [ -f "$CONFIG_PATH" ]; then
  pass "config exists: $CONFIG_PATH"
else
  fail "config not found: $CONFIG_PATH"
  exit 1
fi

# 4. Provider configured
if grep -q '"zai"' "$CONFIG_PATH" 2>/dev/null; then
  pass "provider zai configured"
else
  fail "provider zai not found in config"
fi

# 5. Model configured
if grep -q 'cc-glm5-2' "$CONFIG_PATH" 2>/dev/null; then
  pass "model cc-glm5-2 configured"
else
  fail "model cc-glm5-2 not found in config"
fi

# 6. cc4101 reachable
if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:4101/v1/models 2>/dev/null | grep -q "200"; then
  pass "cc4101 reachable (127.0.0.1:4101)"
else
  fail "cc4101 not reachable (127.0.0.1:4101)"
  exit 1
fi

# 7. Authentication works
AUTH_TEST=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "x-api-key: cc4101-token" \
  -H "Content-Type: application/json" \
  -d '{"model":"cc-glm5-2","max_tokens":5,"messages":[{"role":"user","content":"hi"}]}' \
  http://127.0.0.1:4101/v1/messages 2>/dev/null)
if [ "$AUTH_TEST" = "200" ]; then
  pass "cc4101 authentication works"
else
  fail "cc4101 authentication failed (HTTP $AUTH_TEST)"
fi

# 8. Model responds (quick test)
RESPONSE=$(zcode --prompt "Reply: OK" --mode yolo --json 2>/dev/null)
if echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); assert d.get('response','')" 2>/dev/null; then
  pass "GLM-5.2 model responds"
else
  fail "GLM-5.2 model did not respond"
fi

# 9. Git available
if command -v git &>/dev/null; then
  pass "git available"
else
  warn "git not found"
fi

# 10. tmux available
if command -v tmux &>/dev/null; then
  pass "tmux available (recommended for persistent sessions)"
else
  warn "tmux not found (recommended for SSH persistence)"
fi

echo ""
echo "=== Health check complete ==="
