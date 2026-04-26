unit TEMPLATE_debug_helper;
(*
  TEMPLATE: Debug Helper Unit
  Skill: developer-delphi-debugging-techniques_V1.0.0

  INSTRUCOES DE USO:
    1. Copiar este arquivo para seu projeto com nome adequado, ex.: uDebugHelper.pas
    2. Adicionar na secao uses do .dpr ou da unit que precisar de debug.
    3. Todas as chamadas sao protegidas por {$IFDEF DEBUG} — zero overhead em Release.
    4. REMOVER as chamadas DumpXxx antes de commit em producao.
    5. Compilar: dcc32 / dcc64 (Delphi) | fpc (FPC/Lazarus)

  FUNCOES DISPONIVEIS:
    DebugLog(AMsg)                  — OutputDebugString simples
    DebugLogFmt(AFmt, AArgs)        — com formatacao
    DumpObject(AObj)                — descreve classe e endereco do objeto
    DumpList(AList)                 — conta e descreve itens de TList/TObjectList
    DumpStringList(AList)           — exibe todos os itens de TStrings
    AssertMainThread                — assert que estamos na thread principal
    AssertNotNil(APtr, AName)       — assert que ponteiro nao e nil
    DebugSeparator(ALabel)          — linha separadora no log para organizar saida
*)
{$IFDEF FPC}
  {$mode delphi}
  {$H+}
{$ENDIF}

interface

uses
  SysUtils, Classes
  {$IFDEF MSWINDOWS}, Windows{$ENDIF};

// --- Logging ---

procedure DebugLog(const AMsg: string);
procedure DebugLogFmt(const AFmt: string; const AArgs: array of const);
procedure DebugSeparator(const ALabel: string = '');

// --- Inspecao de objetos ---

procedure DumpObject(const AObj: TObject; const ALabel: string = '');
procedure DumpList(const AList: TList; const ALabel: string = '');
procedure DumpObjectList(const AList: TObjectList; const ALabel: string = '');
procedure DumpStringList(const AList: TStrings; const ALabel: string = '');

// --- Asserts de debug ---

procedure AssertMainThread(const AContext: string = '');
procedure AssertNotNil(const APtr: Pointer; const AName: string);
procedure AssertRange(const AValue, AMin, AMax: Integer; const AName: string);

implementation

var
  GMainThreadID: TThreadID;

// =============================================================================
// Logging
// =============================================================================

procedure DebugLog(const AMsg: string);
begin
  {$IFDEF DEBUG}
  {$IFDEF MSWINDOWS}
  OutputDebugString(PChar('[DBG] ' + AMsg));
  {$ELSE}
  WriteLn(ErrOutput, '[DBG] ' + AMsg);
  {$ENDIF}
  {$ENDIF}
end;

procedure DebugLogFmt(const AFmt: string; const AArgs: array of const);
begin
  {$IFDEF DEBUG}
  DebugLog(Format(AFmt, AArgs));
  {$ENDIF}
end;

procedure DebugSeparator(const ALabel: string = '');
begin
  {$IFDEF DEBUG}
  if ALabel = '' then
    DebugLog('---------------------------------------------------')
  else
    DebugLog('--- ' + ALabel + ' ' + StringOfChar('-', 40 - Length(ALabel)));
  {$ENDIF}
end;

// =============================================================================
// Inspecao de objetos
// =============================================================================

procedure DumpObject(const AObj: TObject; const ALabel: string = '');
begin
  {$IFDEF DEBUG}
  if AObj = nil then
  begin
    DebugLogFmt('DumpObject [%s]: NIL', [ALabel]);
    Exit;
  end;
  DebugLogFmt('DumpObject [%s]: Class=%s | Addr=0x%p | RefCount=%d',
    [ALabel,
     AObj.ClassName,
     Pointer(AObj),
     // RefCount so disponivel em TInterfacedObject
     PInteger(PByte(AObj) + SizeOf(Pointer))^
    ]);
  {$ENDIF}
end;

procedure DumpList(const AList: TList; const ALabel: string = '');
begin
  {$IFDEF DEBUG}
  if AList = nil then
  begin
    DebugLogFmt('DumpList [%s]: NIL', [ALabel]);
    Exit;
  end;
  DebugLogFmt('DumpList [%s]: Count=%d | Capacity=%d',
    [ALabel, AList.Count, AList.Capacity]);
  {$ENDIF}
end;

procedure DumpObjectList(const AList: TObjectList; const ALabel: string = '');
var
  I: Integer;
begin
  {$IFDEF DEBUG}
  if AList = nil then
  begin
    DebugLogFmt('DumpObjectList [%s]: NIL', [ALabel]);
    Exit;
  end;
  DebugLogFmt('DumpObjectList [%s]: Count=%d | OwnsObjects=%s',
    [ALabel, AList.Count, BoolToStr(AList.OwnsObjects, True)]);
  for I := 0 to AList.Count - 1 do
  begin
    if AList[I] <> nil then
      DebugLogFmt('  [%d] Class=%s Addr=0x%p', [I, AList[I].ClassName, Pointer(AList[I])])
    else
      DebugLogFmt('  [%d] NIL', [I]);
  end;
  {$ENDIF}
end;

procedure DumpStringList(const AList: TStrings; const ALabel: string = '');
var
  I: Integer;
begin
  {$IFDEF DEBUG}
  if AList = nil then
  begin
    DebugLogFmt('DumpStringList [%s]: NIL', [ALabel]);
    Exit;
  end;
  DebugLogFmt('DumpStringList [%s]: Count=%d', [ALabel, AList.Count]);
  for I := 0 to AList.Count - 1 do
    DebugLogFmt('  [%d] "%s"', [I, AList[I]]);
  {$ENDIF}
end;

// =============================================================================
// Asserts de debug
// =============================================================================

procedure AssertMainThread(const AContext: string = '');
begin
  {$IFDEF DEBUG}
  if GetCurrentThreadId <> GMainThreadID then
    raise Exception.CreateFmt(
      'AssertMainThread falhou [%s]: chamado da thread %d (esperado: %d)',
      [AContext, GetCurrentThreadId, GMainThreadID]);
  {$ENDIF}
end;

procedure AssertNotNil(const APtr: Pointer; const AName: string);
begin
  {$IFDEF DEBUG}
  if APtr = nil then
    raise Exception.CreateFmt(
      'AssertNotNil falhou: "%s" e nil', [AName]);
  {$ENDIF}
end;

procedure AssertRange(const AValue, AMin, AMax: Integer; const AName: string);
begin
  {$IFDEF DEBUG}
  if (AValue < AMin) or (AValue > AMax) then
    raise Exception.CreateFmt(
      'AssertRange falhou: "%s"=%d nao esta em [%d..%d]',
      [AName, AValue, AMin, AMax]);
  {$ENDIF}
end;

// =============================================================================
// Inicializacao
// =============================================================================

initialization
  GMainThreadID := GetCurrentThreadId;

end.
