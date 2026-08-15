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
│   ├── 04-interaction-methods.md  # 交互方式
│   ├── 05-testing-results.md   # 测试结果
│   └── 06-chatgpt-collaboration.md  # ChatGPT 协作
├── scripts/
│   ├── install-zcode.sh       # 安装脚本（幂等）
│   └── test-zcode.sh          # 端到端测试（8项）
└── webui/
    ├── webui.js               # Express + WebSocket 服务器
    ├── public/index.html       # WebUI 前端
    ├── package.json
    └── zcode-webui.service     # systemd 服务模板
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

### 3. 使用 WebUI

```bash
cd webui && node webui.js
# 浏览器访问 http://localhost:3002
```

### 4. 使用 TUI / Headless

```bash
# TUI
zcode

# 单次 prompt
zcode --prompt "你的问题" --mode yolo --json
```

## 技术栈

- **ZCode**: zcode-app-cli 3.7.7-13（runtime 0.16.3）
- **模型**: GLM-5.2 via cc4101 (Anthropic Messages API 代理)
- **WebUI**: Express + WebSocket + 原生 HTML/JS
- **Node.js**: v24.15.0

## 关键设计

- **Provider key 必须为 `zai`**: ZCode 上游登录门控要求，即使使用自定义 baseURL
- **cc4101 地址**: `http://127.0.0.1:4101`，API key: `cc4101-token`
- **Model ID**: `cc-glm5-2`，在 config 中引用为 `zai/cc-glm5-2`
- **上下文窗口**: 200K tokens

Git 仓库: https://github.com/gitychzh/cc_repair_zcode
