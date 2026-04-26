---
name: developer-delphi-to-fpc-performance-and-architecture
description: Performance e arquitetura em Delphi/FPC — profiling, pool de objetos, lazy loading, otimização de memória, decisões estruturais de alto impacto
model: opus
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-performance-and-architecture

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Data** | 09/04/2026 |

## Responsabilidade única

Esta skill orienta decisões de performance e arquitetura de alto impacto em Delphi/FPC: pool de conexões, lazy initialization, string interning, alocação em stack vs heap, thread pooling e estratégias de cache — com exemplos compiláveis. Exige medição antes e depois de qualquer otimização. Ela NÃO cobre padrões de design simples como Fluent ou Composite (→ `developer-delphi-to-fpc-patterns-composition`), NÃO configura build/compilação (→ `developer-delphi-to-fpc-build`) e NÃO diagnostica exceções de runtime (→ `developer-delphi-to-fpc-error-handling-and-diagnostics`).

## When to use

- Ao identificar gargalo mensurável de memória ou CPU em hotspot confirmado por profiler.
- Ao projetar pool de objetos (conexões, parsers, buffers) para reduzir custo de criação.
- Ao decidir entre alocação em stack vs heap para estruturas de curta duração.
- Ao implementar lazy initialization de recursos pesados (conexão, cache, índice).
- Ao dimensionar thread pool para carga de I/O ou CPU.

## When NOT to use

- Não usar para padrões de composição básicos (Fluent, Decorator, Observer) → use `developer-delphi-to-fpc-patterns-composition`.
- Não usar para configurar build ou flags de compilação → use `developer-delphi-to-fpc-build`.
- Não usar para diagnóstico de leaks isolados sem contexto de performance → use `developer-delphi-to-fpc-performance-and-memory`.
- Não usar para definir contratos arquiteturais de módulos → use `developer-delphi-to-fpc-architecture-and-design`.

## Inputs

- Métricas de baseline: tempo de resposta, alocações por operação, consumo de memória.
- Hotspot identificado por profiler (AQTime, Sampling Profiler, HeapTrc) ou teste de carga.
- Restrições de design: thread safety, compatibilidade Delphi/FPC, sem framework externo.

## Workflow executável

1. **Medir antes de otimizar** — registrar baseline (tempo, memória, alocações/s) com profiler ou `GetTickCount64`.
2. **Identificar hotspot** — confirmar que o ponto alvo é responsável por ≥ 20 % do custo total.
3. **Escolher técnica** — selecionar da tabela de técnicas abaixo conforme o perfil do gargalo.
4. **Implementar com try..finally** — todo recurso alocado manualmente tem bloco `try..finally..Free`.
5. **Validar ausência de leaks** — rodar com FastMM (Delphi) ou HeapTrc/CMem (FPC); zero leaks.
6. **Documentar trade-off** — registrar baseline vs. resultado pós-otimização e custo de complexidade adicionado.

### Tabela de técnicas de performance

| Gargalo | Técnica | Custo de implementação |
|---------|---------|----------------------|
| Criação/destruição frequente de objetos | Pool de objetos (`TAcquire`/`TRelease`) | Médio |
| Inicialização de recurso pesado em toda chamada | Lazy initialization com flag `FInitialized` | Baixo |
| Lookup frequente em `TStringList` | Substituir por `TDictionary<K,V>` | Baixo |
| String concatenação em loop | `TStringBuilder` ou array + `Join` | Baixo |
| Alocação heap de records pequenos | Passar por valor (stack) ou usar `packed record` | Baixo |
| Threads criadas por requisição | Thread pool com fila de tarefas | Alto |
| Cache ausente em queries repetidas | Cache LRU com `TDictionary` + TTL | Médio |

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `documentation-project-expert` | Verificar convenções e restrições do ProvidersORM antes de alterar estrutura |
| `developer-delphi-to-fpc-performance-and-memory` | Confirmar diagnóstico de leaks e baseline de memória antes de otimizar |

## Checklist Delphi+FPC

- [ ] Compilação sem hints/warnings em Delphi (dcc32 + dcc64)
- [ ] Compilação sem hints/warnings em FPC (fpc32 + fpc64)
- [ ] Memory management: Create/Free em try..finally; sem leaks
- [ ] Tratamento de exceções: hierarquia do projeto (EProviderError ou equivalente)
- [ ] Nomenclatura: prefixos T/I/E/F/A conforme documentation-project-expert
- [ ] Diretivas {$IFDEF} conforme developer-delphi-programming-conditional-defines
- [ ] Separação UI/lógica: zero SQL em event handlers
- [ ] Interfaces first-class: variáveis do tipo IInterface, não TClasse
- [ ] class function New retorna interface (desalocação automática)

## Exemplo mínimo compilável

### Lazy initialization com interface — Delphi (dcc32 / dcc64)

