# ZCode 安装指南

## 概述

ZCode 是 Z.ai (智谱AI/bigmodel.cn) 推出的 AI 编码客户端，基于 GLM 系列模型（GLM-5.2、GLM-5.3 等）。

本项目使用 `zcode-app-cli`（非官方 npm 终端客户端），它提取官方 ZCode Desktop 的 agent runtime 并通过 pi-tui 提供 TUI 界面。

## 安装

### 前置条件

- Node.js >= 20（推荐 v24+）
- npm 全局包路径：`~/.npm-global`
- mihomo 代理（端口 7947）用于 GitHub/npm 访问

### 一键安装脚本

```bash
cd /home/opc2_uname/cc_ps/cd_repair_zcode
bash scripts/install-zcode.sh
```

脚本功能：
1. 检查 Node.js 版本
2. 安装 `zcode-app-cli`（全局）
3. 生成并创建配置文件（`~/.zcode/cli/config.json`）
4. 配置 cc4101 为自定义 Anthropic provider
5. 验证安装（发送测试 prompt）

### 手动安装

```bash
# 设置代理
export http_proxy=http://127.0.0.1:7947
export https_proxy=http://127.0.0.1:7947

# 安装
npm install -g zcode-app-cli

# 验证
zcode --version
```

## 版本信息

| 组件 | 版本 |
|------|------|
| zcode-app-cli | 3.7.7-13 |
| 内置 runtime | 0.16.3 |
| Node.js | v24.15.0 |

## 升级策略

```bash
# 查看当前版本
zcode --version

# 升级到最新版
npm update -g zcode-app-cli

# 或指定版本
npm install -g zcode-app-cli@<version>
```

升级后配置文件 (`~/.zcode/cli/config.json`) 保留不变，无需重新配置 cc4101。
