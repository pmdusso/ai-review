# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-07-15

### Added

- Bundled templates: `security`, `architecture`, `pr-review`, `plan-review`
- Agent presets: `fast`, `balanced`, `full`
- Project/global YAML config via `.ai-review/config.yaml` (requires `yq` v4+)
- `--version` and `VERSION` file
- `scripts/install.sh` (CLI + templates + skill symlinks; `--no-skills` to skip), `scripts/install-templates.sh`, `scripts/init-project.sh`
- `docs/reference.md` as single technical reference
- bats test suite with mock CLIs, shellcheck CI, Makefile
- `CONTRIBUTING.md`

### Changed

- Template lookup now falls back to `$AI_REVIEW_HOME/templates` and script-dir templates
- Pre-commit installer uses `ai-review` from PATH, `--redact`, and `fast` preset
- README restructured for team onboarding

### Removed

- Duplicate `ai-review.md` workflow doc (use `SKILL.md`)
- Incomplete GitHub PR-review workflow skeleton (replaced by quality CI)

## [0.1.0] - 2026-04-06

### Added

- Initial multi-agent fan-out harness via native CLIs
- Secret scan, `--redact`, `--dry-run`, `-o`, `-t`, `-d`
- Codex/Claude skill and Gemini extension packaging
