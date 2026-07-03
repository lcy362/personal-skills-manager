# Personal Skills Manager (pks)

> [English](README.en.md) · [中文](README.md)

A personal skill management tool for AI coding agents. Manage all instruction sets in one place, distribute them to projects or agents as needed — no vendor lock-in.

---

## Background

I've written two posts on this topic:

- [How to Farm Free Tokens: Building Agent-Independent AI Workflows](https://lichuanyang.top/en/posts/26060/): **Agents are just tools. Documentation is the core.** Every AI coding agent follows the same loop — read docs → assemble prompts → call a model → modify files. What actually matters is the documentation and workflows you maintain.
- [From Token Farming to Skill Managing: My pks Tool in Practice](https://lichuanyang.top/en/posts/34689/): After switching between agents frequently, skill management became a real pain point — each agent has a different skill directory, and skills have different scopes. This needs proper tooling.

pks is the practical implementation: **package your documented workflows as skills, manage them globally, inject them on demand.** Plain Markdown, no proprietary config formats.

---

## What Problem Does This Solve?

The current agent ecosystem is fragmented — Cursor stores skills in `~/.cursor/skills`, Claude Code in `~/.claude/skills`, Trae in `~/.trae/skills`, OpenCode in `~/.config/opencode/skills`, plus Windsurf, Qoder, Hermes, and more. The community is pushing for standards like `.agents/skills`, which helps but isn't enough.

Skills also naturally have different scopes:
- Some are only relevant to a few specific projects
- Some should be global but only active in certain agents
- When you edit a skill in a project, you need to sync it back to the global library

pks solves this with a centralized repository at `~/.local/share/pks/skills/`, then distributes skills to wherever they're needed.

---

## When to Use pks

pks is best suited for **non-generic** instruction sets such as:

- **Personal habits**: your coding style preferences, common toolchain setup, commit conventions
- **Company standards**: team code review guidelines, CI/CD workflows, internal library usage
- **Project conventions**: Architecture Decision Records (ADRs), database conventions, API design constraints

> **Note**: `weread-skills` (WeChat Reading assistant) is included as a demonstration of pks's installation and workflow. General-purpose tools like WeChat Reading are better configured directly in your agent's global settings — they don't need per-project management via pks.

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
| `pks doctor` | Show diagnostic info (paths, version, skill status) |
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
| `pks update <name>` | Reinstall skill from global (overwrites project copy) |
| `pks push <name>` | Push project skill edits back to global skills |

### Agent-Level Commands

| Command | Description |
|---------|-------------|
| `pks agents` | List detected global agent skill directories |
| `pks project-agents` | List detected project-level agent skill directories |
| `pks list-agents` | List all supported project-level agent skill dirs |
| `pks install-to <agent> <skill>` | Install a skill to an agent's global directory |
| `pks uninstall-from <agent> <skill>` | Remove a skill from an agent's global directory |
| `pks update-to <agent> <skill>` | Update a skill in an agent directory from global |

### Project-Level Linking

| Command | Description |
|---------|-------------|
| `pks link [agent]` | Symlink agent's project skill dir → `.skills/` |
| `pks unlink [agent]` | Remove symlink from agent's project skill dir |

When no `agent` is specified, `link`/`unlink` applies to all supported agents.

Supported agents: opencode, .agents, claude, cursor, windsurf, trae, trae-cn, codex, qoder, qoderwork, qoderworkcn, workbuddy, openclaw, hermes, teamwork.

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

### Installing Skills to a Specific Agent

Some skills have a narrow scope — for example, a "news collector" skill you only want in one agent:

```bash
# See which agents are on this machine
pks agents

# Install a skill to a specific agent
pks install-to cursor news-collector

# Update it later
pks update-to cursor news-collector

# Remove it
pks uninstall-from cursor news-collector
```

### Editing in Project and Pushing Back

Skills evolve as you use them. When you need to tweak a skill:

```bash
# Edit the skill in your project
vim .skills/my-skill/SKILL.md

# Push your changes back to the global library
pks push my-skill
```

### Sharing Skills Across Multiple Agents

For agents that support project-level skill directories, use `link` to share a single `.skills/` directory:

```bash
cd your-project

# See which agent skill dirs exist in this project
pks project-agents

# View all supported agent dirs
pks list-agents

# Link a single agent's dir to .skills
pks link opencode

# Link all supported agents at once
pks link
```

After linking, when these agents read their project skill directory, they are actually reading from `.skills/`.

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

No dependency on `AGENTS.md`, `CLAUDE.md`, or any agent-specific config file. Any AI coding agent exploring the project will naturally discover the `.skills/` directory and read the Markdown files. The INDEX.md prompt guides the agent to load skills on demand.

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
- **Central management, multi-level distribution**: All skills in one repo; distribute to projects, agent global dirs, or agent project dirs as needed
- **Two-way sync**: `push` writes project edits back to the global library
- **Semantic versioning**: Each skill has a version field for change tracking
- **Token efficient**: Skills only load when needed, avoiding unnecessary token consumption on every agent conversation
