#!/usr/bin/env node
/**
 * ZCode WebUI — 轻量级 Web 界面
 *
 * 功能:
 * - 浏览器中发送 prompt 给 zcode
 * - 显示流式/非流式响应
 * - 显示 token 使用统计
 * - 支持工作目录选择
 *
 * 架构: Express + WebSocket → zcode --prompt (headless)
 *
 * 用法: node webui.js [--port 3002] [--host 0.0.0.0]
 */

const express = require('express');
const { WebSocketServer } = require('ws');
const { spawn, execSync } = require('child_process');
const path = require('path');
const fs = require('fs');
const http = require('http');

const args = process.argv.slice(2);
let port = 3002;
let host = '0.0.0.0';
let workspacesRoot = process.env.WORKSPACES_ROOT || process.env.HOME + '/cc_ps';

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--port' && args[i+1]) port = parseInt(args[i+1]);
  if (args[i] === '--host' && args[i+1]) host = args[i+1];
}

const app = express();
const server = http.createServer(app);
const wss = new WebSocketServer({ server, path: '/ws' });

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// 获取 zcode 版本
let zcodeVersion = 'unknown';
try {
  zcodeVersion = execSync('zcode --version 2>&1', { encoding: 'utf-8' }).split('\n')[0];
} catch(e) {}

// API: 获取状态
app.get('/api/status', (req, res) => {
  res.json({
    zcodeVersion,
    nodeVersion: process.version,
    workspacesRoot,
    timestamp: new Date().toISOString(),
  });
});

// API: 获取工作目录列表
app.get('/api/workspaces', (req, res) => {
  try {
    const dirs = fs.readdirSync(workspacesRoot, { withFileTypes: true })
      .filter(d => d.isDirectory() && !d.name.startsWith('.'))
      .map(d => path.join(workspacesRoot, d.name));
    res.json({ workspaces: dirs, root: workspacesRoot });
  } catch(e) {
    res.status(500).json({ error: e.message });
  }
});

// WebSocket: 处理 prompt 请求
wss.on('connection', (ws) => {
  console.log(`[${new Date().toISOString()}] WebSocket connected`);

  ws.on('message', async (data) => {
    let msg;
    try {
      msg = JSON.parse(data.toString());
    } catch(e) {
      ws.send(JSON.stringify({ type: 'error', error: 'Invalid JSON' }));
      return;
    }

    if (msg.type === 'prompt') {
      const { prompt, cwd, mode } = msg;
      const args = ['--prompt', prompt, '--mode', mode || 'yolo', '--json'];
      if (cwd) args.push('--cwd', cwd);

      console.log(`[${new Date().toISOString()}] Prompt: "${prompt.substring(0, 80)}..." cwd=${cwd || 'default'}`);

      try {
        const child = spawn('zcode', args, {
          stdio: ['pipe', 'pipe', 'pipe'],
          env: { ...process.env },
        });

        let stdout = '';
        let stderr = '';

        child.stdout.on('data', (chunk) => {
          stdout += chunk.toString();
          ws.send(JSON.stringify({ type: 'stream', data: chunk.toString() }));
        });

        child.stderr.on('data', (chunk) => {
          stderr += chunk.toString();
          ws.send(JSON.stringify({ type: 'stderr', data: chunk.toString() }));
        });

        child.on('close', (code) => {
          try {
            const result = JSON.parse(stdout);
            ws.send(JSON.stringify({ type: 'result', data: result, exitCode: code }));
          } catch(e) {
            ws.send(JSON.stringify({
              type: 'result',
              data: { response: stdout, error: 'Non-JSON output' },
              exitCode: code,
              stderr
            }));
          }
        });

        child.on('error', (err) => {
          ws.send(JSON.stringify({ type: 'error', error: err.message }));
        });

      } catch(e) {
        ws.send(JSON.stringify({ type: 'error', error: e.message }));
      }
    }
  });

  ws.on('close', () => {
    console.log(`[${new Date().toISOString()}] WebSocket disconnected`);
  });
});

server.listen(port, host, () => {
  console.log(`ZCode WebUI running at http://${host}:${port}`);
  console.log(`ZCode version: ${zcodeVersion}`);
  console.log(`Workspaces root: ${workspacesRoot}`);
});
