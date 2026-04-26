# TRegEx — Flags (TRegExOptions) e Referência Rápida

## Flags disponíveis

```pascal
type TRegExOption = (
  roNone,               // sem flag especial
  roIgnoreCase,         // case-insensitive (i)
  roMultiline,          // ^ e $ batem em cada linha, não só no início/fim (m)
  roExplicitCapture,    // só grupos nomeados capturam (?<nome>...) (n)
  roCompiled,           // compila o padrão para execução mais rápida
  roSingleline,         // '.' bate também em newlines (s)
  roIgnorePatternSpace, // ignora espaços e comentários no padrão (x)
  roECMAScript,         // modo compatível ECMAScript
  roCultureInvariant    // comparação invariante de cultura
);
TRegExOptions = set of TRegExOption;
```

---

## Exemplos de uso

```pascal
// Case-insensitive
TRegEx.IsMatch('DELPHI', 'delphi', [roIgnoreCase]);  // True

// Multiline — ^ e $ batem em início/fim de cada linha
var ML := 'linha1'#10'linha2'#10'linha3';
var MC := TRegEx.Matches(ML, '^linha\d$', [roMultiline]);
// MC.Count = 3  (cada linha bate com o padrão)

// Sem roMultiline — ^ e $ só batem no início/fim da string toda
MC := TRegEx.Matches(ML, '^linha\d$');
// MC.Count = 0  (a string tem newlines no meio)

// SingleLine — '.' inclui newlines
var S := 'início'#10'meio'#10'fim';
TRegEx.IsMatch(S, 'início.*fim', [roSingleline]);  // True
TRegEx.IsMatch(S, 'início.*fim');                   // False (sem roSingleline, '.' para em \n)

// IgnorePatternSpace — comentários no padrão
var Pat := '(\d{3})  # DDD'#10'[-\s]?         # separador'#10'(\d{4,5}-\d{4})  # número';
TRegEx.IsMatch('(11) 99999-8888', Pat, [roIgnorePatternSpace, roIgnoreCase]);

// Combinando flags
TRegEx.IsMatch(Texto, Padrao, [roIgnoreCase, roMultiline]);
```

---

## Âncoras e asserções

| Símbolo | Significado |
|---------|-------------|
| `^` | Início da string (ou linha com roMultiline) |
| `$` | Fim da string (ou linha com roMultiline) |
| `\b` | Fronteira de palavra |
| `\B` | Não-fronteira de palavra |
| `\A` | Início absoluto da string (ignorando roMultiline) |
| `\Z` | Fim absoluto da string |
| `(?=...)` | Lookahead positivo |
| `(?!...)` | Lookahead negativo |
| `(?<=...)` | Lookbehind positivo |
| `(?<!...)` | Lookbehind negativo |

---

## Classes de caracteres

| Padrão | Equivale a |
|--------|-----------|
| `\d` | `[0-9]` — dígito |
| `\D` | `[^0-9]` — não-dígito |
| `\w` | `[a-zA-Z0-9_]` — word char |
| `\W` | `[^a-zA-Z0-9_]` |
| `\s` | `[ \t\n\r\f\v]` — whitespace |
| `\S` | Não-whitespace |
| `.` | Qualquer char exceto `\n` (sem roSingleline) |
| `[abc]` | Classe: a, b ou c |
| `[^abc]` | Negação: não a, b, nem c |
| `[a-z]` | Intervalo |
| `\p{L}` | Letra Unicode |
| `\p{Lu}` | Letra maiúscula Unicode |

---

## Quantificadores

| Padrão | Significado |
|--------|-------------|
| `*` | 0 ou mais (greedy) |
| `+` | 1 ou mais (greedy) |
| `?` | 0 ou 1 |
| `{n}` | Exatamente n |
| `{n,}` | n ou mais |
| `{n,m}` | Entre n e m |
| `*?` | 0 ou mais (lazy/non-greedy) |
| `+?` | 1 ou mais (lazy) |
| `??` | 0 ou 1 (lazy) |

---

## Grupos

| Padrão | Tipo |
|--------|------|
| `(...)` | Grupo de captura (indexado) |
| `(?:...)` | Grupo sem captura |
| `(?P<nome>...)` | Grupo nomeado (Python style) |
| `(?<nome>...)` | Grupo nomeado (.NET style) |
| `(?(n)sim\|não)` | Condicional |

---

## TRegEx vs instância TRegEx

```pascal
// Classe estática — cria RE novo a cada chamada (simples, não reutiliza compilado)
TRegEx.IsMatch(S, Pattern);
TRegEx.Match(S, Pattern);
TRegEx.Matches(S, Pattern);
TRegEx.Replace(S, Pattern, Repl);
TRegEx.Split(S, Pattern);

// Instância — reutiliza o padrão compilado (melhor para loops)
var RE := TRegEx.Create(Pattern, [roIgnoreCase]);
for var Item in Lista do
  if RE.IsMatch(Item) then ...
// RE não precisa de Free (record)
```

---

## Padrões comuns prontos

```pascal
// E-mail
'[\w.+-]+@[\w-]+\.[a-z]{2,}'

// CPF formatado
'\d{3}\.\d{3}\.\d{3}-\d{2}'

// CNPJ formatado
'\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}'

// CEP
'\d{5}-\d{3}'

// Telefone brasileiro (DDD + número)
'\(?\d{2}\)?\s?9?\d{4}[-\s]?\d{4}'

// Data ISO 8601
'\d{4}-\d{2}-\d{2}'

// URL básica
'https?://[\w.-]+(\.[a-z]{2,})+'

// IPv4
'(\d{1,3}\.){3}\d{1,3}'

// Senha forte (8+ chars, maiúscula, minúscula, dígito)
'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$'

// Identificador Delphi
'[a-zA-Z_]\w*'
```
