# Personal Skills Manager (pks)

> [English](README.en.md) · [中文](README.md)

AI Agent 个人技能管理工具。全局管理 skill，按需安装到项目，不依赖特定 Agent 配置。

---

## 背景

市面上的 AI 编码 Agent 层出不穷（Cursor、Windsurf、Claude Code、OpenCode……），但各自的 skill/rule 配置互不兼容。每换一个 Agent 就得重新配一套规则，导致被绑定在单一工具上，无法灵活使用各家免费或试用额度来降低花费。

pks 的核心理念是：**用纯 Markdown 构建与 Agent 无关的 skill 工作流**。Skill 文件存放在项目目录下，任何 Agent 在探索项目时都能自然发现并读取，不受配置文件格式限制。

更详细的设计思路见博客文章：
- [中文版：AI 编码 Agent 技能管理 — 降低 Token 开销的一种思路](https://lichuanyang.top/posts/26060/)
- [English: AI Coding Agent Skill Management — Reducing Token Waste](https://lichuanyang.top/en/posts/26060/)

---

## 适用范围

pks 最适合管理**非通用类**指令，例如：

- **个人习惯**：你的编码风格偏好、常用工具链配置、commit 规范
- **公司规范**：团队代码规范、CI/CD 流程、内部库的使用约定
- **项目约定**：该项目的架构决策记录（ADR）、数据库规范、API 设计约束

> **注意**：`weread-skills`（微信读书助手）是作为示例提供的技能，演示 pks 的安装和工作流。实际上，像微信读书这类**通用工具**更适合直接配置在 Agent 的全局设置中（如 `.opencode/skills/` 或 `CLAUDE.md`），不需要用 pks 按项目管理。

**什么时候用 pks？** 当一个指令集只对**特定项目**或**特定团队**有用，且不希望全局 Agent 每次对话都加载它时，pks 是最佳选择。

---

## 安装

### 方式一：install.sh

```bash
git clone git@github.com:lcy362/personal-skills-manager.git ~/.local/share/pks
~/.local/share/pks/install.sh
source ~/.zshrc
```

### 方式二：pks install-self

```bash
git clone git@github.com:lcy362/personal-skills-manager.git /任意路径/pks-repo
/任意路径/pks-repo/bin/pks install-self
```

两种方式效果相同：
1. 复制文件到 `~/.local/share/pks/`
2. 在 `~/.local/bin/pks` 创建符号链接
3. 将 `~/.local/bin` 加入 PATH（写入 `~/.zshrc`）

可通过环境变量自定义路径：

```bash
PKS_HOME=/custom/path PKS_BIN_DIR=/custom/bin pks install-self
```

完成后重启终端或 `source ~/.zshrc` 即可使用 `pks`。

---

## 命令参考

### 全局操作

| 命令 | 作用 |
|------|------|
| `pks list` | 列出所有全局 skill |
| `pks new <name>` | 基于 `_template` 创建新 skill 骨架 |
| `pks delete <name>` | 永久删除一个全局 skill |
| `pks install-self` | 将当前 pks 安装到系统 |
| `pks help` | 显示帮助 |
| `pks version` | 显示版本号 |

### 项目内操作（需先 `pks init`）

| 命令 | 作用 |
|------|------|
| `pks init` | 在当前项目初始化 `.skills/` 目录 |
| `pks status` | 查看已安装 skill 列表及版本 |
| `pks available` | 查看可安装的全局 skill 及安装状态 |
| `pks install <name>` | 安装指定 skill 到当前项目 |
| `pks uninstall <name>` | 从当前项目卸载指定 skill |

### 删除 vs 卸载

| 操作 | 命令 | 作用范围 | 说明 |
|------|------|----------|------|
| 卸载 | `pks uninstall <name>` | 项目内 `.skills/` | 删除目录 + 更新 INDEX.md |
| 删除 | `pks delete <name>` | 全局 `skills/` | 从仓库永久移除 |
| 直接删文件 | `rm -rf .skills/<name>` | 项目内 | INDEX.md 会残留失效链接，不推荐 |

---

## 完整工作流

### 在项目中使用

```bash
cd your-project

# 1. 初始化（只需一次）
pks init

# 2. 查看可安装的 skill
pks available

# 3. 安装 skill
pks install my-custom-skill

# 4. 查看已安装状态
pks status

# 5. 卸载
pks uninstall my-custom-skill
```

### 创建与删除 Skill

```bash
# 创建（基于模板生成骨架）
pks new my-custom-skill

# 编辑 skill 内容
vim skills/my-custom-skill/SKILL.md

# 永久删除（全局）
pks delete my-custom-skill
```

创建后结构：

```
skills/my-custom-skill/
├── SKILL.md       # 编辑此文件填写 skill 说明
└── files/         # 随 skill 分发的附加文件
```

填充 `description` 和 `version` 字段：

```yaml
---
name: my-custom-skill
description: 用户意图识别后触发指定工作流的指令集
version: 1.0.0
---
```

---

## Skill 格式

每个 skill 是一个目录，包含 `SKILL.md` 和可选附属文件。`SKILL.md` 使用 YAML 前置元数据 + Markdown 正文：

```yaml
---
name: skill-name         # 全局唯一标识
description: 一句话描述  # 用于 pks list/available 展示
version: 1.0.0          # 语义化版本
---
```

正文按需组织，包含能力表格、接口文档、工作流、约束规则等。Agent 读取此文件获得完整的操作指南。

---

## Agent 自然发现机制

Skill 安装后的项目结构：

```
your-project/
├── .skills/
│   ├── INDEX.md         # → 列出所有已安装 skill，Agent 首先读取此文件
│   └── my-custom-skill/
│       └── SKILL.md     # → 具体 skill 说明
└── ...（项目文件）
```

不依赖 `AGENTS.md`、`CLAUDE.md` 等特定 Agent 配置文件。任何 AI 编码 Agent 在探索项目时，都会自然发现 `.skills/` 目录并读取其中的 Markdown 文件，从而获得 skill 指令。INDEX.md 中的提示语引导 Agent 按需加载。

---

## 仓库结构

```
personal-skills-manager/
├── bin/pks              # CLI 工具（纯 bash，零依赖）
├── install.sh           # 一键安装脚本
├── pks.json             # 仓库清单
├── skills/
│   ├── _template/       # pks new 使用的骨架
│   ├── weread-skills/   # 微信读书助手 skill（示例）
│   └── ...              # 其他 skill
├── LICENSE
├── README.md
└── README.en.md
```

---

## 设计原则

- **零依赖**：CLI 纯 bash，无需 Python/Node.js
- **路径无关**：pks 在任何路径都可正常运行（符号链接解析 + 相对路径定位）
- **Agent 无关**：Skill 是纯 Markdown 文件，任何 Agent 都能读取
- **全局管理，按需安装**：所有 skill 集中在本仓库，项目内只安装需要的
- **语义化版本**：每个 skill 标注 version，支持追踪变更
- **节省 Token**：只在需要时加载 skill，避免 Agent 每次对话都读取无关指令
