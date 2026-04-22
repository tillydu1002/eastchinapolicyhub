# 数据源结构说明

本目录存放华东政务信息的**结构化数据**，每月一个 JSON 文件（`YYYY-MM.json`）。
脚本会读取 JSON → 渲染成 HTML 发布。**你只需要维护 JSON，不需要改 HTML**。

---

## 一、文件命名

| 文件 | 用途 |
|---|---|
| `YYYY-MM.json` | 当月数据源（如 `2026-04.json`） |
| `_schema.md` | 本说明文档 |
| `_meta.json` | 全站元数据（密码 hash、更新时间等，可选） |

---

## 二、JSON 顶层结构

```json
{
  "period": "2026-04",
  "title": "华东政务信息",
  "subtitle": "EAST CHINA · GOVERNMENT AFFAIRS BRIEFING",
  "team": "腾讯华东区域公共事务团队",
  "updated_at": "2026-04-21 18:00",
  "locked": false,
  "sections": {
    "hr": [ ... ],
    "leader": [ ... ],
    "policy": [ ... ],
    "industry": [ ... ],
    "rival": [ ... ]
  }
}
```

| 字段 | 类型 | 说明 |
|---|---|---|
| `period` | string | 期次，格式 `YYYY-MM`，决定归档 URL |
| `title` | string | 主标题，一般固定 |
| `subtitle` | string | 副标题（英文） |
| `team` | string | 出品方 |
| `updated_at` | string | 最后更新时间，格式 `YYYY-MM-DD HH:MM` |
| `locked` | boolean | 是否锁版（月末设 true，此后不再自动更新） |
| `sections` | object | 五大板块数据，键名固定：hr / leader / policy / industry / rival |

---

## 三、五大板块通用条目字段

每个板块下是**条目数组**，每个条目结构：

```json
{
  "id": "hr-001",
  "date": "2026-04-15",
  "region": "上海",
  "title": "华源任上海市副市长",
  "summary": "男，1977 年 11 月生，现任上海市人民政府副市长，分管科技创新、数字经济、产业发展等工作。",
  "sources": [
    { "label": "上海市政府", "url": "https://www.shanghai.gov.cn/..." }
  ],
  "tags": ["人事", "副市长", "科技创新"],
  "status": "published",
  "ai_draft": false,
  "reviewed_by": "你的名字",
  "reviewed_at": "2026-04-15 17:30"
}
```

### 通用字段

| 字段 | 必填 | 说明 |
|---|---|---|
| `id` | ✅ | 板块前缀+顺序号，如 `hr-001`、`policy-003`；全文件唯一 |
| `date` | ✅ | 事件日期 `YYYY-MM-DD` |
| `region` | ✅ | 地域，固定 "上海"（含徐汇区） |
| `title` | ✅ | 条目标题，遵循板块格式（见下） |
| `summary` | ✅ | 解读正文，字数要求见下 |
| `sources` | ⭕ | 信源数组，至少 1 条；对外展示为"来源 1 / 来源 2" |
| `tags` | ⭕ | 标签数组（内部检索用，不展示给外部） |
| `status` | ✅ | `draft` / `reviewed` / `published`；只有 `published` 的才会渲染到页面 |
| `ai_draft` | ✅ | true=AI 抓取生成；false=人工录入 |
| `reviewed_by` | ⭕ | 审核人；AI 草稿需人工审核后才能设 published |
| `reviewed_at` | ⭕ | 审核时间 |

---

## 四、五大板块字段规则

### 1. `hr` 人事变动

- **标题格式**：`XXX任XXX` 或 `XXX免去XXX`
- **收录门槛**：副部级及以上
- **summary 结构**：性别 + 出生年月 + 现任职务 + 此前职务（80-120字）

### 2. `leader` 领导动态

- **标题格式**：`XXX+动作`，如"陈吉宁调研人工智能产业发展"
- **收录门槛**：副部级及以上主要领导
- **summary 结构**：时间背景 + 发言/关注点 + 政策导向（100-150字）
- 关注议题：平台经济、数据、AI治理、游戏监管、算法治理、营商环境

### 3. `policy` 重大政策

- **标题格式**：`XXX印发《XXX》`
- **summary 结构**：印发日期 + 内容总结 + 核心条款（100-150字）
- 重点关注：
  - 平台经济反垄断
  - 数据安全与跨境
  - AI 治理（生成式 AI、算法备案）
  - 游戏监管（版号、未成年人保护、海外发行）
  - 算法治理

### 4. `industry` 行业信息

- **标题格式**：中性陈述句，不强加主观
- **summary 结构**：时间 + 事件总结 + 影响（约 100 字）
- 关注赛道：AI/大模型、游戏电竞、云与企服、AIGC、金融科技、社交平台

### 5. `rival` 友商动态

- **标题格式**：`XX公司+动作`
- **summary 结构**：日期 + 事件总结 + 在华东/行业的意义（约 100 字）
- 友商清单：字节跳动、阿里巴巴、米哈游、百度、华为、爱奇艺、网易、快手

---

## 五、工作流（半自动）

```
[早上 9:00] AI 抓取脚本运行
    ↓ 全网抓 + 按白名单过滤 + 去重
[生成] data/drafts/YYYY-MM-DD.json （草稿队列）
    ↓
[你打开审核页面]（后续可做一个本地审核 UI）
    ↓ 逐条：通过 / 修改 / 驳回
[通过的条目] 追加到 data/YYYY-MM.json 对应 sections[xxx]
    ↓
[你点击"发布"] 脚本运行：JSON → HTML → git push
    ↓
[GitHub Pages 自动构建]（1-2 分钟）
    ↓
[公网访问] https://你的用户名.github.io/xxx/
```

---

## 六、人工录入规则（非 AI 时）

- 直接编辑 `YYYY-MM.json`，在对应 `sections[xxx]` 数组里追加条目
- 设 `ai_draft: false`、`status: "published"`
- 运行一次构建脚本即可

---

## 七、ID 编号规则

- 格式：`{section}-{序号}`，如 `hr-001`、`leader-007`
- 每月从 001 开始，跨月重置
- 为方便 AI 去重，脚本会基于 `title + date` 做模糊匹配
