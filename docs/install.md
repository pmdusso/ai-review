# Instalação e atualização em VMs

Este guia prepara uma VM para usar `ai-review` como comando global e para autenticar os agentes usados pelo fan-out.

O fluxo recomendado é:

1. instalar runtimes e CLIs;
2. provisionar credenciais sem depender de browser na VM;
3. clonar este repo;
4. criar um symlink para `ai-review`;
5. validar com `--dry-run` e um review pequeno.

## Instalação do `ai-review`

Clone o repo e exponha o script no `PATH`:

```bash
# Método recomendado (CLI + templates + skills):
./scripts/install.sh

# Sem symlinks de skills (só CLI + templates):
./scripts/install.sh --no-skills

# Ou manualmente:
git clone https://github.com/pmdusso/ai-review ~/code/shared/ai-review
mkdir -p ~/.local/bin
ln -sf ~/code/shared/ai-review/ai-review ~/.local/bin/ai-review
```

Por padrão, `install.sh` também cria:

| Destino | Aponta para |
|---------|-------------|
| `~/.agents/skills/ai-review` | checkout do repo |
| `~/.claude/skills/ai-review` | `~/.agents/skills/ai-review` |
| `~/.codex/skills/ai-review` | `~/.agents/skills/ai-review` |

Garanta que `~/.local/bin` está no `PATH`:

```bash
printf '%s\n' 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Valide:

```bash
ai-review --help
ai-review --version
ai-review --list-agents
```

Atualize a VM com:

```bash
git -C ~/code/shared/ai-review pull --ff-only
# ou: AI_REVIEW_INSTALL_DIR=~/code/shared/ai-review ./scripts/install.sh
```

## Instalação em agentes

Este repo também empacota instruções para agentes:

- `SKILL.md`: compatível com Codex Skills, Claude Code Skills e `~/.agents/skills`.
- `gemini-extension.json`, `GEMINI.md` e `commands/ai-review.toml`: compatíveis com Gemini CLI Extensions.

O `./scripts/install.sh` já instala as skills Claude/Codex/agents (use `--no-skills` para pular). Os passos abaixo são o equivalente manual.

### Codex Skill

Para instalar localmente por symlink:

```bash
mkdir -p ~/.agents/skills ~/.codex/skills
ln -sfn ~/code/shared/ai-review ~/.agents/skills/ai-review
ln -sfn ~/.agents/skills/ai-review ~/.codex/skills/ai-review
```

Depois reinicie a sessão do Codex para recarregar a lista de skills.

Se preferir instalar a partir do GitHub depois que o repo remoto existir:

```bash
python3 "$HOME/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py" \
  --repo pmdusso/ai-review \
  --path .
