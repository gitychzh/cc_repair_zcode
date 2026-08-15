#!/bin/bash
# ZCode 安装脚本 — 在 Ubuntu Server 上安装并配置 zcode-app-cli
# 使用 cc4101 作为自定义 Anthropic provider (GLM-5.2)
# 幂等：可重复执行
set -euo pipefail

ZCODE_NPM_PACKAGE="zcode-app-cli@latest"
ZCODE_CONFIG_DIR="$HOME/.zcode/cli"
ZCODE_CONFIG_FILE="$ZCODE_CONFIG_DIR/config.json"
CC4101_BASE_URL="http://127.0.0.1:4101"
CC4101_API_KEY="cc4101-token"
CC4101_MODEL_ID="cc-glm5-2"

echo "=== ZCode 安装脚本 ==="
echo "时间: $(date)"
echo "Node 版本: $(node --version 2>/dev/null || echo '未安装')"
echo ""

# 1. 检查 Node.js 版本 (需要 >= 22.19)
NODE_VERSION=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1)
if [ -z "$NODE_VERSION" ] || [ "$NODE_VERSION" -lt 22 ]; then
    echo "错误: 需要 Node.js >= 22.19, 当前: ${NODE_VERSION:-未安装}"
    echo "请先安装 Node.js 22+: https://nodejs.org/"
    exit 1
fi
echo "✓ Node.js 版本满足要求 ($NODE_VERSION)"

# 2. 安装 zcode-app-cli
if command -v zcode &>/dev/null; then
    CURRENT_VERSION=$(zcode --version 2>&1 | head -1)
    echo "✓ zcode 已安装: $CURRENT_VERSION"
    echo "  如需更新: npm install -g $ZCODE_NPM_PACKAGE"
else
    echo "→ 安装 zcode-app-cli..."
    npm install -g "$ZCODE_NPM_PACKAGE"
    echo "✓ 安装完成: $(zcode --version 2>&1 | head -1)"
fi

# 3. 首次启动生成配置
if [ ! -f "$ZCODE_CONFIG_FILE" ]; then
    echo "→ 首次启动生成配置文件..."
    zcode --prompt "init" --mode yolo 2>/dev/null || true
    sleep 2
fi

if [ ! -f "$ZCODE_CONFIG_FILE" ]; then
    echo "→ 配置文件未自动生成，手动创建..."
    mkdir -p "$ZCODE_CONFIG_DIR"
    cat "$SCRIPT_DIR/../config/zcode-config.example.json" > "$ZCODE_CONFIG_FILE"
    chmod 600 "$ZCODE_CONFIG_FILE"
fi

echo "✓ 配置文件: $ZCODE_CONFIG_FILE"

# 4. 配置 cc4101 作为自定义 provider
echo "→ 配置 cc4101 作为自定义 Anthropic provider..."

# 使用 Python 修改 JSON 配置
python3 -c "
import json
import os

config_path = os.path.expanduser('$ZCODE_CONFIG_FILE')
with open(config_path, 'r') as f:
    config = json.load(f)

# 配置 provider
config['provider']['zai']['kind'] = 'anthropic'
config['provider']['zai']['name'] = 'cc4101 Local Gateway'
config['provider']['zai']['options'] = {
    'apiKeyRequired': True,
    'baseURL': '$CC4101_BASE_URL',
    'apiKey': '$CC4101_API_KEY'
}
config['provider']['zai']['headers'] = {
    'x-api-key': '$CC4101_API_KEY'
}
config['provider']['zai']['models'] = {
    '$CC4101_MODEL_ID': {
        'name': 'GLM-5.2 (cc4101 local)'
    }
}

# 配置模型
config['model']['main'] = f'zai/$CC4101_MODEL_ID'
config['model']['lite'] = f'zai/$CC4101_MODEL_ID'

# 安全默认
config['permission']['mode'] = 'build'

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')
os.chmod(config_path, 0o600)
print('✓ 配置已更新')
"

# 5. 验证
echo ""
echo "→ 验证安装..."
RESULT=$(zcode --prompt "Say hello" --mode yolo --json 2>&1)
if echo "$RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); print('✓ 模型响应:', d.get('response','')[:50])" 2>/dev/null; then
    echo ""
    echo "=== 安装完成 ==="
    echo "ZCode 版本: $(zcode --version 2>&1 | head -1)"
    echo "配置文件: $ZCODE_CONFIG_FILE"
    echo "模型: $CC4101_MODEL_ID (via $CC4101_BASE_URL)"
    echo ""
    echo "使用方式:"
    echo "  TUI:    zcode"
    echo "  Headless: zcode --prompt \"your prompt\""
    echo "  JSON:   zcode --prompt \"your prompt\" --json"
else
    echo "✗ 验证失败"
    echo "$RESULT" | head -20
    exit 1
fi
