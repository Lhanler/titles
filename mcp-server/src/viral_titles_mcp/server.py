"""
server.py - MCP Server 主体
============================

暴露 5 个确定性查询 tool,不调 LLM。

Tool 列表:
- get_formulas(theme?: 'classic'|'modern'|'all')
- get_platform_cheatsheet(platform: str)
- sample_corpus(platform?: str, count?: int, days?: int)
- get_current_trends()
- get_corpus_stats()
"""

# QClaw/Hermes 兼容:让 pywintypes 可被 mcp 找到
import os as _os
import sys as _sys
if _os.name == "nt":
    _WIN32_ROOT = r"C:\Program Files\QClaw\v0.2.34.621\resources\hermes\libs\win32"
    _WIN32_LIB = _WIN32_ROOT + r"\lib"
    for _p in [_WIN32_ROOT, _WIN32_LIB]:
        if _os.path.isdir(_p) and _p not in _sys.path:
            _sys.path.insert(0, _p)

import asyncio
import json
from typing import Any

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent

from .data import (
    load_formulas,
    load_platform_cheatsheet,
    sample_corpus,
    get_current_trends as load_trends,
    get_corpus_stats as load_stats,
)

server = Server("viral-titles")


@server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="get_formulas",
            description=(
                "获取 16 式爆款标题公式套路库。"
                "包含 8 经典式(数字列表、悬念提问、对比反差、权威背书、福利引导、痛点共鸣、故事钩子、揭秘揭秘)"
                "+ 8 当代式(自我代入式、一句话造句反转、年龄性别反转、AI 互动焦虑、名词当形容词、空格切割、官方 label、权威身份前缀)。"
                "返回 markdown 文本,可作为 prompt 的核心素材。"
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "category": {
                        "type": "string",
                        "enum": ["classic", "modern", "all"],
                        "description": "classic=8 经典式, modern=8 当代式, all=全部(默认)",
                        "default": "all",
                    }
                },
                "required": [],
            },
        ),
        Tool(
            name="get_platform_cheatsheet",
            description=(
                "获取平台差异化速查表。"
                "返回指定平台的字数限制、红线/禁区、钩子偏好、典型句式。"
                "支持平台:公众号 / 抖音 / 小红书 / 头条 / 知乎 / B站 / 通用。"
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "platform": {
                        "type": "string",
                        "enum": ["公众号", "抖音", "小红书", "头条", "知乎", "B站", "通用"],
                        "description": "目标平台",
                    }
                },
                "required": ["platform"],
            },
        ),
        Tool(
            name="sample_corpus",
            description=(
                "从真实标题语料库(JSONL)中抽样 few-shot 样本。"
                "支持按平台过滤 + 时间窗口过滤。"
                "返回 JSON,每条样本含 title / platform / heat_or_view / fetched_at。"
                "这是最关键的差异化素材 —— 让 LLM 学'真实在跑的爆款长啥样'。"
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "platform": {
                        "type": "string",
                        "description": "平台筛选(可选,如 '抖音';省略=全部平台)",
                    },
                    "count": {
                        "type": "integer",
                        "description": "抽样数量,默认 10,范围 1-50",
                        "minimum": 1,
                        "maximum": 50,
                        "default": 10,
                    },
                    "days": {
                        "type": "integer",
                        "description": "最近 N 天的数据,默认 30",
                        "minimum": 1,
                        "maximum": 365,
                        "default": 30,
                    },
                },
                "required": [],
            },
        ),
        Tool(
            name="get_current_trends",
            description=(
                "获取当前跨平台同热事件(用于借势标题)。"
                "返回 markdown,列出近期的同热话题 + 各类平台的切入角度建议。"
            ),
            inputSchema={
                "type": "object",
                "properties": {},
                "required": [],
            },
        ),
        Tool(
            name="get_corpus_stats",
            description=(
                "获取语料库统计信息。"
                "返回 JSON:总数、按平台分布、最近日期、最新条目。"
                "用于诊断语料库状态、决定 few-shot 是否可用。"
            ),
            inputSchema={
                "type": "object",
                "properties": {},
                "required": [],
            },
        ),
    ]


@server.call_tool()
async def call_tool(name: str, arguments: dict[str, Any]) -> list[TextContent]:
    try:
        if name == "get_formulas":
            category = arguments.get("category", "all")
            result = load_formulas(category)
        elif name == "get_platform_cheatsheet":
            platform = arguments.get("platform", "通用")
            result = load_platform_cheatsheet(platform)
        elif name == "sample_corpus":
            platform = arguments.get("platform")
            count = arguments.get("count", 10)
            days = arguments.get("days", 30)
            result = sample_corpus(platform=platform, count=count, days=days)
        elif name == "get_current_trends":
            result = load_trends()
        elif name == "get_corpus_stats":
            result = load_stats()
        else:
            result = json.dumps({"error": f"Unknown tool: {name}"}, ensure_ascii=False)

        return [TextContent(type="text", text=result)]
    except Exception as e:
        return [TextContent(
            type="text",
            text=json.dumps({"error": str(e), "tool": name, "arguments": arguments}, ensure_ascii=False, indent=2)
        )]


async def main_async():
    """Run MCP server in stdio mode"""
    async with stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            server.create_initialization_options(),
        )


def main():
    """Entry point for `python -m viral_titles_mcp` and `viral-titles-mcp` script"""
    asyncio.run(main_async())


if __name__ == "__main__":
    main()