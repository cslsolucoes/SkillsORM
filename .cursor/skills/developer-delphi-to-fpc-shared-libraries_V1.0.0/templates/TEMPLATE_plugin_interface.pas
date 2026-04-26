{ =============================================================================
  TEMPLATE_plugin_interface.pas
  Template de unit de interface de plugin partilhada.

  Esta unit é compilada em AMBOS os lados:
    - No host (aplicação principal) — para carregar e usar plugins
    - Em cada DLL/plugin — para implementar a interface

  IMPORTANTE: Esta unit NÃO deve ser linkada como dependência de compilação
  entre host e plugin. Cada lado compila a sua própria cópia.
  O contrato é mantido pelo GUID das interfaces.

  Como usar:
    1. Substituir {PLUGIN_FAMILY} pelo nome da família de plugins
       (ex.: GestorERP, RelatorioDomain, ImportacaoModule)
    2. Gerar novos GUIDs (Ctrl+Shift+G no RAD Studio) para cada interface
    3. Definir a versão mínima do host em PLUGIN_MIN_HOST_VERSION
    4. Adicionar métodos às interfaces conforme o domínio
    5. Criar IPlugin2 (e superiores) para extensões futuras

  Placeholders:
    {PLUGIN_FAMILY}  — família/domínio do plugin (ex.: GestorERP)
    {GUID_V1}        — GUID gerado para IPlugin (Ctrl+Shift+G)
    {GUID_V2}        — GUID gerado para IPlugin2
    {GUID_V3}        — GUID gerado para IPlugin3
  ============================================================================= }

unit {PLUGIN_FAMILY}PluginInterfaces;

interface

// ===========================================================================
// CONSTANTES DO PROTOCOLO
// ===========================================================================
const
  // Versão do protocolo de interface — inteiro YYYYMMDD
  // Incrementar a cada mudança incompatível no protocolo.
  // Host e plugin DEVEM concordar na versão mínima.
  PLUGIN_VERSION          = 20260411;

  // Versão mínima do host que o plugin suporta
  // Plugins com PLUGIN_MIN_HOST_VERSION > versão do host serão rejeitados.
  PLUGIN_MIN_HOST_VERSION = 20260101;

  // Categoria do plugin — string literal para diagnóstico
  PLUGIN_CATEGORY_PREFIX  = '{PLUGIN_FAMILY}';

