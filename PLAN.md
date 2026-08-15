# ZCode 部署与调试总计划

## 项目背景

在 Ubuntu Server 上部署 ZCode（Z.ai 出品的 AI 编程客户端），将本机已有的 cc4101 GLM-5.2 模型网关配置为 ZCode 的后端模型，端到端调试；配置最优交互方式（WebUI 优先、TUI 兜底）；所有改动通过 Git 管理并推送至 GitHub 仓库 `gitychzh/cc_repair_zcode`。

## 环境现状（调研结论）

| 项目 | 状态 |
|------|------|
| OS | Ubuntu 22.04 x86_64, Linux 5.15 |
| Node.js | v24.15.0 (满足 zcode-app-cli 要求 ≥22.19) |
| Docker | 29.5.3, cc4101 容器运行中 |
| cc4101 网关 | `http://127.0.0.1:4101`, Anthropic Messages API 兼容, model `cc-glm5-2` → 实际 `glm5_2_nv` |
| cc4101 认证 | API Key: `cc4101-token`, Header: `x-api-key` |
| Git 仓库 | 已 clone `gitychzh/cc_repair_zcode` 到 `/home/opc2_uname/cc_ps/cd_repair_zcode` |
| ChatGPT API | Edge 浏览器在运行但 API 返回 403（被检测异常活动），需修复后用于协作 |
| 代理 | mihomo 端口 7947/7893, git 已配置 http.proxy |

## ZCode 调研结论

- **ZCode** 是 Z.ai（智谱 AI / bigmodel.cn）出品的 AI 编程客户端，内置 GLM 系列模型
- **zcode-app-cli** (npm: `zcode-app-cli@latest`) 是非官方终端客户端，提取官方 ZCode Desktop 的 agent runtime，配合 `@zcode/tui` 实现终端 TUI 交互
- **架构**: Node.js launcher → 官方 zcode.cjs agent runtime → 本地 @zcode/tui adapter → pi-tui
- **配置路径**: `~/.zcode/cli/config.json`（首次启动自动生成）
- **自定义 Provider**: 支持 `anthropic` / `openai-compatible` / `openai` 三种 API 格式
- **不需要 OAuth**: 使用自定义 provider + 内联 API key 即可跳过登录
- **模型**: 配置 `provider.zai.kind=anthropic`, `baseURL` 指向 cc4101, `apiKey` 填 cc4101-token

## 执行计划

### 阶段 1: 安装 ZCode + 配置 cc4101 模型（核心）

1. **安装 zcode-app-cli**
   ```bash
   npm install -g zcode-app-cli@latest
   ```

2. **首次启动生成配置**
   ```bash
   zcode  # 首次运行自动创建 ~/.zcode/cli/config.json
   ```
   (会失败/退出，但配置文件已生成)

3. **配置 cc4101 作为自定义 Anthropic provider**
   编辑 `~/.zcode/cli/config.json`，设置：
   - `provider.zai.kind` = `"anthropic"`
   - `provider.zai.options.baseURL` = `"http://127.0.0.1:4101"`
   - `provider.zai.options.apiKey` = `"cc4101-token"`
   - `provider.zai.options.apiKeyRequired` = `true`
   - `provider.zai.models.cc-glm5-2.name` = `"GLM-5.2 (cc4101)"`
   - `model.main` = `"zai/cc-glm5-2"`
   - `model.lite` = `"zai/cc-glm5-2"`
   - `permission.mode` = `"build"` (安全默认)

4. **端到端测试**
   - TUI 交互测试: `zcode` → 输入 prompt → 验证 GLM-5.2 响应
   - Headless 测试: `zcode --prompt "Say hello"` → 验证输出
   - 工作目录测试: 在项目目录内运行，验证文件操作能力

### 阶段 2: 交互方式配置

**优先级**: WebUI > TUI (SSH)

