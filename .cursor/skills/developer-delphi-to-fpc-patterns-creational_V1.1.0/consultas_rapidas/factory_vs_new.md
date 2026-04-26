# Factory vs. `New` direto — quando usar cada um

## Regra geral

| Situação | Abordagem |
|----------|-----------|
| Criação simples, tipo fixo em tempo de compilação | `TFoo.Create` ou `TFoo.New` direto |
| Tipo decidido em runtime (string, config, enum) | Factory function / `TRegistry` |
| Múltiplas variantes com mesma interface | Factory Method ou Abstract Factory |
| Criação cara, objeto reutilizável | Object Pool |
| Objeto complexo com muitos parâmetros opcionais | Builder fluente |
| Instância única global | Singleton |

---

## `TFoo.Create` — quando é suficiente

```pascal
// OK: tipo conhecido, sem variação de runtime
var Conn := TFireDACConnection.Create;
var List := TList<string>.Create;
```

Prós: simples, direto, sem indireção.  
Contras: acopla o chamador ao tipo concreto — dificulta mocks e extensão.

---

## Factory function (`New`) — invólucro mínimo

```pascal
// Na interface pública da unit:
function NewLogger(ADestino: TLogDestino): ILogger;

// Implementação oculta:
function NewLogger(ADestino: TLogDestino): ILogger;
begin
  case ADestino of
    ldConsole: Result := TConsoleLogger.Create;
    ldArquivo: Result := TFileLogger.Create;
  end;
end;
```

Prós: encapsula `Create`, retorna interface, fácil de substituir.  
Recomendado para: módulos com interface única, sem extensão dinâmica.

---

## Registry dinâmico — quando há extensão em runtime

```pascal
TAnimalRegistry.Registrar('lobo',
  function: IAnimal begin Result := TLobo.Create; end);
var A := TAnimalRegistry.Criar('lobo');
```

Prós: open/closed — novos tipos sem alterar factory.  
Contras: erro em runtime se tipo não registrado; diagnóstico mais difícil.

---

## Abstract Factory — quando há famílias de produtos

Usar quando o cliente precisa de múltiplos produtos coerentes entre si:

```pascal
var F: IDBFactory := DBFactoryPara('sqlite');
var Conn := F.NewConnection;   // TSQLiteConnection
var Qry  := F.NewQuery(Conn);  // TSQLiteQuery
// Trocar para Postgres: só muda F — zero alteração no cliente
```

---

## Checklist de escolha

```
Preciso de instância única?  → Singleton
Objeto tem > 4 parâmetros opcionais?  → Builder
Vários objetos da mesma família?  → Abstract Factory
Tipo determinado em string/config?  → Registry
Objeto caro de criar, reutilizável?  → Object Pool
Resto  → TFoo.Create ou New()
```
