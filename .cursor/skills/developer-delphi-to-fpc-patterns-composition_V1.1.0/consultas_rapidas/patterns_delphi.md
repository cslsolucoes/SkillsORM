# Adaptações de Patterns ao Delphi

## 1. Interfaces `I*` como base dos patterns

Em Delphi, a convenção é que todos os patterns usem interfaces como contrato:

```pascal
// Correto — código cliente depende de interface
var Logger: ILogger := TTimestampLogger.Create(TConsoleLogger.Create);

// Evitar — código cliente depende da classe concreta
var Logger := TTimestampLogger.Create(...);
```

**Por quê:** `TInterfacedObject` provê contagem de referência automática — sem `Free` manual quando a variável é de interface.

---

## 2. `TInterfacedObject` como base universal

Todos os participantes dos patterns herdam de `TInterfacedObject`:

```pascal
type TTimestampLogger = class(TInterfacedObject, ILogger)
  // Sem destrutor manual — ref count cuida do ciclo de vida
end;
```

**Armadilha:** não misturar referência por interface e por objeto:

```pascal
var Obj := TTimestampLogger.Create;  // ref count = 0 (variável de classe)
var I: ILogger := Obj;               // ref count = 1
Obj.Free;                            // ERRO — interface ainda usa o objeto
// Correto: usar apenas a interface, nunca o objeto diretamente
```

---

## 3. Anonymous Methods como Strategy / Observer inline

```pascal
// Strategy inline — sem criar nova classe
var Sort: ISortStrategy := TLambdaSortStrategy.Create('insertion',
  procedure(var A: TArray<Integer>)
  begin
    // insertion sort
  end);

// Observer inline
Conta.Inscrever(TLambdaObserver.Create('sms',
  procedure(const AEvt: string; const ADados: TValue)
  begin Writeln('[SMS] ', AEvt); end));
```

Quando preferir lambda vs. classe: lambda para handlers simples; classe quando o observer tem estado próprio ou é testado isoladamente.

---

## 4. Generics em Patterns

```pascal
// Singleton genérico — reutilizável para qualquer classe
type TSingleton<T: class, constructor> = class
  class function GetInstance: T;
end;

// Observer tipado — sem TValue
type TMulticastEvent<T> = class
  procedure Subscribe(AHandler: reference to procedure(const ADados: T));
  procedure Fire(const ADados: T);
end;

// Repository genérico
type IRepository<T, TId> = interface
  function FindById(AId: TId): T;
  procedure Save(AEntity: T);
end;
```

---

## 5. Class Constructor para inicialização de singleton e registry

```pascal
type TAnimalRegistry = class
private
  class var FRegistry: TDictionary<string, TAnimalCreator>;
  class constructor Create;   // executado uma vez, thread-safe
  class destructor Destroy;
public
  class procedure Registrar(const ATipo: string; ACreator: TAnimalCreator);
end;

class constructor TAnimalRegistry.Create;
begin
  FRegistry := TDictionary<string, TAnimalCreator>.Create;
  Registrar('cao', function: IAnimal begin Result := TCao.Create; end);
end;
```

**Vantagem:** inicializado antes do primeiro uso, sem precisar de check explícito.

---

## 6. `reference to procedure/function` em Chain of Responsibility

```pascal
// Chain com anonymous method — quando handlers são simples funções
type TValidador = reference to function(const AInput: string): string;

procedure Validar(const AInput: string; const AChain: TArray<TValidador>);
var Erro: string;
begin
  for var V in AChain do
  begin
    Erro := V(AInput);
    if Erro <> '' then begin Writeln('Inválido: ', Erro); Exit; end;
  end;
  Writeln('Válido: ', AInput);
end;

Validar('teste@email.com', [
  function(S: string): string begin if S = '' then Result := 'Vazio'; end,
  function(S: string): string begin if not S.Contains('@') then Result := 'Sem @'; end
]);
```

---

## 7. Compatibilidade Delphi + FPC

| Feature | Delphi | FPC | Alternativa compatível |
|---------|--------|-----|------------------------|
| `TValue` (RTTI) | Sim | Parcial | Usar `Variant` ou interface específica |
| `TFunc<T,R>` | Sim | Sim | `reference to function` |
| `TProc<T>` | Sim | Sim | `reference to procedure` |
| Generics com constraints | Sim | Parcial | Evitar constraints `constructor` no FPC |
| `class constructor` | Sim | Sim | Totalmente compatível |
| `TInterfacedObject` | Sim | Sim | Totalmente compatível |
| `inline` | Sim | Sim | Sem ASM + inline juntos |
