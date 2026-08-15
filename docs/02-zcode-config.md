# ZCode 配置指南

## 配置文件位置

```
~/.zcode/cli/config.json
```

文件权限：`600`（仅用户可读写）

## 配置模板

模板文件位于：`config/zcode-config.example.json`

## 关键配置项

### Provider 配置

ZCode 支持三种 provider kind：
- `anthropic` — Anthropic Messages API 兼容
- `openai-compatible` — OpenAI 兼容 API
- `openai` — OpenAI 原生 API

本项目使用 `anthropic` kind，将 cc4101 作为自定义 provider：

```json
{
  "provider": {
    "zai": {
      "kind": "anthropic",
      "name": "Z.AI Coding Plan",
      "options": {
        "apiKeyRequired": true,
        "baseURL": "http://127.0.0.1:4101",
        "apiKey": "cc4101-token"
      },
      "headers": {
        "x-api-key": "cc4101-token"
      },
      "models": {
        "cc-glm5-2": {
          "name": "GLM-5.2 (cc4101 local)"
        }
      }
    }
  }
}
```

### 重要约束

1. **Provider key 必须是 `zai` 或 `bigmodel`**：这是上游登录门控的要求。即使使用自定义 baseURL，provider key 仍需用这两个名称之一。

2. **apiKey 必须行内传入**：`options.apiKey` 字段和 `headers.x-api-key` 都需要设置。

3. **model.main 和 model.lite 格式**：必须是 `<provider-key>/<model-id>`，即 `zai/cc-glm5-2`。

### 权限模式

| 模式 | 说明 |
|------|------|
| `yolo` | 全自动，无需确认 |
| `build` | 文件操作需确认（默认） |
| `edit` | 只读+编辑 |
| `plan` | 只规划，不执行 |

### 网络超时

```json
{
  "network": {
    "timeout": 180000
  }
}
```

默认 180 秒（3分钟），适用于长时间推理请求。

## 配置验证

```bash
# 测试基本连通性
zcode --prompt "Say hello" --mode yolo --json

# 如果配置正确，会返回 JSON 格式的响应
```
