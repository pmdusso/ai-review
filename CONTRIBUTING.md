# Contributing

## Development setup

```bash
git clone https://github.com/pmdusso/ai-review
cd ai-review
./scripts/install.sh

# Test deps
brew install bats-core shellcheck yq jq   # or apt equivalents
```

## Checks before opening a PR

```bash
make lint
make test
```

Manual smoke (optional, needs agent CLIs):

```bash
./scripts/install.sh
ai-review --version
ai-review --list-agents
ai-review --dry-run -a fast -s "OK" <<< "teste"
ai-review -t pr-review --dry-run -f README.md
./scripts/init-project.sh --force
ai-review --dry-run -f README.md
```

## Guidelines

- Keep the core in a single bash script (`ai-review`); prefer small focused helpers over new layers.
- Document flags/presets/config only in [`docs/reference.md`](docs/reference.md); link from README/SKILL.
- Bump [`VERSION`](VERSION), [`gemini-extension.json`](gemini-extension.json), and [`CHANGELOG.md`](CHANGELOG.md) together.
- Add bats coverage for new CLI behavior (prefer mock CLIs under `tests/helpers/mock-clis/`).
- Do not commit secrets, `.expect/`, or `.superpowers/`.

## Commit style

Prefer short imperative subjects focused on why, e.g. `fix: soft-skip missing agents only for default preset`.
