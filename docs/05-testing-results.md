# 测试结果

## 端到端测试

运行脚本：`scripts/test-zcode.sh`

### 测试结果（2026-08-15）

```
=== ZCode 端到端测试 ===
时间: Sun Aug 16 12:12:45 AM CST 2026

Test 1: 基本连通性 (Say hello)... PASS (response: Hello! 👋)
Test 2: 数学推理 (2+2)... PASS
Test 3: 文件创建... PASS
Test 4: 文件读取... PASS
Test 5: 代码生成... PASS
Test 6: JSON 结构化输出... PASS
Test 7: Token 使用统计... PASS (in:19773 out:2)
Test 8: 上下文窗口... PASS (context window: 200000)

=== 测试结果 ===
通过: 8
失败: 0
总计: 8
✓ 所有测试通过
```

### 测试详情

| # | 测试 | 说明 | 结果 |
|---|------|------|------|
| 1 | 基本连通性 | 发送简单 prompt 验证 API 可达 | ✅ PASS |
| 2 | 数学推理 | 2+2 简单运算 | ✅ PASS |
| 3 | 文件创建 | 让 zcode 在 /tmp 中创建文件 | ✅ PASS |
| 4 | 文件读取 | 让 zcode 读取刚创建的文件 | ✅ PASS |
| 5 | 代码生成 | 生成一段 Python 代码 | ✅ PASS |
| 6 | JSON 输出 | 要求结构化 JSON 响应 | ✅ PASS |
| 7 | Token 统计 | 验证 JSON 中的 usage 字段 | ✅ PASS |
| 8 | 上下文窗口 | 验证 projection.contextWindow | ✅ PASS (200K) |

### 运行测试

```bash
cd /home/opc2_uname/cc_ps/cd_repair_zcode
bash scripts/test-zcode.sh
```

## WebUI 测试

### 服务器启动测试

```
$ curl -s http://127.0.0.1:3002/api/status | python3 -m json.tool
{
    "zcodeVersion": "zcode-app-cli 3.7.7-13",
    "nodeVersion": "v24.15.0",
    "workspacesRoot": "/home/opc2_uname/cc_ps",
    "timestamp": "2026-08-15T16:08:36.146Z"
}

$ curl -s http://127.0.0.1:3002/api/workspaces | python3 -m json.tool
{
    "workspaces": ["/home/opc2_uname/cc_ps/NVForge", ...16个项目目录...],
    "root": "/home/opc2_uname/cc_ps"
}
```

### WebSocket 测试

```
发送: {"type":"prompt","prompt":"Reply with exactly: WebSocket test OK","mode":"yolo"}
接收:
  type: stream
  type: result
  response: WebSocket test OK
  usage: {"inputTokens":9882,"outputTokens":4,"totalTokens":9886}
```

### 前端验证

- ✅ 前端 HTML 加载正常
- ✅ WebSocket 连接建立
- ✅ Prompt 发送和响应接收
- ✅ 工作目录列表显示
- ✅ Token 统计显示
- ✅ 权限模式切换

## cc4101 验证

### 非流式请求

```bash
$ curl -s http://127.0.0.1:4101/v1/messages \
  -H "x-api-key: cc4101-token" \
  -d '{"model":"cc-glm5-2","max_tokens":100,"messages":[{"role":"user","content":"Say OK"}]}'
# 返回: {"content":[{"text":"OK",...}],...}
```

### 流式请求

```bash
$ curl -s http://127.0.0.1:4101/v1/messages \
  -H "x-api-key: cc4101-token" \
  -d '{"model":"cc-glm5-2","max_tokens":100,"stream":true,"messages":[...]}'
# 返回 SSE 流
```
