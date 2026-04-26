{ =============================================================================
  ExemploBasico.dpr / library_basic_exports.pas
  Exemplo compilável de projecto Library com Delphi e FPC.

  Demonstra:
    - Projecto library com exports por nome, alias e índice
    - Apenas tipos POD na interface (sem ShareMem)
    - DllProc para attach/detach (Windows)
    - GetLibraryVersion exportado
    - Comentários explicando cada decisão

  Para compilar (Delphi Win32):
    dcc32 ExemploBasico.dpr

  Para compilar (FPC Win64):
    fpc -Twin64 -Px86_64 ExemploBasico.dpr

  Para compilar (FPC Linux64):
    fpc -Tlinux -Px86_64 ExemploBasico.dpr
  ============================================================================= }

{ --- FICHEIRO .dpr (projecto library) --------------------------------------- }

library ExemploBasico;

{$R *.res}  // recursos: ícone, manifesto, informação de versão

// NOTA: NÃO incluímos ShareMem porque usamos apenas tipos POD na interface.
// Se precisar de passar TStringList ou string Delphi, adicionar ShareMem
// COMO PRIMEIRO item aqui E no .dpr do host.
uses
  {$IFDEF MSWINDOWS}
  Winapi.Windows,   // DLL_PROCESS_ATTACH, DLL_PROCESS_DETACH, etc.
  {$ENDIF}
  System.SysUtils,
  System.Math;

// -------------------------------------------------------------------------
// Constantes internas
// -------------------------------------------------------------------------
const
  // Versão codificada como inteiro — convenção YYYYMMDD
  // Permite comparação simples: if GetLibraryVersion >= 20260411 then ...
  LIBRARY_VERSION = 20260411;

  // Nome público para diagnóstico
  LIBRARY_NAME: PChar = 'ExemploBasico';

// -------------------------------------------------------------------------
// Variável para encadear DllProc anterior (boa prática)
// -------------------------------------------------------------------------
{$IFDEF MSWINDOWS}
var
  GSavedDLLProc: TDLLProc;
{$ENDIF}

// =========================================================================
// FUNÇÕES EXPORTADAS — apenas tipos POD
// =========================================================================

// -------------------------------------------------------------------------
// GetLibraryVersion
// Sempre exportar — facilita diagnóstico em campo sem abrir o binário.
// Convenção: inteiro YYYYMMDD ou Major*10000+Minor*100+Patch.
// -------------------------------------------------------------------------
function GetLibraryVersion: Integer;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
begin
  Result := LIBRARY_VERSION;
end;

// -------------------------------------------------------------------------
// GetLibraryName
// Devolve ponteiro para string literal — o caller NÃO deve libertar.
// Documentar sempre este detalhe no header / unit de interface.
// -------------------------------------------------------------------------
function GetLibraryName: PChar;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
begin
  Result := LIBRARY_NAME;
end;

// -------------------------------------------------------------------------
// SomarInteiros
// Função simples — demonstra passagem de Integer (tipo POD).
// -------------------------------------------------------------------------
function SomarInteiros(A, B: Integer): Integer;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
begin
  Result := A + B;
end;

// -------------------------------------------------------------------------
// CalcularMedia
// Demonstra array via ponteiro + tamanho — padrão C-style para arrays.
// O caller aloca e gere o array; a DLL apenas lê.
// -------------------------------------------------------------------------
function CalcularMedia(AValues: PDouble; ACount: Integer; out AMedia: Double): LongBool;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
var
  LSum: Double;
  I: Integer;
begin
  Result := False;
  AMedia := 0;

  // Validação defensiva — NUNCA confiar cegamente no caller
  if (AValues = nil) or (ACount <= 0) then
    Exit;

  LSum := 0;
  for I := 0 to ACount - 1 do
    LSum := LSum + PDouble(PByte(AValues) + I * SizeOf(Double))^;

  AMedia := LSum / ACount;
  Result := True;
end;

// -------------------------------------------------------------------------
// FormatarTexto
// Demonstra buffer PChar preenchido pela DLL.
// Padrão: caller fornece buffer + tamanho; DLL preenche e retorna bytes escritos.
// Retorna -1 se buffer insuficiente.
// -------------------------------------------------------------------------
function FormatarTexto(AValor: Integer; ABuffer: PChar; ABufferSize: Integer): Integer;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
var
  LTexto: string;
begin
  if (ABuffer = nil) or (ABufferSize <= 0) then
  begin
    Result := -1;
    Exit;
  end;

  LTexto := Format('Valor processado pela DLL: %d (v%d)', [AValor, LIBRARY_VERSION]);

  if Length(LTexto) + 1 > ABufferSize then
  begin
    Result := -(Length(LTexto) + 1); // sinaliza tamanho necessário como negativo
    Exit;
  end;

  // StrPLCopy garante null-terminator e respeita o tamanho do buffer
  StrPLCopy(ABuffer, LTexto, ABufferSize - 1);
  Result := Length(LTexto);
