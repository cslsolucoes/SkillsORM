unit dialogs_fmx;
// TDialogService: diálogos cross-platform e thread-safe em FMX

interface

uses
  FMX.Forms, FMX.DialogService, FMX.Types,
  System.UITypes, System.SysUtils;

// Confirmar ação destrutiva (ex: excluir registro)
procedure ConfirmarExclusao(const AMensagem: string;
  AOnConfirmado: TProc);

// Confirmar ação genérica com pergunta customizada
procedure ConfirmarAcao(const ATitulo, AMensagem: string;
  AOnSim: TProc; AOnNao: TProc = nil);

// Exibir mensagem de sucesso
procedure MostrarSucesso(const AMensagem: string;
  AOnFechado: TProc = nil);

// Exibir mensagem de erro
procedure MostrarErro(const AMensagem: string;
  AOnFechado: TProc = nil);

// Pedir texto ao usuário
procedure PedirTexto(const ATitulo, APrompt, APadrao: string;
  AOnConfirmado: TProc<string>);

implementation

procedure ConfirmarExclusao(const AMensagem: string; AOnConfirmado: TProc);
begin
  TDialogService.MessageDialog(
    AMensagem,
    TMsgDlgType.mtWarning,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
    TMsgDlgBtn.mbNo,  // botão padrão = No (seguro)
    0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrYes then
        if Assigned(AOnConfirmado) then
          AOnConfirmado();
    end);
end;

procedure ConfirmarAcao(const ATitulo, AMensagem: string;
  AOnSim, AOnNao: TProc);
begin
  TDialogService.MessageDialog(
    AMensagem,
    TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
    TMsgDlgBtn.mbYes,
    0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrYes then
      begin
        if Assigned(AOnSim) then AOnSim();
      end
      else
      begin
        if Assigned(AOnNao) then AOnNao();
      end;
    end);
end;

procedure MostrarSucesso(const AMensagem: string; AOnFechado: TProc);
begin
  TDialogService.MessageDialog(
    AMensagem,
    TMsgDlgType.mtInformation,
    [TMsgDlgBtn.mbOK],
    TMsgDlgBtn.mbOK,
    0,
    procedure(const AResult: TModalResult)
    begin
      if Assigned(AOnFechado) then AOnFechado();
    end);
end;

procedure MostrarErro(const AMensagem: string; AOnFechado: TProc);
begin
  TDialogService.MessageDialog(
    AMensagem,
    TMsgDlgType.mtError,
    [TMsgDlgBtn.mbOK],
    TMsgDlgBtn.mbOK,
    0,
    procedure(const AResult: TModalResult)
    begin
      if Assigned(AOnFechado) then AOnFechado();
    end);
end;

procedure PedirTexto(const ATitulo, APrompt, APadrao: string;
  AOnConfirmado: TProc<string>);
begin
  TDialogService.InputQuery(
    ATitulo,
    [APrompt],
    [APadrao],
    procedure(const AResult: Boolean;
      const AValues: array of string)
    begin
      if AResult and (Length(AValues) > 0) then
        if Assigned(AOnConfirmado) then
          AOnConfirmado(AValues[0]);
    end);
end;

// ============================================================
// EXEMPLOS DE USO:
//
// // Confirmar exclusão:
// ConfirmarExclusao('Excluir cliente #123?', procedure
// begin
//   ExcluirCliente(123);
//   MostrarSucesso('Cliente excluído com sucesso.');
// end);
//
// // Confirmar com Sim/Não:
// ConfirmarAcao('Salvar', 'Salvar alterações pendentes?',
//   procedure begin Salvar; end,
//   procedure begin Cancelar; end);
//
// // Pedir código de autorização:
// PedirTexto('Autorização', 'Digite o código de autorização:', '',
//   procedure(const Codigo: string)
//   begin
//     if ValidarCodigo(Codigo) then
//       ExecutarOperacao
//     else
//       MostrarErro('Código inválido.');
//   end);
//
// POR QUE TDialogService:
//   - Thread-safe: pode ser chamado de TThread.Synchronize
//   - Cross-platform: Windows / macOS / iOS / Android
//   - Não bloqueia: usa callback assíncrono
//   - Application.MessageBox é Windows-only e bloqueia a UI thread
//
// TMSGDLGTYPE (ícone do diálogo):
//   mtWarning      — ícone de aviso (!)
//   mtError        — ícone de erro (X)
//   mtInformation  — ícone de informação (i)
//   mtConfirmation — ícone de interrogação (?)
//   mtCustom       — sem ícone
//
// TMODALRESULT:
//   mrOk = 1, mrCancel = 2, mrAbort = 3, mrRetry = 4,
//   mrIgnore = 5, mrYes = 6, mrNo = 7
// ============================================================

end.
