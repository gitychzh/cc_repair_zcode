#!/bin/bash
# ZCode 端到端测试脚本
# 测试 TUI headless 模式、文件操作、JSON 输出、模型连接
set -euo pipefail

PASS=0
FAIL=0
TEST_DIR="/tmp/zcode-e2e-test"

echo "=== ZCode 端到端测试 ==="
echo "时间: $(date)"
echo ""

rm -rf "$TEST_DIR" && mkdir -p "$TEST_DIR"

# 测试 1: 基本连通性
echo -n "Test 1: 基本连通性 (Say hello)... "
RESULT=$(zcode --prompt "Say hello" --mode yolo --json 2>&1)
if echo "$RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); assert d.get('response','')" 2>/dev/null; then
    RESPONSE=$(echo "$RESULT" | python3 -c "import json,sys; print(json.load(sys.stdin)['response'])")
    echo "PASS (response: ${RESPONSE:0:50})"
    PASS=$((PASS+1))
else
    echo "FAIL"
    echo "  $RESULT" | head -5
    FAIL=$((FAIL+1))
fi

# 测试 2: 数学推理
echo -n "Test 2: 数学推理 (2+2)... "
RESULT=$(zcode --prompt "What is 2+2? Reply with just the number." --mode yolo --json 2>&1)
if echo "$RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); assert '4' in d.get('response','')" 2>/dev/null; then
    echo "PASS"
    PASS=$((PASS+1))
else
    echo "FAIL"
    echo "  $RESULT" | head -5
    FAIL=$((FAIL+1))
fi

# 测试 3: 文件创建
echo -n "Test 3: 文件创建... "
RESULT=$(zcode --prompt "Create a file called test.txt with content 'E2E test OK'" --mode yolo --cwd "$TEST_DIR" 2>&1)
if [ -f "$TEST_DIR/test.txt" ] && grep -q "E2E test OK" "$TEST_DIR/test.txt"; then
    echo "PASS"
    PASS=$((PASS+1))
else
    echo "FAIL"
    FAIL=$((FAIL+1))
fi

# 测试 4: 文件读取
echo -n "Test 4: 文件读取... "
RESULT=$(zcode --prompt "Read the file test.txt and tell me its content" --mode yolo --cwd "$TEST_DIR" --json 2>&1)
if echo "$RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); assert 'E2E test OK' in d.get('response','')" 2>/dev/null; then
    echo "PASS"
    PASS=$((PASS+1))
else
    echo "FAIL"
    echo "  $RESULT" | head -5
    FAIL=$((FAIL+1))
fi

# 测试 5: 代码生成
echo -n "Test 5: 代码生成... "
RESULT=$(zcode --prompt "Create a Python file called hello.py that prints 'Hello from ZCode'" --mode yolo --cwd "$TEST_DIR" 2>&1)
if [ -f "$TEST_DIR/hello.py" ] && python3 "$TEST_DIR/hello.py" 2>/dev/null | grep -q "Hello from ZCode"; then
    echo "PASS"
    PASS=$((PASS+1))
else
    echo "FAIL"
    FAIL=$((FAIL+1))
fi

# 测试 6: JSON 结构化输出
echo -n "Test 6: JSON 结构化输出... "
RESULT=$(zcode --prompt "Return a JSON object with key 'status' and value 'ok'" --mode yolo --json 2>&1)
if echo "$RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); assert d.get('usage'); assert d.get('sessionId')" 2>/dev/null; then
    echo "PASS"
    PASS=$((PASS+1))
else
    echo "FAIL"
    FAIL=$((FAIL+1))
fi

# 测试 7: Token 使用统计
echo -n "Test 7: Token 使用统计... "
RESULT=$(zcode --prompt "Say OK" --mode yolo --json 2>&1)
if echo "$RESULT" | python3 -c "
import json,sys
d=json.load(sys.stdin)
usage = d.get('usage',{})
assert usage.get('inputTokens',0) > 0
assert usage.get('outputTokens',0) > 0
" 2>/dev/null; then
    INPUT_TOK=$(echo "$RESULT" | python3 -c "import json,sys; print(json.load(sys.stdin)['usage']['inputTokens'])")
    OUTPUT_TOK=$(echo "$RESULT" | python3 -c "import json,sys; print(json.load(sys.stdin)['usage']['outputTokens'])")
    echo "PASS (in:$INPUT_TOK out:$OUTPUT_TOK)"
    PASS=$((PASS+1))
else
    echo "FAIL"
    FAIL=$((FAIL+1))
fi

# 测试 8: 上下文窗口
echo -n "Test 8: 上下文窗口... "
RESULT=$(zcode --prompt "Say OK" --mode yolo --json 2>&1)
if echo "$RESULT" | python3 -c "
import json,sys
d=json.load(sys.stdin)
proj = d.get('projection',{})
assert proj.get('contextWindow',0) > 0
" 2>/dev/null; then
    CTX=$(echo "$RESULT" | python3 -c "import json,sys; print(json.load(sys.stdin)['projection']['contextWindow'])")
    echo "PASS (context window: $CTX)"
    PASS=$((PASS+1))
else
    echo "FAIL"
    FAIL=$((FAIL+1))
fi

echo ""
echo "=== 测试结果 ==="
echo "通过: $PASS"
echo "失败: $FAIL"
echo "总计: $((PASS+FAIL))"

if [ $FAIL -gt 0 ]; then
    exit 1
fi

# 清理
rm -rf "$TEST_DIR"
echo "✓ 所有测试通过"
