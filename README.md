# viral-titles — 爆款标题生成器

> 紧跟现代风格的爆款标题生成 skill,适用于公众号、小红书、抖音、新闻类文章。

## 🎯 这是什么

一个 OpenClaw skill,提供:
- **16 式爆款套路库**(反常识、悬念、数字、对比、情感等)
- **平台速查**(公众号 / 小红书 / 抖音 / 新闻)
- **249 条真实爆款语料**(`data/title-corpus.jsonl`)
- **趋势洞察**(`data/title-trends-rolling.md`)
- **可选 MCP server 形态**(装 `mcp-server/`)

## 🚀 怎么用

### OpenClaw Agent(零依赖,推荐)

把本仓库根目录加到 OpenClaw skill 加载根(`/new` 时自动发现):

```bash
# 1. 克隆到任意位置
git clone https://github.com/Lhanler/titles.git ~/titles

# 2. 复制到 OpenClaw 加载根(任选一个,看你的 OpenClaw 配置)
cp -r ~/titles/* ~/.qclaw/skills/viral-titles/
```

或直接用整个仓库作为 skill 目录(把 `~/titles` 软链到 `~/.qclaw/skills/viral-titles`)。

### Claude Desktop / Cursor(MCP server)

```bash
# 1. 克隆
git clone https://github.com/Lhanler/titles.git ~/titles

# 2. 装 MCP server
cd ~/titles/mcp-server
pip install -e .  # 或 install.bat(Windows)

# 3. 配 MCP client
# 配置示例见 mcp-server/mcp_config_examples/
```

### 直接读文件(任何 LLM)

Agent 只需要:
1. 读 `skill.md` 拿到工作流
2. 读 `data/formulas.md` 拿 16 式套路
3. 读 `data/platform-cheatsheet.md` 拿平台速查
4. 抽 `data/title-corpus.jsonl` 几条做 few-shot
5. 用自己的 LLM 生成标题

## 🎬 触发词

- 起标题
- 写标题
- 爆款标题
- viral title
- 标题生成

## 📂 仓库结构

```
titles/
├── skill.md                   # 主入口(OpenClaw 格式)
├── README.md                  # 项目说明
├── LICENSE
├── data/                      # 数据
│   ├── title-corpus.jsonl     # 真实爆款语料
│   ├── title-trends-rolling.md # 趋势洞察
│   ├── formulas.md            # 16 式套路库
│   └── platform-cheatsheet.md # 平台速查
├── references/                # 深度文档
│   ├── formulas.md
│   └── platform-cheatsheet.md
└── mcp-server/                # MCP server 形态(可选)
    ├── pyproject.toml
    ├── install.bat / .ps1
    ├── start-mcp.bat / .ps1
    ├── src/viral_titles_mcp/
    ├── data/
    ├── mcp_config_examples/
    └── tests/
```

## 🤝 关联仓库

- **[axkit](https://github.com/Lhanler/axkit)**:中央 skills 仓库,装多个 skill 用
- **[titles](https://github.com/Lhanler/titles)**(本仓库):本 skill 的单仓版本,直接装

## 📄 License

MIT
