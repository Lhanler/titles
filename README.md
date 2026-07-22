# viral-titles — 爆款标题生成器

> 紧跟现代风格的爆款标题生成 skill,适用于公众号、小红书、抖音、新闻类文章。

## 🎯 这是什么

一个 OpenClaw skill,提供:
- **16 式爆款套路库**(反常识、悬念、数字、对比、情感等)
- **平台速查**(公众号 / 小红书 / 抖音 / 新闻)
- **真实爆款标题持续更新**(`data/title-corpus.jsonl`)
- **趋势洞察**(`data/title-trends-rolling.md`)

## 🚀 怎么用

### 1. 安装

完整 git clone(非 shallow,这样后续可以 `git pull` 更新数据):

```bash
git clone https://github.com/Lhanler/titles.git ~/.qclaw/skills/viral-titles
```

Windows:

```bat
git clone https://github.com/Lhanler/titles.git %USERPROFILE%\.qclaw\skills\viral-titles
```

或用一键脚本:

```bash
# Linux/macOS/Git Bash
curl -O https://raw.githubusercontent.com/Lhanler/titles/main/install-viral-titles.sh
bash install-viral-titles.sh

# Windows
curl -O https://raw.githubusercontent.com/Lhanler/titles/main/install-viral-titles.bat
install-viral-titles.bat
```

### 2. 重启 Agent

重启 Cursor / OpenClaw / Claude Desktop,skill 自动加载。

### 3. 触发

说:"帮我起 6 个抖音标题,主题是 30 岁从大厂裸辞去云南开咖啡馆"

## 🎬 触发词

- 起标题
- 写标题
- 爆款标题
- viral title
- 标题生成

## 🔄 更新数据

### 手动(最简单)

```bash
cd ~/.qclaw/skills/viral-titles
git pull origin main
```

Windows:

```bat
cd /d %USERPROFILE%\.qclaw\skills\viral-titles
git pull origin main
```

### 一键脚本

仓库根有 `update-viral-titles.sh` / `update-viral-titles.bat`,会自动查找常见安装目录并执行 `git pull origin main`。

```bash
bash update-viral-titles.sh
```

```bat
update-viral-titles.bat
```

### 每周自动(可选)

用 crontab(Windows 任务计划程序)设一行:

```bash
# 每周一 09:00 自动拉新数据(Linux/macOS)
0 9 * * 1 cd ~/.qclaw/skills/viral-titles && git pull origin main
```

> 数据由作者每周一推送;用户不需要关心采集过程。

## 📂 仓库结构

```
titles/
├── SKILL.md                    # 主入口(Agent 加载这个)
├── README.md                   # 项目说明
├── LICENSE                     # MIT
├── install-viral-titles.sh     # 一键安装
├── install-viral-titles.bat    # Windows 一键安装
├── update-viral-titles.sh      # 一键更新
├── update-viral-titles.bat     # Windows 一键更新
├── data/                       # 数据(作者持续更新)
│   ├── title-corpus.jsonl      # 真实爆款标题持续更新
│   ├── title-trends-rolling.md # 趋势洞察
│   └── _version                # 当前 commit SHA
└── references/                 # 深度文档
    ├── formulas.md             # 16 式爆款公式
    └── platform-cheatsheet.md  # 平台字数/红线/钩子速查
```

## 📄 License

MIT
