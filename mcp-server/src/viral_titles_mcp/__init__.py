"""
viral-titles-mcp
=================

MCP server exposing viral-title-generator skill data.

Exposes deterministic query tools:
- get_formulas         - 16 式爆款公式套路库
- get_platform_cheatsheet - 平台差异化速查
- sample_corpus        - 真实标题语料抽样(few-shot)
- get_current_trends   - 当前跨平台同热事件
- get_corpus_stats     - 语料库统计

**No LLM calls in this server.** The calling agent uses its own LLM
to combine these materials into actual titles.

Usage with Claude Desktop / Cursor / any MCP client:
    Add to MCP config:
    {
      "mcpServers": {
        "viral-titles": {
          "command": "python",
          "args": ["-m", "viral_titles_mcp"]
        }
      }
    }
"""

__version__ = "0.1.0"