# ZCode 交互方式

## 可选交互方式

| 方式 | URL/端口 | 状态 | 适用场景 |
|------|----------|------|----------|
| WebUI | http://<host>:3002 | ✅ 已实现 | 浏览器远程交互 |
| TUI (SSH) | 终端 | ✅ 可用 | SSH 连接，终端交互 |
| 飞书 | — | ❌ 不支持 | zcode 无飞书集成 |

## 方式一：WebUI（推荐）

### 启动

```bash
cd /home/opc2_uname/cc_ps/cd_repair_zcode/webui
node webui.js --port 3002 --host 0.0.0.0
```

### systemd 服务

```bash
# 安装服务（需 sudo）
sudo cp zcode-webui.service /etc/systemd/system/zcode-webui@.service
sudo systemctl daemon-reload
sudo systemctl enable --now zcode-webui@$(whoami)

# 管理
sudo systemctl status zcode-webui@$(whoami)
sudo systemctl restart zcode-webui@$(whoami)
sudo journalctl -u zcode-webui@$(whoami) -f
```

### 功能

- **聊天界面**：发送 prompt，显示响应
- **工作目录选择**：左侧栏列出 ~/cc_ps 下的工作目录
- **权限模式切换**：Yolo / Build / Edit / Plan
- **流式输出**：实时显示 zcode 命令输出
- **Token 统计**：显示 input/output/total tokens 和 context window
- **WebSocket 连接**：自动重连

### API 端点

| 端点 | 方法 | 说明 |
|------|------|------|
| `/` | GET | WebUI 前端 (index.html) |
| `/api/status` | GET | 系统状态（版本、时间戳） |
| `/api/workspaces` | GET | 工作目录列表 |
| `/ws` | WebSocket | Prompt 执行（双向流式） |

### WebSocket 协议

**发送**：
```json
{
  "type": "prompt",
  "prompt": "你的问题",
  "cwd": "/path/to/workspace",
  "mode": "yolo"
}
```

**接收**：
```json
// 流式输出
{"type": "stream", "data": "..."}

// 最终结果
{"type": "result", "data": {"response": "...", "usage": {...}, "projection": {...}}}

// 错误
{"type": "error", "error": "..."}
```

## 方式二：TUI（SSH）

### 直接 SSH + TUI

```bash
# SSH 连接到服务器
ssh user@server

# 启动 TUI
zcode
```

### 在 tmux 中运行（推荐）

```bash
# 启动 tmux 会话
tmux new -s zcode

# 在 tmux 中启动
zcode

# 断开（保留会话）
# Ctrl+B 然后 D

# 重新连接
tmux attach -s zcode
```

### Headless 模式

```bash
# 单次 prompt
zcode --prompt "你的问题" --mode yolo --json

# 指定工作目录
zcode --prompt "修复这个 bug" --cwd /path/to/project --mode build

# 附带文件
zcode --prompt "分析这个文件" --attach /path/to/file.py

# 恢复上次会话
zcode --continue

# 最大轮次限制
zcode --prompt "复杂任务" --max-turns 10

# 导出 JSON
zcode --prompt "生成 JSON" --json
```

## 方式三：飞书

ZCode 目前不提供飞书（Lark）机器人集成。如需飞书交互，需要自行开发中间层：

1. 使用飞书开放平台 API 创建机器人
2. 机器人接收消息后调用 `zcode --prompt`
3. 将 zcode 响应返回飞书

这属于未来扩展方向，不在当前项目范围内。
