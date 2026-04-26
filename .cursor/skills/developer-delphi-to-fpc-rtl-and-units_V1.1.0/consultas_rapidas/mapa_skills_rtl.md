# Mapa de Skills RTL — Quando Usar Cada Uma

## Árvore de decisão

```
Preciso trabalhar com dados?
│
├─► Estrutura de dados em memória?
│   │
│   ├─► Lista ordenável, iterável          → rtl-collections (TList<T>)
│   ├─► Lookup por chave O(1)             → rtl-collections (TDictionary)
│   ├─► Lista de objetos com auto-free    → rtl-collections (TObjectList)
│   ├─► Fila FIFO (proc em ordem)         → rtl-collections (TQueue)
│   ├─► Pilha LIFO (undo, DFS)            → rtl-collections (TStack)
│   ├─► Lista sempre ordenada             → rtl-collections (TSortedList)
│   └─► Transformações pipeline           → rtl-collections (linq_style)
│
├─► Arquivo ou I/O?
│   │
│   ├─► Criar/ler arquivo texto           → rtl-streams-io (TStreamReader/Writer)
│   ├─► Arquivo binário (bytes/registros) → rtl-streams-io (TBinaryWriter/Reader)
│   ├─► Buffer em memória (sem arquivo)   → rtl-streams-io (TMemoryStream)
│   ├─► Copiar entre streams              → rtl-streams-io (CopyFrom)
│   ├─► Caminhos de arquivo (TPath)       → rtl-streams-io (TPath)
│   ├─► Operações de alto nível           → rtl-streams-io (TFile, TDirectory)
│   └─► Encoding/BOM de arquivo          → rtl-streams-io (stream_encoding)
│
└─► Texto / String?
    │
    ├─► Busca/transformação simples       → rtl-strings (TStringHelper)
    ├─► Concatenação em loop (performance)→ rtl-strings (TStringBuilder)
    ├─► Formatação com especificadores    → rtl-strings (Format/FormatFloat)
    ├─► Validação/extração com padrão     → rtl-strings (TRegEx)
    ├─► Encoding de string (UTF-8/ANSI)   → rtl-strings (string_encoding)
    └─► Conversão StrToInt/FloatToStr     → rtl-strings (string_conversion)
```

---

## Tabela de decisão rápida

| Tenho... | Quero... | Skill → Arquivo |
|----------|---------|-----------------|
| `TList<TProduto>` | Ordenar por preço | rtl-collections → `tlist_generica.pas` |
| Lista de clientes | Buscar por ID em O(1) | rtl-collections → `tdictionary.pas` |
| Lista de objetos | Auto-free ao remover | rtl-collections → `tobjectlist.pas` |
| Mensagens a processar | FIFO garantida | rtl-collections → `tqueue_tstack.pas` |
| Histórico de ações | LIFO (undo) | rtl-collections → `tqueue_tstack.pas` |
| Catálogo ordenado | Busca binária | rtl-collections → `tsortedlist.pas` |
| `TList<T>` | WHERE/SELECT | rtl-collections → `linq_style.pas` |
| — | Gravar texto em arquivo | rtl-streams-io → `file_stream.pas` |
| — | Ler CSV linha a linha | rtl-streams-io → `file_stream.pas` |
| — | Serializar records binários | rtl-streams-io → `binary_io.pas` |
| — | Manipular paths cross-platform | rtl-streams-io → `ioutils.pas` |
| Arquivo com BOM | Detectar encoding | rtl-streams-io → `stream_encoding.pas` |
| String | Verificar/extrair | rtl-strings → `string_helpers.pas` |
| Loop de concatenação | Performance | rtl-strings → `string_builder.pas` |
| — | Gerar relatório formatado | rtl-strings → `format_strings.pas` |
| Campo texto | Validar CPF/email | rtl-strings → `regex_delphi.pas` |
| `'3,14'` (string) | Converter para Double | rtl-strings → `string_conversion.pas` |

---

## Combinações frequentes

### Ler arquivo CSV → carregar em dicionário
```
1. rtl-streams-io/file_stream.pas → TStreamReader linha a linha
2. rtl-strings/string_helpers.pas → Split por ','
3. rtl-collections/tdictionary.pas → AddOrSetValue para cada linha
```

### Filtrar lista → formatar relatório → salvar arquivo
```
1. rtl-collections/linq_style.pas → Where + OrderBy
2. rtl-strings/string_builder.pas → montar texto formatado
3. rtl-streams-io/file_stream.pas → TStreamWriter para salvar
```

### Parsear log → agrupar erros
```
1. rtl-streams-io/file_stream.pas → ler arquivo linha a linha
2. rtl-strings/regex_delphi.pas → extrair nível/mensagem com grupos
3. rtl-collections/tdictionary.pas + linq_style.pas → GroupBy por nível
```
