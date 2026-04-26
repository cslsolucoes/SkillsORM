# PAServer Linux — Setup Completo

O PAServer (Platform Assistant Server) é o agente intermediário entre o RAD Studio Windows e o servidor Linux. É obrigatório para compilação remota, deploy e debugging.

---

## 1. Localizar o PAServer no Windows

O binário Linux do PAServer é distribuído junto com o RAD Studio:

```
C:\Program Files (x86)\Embarcadero\Studio\23.0\PAServer\
├── paserver              ← binário Linux ELF64
├── paserver.exe          ← versão Windows (para teste local)
└── paserver.ini          ← configuração padrão
```

**Nota:** O ficheiro `paserver` (sem extensão) já é um binário Linux ELF64 — não é o executável Windows.

---

## 2. Instalar no Ubuntu 20.04 / 22.04 LTS

### 2.1 Copiar o binário para o servidor

```bash
# Do Windows, via SCP
scp "C:\Program Files (x86)\Embarcadero\Studio\23.0\PAServer\paserver" \
    usuario@IP_SERVIDOR:~/paserver

# Alternativa: via SFTP (FileZilla, WinSCP)
# Destino no servidor: /home/usuario/paserver
```

### 2.2 Preparar o ambiente no servidor

```bash
# 1. Tornar o binário executável
chmod +x ~/paserver

# 2. Verificar que é um ELF64 válido
file ~/paserver
# Saída esperada: ELF 64-bit LSB executable, x86-64, ...

# 3. Instalar dependências do PAServer
sudo apt update
sudo apt install -y \
  libssl-dev \
  libcurl4 \
  libpthread-stubs0-dev \
  libz-dev

# 4. Verificar dependências do binário
ldd ~/paserver
# Verificar que não há "not found"
```

### 2.3 Mover para localização definitiva

```bash
# Criar utilizador dedicado (recomendado para segurança)
sudo useradd -r -m -d /opt/paserver -s /bin/false paserver

# Copiar binário
sudo cp ~/paserver /opt/paserver/paserver
sudo chown paserver:paserver /opt/paserver/paserver
sudo chmod 750 /opt/paserver/paserver

# Criar directório de trabalho (scratch dir para builds)
sudo mkdir -p /opt/paserver/scratch-dir
sudo chown -R paserver:paserver /opt/paserver/
```

---

## 3. Instalar no RHEL 8 / Rocky Linux 8 / AlmaLinux 8

```bash
# Instalar dependências
sudo dnf install -y \
  openssl-libs \
  libcurl \
  zlib \
  glibc

# O resto do processo é idêntico ao Ubuntu
chmod +x ~/paserver
sudo useradd -r -m -d /opt/paserver -s /bin/false paserver
sudo cp ~/paserver /opt/paserver/paserver
sudo chown -R paserver:paserver /opt/paserver/
sudo chmod 750 /opt/paserver/paserver
```

---

## 4. Iniciar o PAServer Manualmente

### 4.1 Modos de arranque

```bash
# Modo mínimo (sem senha — apenas para redes isoladas/desenvolvimento)
./paserver

# Com porta personalizada
./paserver -p 64211

# Com senha (recomendado)
./paserver -p 64211 -password=MinhaSenha123

# Com directório de scratch personalizado
./paserver -p 64211 -password=MinhaSenha123 -scratch=/opt/paserver/scratch-dir

# Em background (para testes — preferir systemd para produção)
nohup /opt/paserver/paserver -p 64211 -password=MinhaSenha123 \
  > /var/log/paserver.log 2>&1 &

echo $! > /var/run/paserver.pid
```

### 4.2 Verificar que está em execução

```bash
# Ver processo
ps aux | grep paserver

# Ver porta em escuta
ss -tlnp | grep 64211
# ou
netstat -tlnp | grep 64211

# Output esperado:
# tcp  0  0  0.0.0.0:64211  0.0.0.0:*  LISTEN  1234/paserver
```

---

## 5. Configurar como Serviço systemd (Produção)

### 5.1 Criar ficheiro de ambiente

```bash
# Ficheiro com variáveis sensíveis (senha)
sudo mkdir -p /etc/paserver
sudo tee /etc/paserver/paserver.env > /dev/null <<'EOF'
PASERVER_PASSWORD=MinhaSenha123
PASERVER_PORT=64211
EOF

# Restringir leitura apenas ao root e ao serviço
sudo chmod 640 /etc/paserver/paserver.env
sudo chown root:paserver /etc/paserver/paserver.env
```

### 5.2 Criar unit file