end;

// -------------------------------------------------------------------------
// ProcessarComHandle (opaque handle pattern)
// A DLL aloca um objecto interno e devolve um Pointer opaco.
// O caller só passa este pointer de volta — nunca o desreferencia.
// A DLL liberta via DestruirHandle.
// -------------------------------------------------------------------------
type
  // Estrutura interna — invisível ao caller
  TContextoInterno = record
    ID: Integer;
    Acumulador: Double;
    Contagem: Integer;
  end;
  PContextoInterno = ^TContextoInterno;

function CriarHandle(AID: Integer): Pointer;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
var
  LCtx: PContextoInterno;
begin
  New(LCtx); // alocado no heap DESTA DLL
  LCtx^.ID := AID;
  LCtx^.Acumulador := 0;
  LCtx^.Contagem := 0;
  Result := LCtx;
end;

function AdicionarValor(AHandle: Pointer; AValor: Double): LongBool;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
var
  LCtx: PContextoInterno;
begin
  Result := False;
  if AHandle = nil then Exit;
  LCtx := PContextoInterno(AHandle);
  LCtx^.Acumulador := LCtx^.Acumulador + AValor;
  Inc(LCtx^.Contagem);
  Result := True;
end;

function ObterMedia(AHandle: Pointer; out AMedia: Double): LongBool;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
var
  LCtx: PContextoInterno;
begin
  Result := False;
  AMedia := 0;
  if AHandle = nil then Exit;
  LCtx := PContextoInterno(AHandle);
  if LCtx^.Contagem = 0 then Exit;
  AMedia := LCtx^.Acumulador / LCtx^.Contagem;
  Result := True;
end;

procedure DestruirHandle(AHandle: Pointer);
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
var
  LCtx: PContextoInterno;
begin
  if AHandle = nil then Exit;
  LCtx := PContextoInterno(AHandle);
  Dispose(LCtx); // libertado no heap DESTA DLL — correcto
end;

// =========================================================================
// DllProc — notificações do SO (Windows apenas)
// Em Linux, usar initialization/finalization para setup/cleanup.
// =========================================================================
{$IFDEF MSWINDOWS}
procedure DLLHandler(Reason: Integer);
begin
  case Reason of
    DLL_PROCESS_ATTACH:
      begin
        // DLL carregada no processo.
        // - Inicializar recursos globais thread-safe aqui.
        // - NUNCA chamar LoadLibrary (deadlock no Loader Lock).
        // - NUNCA criar janelas (sem HWND disponível ainda).
        // - Manter o código mínimo — SO aguarda retorno.
      end;

    DLL_PROCESS_DETACH:
      begin
        // DLL prestes a ser descarregada.
        // - Libertar todos os recursos alocados globalmente.
        // - Fechar handles de ficheiros, sockets, etc.
        // - Manter mínimo — SO pode terminar o processo logo após.
      end;

    DLL_THREAD_ATTACH:
      begin
        // Nova thread criada no processo host.
        // A maioria das DLLs não precisa reagir a este evento.
      end;

    DLL_THREAD_DETACH:
      begin
        // Thread terminou.
        // Libertar TLS (Thread Local Storage) se alocado em THREAD_ATTACH.
      end;
  end;

  // Encadear com o DllProc anterior (pode ser do RTL Delphi)
  if Assigned(GSavedDLLProc) then
    GSavedDLLProc(Reason);
end;
{$ENDIF}

// =========================================================================
// Cláusula EXPORTS — define o nome público de cada função
// =========================================================================
exports
  // Por nome simples — nome público = nome Pascal
  GetLibraryVersion,
  GetLibraryName,
  SomarInteiros,
  CalcularMedia,
  FormatarTexto,

  // Opaque handle API — convenção: Criar/Adicionar/Obter/Destruir
  CriarHandle,
  AdicionarValor,
  ObterMedia,
  DestruirHandle,

  // Alias — nome público diferente do nome Pascal (retrocompatibilidade)
  SomarInteiros name 'Add',        // exporta "Add" como alias de SomarInteiros
  GetLibraryVersion index 1;       // também acessível por índice 1

// =========================================================================
// Inicialização / Finalização
// =========================================================================
initialization
  {$IFDEF MSWINDOWS}
  // Registar DllProc ANTES de qualquer inicialização do RTL
  GSavedDLLProc := DLLProc;
  DLLProc := @DLLHandler;
  DLLHandler(DLL_PROCESS_ATTACH);
  {$ENDIF}
  // Inicializações globais cross-platform aqui

finalization
  {$IFDEF MSWINDOWS}
  DLLHandler(DLL_PROCESS_DETACH);
  {$ENDIF}
  // Cleanup global cross-platform aqui

end.
