# TEMPLATE — Checklist de Setup para Projecto de Servidor/Biblioteca

**Skill:** `developer-delphi-servers-libraries-orchestrator_V1.1.0`  
**Actualizado:** 2026-04-11

---

## Como usar este template

1. Copie este checklist para o ficheiro de notas do projecto (ex.: `Documentation/setup-notes.md`)
2. Preencha as secções que se aplicam ao tipo de componente que está a criar
3. Execute cada item sequencialmente — a ordem importa
4. Marque `[x]` ao completar cada passo

---

## PARTE 1 — Definição do tipo de componente

### 1.1 Identificar o tipo

- [ ] **Windows Service** — processo SCM, corre em Session 0, sem UI
  - Skill: `developer-delphi-windows-services_V1.0.0`
- [ ] **Linux Daemon** — processo de fundo, systemd, SIGTERM handler
  - Skill: `developer-delphi-to-fpc-linux-servers_V1.0.0`
- [ ] **DLL Windows** — biblioteca partilhada, exports explícitos, stdcall
  - Skill: `developer-delphi-to-fpc-shared-libraries_V1.0.0`
- [ ] **SO Linux** — shared object, exports com cdecl, dlopen
  - Skill: `developer-delphi-to-fpc-shared-libraries_V1.0.0` + `developer-delphi-to-fpc-linux-servers_V1.0.0`
- [ ] **BPL (Delphi Package)** — componentes VCL/FMX, partilha de código entre apps Delphi
  - Skill: `developer-delphi-to-fpc-shared-libraries_V1.0.0` (secção BPL)
- [ ] **Multi-plataforma (Win+Linux)** — binários para ambas as plataformas
  - Skill adicional: `developer-delphi-to-fpc-build_V1.0.0`

### 1.2 Documentar a decisão

```
Tipo escolhido: _______________________________________________
Razão: ________________________________________________________
Plataformas alvo: [ ] Win32  [ ] Win64  [ ] Linux64  [ ] macOS64
```

---

## PARTE 2 — Criação do projecto no RAD Studio

### 2.1 Para Windows Service

- [ ] File → New → Other → Delphi Projects → **Service Application**
- [ ] Definir `ServiceName` em `TService` (será o nome no SCM)
- [ ] Definir `DisplayName` (nome legível em `services.msc`)
- [ ] Definir `Description` (visível nas propriedades do serviço)
- [ ] Verificar que `Interactive` = False (Session 0 não permite UI)
- [ ] Definir `StartType`: `stAutomatic` (arranca com o sistema) ou `stManual`
- [ ] Aplicar template: `developer-delphi-windows-services_V1.0.0/templates/TEMPLATE_tservice.pas`

### 2.2 Para DLL / BPL

- [ ] File → New → Other → Delphi Projects → **DLL** (ou **Package** para BPL)
- [ ] Verificar que o tipo de projecto em `.dproj` é `library` (DLL) ou `package` (BPL)
- [ ] Configurar `exports` na unit principal (DLL) ou `contains` / `requires` (BPL)
- [ ] Verificar referência: `developer-delphi-to-fpc-shared-libraries_V1.0.0/consultas_rapidas/dproj_library_multiplatform.md`

### 2.3 Para Linux Daemon (via dcclinux64)

- [ ] Criar projecto console normal (File → New → Console Application)
- [ ] Adicionar Connection Profile no IDE (Tools → Options → Connection Profile Manager)
- [ ] Verificar que o PAServer está a correr na máquina Linux de destino
- [ ] Guia de setup: `developer-delphi-to-fpc-linux-servers_V1.0.0/exemplos/paserver_linux_setup.md`

---

## PARTE 3 — Configuração do .dproj

### 3.1 Plataformas alvo

- [ ] Abrir `.dproj` no editor XML
- [ ] Verificar `<PropertyGroup>` com `<DCC_Platform>` correcto
- [ ] Para multi-plataforma: adicionar `Win32`, `Win64`, `Linux64` como plataformas activas
- [ ] Referência: `developer-delphi-to-fpc-shared-libraries_V1.0.0/consultas_rapidas/dproj_library_multiplatform.md`

### 3.2 Output paths

