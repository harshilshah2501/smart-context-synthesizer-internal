# Two-repository layout

Context Synthesizer is split across **two GitHub repositories**:

| Repository | Remote | Visibility | Branch | Contents |
|------------|--------|------------|--------|----------|
| [smart-context-synthesizer](https://github.com/harshilshah2501/smart-context-synthesizer) | `origin` | **Public** | `main` | OSS proxy product only |
| [smart-context-synthesizer-internal](https://github.com/harshilshah2501/smart-context-synthesizer-internal) | `internal` | **Private** | `main` | Full toolkit (corpus, team deploy, reports) |

GitHub does not support per-branch privacy. Internal history must live in the private repo.

---

## Local clone setup

### If you cloned the **internal** repository

```bash
git remote rename origin internal
git remote add origin https://github.com/harshilshah2501/smart-context-synthesizer.git
git fetch origin
git checkout -b public origin/main
git checkout main
```

### If you cloned before the split (both remotes already configured)

```bash
git remote -v
# origin    → public OSS repo (push OSS releases here)
# internal  → private full toolkit (push daily work here)
```

Recommended local branches:

| Local branch | Tracks | Use for |
|--------------|--------|---------|
| `main` | `internal/main` | Daily development (full toolkit) |
| `public` | `origin/main` | OSS release line (proxy-only) |

---

## Daily workflow (internal)

```bash
# Work on main, commit, push to private repo
git checkout main
git push internal main
```

---

## Publish OSS release

When proxy/product changes are ready for the public repo:

```bash
# 1) Update OSS branch from internal (cherry-pick or merge selectively)
git checkout public
git cherry-pick <commit-sha>   # repeat for each proxy-only commit
# or: git merge main --no-commit  # then unstage/remove internal-only files

# 2) Push to public repository main
git push origin public:main

# 3) Return to internal work
git checkout main
```

Helper script:

```bash
bash scripts/push-oss-release.sh
```

---

## Never push internal main to public origin

```bash
# WRONG — exposes corpus/team tooling
git push origin main
```

Always use `git push origin public:main` from the curated `public` branch.

---

## Clone URLs

**Open source users:**

```bash
git clone https://github.com/harshilshah2501/smart-context-synthesizer.git
```

**Team members (private):**

```bash
git clone https://github.com/harshilshah2501/smart-context-synthesizer-internal.git
```
