# Mapa de Skills FMX — Tabela de Decisão

## Qual micro-skill invocar para cada tarefa?

| Tarefa / Problema | Skill | Arquivo-chave |
|-------------------|-------|---------------|
| Criar container visual com cor e borda | `fmx-containers` | `SKILL.md §3` |
| Alinhar componentes (Top/Bottom/Client/Left/Right) | `fmx-containers` | `consultas_rapidas/alignlayout_tabela.md` |
| Configurar Fill, Stroke, XRadius, Padding, Margins | `fmx-containers` | `SKILL.md §2-3` |
| Tipografia: TLabel, TText, FontFamily, WordWrap | `fmx-containers` | `SKILL.md §4` |
| Layout responsivo ao resize | `fmx-containers` | `exemplos/responsive_layout.pas` |
| Animar posição, tamanho, opacidade | `fmx-animations` | `SKILL.md §1` |
| Animar cor (Fill.Color, Stroke.Color) | `fmx-animations` | `exemplos/animacoes_cor.pas` |
| Escolher interpolação (Back, Bounce, Elastic…) | `fmx-animations` | `consultas_rapidas/interpolacoes_tabela.md` |
| Animação declarativa no .fmx (design-time) | `fmx-animations` | `exemplos/animacoes_declarativas.pas` |
| Hover color em botão ou card | `fmx-animations` | `exemplos/hover_animation.pas` |
| Transição entre abas/telas | `fmx-animations` | `exemplos/tab_switch_animation.pas` |
| Lazy-load de controles ao ficar visível | `fmx-animations` | `exemplos/lazy_load_pattern.pas` |
| Sombra (TShadowEffect) | `fmx-effects` | `SKILL.md §1` |
| Desfoque / fundo fosco (TBlurEffect) | `fmx-effects` | `exemplos/blur_effect.pas` |
| Brilho / glow em botão destaque | `fmx-effects` | `exemplos/glow_effect.pas` |
| Reflexo de elemento | `fmx-effects` | `exemplos/reflexo_effect.pas` |
| Overlay semitransparente (modal background) | `fmx-effects` | `templates/TEMPLATE_overlay_fosco.pas` |
| TMultiView (drawer lateral, sidebar) | `fmx-components` | `SKILL.md §2` |
| LiveBindings (TBindingsList, TLinkControlToField) | `fmx-components` | `exemplos/livebindings_basico.pas` |
| TListView com itens customizados | `fmx-components` | `exemplos/listview_custom.pas` |
| TArc como gráfico de progresso circular | `fmx-components` | `exemplos/progressbar_arc.pas` |
| TDialogService (confirmação, alerta, cross-platform) | `fmx-components` | `exemplos/dialogs_fmx.pas` |
| TEdit, TMemo, TComboBox, TDateEdit | `fmx-components` | `exemplos/edit_components.pas` |
| Criar TFrame reutilizável | `fmx-frames` | `SKILL.md §1` |
| Herança visual de frame (Object Repository) | `fmx-frames` | `exemplos/frame_heranca.pas` |
| Passar parâmetros ao frame | `fmx-frames` | `exemplos/frame_parametros.pas` |
| Frame modal com CarregarDados auto-map | `fmx-frames` | `exemplos/frame_modal.pas` |
| Padrão DestruirTudo (limpar frames filhos) | `fmx-frames` | `exemplos/frame_destruir_tudo.pas` |
| Drag de form sem titlebar | `fmx-patterns` | `exemplos/drag_sem_titlebar.pas` |
| TStyleBook, trocar tema Dark/Light | `fmx-patterns` | `exemplos/tema_dark_light.pas` |
| Arc progress chart (padrão GestorERP) | `fmx-patterns` | `exemplos/arcprogress_chart.pas` |
| CRUD completo (listagem + modal + delete) | `fmx-patterns` | `templates/TEMPLATE_crud_completo.pas` |

## Prefixo de skill canônico

Todas as micro-skills desta família usam o prefixo:
```
developer-delphi-fmx-<especialidade>_V1.0.0
```

## Ordem de leitura recomendada para dominar FMX

1. `fmx-containers` — fundamentos de layout (obrigatório primeiro)
2. `fmx-animations` — movimento e feedback visual
3. `fmx-effects` — polish e acabamento visual
4. `fmx-components` — componentes funcionais
5. `fmx-frames` — reutilização e composição
6. `fmx-patterns` — padrões de produção completos
