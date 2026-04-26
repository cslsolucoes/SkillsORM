# Command — Undo/Redo com TStack<ICommand>

## Estrutura essencial

```pascal
type ICommand = interface
  procedure Execute;
  procedure Undo;
  function  GetDescricao: string;
  function  PodeDesfazer: Boolean;
end;

type TCommandHistory = class
  FHistorico: TStack<ICommand>;
  FRedo:      TStack<ICommand>;
public
  procedure Executar(ACmd: ICommand);  // executa + push no histórico
  procedure Desfazer;                  // pop + Undo + push em Redo
  procedure Refazer;                   // pop Redo + Execute + push em Histórico
end;
```

---

## Regras do Undo

| Regra | Detalhe |
|-------|---------|
| Salvar estado ANTES de Execute | Execute salva o que precisará restaurar em Undo |
| Undo = inverso exato de Execute | `TInsertCommand.Execute` insere; `Undo` deleta no mesmo lugar |
| Execute deve ser idempotente com Undo | Execute → Undo → Execute deve resultar no mesmo estado que Execute direto |
| Nova ação limpa o Redo stack | Ao executar novo comando, `FRedo.Clear` |
| `PodeDesfazer` = False para irreversíveis | Log, e-mail — execute mas não empilhe em Undo |

---

## Padrão de implementação

```pascal
type TDeleteCommand = class(TInterfacedObject, ICommand)
private
  FEditor:     TTextEditor;
  FPosicao:    Integer;
  FQtd:        Integer;
  FTextoSalvo: string;  // ← CRÍTICO: salvo no Execute para restaurar em Undo
public
  procedure Execute;
  begin
    FTextoSalvo := Copy(FEditor.Conteudo, FPosicao + 1, FQtd);  // salvar antes
    FEditor.DeletarTexto(FPosicao, FQtd);
  end;

  procedure Undo;
  begin FEditor.InserirTexto(FTextoSalvo, FPosicao); end;  // restaurar
end;
```

---

## MacroCommand — composição de comandos

```pascal
type TMacroCommand = class(TInterfacedObject, ICommand)
private
  FComandos: TList<ICommand>;
public
  procedure Execute;
  begin for var C in FComandos do C.Execute; end;

  procedure Undo;
  begin
    // Undo em ordem reversa
    for var I := FComandos.Count - 1 downto 0 do
      if FComandos[I].PodeDesfazer then FComandos[I].Undo;
  end;
end;

// Uso: toda a macro é uma única entrada no histórico
var Macro := TMacroCommand.Create('formatar-bloco');
Macro.Adicionar(TBoldCommand.Create(Editor, Sel));
Macro.Adicionar(TColorCommand.Create(Editor, Sel, clRed));
Historico.Executar(Macro);  // um Undo desfaz os dois
```

---

## Comandos irreversíveis

```pascal
type TEmailCommand = class(TInterfacedObject, ICommand)
public
  procedure Execute;
  begin EnviarEmail(...); end;  // irreversível

  procedure Undo;
  begin (* nada — não pode desfazer e-mail *) end;

  function PodeDesfazer: Boolean;
  begin Result := False; end;  // ← não será adicionado ao Undo stack
end;

// Em TCommandHistory.Executar:
procedure TCommandHistory.Executar(ACmd: ICommand);
begin
  ACmd.Execute;
  if ACmd.PodeDesfazer then FHistorico.Push(ACmd);  // só empilha se desfazível
  FRedo.Clear;
end;
```

---

## Limite do histórico

```pascal
// TList permite remover o elemento mais antigo (TStack não)
// Use TList<ICommand> com lógica de deque se precisar de limite:
if FHistorico.Count >= FMaxSize then
  FHistorico.Delete(0);  // remove o mais antigo
FHistorico.Add(ACmd);
```
