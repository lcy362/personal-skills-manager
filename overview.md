# Reasonix Skill 目录支持 - 变更总结

## 调研结论

Reasonix (DeepSeek 原生编码框架) 的 skill 目录体系：

| 层级 | 路径 | 优先级 |
|------|------|--------|
| 全局 | `~/.reasonix/skills/` (支持 `REASONIX_SKILLS_DIR` 覆盖) | 所有会话自动加载 |
| 项目 | `.reasonix/skills/` | 覆盖同名全局/内置 skills |
| 备用扫描 | `.claude/skills/`, `.agents/skills/` | Reasonix 兼容扫描 |

Skill 格式：Markdown 文件 + 可选 YAML frontmatter，支持 inline 和 subagent 执行模式。

参考来源：`github.com/esengine/DeepSeek-Reasonix` 官方文档 `CONFIG_PATHS.md`

## 变更内容

### `bin/pks` - 12 处修改
1. `resolve_agent_path()` - 新增 `reasonix` → `${REASONIX_SKILLS_DIR:-$HOME/.reasonix/skills}`
2. `resolve_project_agent_path()` - 新增 `reasonix` → `.reasonix/skills`
3. `detect_agents()` - 新增 detection 条目
4. `detect_project_agents()` - 新增 detection 条目
5. `cmd_list_project_supported()` - 新增文档行 (标注 official)
6. 4 处已知 agent 列表 (cmd_install_to, cmd_update_to, cmd_uninstall_from, cmd_link 单agent) 统一追加 `reasonix`
7. `cmd_link` 和 `cmd_unlink` 的批量操作列表追加

### `README.md` / `README.en.md` - 各 1 处
- 支持的 Agent 列表追加 `reasonix`

## 使用方式

```bash
# 全局: 安装 skill 到 Reasonix
pks install-to reasonix my-skill

# 项目: 链接 Reasonix 项目目录到 .skills/
pks link reasonix

# 检测
pks agents            # 检测全局 ~/.reasonix/skills/
pks project-agents    # 检测项目 .reasonix/skills/
```
