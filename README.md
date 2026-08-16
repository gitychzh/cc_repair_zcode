# cc_repair_zcode

ZCode 安装、配置与交互工程化项目 — 在本机 Ubuntu Server 上部署 ZCode，通过 cc4101 模型网关使用本地 GLM-5.2 模型。

## 项目结构

```
cc_repair_zcode/
├── PLAN.md                  # 执行计划
├── README.md                # 本文件
├── config/
│   └── zcode-config.example.json  # ZCode 配置模板
├── docs/
│   ├── 01-zcode-install.md    # 安装指南
│   ├── 02-zcode-config.md     # 配置指南
│   ├── 03-cc4101-integration.md  # cc4101 集成
│   ├── 04-interaction-methods.md  # 交互方式（TUI 为推荐方式）
│   ├── 05-testing-results.md   # 测试结果
│   └── 06-chatgpt-collaboration.md  # ChatGPT 协作
├── scripts/
│   ├── install-zcode.sh       # 安装脚本（幂等）
│   └── test-zcode.sh          # 端到端测试（8项）
└── webui/                     # WebUI（已弃用，保留作参考）
    ├── webui.js
    ├── public/index.html
    ├── package.json
    └── zcode-webui.service
```

## 快速开始

### 1. 安装 ZCode

```bash
bash scripts/install-zcode.sh
```

### 2. 验证安装

```bash
bash scripts/test-zcode.sh
```

### 3. 使用 TUI（官方推荐）

```bash
# SSH 连接后直接运行
zcode

# 或在 tmux 中持久化运行
tmux new -s zcode
zcode
# Ctrl+B D 断开，tmux attach -s zcode 重连
```

### 4. Headless 模式（脚本/自动化）

```bash
# 单次 prompt（JSON 输出）
zcode --prompt "你的问题" --mode yolo --json

# 指定工作目录
zcode --prompt "修复这个 bug" --cwd /path/to/project --mode build
```

> ⚠️ **WebUI 已弃用**：之前部署的端口 3002 WebUI 存在会话不延续、响应阻塞等问题。
> 官方推荐方式是 **SSH + TUI**，功能最完整（流式输出、会话管理、文件引用、Skill/Plugin）。
> 详见 [交互方式文档](docs/04-interaction-methods.md)。

## 技术栈

- **ZCode**: zcode-app-cli 3.7.7-13（runtime 0.16.3）
- **模型**: GLM-5.2 via cc4101 (Anthropic Messages API 代理)
- **Node.js**: v24.15.0
- **OS**: Ubuntu 22.04 x86_64

## 关键设计

- **Provider key 必须为 `zai`**: ZCode 上游登录门控要求，即使使用自定义 baseURL
- **cc4101 地址**: `http://127.0.0.1:4101`，API key: `cc4101-token`
- **Model ID**: `cc-glm5-2`，在 config 中引用为 `zai/cc-glm5-2`
- **上下文窗口**: 200K tokens
- **推荐交互方式**: SSH + TUI（`zcode` 命令直接启动）

Git 仓库: https://github.com/gitychzh/cc_repair_zcode
