# ChatGPT 协作与验收

## 协作模型

按照用���要求，本项目的协作模型为：
1. **Claude（本机）**：执行具体工作 — 安装、配置、编码、测试
2. **ChatGPT（Edge CDP）**：制定计划、审查和验收

## ChatGPT API 状态

### 当前问题

ChatGPT API（通过 Edge CDP 自动化）遇到 **403 "Unusual activity has been detected"** 限制：

```
HTTP 403 {"detail":"Unusual activity has been detected from your device..."}
```

### 原因

ChatGPT 检测到自动化请求，要求用户在浏览器中完成验证（验证码/人机确认）。

### 解决方案

- **手动解除**：用户需要在 Edge 浏览器中手动访问 chatgpt.com 并完成验证
- 完成后 ChatGPT API 脚本可恢复正常

### 脚本位置

```
/home/opc2_uname/cc_ps/chatgpt_api/
├── api_ask.py       # API 后端请求（推荐）
├── js_ask.py        # DOM 交互方式
├── login_edge.py    # Edge CDP 连接工具
└── ...
```

### ChatGPT API 使用

```bash
cd /home/opc2_uname/cc_ps/chatgpt_api
python3 api_ask.py "你的问题"
```

## 项目交付物

### 已完成

1. ✅ ZCode 安装（zcode-app-cli 3.7.7-13）
2. ✅ cc4101 集成（Anthropic Messages API → GLM-5.2）
3. ✅ 配置文件（~/.zcode/cli/config.json）
4. ✅ WebUI（Express + WebSocket，端口 3002）
5. ✅ 端到端测试（8/8 通过）
6. ✅ 交互方式文档（WebUI + TUI/SSH）
7. ✅ Git 仓库管理

### 待 ChatGPT 验收

- [ ] 计划审查：PLAN.md 中的执行计划
- [ ] 架构审查：Provider 集成方案
- [ ] 代码审查：WebUI、脚本、配置
- [ ] 测试验收：8 项端到端测试结果
- [ ] 文档验收：6 篇文档完整性

## 验收清单

提交给 ChatGPT 审查的内容：

1. `PLAN.md` — 执行计划
2. `docs/01-zcode-install.md` — 安装指南
3. `docs/02-zcode-config.md` — 配置指南
4. `docs/03-cc4101-integration.md` — cc4101 集成
5. `docs/04-interaction-methods.md` — 交互方式
6. `docs/05-testing-results.md` — 测试结果
7. `scripts/install-zcode.sh` — 安装脚本
8. `scripts/test-zcode.sh` — 测试脚本
9. `webui/` — WebUI 完整代码
10. `config/zcode-config.example.json` — 配置模板
