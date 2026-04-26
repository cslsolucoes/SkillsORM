# Checklist de Layout FMX — Antes de Publicar uma Tela

## Estrutura e Alinhamento

- [ ] Todos os containers têm `Align` definido (nunca deixar `None` em container principal)
- [ ] Há um container raiz com `Align = Client` dentro do Form/Frame
- [ ] Nenhum container usa `Position.X/Y` manual quando deveria usar `Align`
- [ ] `Padding` e `Margins` usados corretamente (Padding = interno, Margins = externo)
- [ ] `Size.PlatformDefault = False` em controles com tamanho customizado no `.fmx`

## Visual e Cores

- [ ] `Fill.Kind = None` e `Stroke.Kind = None` em containers puramente organizacionais (TLayout)
- [ ] Todos os `TRectangle` decorativos têm `HitTest = False`
- [ ] `XRadius` e `YRadius` consistentes com o design (mesmo valor em elementos similares)
- [ ] Gradientes com `StartPosition` e `StopPosition` configurados (não deixar no padrão)
- [ ] Cores em ARGB hex (`$FF######`) com Alpha = FF (opaco) a menos que transparência seja intencional

## Tipografia

- [ ] `FontFamily` consistente em toda a tela (não misturar fontes)
- [ ] `WordWrap = True` em textos que podem ser longos
- [ ] `AutoSize` desabilitado se o label tem tamanho fixo no layout
- [ ] `TextSettings.HorzAlign` definido explicitamente (não confiar no padrão)

## Animações

- [ ] Animações têm `Duration` razoável (0.2s hover, 0.3s entrada, 0.5s tela — nunca >1s)
- [ ] `TInterpolationType.Quadratic` ou `Linear` para a maioria; `Back`/`Bounce` só para efeito especial
- [ ] Animações OnFinish liberam referência ou fazem cleanup (sem memory leak)
- [ ] Animações de layout (Position, Width, Height) usam `TAnimator.AnimateFloat`, não loop manual

## Efeitos

- [ ] `TShadowEffect` criado em runtime (não design-time) para efeitos em frames dinâmicos
- [ ] `TBlurEffect` usado com moderação (pesado se aplicado a muitos controles simultaneamente)
- [ ] Efeitos têm `Enabled = True` apenas quando necessário (desabilitar em animações de saída)

## Frames e Reutilização

- [ ] Frames reutilizáveis em `.cursor/skills/fmx-frames` ou em pasta de templates do projeto
- [ ] Frames herdam corretamente via `inherited` no `.fmx`
- [ ] `DestruirTudo` chamado antes de recriar frames dinâmicos (evitar duplicação)
- [ ] `CarregarDados` chamado após criar frame, não no constructor

## Performance

- [ ] Controles pesados (TListView com muitos itens, TImage grande) usam lazy-load
- [ ] Nenhum loop manual criando controles onde TListView seria adequado
- [ ] `OnResize` do container raiz como gatilho de lazy-load (RecFundoResize pattern)
- [ ] Sem operações pesadas no `OnPaint` ou `OnResize`

## Responsividade

- [ ] Tela testada em modo portrait e landscape (se mobile)
- [ ] Tela testada com resize da janela (se Windows)
- [ ] Nenhum valor hardcoded de largura que quebre em tela menor
- [ ] ScrollBox envolve conteúdo que pode exceder a altura da tela

## Acessibilidade e UX

- [ ] Feedback visual em ações (hover, click) implementado
- [ ] Estados de loading/erro/vazio considerados e tratados visualmente
- [ ] `TDialogService` usado para confirmações destrutivas (não MessageBox nativo)
- [ ] Tab order configurado para forms com múltiplos TEdit
