# Personal Skills Manager (pks)

> [English](README.en.md) · [中文](README.md)

A personal skill management tool for AI coding agents. Manage global instruction sets and install them per-project, without depending on any specific Agent configuration.

---

## Background

New AI coding agents emerge constantly — Cursor, Windsurf, Claude Code, OpenCode, and more. Each has its own proprietary skill/rule configuration format, making them mutually incompatible. Switching agents means rebuilding your setup from scratch, locking you into a single tool and preventing you from leveraging free trials across different agents to reduce costs.

pks was built on a simple premise: **build agent-agnostic skill workflows with plain Markdown**. Skill files live in your project directory, and any agent exploring the project can naturally discover and read them — no proprietary config format required.

For a deeper dive into the design philosophy, see:
- [AI Coding Agent Skill Management — Reducing Token Waste](https://lichuanyang.top/en/posts/26060/)
- [中文版：AI 编码 Agent 技能管理 — 降低 Token 开销的一种思路](https://lichuanyang.top/posts/26060/)

---

## When to Use pks

pks is best suited for **non-generic** instruction sets such as:

- **Personal habits**: your coding style preferences, common toolchain setup, commit conventions
- **Company standards**: team code review guidelines, CI/CD workflows, internal library usage
- **Project conventions**: Architecture Decision Records (ADRs), database conventions, API design constraints

> **Note**: `weread-skills` (WeChat Reading assistant) is included as a demonstration of pks's installation and workflow. General-purpose tools like WeChat Reading are better configured directly in your agent's global settings (e.g., `.opencode/skills/` or `CLAUDE.md`) — they don't need per-project management via pks.

**When should you use pks?** When an instruction set is only relevant to **specific projects** or **specific teams**, and you don't want your global agent loading it on every conversation.

---

## Installation

### Option 1: install.sh

```bash
git clone git@github.com:lcy362/personal-skills-manager.git ~/.local/share/pks
~/.local/share/pks/install.sh
source ~/.zshrc
```

### Option 2: pks install-self

```bash
git clone git@github.com:lcy362/personal-skills-manager.git /any/path/pks-repo
/any/path/pks-repo/bin/pks install-self
```

Both methods do the same thing:
1. Copy files to `~/.local/share/pks/`
2. Create a symlink at `~/.local/bin/pks`
3. Add `~/.local/bin` to `PATH` in `~/.zshrc`

You can customize paths via environment variables:

```bash
PKS_HOME=/custom/path PKS_BIN_DIR=/custom/bin pks install-self
```

After installation, restart your terminal or run `source ~/.zshrc` to start using `pks`.

---

## Command Reference

### Global Commands

| Command | Description |
|---------|-------------|
| `pks list` | List all global skills |
| `pks new <name>` | Create a new skill from `_template` |
| `pks delete <name>` | Permanently delete a global skill |
| `pks install-self` | Install pks to system |
| `pks help` | Show help |
| `pks version` | Show version |

### Project Commands (after `pks init`)

| Command | Description |
|---------|-------------|
| `pks init` | Initialize `.skills/` in current project |
| `pks status` | Show installed skills with versions |
| `pks available` | List installable global skills with project status |
| `pks install <name>` | Install a skill into current project |
| `pks uninstall <name>` | Uninstall a skill from current project |

### Delete vs Uninstall

| Action | Command | Scope | Details |
|--------|---------|-------|---------|
| Uninstall | `pks uninstall <name>` | Project `.skills/` | Removes directory + updates INDEX.md |
| Delete | `pks delete <name>` | Global `skills/` | Permanently removes from repository |
| Manual delete | `rm -rf .skills/<name>` | Project | Leaves broken links in INDEX.md, not recommended |

---

## Workflow

### Using Skills in a Project

```bash
cd your-project

# 1. Initialize (once per project)
pks init

# 2. See what's available
pks available

# 3. Install a skill
pks install my-custom-skill

# 4. Check installation status
pks status

# 5. Uninstall when done
pks uninstall my-custom-skill
```

### Creating and Deleting Skills

```bash
# Create a new skill from template
pks new my-custom-skill

# Edit the skill's instructions
vim skills/my-custom-skill/SKILL.md

# Permanently delete a global skill
pks delete my-custom-skill
```

Created structure:

```
skills/my-custom-skill/
├── SKILL.md       # Edit this file with your instructions
└── files/         # Additional files bundled with the skill
```

Fill in `description` and `version`:

```yaml
---
name: my-custom-skill
description: Instruction set for triggering specific workflows
version: 1.0.0
---
```

---

## Skill Format

Each skill is a directory containing `SKILL.md` and optional additional files. `SKILL.md` uses YAML front matter + Markdown body:

```yaml
---
name: skill-name         # Globally unique identifier
description: One-liner   # Shown in pks list/available
version: 1.0.0          # Semantic versioning
---
```

The body can include capability tables, API documentation, workflows, and constraint rules. The agent reads this file to understand how to operate.

---

## Agent Auto-Discovery

After installing a skill, the project looks like this:

```
your-project/
├── .skills/
│   ├── INDEX.md         # → Agent reads this first: lists all installed skills
│   └── my-custom-skill/
│       └── SKILL.md     # → Specific skill instructions
└── ...（project files）
```

No dependency on `AGENTS.md`, `CLAUDE.md`, or any agent-specific config file. Any AI coding agent exploring the project will naturally discover the `.skills/` directory and read the Markdown files. The INDEX.md prompt `Agents: read the SKILL.md file in each skill directory below for relevant instructions.` guides the agent to load skills on demand.

---

## Repository Structure

```
personal-skills-manager/
├── bin/pks              # CLI tool (pure bash, zero dependencies)
├── install.sh           # One-click installer
├── pks.json             # Manifest
├── skills/
│   ├── _template/       # Template for pks new
│   ├── weread-skills/   # WeChat Reading assistant skill (example)
│   └── ...              # More skills
├── LICENSE
├── README.md
└── README.en.md
```

---

## Design Principles

- **Zero dependencies**: Pure bash CLI, no Python/Node.js required
- **Path-independent**: pks works from any location (symlink resolution + relative pathing)
- **Agent-agnostic**: Skills are plain Markdown — any agent can read them
- **Central management, per-project installation**: All skills in one repo, project gets only what it needs
- **Semantic versioning**: Each skill has a version field for change tracking
- **Token efficient**: Skills only load when needed, avoiding unnecessary token consumption on every agent conversation
