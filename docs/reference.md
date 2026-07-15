# Referência técnica — ai-review

Fonte única de verdade para flags, agentes, presets, templates, config YAML e secret scan.
O README e as skills apontam para este documento em vez de duplicar tabelas.

## Flags

| Flag | Descrição |
|------|-----------|
| `-f, --file <path>` | Arquivo a revisar |
| `-s, --system <text>` | Instrução de sistema / persona |
| `-p, --prompt <text>` | Prefixo de prompt (antes do conteúdo) |
| `-a, --agents <list>` | Agentes, presets ou aliases (ver abaixo) |
| `--allow-secrets` | Envia mesmo com secrets detectados |
| `--redact` | Substitui secrets por `[REDACTED]` e segue |
| `--dry-run` | Mostra agentes/modelos/stats sem enviar |
| `--keep-results` | Mantém arquivos temp de stdout/stderr/status |
| `--list-agents` | Lista agentes, modelos e env overrides |
| `-o, --output <path>` | Salva relatório Markdown unificado |
| `-t, --template <name>` | Carrega system prompt de template |
| `-d, --diff` | Combina conteúdo do arquivo + `git diff` local |
| `--timeout <seconds>` | Timeout por agente (default: 600) |
| `--version` | Mostra versão do harness |
| `-h, --help` | Ajuda |

`-s` e `-t` são mutuamente exclusivos.

## Agentes e modelos default

| Agente | Default? | Modelo default | Override |
|--------|----------|----------------|----------|
| `gemini` | sim | `gemini-3.1-pro-preview` | `AI_REVIEW_GEMINI_MODEL` |
| `codex` | sim | `gpt-5.5` | `AI_REVIEW_CODEX_MODEL` |
| `auggie` | sim | `opus4.7` | `AI_REVIEW_AUGGIE_MODEL` |
| `mmx` | sim | `MiniMax-M2.7` | `AI_REVIEW_MMX_MODEL` |
| `qwen` | sim | `qwen3-coder-plus` | `AI_REVIEW_QWEN_MODEL` |
| `claude` | opt-in | `claude-fable-5` | `AI_REVIEW_CLAUDE_MODEL` |

Outras env vars:

| Variável | Default | Uso |
|----------|---------|-----|
| `AI_REVIEW_TIMEOUT_SECONDS` | `600` | Timeout por agente |
| `AI_REVIEW_QWEN_AUTH_TYPE` | `openai` | `--auth-type` do Qwen |
| `AI_REVIEW_HOME` | dir do script | Raiz da instalação (templates bundled) |

## Presets e selectors

| Selector | Expande para | Quando usar |
|----------|--------------|-------------|
| `fast` | `qwen` | Pre-commit, iteração rápida, baixo custo |
| `balanced` | `qwen,gemini` | Review de PR / segunda opinião |
| `full` | `gemini,codex,auggie,mmx,qwen` | Decisões importantes (mesmo que `default`) |
| `default` | `gemini,codex,auggie,mmx,qwen` | Fan-out completo sem Claude |
| `default+claude` / `all` | default + `claude` | Planos críticos |

Lista explícita: `-a qwen,gemini,codex`.

## Templates (`-t`)

Ordem de busca do arquivo `<name>.txt`:

1. `./.ai-review/templates/<name>.txt` (projeto)
2. `~/.config/ai-review/templates/<name>.txt` (global do usuário)
3. `$AI_REVIEW_HOME/templates/<name>.txt` (instalação)
4. `<dir-do-script>/templates/<name>.txt` (bundled no repo)

Templates bundled: `security`, `architecture`, `pr-review`, `plan-review`.

Instalação global: `./scripts/install-templates.sh`  
Cópia no projeto: `./scripts/install-templates.sh --project`

## Config YAML

Arquivos (merge, menor prioridade primeiro):

1. Defaults do script
2. `~/.config/ai-review/config.yaml` (global)
3. `.ai-review/config.yaml` (projeto — sobe diretórios a partir do cwd ou do path de `-f`)
4. Env vars `AI_REVIEW_*`
5. Flags CLI (sempre ganham)

Requer [`yq`](https://github.com/mikefarah/yq) v4+ quando um arquivo de config existe.
Se o arquivo existe e `yq` não está no PATH, o script aborta com erro claro.

Schema (`version: 1`):

```yaml
version: 1
agents: balanced          # string (preset/lista) ou lista YAML: [qwen, gemini]
timeout_seconds: 300
template: pr-review       # default -t quando -s não foi passado
output: null              # default -o
redact: true              # default --redact
models:
  qwen: qwen3-coder-plus
  gemini: gemini-3.1-pro-preview
  codex: gpt-5.5
  auggie: opus4.7
  mmx: MiniMax-M2.7
  claude: claude-fable-5
```

Bootstrap em um repo consumidor:

```bash
# a partir do clone do ai-review, no diretório do projeto alvo:
/path/to/ai-review/scripts/init-project.sh
```

Exemplo versionado: [`templates/config.example.yaml`](../templates/config.example.yaml).

## Secret scan

Antes do envio, o script escaneia system instruction, prompt prefix e conteúdo por padrões comuns (API keys, private keys, tokens).

| Situação | Comportamento |
|----------|---------------|
| Nenhum match | Segue normalmente |
| Match + `--redact` | Substitui por `[REDACTED]` e segue |
| Match + `--allow-secrets` | Avisa e segue |
| Match + TTY interativo | Pergunta `[y/N]` |
| Match + sem TTY (CI) | Aborta com exit `3` |

Em CI/headless, use `--redact` ou `--allow-secrets` de forma consciente.

## Dependências

| Dep | Quando |
|-----|--------|
| `bash` 3.2+ | Sempre |
| `jq` | Agente `mmx` |
| `yq` v4+ | Quando existe `config.yaml` (global ou projeto) |
| CLIs dos agentes | Conforme `-a` / defaults |

Setup mínimo sugerido: `bash`, `jq`, `yq`, um agente (`qwen`).
Setup completo: ver [`docs/install.md`](install.md).
