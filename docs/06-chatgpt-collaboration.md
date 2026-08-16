# ChatGPT 协作与验收

## 协作模型

1. **Claude（本机）**：执行具体工作 — 安装、配置、编码、测试
2. **ChatGPT（Edge CDP）**：制定计划、审查和验收

## ChatGPT API 状态

### 历史

ChatGPT API（通过 Edge CDP 自动化）曾遇到 **403 "Unusual activity has been detected"** 限制，现已恢复可用。

### 使用方式

```bash
cd /home/opc2_uname/cc_ps/chatgpt_api
python3 api_ask.py "你的问题"
```

## ChatGPT 验收结果（2026-08-16）

### 最终判定：PASS（带 WARN 项，无 FAIL 项）

### 分项验收

| # | 验收项 | 结论 | 验收意见 |
|---|--------|------|----------|
| 1 | 计划合理性 | ✅ PASS | 阶段划分清晰，核心目标明确；从安装→Provider→E2E→TUI→文档→Git 的闭环合理。WebUI 调整为 TUI 主方案是正确取舍。 |
| 2 | cc4101 Provider | ✅ PASS | `zai/cc-glm5-2 → 127.0.0.1:4101 → cc4101 → GLM-5.2` 已有实际 E2E 证据；非流式、SSE、Token usage、200K context 均有验证。 |
| 3 | TUI 替代 WebUI | ✅ PASS | 正确决策。WebUI 会话不连续、同步阻塞、功能缺失；TUI + SSH + tmux 更适合本机长期 Agent 工作。 |
| 4 | E2E 测试覆盖 | ⚠️ WARN | 8/8 足以证明"基本部署成功"，但不足以证明"完整 Coding Agent 可用"。缺 tool calling、多轮上下文、Agent 编辑闭环、异常恢复。 |
| 5 | 文档完整性 | ✅ PASS | PLAN、README、安装、配置、集成、交互、测试、ChatGPT 协作文档结构完整。 |
| 6 | 脚本可用性 | ⚠️ WARN | 脚本存在且测试通过，但幂等性、异常退出码、依赖检查需进一步验证。 |
| 7 | 一键健康检查 | ⚠️ WARN | 建议补充 `healthcheck-zcode.sh` 快速诊断工具。 |
| 8 | 遗漏项 | ⚠️ WARN | 缺 Agent 能力专项验证、升级回滚、安全检查等。 |

### ChatGPT 建议补充项

1. **Tool calling / Agent loop**：让 ZCode 创建文件→修改→读取，一次任务内多个 tool calls
2. **多轮上下文**：第一轮给隐含信息，第二轮验证上下文延续
3. **代码编辑闭环**：创建项目→修改代码→执行测试→根据结果再修改
4. **异常恢复**：模拟 API error/timeout，确认不挂死
5. **一键健康检查**：`healthcheck-zcode.sh`

### ChatGPT 关键意见

> "现有 8/8 更准确地说应该叫 Transport/API/E2E Basic 8/8，而不是 Full Coding-Agent 8/8。"
> "核心链路已经具备上线使用条件；主要缺口集中在 tool calling/Agent 能力验证。"
> "TUI + tmux = 当前项目正式方案，这个结论可以通过。"

## 项目交付物

### 已完成

1. ✅ ZCode 安装（zcode-app-cli 3.7.7-13）
2. ✅ cc4101 集成（Anthropic Messages API → GLM-5.2）
3. ✅ 配置文件（~/.zcode/cli/config.json）
4. ✅ TUI 验证通过（官方推荐方式）
5. ✅ 端到端测试（8/8 通过）
6. ✅ 交互方式文档（TUI 为主，WebUI 弃用）
7. ✅ Git 仓库管理（已推送 GitHub）
8. ✅ ChatGPT 验收（PASS with WARN）

### 后续改进方向

- [ ] 补充 tool calling 测试
- [ ] 补充多轮上下文测试
- [ ] 补充一键健康检查脚本
- [ ] 验证 install/test 脚本幂等性
- [ ] Agent 编辑闭环测试
