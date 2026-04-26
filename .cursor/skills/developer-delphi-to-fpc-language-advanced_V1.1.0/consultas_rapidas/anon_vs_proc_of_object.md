# Anonymous Methods vs Procedure of Object

## Comparação fundamental

| Aspecto | `procedure of object` | Anonymous method |
|---------|----------------------|-----------------|
| Sintaxe | `procedure(X: T) of object` | `reference to procedure(X: T)` |
| Captura variáveis | NÃO — só acessa membros da classe | SIM — captura variáveis do escopo |
| Requer instância | SIM — precisa de método em uma classe | NÃO — pode ser criado inline |
| Implementado como | Ponteiro duplo (código + objeto) | Interface (ref-counted) |
| Overhead | Mínimo — 2 ponteiros | Maior — alocação de interface |
| Ciclo de vida | Gerenciado manualmente | Ref counting automático |
| Comparação | `=` direto entre handlers | NÃO comparável com `=` |
| FPC compatível | Sim | Sim (FPC 2.6+) |

## Declaração

```pascal
// Procedure of object
type TClickHandler = procedure(Sender: TObject) of object;
type TChangeHandler = procedure(const AValue: string) of object;

// Anonymous method
type TClickAnon    = reference to procedure(Sender: TObject);
type TChangeAnon   = reference to procedure(const AValue: string);
type TPredicado<T> = reference to function(const V: T): Boolean;
```

## Atribuição

```pascal
// Procedure of object — precisa de método em instância
type
  THandler = class
    procedure OnClick(Sender: TObject);
  end;

var H := THandler.Create;
var Handler: TClickHandler := H.OnClick;  // método ligado à instância

// Anonymous method — pode ser criado em qualquer lugar
var AnonHandler: TClickAnon :=
  procedure(Sender: TObject)
  begin
    Writeln('Clicado!');
  end;
```

## Quando cada um captura variáveis

```pascal
// Procedure of object: NÃO captura variáveis locais
procedure TForm.ConfigurarBotao;
var N: Integer;
begin
  N := 42;
  Botao.OnClick := Botao1Click;  // método — não acessa N diretamente
end;

procedure TForm.Botao1Click(Sender: TObject);
begin
  // N não existe aqui — é variável local de ConfigurarBotao
end;

// Anonymous method: CAPTURA variáveis locais por referência
procedure TForm.ConfigurarBotao;
var N: Integer;
begin
  N := 42;
  Botao.OnClick :=
    procedure(Sender: TObject)
    begin
      Writeln(N);  // OK — N foi capturado!
      N := N + 1;  // modifica N na variável original
    end;
end;
```

## Ciclo de vida de variável capturada

```pascal
function CriarClosure: TProc;
var X: Integer;  // X fica vivo enquanto o closure existir
begin
  X := 10;
  Result := procedure begin Writeln(X); Inc(X); end;
  // Após retornar, X NÃO é destruído — continua vivo via closure
end;

var C := CriarClosure;
C();  // 10
C();  // 11  ← X persiste!
C := nil;  // agora X é liberado
```

## Uso como callback em eventos

```pascal
// Procedure of object — padrão VCL clássico
Button1.OnClick := Botao1Click;  // nome de método
// Remove: Button1.OnClick := nil;

// Anonymous — inline, sem necessidade de método separado
Button1.OnClick :=
  procedure(Sender: TObject)
  begin
    ShowMessage(Format('Usuário: %s', [FUsuarioAtivo]));
  end;
// FUsuarioAtivo é capturado por referência
```

## Regras práticas

```
Use procedure of object quando:
  - Componentes VCL/FMX (Button.OnClick, Timer.OnTimer)
  - Desempenho crítico sem necessidade de captura
  - Remoção de handler necessária (nil assignment)

Use anonymous method quando:
  - Callback inline sem necessidade de método separado
  - Precisar capturar variáveis locais (estado de closure)
  - Passar como TProc<T> / TFunc<T,R> para APIs genéricas
  - Código funcional: filter, map, reduce, pipeline
```
