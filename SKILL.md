---
name: ai-review
description: Use when the user wants multi-agent AI review of a file, plan, technical decision, diff, or project artifact through the local ai-review CLI, including choosing agents, preparing safe prompts, confirming external data sharing, running reviews, and synthesizing consensus, disagreements, and prioritized follow-up actions.
---

# AI Review

Use the local `ai-review` command to request feedback from multiple AI agent CLIs.

Default agents are `gemini,codex,auggie,mmx,qwen`; `claude` is opt-in via `-a claude`, `-a default+claude`, or `-a all`.

## Workflow

1. Identify the review target: file, stdin content, decision, plan, or diff.
2. Inspect the target enough to understand scope and avoid sending unnecessary material.
3. Confirm with the user before sending content to external providers. Include:
   - target path or content summary;
   - selected agents;
   - system instruction;
   - prompt focus.
4. Use Brazilian Portuguese for prompts unless the user asks otherwise.
5. Prefer narrow, focused reviews for large documents or codebases.
6. Run `ai-review --dry-run` first when validating agent selection, prompt size, or VM setup.
7. Execute the review.
8. Synthesize the output into:
   - consensus;
   - disagreements;
   - prioritized suggested actions;
   - notable failures or stderr from individual agents.

## Commands

Review a file:

```bash
ai-review \
  -f <file> \
  -s "<system instruction>" \
  -p "<optional prompt focus>"
```

Review stdin:

```bash
cat <file> | ai-review -s "<system instruction>"
```

Select agents:

```bash
ai-review -f docs/ARCHITECTURE.md -s "Revise." -a qwen,gemini
ai-review -f docs/ARCHITECTURE.md -s "Revise." -a default+claude
ai-review -f docs/ARCHITECTURE.md --dry-run -a all
```

Useful flags:

```bash
ai-review --list-agents
ai-review --dry-run
ai-review --redact           # Redacts secrets automatically into [REDACTED] instead of aborting
ai-review -o report.md       # Saves final unified markdown report to a local file
ai-review -t security        # Loads system prompt instructions from config/local templates
ai-review -d                 # Injects file's local git diff context alongside content
ai-review --keep-results
ai-review --timeout 900
```

Use `--allow-secrets` only when the user explicitly confirms that sending possible secrets to external providers is intentional.

## Agent Selection

- `default`: `gemini,codex,auggie,mmx,qwen`
- `default+claude` or `all`: default agents plus `claude`
- `qwen`: useful for code-focused review with lower fan-out cost
- `gemini,codex`: useful for a quick second opinion without all agents

## Safety

The script scans for common secret patterns before sending content. If it detects possible secrets, do not bypass the warning unless the user explicitly authorizes it.

Do not send secrets, personal sensitive data, regulated data, private customer data, or proprietary material to external providers unless the user has confirmed that this is allowed.

## Setup Reference

If `ai-review` or agent CLIs are missing, read `docs/install.md` in this repo for installation, headless VM authentication, validation, and update instructions.
