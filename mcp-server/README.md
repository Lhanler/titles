# viral-titles-mcp

> MCP server exposing **viral-title-generator** skill data for any MCP-compatible client.
>
> **No LLM calls in this server.** The calling agent uses its own LLM to combine these materials into actual titles.

## What it does

Exposes **5 deterministic query tools** that return title-generation materials:

| Tool | Returns |
|---|---|
| `get_formulas` | 16 式爆款公式套路库(8 经典 + 8 当代) |
| `get_platform_cheatsheet` | 平台差异化速查(字数/红线/钩子偏好) |
| `sample_corpus` | 真实标题语料抽样(few-shot 用) |
| `get_current_trends` | 当前跨平台同热事件 |
| `get_corpus_stats` | 语料库统计(总数/平台分布/最新) |

The calling agent (Claude Desktop / Cursor / Cline / OpenClaw 小方 / etc.) receives these as text content, then uses its **own LLM** to combine them into actual viral titles.

## Install

### Windows

```cmd
REM 双击 install.bat
install.bat
```

或 PowerShell:
```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

### macOS / Linux

```bash
pip install -e .
```

## Configure your MCP client

### Claude Desktop

Edit `%APPDATA%\Claude\claude_desktop_config.json` (Windows) or `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS):

```json
{
  "mcpServers": {
    "viral-titles": {
      "command": "python",
      "args": ["-m", "viral_titles_mcp"]
    }
  }
}
```

Restart Claude Desktop. The tool `viral-titles.get_*` should appear.

### Cursor

Edit `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "viral-titles": {
      "command": "python",
      "args": ["-m", "viral_titles_mcp"]
    }
  }
}
```

### OpenClaw / QClaw 小方

把 `viral-titles-mcp/` 整个文件夹放到 OpenClaw plugin 路径,然后配置:

```json
{
  "plugins": {
    "entries": {
      "viral-titles-mcp": {
        "enabled": true,
        "command": "python",
        "args": ["-m", "viral_titles_mcp"]
      }
    }
  }
}
```

或在 OpenClaw workspace 里,加 MCP server 引用。

### Other MCP clients

Any client that supports stdio MCP works. The server speaks stdio JSON-RPC.

## Usage in your agent

Once configured, in your agent:

> "帮我起 6 个抖音标题,主题是 30 岁从大厂裸辞去云南开咖啡馆"

The agent will:
1. Call `get_formulas(category="all")` → get 16 式套路库
2. Call `get_platform_cheatsheet(platform="抖音")` → get 平台速查
3. Call `sample_corpus(platform="抖音", count=10)` → get few-shot 样本
4. Use its own LLM to combine them into 6 candidates
5. Return to you with pattern/hook/platform_fit annotations

## File structure

```
viral-titles-mcp/
├── pyproject.toml                           # 包定义(pip install -e .)
├── README.md                                # 本文档
├── install.bat / install.ps1                # 一键安装
├── start-mcp.bat / start-mcp.ps1            # 测试启动
├── data/                                    # 内置数据
│   ├── formulas.md                          # 16 式套路库
│   ├── platform-cheatsheet.md               # 平台速查
│   ├── title-corpus.jsonl                   # 真实语料(可选)
│   └── title-trends-rolling.md              # 趋势洞察(可选)
├── src/viral_titles_mcp/
│   ├── __init__.py
│   ├── __main__.py                          # python -m viral_titles_mcp
│   ├── server.py                            # MCP server 主体
│   └── data.py                              # 数据访问层
├── mcp_config_examples/
│   ├── claude_desktop_config.json
│   ├── cursor_mcp_config.json
│   └── openclaw_config.json
└── tests/
    └── test_tools.py                        # 数据层单元测试
```

## Custom data location

Default uses bundled `data/`. To use your own corpus:

```cmd
set VIRAL_TITLES_DATA_DIR=C:\path\to\your\data
python -m viral_titles_mcp
```

Expected files in that directory:
- `formulas.md`
- `platform-cheatsheet.md`
- `title-corpus.jsonl` (optional)
- `title-trends-rolling.md` (optional)

## Test

```bash
# 测试数据层(不需要 MCP client)
python tests/test_tools.py

# 测试 MCP server(发一个测试请求)
python tests/test_mcp_client.py
```

## Tool schemas

### `get_formulas(category?: 'classic' | 'modern' | 'all')`
Returns markdown string with the 16 formula patterns.

### `get_platform_cheatsheet(platform: str)`
`platform` ∈ `公众号 | 抖音 | 小红书 | 头条 | 知乎 | B站 | 通用`

### `sample_corpus(platform?: str, count?: int, days?: int)`
- `platform`: optional filter
- `count`: 1-50, default 10
- `days`: 1-365, default 30

Returns JSON with `sample` array.

### `get_current_trends()`
Returns markdown with current trending topics.

### `get_corpus_stats()`
Returns JSON with corpus statistics.

## Design philosophy

**Skill = 素材 + 指令,不是独立 LLM 服务。**

This MCP server follows that philosophy:
- ✅ Pure deterministic data queries
- ✅ No LLM calls inside
- ✅ Calling agent decides how to combine materials using its own LLM
- ✅ Stateless and side-effect-free

## License

MIT