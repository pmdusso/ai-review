# ai-review

Fan-out de code/doc review para múltiplos agentes de IA via CLIs nativos, em paralelo, com um único comando.

```bash
ai-review -f docs/ARCHITECTURE.md -t architecture -a balanced
```

Envia o mesmo conteúdo para agentes configuráveis (**Gemini, Codex, Auggie, MiniMax, Qwen**; Claude é opt-in), coleta as respostas em paralelo e apresenta a saída por agente — pronta para síntese de consenso, divergências e ações.

## Por que

Uma segunda opinião pega o que o primeiro modelo perdeu. Várias segundas opiniões, de famílias de modelos diferentes, pegam muito mais — e divergência entre elas é sinal de onde olhar com atenção.

## Quick start (2 minutos)

```bash
git clone https://github.com/pmdusso/ai-review ~/code/shared/ai-review
cd ~/code/shared/ai-review
./scripts/install.sh

# Validar sem chamar APIs (precisa de pelo menos um CLI no PATH para runs reais)
printf 'teste\n' | ai-review --dry-run -a fast -s "Responda apenas OK."
```

Setup mínimo: `bash`, `jq`, `yq` (para config YAML) e **um** agente autenticado (`qwen` recomendado).  
Guia completo (VMs headless, auth, skills): [`docs/install.md`](docs/install.md).

Diretórios locais `.expect/` e `.superpowers/` são scratch de desenvolvimento e podem ser apagados.

## Casos de uso

| Cenário | Comando |
|---------|---------|
| Review de PR diff | `git diff main...HEAD \| ai-review -a balanced -t pr-review` |
| Review de plano | `ai-review -f plan.md -t plan-review -a full` |
| Review de segurança | `ai-review -f app.py -t security -a balanced` |
| Pre-commit rápido | `git diff --cached \| ai-review -a fast --redact -s "Bugs óbvios."` |
| Diff + contexto do arquivo | `ai-review -f app.py -d -t pr-review` |
| Validar setup | `ai-review --dry-run -f plan.md -a fast` |
| CI / headless com secrets | `ai-review --redact -a fast -t pr-review -f app.py -o out.md` |

## Presets (custo / latência)

| Preset | Agentes | Quando |
|--------|---------|--------|
| `fast` | `qwen` | Iteração, pre-commit, baixo custo |
| `balanced` | `qwen,gemini` | Review de PR / segunda opinião |
| `full` / `default` | 5 agentes default | Decisões importantes |
| `default+claude` / `all` | default + Claude | Planos críticos |

```bash
ai-review -f app.py -a fast -t pr-review
ai-review -f app.py -a balanced -t pr-review
ai-review -f plan.md -a full -t plan-review
```

## Templates

Templates bundled: `security`, `architecture`, `pr-review`, `plan-review` (ver [`templates/`](templates/)).

```bash
ai-review -f main.py -t security -a balanced
./scripts/install-templates.sh          # → ~/.config/ai-review/templates/
./scripts/install-templates.sh --project
```

Ordem de busca e schema completo: [`docs/reference.md`](docs/reference.md).

## Config por projeto

```bash
# No root do repo consumidor (a partir do clone do ai-review):
/path/to/ai-review/scripts/init-project.sh
```

Isso cria `.ai-review/config.yaml` e templates locais. Exemplo: [`templates/config.example.yaml`](templates/config.example.yaml).

Prioridade: **CLI > env `AI_REVIEW_*` > config do projeto > config global > defaults**.

## Integração com agentes de código

`./scripts/install.sh` instala as skills automaticamente (`--no-skills` para pular).

| Ecossistema | Arquivos | Instalação |
|---|---|---|
| Agents / Claude / Codex (skill) | `SKILL.md` | via `install.sh` → `~/.agents/skills`, `~/.claude/skills`, `~/.codex/skills` |
| Gemini CLI (extension) | `gemini-extension.json`, `GEMINI.md`, `commands/ai-review.toml` | `gemini extensions link <repo>` |

Detalhes em [`docs/install.md`](docs/install.md).

Pre-commit em repos consumidores:

```bash
# no root do projeto alvo (ai-review no PATH)
/path/to/ai-review/scripts/install-pre-commit.sh
```

## Segurança

O conteúdo é enviado a provedores externos. O script escaneia secrets e **aborta** se encontrar algo — em CI use `--redact` ou `--allow-secrets`. Detalhes: [`docs/reference.md`](docs/reference.md#secret-scan).

## Troubleshooting

| Problema | Solução |
|----------|---------|
| Secret scan aborta em CI (exit 3) | `--redact` ou `--allow-secrets` |
| `yq` missing | `brew install yq` (só necessário com config YAML) |
| Agente não encontrado | `ai-review --list-agents`; instale o CLI ou use `-a fast` |
| Timeout | `--timeout 120` ou `AI_REVIEW_TIMEOUT_SECONDS=120` |
| Template não encontrado | confira `templates/` ou `./scripts/install-templates.sh` |

## Docs

- [`docs/install.md`](docs/install.md) — instalação, auth headless, skills
- [`docs/reference.md`](docs/reference.md) — flags, presets, config, secret scan
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — testes e contribuição
- [`CHANGELOG.md`](CHANGELOG.md) — histórico de versões

## Licença

[MIT](LICENSE)