```pascal
program SampleLazyDelphi;
{$APPTYPE CONSOLE}

uses SysUtils;

type
  IExpensiveResource = interface
    ['{C3D4E5F6-0003-0000-0000-000000000003}']
    function GetValue: string;
  end;

  TExpensiveResource = class(TInterfacedObject, IExpensiveResource)
  private
    FValue: string;
  public
    constructor Create(const AValue: string);
    class function New(const AValue: string): IExpensiveResource;
    function GetValue: string;
  end;

  ILazyContainer = interface
    ['{D4E5F6A7-0004-0000-0000-000000000004}']
    function GetResource: IExpensiveResource;
  end;

  TLazyContainer = class(TInterfacedObject, ILazyContainer)
  private
    FResource: IExpensiveResource;
    FInitialized: Boolean;
    procedure Initialize;
  public
    class function New: ILazyContainer;
    function GetResource: IExpensiveResource;
  end;

constructor TExpensiveResource.Create(const AValue: string);
begin
  inherited Create;
  FValue := AValue;
  WriteLn('[TExpensiveResource] criado: ' + FValue);
end;

class function TExpensiveResource.New(const AValue: string): IExpensiveResource;
begin
  Result := TExpensiveResource.Create(AValue);
end;

function TExpensiveResource.GetValue: string;
begin
  Result := FValue;
end;

class function TLazyContainer.New: ILazyContainer;
begin
  Result := TLazyContainer.Create;
end;

procedure TLazyContainer.Initialize;
begin
  if not FInitialized then
  begin
    FResource := TExpensiveResource.New('recurso-caro-inicializado-apenas-uma-vez');
    FInitialized := True;
  end;
end;

function TLazyContainer.GetResource: IExpensiveResource;
begin
  Initialize;
  Result := FResource;
end;

var
  Container: ILazyContainer;
begin
  Container := TLazyContainer.New;
  WriteLn('Container criado; recurso ainda NAO inicializado.');
  WriteLn('Acessando recurso: ' + Container.GetResource.GetValue);
  WriteLn('Segundo acesso (sem re-inicializacao): ' + Container.GetResource.GetValue);
end.
```

### Lazy initialization com interface — Free Pascal (fpc32 / fpc64)

```pascal
program SampleLazyFPC;
{$IF DEFINED(FPC)}
  {$mode delphi}
  {$H+}
{$ENDIF}
{$APPTYPE CONSOLE}

uses SysUtils;

type
  IExpensiveResource = interface
    ['{C3D4E5F6-0003-0000-0000-000000000003}']
    function GetValue: string;
  end;

  TExpensiveResource = class(TInterfacedObject, IExpensiveResource)
  private
    FValue: string;
  public
    constructor Create(const AValue: string);
    class function New(const AValue: string): IExpensiveResource;
    function GetValue: string;
  end;

  ILazyContainer = interface
    ['{D4E5F6A7-0004-0000-0000-000000000004}']
    function GetResource: IExpensiveResource;
  end;

  TLazyContainer = class(TInterfacedObject, ILazyContainer)
  private
    FResource: IExpensiveResource;
    FInitialized: Boolean;
    procedure Initialize;
  public
    class function New: ILazyContainer;
    function GetResource: IExpensiveResource;
  end;

constructor TExpensiveResource.Create(const AValue: string);
begin
  inherited Create;
  FValue := AValue;
  WriteLn('[TExpensiveResource] criado: ' + FValue);
end;

class function TExpensiveResource.New(const AValue: string): IExpensiveResource;
begin
  Result := TExpensiveResource.Create(AValue);
end;

function TExpensiveResource.GetValue: string;
begin
  Result := FValue;
end;

class function TLazyContainer.New: ILazyContainer;
begin
  Result := TLazyContainer.Create;
end;

procedure TLazyContainer.Initialize;
begin
  if not FInitialized then
  begin
    FResource := TExpensiveResource.New('recurso-caro-inicializado-apenas-uma-vez');
    FInitialized := True;
  end;
end;

function TLazyContainer.GetResource: IExpensiveResource;
begin
  Initialize;
  Result := FResource;
end;

var
  Container: ILazyContainer;
begin
  Container := TLazyContainer.New;
  WriteLn('Container criado; recurso ainda NAO inicializado.');
  WriteLn('Acessando recurso: ' + Container.GetResource.GetValue);
  WriteLn('Segundo acesso (sem re-inicializacao): ' + Container.GetResource.GetValue);
end.
```

### Pool de objetos simples — unit de referência (Delphi + FPC)

