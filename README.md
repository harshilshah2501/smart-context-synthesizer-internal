# Smart Context Synthesizer (internal)

[![Project status](https://img.shields.io/badge/status-beta-orange)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![CI](https://img.shields.io/badge/CI-public%20repo-blue)](https://github.com/harshilshah2501/smart-context-synthesizer/actions/workflows/ci.yml)

A local API proxy between **Claude Code** / **Cursor** and the Anthropic API. It compacts long session history into cached layers (L1/L2), preserves active tool loops, and exposes a live cost dashboard.

**This is the private internal repository** — corpus analysis, team deployment, and full R&D docs.

**Public OSS release:** [smart-context-synthesizer](https://github.com/harshilshah2501/smart-context-synthesizer) — fully usable without this repo for install and daily proxy use.  
**Repo layout:** [docs/guides/REPO_SPLIT.md](docs/guides/REPO_SPLIT.md)

**Docs:** [docs/README.md](docs/README.md) · **Security:** [SECURITY.md](SECURITY.md) · **Cheatsheet:** [docs/guides/DOCS_CHEATSHEET.md](docs/guides/DOCS_CHEATSHEET.md)

---

## Quick start

### From GitHub (recommended for open source)

```bash
git clone https://github.com/harshilshah2501/smart-context-synthesizer.git
cd smart-context-synthesizer/context-synthesizer
bash install.sh your.handle --install-dir ~/.local/share/context-synthesizer
```

Or one-liner (public repo):

```bash
curl -fsSL https://raw.githubusercontent.com/harshilshah2501/smart-context-synthesizer/main/install.sh | bash -s -- your.handle
```

Then:

```bash
export PATH="$HOME/.local/bin:$PATH"
csynth doctor && csynth dashboard
```

Use **Claude Code Max/Pro** — the CLI forwards OAuth; no separate API key at setup.

### From a release tarball

```bash
tar -xzf context-synthesizer-toolkit-*.tar.gz
cd context-synthesizer-toolkit-*
bash run-setup.sh your.handle
```

Team leads: `bash packaging/build-release-tarball.sh` — see [docs/guides/DEPLOY.md](docs/guides/DEPLOY.md).

---

## Benchmark locally

Reproducible 12-turn session against a running proxy (no Claude Code required):

```bash
# Terminal 1 — proxy (or: csynth proxy on)
cd context-synthesizer
source .venv/bin/activate   # or use install dir venv
uvicorn proxy_tool:app --host 127.0.0.1 --port 8080

# Terminal 2 — simulator (needs ANTHROPIC_API_KEY or proxy .env)
export ANTHROPIC_API_KEY=sk-ant-...
python test_simulator.py --base-url http://127.0.0.1:8080 --turns 12
```

The simulator prints cumulative cache read/write, shaped vs naive payload, and estimated cost. Results vary by model and `Claude.md` size — use your numbers, not fixed % claims.

Watch live metrics: `csynth dashboard` in a third terminal.

---

## What it does

| Feature | Description |
|---------|-------------|
| **Layered compaction** | L1 rules + L2 ledger + L3 recent turns + L4 prompt |
| **Prompt cache alignment** | `cache_control` breakpoints on stable prefix |
| **Tool-faithful proxy** | Preserves `tool_use` / `tool_result` in active loops |
| **Pinned checkpoints** | `@synth-remember:` in user messages → L2a |
| **Live dashboard** | Cache read / uncached / cost bifurcation per request |
| **Dual API** | Anthropic `/v1/messages` (full fidelity) + OpenAI `/v1/chat/completions` (Cursor — see [limitations](#limitations)) |

---

## Project status

**Beta** — core proxy, compaction, and dashboard are production-tested locally, but behavior and APIs may evolve. See [CHANGELOG.md](CHANGELOG.md). Report issues on [GitHub](https://github.com/harshilshah2501/smart-context-synthesizer/issues).

---

## Limitations

| Topic | Detail |
|-------|--------|
| **Claude Code (recommended)** | `/v1/messages` path is tool-faithful — preserves `tool_use` / `tool_result` in active loops. |
| **Cursor / OpenAI shim** | `/v1/chat/completions` uses a simpler legacy payload builder — not full parity with the Anthropic path. Fine for chat + telemetry; not ideal for heavy tool loops. See [docs/guides/CURSOR_TEST.md](docs/guides/CURSOR_TEST.md). |
| **Sessions** | In-memory only — restart clears ledger and pins. |
| **Scale** | Single-machine local proxy — not horizontally scalable. |
| **Savings** | Cost reduction depends on session length, model pricing, and `Claude.md` size. Run `python test_simulator.py` for a reproducible local benchmark — avoid quoting fixed % savings without your own numbers. |
| **Anthropic-only economics** | Prompt-cache breakpoints require Anthropic API semantics. |

---

## Privacy & security

- **API keys** pass through to Anthropic per request; store them only in `.env` (gitignored).
- **Telemetry** (`stats/telemetry.jsonl`) and **pinned checkpoints** stay on your machine but may contain project text.
- **Dashboard** — default bind is `127.0.0.1`. If you use `PROXY_HOST=0.0.0.0`, set `DASHBOARD_TOKEN` or `DASHBOARD_LOCALHOST_ONLY=1`.

Full details: [SECURITY.md](SECURITY.md)

---

## Repository layout

```
.
├── README.md
├── docs/                     guides, reports, architecture
└── context-synthesizer/
    ├── proxy_tool.py         FastAPI gateway
    ├── proxy_message_bridge.py
    ├── compaction.py         Dreaming v4
    ├── scripts/csynth          post-install CLI
    ├── packaging/            tarball build (optional team publish scripts)
    └── stats/                local telemetry — gitignored, never commit
```

---

## Daily commands

```bash
csynth proxy on | off | restart
csynth status | doctor | dashboard | logs
csynth upgrade    # pull latest from GitHub; preserves .env + stats/
```

If `csynth upgrade` is unknown (install from before v0.1.1), bootstrap once:

```bash
bash ~/.local/share/context-synthesizer/context-synthesizer/scripts/upgrade.sh
```

Full reference: [docs/guides/CSYNTH_QUICK_REFERENCE.md](docs/guides/CSYNTH_QUICK_REFERENCE.md)

**Why cost drops when payload looks flat:** [docs/guides/COST_SAVINGS.md](docs/guides/COST_SAVINGS.md)

---

## Public release checklist

Before publishing or sharing forks, read [docs/guides/PUBLIC_RELEASE.md](docs/guides/PUBLIC_RELEASE.md).

**Never commit:** `.env`, `stats/`, `stats/backups/`, session exports, or org-specific `packaging/share.conf`.

---

## License

MIT — see [LICENSE](LICENSE). · [Contributing](CONTRIBUTING.md) · [Security](SECURITY.md) · Issues: [GitHub](https://github.com/harshilshah2501/smart-context-synthesizer)