```

O symlink é melhor para VMs que fazem `git pull`, porque a skill acompanha automaticamente a versão local do script e da documentação.

### Claude Code Skill

Claude Code descobre skills pessoais em `~/.claude/skills/`. O padrão do time é ter a skill canônica em `~/.agents/skills/` e linkar Claude a partir dela:

```bash
mkdir -p ~/.agents/skills ~/.claude/skills
ln -sfn ~/code/shared/ai-review ~/.agents/skills/ai-review
ln -sfn ~/.agents/skills/ai-review ~/.claude/skills/ai-review
```

Depois reinicie a sessão do Claude Code. Para verificar, pergunte dentro do Claude:

```text
List all available Skills
```

Com isso, pedidos como "revise este plano com ai-review" ou "rode uma revisão multi-agente deste arquivo" devem acionar a skill automaticamente.

### Gemini CLI Extension

Gemini CLI não usa `SKILL.md`; o equivalente é uma extension. Este repo inclui:

- `gemini-extension.json`: manifesto da extension.
- `GEMINI.md`: contexto curto carregado pela extension.
- `commands/ai-review.toml`: comando `/ai-review`.

Para desenvolvimento ou VMs atualizadas por `git pull`, prefira linkar a extension:

```bash
gemini extensions link ~/code/shared/ai-review
```

Reinicie a sessão do Gemini CLI e valide:

```bash
gemini extensions list
```

Dentro do Gemini CLI, use:

```text
/ai-review docs/ARCHITECTURE.md
```

Se preferir instalar a partir do GitHub depois que o repo remoto existir:

```bash
gemini extensions install https://github.com/pmdusso/ai-review
```

Extensões instaladas por `gemini extensions install` são copiadas para `~/.gemini/extensions`; para receber mudanças depois, rode:

```bash
gemini extensions update ai-review
```

## Setup mínimo vs completo

| Perfil | Dependências | Uso |
|--------|--------------|-----|
| **Mínimo** | `bash`, `jq`, `yq`, 1 agente (`qwen`) | Iteração rápida (`-a fast`) |
| **Completo** | Mínimo + CLIs autenticados: `gemini`, `codex`, `auggie`, `mmx`, `qwen` (+ `claude` opt-in) | Fan-out `default` / `full` |

Instale `yq` (v4+) para config YAML por projeto:

```bash
brew install yq
# Linux: https://github.com/mikefarah/yq#install
```

`yq` só é obrigatório quando existe `~/.config/ai-review/config.yaml` ou `.ai-review/config.yaml`.

Referência completa de flags/config: [`docs/reference.md`](reference.md).

## Dependências base

Os CLIs são majoritariamente Node. Use `nvm` para controlar a versão de Node e instale CLIs globais com `npm`, não com `brew`, quando houver pacote npm.

Versões mínimas conhecidas:

| CLI | Node mínimo |
| --- | --- |
| `gemini` | 20+ |
| `qwen` | 20+ |
| `auggie` | 22+ |
| `codex` | 18+ |
| `claude` | 18+ |
| `mmx` | 18+ |

Na prática, Node 22+ cobre todos os agentes atuais:

```bash
nvm install 22
nvm use 22
npm install -g \
  @google/gemini-cli@latest \
  @openai/codex@latest \
  @anthropic-ai/claude-code@latest \
  @augmentcode/auggie@latest \
  @qwen-code/qwen-code@latest \
  mmx-cli@latest
