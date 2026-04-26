# Guia de Instalação — Windows Service Delphi

## Pré-requisitos

- Executar todos os comandos `sc` como **Administrador**
- Executável compilado em **Release** (Win64 recomendado)
- Caminho do executável sem espaços (ou entre aspas nos comandos)

---

## Passo 1 — Compilar em Release (Win64)

```batch
:: Via CLI — Delphi
dcc64 GestorERPService.dpr

:: Via IDE
:: Project > Options > Build Configuration > Release
:: Run > Build (Shift+F9)
```

Verificar que o executável foi gerado em `Win64\Release\`:

```batch
dir Win64\Release\GestorERPService.exe
```

---

## Passo 2 — Instalar o serviço

Abrir **Prompt de Comando como Administrador** e executar:

```batch
sc create "GestorERPService" ^
  binPath= "C:\GestorERP\Win64\Release\GestorERPService.exe" ^
  DisplayName= "GestorERP Background Service" ^
  start= auto ^
  obj= "LocalService"

:: Verificar se foi criado:
sc query "GestorERPService"
```

**Parâmetros explicados:**

| Parâmetro | Valor | Descrição |
|-----------|-------|-----------|
| `binPath=` | Caminho completo do `.exe` | O espaço após `=` é obrigatório |
| `DisplayName=` | Nome exibido no services.msc | Pode conter espaços |
| `start=` | `auto` / `demand` / `disabled` | `auto` = iniciar com o Windows |
| `obj=` | `LocalService` / `NetworkService` / `LocalSystem` | Conta de execução |

---

## Passo 3 — Adicionar descrição

```batch
sc description "GestorERPService" ^
  "Processa operações em background do sistema GestorERP: sincronização, importação e alertas."
```

---

## Passo 4 — Verificar no services.msc

```batch
:: Abrir Services Management Console
services.msc
```

- Localizar **GestorERP Background Service** na lista.
- Verificar: **Status** vazio (parado), **Startup Type** = Automatic.
- Double-click → verificar **Service name**, **Path to executable**, **Log On** tab.

---

## Passo 5 — Iniciar e testar

```batch
:: Iniciar
sc start "GestorERPService"

:: Verificar estado
sc query "GestorERPService"
:: Aguardar: STATE = 4 RUNNING

:: Ver logs no Event Viewer
eventvwr.msc
:: Windows Logs > Application > filtrar por Source = GestorERPService
```

---

## Passo 6 — Testar stop/start

```batch
:: Parar
sc stop "GestorERPService"

:: Verificar
sc query "GestorERPService"
:: STATE = 1 STOPPED

:: Reiniciar
sc start "GestorERPService"
```

---

## Passo 7 — Configurar Recovery Actions

Reiniciar automaticamente em caso de falha:

```batch
sc failure "GestorERPService" ^
  reset= 86400 ^
  actions= restart/60000/restart/120000/restart/300000
```

**Interpretação:**
- `reset= 86400` — resetar contador de falhas após 24h
- 1ª falha: restart após 60s
- 2ª falha: restart após 120s
- 3ª falha: restart após 300s (5 min)

Via GUI: `services.msc` → clique direito → Properties → **Recovery** tab.

---

## Passo 8 — Desinstalação

```batch
:: 1. Parar o serviço
sc stop "GestorERPService"

:: 2. Aguardar paragem completa (verificar com query)
sc query "GestorERPService"

:: 3. Deletar o registo do serviço
sc delete "GestorERPService"

:: 4. Confirmar remoção (deve retornar "The specified service does not exist")
sc query "GestorERPService"
```

> **Nota:** O ficheiro `.exe` não é removido — apagar manualmente se necessário.

---

## Referência rápida de comandos sc

| Comando | Descrição |
|---------|-----------|
| `sc create "Nome" binPath= "..."` | Instalar |
| `sc start "Nome"` | Iniciar |
| `sc stop "Nome"` | Parar |
| `sc pause "Nome"` | Pausar (se suportado) |
| `sc continue "Nome"` | Retomar após pausa |
| `sc query "Nome"` | Ver estado |
| `sc config "Nome" start= disabled` | Desabilitar auto-start |
| `sc config "Nome" start= auto` | Habilitar auto-start |
| `sc delete "Nome"` | Desinstalar |
| `sc description "Nome" "Texto"` | Definir descrição |
| `sc failure "Nome" ...` | Configurar recovery |

---

## Script completo de instalação (batch)

```batch
@echo off
setlocal

set SERVICE_NAME=GestorERPService
set SERVICE_EXE=C:\GestorERP\Win64\Release\GestorERPService.exe
set SERVICE_DISPLAY=GestorERP Background Service
set SERVICE_DESC=Processa operações em background do sistema GestorERP.

echo Instalando %SERVICE_DISPLAY%...

:: Verificar se existe e remover se necessário
sc query %SERVICE_NAME% >nul 2>&1
if %errorlevel% == 0 (
  echo Servico ja existe. Parando e removendo...
  sc stop %SERVICE_NAME% >nul 2>&1
  timeout /t 3 /nobreak >nul
  sc delete %SERVICE_NAME%
  timeout /t 2 /nobreak >nul
)

:: Criar serviço
sc create "%SERVICE_NAME%" ^
  binPath= "%SERVICE_EXE%" ^
  DisplayName= "%SERVICE_DISPLAY%" ^
  start= auto ^
  obj= LocalService

if %errorlevel% neq 0 (
  echo ERRO: Falha ao criar servico.
  exit /b 1
)

:: Adicionar descrição
sc description "%SERVICE_NAME%" "%SERVICE_DESC%"

:: Configurar recovery
sc failure "%SERVICE_NAME%" reset= 86400 actions= restart/60000/restart/120000/restart/300000

:: Iniciar
sc start "%SERVICE_NAME%"
if %errorlevel% neq 0 (
  echo ERRO: Falha ao iniciar servico. Verificar Event Viewer.
  exit /b 1
)

echo Instalacao concluida com sucesso.
echo Verificar: services.msc e eventvwr.msc
endlocal
```
