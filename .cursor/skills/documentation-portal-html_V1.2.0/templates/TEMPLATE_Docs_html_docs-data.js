// internal_file_version: 1.0.0 | política: .cursor/VERSION.md
// =============================================================================
// docs-data.js — Dados da documentação do {PROJETO_NOME}
// Carregado por {DocsRaiz}/html/index.html (ex.: Documentation/html/index.html) — ver skill documentation-portal-html
// =============================================================================
// INSTRUÇÕES:
//   1. Preencher PROJECT_* com os dados do projeto.
//   2. Editar MODULES[] com um objeto por módulo (ver estrutura abaixo).
//   3. Editar DATABASE_TYPES[] com os bancos suportados.
//   4. Editar ENGINES[] com as engines/diretivas disponíveis.
//   5. Editar EXAMPLES[] com os projetos de exemplo.
// =============================================================================

const PROJECT_NAME    = '{PROJETO_NOME}';
const PROJECT_VERSION = '{X.Y.Z}';
const PROJECT_DATE    = 'DD/MM/AAAA';
const PROJECT_AUTHOR  = '{Nome do Autor}';

// ---------------------------------------------------------------------------
// Módulos do projeto
// ---------------------------------------------------------------------------
// Campos obrigatórios: id, name, icon, desc, path
// Campos opcionais:    interfaces[], classes[], files[], features[], example, note, analise[]
// ---------------------------------------------------------------------------
const MODULES = [
  {
    id:         '{modulo-id}',            // identificador único (sem espaços, lowercase)
    name:       '{Nome do Módulo}',
    icon:       '🔌',                     // emoji representativo
    desc:       '{Descrição curta — Interface / Classe principal}',
    interfaces: ['{IClassName}'],
    classes:    ['{TClassName}'],
    path:       'src/{Caminho}/',
    files: [
      '{Unit}.Interfaces.pas',
      '{Unit}.pas',
    ],
    analise: [
      'Analise/{Modulo}/{ClassName}.md',
    ],
    features: [
      '{Funcionalidade 1}',
      '{Funcionalidade 2}',
      '{Funcionalidade 3}',
    ],
    example: `{Exemplo de código Pascal/Delphi/FPC}`,
    note: '{Aviso opcional — ex.: diretiva necessária}',  // remover se não houver
  },

  // Repetir bloco acima para cada módulo adicional
  // {
  //   id: '...',
  //   ...
  // },
];

// ---------------------------------------------------------------------------
// Tipos de banco suportados
// ---------------------------------------------------------------------------
const DATABASE_TYPES = [
  { const: 'dt{Banco}',  name: '{Nome do Banco}',  dll: '{DLL ou driver necessário}' },
  // Adicionar entradas conforme os bancos suportados
];

// ---------------------------------------------------------------------------
// Engines disponíveis (um por compilação via {ArquivoDeDefines})
// ---------------------------------------------------------------------------
// status: 'ativo' | 'suporte' | 'pausado'
const ENGINES = [
  { define: 'USE_{ENGINE}',  name: '{Nome do Engine}', status: 'ativo',   note: '{Observação}' },
  { define: 'USE_{ENGINE2}', name: '{Nome do Engine2}',status: 'suporte', note: '{Observação}' },
];

// ---------------------------------------------------------------------------
// Exemplos disponíveis em Exemplos/
// ---------------------------------------------------------------------------
const EXAMPLES = [
  {
    name: '{ExemploProjeto}.dpr',
    path: 'Exemplos/{Categoria}/',
    desc: '{Descrição do que o exemplo demonstra}',
  },
  // Adicionar entradas para cada projeto de exemplo
];
