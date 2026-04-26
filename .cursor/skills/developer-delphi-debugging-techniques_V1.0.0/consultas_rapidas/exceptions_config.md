# Configuração de Exceções no Debugger Delphi

**Skill:** `developer-delphi-debugging-techniques_V1.0.0`
**Data:** 2026-04-11

---

## Onde configurar

**Tools → Options → Debugger → Embarcadero Debuggers → Language Exceptions**

(RAD Studio 10.x+: Tools → Options → IDE → Debugger Options → Language Exceptions)

---

## Comportamentos configuráveis

| Configuração | Efeito |
|-------------|--------|
| **Stop on Delphi exceptions** | Para em TODA exceção Delphi, mesmo as tratadas por `except` |
| **Ignore subsequent exceptions** | Após parar uma vez, ignorar exceções do mesmo tipo |
| **Handle subsequent exceptions** | Continuar parando em cada ocorrência |

---

## Adicionar exceção específica para monitorar

1. Abrir Language Exceptions (caminho acima).
2. Clicar em **Add**.
3. Digitar o nome da classe de exceção: `EAccessViolation`
4. Selecionar ação: **Stop** (parar) ou **Log** (registrar sem parar).
5. Confirmar.

**Exemplos de exceções úteis para monitorar:**

| Exceção | Quando adicionar |
|---------|-----------------|
| `EAccessViolation` | Investigar crash por ponteiro nulo ou use-after-free |
| `EDivByZero` | Divisão por zero em cálculos |
| `ERangeError` | Índice fora do array (`{$RANGECHECKS ON}`) |
| `EInvalidPointer` | Liberação de ponteiro inválido |
| `EOutOfMemory` | Falha de alocação de memória |
| `EAbort` | Rastrear todas as chamadas a `Abort` |
| Exceção do projeto | Ex.: `EConexaoError` — para em toda falha de conexão |

---

## Exceções silenciosas — EAbort

`EAbort` (e descendentes) é tratada de forma especial pelo framework VCL/FMX:
- Não exibe dialog de erro ao usuário.
- `Application.HandleException` captura e descarta silenciosamente.
- Para parar nela: adicionar `EAbort` explicitamente na lista de Language Exceptions.

```pascal
// Lançar EAbort
Abort; // equivale a raise EAbort.Create('')
```

---

## SEH (Structured Exception Handling) vs Delphi Exceptions

| Tipo | Exemplos | Configuração |
|------|---------|-------------|
| **Delphi Exceptions** | `Exception`, `EDivByZero`, exceções customizadas | Language Exceptions |
| **SEH / Win32 Exceptions** | `EXCEPTION_ACCESS_VIOLATION` (0xC0000005), `EXCEPTION_STACK_OVERFLOW` | Tools → Options → Debugger → OS Exceptions |

Para capturar `EAccessViolation` como exceção Delphi (não SEH):
```pascal
uses SysUtils;
// EAccessViolation já é mapeada pelo Delphi RTL a partir de EXCEPTION_ACCESS_VIOLATION
try
  P^ := 0; // ponteiro nulo
except
  on E: EAccessViolation do
    WriteLn('AV: ' + E.Message);
end;
```

---

## FastMM4 — configurações de relatório

| Setting | Onde definir | Efeito |
|---------|-------------|--------|
| `ReportMemoryLeaksOnShutdown := True` | Início do `.dpr`, protegido por `{$IFDEF DEBUG}` | Exibe relatório ao fechar a aplicação |
| `{$DEFINE FullDebugMode}` | Antes de `uses FastMM4` | Habilita stack trace por alocação (lento) |
| `FastMM_LogToFile := True` | FastMM4 4.x | Salva relatório em arquivo `.log` ao lado do executável |

**Estrutura do relatório FastMM4:**
```
A memory block has been leaked. The size is: 48
This block was allocated by thread 0x1A2C, and the
stack trace (return addresses) at the time was:
  [00404510] + $0000 [TCliente.Create]
  [00401234] + $0010 [CriarCliente]
  [00401100] + $0020 [TForm1.Button1Click]
```

---

## EurekaLog — interpretar crash report

```
Exception class:  EAccessViolation
Exception message: Access violation at address 00404510
                   in module 'MeuApp.exe'. Read of address 00000000.

Call Stack:
  [00404510] TConexao.Conectar (uConexao.pas, line 87)
  [00403200] TGerenciador.Inicializar (uGerenciador.pas, line 45)
  [00401100] TForm1.FormCreate (ufrm.Main.pas, line 23)
  [00400800] Application.Initialize (Controls.pas, line 5821)
```

**Leitura:**
- Linha 1 do call stack = **ponto exato do crash** (AV em `TConexao.Conectar`)
- Linha 87 de `uConexao.pas`: provavelmente `FConexao.Open` com `FConexao = nil`
- Rastrear por que `FConexao` não foi inicializado antes de `TForm1.FormCreate`

---

## MadExcept — informações adicionais no report

```
main thread ($1234):
  madExcept 4.0.x
  exception class:  EAccessViolation
  exception message: Access violation ...
  
  thread registers:
  EAX=00000000  EBX=004A5000  ECX=00404510  EDX=00000003
  ESP=0018FF4C  EBP=0018FF60  EIP=00404510

  call stack:
  ...
```

**Campos extras do MadExcept:** registradores da CPU, lista de threads ativas, módulos carregados, versão do SO — úteis para reproduzir crashes dependentes de ambiente.
