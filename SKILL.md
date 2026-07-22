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

用 `read_file` 工具读 `data/title-corpus.jsonl`。

**这是关键差异化**:JSONL 里每行是一条真实标题(平台、热度、时间)。从同平台最近条目随机抽 5-10 条作为 few-shot,让 LLM 学"真实在跑的爆款长啥样"。

格式样例:
```json
{"title": "30 岁从大厂裸辞,我后悔了吗", "platform": "抖音", "heat_or_view": 1234567, "fetched_at": "2026-07-21T09:00:00"}
```

(可选)再读 `data/title-trends-rolling.md` 拿到当前跨平台同热事件(借势用)。

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
- 尽可能读 `data/title-corpus.jsonl` 抽 few-shot —— 真实语料胜过任何 prompt
- prompt 末尾明确"只输出 JSON" —— 避免 LLM 加多余解释

### 失败回退
- 如果 `data/title-corpus.jsonl` 不存在或为空,跳过 few-shot
- 如果用户没指定平台,默认"通用"
- 如果 LLM 输出不是 JSON,提示它重输出 JSON 格式

## 怎么更新数据

**手动**:
```bash
cd ~/.qclaw/skills/viral-titles
git pull origin main
```

**一键脚本**(自动找常见安装目录):
```bash
bash update-viral-titles.sh        # Linux/macOS/Git Bash
update-viral-titles.bat            # Windows
```

**每周自动**(可选):用 crontab(Windows 任务计划程序)设一行,周一 09:00 自动 `git pull`:
```bash
0 9 * * 1 cd ~/.qclaw/skills/viral-titles && git pull origin main
```

---

## 仓库结构

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
│   ├── title-corpus.jsonl      # 真实爆款标题(同平台最近 few-shot 用)
│   ├── title-trends-rolling.md # 跨平台同热事件(借势用)
│   └── _version                # 当前 commit SHA
└── references/                 # 深度文档
    ├── formulas.md             # 16 式爆款公式
    └── platform-cheatsheet.md  # 平台字数/红线/钩子速查
```

## 数据说明

- `data/title-corpus.jsonl`:作者持续从微博/知乎/抖音/头条/B站/公众号/小红书等平台抓取的当日爆款标题
- `data/title-trends-rolling.md`:跨平台同热事件周报(借势用)
- 更新频率:**每周一次**(作者周一 09:00 采集 → 21:00 提炼 → 23:00 推送)

**用户的你不需要关心数据采集**,只需要 `git pull` 拉新数据。