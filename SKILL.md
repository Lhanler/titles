---
name: viral-titles
description: 爆款标题生成器 - 基于 16 式公式 + 真实语料 + 平台速查,生成紧跟现代风格的爆款标题(公众号/抖音/小红书/通用)。
triggers:
  - "起标题"
  - "写标题"
  - "标题生成"
  - "爆款标题"
  - "想个标题"
  - "给我几个标题"
  - "viral title"
tools:
  - read_file
mutating: false
---

# 爆款标题生成器

## 触发条件

当用户说"起标题"、"写标题"、"想个爆款标题"、"给我几个标题"时,使用本 skill。

## 输入参数

从用户消息中解析:
- **theme**(必填):选题/主题
- **platform**(默认 `通用`):`公众号` / `抖音` / `小红书` / `头条` / `知乎` / `B站` / `通用`
- **audience**(默认 `主流受众`):受众描述
- **count**(默认 `6`,范围 `1-20`):候选数量

## 工作流

### 步骤 1 · 解析用户请求

从用户消息中提取 `theme`、`platform`、`count`。如果用户没指定平台,根据语境判断:
- 提到"公众号"、"文章" → 公众号
- 提到"短视频"、"抖音"、"视频" → 抖音
- 提到"小红书"、"种草"、"攻略" → 小红书
- 其他 → 通用

### 步骤 2 · 加载套路库(必读)

用 `read_file` 工具读 `references/formulas.md`。

理解 16 式爆款公式套路(8 经典 + 8 当代):
- **8 经典**:数字列表、悬念提问、对比反差、权威背书、福利引导、痛点共鸣、故事钩子、揭秘揭秘
- **8 当代**:自我代入式、一句话造句反转、年龄性别反转、AI 互动焦虑、名词当形容词、空格切割、官方 label、权威身份前缀

### 步骤 3 · 加载平台速查(必读)

用 `read_file` 工具读 `references/platform-cheatsheet.md`。

提取对应平台的:
- **字数限制**:抖音 12-18 字、公众号 18-25 字、小红书 8-20 字
- **红线/禁区**:抖音禁"震惊"、公众号可深度、小红书禁绝对化用语
- **钩子偏好**:抖音偏数字+悬念、公众号偏情感+反差、小红书偏攻略+种草

### 步骤 4 · 加载真实语料(可选,强烈建议)

用 `read_file` 工具读 `title-corpus.jsonl`。

**这是关键差异化**:JSONL 里每行是一条真实标题(平台、热度、时间)。从同平台最近条目随机抽 5-10 条作为 few-shot,让 LLM 学"真实在跑的爆款长啥样"。

格式样例:
```json
{"title": "30 岁从大厂裸辞,我后悔了吗", "platform": "抖音", "heat_or_view": 1234567, "fetched_at": "2026-07-21T09:00:00"}
```

(可选)再读 `title-trends-rolling.md` 拿到当前跨平台同热事件(借势用)。

### 步骤 5 · 用你的 LLM 能力生成候选

基于以上素材构造 prompt,**调用你本身已有的 LLM 能力**生成 {count} 个候选标题。

prompt 模板(组装到你的消息里):

```
你是爆款标题专家。基于以下素材为这个主题生成 {count} 个候选标题。

# 主题
{theme}

# 平台
{platform}

# 受众
{audience}

# 套路库(选 3-4 个用)
[贴 references/formulas.md 的内容]

# 平台速查
[贴 references/platform-cheatsheet.md 对应章节]

# 真实语料抽样(few-shot,5-10 条)
[贴 title-corpus.jsonl 中抽的 5-10 条]

# 当前同热事件(借势用,可选)
[贴 title-trends-rolling.md 关键内容]

# 输出要求(JSON 数组)
[
  {
    "title": "...",
    "pattern": "用了哪个套路(从套路库选)",
    "hook": "情绪/利益钩子是什么",
    "platform_fit": "为什么适合此平台"
  }
]

只输出 JSON 数组,不要任何其他文字或 markdown 标记。
```

### 步骤 6 · 解析并展示

LLM 返回后,提取 JSON 数组,展示给用户。建议展示格式:

```
【候选 1】我在云南开了家咖啡馆,90 天后终于敢说真话
  → 套路:自我代入式
  → 钩子:第一人称当下时
  → 平台匹配:抖音偏好第一人称代入

【候选 2】...
```

