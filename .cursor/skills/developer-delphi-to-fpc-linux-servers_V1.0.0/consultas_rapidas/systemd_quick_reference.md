# systemd — Referência Rápida para Daemons Delphi/FPC

Referência de configuração systemd focada em daemons criados com Delphi e FPC/Lazarus no Linux.

---

## 1. Estrutura do Unit File

```ini
[Unit]
# Metadados e dependências
Description=Descrição do daemon
Documentation=https://url/da/documentacao
After=network.target       # iniciar depois do networking
Wants=network-online.target # preferência (não obrigatório)
Requires=postgresql.service # dependência obrigatória
Before=nginx.service        # iniciar antes do nginx (se aplicável)

[Service]
# Tipo e execução
Type=simple
User=meuservico
Group=meuservico
WorkingDirectory=/opt/meudaemon
ExecStart=/opt/meudaemon/MeuDaemon --config /etc/meudaemon/config.ini
ExecStartPre=/opt/meudaemon/check_config.sh   # validação antes de iniciar
ExecStopPost=/opt/meudaemon/cleanup.sh        # limpeza após parar
ExecReload=/bin/kill -HUP $MAINPID            # reload via SIGHUP

# Restart
Restart=on-failure
RestartSec=5
StartLimitIntervalSec=60    # janela de contagem de falhas
StartLimitBurst=5           # máximo de restarts na janela acima

# Output e logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=meudaemon

# Variáveis de ambiente
Environment="MEUAPP_ENV=production"
Environment="LOG_LEVEL=info"
EnvironmentFile=/etc/meudaemon/meudaemon.env   # ficheiro de env vars

# Timeouts
TimeoutStartSec=30    # tempo máximo para o processo arrancar
TimeoutStopSec=30     # tempo máximo para parar limpo antes de SIGKILL

[Install]
WantedBy=multi-user.target
```

---

## 2. Type= — Escolher o Tipo Correcto

| Type | Comportamento | Quando usar |
|------|--------------|-------------|
| `simple` | systemd considera o serviço iniciado assim que o processo principal arranca. `ExecStart` é o processo principal. | **Recomendado** para daemons Delphi/FPC novos que não fazem fork. |
| `forking` | systemd espera que o processo pai termine (fork UNIX clássico). Requer `PIDFile=` para tracking. | Daemons legados com double-fork. |
| `notify` | Processo notifica o systemd via `sd_notify("READY=1")` quando está pronto. Maior controlo. | Daemons que precisam de inicialização longa. |
| `oneshot` | Processo executa e termina; systemd considera a unidade activa enquanto o processo decorreu. | Scripts de configuração, migrações. |
| `idle` | Como `simple` mas aguarda que todos os jobs de arranque terminem. | Tarefas de baixa prioridade no boot. |

**Para Delphi/FPC — regra prática:**
- Usar `Type=simple` + **sem daemonização** no código (sem fork): deixar o systemd gerir o ciclo de vida.
- Se precisar fork clássico (código legado): usar `Type=forking` com `PIDFile=/var/run/meudaemon.pid`.

---

## 3. Restart= — Política de Reinício

| Valor | Reinicia quando | Não reinicia quando |
|-------|----------------|---------------------|
| `no` | Nunca | — |
| `always` | Sempre que o processo termina | — |
| `on-failure` | Exit code ≠ 0, sinal de kill, timeout | Exit code 0 (saída normal) |
| `on-abnormal` | Sinal de kill, timeout, watchdog | Exit code qualquer |
| `on-abort` | Apenas sinal de abort (SIGABRT) | — |
| `on-success` | Apenas quando exit code = 0 | — |

**Recomendado para daemons de produção:** `Restart=on-failure` com `RestartSec=5`

---

## 4. Variáveis de Ambiente

### 4.1 Environment= inline

```ini
[Service]
Environment="VAR1=valor1"
Environment="VAR2=valor2"
# Múltiplas variáveis numa linha:
Environment="VAR1=a" "VAR2=b" "VAR3=c"
```

### 4.2 EnvironmentFile= (recomendado para senhas)

```bash
# /etc/meudaemon/meudaemon.env
DATABASE_URL=postgres://user:senha@localhost/meubanco
API_KEY=chave-secreta-aqui
LOG_LEVEL=info
```

```ini
[Service]
EnvironmentFile=/etc/meudaemon/meudaemon.env
# Prefixar com - para ignorar ficheiro inexistente:
EnvironmentFile=-/etc/meudaemon/optional.env
```

```bash
# Restringir acesso ao ficheiro de env
sudo chmod 640 /etc/meudaemon/meudaemon.env
sudo chown root:meuservico /etc/meudaemon/meudaemon.env
```

---

## 5. ExecStartPre, ExecStopPost, ExecReload