```bash
sudo tee /etc/systemd/system/paserver.service > /dev/null <<'EOF'
[Unit]
Description=Embarcadero Platform Assistant Server
Documentation=https://docwiki.embarcadero.com/RADStudio/en/PAServer
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=paserver
Group=paserver
WorkingDirectory=/opt/paserver
ExecStart=/opt/paserver/paserver -p ${PASERVER_PORT} -password=${PASERVER_PASSWORD} -scratch=/opt/paserver/scratch-dir
EnvironmentFile=/etc/paserver/paserver.env
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=paserver

# Limites de segurança
NoNewPrivileges=true
ProtectSystem=strict
ReadWritePaths=/opt/paserver/scratch-dir
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
```

### 5.3 Activar e iniciar o serviço

```bash
# Recarregar configuração do systemd
sudo systemctl daemon-reload

# Habilitar para iniciar automaticamente no boot
sudo systemctl enable paserver

# Iniciar o serviço
sudo systemctl start paserver

# Verificar estado
sudo systemctl status paserver

# Ver logs ao vivo
journalctl -u paserver -f

# Ver logs das últimas horas
journalctl -u paserver --since "2 hours ago"
```

---

## 6. Configurar Firewall

### 6.1 UFW (Ubuntu)

```bash
# Permitir acesso à porta do PAServer APENAS da máquina de desenvolvimento
sudo ufw allow from IP_WINDOWS to any port 64211 proto tcp

# Verificar regras
sudo ufw status numbered

# Alternativa: abrir para toda a rede interna (192.168.x.x)
sudo ufw allow from 192.168.0.0/16 to any port 64211 proto tcp
```

### 6.2 firewalld (RHEL/Rocky)

```bash
# Criar uma zona ou usar a zona interna
sudo firewall-cmd --permanent --add-rich-rule='
  rule family="ipv4"
  source address="192.168.1.50/32"
  port protocol="tcp" port="64211"
  accept'

sudo firewall-cmd --reload

# Verificar
sudo firewall-cmd --list-rich-rules
```

### 6.3 iptables (alternativa)

```bash
# Permitir TCP 64211 do IP da máquina Windows
sudo iptables -A INPUT -p tcp --dport 64211 -s IP_WINDOWS -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 64211 -j DROP

# Persistir (Ubuntu)
sudo apt install iptables-persistent
sudo netfilter-persistent save
```

---

## 7. Testar Conexão do Windows

### 7.1 Via RAD Studio

1. **Tools > Options > IDE > Connection Profile Manager**
2. Seleccionar o perfil criado (`LinuxDev`)
3. Clicar **Test Connection**
4. Resultado esperado: caixa de diálogo "Connection to LinuxDev was successful."

### 7.2 Via telnet (diagnóstico rápido)

```powershell
# No Windows — verificar conectividade TCP básica
Test-NetConnection -ComputerName IP_SERVIDOR -Port 64211

# Output esperado:
# TcpTestSucceeded : True
```

### 7.3 Problemas comuns

| Sintoma | Causa Provável | Solução |
|---------|---------------|---------|
| "Connection refused" | PAServer não está a correr | `sudo systemctl start paserver` |
| "Connection timed out" | Firewall bloqueando | Verificar regras de firewall |
| "Authentication failed" | Senha incorrecta | Verificar `/etc/paserver/paserver.env` |
| "Platform not supported" | Binário incorrecto | Verificar que `paserver` é ELF64, não Windows PE |
| Desconexão frequente | Timeout de rede | Aumentar timeout no Connection Profile |

---

## 8. Actualizar o PAServer

Quando actualizar o RAD Studio, o PAServer também deve ser actualizado no servidor:

```bash
# Parar o serviço
sudo systemctl stop paserver

# Copiar novo binário do Windows
scp "C:\Program Files (x86)\Embarcadero\Studio\23.0\PAServer\paserver" \
    usuario@IP_SERVIDOR:~/paserver_novo

# Substituir (como root ou com sudo)
sudo cp ~/paserver_novo /opt/paserver/paserver
sudo chown paserver:paserver /opt/paserver/paserver
sudo chmod 750 /opt/paserver/paserver

# Reiniciar
sudo systemctl start paserver
sudo systemctl status paserver
```

---

## 9. Múltiplos Servidores Linux

Para trabalhar com múltiplos servidores (desenvolvimento, staging, produção):

1. Instalar o PAServer em cada servidor
2. Criar um **Connection Profile** separado para cada um no RAD Studio
3. No **Project Manager**, alternar o perfil activo conforme necessário

Convenção de nomes recomendada:
- `Linux-Dev` — servidor de desenvolvimento
- `Linux-Staging` — servidor de staging
- `Linux-Prod` — servidor de produção (só para deploy final, não debugging)
