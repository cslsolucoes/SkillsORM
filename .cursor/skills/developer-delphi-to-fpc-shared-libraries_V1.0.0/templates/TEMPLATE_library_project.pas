{ =============================================================================
  TEMPLATE_library_project.pas
  Template completo de projecto Library Delphi/FPC.

  Como usar:
    1. Substituir {LIBRARY_NAME} pelo nome da DLL (ex.: GestorCore)
    2. Substituir {UNIT_IMPL} pelo nome da unit de implementação
    3. Decidir a estratégia de memória (ver comentário DECISÃO_MEMORIA)
    4. Ajustar a cláusula exports conforme as funções do projecto
    5. Implementar inicialização/finalização se necessário

  Placeholders:
    {LIBRARY_NAME}   — nome do projecto (sem extensão)
    {UNIT_IMPL}      — nome da unit de implementação (sem .pas)
    {SHARED_UNIT}    — unit de interfaces partilhada (ex.: PluginInterfaces)
    {VERSION_INT}    — versão como inteiro YYYYMMDD (ex.: 20260411)
    {VERSION_STR}    — versão como string (ex.: '2026.04.11')
    {COMPANY}        — nome da empresa/equipa
  ============================================================================= }

library {LIBRARY_NAME};

{$R *.res}  // recursos: ícone, manifesto, informação de versão

{ ---------------------------------------------------------------------------
  DECISÃO_MEMORIA — escolher UMA das opções abaixo e remover as outras:

  OPÇÃO A: ShareMem (apenas Windows, host Delphi, mesmo processo)
    → Descomente a linha ShareMem abaixo.
    → Adicionar ShareMem como PRIMEIRO item no .dpr do host também.
    → Incluir BORLNDMM.DLL no installer.

  OPÇÃO B: Apenas POD / Opaque Handle (cross-platform, qualquer host)
    → Não incluir ShareMem.
    → NUNCA retornar string, TObject, ou TArray dinâmico pela fronteira.
    → Usar PChar + buffer caller-allocated para strings.

  OPÇÃO C: Interface approach (Delphi ↔ Delphi, via IPlugin)
    → Não incluir ShareMem.
    → Exportar apenas factories que retornam IInterface.
    → Usar WideString (não string) nos métodos de interface.
  --------------------------------------------------------------------------- }

uses
  // OPÇÃO A: Descomentar a linha abaixo (deve ser o PRIMEIRO item)
  // ShareMem,

  {$IFDEF MSWINDOWS}
  Winapi.Windows,     // DLL_PROCESS_ATTACH, etc.
  {$ENDIF}
  System.SysUtils,
  System.Classes,

  // Unit de implementação interna (não visível ao caller)
  {UNIT_IMPL} in '{UNIT_IMPL}.pas'

  // Unit de interfaces partilhada (se usar interface approach)
  // {SHARED_UNIT} in '..\shared\{SHARED_UNIT}.pas'
  ;

// ===========================================================================
// CONSTANTES INTERNAS
// ===========================================================================
const
  LIB_VERSION_INT: Integer = {VERSION_INT};  // ex.: 20260411
  LIB_VERSION_STR: PChar   = '{VERSION_STR}'; // ex.: '2026.04.11'
  LIB_NAME:        PChar   = '{LIBRARY_NAME}';

// ===========================================================================
// DllProc (Windows apenas)
// ===========================================================================
{$IFDEF MSWINDOWS}
var
  GDLLProcSaved: TDLLProc;

procedure DLLEntryPoint(Reason: Integer);
begin
  case Reason of
    DLL_PROCESS_ATTACH:
      begin
        // Inicializar recursos globais da DLL.
        // REGRAS:
        //   - NÃO chamar LoadLibrary (deadlock no Loader Lock)
        //   - NÃO criar janelas
        //   - NÃO iniciar threads pesadas
        //   - Manter mínimo — o SO espera retorno rápido
        // {INIT_CODE}
      end;

    DLL_PROCESS_DETACH:
      begin
        // Libertar recursos globais.
        // REGRAS:
        //   - Fechar handles abertos
        //   - Libertar memória global
        //   - O processo pode estar a terminar — manter mínimo
        // {CLEANUP_CODE}
      end;

    DLL_THREAD_ATTACH:
      begin
        // Raramente necessário — nova thread criada no host.
        // {THREAD_ATTACH_CODE}
      end;

    DLL_THREAD_DETACH:
      begin
        // Thread terminou — libertar TLS se usado.
        // {THREAD_DETACH_CODE}
      end;
  end;

  if Assigned(GDLLProcSaved) then
    GDLLProcSaved(Reason);
end;
{$ENDIF}