```ini
[Service]
# Verificar configuração antes de iniciar (falha impede o arranque)
ExecStartPre=/usr/bin/test -f /etc/meudaemon/config.ini
ExecStartPre=/opt/meudaemon/validate-config.sh

# Limpeza após parar (não bloqueia o stop)
ExecStopPost=/bin/rm -f /var/run/meudaemon.pid
ExecStopPost=/bin/bash -c 'echo "Daemon parado em $(date)" >> /var/log/meudaemon.log'

# Reload via SIGHUP (envia sinal ao processo principal)
ExecReload=/bin/kill -HUP $MAINPID

# Prefixo - = ignorar falha deste comando (não para o serviço)
ExecStartPre=-/opt/meudaemon/optional-init.sh
```

---

## 6. Limits — Limitar Recursos

```ini
[Service]
# Número máximo de ficheiros abertos (file descriptors)
LimitNOFILE=65536

# Número máximo de processos/threads
LimitNPROC=512

# Tamanho máximo de core dump (0 = desactivar)
LimitCORE=0

# Memória virtual máxima
LimitAS=4G

# Tamanho máximo de pilha (stack)
LimitSTACK=8M

# CPU time máximo
LimitCPU=infinity
```

---

## 7. Segurança — Sandboxing

```ini
[Service]
# Não adquirir novos privilégios
NoNewPrivileges=true

# Proteger sistema de ficheiros de sistema (leitura apenas)
ProtectSystem=strict

# Proteger /home do utilizador de outros utilizadores
ProtectHome=true

# Filesystem privado temporário em /tmp
PrivateTmp=true

# Sem acesso a dispositivos físicos
PrivateDevices=true

# Paths com escrita permitida (necessário com ProtectSystem=strict)
ReadWritePaths=/opt/meudaemon/data /var/log/meudaemon

# Paths com leitura permitida
ReadOnlyPaths=/etc/meudaemon

# Namespace de rede privado (isolamento de rede — cuidado!)
# PrivateNetwork=true  # raramente útil para servidores

# Filtro de system calls (whitelist — avançado)
SystemCallFilter=@system-service
SystemCallArchitectures=native
```

---

## 8. Monitoring com journalctl

```bash
# Seguir logs ao vivo
journalctl -u meudaemon -f

# Logs desde o arranque do sistema
journalctl -u meudaemon -b

# Últimas N linhas
journalctl -u meudaemon -n 100

# Intervalo de tempo
journalctl -u meudaemon --since "2024-01-15 10:00:00"
journalctl -u meudaemon --since "1 hour ago"
journalctl -u meudaemon --since "yesterday"

# Apenas erros e críticos
journalctl -u meudaemon -p err

# Formato JSON (para parsing programático)
journalctl -u meudaemon -o json-pretty | head -50

# Exportar logs para ficheiro
journalctl -u meudaemon --since "1 hour ago" > /tmp/meudaemon.log

# Ver logs de todos os serviços do boot actual
journalctl -b --priority=err
```

---

## 9. Comandos de Gestão Essenciais

```bash
# ── Controlo do serviço ──
sudo systemctl start   meudaemon    # iniciar
sudo systemctl stop    meudaemon    # parar (SIGTERM → SIGKILL após timeout)
sudo systemctl restart meudaemon    # parar + iniciar
sudo systemctl reload  meudaemon    # enviar SIGHUP (se ExecReload configurado)
sudo systemctl kill meudaemon       # SIGKILL imediato (forçado)
sudo systemctl kill -s SIGUSR1 meudaemon  # enviar sinal customizado

# ── Estado ──
sudo systemctl status  meudaemon    # estado actual + últimas linhas de log
sudo systemctl is-active  meudaemon # active/inactive (exit 0 = activo)
sudo systemctl is-enabled meudaemon # enabled/disabled (exit 0 = habilitado)
sudo systemctl is-failed  meudaemon # failed/active (exit 0 = em falha)

# ── Boot ──
sudo systemctl enable  meudaemon    # habilitar no boot
sudo systemctl disable meudaemon    # desabilitar no boot
sudo systemctl mask    meudaemon    # impedir completamente (override)
sudo systemctl unmask  meudaemon    # remover mask

# ── Configuração ──
sudo systemctl daemon-reload         # recarregar unit files modificados
sudo systemctl edit meudaemon        # editar override inline
sudo systemctl cat meudaemon         # ver unit file efectivo

# ── Diagnóstico ──
systemd-analyze blame                # tempo de arranque por serviço
systemd-analyze critical-chain meudaemon  # cadeia crítica de dependências
systemctl list-dependencies meudaemon     # árvore de dependências
```

---

## 10. Override de Unit (sem editar o ficheiro original)

```bash
# Editar override (cria /etc/systemd/system/meudaemon.service.d/override.conf)
sudo systemctl edit meudaemon

# Exemplo de override para alterar apenas o RestartSec:
# [Service]
# RestartSec=10

# Ver configuração efectiva (unit original + overrides)
sudo systemctl cat meudaemon

# Remover override
sudo rm -rf /etc/systemd/system/meudaemon.service.d/
sudo systemctl daemon-reload
```
