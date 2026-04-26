---
name: developer-delphi-claudeignore
description: >
  Cria e mantém automaticamente o arquivo .claudeignore em projetos Delphi, ignorando binários
  (.dcu/.exe/.dll/.bpl), compilados por plataforma (Win32/Win64/Android/iOS), configurações de IDE
  (.dof/.cfg/.local/.identcache), temporários e __history/, economizando tokens.
  Ativar quando detectar arquivos .dpr/.dproj/.pas em projeto sem .claudeignore, ou quando
  o usuário mencionar: .claudeignore, ignorar arquivos delphi, economizar tokens,
  arquivos desnecessários, otimizar contexto.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-claudeignore

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | DevOps / Tooling |

## Responsabilidade única

Garantir que todo projeto Delphi tenha um `.claudeignore` adequado, evitando que binários,
compilados e metadados de IDE sejam lidos desnecessariamente.

## When to use

- Projeto Delphi detectado sem `.claudeignore`
- Usuário solicita redução de tokens ou otimização de contexto
- `.claudeignore` existente mas incompleto

## When NOT to use

- Projetos não-Delphi → adaptar manualmente
- Arquivos de código-fonte (`.pas`, `.dfm`, `.dpr`) **nunca** ignorar

---

## §1 — Idioma

Detecte o idioma. pt-BR (padrão) ou en-US. Notificações para o usuário seguem o idioma
detectado; nomes de arquivos e extensões não são traduzidos.

---

## §2 — Protocolo automático

### Passo 1 — Verificar existência
Verificar se `.claudeignore` existe na raiz do projeto.

### Passo 2A — Se NÃO existir
Criar com o conteúdo padrão (§3). Notificar:
- pt-BR: `✅ .claudeignore criado automaticamente — N categorias de arquivos ignorados.`
- en-US: `✅ .claudeignore created automatically — N file categories ignored.`

### Passo 2B — Se JA existir mas incompleto
Comparar com o padrão. Se faltarem entradas relevantes, sugerir atualização:
- pt-BR: `Seu .claudeignore não inclui [X]. Deseja que eu atualize?`
- en-US: `Your .claudeignore is missing [X]. Would you like me to update it?`

### Passo 3 — Nunca ignorar código-fonte
`.pas`, `.dfm`, `.dpr`, `.dpk`, `.inc`, `.fmx` **nunca** no `.claudeignore`.

---

## §3 — Conteúdo padrão do .claudeignore

```
# =============================================
# .claudeignore — Projeto Delphi
# Gerado automaticamente — developer-delphi-claudeignore
# =============================================

# --- Arquivos compilados e binários ---
*.dcu
*.exe
*.dll
*.bpl
*.dcp
*.rsm
*.so
*.dylib
*.apk
*.ipa

# --- Recursos compilados ---
*.res
*.dres

# --- Configuração e metadados de IDE ---
*.dproj
*.dof
*.cfg
*.local
*.identcache
*.projdata
*.tvsconfig
*.dsk

# --- Mapas e debug ---
*.map
*.drc
*.jdbg

# --- Arquivos temporários ---
*.~*
*.bak
*.tmp
*.log

# --- Saídas de compilação por plataforma ---
Win32/
Win64/
Android/
Android64/
iOSDevice32/
iOSDevice64/
iOSSimulator/
OSX64/
OSXARM64/
Linux64/

# --- Histórico e backup de IDE ---
__history/
__recovery/

# --- Controle de versão e dependências ---
.git/
node_modules/
```

---

## §4 — O que NUNCA ignorar

| Extensão | Motivo |
|----------|--------|
| `.pas` | Código-fonte Pascal — leitura principal |
| `.dfm` | Layout de formulários VCL |
| `.dpr` | Arquivo de projeto |
| `.dpk` | Arquivo de pacote |
| `.inc` | Includes — podem conter código relevante |
| `.fmx` | Layout FMX — projetos FireMonkey |

---

## §5 — Checklist de qualidade — .claudeignore

- [ ] `.claudeignore` presente na raiz do projeto
- [ ] Todos os binários Delphi cobertos (`.dcu`, `.exe`, `.dll`, `.bpl`)
- [ ] Pastas de plataforma cobertas (Win32/, Win64/, Android/...)
- [ ] `__history/` incluído
- [ ] Nenhum arquivo de código-fonte (`.pas`, `.dfm`, `.dpr`) ignorado

## Referências cruzadas

- `developer-delphi-coding-workflow` — geração de código novo
- `developer-delphi-project-audit` — auditoria completa do projeto
