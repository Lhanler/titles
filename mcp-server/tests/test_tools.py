"""
tests/test_tools.py - 基础测试(不依赖 MCP client)
直接调用 data 层函数,验证返回正确。
"""

import json
import sys
from pathlib import Path

# 让 import 找得到
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "src"))

from viral_titles_mcp.data import (
    load_formulas,
    load_platform_cheatsheet,
    sample_corpus,
    get_current_trends,
    get_corpus_stats,
)


def test_get_formulas():
    print("\n=== test get_formulas ===")
    for cat in ["all", "classic", "modern"]:
        result = load_formulas(cat)
        assert isinstance(result, str), f"Expected str, got {type(result)}"
        assert len(result) > 100, f"Result too short ({len(result)} chars) for category={cat}"
        print(f"  ✓ get_formulas(category='{cat}'): {len(result)} chars")


def test_get_platform_cheatsheet():
    print("\n=== test get_platform_cheatsheet ===")
    for plat in ["公众号", "抖音", "小红书", "知乎", "通用"]:
        result = load_platform_cheatsheet(plat)
        assert isinstance(result, str), f"Expected str, got {type(result)}"
        print(f"  ✓ get_platform_cheatsheet(platform='{plat}'): {len(result)} chars")


def test_sample_corpus():
    print("\n=== test sample_corpus ===")
    # 全部平台
    r = sample_corpus(platform=None, count=5, days=365)
    parsed = json.loads(r)
    assert "sample" in parsed
    assert "stats" in parsed or "returned" in parsed
    print(f"  ✓ sample_corpus(): {parsed.get('returned', 0)} 条样本")

    # 按平台
    r = sample_corpus(platform="抖音", count=3, days=30)
    parsed = json.loads(r)
    print(f"  ✓ sample_corpus(platform='抖音'): {parsed.get('returned', 0)} 条样本")


def test_get_corpus_stats():
    print("\n=== test get_corpus_stats ===")
    r = get_corpus_stats()
    parsed = json.loads(r)
    assert "total" in parsed
    assert "by_platform" in parsed
    print(f"  ✓ total={parsed['total']}, platforms={list(parsed['by_platform'].keys())}")


def test_get_current_trends():
    print("\n=== test get_current_trends ===")
    r = get_current_trends()
    assert isinstance(r, str)
    print(f"  ✓ {len(r)} chars")


if __name__ == "__main__":
    print("Running viral-titles-mcp data layer tests...")
    test_get_formulas()
    test_get_platform_cheatsheet()
    test_sample_corpus()
    test_get_corpus_stats()
    test_get_current_trends()
    print("\n✅ All tests passed!")