"""
data.py - 数据访问层
====================

为 MCP server 提供确定性的素材查询函数。所有函数都是纯查询,无 LLM 调用。

数据源:
- 内置 data/ 目录(formulas.md / platform-cheatsheet.md / title-corpus.jsonl)
- 可被环境变量 VIRAL_TITLES_DATA_DIR 覆盖(指向 ~/.hermes/data/ 等)
"""

import json
import os
import random
import re
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict, Optional

# 数据目录:内置或环境变量覆盖
_DEFAULT_DATA_DIR = Path(__file__).resolve().parent.parent.parent / "data"
_DATA_DIR = Path(os.environ.get("VIRAL_TITLES_DATA_DIR", _DEFAULT_DATA_DIR))


def _read_text(filename: str) -> str:
    path = _DATA_DIR / filename
    if path.exists():
        return path.read_text(encoding="utf-8")
    return f"(数据文件不存在: {filename})"


def _read_jsonl(filename: str) -> List[Dict]:
    """读取 JSONL 文件,返回行列表"""
    path = _DATA_DIR / filename
    if not path.exists():
        return []
    rows = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                rows.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    return rows


# ============================================================
# Tool 1: get_formulas
# ============================================================
def load_formulas(category: str = "all") -> str:
    """
    获取爆款标题公式套路库。

    Args:
        category: 'classic' = 8 经典式 | 'modern' = 8 当代式 | 'all' = 全部

    Returns:
        markdown 文本
    """
    content = _read_text("formulas.md")
    if category == "all":
        return content

    # 按章节切分(假设 markdown 中有 ## 章节标记)
    # 取到匹配的章节 + 后续内容直到下一个 ## 章节
    sections = re.split(r"^## ", content, flags=re.MULTILINE)
    headers = re.findall(r"^## (.+)$", content, re.MULTILINE)

    keyword_map = {
        "classic": ["经典", "基础", "传统", "8 式"],
        "modern": ["当代", "现代", "新", "趋势"],
    }
    keywords = keyword_map.get(category, [])

    matched = []
    for header, section in zip(headers, sections[1:]):
        if any(kw in header for kw in keywords):
            matched.append(f"## {header}\n{section}")

    if not matched:
        # fallback:返回全部
        return content

    preamble = sections[0]  # 文件开头(在第一个 ## 之前)
    return preamble + "\n\n" + "\n\n".join(matched)


# ============================================================
# Tool 2: get_platform_cheatsheet
# ============================================================
def load_platform_cheatsheet(platform: str) -> str:
    """
    获取平台差异化速查。

    Args:
        platform: '公众号' | '抖音' | '小红书' | '头条' | '知乎' | 'B站' | '通用'

    Returns:
        markdown 文本(对应平台章节)
    """
    content = _read_text("platform-cheatsheet.md")

    if platform in ["通用", "全部", "all"]:
        return content

    # 找对应平台的章节
    pattern = rf"^## .*{re.escape(platform)}.*?\n(.*?)(?=^## |\Z)"
    m = re.search(pattern, content, re.MULTILINE | re.DOTALL)
    if m:
        return f"# {platform} 平台速查\n\n{m.group(1).strip()}"

    # fallback:返回全文
    return content


# ============================================================
# Tool 3: sample_corpus
# ============================================================
def sample_corpus(
    platform: Optional[str] = None,
    count: int = 10,
    days: int = 30,
    seed: Optional[int] = None,
) -> str:
    """
    从真实标题语料库抽样 few-shot 样本。

    Args:
        platform: 平台筛选(可选,如 '抖音';None=全部平台)
        count: 抽样数量(默认 10)
        days: 最近 N 天的数据(默认 30)
        seed: 随机种子(可选,固定可重现)

    Returns:
        JSON 字符串,包含抽样结果
    """
    rows = _read_jsonl("title-corpus.jsonl")
    if not rows:
        return json.dumps({
            "warning": "title-corpus.jsonl 不存在或为空",
            "sample": [],
            "stats": {"total": 0, "filtered": 0, "returned": 0},
        }, ensure_ascii=False, indent=2)

    # 按时间过滤
    cutoff = (datetime.now() - timedelta(days=days)).isoformat()
    rows = [r for r in rows if r.get("fetched_at", "") >= cutoff]

    # 按平台过滤
    if platform and platform not in ["通用", "全部", "all"]:
        rows = [r for r in rows if r.get("platform") == platform]

    total_filtered = len(rows)

    # 抽样
    if seed is not None:
        random.seed(seed)
    if total_filtered <= count:
        sample = rows
    else:
        sample = random.sample(rows, count)

    return json.dumps({
        "platform_filter": platform or "全部",
        "days_filter": days,
        "total_in_filter": total_filtered,
        "returned": len(sample),
        "sample": [
            {
                "title": r.get("title", ""),
                "platform": r.get("platform", ""),
                "heat_or_view": r.get("heat_or_view", 0),
                "fetched_at": r.get("fetched_at", ""),
            }
            for r in sample
        ],
    }, ensure_ascii=False, indent=2)


# ============================================================
# Tool 4: get_current_trends
# ============================================================
def get_current_trends() -> str:
    """
    获取当前跨平台同热事件(用于借势)。

    Returns:
        markdown 文本
    """
    content = _read_text("title-trends-rolling.md")
    if "(数据文件不存在" in content:
        return "(趋势数据尚未累积。请先运行 daily-hot-titles cron 收集数据。)"
    return content


# ============================================================
# Tool 5: get_corpus_stats
# ============================================================
def get_corpus_stats() -> str:
    """
    获取语料库统计信息。

    Returns:
        JSON 字符串
    """
    rows = _read_jsonl("title-corpus.jsonl")
    if not rows:
        return json.dumps({"total": 0, "by_platform": {}, "warning": "语料库为空"}, ensure_ascii=False, indent=2)

    by_platform: Dict[str, int] = {}
    by_date: Dict[str, int] = {}
    for r in rows:
        p = r.get("platform", "未知")
        by_platform[p] = by_platform.get(p, 0) + 1
        date = r.get("fetched_at", "")[:10]
        if date:
            by_date[date] = by_date.get(date, 0) + 1

    # 最新条目
    latest = max(rows, key=lambda r: r.get("fetched_at", "")) if rows else None

    return json.dumps({
        "total": len(rows),
        "by_platform": dict(sorted(by_platform.items(), key=lambda x: -x[1])),
        "by_date_top10": dict(sorted(by_date.items(), key=lambda x: -x[1])[:10]),
        "latest_entry": {
            "fetched_at": latest.get("fetched_at"),
            "platform": latest.get("platform"),
            "title": latest.get("title"),
        } if latest else None,
        "data_dir": str(_DATA_DIR),
    }, ensure_ascii=False, indent=2)