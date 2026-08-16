# ZCode 交互方式

## 官方推荐：TUI（终端 UI）

根据 zcode-app-cli 官方 README，TUI 是核心设计的使用方式。zcode-app-cli 提取了 ZCode Desktop 的官方 agent runtime，配合 `@zcode/tui` 实现终端交互界面。

### 为什么推荐 TUI

| 特性 | TUI (SSH) | WebUI (浏览器) |
|------|-----------|----------------|
| 流式输出 | ✅ 实时流式显示 | ⚠️ 阻塞等待完整响应 |
| 会话管理 | ✅ 多会话、`/resume`、`/rewind` | ❌ 每次 prompt 独立会话 |
| 上下文延续 | ✅ 对话上下文保持 | ❌ 无上下文 |
| 文件操作 | ✅ `@` 引用、inline diff | ❌ 不支持 |
| 权限审批 | ✅ 交互式审批对话框 | ⚠️ 仅模式切换 |
| Plugin/Skill | ✅ 完整支持 | ❌ 不支持 |
| 会话恢复 | ✅ `--resume`/`--continue` | ❌ 不支持 |
| 配置命令 | ✅ `/status` `/model` `/mode` 等 | ❌ 不支持 |

### 使用方式

#### 直接 SSH + TUI

```bash
# SSH 连接到服务器
ssh user@server

# 启动 TUI（默认命令）
zcode

# 在 TUI 中：
# - 直接输入 prompt 回车发送
# - Shift+Tab 切换权限模式 (build → edit → yolo → plan)
# - Ctrl+N 切换模型
# - /help 查看命令
# - /model 查看/切换模型
# - /mode 查看/切换权限
# - /status 查看运行状态
# - /exit 退出
```

#### 在 tmux 中运行（推荐）

```bash
# 启动 tmux 会话
tmux new -s zcode

# 在 tmux 中启动 zcode
zcode

# 断开（保留会话）
# Ctrl+B 然后 D

# 重新连接
tmux attach -s zcode
```

### TUI 核心功能

- **流式输出**：实时显示 GLM-5.2 的流式回复
- **CJK 编辑器**：多行编辑，支持中文输入
- **`@` 文件引用**：输入 `@` 弹出工作目录文件补全
- **`$` Skill 调用**：输入 `$` 弹出 Skill 选择器
- **`/` 斜杠命令**：`/help`、`/model`、`/mode`、`/status`、`/diff`、`/context` 等
- **会话管理**：`/resume` 恢复会话、双击 Esc 回溯对话
- **附件**：Ctrl+V 粘贴图片
- **Markdown 渲染**：语法高亮代码块、Mermaid 图表
- **Active-turn steering**：运行中按 Enter 追加指令

### 权限模式

| 模式 | 说明 | 适用场景 |
|------|------|----------|
| `build` | 文件操作需确认（默认） | 日常开发 |
| `edit` | 只读 + 编辑 | 代码审查 |
| `plan` | 只规划不执行 | 方案设计 |
| `yolo` | 全自动无确认 | 脚本/自动化 |

## Headless 模式（脚本/自动化）

```bash
# 单次 prompt（JSON 输出）
zcode --prompt "你的问题" --mode yolo --json

# 指定工作目录
zcode --prompt "修复这个 bug" --cwd /path/to/project --mode build

# 附带文件
zcode --prompt "分析这个文件" --attach /path/to/file.py

# 恢复上次会话
zcode --continue

# 最大轮次限制
zcode --prompt "复杂任务" --max-turns 10

# 设置会话目标
zcode --prompt "实现功能" --target "完成 XXX 模块" --mode build
```

## WebUI（已弃用）

WebUI 之前作为浏览器交互方案部署在端口 3002，但存在以下限制：

- 每次 prompt 启动新的 zcode 进程，**无会话上下文延续**
- `zcode --prompt` 是同步阻塞模式，响应需要 30-60 秒
- 不支持 TUI 的流式输出、文件引用、Skill/Plugin 等功能
- WebSocket 缺少心跳保活，长时间等待可能断连

**推荐替代方案**：通过 SSH + TUI 使用完整功能。

如仍需 WebUI 代码作为参考，`webui/` 目录保留但不再推荐使用。

## 环境要求

- **Node.js** ≥ 22.19（当前 v24.15.0）
- **终端**：支持 ANSI 256 色的终端（SSH 直连即可）
- **tmux**（可选）：用于持久化会话
