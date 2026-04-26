# Test Data Builders — Construtor de Dados de Teste

**Skill:** developer-delphi-testing-integration_V1.0.0

---

## O problema: dados hardcoded em cada teste

```pascal
// RUIM: duplicacao e fragilidade
procedure TesteSalvarCliente;
begin
  var C: TClienteRecord;
  C.Id    := 1;
  C.Nome  := 'Joao';
  C.Email := 'joao@teste.com';
  C.Ativo := True;
  C.Cpf   := '111.444.777-35';
  // ... 5 campos repetidos em cada teste ...
end;
```

Se o `TClienteRecord` ganhar um novo campo obrigatorio, todos os testes quebram.

---

## Solucao: Builder com valores padrao

```pascal
type
  TClienteBuilder = class
  private
    FId:    Integer;
    FNome:  string;
    FEmail: string;
    FAtivo: Boolean;
    FCpf:   string;
  public
    constructor Create;

    function ComId(AId: Integer): TClienteBuilder;
    function ComNome(const ANome: string): TClienteBuilder;
    function ComEmail(const AEmail: string): TClienteBuilder;
    function Inativo: TClienteBuilder;
    function ComCpf(const ACpf: string): TClienteBuilder;
    function Build: TClienteRecord;

    // Factory para o caso mais comum
    class function Padrao: TClienteRecord;
  end;

constructor TClienteBuilder.Create;
begin
  inherited Create;
  // Valores padrao validos — cada teste so sobrescreve o que precisa
  FId    := 1;
  FNome  := 'Cliente Padrao';
  FEmail := 'padrao@teste.com';
  FAtivo := True;
  FCpf   := '111.444.777-35';
end;

function TClienteBuilder.ComId(AId: Integer): TClienteBuilder;
begin FId := AId; Result := Self; end;

function TClienteBuilder.ComNome(const ANome: string): TClienteBuilder;
begin FNome := ANome; Result := Self; end;

function TClienteBuilder.ComEmail(const AEmail: string): TClienteBuilder;
begin FEmail := AEmail; Result := Self; end;

function TClienteBuilder.Inativo: TClienteBuilder;
begin FAtivo := False; Result := Self; end;

function TClienteBuilder.ComCpf(const ACpf: string): TClienteBuilder;
begin FCpf := ACpf; Result := Self; end;

function TClienteBuilder.Build: TClienteRecord;
begin
  Result.Id    := FId;
  Result.Nome  := FNome;
  Result.Email := FEmail;
  Result.Ativo := FAtivo;
  Result.Cpf   := FCpf;
end;

class function TClienteBuilder.Padrao: TClienteRecord;
begin
  Result := TClienteBuilder.Create.Build;
end;
```

---

## Usando o Builder nos testes

```pascal
// Caso simples — usar padrao
procedure Teste_BuscarCliente;
begin
  FRepo.Salvar(TClienteBuilder.Padrao);
  // ...
end;

// Customizar apenas o que importa para o teste
procedure Teste_ClienteInativo;
begin
  var C := TClienteBuilder.Create.ComId(99).Inativo.Build;
  FRepo.Salvar(C);
  Assert.IsFalse(FRepo.BuscarPorId(99).Ativo);
end;

// Fluent — encadeamento
procedure Teste_EmailDuplicado;
begin
  FRepo.Salvar(TClienteBuilder.Create.ComId(1).ComEmail('x@y.com').Build);
  FRepo.Salvar(TClienteBuilder.Create.ComId(2).ComEmail('x@y.com').Build);
  // verificar regra de unicidade...
end;
```

---

## Helpers de fixture de banco

Para simplificar insercao direta no banco (sem passar pelo repositorio):

```pascal
type
  TFixtureHelper = class
  private
    FConn: TFDConnection;
  public
    constructor Create(AConn: TFDConnection);

    /// Insere cliente e retorna ID gerado
    function InserirCliente(const ANome, AEmail: string; AAtivo: Boolean = True): Integer;
    /// Insere produto com preco
    function InserirProduto(const ANome: string; APreco: Currency): Integer;
    /// Limpar tabela (para casos onde ROLLBACK nao e suficiente)
    procedure LimparTabela(const ANome: string);
  end;

// Uso no teste:
procedure Teste_BuscarCliente_IdValido;
begin
  var Id := FFixture.InserirCliente('Maria', 'maria@teste.com');
  var C  := FRepo.BuscarPorId(Id);
  Assert.AreEqual('Maria', C.Nome);
end;
```

---

## Boas praticas de builders

| Pratica | Motivo |
|---------|--------|
| Valores padrao sempre validos | Teste compila mesmo sem customizar nada |
| Um builder por entidade | Reutilizavel em toda a suite |
| Factory `Padrao` para o caso mais comum | Reduz verbosidade nos testes |
| Fluent API (retorna Self) | Leitura natural: `.ComNome('X').Inativo.Build` |
| Nao usar em [SetupFixture] global | Dados devem ser criados dentro de cada teste |