## 输出格式

向用户返回结构化结果(优先 JSON,其次 markdown 列表):

```json
[
  {
    "title": "我在云南开了家咖啡馆,90 天后终于敢说真话",
    "pattern": "自我代入式",
    "hook": "第一人称当下时",
    "platform_fit": "抖音偏好第一人称代入和数字钩子"
  }
]
```

## 注意事项

### 关键点
- **不需要任何外部 API 调用**(不用 web_fetch 调云 LLM)
- **不需要任何本地服务**(不用 HTTP server、Python 脚本)
- **LLM 由你(Agent)本身提供**—— 你本来就在用 LLM 跑对话,这里直接复用
- **真正的"技能"= 套路库 + 平台速查 + 语料抽样 + 工作流指令**,这些是 markdown 文件,你读它们然后思考

### 质量保证
- 每次生成都要读 `references/formulas.md` —— 套路库是核心武器
- 每次都要读 `references/platform-cheatsheet.md` —— 平台差异化是硬约束
- 尽可能读 `title-corpus.jsonl` 抽 few-shot —— 真实语料胜过任何 prompt
- prompt 末尾明确"只输出 JSON" —— 避免 LLM 加多余解释

### 失败回退
- 如果 `title-corpus.jsonl` 不存在或为空,跳过 few-shot
- 如果用户没指定平台,默认"通用"
- 如果 LLM 输出不是 JSON,提示它重输出 JSON 格式

## 数据积累(可选,提升长期质量)

如果用户在你的会话里产生了"想收藏的标题",可以 append 到 `title-corpus.jsonl`:

```json
{"title": "...", "platform": "...", "heat_or_view": 0, "fetched_at": "2026-07-21T...", "source": "user-favorite"}
```

让语料库持续成长,后续生成更有依据。

## 验证

在小方里说:
> 帮我起 6 个抖音标题,主题是 30 岁从大厂裸辞去云南开咖啡馆

应触发本 skill,Agent 会:
1. 读 `references/formulas.md`
2. 读 `references/platform-cheatsheet.md`
3. 抽 `title-corpus.jsonl` 中抖音最近 5 条
4. 拼 prompt,基于自己的 LLM 生成
5. 返回 6 个候选 + 套路标注

---

## 数据源与自动同步(2026-07-22 起)

### 9 个数据源(每日 cron 自动采集)

| 平台 | 抓取方式 | 平台字段 | 典型入库/天 |
|---|---|---|---|
| 微博热搜 | weibo.com/ajax/side/hotSearch | `weibo` | 25-30 条 |
| 知乎热榜 | zhihu.com/api/v3/feed/topstory/hot-lists/total | `zhihu` | 15-20 条 |
| 抖音热门 | douyin.com/aweme/v1/web/hot/search/list/ | `douyin` | 20-25 条 |
| 头条热榜 | toutiao.com/hot-event/hot-board/ | `toutiao` | 25-30 条 |
| B 站热门 | api.bilibili.com/x/web-interface/ranking/v2 | `bilibili` | 10-15 条 |
| **微信公众号** | **搜狗微信搜索 `weixin.sogou.com/weixin?query=`** | **`wechat-mp`** | **30+ 条** |
| **小红书** | **web_search 兜底(`小红书 [关键词] 爆文`)** | **`xiaohongshu`** | **20+ 条** |
| 少数派(sspai) | sspai.com 首页 | `sspai` | 10-15 条 |
| 华尔街见闻 | wallstreetcn.com 热门 | `wallstcn` | 8-12 条 |
| 36kr | 36kr.com/hot-list/catalog | `36kr` | 10-15 条 |

**目标每日入库 ≥ 200 条**(早 cron `daily-hot-titles` 09:00 跑)。

### 平台风格差异化(关键 for 生成)

| 平台 | 字数 | emoji | 数字 | 反差 | 句式 | 钩子偏好 |
|---|---|---|---|---|---|---|
| **公众号** | 18-25 | 少 | 必有(数据) | 反差/揭秘 | 长句、信息量大 | 痛点共鸣 + 观点 + 数据 |
| **小红书** | 8-20 | **超多**(必备)| 必有 | 反差强烈 | 短句、口语化 | 攻略/种草/避坑/清单 |
| 抖音 | 12-18 | 中 | 偶有 | 悬念 | 自我代入式 | 第一人称当下时 |
| 微博 | 5-15 | 中 | 偶有 | 反转 | 短爆点 | 情绪 + 反差 |
| 头条 | 15-30 | 少 | 必有 | 客观 | 客观描述 | 数字 + 官方 label |
| 知乎 | 20-40 | 少 | 中 | 深度 | 问号结尾 | "如何看待""为什么" 框架 |

