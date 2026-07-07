---
description: Solicitar feedback de múltiplos agentes de IA (Gemini, GPT-5.5, Claude, MiniMax, Qwen Coder) sobre um arquivo ou decisão técnica usando ai-review (disponível no PATH)
---

# AI Review — Feedback de múltiplos agentes

Use este workflow quando quiser obter feedback de múltiplos LLMs sobre um documento, decisão técnica, trecho de código ou artefato do projeto.

## Pré-requisitos

CLIs instalados e autenticados: `gemini`, `codex`, `auggie`, `mmx`, `qwen` para o fan-out default. `claude` é opcional e entra via `-a claude`, `-a default+claude` ou `-a all`.

O conteúdo é enviado para provedores externos. Não envie secrets, dados pessoais sensíveis ou conteúdo regulado sem autorização explícita.

## Passos

1. **Identificar o alvo do review.** Pergunte ao usuário qual arquivo ou tema ele quer revisar, caso não tenha sido especificado. Inspecione o arquivo o suficiente para montar contexto e evitar enviar material desnecessário.

2. **Construir o prompt.** Monte:
   - Um **system instruction** com o papel do revisor.
   - Um **prompt prefix** opcional com pergunta específica, foco ou contexto adicional.
   - Prompt em **português brasileiro**, salvo pedido em outro idioma.
   - Para documentos grandes, prefira recortar o alvo ou revisar por seções.

3. **Confirmar com o usuário.** Mostre o system instruction, agentes escolhidos e um resumo do conteúdo antes de executar.

4. **Executar o script.**

```bash
ai-review \
  -f <ARQUIVO> \
  -s "<SYSTEM_INSTRUCTION>" \
  -p "<PROMPT_PREFIX_OPCIONAL>"
```

Para rodar apenas agentes específicos ou aliases:

```bash
ai-review -f docs/ARCHITECTURE.md -s "Revise." -a qwen,gemini
ai-review -f docs/ARCHITECTURE.md -s "Revise." -a default+claude
ai-review -f docs/ARCHITECTURE.md --dry-run -a all
```

Agentes disponíveis:

- `default` → `gemini,codex,auggie,mmx,qwen`
- `default+claude` ou `all` → default + `claude`
- `claude` isolado continua opt-in

Modelos default:

- `gemini` → `gemini-3.1-pro-preview`
- `codex` → `gpt-5.5`
- `auggie` → `opus4.7`
- `mmx` → `MiniMax-M2.7`
- `qwen` → `qwen3-coder-plus`
- `claude` → `claude-fable-5`

Overrides por ambiente:

- `AI_REVIEW_GEMINI_MODEL`
- `AI_REVIEW_CODEX_MODEL`
- `AI_REVIEW_AUGGIE_MODEL`
- `AI_REVIEW_MMX_MODEL`
- `AI_REVIEW_QWEN_MODEL`
- `AI_REVIEW_CLAUDE_MODEL`
- `AI_REVIEW_TIMEOUT_SECONDS`
- `AI_REVIEW_QWEN_AUTH_TYPE` para o `--auth-type` do Qwen Code; default `openai`

Flags úteis:

- `--list-agents` mostra agentes, modelos e env vars.
- `--dry-run` valida seleção e tamanho do prompt sem enviar conteúdo.
- `--redact` substitui segredos detectados por `[REDACTED]` e prossegue sem abortar ou pedir confirmação.
- `-o, --output <path>` salva o relatório unificado final formatado em arquivo Markdown local.
- `-t, --template <name>` carrega uma instrução de sistema pré-configurada em arquivo de template.
- `-d, --diff` extrai e revisa cirurgicamente o git diff local do arquivo, combinando com seu contexto.
- `--keep-results` preserva stdout/stderr/status temporários.
- `--allow-secrets` só deve ser usado quando o envio de possíveis secrets for intencional.

5. **Apresentar os resultados.** O script formata a saída por agente e inclui status/modelo. Preserve falhas e stderr resumido na síntese.

6. **Sintetizar.** Destaque:
   - **Consenso** — pontos que a maioria concorda.
   - **Divergências** — opiniões conflitantes.
   - **Ações sugeridas** — lista priorizada de melhorias.

7. **Pergunte ao usuário** se deseja aplicar alguma das sugestões diretamente no arquivo.

## Dicas

- Também aceita stdin: `cat docs/PRD.md | ai-review -s "Revise este PRD."`
- Para revisão focada em código, `-a qwen` traz só o code-specialist e evita a latência do fan-out.
- `-s` é respeitado por todos os agentes, mas nem todos os CLIs têm system prompt nativo. Claude, Qwen e MiniMax recebem system nativo; Gemini, Codex e Auggie recebem a instrução embutida no prompt de revisão.
- O script usa modos read-only/plan quando o CLI oferece essa opção e remove o bypass perigoso do Codex.