1. **WebUI 方案评估**
   - 现有 cc_webui (CloudCLI UI) 当前服务 Claude Code, 架构是 Vite + Node server
   - 方案 A: 为 ZCode 独立部署一个 WebUI 实例（端口 3002），配置 `CLAUDE_CLI_PATH` 指向 zcode 二进制，`ANTHROPIC_BASE_URL` 指向 cc4101
   - 方案 B: 直接使用 zcode CLI 的 TUI 模式（SSH 直连）

2. **TUI 方案（兜底，已确认可行）**
   - SSH 连接后直接运行 `zcode` 进入 TUI
   - 验证: `/model` 确认模型、`/status` 确认运行状态、发送测试 prompt

3. **测试和调试**
   - WebUI: 浏览器访问 → 发送 prompt → 查看 GLM-5.2 响应
   - TUI: SSH → `zcode` → 发送 prompt → 确认流式输出
   - 记录两种方式的优缺点

### 阶段 3: ChatGPT 协作

1. **修复 ChatGPT API**
   - 当前 403 问题可能是 Edge 浏览器需要重新登录 ChatGPT
   - 检查 Edge profile 是否过期，必要时刷新登录状态
   - 备选: 使用 `api_ask.py` 的 backend API 模式

2. **与 ChatGPT 制定详细计划**
   - 将本计划发送给 ChatGPT 评审
   - 获取 ChatGPT 的修改建议和补充
   - 记录 ChatGPT 的反馈

3. **ChatGPT 验收**
   - 完成所有部署后，将结果发送给 ChatGPT 验收
   - 记录验收意见

### 阶段 4: Git 管理与文档

1. **记录所有改动到仓库**
   - `docs/01-zcode-install.md` — 安装过程记录
   - `docs/02-zcode-config.md` — 配置详情（脱敏 API key）
   - `docs/03-cc4101-integration.md` — cc4101 集成方案
   - `docs/04-interaction-methods.md` — 交互方式对比
   - `docs/05-testing-results.md` — 端到端测试结果
   - `docs/06-chatgpt-collaboration.md` — ChatGPT 协作记录
   - `config/zcode-config.example.json` — 配置模板
   - `scripts/install-zcode.sh` — 一键安装脚本
   - `scripts/test-zcode.sh` — 端到端测试脚本

2. **每次改动先 pull 再 push**
   ```bash
   git pull origin main
   # ... 修改 ...
   git add . && git commit -m "描述" && git push origin main
   ```

3. **工程化考虑**
   - 安装脚本可重复执行（幂等）
   - 配置文件模板化（方便迁移到其他机器）
   - 版本锁定（记录 zcode-app-cli 版本号）
   - 升级路径清晰（npm update + 检查配置兼容性）

## 风险与缓解

| 风险 | 缓解措施 |
|------|---------|
| zcode-app-cli 提取的官方 runtime 可能有许可证限制 | 仅在本地使用，不分发；记录在 docs |
| cc4101 只支持 cc-glm5-2 一个模型 | zcode 配置 model.main 和 model.lite 都指向它 |
| ChatGPT API 403 | 优先尝试刷新登录；如不可用，手动记录计划让用户审核 |
| Node.js 版本变化 | 记录 Node v24.15.0 + zcode version |
| 网络代理依赖 | git/npm 已配置 proxy，记录在文档中 |

## 执行顺序

1. ✅ 调研 zcode 官方信息（完成）
2. ✅ Clone 仓库（完成）
3. ✅ 安装 zcode-app-cli v3.7.7-13（完成）
4. ✅ 配置 cc4101 作为自定义 provider（完成）
5. ✅ 端到端测试 8/8 通过（完成）
6. ✅ WebUI (port 3002) + TUI 测试（完成）
7. ⚠️ ChatGPT API (api_ask.py 403; js_ask.py 可用但不稳定)
8. 🔄 编写文档和脚本
9. ⬜ Git commit + push
10. ⬜ ChatGPT 验收
