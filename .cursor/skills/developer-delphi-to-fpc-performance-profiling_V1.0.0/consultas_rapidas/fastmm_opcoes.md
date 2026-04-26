# FastMM5 — Opcoes e Modos de Operacao

**Skill:** developer-delphi-to-fpc-performance-profiling_V1.0.0
**Referencia:** `exemplos/fastmm5_config.pas`

---

## Modos principais

| Modo | Quando usar | Overhead |
|------|-------------|----------|
| **Producao (padrao)** | Build de producao; sem diagnostico | ~0% |
| **FullDebugMode** | Diagnostico de leaks com stack trace | ~3-5x mais lento |
| **LogToFile apenas** | CI/build de teste; sem interrupcao de UI | ~5% |

---

## Opcoes booleanas essenciais

```pascal
// Habilitar log em arquivo (NomeProjeto_MemoryManager_EventLog.txt)
FastMM_LogToFile := True;

// Enviar mensagens para OutputDebugString (visivel no debugger / DebugView)
FastMM_OutputDebugString := True;

// DESABILITAR MessageBox — obrigatorio para servicos e headless
FastMM_MessageBoxes := False;

// Entrar em FullDebugMode (registra stack trace de cada alocacao)
FastMM_EnterDebugMode;

// Sair do FullDebugMode (voltar a modo normal)
FastMM_ExitDebugMode;
```

---

## Localizacao do arquivo de log

```
<DiretorioExe>\<NomeProjeto>_MemoryManager_EventLog.txt
```

Exemplo de entrada de leak no log:
```
A memory block of 48 bytes was allocated at address 0x00AB1234 and was not freed.
The allocation number was 42.
Stack trace of when the block was allocated:
  [0] ... TMinhaClasse.Create
  [1] ... TServico.Inicializar
  ...
```

---

## Configuracao recomendada por ambiente

### Build de diagnostico (dev / CI)

```pascal
uses FastMM5;

// Antes de Application.Initialize no .dpr:
FastMM_LogToFile         := True;
FastMM_OutputDebugString := True;
FastMM_MessageBoxes      := False;
FastMM_EnterDebugMode;   // stack traces completos
```

### Build de producao

```pascal
// FastMM5 e incluido apenas para gerenciamento de memoria rapido.
// NÃO habilitar DebugMode; NÃO habilitar LogToFile por padrao.
// ReportMemoryLeaksOnShutdown (RTL) pode ser usado como alternativa leve:
ReportMemoryLeaksOnShutdown := {$IFDEF DEBUG} True {$ELSE} False {$ENDIF};
```

---

## FastMM4 vs FastMM5

| Aspecto | FastMM4 | FastMM5 |
|---------|---------|---------|
| Suporte ativo | Descontinuado | Sim (Pierre le Riche) |
| Thread safety | Parcial | Completo (lock-free) |
| API de configuracao | Global vars | Global vars (compativel) |
| GetIt Package | Sim | Sim |
| FPC | Nao | Nao (Delphi only) |

**FPC:** usar HeapTrc (`-gh` ou `uses HeapTrc`) e CMem (`uses CMem`).

---

## Verificar instalacao

```pascal
// Se FastMM5 estiver no Search Path, isso compila:
uses FastMM5;
// Versao: ver FastMM5.pas cabecalho — ex.: "Version 5.03"
```

Instalar via GetIt: **Tools > GetIt Package Manager > pesquisar "FastMM5"**.
Ou copiar `FastMM5.pas` para o Search Path do projeto.
