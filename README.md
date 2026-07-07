# ai-review

Fan-out de code/doc review para múltiplos agentes de IA via CLIs nativos, em paralelo, com um único comando.

```bash
ai-review -f docs/ARCHITECTURE.md -s "Você é um arquiteto sênior. Revise."
```

Envia o mesmo conteúdo para **Gemini, Codex (GPT), Auggie, MiniMax e Qwen Coder** (Claude é opt-in), coleta as respostas em paralelo e apresenta a saída por agente — pronta para síntese de consenso, divergências e ações.

## Por que

Uma segunda opinião pega o que o primeiro modelo perdeu. Cinco segundas opiniões, de famílias de modelos diferentes, pegam muito mais — e divergência entre elas é sinal de onde olhar com atenção.

## Requisitos

- `bash` 3.2+ (macOS ou Linux)
- `jq` (para o agente MiniMax)
- CLIs dos agentes instalados e autenticados: `gemini`, `codex`, `auggie`, `mmx`, `qwen` (e opcionalmente `claude`)

Guia completo de instalação e autenticação headless (VMs sem browser): [`docs/install.md`](docs/install.md).

## Instalação

```bash
git clone https://github.com/pmdusso/ai-review ~/code/shared/ai-review
mkdir -p ~/.local/bin
ln -sf ~/code/shared/ai-review/ai-review ~/.local/bin/ai-review
```

## Uso

```bash
# Review de arquivo
ai-review -f plan.md -s "Revise este plano de implementação."

# Via stdin
git diff | ai-review -s "Revise este diff."

# Selecionar agentes
ai-review -f app.py -a qwen,gemini
ai-review -f plan.md -a default+claude

# Redigir segredos detectados automaticamente (substitui por [REDACTED] sem abortar)
ai-review -f app.py --redact -s "Revise."

# Salvar relatório final unificado em arquivo Markdown local
ai-review -f plan.md -o relatorio.md

# Carregar uma persona/instrução de sistema de um arquivo de template
ai-review -f main.py -t security

# Revisar estritamente o git diff local do arquivo (combina diff + contexto)
ai-review -f app.py -d

# Validar sem enviar nada (simula dry-run de payload e avisos)
ai-review --dry-run -f plan.md
ai-review --list-agents
```

### Agentes e modelos default

| Agente | Modelo default | Override |
|---|---|---|
| `gemini` | `gemini-3.1-pro-preview` | `AI_REVIEW_GEMINI_MODEL` |
| `codex` | `gpt-5.5` | `AI_REVIEW_CODEX_MODEL` |
| `auggie` | `opus4.7` | `AI_REVIEW_AUGGIE_MODEL` |
| `mmx` | `MiniMax-M2.7` | `AI_REVIEW_MMX_MODEL` |
| `qwen` | `qwen3-coder-plus` | `AI_REVIEW_QWEN_MODEL` |
| `claude` (opt-in) | `claude-sonnet-4-6` | `AI_REVIEW_CLAUDE_MODEL` |

Timeout por agente: `AI_REVIEW_TIMEOUT_SECONDS` (default 600). Auth do Qwen: `AI_REVIEW_QWEN_AUTH_TYPE` (default `openai`).

## Segurança

O conteúdo é enviado a provedores externos. Antes do envio, o script escaneia conteúdo, system instruction e prompt por padrões comuns de secrets (chaves de API, chaves privadas, senhas) e **aborta** se encontrar algo — o bypass exige `--allow-secrets` explícito.

## Integração com agentes de código

O repo empacota a integração para três ecossistemas:

| Ecossistema | Arquivos | Instalação |
|---|---|---|
| Claude Code (skill) | `SKILL.md` | `ln -sfn <repo> ~/.claude/skills/ai-review` |
| Codex (skill) | `SKILL.md` | `ln -sfn <repo> ~/.codex/skills/ai-review` |
| Gemini CLI (extension) | `gemini-extension.json`, `GEMINI.md`, `commands/ai-review.toml` | `gemini extensions link <repo>` |

Detalhes em [`docs/install.md`](docs/install.md).

## Licença

[MIT](LICENSE)
