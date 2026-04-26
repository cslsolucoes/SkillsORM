# Singleton — riscos, thread safety e testabilidade

## Implementação correta (Double-Checked Locking)

```pascal
class function TMinhaClasse.GetInstance: TMinhaClasse;
begin
  if FInstancia = nil then
  begin
    FLock.Enter;
    try
      if FInstancia = nil then   // ← segundo check dentro do lock
        FInstancia := TMinhaClasse.Create;
    finally
      FLock.Leave;
    end;
  end;
  Result := FInstancia;
end;
```

**Por que dois checks?**  
O primeiro evita aquisição desnecessária do lock quando já inicializado.  
O segundo protege contra race condition quando duas threads passam pelo primeiro check simultaneamente.

---

## Inicialização do lock

```pascal
// Usar class constructor — executado uma única vez antes do primeiro uso da classe
class constructor TMinhaClasse.Create;
begin
  FLock := TCriticalSection.Create;
end;

class destructor TMinhaClasse.Destroy;
begin
  FreeAndNil(FInstancia);
  FreeAndNil(FLock);
end;
```

**Nunca** inicializar o lock dentro de `GetInstance` — race condition na criação do próprio lock.

---

## Riscos conhecidos

| Risco | Sintoma | Mitigação |
|-------|---------|-----------|
| Race condition sem lock | Duas instâncias criadas | Double-Checked Locking |
| Lock na criação do lock | Crash na inicialização | Usar `class constructor` |
| Dependência circular entre singletons | Stack overflow | Injetar dependências, não referenciar singleton dentro de outro |
| Testes acoplados ao estado global | Testes interferem entre si | Expor `ResetInstance` para testes |
| Lifetime não controlado | Vazamento de recursos | `class destructor` ou `FreeAndNil` explícito |

---

## Testabilidade

```pascal
// Problema: testes acoplados ao estado global
procedure TTesteA.SetUp;
begin
  // estado do singleton persiste entre testes!
  TConfiguracao.GetInstance.Put('chave', 'valor_a');
end;

// Solução 1: ResetInstance (apenas para testes)
procedure TTesteA.TearDown;
begin
  TConfiguracao.ResetInstance;
end;

// Solução 2 (melhor): não usar singleton no código de negócio,
// injetar IConfiguracao como dependência
type TServico = class
private
  FConfig: IConfiguracao;
public
  constructor Create(AConfig: IConfiguracao);
end;
// Em produção: passar TConfiguracao.GetInstance
// Em testes: passar TConfigMock.Create
```

---

## Quando NÃO usar Singleton

- Quando a "instância única" é uma suposição que pode mudar (ex.: multi-tenant)
- Quando o objeto tem estado mutável acessado de muitas threads sem sincronização interna
- Quando você precisa de múltiplas instâncias em testes

**Prefer:** injeção de dependência com lifetime gerenciado pelo container.
