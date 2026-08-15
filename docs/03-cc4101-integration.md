# cc4101 集成指南

## 概述

cc4101 是本地 Docker 容器 (`cc-infra-cc4101`)，作为 Anthropic Messages API 代理运行在端口 4101。它将 Anthropic 格式的请求路由到 GLM-5.2 模型。

## 架构

```
ZCode CLI  →  cc4101 (127.0.0.1:4101)  →  GLM-5.2
                 Anthropic Messages API        (glm5_2_nv primary)
                 /v1/messages                  (glm5_2_ms fallback)
                 /v1/models
```

## API 端点

| 端点 | 方法 | 说明 |
|------|------|------|
| `/v1/messages` | POST | Anthropic Messages API（支持流式和非流式） |
| `/v1/models` | GET | 模型列表 |

## 认证

- Header: `x-api-key: cc4101-token`
- 也支持 `Authorization: Bearer cc4101-token`

## 验证 cc4101 运行

```bash
# 检查容器状态
docker ps | grep cc4101

# 测试非流式
curl -s http://127.0.0.1:4101/v1/messages \
  -H "x-api-key: cc4101-token" \
  -H "Content-Type: application/json" \
  -d '{"model":"cc-glm5-2","max_tokens":100,"messages":[{"role":"user","content":"Say OK"}]}'

# 测试流式
curl -s http://127.0.0.1:4101/v1/messages \
  -H "x-api-key: cc4101-token" \
  -H "Content-Type: application/json" \
  -d '{"model":"cc-glm5-2","max_tokens":100,"stream":true,"messages":[{"role":"user","content":"Say OK"}]}'
```

## 模型路由

cc4101 内部配置了模型路由：
- 主模型: `glm5_2_nv`
- 备用模型: `glm5_2_ms`

当主模型不可用时自动切换到备用模型。

## ZCode 集成

在 `~/.zcode/cli/config.json` 中配置：

```json
{
  "provider": {
    "zai": {
      "kind": "anthropic",
      "options": {
        "baseURL": "http://127.0.0.1:4101",
        "apiKey": "cc4101-token"
      },
      "headers": {
        "x-api-key": "cc4101-token"
      }
    }
  },
  "model": {
    "main": "zai/cc-glm5-2",
    "lite": "zai/cc-glm5-2"
  }
}
```

## 故障排除

### 连接被拒绝
```bash
# 检查容器是否运行
docker ps | grep cc4101
# 如未运行，检查 cc-infra 配置
```

### Unauthorized 错误
- 确认 `x-api-key` 标头设置为 `cc4101-token`
- 确认 provider key 为 `zai`（不是其他名称）

### 模型未找到
- 确认 model ID 为 `cc-glm5-2`
- 在 config.json 中 `model.main` 格式为 `zai/cc-glm5-2`
