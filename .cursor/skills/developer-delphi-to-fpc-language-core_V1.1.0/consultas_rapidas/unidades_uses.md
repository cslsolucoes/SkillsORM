# Estrutura de Units e cláusula uses

## Estrutura completa de uma unit

```pascal
unit MinhaUnit;
// Nenhuma diretiva {$APPTYPE} aqui — isso é só em .dpr

interface

uses
  // Units públicas — exportadas para quem usar esta unit
  System.SysUtils,
  System.Classes,
  MinhaOutraUnit;

const
  MINHA_CONSTANTE = 42;
  VERSAO = '1.0.0';

type
  TMinhaClasse = class ...;
  IMinhaInterface = interface ...;

var
  GVariavelGlobal: Integer;  // evitar variáveis globais

function MinhaFuncao(A: Integer): string;

implementation

uses
  // Units privadas — usadas apenas na implementação, não expostas
  System.RegularExpressions,
  System.JSON;

const
  CONSTANTE_PRIVADA = 'interna';  // só visível na implementation

var
  FVariavelPrivada: Integer;  // estado privado da unit

{ TMinhaClasse }

function MinhaFuncao(A: Integer): string;
begin
  Result := IntToStr(A);
end;

initialization
  // Executado UMA VEZ quando a unit é carregada na memória
  FVariavelPrivada := 0;

finalization
  // Executado UMA VEZ quando a unit é descarregada
  // Liberar recursos globais criados em initialization

end.
```

## Seção interface vs implementation

| | `interface` | `implementation` |
|--|-------------|-----------------|
| Visibilidade | Público — visível externamente | Privado — apenas dentro da unit |
| `uses` aqui | Tipos usados em declarações públicas | Tipos usados apenas nas implementações |
| Conteúdo | Tipos, constantes, variáveis, protótipos | Corpos de funções, constantes/vars privadas |

## Ordem canônica das cláusulas `uses`

### Delphi

```pascal
uses
  // 1. System / RTL (Embarcadero)
  System.SysUtils, System.Classes, System.Generics.Collections,
  // 2. FMX ou VCL
  FMX.Types, FMX.Controls,
  // 3. Projeto (prefixo do projeto)
  GestorERP.Commons, GestorERP.Models;
```

### FPC / Lazarus

```pascal
uses
  // 1. Unidades do sistema FPC
  SysUtils, Classes,
  // 2. LCL (se GUI)
  Forms, Controls,
  // 3. Projeto
  MinhaUnit;
```

## Unidades essenciais da RTL

| Unit | Conteúdo principal |
|------|--------------------|
| `System` | Implicitamente usada; TObject, string, Integer, etc. |
| `System.SysUtils` | Format, IntToStr, StrToInt, TryStrToInt, FreeAndNil, etc. |
| `System.Classes` | TStringList, TStream, TComponent, TThread |
| `System.Generics.Collections` | TList<T>, TDictionary<K,V>, TQueue<T>, TStack<T> |
| `System.Generics.Defaults` | TComparer<T>, IComparer<T> |
| `System.Rtti` | TRttiContext, TRttiType, TRttiProperty, TValue |
| `System.TypInfo` | TypeInfo(), GetTypeData(), tkXXX constants |
| `System.JSON` | TJSONObject, TJSONArray, TJSONValue |
| `System.Math` | Min, Max, Round, Trunc, Power, etc. |
| `System.DateUtils` | DateOf, TimeOf, SecondsBetween, IncDay, etc. |
| `System.RegularExpressions` | TRegEx.IsMatch, TRegEx.Replace |
| `System.IOUtils` | TPath, TDirectory, TFile |
| `System.SyncObjs` | TCriticalSection, TEvent, TMonitor |
| `System.Threading` | TTask, TParallel, IFuture<T> |

## Circular dependency — como evitar

```
// PROBLEMA: UnitA usa UnitB, UnitB usa UnitA
// SOLUÇÃO 1: Mover tipo comum para UnitC (commons/base)
// SOLUÇÃO 2: Usar forward declaration + colocar uses em implementation
// SOLUÇÃO 3: Usar interface/abstração em vez de tipo concreto

// Forward declaration em interface:
type
  TMinhaClasse = class; // forward — permite referenciar antes de definir

  TOutraClasse = class
    FRef: TMinhaClasse;  // OK — forward resolvida
  end;

  TMinhaClasse = class  // definição completa
    FOutra: TOutraClasse;
  end;
```

## initialization / finalization — regras

```pascal
initialization
  // Executado na ordem de CARREGAMENTO das units (dependências primeiro)
  // Bom para: registrar factories, inicializar singletons, abrir logs

finalization
  // Executado na ordem INVERSA do carregamento
  // Sempre liberar recursos na ordem inversa de criação
  FreeAndNil(GInstance);
  // NÃO lançar exceções em finalization — pode causar crash no shutdown
```