**生成标题时**,platform 字段必须精确匹配(`公众号` → `wechat-mp` 风格,`小红书` → `xiaohongshu` 风格)。

### 数据流(cron 自动化)

```
每日 09:00   cron `daily-hot-titles` 跑 → 写 ~/.hermes/data/title-corpus.jsonl
每日 21:00   cron `daily-skill-synthesis` 跑 → 写 ~/.hermes/data/title-trends-rolling.md
每日每小时    cron `titles-auto-sync`(no_agent 脚本) → 检测 + 复制 + git commit + git push
```

**watcher 脚本**:`~/.hermes/scripts/titles-auto-sync.py`:
- **触发**: cron `titles-auto-sync`(每 17 分整点跑,no_agent 模式免 LLM 调用)
- **逻辑**: 检测 `~/.hermes/data/` 是否有比 `~/Desktop/titles/data/title-corpus.jsonl` 更新的文件,有就 sync + commit + push,3 次重试
- **同步范围**:
  - `title-corpus.jsonl` / `title-trends-rolling.md` → `titles/data/`
  - `daily-*.md` → `titles/references/daily/`
- **不弹窗**: `GIT_TERMINAL_PROMPT=0` + `~/.gitconfig` `[credential "https://github.com"] helper = store` 跳过 GCM

**手动同步**(其他文件如 SKILL.md):直接 `cd ~/Desktop/titles && git add -A && git commit -m "..." && git push`

### 双周复盘(cron `weekly-title-trend-analysis`)

周日 22:00 跑,产出周报 + 趋势升级建议 → 写到 `references/weekly-trend-{date}.md`。

---

## 自动版本检查(skill 加载时 LLM 必读)

**目的**:让已安装用户的 skill 自动感知有新数据,提醒更新。

### 加载时检测流程(LLM 必执行)

**每次加载 skill 时,执行以下 3 步**:

#### 步骤 1:读本地版本

```python
local_sha = read_file("data/_version").strip().split("\n")[-1]  # 取最后一行(SHA 在末尾)
```

#### 步骤 2:查 GitHub 最新 commit

```python
import urllib.request, json
resp = urllib.request.urlopen(
    "https://api.github.com/repos/Lhanler/titles/commits/main",
    timeout=10
)
latest_sha = json.loads(resp.read())["sha"]
```

(限流 ~60 次/小时,但对个人客户端足够)

#### 步骤 3:对比 + 提示

- **`local_sha == latest_sha`** → 已是最新,无操作
- **`local_sha != latest_sha`** → 提示用户:

```
📦 检测到 viral-titles 数据有更新
   本地:    {local_sha[:7]}
   最新:    {latest_sha[:7]}

推荐运行一键更新:
   bash update-viral-titles.sh        # Linux/macOS/Git Bash
   update-viral-titles.bat           # Windows

或手动:
   cd ~/.qclaw/skills/viral-titles && git pull origin main
```

### 用户更新数据的方式(详见 README.md)

| 方式 | 适用场景 | 频次 |
|---|---|---|
| 手动 `git pull` | 临时想看新数据 | 用户主动 |
| `update-viral-titles.sh` / `.bat` 一键脚本 | 一行命令搞定 | 用户主动 |
| **crontab / Windows 任务计划** 自动跑脚本 | 自动化,**最推荐** | 每天 10:30 + 22:30 |
| **Skill 加载时 LLM 检查**(本章节) | 无操作提醒 | 每次加载 |

### 关键:安装时必须完整 git clone

> **不要** 下载 zip 后 `cp -r` —— 这会丢 git 历史,后续无法 `git pull` 更新。

正确安装:
```bash
git clone https://github.com/Lhanler/titles.git ~/.qclaw/skills/viral-titles
```

一键脚本:
```bash
curl -O https://raw.githubusercontent.com/Lhanler/titles/main/install-viral-titles.sh
bash install-viral-titles.sh
```