```pascal
unit Sample.Pool;
{$IF DEFINED(FPC)}
  {$mode delphi}
  {$H+}
{$ENDIF}
interface

uses Generics.Collections;

type
  IPooledObject = interface
    ['{E5F6A7B8-0005-0000-0000-000000000005}']
    procedure Reset;
    function IsReady: Boolean;
  end;

  IObjectPool = interface
    ['{F6A7B8C9-0006-0000-0000-000000000006}']
    function Acquire: IPooledObject;
    procedure Release(const AObj: IPooledObject);
    function PoolSize: Integer;
  end;

  TSimplePool = class(TInterfacedObject, IObjectPool)
  private
    FAvailable: TList<IPooledObject>;
    FFactory: TFunc<IPooledObject>;
  public
    constructor Create(const AFactory: TFunc<IPooledObject>; AInitialSize: Integer);
    destructor Destroy; override;
    class function New(const AFactory: TFunc<IPooledObject>; AInitialSize: Integer): IObjectPool;
    function Acquire: IPooledObject;
    procedure Release(const AObj: IPooledObject);
    function PoolSize: Integer;
  end;

implementation

constructor TSimplePool.Create(const AFactory: TFunc<IPooledObject>; AInitialSize: Integer);
var
  I: Integer;
begin
  inherited Create;
  FFactory := AFactory;
  FAvailable := TList<IPooledObject>.Create;
  for I := 1 to AInitialSize do
    FAvailable.Add(FFactory());
end;

destructor TSimplePool.Destroy;
begin
  FAvailable.Free;
  inherited;
end;

class function TSimplePool.New(const AFactory: TFunc<IPooledObject>; AInitialSize: Integer): IObjectPool;
begin
  Result := TSimplePool.Create(AFactory, AInitialSize);
end;

function TSimplePool.Acquire: IPooledObject;
begin
  if FAvailable.Count > 0 then
  begin
    Result := FAvailable[FAvailable.Count - 1];
    FAvailable.Delete(FAvailable.Count - 1);
  end
  else
    Result := FFactory();
  Result.Reset;
end;

procedure TSimplePool.Release(const AObj: IPooledObject);
begin
  if AObj <> nil then
    FAvailable.Add(AObj);
end;

function TSimplePool.PoolSize: Integer;
begin
  Result := FAvailable.Count;
end;

end.
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| Otimizar sem medir (otimização prematura) | Complexidade adicionada ao lugar errado; pior relação custo/benefício | Medir com profiler; otimizar apenas hotspot com ≥ 20 % do custo total |
| `TStringList` para lookup frequente | O(n) por busca; desempenho degrada linearmente | Substituir por `TDictionary<string, T>` para O(1) amortizado |
| Criar e destruir objetos em loop interno | Custo do alocador de memória acumula; fragmentação de heap | Usar pool ou instância reutilizável fora do loop |
| Lazy initialization sem proteção em ambiente multithread | Condição de corrida: dois threads inicializam simultaneamente | Usar `TCriticalSection` ou `TSpinLock` no bloco `Initialize` |
| Pool sem limite máximo | Vazamento lento de memória se consumidores nunca devolverem | Definir `MaxSize`; lançar exceção ou bloquear se excedido |
| Cache sem política de invalidação (TTL/LRU) | Dados obsoletos; crescimento ilimitado de memória | Implementar TTL por entrada ou evicção LRU com `TDictionary` + fila |

## Métricas de sucesso

- Zero leaks reportados por FastMM (Delphi) ou HeapTrc/CMem (FPC) após cada ciclo.
- Tempo de resposta do hotspot reduzido em ≥ 20 % vs. baseline documentado.
- Compilação dcc32, dcc64, fpc32, fpc64 sem hints ou warnings.
- Trade-off (ganho vs. complexidade adicionada) registrado no comentário da PR ou documentação.

## Responsável principal

| Papel | Quem |
|-------|------|
| Arquiteto de performance | `dev-agent-providers-orm-expert` |
| Validador de leaks | CI/pipeline local com FastMM/HeapTrc habilitado |
| Guardião de baseline | Desenvolvedor responsável pelo módulo otimizado |

## Avaliacao de risco e confirmacao

- Otimizações que alteram contrato público (assinatura de interface, semântica de retorno) exigem confirmação prévia e execução de `governance-refactoring-compatibility-policy`.
- Introdução de thread pool em módulo sem thread safety documentada requer análise de risco explícita antes de implementar.

## Referencias

- `e:/CSL/ProvidersORM/src/Modulos/PoolConnections/` — referência de pool no ProvidersORM
- `.cursor/skills/developer-delphi-to-fpc-performance-and-memory_V1.0.0/SKILL.md`
- `.cursor/skills/developer-delphi-to-fpc-architecture-and-design_V1.0.0/SKILL.md`
- RAD Studio docs — FastMM, AQTime, Sampling Profiler
- FPC docs — HeapTrc, CMem, profiling
- `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Skill nova V2 — performance e arquitetura de alto impacto em Delphi/FPC (pool de objetos, lazy initialization, TDictionary, thread pool, cache LRU) adaptados do contexto React para ProvidersORM; workflow 6 passos; checklist 9 itens; exemplos compiláveis Delphi + FPC separados com lazy init e pool de objetos.
