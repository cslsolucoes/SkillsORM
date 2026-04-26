# sc.exe — Referência Completa de Comandos

> Todos os comandos `sc` requerem execução como **Administrador**.
> O espaço após `=` nos parâmetros é **obrigatório**.

---

## Instalação e remoção

### `sc create` — Instalar serviço

```batch
sc create "NomeServico" ^
  binPath= "C:\Caminho\MeuServico.exe" ^
  DisplayName= "Nome Exibido no services.msc" ^
  start= auto ^
  obj= LocalService ^
  type= own
```

| Parâmetro | Valores | Descrição |
|-----------|---------|-----------|
| `binPath=` | Caminho completo | Caminho para o `.exe` (com espaço após `=`) |
| `DisplayName=` | String | Nome amigável exibido no console de serviços |
| `start=` | `boot` `system` `auto` `demand` `disabled` `delayed-auto` | Tipo de inicialização |
| `obj=` | `LocalSystem` `LocalService` `NetworkService` `DOMINIO\conta` | Conta de execução |
| `type=` | `own` `share` `interact` `kernel` `filesys` `rec` `adapt` | Tipo do serviço (padrão: `own`) |
| `error=` | `normal` `severe` `critical` `ignore` | Severidade de erro no boot |
| `group=` | Nome do grupo | Grupo de ordem de inicialização |
| `depend=` | `servico1/servico2` | Dependências (iniciar após estes serviços) |
| `tag=` | Número | Tag de ordem dentro do grupo |

---

### `sc delete` — Desinstalar serviço

```batch
:: Serviço deve estar PARADO antes de deletar
sc stop "NomeServico"
timeout /t 3 /nobreak
sc delete "NomeServico"
```

---

## Controle de estado

### `sc start` — Iniciar

```batch
sc start "NomeServico"

:: Com argumentos (passados ao serviço):
sc start "NomeServico" arg1 arg2
```

### `sc stop` — Parar

```batch
sc stop "NomeServico"
```

### `sc pause` — Pausar

```batch
:: Requer CanPause := True no serviço
sc pause "NomeServico"
```

### `sc continue` — Retomar após pausa

```batch
sc continue "NomeServico"
```

---

## Consulta e diagnóstico

### `sc query` — Estado actual

```batch
:: Estado de um serviço específico
sc query "NomeServico"

:: Todos os serviços em execução
sc query type= all state= all

:: Serviços parados
sc query state= inactive
```

**Output relevante:**
```
SERVICE_NAME: NomeServico
        TYPE               : 10  WIN32_OWN_PROCESS
        STATE              : 4  RUNNING
                                (STOPPABLE, NOT_PAUSABLE, ACCEPTS_SHUTDOWN)
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x0
        WAIT_HINT          : 0x0
```

**Códigos de STATE:**
| Código | Estado |
|--------|--------|
| 1 | STOPPED |
| 2 | START_PENDING |
| 3 | STOP_PENDING |
| 4 | RUNNING |
| 5 | CONTINUE_PENDING |
| 6 | PAUSE_PENDING |
| 7 | PAUSED |

### `sc qc` — Configuração completa

```batch
sc qc "NomeServico"
```

### `sc qfailure` — Recovery actions configuradas

```batch
sc qfailure "NomeServico"
```

---

## Configuração

### `sc config` — Alterar configuração

```batch
:: Alterar tipo de start
sc config "NomeServico" start= disabled
sc config "NomeServico" start= auto
sc config "NomeServico" start= demand

:: Alterar conta de execução
sc config "NomeServico" obj= "NT AUTHORITY\NetworkService"
sc config "NomeServico" obj= "EMPRESA\svc-conta" password= "Senha"

:: Alterar caminho do executável
sc config "NomeServico" binPath= "C:\NovosCaminho\MeuServico.exe"
```

### `sc description` — Definir descrição

```batch
sc description "NomeServico" "Descrição completa do serviço GestorERP."
```

### `sc failure` — Configurar recovery actions

