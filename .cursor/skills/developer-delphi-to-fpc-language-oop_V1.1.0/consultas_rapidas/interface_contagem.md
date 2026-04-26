# Interfaces e Reference Counting em Delphi

## Como funciona o reference counting

Quando uma variável de interface recebe um objeto TInterfacedObject:
1. `_AddRef` é chamado → `RefCount` incrementa
2. Quando a variável sai do escopo ou é atribuída nil → `_Release` é chamado
3. Se `RefCount` chega a 0 → objeto é destruído automaticamente

```pascal
var Log: ILogger := TConsoleLogger.Create; // RefCount = 1
begin
  Log.Log('x'); // RefCount ainda 1
end; // sai do escopo → _Release → RefCount = 0 → objeto destruído
```

## Múltiplas variáveis de interface

```pascal
var L1: ILogger := TConsoleLogger.Create; // RefCount = 1
var L2 := L1;  // RefCount = 2 (mesmo objeto)
L1 := nil;     // RefCount = 1 (objeto ainda existe)
L2 := nil;     // RefCount = 0 → objeto destruído
```

## Ciclo de referência (memory leak)

```pascal
// PROBLEMA: A tem ref para B, B tem ref para A → RefCount nunca chega a 0
type
  TNo = class(TInterfacedObject, INo)
    Proximo: INo; // referência forte
  end;

var A := TNo.Create as INo;
var B := TNo.Create as INo;
A.Proximo := B; // B.RefCount = 2
B.Proximo := A; // A.RefCount = 2
// Ao sair do escopo: A.RefCount = 1, B.RefCount = 1 → LEAK!
```

## Solução: referência fraca (Weak)

```pascal
// Usar [weak] para quebrar ciclos (Delphi 10.1+, necessita ARC)
type
  TNo = class(TInterfacedObject, INo)
    [Weak] Pai: INo; // não incrementa RefCount
    Filhos: TArray<INo>; // referência forte para os filhos
  end;
```

## TInterfacedObject vs TObject para interfaces

| | TInterfacedObject | TObject |
|---|---|---|
| `_AddRef` / `_Release` | gerencia RefCount | deve implementar manualmente |
| Destruição | automática (RefCount = 0) | manual (você chama Free) |
| Uso | objetos criados PARA viver via interface | objetos com ciclo de vida independente |

```pascal
// TObject com _AddRef/_Release que não destroem:
function TFileLogger._AddRef:  Integer; begin Result := -1; end;
function TFileLogger._Release: Integer; begin Result := -1; end;
// → Você é responsável por chamar .Free manualmente
```

## Quando usar interface vs classe

```pascal
// Interface: quando o consumidor não deve saber o tipo concreto
procedure Processar(ALog: ILogger);  // aceita qualquer logger

// Classe: quando o consumidor precisa de métodos específicos do tipo
procedure ConfigurarFireDAC(AConn: TFDConnection);
```

## Regras práticas

- `TInterfacedObject`: use quando o objeto vai viver **inteiramente via interface**
- `TObject` com `_AddRef/_Release = -1`: use quando o objeto tem **ciclo de vida próprio** (componente, form, etc.)
- Quebre ciclos com `[Weak]` ou atribuindo `nil` explicitamente antes do escopo terminar
- Nunca misture `Free` e gestão via interface no mesmo objeto `TInterfacedObject`

```pascal
// ERRADO: chamar Free em TInterfacedObject que ainda tem variável de interface apontando
var L: ILogger := TConsoleLogger.Create;
TConsoleLogger(L).Free; // AV quando L sair do escopo e chamar _Release!

// CORRETO: apenas atribuir nil ou deixar sair do escopo
L := nil; // _Release → RefCount = 0 → destruição automática
```
