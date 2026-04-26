(*
  TEMPLATE: Módulo com Interface Pública + Factory
  Skill: developer-delphi-to-fpc-architecture-modules_V1.0.0

  INSTRUCOES DE USO:
    1. Substituir NOME_MODULO pelo nome do módulo (ex.: Clientes, Pagamento).
    2. Substituir EMPRESA pelo prefixo de namespace da empresa (ex.: GestorERP, Acme).
    3. Copiar e renomear:
         EMPRESA.NOME_MODULO.Interfaces.pas  ← interface pública
         EMPRESA.NOME_MODULO.Impl.pas        ← implementação (arquivo separado)
         EMPRESA.NOME_MODULO.Factory.pas     ← factory (arquivo separado)
    4. Substituir os GUIDs por novos (Ctrl+Shift+G no Delphi gera GUID novo).
    5. Adicionar métodos específicos do domínio.
    6. Compilar: dcc32 / dcc64 (Delphi) | fpc (FPC/Lazarus)

  NESTE ARQUIVO: interface + impl + factory juntos (para ser compilável standalone).
  Em um projeto real: separar em 3 arquivos .pas distintos.
*)
unit TEMPLATE_modulo_interface;
{$IFDEF FPC}
  {$mode delphi}
  {$H+}
{$ENDIF}

interface

uses
  SysUtils;

// =============================================================================
// ARQUIVO 1: EMPRESA.NOME_MODULO.Interfaces.pas
// Exportar APENAS esta seção para os consumidores.
// =============================================================================

type
  // Contrato público do módulo
  // Substituir GUID: Ctrl+Shift+G no Delphi IDE
  INOME_MODULO = interface
    ['{00000000-0000-0000-0000-000000000000}']  // SUBSTITUIR GUID

    // Operações do domínio — adaptar para o módulo real
    function Inicializar: Boolean;
    function Processar(const AEntrada: string): string;
    function Finalizar: Boolean;

    // Propriedades de estado
    function Ativo: Boolean;
    function UltimoErro: string;
  end;

  // Factory — ÚNICO ponto de criação do módulo
  // Consumidores usam APENAS esta classe + a interface acima
  TNOME_MODULOFactory = class
  public
    // Parâmetros: adaptar para configuração do módulo
    class function New(const AConfig: string = ''): INOME_MODULO;
  end;

// =============================================================================
// ARQUIVO 2: EMPRESA.NOME_MODULO.Impl.pas
// Implementação privada — consumidores NÃO referenciam esta unit diretamente.
// =============================================================================

// (Em arquivo separado, esta seção seria uma unit própria com interface/implementation)

type
  TNOME_MODULOImpl = class(TInterfacedObject, INOME_MODULO)
  private
    FAtivo: Boolean;
    FConfig: string;
    FUltimoErro: string;
  public
    constructor Create(const AConfig: string);
    destructor Destroy; override;

    // INOME_MODULO
    function Inicializar: Boolean;
    function Processar(const AEntrada: string): string;
    function Finalizar: Boolean;
    function Ativo: Boolean;
    function UltimoErro: string;
  end;

implementation

// =============================================================================
// Implementação de TNOME_MODULOImpl
// =============================================================================

constructor TNOME_MODULOImpl.Create(const AConfig: string);
begin
  inherited Create;
  FConfig := AConfig;
  FAtivo := False;
  FUltimoErro := '';
end;

destructor TNOME_MODULOImpl.Destroy;
begin
  // Liberar recursos do módulo
  if FAtivo then
    Finalizar;
  inherited;
end;

function TNOME_MODULOImpl.Inicializar: Boolean;
begin
  // Implementar inicialização real aqui
  // Ex.: conectar a banco, abrir arquivo, validar configuração
  try
    FAtivo := True;
    FUltimoErro := '';
    Result := True;
  except
    on E: Exception do
    begin
      FUltimoErro := E.Message;
      FAtivo := False;
      Result := False;
    end;
  end;
end;

function TNOME_MODULOImpl.Processar(const AEntrada: string): string;
begin
  if not FAtivo then
    raise Exception.Create('TNOME_MODULOImpl.Processar: módulo não inicializado');

  // Implementar lógica de processamento aqui
  // Adaptar para o domínio real do módulo
  try
    Result := Format('[%s processado] %s', [ClassName, AEntrada]);
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := E.Message;
      Result := '';
      raise;  // re-lançar para o chamador decidir como tratar
    end;
  end;
end;

function TNOME_MODULOImpl.Finalizar: Boolean;
begin
  // Implementar finalização real aqui
  // Ex.: fechar conexão, liberar recursos externos
  try
    FAtivo := False;
    FUltimoErro := '';
    Result := True;
  except
    on E: Exception do
    begin
      FUltimoErro := E.Message;
      Result := False;
    end;
  end;
end;

function TNOME_MODULOImpl.Ativo: Boolean;
begin
  Result := FAtivo;
end;

function TNOME_MODULOImpl.UltimoErro: string;
begin
  Result := FUltimoErro;
end;

// =============================================================================
// ARQUIVO 3: EMPRESA.NOME_MODULO.Factory.pas
// Factory pública — implementação da classe declarada na interface section
// =============================================================================

class function TNOME_MODULOFactory.New(const AConfig: string): INOME_MODULO;
begin
  // Aqui pode selecionar diferentes implementações com base em AConfig
  // Ex.: 'sqlite' → TSQLiteImpl, 'memory' → TMemoryImpl
  Result := TNOME_MODULOImpl.Create(AConfig);
end;

end.