// ===========================================================================
// INTERFACES
// ===========================================================================
type

  // =========================================================================
  // I{PLUGIN_FAMILY}Plugin — interface base V1
  //
  // REGRAS DE DESIGN:
  //   1. Todos os métodos com WideString (não string Delphi) — COM-safe
  //   2. GUID obrigatório — necessário para Supports() e QueryInterface()
  //   3. Nunca passar TObject, TList, string Delphi pela interface
  //   4. Métodos que podem falhar: retornar Boolean ou usar out param de erro
  // =========================================================================
  I{PLUGIN_FAMILY}Plugin = interface
    ['{GUID_V1}']
    // --- Metadados do plugin ---

    // Nome legível do plugin — ex.: 'ImportacaoNF'
    function GetName: WideString;

    // Versão interna do plugin como inteiro YYYYMMDD
    function GetVersion: Integer;

    // Descrição resumida — uma linha
    function GetDescription: WideString;

    // Categoria do plugin — deve começar com PLUGIN_CATEGORY_PREFIX
    // ex.: 'GestorERP.Importacao.NF'
    function GetCategory: WideString;

    // --- Compatibilidade ---

    // Verificar se este plugin funciona com a versão do host.
    // Host passa PLUGIN_VERSION; plugin verifica contra PLUGIN_MIN_HOST_VERSION.
    // Retorna False → plugin será ignorado/rejeitado pelo PluginManager.
    function IsCompatible(AHostVersion: Integer): Boolean;

    // --- Ciclo de vida ---

    // Inicializar o plugin com contexto do host.
    // Chamado antes de Execute.
    // AConfig: JSON de configuração fornecida pelo host.
    // Retorna True em sucesso, False em falha.
    function Initialize(const AConfig: WideString): Boolean;

    // Libertar recursos e preparar para descarregamento.
    // Chamado pelo PluginManager antes de FreeLibrary.
    procedure Shutdown;

    // --- Execução ---

    // Ponto de entrada principal.
    // AContext: identificador de operação ou JSON com payload
    // Ex.: 'GestorERP:importar:NF:12345' ou '{"op":"importar","id":12345}'
    // Retorna True em sucesso.
    function Execute(const AContext: WideString): Boolean;

    // Obter resultado da última execução como WideString (JSON ou texto)
    function GetLastResult: WideString;

    // Obter mensagem de erro da última operação falhada
    function GetLastError: WideString;
  end;

  // =========================================================================
  // I{PLUGIN_FAMILY}Plugin2 — interface estendida V2
  //
  // Extends V1 sem quebrar compatibilidade.
  // Hosts antigos ignoram esta interface; hosts novos verificam com Supports().
  // Plugins antigos que não implementam V2 ainda funcionam via V1.
  // =========================================================================
  I{PLUGIN_FAMILY}Plugin2 = interface(I{PLUGIN_FAMILY}Plugin)
    ['{GUID_V2}']
    // --- Metadados estendidos ---
    function GetAuthor: WideString;
    function GetLicense: WideString;           // ex.: 'MIT', 'Proprietary'
    function GetHomepageURL: WideString;

    // --- Configuração dinâmica ---
    // Reconfigurar sem reiniciar — suporta hot-reload de configuração
    function Reconfigure(const AConfig: WideString): Boolean;

    // --- Capacidades declaradas pelo plugin ---
    // Retorna JSON: {"supportsAsync":true,"supportsCancel":true,...}
    function GetCapabilities: WideString;

    // --- Execução assíncrona (se suportada) ---
    // Retorna um ID de tarefa; usar GetTaskStatus para monitorizar
    function ExecuteAsync(const AContext: WideString): Integer;

    // Verificar estado de tarefa assíncrona
    // ATaskID: ID retornado por ExecuteAsync
    // Retorna: 0=pendente, 1=concluído, 2=falhou, -1=ID inválido
    function GetTaskStatus(ATaskID: Integer): Integer;

    // Cancelar tarefa assíncrona em curso
    function CancelTask(ATaskID: Integer): Boolean;
  end;

  // =========================================================================
  // I{PLUGIN_FAMILY}Plugin3 — interface estendida V3 (placeholder futuro)
  //
  // Adicionar quando necessário — manter comentado até definir os métodos.
  // =========================================================================
  // I{PLUGIN_FAMILY}Plugin3 = interface(I{PLUGIN_FAMILY}Plugin2)
  //   ['{GUID_V3}']
  //   // ... métodos futuros ...
  // end;

  // =========================================================================
  // Tipo da factory exportada pela DLL
  // Calling convention cross-platform.
  // =========================================================================
  T{PLUGIN_FAMILY}PluginFactory = function: I{PLUGIN_FAMILY}Plugin;
    {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

  // =========================================================================
  // T{PLUGIN_FAMILY}PluginInfo — record de metadados sem interface
  // (para listar plugins sem instanciar)
  // =========================================================================
  T{PLUGIN_FAMILY}PluginInfo = record
    Name: WideString;
    Version: Integer;
    Category: WideString;
    HasV2: Boolean;
    Path: WideString;
  end;

implementation
end.

{ =============================================================================
  Exemplo de GUID gerado — substituir pelos reais (Ctrl+Shift+G):
  {GUID_V1} = '{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}'
  {GUID_V2} = '{B2C3D4E5-F6A7-8901-BCDE-F12345678901}'

  Verificar se o GUID é único antes de usar:
  - Cada interface em todo o ecossistema deve ter GUID único
  - Dois interfaces com o mesmo GUID causam colisão no QueryInterface
  ============================================================================= }
