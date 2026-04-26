---
name: iniciar
description: Inicializa o projecto quando nao existe .dpr/.lpr na raiz — aciona o fluxo interativo (P1..P9) e gera build config via Bootstrap-BuildConfig.ps1.
---

# /iniciar

Inicializa o projecto quando ainda nao existe `*.dpr` nem `*.lpr` na raiz.

## Escopo

Invocar quando:

- O usuario escrever `/iniciar`, **ou**
- Esta for a primeira mensagem da sessao e nao existir `*.dpr` nem `*.lpr` na raiz (excluindo `*.template`).

O comando deve priorizar o bootstrap do projecto **antes** de qualquer outra tarefa.

## Skills invocadas

| Skill | Quando/Por que e chamada |
|-------|--------------------------|
| *(nenhuma)* | Este comando opera via scripts de bootstrap (`.cursor/scripts/*.ps1`) |

## Parâmetros

| Parâmetro | Tipo | Padrao | Descrição |
|-----------|------|--------|-----------|
| *(nenhum)* | — | — | O alvo e o workspace atual |

## Comportamento

1. **Validar espelhos**: executar `Bootstrap-MirrorSymlinks.ps1 -ValidateOnly`. Se falhar por falta de privilegios de Administrador, informar e **parar**.
2. **Detectar projecto**: procurar `*.dpr`/`*.lpr` na raiz.
3. **Se existir projecto**: executar `Bootstrap-BuildConfig.ps1 -ValidateOnly` e, se necessario, gerar os arquivos de build ausentes.
4. **Se NAO existir projecto**: iniciar o fluxo interativo (uma pergunta por mensagem, aguardando resposta):
   - P1 Nome do projecto
   - P2 Pasta de documentacao
   - P3 Framework (Delphi / FPC / Ambos)
   - P4 Unit do formulario principal (opcional)
   - P5 Defines adicionais (opcional)
   - P6 Versao RAD Studio (opcional; se Delphi)
   - P7/P8/P9 Paths FPC/Lazarus/OPM (opcional; se FPC)
5. **Gerar arquivos**: executar `.cursor/scripts/Bootstrap-BuildConfig.ps1` com os parametros correspondentes a P1..P9.
6. **Confirmar no chat**: listar os arquivos gerados e indicar como compilar (Delphi/FPC) conforme o toolchain do projecto.

## Exemplos de uso

```text
# Iniciar o projecto no workspace atual
/iniciar
```

## Saida

- Projeto criado (quando ausente) e build configs materializados (quando faltantes).
- Confirmacao no chat com lista de arquivos gerados e comando(s) de compilacao.

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (24/04/2026): Versao inicial do comando `/iniciar` — gatilho de bootstrap e fluxo interativo P1..P9.
