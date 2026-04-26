# Assets da Microsoft Store — Especificacoes Completas

> **AVISO:** Especificacoes mudam com atualizacoes da Store.
> Verificar sempre em: `https://learn.microsoft.com/windows/apps/publish/store-listings`

---

## Icones do App (Obrigatorios)

| Asset | Dimensoes | Formato | Fundo | Obrigatorio |
|-------|-----------|---------|-------|-------------|
| Icone da Store | 300×300 px | PNG | Transparente ou solido | **Sim** |
| Icone do app (legado) | 50×50 px | PNG | Qualquer | Opcional |
| Logo pequeno | 71×71 px | PNG | Transparente | Opcional |
| Logo quadrado | 150×150 px | PNG | Transparente | Opcional |
| Logo largo | 310×150 px | PNG | Transparente | Opcional |

### Diretrizes para icone 300×300

- Fundo: cor solida ou gradiente (evitar transparente total — pode sumir no tema claro)
- Margem de seguracao: 10% de cada lado (30px) sem elementos importantes
- Sem texto se possivel — deve ser reconhecivel em tamanho pequeno
- Formato de arquivo: PNG-24 (sem JPEG — perde qualidade com compressao)

---

## Screenshots (Obrigatorias)

### Desktop (obrigatorio — minimo 1)

| Parametro | Especificacao |
|-----------|--------------|
| Quantidade minima | 1 |
| Quantidade maxima | 10 |
| Dimensao minima | 1366×768 px (landscape) ou 768×1366 px (portrait) |
| Dimensao maxima | 3840×2160 px |
| Formato | PNG ou JPEG |
| Tamanho maximo | 50 MB por imagem |

### Mobile / Tablet (opcional)

| Parametro | Especificacao |
|-----------|--------------|
| Quantidade maxima | 10 |
| Dimensao minima | 768×1366 px (portrait) |
| Dimensao maxima | 3840×2160 px |
| Formato | PNG ou JPEG |

### Xbox (opcional)

| Parametro | Especificacao |
|-----------|--------------|
| Formato recomendado | 3480×2160 px ou 1920×1080 px |
| Aspecto | 16:9 |

### Dicas para Screenshots de Qualidade

1. Usar resolucao Full HD (1920×1080) ou 4K para melhor qualidade
2. Capturar com DPI do Windows a 100% (nao escalonado)
3. Mostrar a funcionalidade principal na primeira screenshot
4. Evitar cursors do mouse visivel nas capturas
5. Dados de exemplo devem ser realistas (nao "Empresa Teste LTDA")
6. Se o UI tem temas claro/escuro: incluir screenshots de ambos

---

## Arte Promocional

| Asset | Dimensoes | Formato | Uso | Obrigatorio |
|-------|-----------|---------|-----|-------------|
| Hero art | 1920×1080 px | PNG ou JPEG | Destaque editorial, featured placement | Recomendado |
| Imagem promocional quadrada | 1000×1000 px | PNG ou JPEG | Promocioes da Store | Opcional |

### Sobre o Hero Art (1920×1080)

- Manter 924px centrais livres de elementos importantes (bordas podem ser cortadas)
- Nao incluir texto do nome do app (a Store sobrepora o titulo automaticamente)
- Fundo deve ter boa aparencia em versao escurecida (Store pode aplicar overlay)
- Formato recomendado: PNG para arte com graficos, JPEG para fotografias

---

## Trailer / Video

| Parametro | Especificacao |
|-----------|--------------|
| Duracao recomendada | 30 a 90 segundos |
| Formato | MP4, MOV |
| Resolucao recomendada | 1920×1080 px |
| Alternativa | URL do YouTube ou Vimeo |
| Thumbnail | 1920×1080 px PNG (opcional; extraida automaticamente se omitida) |

---

## Resumo Rapido — Assets Minimos para Publicar

```
OBRIGATORIO:
  [x] Icone Store: 300×300 PNG
  [x] Screenshot desktop: 1366×768 PNG (minimo 1)
  [x] Descricao: texto (ate 10.000 chars)
  [x] Notas de versao: texto

FORTEMENTE RECOMENDADO:
  [ ] Hero art: 1920×1080 PNG
  [ ] Screenshots adicionais (ate 10)
  [ ] Logo em multiplos tamanhos

OPCIONAL:
  [ ] Video / trailer
  [ ] Screenshots mobile
  [ ] Screenshots Xbox
```

---

## Tabela de Requisitos por Plataforma

| Plataforma | Screenshot minima | Screenshot maxima | Obrigatorio |
|------------|------------------|------------------|-------------|
| PC / Desktop | 1366×768 | 3840×2160 | Sim |
| Mobile | 768×1366 | 2160×3840 | Nao |
| Xbox | 1920×1080 | 3840×2160 | Nao |
| HoloLens | 1268×720 | 1268×720 | Nao |
| Surface Hub | 1024×768 | 3840×2160 | Nao |