```

`mmx` também exige `jq` para o `ai-review`, porque o script monta o arquivo JSON de mensagens:

```bash
brew install jq
```

Em Linux sem Homebrew, use o gerenciador do sistema para instalar `jq`.

## Autenticação em VM sem browser

Evite OAuth interativo em VM headless quando houver alternativa por API key, device code ou token exportado. Preferir credenciais por ambiente também facilita recriar VMs.

Nunca commite arquivos de credenciais. Trate os valores abaixo como secrets.

| Agente | Caminho recomendado em VM sem browser | Verificação |
| --- | --- | --- |
| `gemini` | `GEMINI_API_KEY` em `~/.gemini/.env`, ou Vertex AI com service account | `gemini -p "ping" --output-format text` |
| `codex` | `OPENAI_API_KEY` ou `codex login --device-auth` quando disponível na versão instalada | `codex login status` ou `codex exec -m <modelo> "ping"` |
| `auggie` | gerar sessão em máquina com browser e copiar `AUGMENT_SESSION_AUTH` | `auggie account status` |
| `mmx` | `mmx auth login --api-key <token>` | `mmx auth status` |
| `qwen` | OpenAI-compatible API via `~/.qwen/.env`; manter `AI_REVIEW_QWEN_AUTH_TYPE=openai` | `qwen --auth-type openai -p "ping"` |
| `claude` | `ANTHROPIC_API_KEY` para Console/API, ou login OAuth em máquina com browser | `claude auth status --text` |

### Gemini

Para VM sem browser, use uma API key do AI Studio:

```bash
mkdir -p ~/.gemini
chmod 700 ~/.gemini
cat > ~/.gemini/.env <<'EOF'
GEMINI_API_KEY="substitua"
EOF
chmod 600 ~/.gemini/.env
```

Para Vertex AI, use `GOOGLE_GENAI_USE_VERTEXAI=true` junto com `GOOGLE_CLOUD_PROJECT`, `GOOGLE_CLOUD_LOCATION` e credencial ADC ou service account.

### Codex

O caminho mais simples em VM é usar API key:

```bash
printf '%s\n' 'export OPENAI_API_KEY="substitua"' >> ~/.zshrc
source ~/.zshrc
```

Se a versão instalada suportar device auth, prefira quando quiser usar login ChatGPT sem abrir browser na VM:

```bash
codex login --device-auth
```

Se `OPENAI_API_KEY` estiver setado, espere que o Codex use essa key para chamadas de API.

### Auggie

Faça login uma vez em uma máquina com browser:

```bash
auggie login
auggie token print
```

Copie o JSON de sessão para a VM como secret:

```bash
printf '%s\n' 'export AUGMENT_SESSION_AUTH='\''<session-json>'\''' >> ~/.zshrc
source ~/.zshrc
```

Alternativamente, passe o JSON por execução com `--augment-session-json`.

### MiniMax `mmx`

Use API key/token plan:

```bash
mmx auth login --api-key <token>
mmx auth status
```

O `ai-review` usa `mmx text chat --non-interactive`, então não precisa de sessão interativa depois do login.

### Qwen

O `ai-review` chama Qwen com `--auth-type "$AI_REVIEW_QWEN_AUTH_TYPE"`, cujo default é `openai`. Em VM headless, configure um provedor OpenAI-compatible:

```bash
mkdir -p ~/.qwen
chmod 700 ~/.qwen
cat > ~/.qwen/.env <<'EOF'
OPENAI_API_KEY="substitua"
OPENAI_BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1"
OPENAI_MODEL="qwen3-coder-plus"
EOF
chmod 600 ~/.qwen/.env
```

Se usar outro gateway compatível com OpenAI, ajuste `OPENAI_BASE_URL` e `OPENAI_MODEL`.

### Claude

Para VM sem browser, use API key do Anthropic Console:

```bash
printf '%s\n' 'export ANTHROPIC_API_KEY="substitua"' >> ~/.zshrc
source ~/.zshrc
```

Atenção: `ANTHROPIC_API_KEY` tem precedência sobre login por assinatura Claude Pro/Max/Team/Enterprise em sessões CLI. Isso pode gerar cobrança por API mesmo quando existe uma assinatura logada.

## Validação

Depois de instalar e autenticar, rode um teste sem enviar conteúdo:

```bash
ai-review --list-agents
printf '%s\n' "Teste pequeno" | ai-review --dry-run -s "Responda apenas OK."
```

Depois rode um agente isolado antes do fan-out completo:

```bash
printf '%s\n' "Teste pequeno" | ai-review -a gemini -s "Responda apenas OK."
printf '%s\n' "Teste pequeno" | ai-review -a qwen -s "Responda apenas OK."
```

Quando todos os CLIs estiverem OK:

```bash
printf '%s\n' "Teste pequeno" | ai-review -s "Responda apenas OK."
```

## Operação entre várias VMs

Para atualizar todas as VMs, rode:

```bash
git -C ~/code/shared/ai-review pull --ff-only
nvm use 22
npm install -g \
  @google/gemini-cli@latest \
  @openai/codex@latest \
  @anthropic-ai/claude-code@latest \
  @augmentcode/auggie@latest \
  @qwen-code/qwen-code@latest \
  mmx-cli@latest
```

Alguns CLIs têm auto-update ou comando próprio. Use o comando nativo quando ele for a recomendação do fornecedor, por exemplo `claude update`, `mmx update` ou `auggie upgrade`.

## Referências oficiais

- Gemini CLI: https://google-gemini.github.io/gemini-cli/docs/get-started/
- Gemini CLI Extensions: https://google-gemini.github.io/gemini-cli/docs/extensions/
- Gemini custom commands: https://google-gemini.github.io/gemini-cli/docs/cli/custom-commands.html
- Gemini auth/headless: https://google-gemini.github.io/gemini-cli/docs/get-started/authentication.html
- Codex CLI: https://help.openai.com/en/articles/11096431-openai-codex-ci-getting-started
- Codex auth: https://help.openai.com/en/articles/11381614-api-codex-cli-and-sign-in-with-chatgpt
- Claude Code setup: https://docs.anthropic.com/en/docs/claude-code/getting-started
- Claude Code Skills: https://docs.claude.com/en/docs/claude-code/skills
- Claude Code auth/env vars: https://code.claude.com/docs/en/authentication
- Auggie install/auth: https://docs.augmentcode.com/cli/setup-auggie/install-auggie-cli
- Auggie automation/auth: https://docs.augmentcode.com/cli/setup-auggie/authentication
- MiniMax CLI: https://github.com/MiniMax-AI/cli
- Qwen Code quickstart/auth: https://qwenlm.github.io/qwen-code-docs/en/users/quickstart/
- Qwen Code auth: https://qwenlm.github.io/qwen-code-docs/en/cli/authentication/