```batch
:: Configuração completa de recovery:
sc failure "NomeServico" ^
  reset= 86400 ^
  actions= restart/60000/restart/120000/restart/300000

:: Parâmetros:
:: reset=     Segundos após os quais o contador de falhas é resetado (86400 = 24h)
:: actions=   Lista action/delay em ms (restart, run, reboot)
```

**Exemplos de actions:**
```batch
:: Reiniciar sempre após 1 minuto:
sc failure "NomeServico" reset= 86400 actions= restart/60000/restart/60000/restart/60000

:: Reiniciar 2x, depois reboot:
sc failure "NomeServico" reset= 86400 actions= restart/60000/restart/120000/reboot/300000

:: Reiniciar 2x, depois executar script:
sc failure "NomeServico" ^
  reset= 86400 ^
  actions= restart/60000/restart/120000/run/0 ^
  command= "C:\Scripts\AlertaFalhaServico.bat"
```

### `sc failureflag` — Falha em exit code != 0

```batch
:: Tratar exit code diferente de 0 como falha (para acionar recovery):
sc failureflag "NomeServico" 1
```

---

## Dependências

```batch
:: Adicionar dependência (NomeServico inicia após RpcSs e TCPIP):
sc config "NomeServico" depend= RpcSs/TCPIP

:: Remover todas as dependências:
sc config "NomeServico" depend= /
```

---

## Comandos de diagnóstico avançado

```batch
:: Verificar se serviço existe
sc query "NomeServico" >nul 2>&1
if %errorlevel% == 0 (echo Existe) else (echo Nao existe)

:: Aguardar serviço estar RUNNING (script):
:WAIT_LOOP
sc query "NomeServico" | findstr "RUNNING" >nul 2>&1
if %errorlevel% neq 0 (
  timeout /t 2 /nobreak >nul
  goto WAIT_LOOP
)
echo Servico em execucao.

:: Ver todos os serviços com falha de start:
sc query type= all state= all | findstr /i "STOPPED"

:: Controle personalizado (código 128-255):
sc control "NomeServico" 128
```

---

## Script de deploy completo (template)

```batch
@echo off
setlocal EnableDelayedExpansion

set SVC_NAME=GestorERPService
set SVC_EXE=C:\GestorERP\Win64\Release\GestorERPService.exe
set SVC_DISPLAY=GestorERP Background Service
set SVC_DESC=Processa operacoes em background do sistema GestorERP.
set SVC_ACCOUNT=LocalService

echo ============================================
echo  Deploy: %SVC_DISPLAY%
echo ============================================

:: Verificar privilégios de admin
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo ERRO: Execute como Administrador.
  exit /b 1
)

:: Verificar se executável existe
if not exist "%SVC_EXE%" (
  echo ERRO: Executavel nao encontrado: %SVC_EXE%
  exit /b 1
)

:: Remover instalação anterior se existir
sc query "%SVC_NAME%" >nul 2>&1
if %errorlevel% == 0 (
  echo Removendo instalacao anterior...
  sc stop "%SVC_NAME%" >nul 2>&1
  timeout /t 5 /nobreak >nul
  sc delete "%SVC_NAME%"
  timeout /t 2 /nobreak >nul
)

:: Instalar
echo Instalando servico...
sc create "%SVC_NAME%" binPath= "%SVC_EXE%" DisplayName= "%SVC_DISPLAY%" start= auto obj= %SVC_ACCOUNT%
if %errorlevel% neq 0 ( echo ERRO: sc create falhou. & exit /b 1 )

:: Descricao
sc description "%SVC_NAME%" "%SVC_DESC%"

:: Recovery
sc failure "%SVC_NAME%" reset= 86400 actions= restart/60000/restart/120000/restart/300000

:: Iniciar
echo Iniciando servico...
sc start "%SVC_NAME%"
if %errorlevel% neq 0 ( echo ERRO: sc start falhou. Verificar Event Viewer. & exit /b 1 )

:: Aguardar RUNNING
timeout /t 5 /nobreak >nul
sc query "%SVC_NAME%" | findstr "RUNNING"
if %errorlevel% neq 0 (
  echo AVISO: Servico nao esta RUNNING apos 5s. Verificar eventvwr.msc.
) else (
  echo SUCESSO: Servico instalado e em execucao.
)

endlocal
```
