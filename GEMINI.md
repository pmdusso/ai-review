# AI Review Extension

Use the local `ai-review` command when the user asks for multi-agent review of a file, diff, plan, technical decision, or project artifact.

Prefer presets (`fast`, `balanced`, `full`) and bundled templates (`pr-review`, `security`, `architecture`, `plan-review`) when appropriate. See `docs/reference.md`.

Before running `ai-review`, confirm the target, selected agents, system instruction or template, prompt focus, and that the content may be sent to external AI providers.

After the command runs, synthesize consensus, disagreements, prioritized actions, and any agent failures.