- [ ] Definir `DCC_ExeOutput` ou `DCC_BplOutput` para directório de output consistente
  - Sugestão: `bin\Win32\`, `bin\Win64\`, `bin\Linux64\`
- [ ] Verificar que o `.gitignore` exclui os directórios de output
- [ ] Para DLL: verificar que o output vai para o directório onde a app host o procura

### 3.3 Defines condicionais

- [ ] Adicionar define `FRAMEWORK_VCL` (VCL) ou `LCL` (FPC) conforme aplicável
- [ ] Para código condicional Win/Linux: usar `{$IFDEF MSWINDOWS}` e `{$IFDEF LINUX}`
- [ ] Para DLL/Library: adicionar define `IS_LIBRARY` se precisar de comportamento diferente
- [ ] Referência: skill `developer-delphi-programming-conditional-defines_V1.0.0`

---

## PARTE 4 — Decisão de Memory Manager

### 4.1 Windows Service

- [ ] Não há DLLs a carregar dinamicamente → Memory manager padrão (FastMM5 ou Delphi MM)
- [ ] Há DLLs que trocam objectos Delphi com o serviço → **Opção A**: ShareMem (todas as DLLs usam `borlndmm.dll`) ou **Opção B**: Usar apenas interfaces e tipos POD como boundary
- [ ] **Recomendação:** Opção B (interfaces) — sem dependência de `borlndmm.dll`, sem risco de cross-heap deallocation

### 4.2 DLL / .so

- [ ] Identificar o boundary entre DLL e host:
  - [ ] Apenas tipos POD (Integer, Double, PChar, array of byte) → sem problema
  - [ ] Interfaces Delphi → sem problema (ref counting é por interface, não por heap)
  - [ ] Strings AnsiString/UnicodeString → **problema**: usar ShareMem ou converter para PChar
  - [ ] Classes Delphi → **problema**: usar ShareMem ou converter para interfaces
- [ ] Decisão documentada: `_______________________________________________`
- [ ] Guia detalhado: `developer-delphi-to-fpc-shared-libraries_V1.0.0/exemplos/dll_memory_manager_guide.md`
- [ ] Armadilhas: `developer-delphi-to-fpc-shared-libraries_V1.0.0/consultas_rapidas/memory_manager_pitfalls.md`

---

## PARTE 5 — Calling Convention explícita

### 5.1 Para DLL Windows

- [ ] Todas as funções exportadas têm `stdcall` explícito
  ```delphi
  function CreateWidget(ASize: Integer): Pointer; stdcall; export;
  ```
- [ ] O ficheiro `.def` (se usado) lista todas as funções exportadas
- [ ] Referência: `developer-delphi-to-fpc-shared-libraries_V1.0.0/consultas_rapidas/exports_syntax_reference.md`

### 5.2 Para .so Linux

- [ ] Funções exportadas usam `cdecl` (convenção padrão Linux)
  ```delphi
  function CreateWidget(ASize: Integer): Pointer; cdecl; export;
  ```
- [ ] Verificar que `{$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF}` é usado para código multi-plataforma
- [ ] Referência: `developer-delphi-to-fpc-shared-libraries_V1.0.0/consultas_rapidas/calling_conventions_win_linux.md`

### 5.3 Para interface-based plugin system

- [ ] A factory function usa `stdcall` (Windows) ou `cdecl` (Linux)
  ```delphi
  function GetPlugin: IMyPlugin; stdcall;
  ```
- [ ] A interface não precisa de calling convention (definida pela interface vtable)

---

## PARTE 6 — Logging strategy

### 6.1 Windows Service

- [ ] **Windows Event Log** (recomendado para eventos críticos de sistema)
  ```delphi
  // Usar TEventLogger da unit SvcMgr
  LogMessage('Service started', EVENTLOG_INFORMATION_TYPE);
  ```
- [ ] **Ficheiro de log** (para debug detalhado)
  - Path: `C:\ProgramData\NomeApp\logs\service.log`
  - Rotação de logs: tamanho máximo ou por data
- [ ] **Ambos**: Event Log para erros críticos + ficheiro para debug verbose
- [ ] Verificar que o log é thread-safe (worker thread escreve em paralelo)

### 6.2 Linux Daemon

- [ ] **systemd journal** (recomendado)
  - Simplesmente escrever para `stdout`/`stderr` — o systemd captura automaticamente
  - Consultar: `journalctl -u nome-do-servico -f`
- [ ] **Ficheiro de log** (alternativa ou complemento)
  - Path: `/var/log/nomeapp/app.log`
  - Rotação via `logrotate`
- [ ] Referência: `developer-delphi-to-fpc-linux-servers_V1.0.0/consultas_rapidas/systemd_quick_reference.md`

### 6.3 DLL / .so

- [ ] A DLL **não deve ter log independente** — deve notificar o host via callback ou interface
  ```delphi
  type
    TLogCallback = procedure(const AMsg: string); stdcall;
  // A DLL recebe o callback no init e usa-o para logging
  ```
- [ ] Alternativa: a DLL escreve para ficheiro com path configurável via `Initialize(const ALogPath: PChar)`

---

## PARTE 7 — Deploy strategy

### 7.1 Windows Service

- [ ] **Instalação via Inno Setup**
  - `[Run]` section com `sc.exe create NomeServico binPath= "C:\...\MyService.exe"`
  - `[UninstallRun]` com `sc.exe delete NomeServico`
  - Verificar que o serviço é parado antes do uninstall
- [ ] **Instalação auto-registada** (o próprio executável aceita `--install` e `--uninstall`)
  ```delphi
  if ParamStr(1) = '--install' then
    Application.Initialize; // registar no SCM
  ```
- [ ] Referência: `developer-delphi-windows-services_V1.0.0/consultas_rapidas/sc_commands_reference.md`
- [ ] Skill de packaging: `developer-delphi-packaging-delivery_V1.0.0`

### 7.2 Linux Daemon

- [ ] Compilar com `dcclinux64` ou FPC para Linux64
- [ ] Verificar runtime deps: `ldd ./meuapp` — lista de `.so` necessários
- [ ] Copiar binário para `/usr/local/bin/` ou `/opt/nomeapp/`
- [ ] Instalar unidade systemd:
  ```bash
  cp meuapp.service /etc/systemd/system/
  systemctl daemon-reload
  systemctl enable meuapp
  systemctl start meuapp
  ```
- [ ] Template: `developer-delphi-to-fpc-linux-servers_V1.0.0/templates/TEMPLATE_daemon.service`
- [ ] Runtime deps: `developer-delphi-to-fpc-linux-servers_V1.0.0/consultas_rapidas/linux_runtime_deps.md`

### 7.3 DLL / .so

- [ ] **Windows:** DLL vai para o directório do executável host OU para `System32` (não recomendado)
  - Preferência: directório da aplicação (evita DLL Hell)
  - Para plugins: subdirectório `plugins\` no directório da aplicação
- [ ] **Linux:** `.so` vai para `/usr/local/lib/` ou `/opt/nomeapp/lib/`
  - Actualizar `ldconfig` após instalar: `ldconfig /usr/local/lib`
  - Ou usar `LD_LIBRARY_PATH` no script de arranque
- [ ] Skill de packaging: `developer-delphi-packaging-delivery_V1.0.0`

---

## PARTE 8 — Testes: smoke test de instalação/desinstalação

### 8.1 Windows Service — smoke test

- [ ] **Instalar o serviço:**
  ```bat
  sc create MeuServico binPath= "C:\path\MeuServico.exe" start= auto
  sc description MeuServico "Descrição do serviço"
  ```
- [ ] **Verificar criação:** `sc query MeuServico` → estado `STOPPED`
- [ ] **Arrancar:** `sc start MeuServico` → estado `RUNNING` (aguardar 5s)
- [ ] **Verificar Event Log:** Abrir Event Viewer → Windows Logs → Application → verificar evento de arranque
- [ ] **Parar:** `sc stop MeuServico` → estado `STOPPED`
- [ ] **Reinício automático:** desligar processo no Task Manager → verificar que o SCM reinicia (se Recovery Actions configuradas)
- [ ] **Desinstalar:** `sc delete MeuServico` → verificar que desaparece de `services.msc`
- [ ] Referência: `developer-delphi-windows-services_V1.0.0/consultas_rapidas/sc_commands_reference.md`

### 8.2 Linux Daemon — smoke test

- [ ] **Verificar binário funciona em foreground:**
  ```bash
  ./meuapp --foreground
  # Ctrl+C para parar — verificar shutdown graceful
  ```
- [ ] **Instalar unidade systemd:**
  ```bash
  sudo systemctl daemon-reload
  sudo systemctl enable meuapp
  sudo systemctl start meuapp
  ```
- [ ] **Verificar estado:** `systemctl status meuapp` → `active (running)`
- [ ] **Verificar logs:** `journalctl -u meuapp -f` → ver mensagens de arranque
- [ ] **Parar:** `sudo systemctl stop meuapp` → verificar shutdown graceful nos logs
- [ ] **SIGTERM manual:** `kill -TERM $(pidof meuapp)` → verificar que termina gracefully
- [ ] **Reinício automático:** `sudo systemctl kill meuapp` → verificar que o systemd reinicia
- [ ] **Desactivar:** `sudo systemctl disable meuapp && sudo rm /etc/systemd/system/meuapp.service`

### 8.3 DLL / .so — smoke test

- [ ] **Windows — teste de carregamento:**
  ```delphi
  var
    hLib: HMODULE;
    pfnCreate: TCreatePlugin;
  begin
    hLib := LoadLibrary('MinhaDLL.dll');
    Assert(hLib <> 0, 'LoadLibrary falhou: ' + SysErrorMessage(GetLastError));
    pfnCreate := GetProcAddress(hLib, 'CreatePlugin');
    Assert(Assigned(pfnCreate), 'GetProcAddress falhou');
    // Usar o plugin...
    FreeLibrary(hLib);
  end;
  ```
- [ ] **Linux — teste de carregamento:**
  ```bash
  ldd libminha.so          # verificar todas as dependências resolvidas
  nm -D libminha.so | grep CreatePlugin  # verificar que o símbolo está exportado
  ```
- [ ] **Teste de memory manager:** criar objecto na DLL e destruir no host → verificar sem AV
- [ ] **Teste de thread safety:** carregar DLL em múltiplas threads → verificar sem deadlock

---

## Notas finais

```
Data de criação: _________________
Responsável: _____________________
Tipo final: ______________________
Plataformas testadas: ____________
Estado: [ ] Em desenvolvimento  [ ] Em teste  [ ] Pronto para deploy
```
