# Diálogos Cross-Platform — TDialogService vs Application.MessageBox

## Comparativo rápido

| Característica | TDialogService | Application.MessageBox |
|----------------|----------------|------------------------|
| Cross-platform | Sim (Win/Mac/iOS/Android) | Não (Windows only) |
| Thread-safe | Sim | Não |
| Bloqueia UI | Não (callback) | Sim |
| Estilo nativo | Sim (por plataforma) | Sim (Windows) |
| Customizável | Limitado (tipos padrão) | Não |
| Recomendado | Sempre em FMX | Nunca em FMX |

**Regra:** Em FMX, usar sempre `TDialogService`. Nunca `Application.MessageBox`.

---

## TDialogService.MessageDialog

```pascal
uses FMX.DialogService;

TDialogService.MessageDialog(
  'Mensagem para o usuário',     // texto
  TMsgDlgType.mtConfirmation,    // tipo (ícone)
  [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], // botões
  TMsgDlgBtn.mbNo,               // botão padrão (Enter)
  0,                             // HelpContext (0=sem ajuda)
  procedure(const AResult: TModalResult)
  begin
    // Callback chamado quando usuário clica um botão
    if AResult = mrYes then
      ExecutarAcao;
  end);
```

---

## TMsgDlgType — tipos de ícone

| Constante | Ícone | Uso |
|-----------|-------|-----|
| `mtWarning` | ! (aviso) | ações irreversíveis, exclusão |
| `mtError` | X (erro) | falhas, erros |
| `mtInformation` | i (informação) | sucesso, notificações |
| `mtConfirmation` | ? (interrogação) | confirmar ação |
| `mtCustom` | nenhum | genérico |

---

## TMsgDlgBtn — botões disponíveis

| Botão | TModalResult retornado |
|-------|------------------------|
| `mbOK` | `mrOk` (1) |
| `mbCancel` | `mrCancel` (2) |
| `mbYes` | `mrYes` (6) |
| `mbNo` | `mrNo` (7) |
| `mbAbort` | `mrAbort` (3) |
| `mbRetry` | `mrRetry` (4) |
| `mbIgnore` | `mrIgnore` (5) |

---

## Padrões de uso comuns

```pascal
// 1. Confirmação simples (Sim/Não)
TDialogService.MessageDialog('Continuar?',
  TMsgDlgType.mtConfirmation, [mbYes, mbNo], mbNo, 0,
  procedure(const R: TModalResult)
  begin if R = mrYes then Continuar; end);

// 2. Aviso de exclusão
TDialogService.MessageDialog('Excluir item selecionado?',
  TMsgDlgType.mtWarning, [mbYes, mbNo], mbNo, 0,
  procedure(const R: TModalResult)
  begin if R = mrYes then Excluir; end);

// 3. Mensagem informativa (só OK)
TDialogService.ShowMessage('Operação realizada com sucesso!');
// ou equivalente:
TDialogService.MessageDialog('Salvo!',
  TMsgDlgType.mtInformation, [mbOK], mbOK, 0, nil);

// 4. Input de texto
TDialogService.InputQuery('Login', ['Usuário:', 'Senha:'], ['', ''],
  procedure(const OK: Boolean; const V: array of string)
  begin
    if OK then Login(V[0], V[1]);
  end);
```

---

## Chamar de thread em background

```pascal
// TTask.Run — pode chamar TDialogService de dentro de Synchronize
TTask.Run(procedure
begin
  // processamento assíncrono...
  var Resultado := CarregarDados;

  // Para exibir diálogo de thread secundária: usar TThread.Synchronize
  TThread.Synchronize(nil, procedure
  begin
    TDialogService.ShowMessage('Dados carregados: ' + IntToStr(Resultado));
  end);
end);
```

---

## TDialogService.ShowMessage vs MessageDlg

```pascal
// ShowMessage — não bloqueia, sem callback
TDialogService.ShowMessage('Texto');

// MessageDlg (legado VCL/FMX) — BLOQUEIA, retorna TModalResult
var R := MessageDlg('Texto?', TMsgDlgType.mtConfirmation, [mbYes, mbNo], 0);
// NÃO usar em FMX — pode bloquear UI em mobile
```

Use `MessageDlg` apenas se precisar de resultado síncrono e souber que está na
main thread desktop. Em qualquer outro caso, `MessageDialog` com callback.
