# viral-titles — 爆款标题生成器

> 紧跟现代风格的爆款标题生成 skill,适用于公众号、小红书、抖音、新闻类文章。

## 🎯 这是什么

一个 OpenClaw skill,提供:
- **16 式爆款套路库**(反常识、悬念、数字、对比、情感等)
- **平台速查**(公众号 / 小红书 / 抖音 / 新闻)
- **真实爆款标题持续更新**(`data/title-corpus.jsonl`)
- **趋势洞察**(`data/title-trends-rolling.md`)

## 🚀 怎么用

### OpenClaw Agent(零依赖,推荐)

把本仓库**完整 git clone** 到 OpenClaw skill 加载根(`/new` 时自动发现)。

> 关键:不要下载 zip 后复制文件,否则后续无法 `git pull` 自动更新数据。

```bash
# 直接克隆到 skill 目录(推荐)
git clone https://github.com/Lhanler/titles.git ~/.qclaw/skills/viral-titles
```

Windows:

```bat
git clone https://github.com/Lhanler/titles.git %USERPROFILE%\.qclaw\skills\viral-titles
```

也可用一键安装脚本:

```bash
# Linux/macOS/Git Bash
curl -O https://raw.githubusercontent.com/Lhanler/titles/main/install-viral-titles.sh
bash install-viral-titles.sh

# Windows
curl -O https://raw.githubusercontent.com/Lhanler/titles/main/install-viral-titles.bat
install-viral-titles.bat
```

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
1. 读 `SKILL.md` 拿到工作流
2. 读 `references/formulas.md` 拿 16 式套路
3. 读 `references/platform-cheatsheet.md` 拿平台速查
4. 抽 `data/title-corpus.jsonl` 几条做 few-shot
5. 用自己的 LLM 生成标题

## 🎬 触发词

- 起标题
- 写标题
- 爆款标题
- viral title
- 标题生成

## 🔄 已安装用户怎么更新数据

### 方式 1:手动更新(最简单)

```bash
cd ~/.qclaw/skills/viral-titles
git pull origin main
```

Windows:

```bat
cd /d %USERPROFILE%\.qclaw\skills\viral-titles
git pull origin main
```

### 方式 2:一键更新脚本

仓库根有 `update-viral-titles.sh` / `update-viral-titles.bat`,会自动查找常见安装目录并执行 `git pull origin main`。

```bash
bash update-viral-titles.sh
```

```bat
update-viral-titles.bat
```

如果脚本不在本地,直接 curl:

```bash
curl -O https://raw.githubusercontent.com/Lhanler/titles/main/update-viral-titles.sh
bash update-viral-titles.sh
```

### 方式 3:定时自动更新

**Linux/macOS** —— 配 crontab:

```bash
0 10,22 * * * cd ~/.qclaw/skills/viral-titles && git pull origin main >/tmp/viral-titles-update.log 2>&1
```

**Windows** —— 任务计划程序:
- 触发器:每天 10:30 / 22:30
- 操作:启动程序 `%USERPROFILE%\.qclaw\skills\viral-titles\update-viral-titles.bat`

### 方式 4:Skill 加载时自动检查

`SKILL.md` 末尾的"自动版本检查"章节会让 LLM 在每次加载 skill 时:
1. 读 `data/_version`(本地 commit SHA)
2. 调 `https://api.github.com/repos/Lhanler/titles/commits/main` 拿最新 SHA
3. 不同 → 友好提示用户"有更新,推荐跑 update-viral-titles.sh"

## 📂 仓库结构

```
titles/
├── SKILL.md                   # 主入口(OpenClaw 格式,大写)
├── README.md                  # 项目说明
├── LICENSE                    # MIT
├── install-viral-titles.sh    # 一键安装(完整 git clone)
├── install-viral-titles.bat   # Windows 一键安装
├── update-viral-titles.sh     # 一键更新(git pull)
├── update-viral-titles.bat    # Windows 一键更新
├── data/                      # 数据
│   ├── title-corpus.jsonl     # 真实爆款语料(520+ 条)
│   ├── title-trends-rolling.md # 趋势洞察
│   ├── _version               # 当前 commit SHA(版本检测用)
│   ├── formulas.md            # 16 式套路库
│   └── platform-cheatsheet.md # 平台速查
├── references/                # 深度文档
│   ├── formulas.md
│   └── platform-cheatsheet.md
│   └── daily/                 # 每日 cron 报告归档
└── mcp-server/                # MCP server 形态(可选)
    ├── pyproject.toml
    ├── install.bat / .ps1
    ├── start-mcp.bat / .ps1
    ├── src/viral_titles_mcp/
    ├── data/
    ├── mcp_config_examples/
    └── tests/
```

## 📄 License

MIT