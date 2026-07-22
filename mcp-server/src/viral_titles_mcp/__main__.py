"""
__main__.py - 命令行入口
=========================

让 `python -m viral_titles_mcp` 和 `viral-titles-mcp` 都能启动 MCP server。

兼容层:在 QClaw/Hermes Python 环境下,pywintypes 在 libs/win32/lib/(不在 sys.path),
需要主动注入才能让 mcp/os/win32/utilities.py 正常 import。
"""

import sys
import os

# QClaw/Hermes 兼容:让 pywintypes / win32api 可被 mcp 找到
_WIN32_ROOT = r"C:\Program Files\QClaw\v0.2.34.621\resources\hermes\libs\win32"
_WIN32_LIB = _WIN32_ROOT + r"\lib"
if os.name == "nt":
    for _p in [_WIN32_ROOT, _WIN32_LIB]:
        if os.path.isdir(_p) and _p not in sys.path:
            sys.path.insert(0, _p)

from .server import main

if __name__ == "__main__":
    main()