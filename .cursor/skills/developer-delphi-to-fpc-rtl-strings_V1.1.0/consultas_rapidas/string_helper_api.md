# TStringHelper — Tabela Completa de Métodos e Propriedades

## Propriedades

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `Length` | `Integer` | Número de caracteres (base 0 para index) |
| `Chars[I]` | `Char` | Acesso por índice (base 0), leitura/escrita |
| `IsEmpty` | `Boolean` | True se Length = 0 |

---

## Verificação / Busca

| Método | Retorno | Descrição |
|--------|---------|-----------|
| `Contains(S)` | `Boolean` | Verifica presença (case-sensitive) |
| `StartsWith(S)` | `Boolean` | Começa com S (case-sensitive) |
| `StartsWith(S, IgnoreCase)` | `Boolean` | Com controle de case |
| `EndsWith(S)` | `Boolean` | Termina com S |
| `EndsWith(S, IgnoreCase)` | `Boolean` | Com controle de case |
| `IndexOf(S)` | `Integer` | Posição base 0; -1 se não encontrado |
| `IndexOf(S, StartIndex)` | `Integer` | Busca a partir de StartIndex |
| `IndexOf(C: Char)` | `Integer` | Por caractere |
| `IndexOfAny(Chars)` | `Integer` | Primeiro char de um conjunto |
| `LastIndexOf(S)` | `Integer` | Última ocorrência |
| `LastIndexOf(S, StartIndex)` | `Integer` | Busca retroativa |
| `CountChar(C)` | `Integer` | Conta ocorrências do caractere |

---

## Transformação

| Método | Retorno | Descrição |
|--------|---------|-----------|
| `ToLower` | `string` | Minúsculas |
| `ToUpper` | `string` | Maiúsculas |
| `Trim` | `string` | Remove espaços nas duas extremidades |
| `TrimLeft` | `string` | Remove espaços à esquerda |
| `TrimRight` | `string` | Remove espaços à direita |
| `Trim(Chars)` | `string` | Remove chars específicos |
| `TrimLeft(Chars)` | `string` | Remove chars específicos |
| `TrimRight(Chars)` | `string` | Remove chars específicos |
| `Replace(Old, New)` | `string` | Substitui todas as ocorrências |
| `Replace(Old, New, Flags)` | `string` | Com `rfIgnoreCase`, `rfReplaceAll` |
| `PadLeft(Width)` | `string` | Preenche com espaços à esquerda |
| `PadLeft(Width, PadChar)` | `string` | Preenche com caractere específico |
| `PadRight(Width)` | `string` | Preenche com espaços à direita |
| `PadRight(Width, PadChar)` | `string` | Preenche com caractere específico |
| `Substring(StartIndex)` | `string` | Do índice até o fim (base 0) |
| `Substring(StartIndex, Length)` | `string` | Trecho com comprimento |

---

## Divisão / União

| Método | Retorno | Descrição |
|--------|---------|-----------|
| `Split(Delimiters)` | `TArray<string>` | Divide por array de chars |
| `Split(Delimiters, Count)` | `TArray<string>` | Com limite de partes |
| `Split(Delimiters, Options)` | `TArray<string>` | Com `TStringSplitOptions` |
| `string.Join(Sep, Values)` | `string` | *(class method)* Une array |
| `string.Join(Sep, Values, Start, Count)` | `string` | Faixa do array |

**TStringSplitOptions:**
- `TStringSplitOptions.None` — mantém strings vazias
- `TStringSplitOptions.ExcludeEmpty` — remove strings vazias

---

## Comparação / Conversão

| Método | Retorno | Descrição |
|--------|---------|-----------|
| `string.Compare(A, B)` | `Integer` | Compara (locale-aware) |
| `string.Compare(A, B, IgnoreCase)` | `Integer` | Com controle case |
| `string.CompareOrdinal(A, B)` | `Integer` | Ordinal, sem locale |
| `ToBoolean` | `Boolean` | Converte '0'/'1'/'true'/'false' |
| `ToInteger` | `Integer` | StrToInt |
| `ToInt64` | `Int64` | StrToInt64 |
| `ToDouble` | `Double` | StrToFloat |
| `ToSingle` | `Single` | StrToFloat |
| `ToExtended` | `Extended` | StrToFloat |
| `QuotedString` | `string` | Envolve em aspas simples escapadas |
| `DeQuotedString` | `string` | Remove aspas externas |

---

## Char Methods (uso via S.Chars[I])

| Método | Retorno | Descrição |
|--------|---------|-----------|
| `Char.IsLetter(C)` | `Boolean` | É letra |
| `Char.IsDigit(C)` | `Boolean` | É dígito 0-9 |
| `Char.IsLetterOrDigit(C)` | `Boolean` | Letra ou dígito |
| `Char.IsUpper(C)` | `Boolean` | Maiúscula |
| `Char.IsLower(C)` | `Boolean` | Minúscula |
| `Char.IsWhiteSpace(C)` | `Boolean` | Espaço/tab/newline |
| `Char.IsPunctuation(C)` | `Boolean` | Pontuação |
| `Char.ToUpper(C)` | `Char` | Converter para maiúscula |
| `Char.ToLower(C)` | `Char` | Converter para minúscula |
| `C.IsLetter` | `Boolean` | Helper de instância |
| `C.IsInArray([...])` | `Boolean` | Está em conjunto |

---

## Funções globais relacionadas (não são helpers)

| Função | Descrição |
|--------|-----------|
| `Copy(S, From, Count)` | Subtring base 1 (legacy) |
| `Delete(var S, From, Count)` | Remove in-place base 1 |
| `Insert(Sub, var S, Pos)` | Insere in-place base 1 |
| `StringOfChar(C, N)` | Cria string com N cópias de C |
| `UpperCase(S)` / `LowerCase(S)` | Legacy (usar ToUpper/ToLower) |
| `Pos(Sub, S)` | Posição base 1 (legacy) |
| `AnsiPos`, `PosEx` | Variantes de Pos |
