---
name: skills-git-commit
description: '专门用于将 /Users/ja/.agents/skills 目录下的 skills 提交到 GitHub 仓库 personal-skills。当用户想要提交 skills、上传 skills 到 GitHub、或者 skills 目录有变更需要提交时使用。自动检测变更、生成 conventional commit message 并推送到远程仓库。'
---

# Skills Git Commit

将本地 skills 提交到 GitHub 仓库 `MeinAJ/personal-skills`。

## 工作流程

### 1. 进入 Skills 目录

所有操作都在 `/Users/ja/.agents/skills` 目录下执行：

```bash
cd /Users/ja/.agents/skills
```

### 2. 检查当前状态

```bash
git status
git diff          # 如果有已暂存的文件
git diff --staged # 查看暂存区的变更
```

### 3. 检测变更内容

识别哪些 skill 发生了变化：

```bash
# 查看未暂存的变更文件
git status --porcelain

# 查看具体某个 skill 的变更
git diff <skill-name>/
```

### 4. 生成 Commit Message

根据变更类型生成 conventional commit message：

| 变更类型 | Commit Type | 示例 |
|---------|-------------|------|
| 新增 skill | `feat` | `feat: add <skill-name> skill` |
| 更新 skill | `feat` 或 `fix` | `feat: update <skill-name> with ...` |
| 修复 bug | `fix` | `fix: resolve issue in <skill-name>` |
| 文档更新 | `docs` | `docs: update SKILL.md for <skill-name>` |
| 删除 skill | `feat!` | `feat!: remove <skill-name> skill` |

**多 skill 变更示例：**
```
feat: add multiple skills

- add git-commit skill for conventional commits
- add webapp-testing skill for Playwright testing
- update find-skills with better search
```

### 5. 执行提交

```bash
# 添加所有变更
git add .

# 提交（单引号或多行消息）
git commit -m "<type>: <description>"

# 或多行提交
git commit -m "$(cat <<'EOF'
<type>: <description>

<body if needed>
EOF
)"
```

### 6. 推送到 GitHub

```bash
git push origin main
```

## 安全提醒

- ⚠️ 不要提交包含敏感信息（API keys、密码、私钥）的 skill
- 提交前检查 `.env` 文件是否被意外包含
- 确保每个 skill 的 `SKILL.md` 符合规范

## 常见场景

### 场景 1：提交单个新 skill

```bash
cd /Users/ja/.agents/skills
git status                              # 确认只有目标 skill 的变更
git diff <skill-name>/                  # 检查变更内容
git add .
git commit -m "feat: add <skill-name> skill"
git push origin main
```

### 场景 2：更新现有 skill

```bash
cd /Users/ja/.agents/skills
git diff <skill-name>/SKILL.md          # 查看 SKILL.md 的变更
git add .
git commit -m "feat: update <skill-name> with <what-changed>"
git push origin main
```

### 场景 3：批量提交多个 skills

```bash
cd /Users/ja/.agents/skills
git status --short                      # 查看所有变更的文件列表

# 生成包含所有变更的 commit message
git add .
git commit -m "$(cat <<'EOF'
feat: add and update multiple skills

- add <skill-1>: <brief-description>
- add <skill-2>: <brief-description>
- update <skill-3>: <what-changed>
EOF
)"
git push origin main
```

### 场景 4：修复 skill 中的问题

```bash
cd /Users/ja/.agents/skills
git diff                                # 查看修复内容
git add .
git commit -m "fix: resolve <issue> in <skill-name>"
git push origin main
```