// ===========================================================================
// FUNÇÕES EXPORTADAS
// ===========================================================================

// ---------------------------------------------------------------------------
// Get{LIBRARY_NAME}Version
// SEMPRE exportar — facilita diagnóstico sem abrir o binário.
// ---------------------------------------------------------------------------
function Get{LIBRARY_NAME}Version: Integer;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
begin
  Result := LIB_VERSION_INT;
end;

// ---------------------------------------------------------------------------
// Get{LIBRARY_NAME}VersionString
// Retorna ponteiro para string literal — caller NÃO deve libertar.
// ---------------------------------------------------------------------------
function Get{LIBRARY_NAME}VersionString: PChar;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
begin
  Result := LIB_VERSION_STR;
end;

// ---------------------------------------------------------------------------
// Create{LIBRARY_NAME}
// Factory — cria uma instância da implementação e retorna handle opaco.
// O caller DEVE chamar Destroy{LIBRARY_NAME} quando terminar.
// ---------------------------------------------------------------------------
function Create{LIBRARY_NAME}(out AHandle: Pointer): LongBool;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
begin
  Result := False;
  AHandle := nil;
  try
    AHandle := T{UNIT_IMPL}Impl.Create; // cria no heap desta DLL
    Result := True;
  except
    // Nunca propagar excepções pela fronteira da DLL
    // (o host pode não ter o mesmo RTL de excepções)
    Result := False;
  end;
end;

// ---------------------------------------------------------------------------
// Destroy{LIBRARY_NAME}
// Liberta o handle criado por Create{LIBRARY_NAME}.
// Seguro chamar com nil (no-op).
// ---------------------------------------------------------------------------
procedure Destroy{LIBRARY_NAME}(AHandle: Pointer);
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
begin
  if AHandle <> nil then
  try
    T{UNIT_IMPL}Impl(AHandle).Free; // liberta no heap desta DLL — correcto
  except
    // Silenciar excepções no destroy — o processo pode estar a terminar
  end;
end;

// ---------------------------------------------------------------------------
// {LIBRARY_NAME}_Execute
// Ponto de entrada principal — exemplo com buffer pattern para resultado string.
// ---------------------------------------------------------------------------
function {LIBRARY_NAME}_Execute(
  AHandle: Pointer;
  AInput: Integer;
  AResultBuffer: PChar;
  ABufferSize: Integer): Integer;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
var
  LImpl: T{UNIT_IMPL}Impl;
  LResult: string;
begin
  Result := -1;
  if AHandle = nil then Exit;
  try
    LImpl := T{UNIT_IMPL}Impl(AHandle);
    LResult := LImpl.Execute(AInput);

    if (AResultBuffer = nil) or (ABufferSize = 0) then
    begin
      Result := -(Length(LResult) + 1); // indica tamanho necessário como negativo
      Exit;
    end;

    if Length(LResult) + 1 > ABufferSize then
    begin
      Result := -(Length(LResult) + 1);
      Exit;
    end;

    StrPLCopy(AResultBuffer, LResult, ABufferSize - 1);
    Result := Length(LResult);
  except
    Result := -1; // erro genérico — nunca propagar excepção
  end;
end;

// ===========================================================================
// CLÁUSULA EXPORTS
// ===========================================================================
exports
  // Versão — sempre primeiro, facilita diagnóstico
  Get{LIBRARY_NAME}Version,
  Get{LIBRARY_NAME}VersionString,

  // Ciclo de vida do objecto principal
  Create{LIBRARY_NAME},
  Destroy{LIBRARY_NAME},

  // Operações
  {LIBRARY_NAME}_Execute,

  // Aliases para retrocompatibilidade (manter exports antigos)
  // FuncaoAntiga name '{LIBRARY_NAME}_FuncaoAntiga',

  // Por índice (opcional — para carregamento mais rápido)
  Get{LIBRARY_NAME}Version index 1;

// ===========================================================================
// INICIALIZAÇÃO / FINALIZAÇÃO (cross-platform)
// ===========================================================================
initialization
  {$IFDEF MSWINDOWS}
  GDLLProcSaved := DLLProc;
  DLLProc := @DLLEntryPoint;
  DLLEntryPoint(DLL_PROCESS_ATTACH);
  {$ENDIF}
  // Inicializações cross-platform aqui (se necessário)
  // Ex.: TMonitor.Enter(GInitLock); GInitialized := True; TMonitor.Exit(GInitLock);

finalization
  {$IFDEF MSWINDOWS}
  DLLEntryPoint(DLL_PROCESS_DETACH);
  {$ENDIF}
  // Cleanup cross-platform aqui

end.
