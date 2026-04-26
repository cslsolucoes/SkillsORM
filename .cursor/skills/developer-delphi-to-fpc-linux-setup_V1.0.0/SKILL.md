---
name: developer-delphi-to-fpc-linux-setup
description: Configurar o ambiente de cross-compile Delphi/FPC para Linux — pré-requisitos no Windows e no servidor Linux, instalação e configuração do PAServer (incluindo como serviço systemd), compilação via dcclinux64 (IDE, MSBuild CLI, deploy SCP) e gestão de runtime dependencies (.so). Foco em setup, não em implementação de daemons.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-linux-setup

## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |
| **Criado**      | 2026-04-24 |
| **Família**     | M — Serviços e Bibliotecas |

## Responsabilidade única

Configurar o ambiente completo para compilar e implantar projetos Delphi e FPC em Linux 64-bit. Cobre: pré-requisitos na máquina Windows de desenvolvimento e no servidor Linux, instalação e configuração do PAServer (modo manual e como daemon systemd), compilação via `dcclinux64` (IDE, MSBuild CLI, deploy SCP), e gestão de runtime dependencies (`.so`) via Deployment Manager e `ldd`.

## When to use

- Configurar PAServer no servidor Linux (primeira vez ou actualização).
- Compilar projeto Delphi para Linux 64-bit com `dcclinux64` ou MSBuild.
- Resolver erros de runtime dependencies (`librtl.so not found`, etc.).
- Fazer deploy de binário Linux via SCP ou Deployment Manager.
- Configurar Connection Profile no RAD Studio para Linux.

## When NOT to use

- Implementar daemon UNIX com fork/setsid → usar `developer-delphi-to-fpc-linux-daemon`.
- Signal handlers ou systemd unit files para o daemon → usar `developer-delphi-to-fpc-linux-daemon`.
- Windows Services → usar `developer-delphi-windows-services-setup`.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-to-fpc-build` | Confirmar toolchain configurada antes do cross-compile |

## Referências cruzadas

- `developer-delphi-to-fpc-linux-daemon` — daemon UNIX, signal handling, systemd unit files, FPC/Delphi diferenças, DataSnap em Linux

---

## 1. Pré-requisitos para Linux

### 1.1 Lado Windows (máquina de desenvolvimento)

- **RAD Studio 12 Athens** (ou superior) com licença **Enterprise** ou **Architect**
  - A licença Professional **não inclui** a plataforma Linux 64-bit
  - Verificar: Help > About > Licensed Features → "Linux 64-bit"
- SDK e compilador Linux incluídos na instalação padrão Enterprise/Architect
- MSBuild disponível no PATH (incluso no RAD Studio)

### 1.2 Lado Linux (servidor alvo)

- **Ubuntu 20.04 LTS** ou **22.04 LTS** (certificados pela Embarcadero)
- **RHEL 8** / **Rocky Linux 8** / **AlmaLinux 8** (também suportados)
- Arquitectura: **x86_64** (Linux 64-bit)
- Pacotes de runtime obrigatórios:
  ```bash
  sudo apt install libcurl4 libssl-dev libpthread-stubs0-dev
  # ou em RHEL/Rocky:
  sudo dnf install libcurl openssl-libs
  ```
- PAServer instalado e em execução (ver Secção 2)
- Porta **64211** aberta no firewall (TCP)

### 1.3 Versões do compilador

| Compilador | Plataforma alvo | Notas |
|-----------|----------------|-------|
| `dcc32.exe` | Windows 32-bit | Não gera Linux |
| `dcc64.exe` | Windows 64-bit | Não gera Linux |
| `dcclinux64.exe` | Linux 64-bit (ELF64) | Requer instalação Enterprise/Architect |
| `fpc` (i386-linux) | Linux 32-bit | FPC open-source |
| `fpc` (x86_64-linux) | Linux 64-bit | FPC open-source |

---

## 2. PAServer (Platform Assistant) — Instalação e Configuração

O PAServer é o agente que o RAD Studio usa para comunicar com o servidor Linux: compilação remota, deploy e debugging.

### 2.1 Instalar o PAServer no Linux

```bash
# 1. Copiar o binário do Windows para o Linux via SCP
#    (localização padrão no Windows)
scp "C:\Program Files (x86)\Embarcadero\Studio\23.0\PAServer\paserver" \
    user@linuxhost:~/paserver

# 2. Tornar executável
chmod +x ~/paserver

# 3. Verificar que executa
./paserver --version
```

**Nota:** O binário `paserver` é nativo Linux ELF64 — a Embarcadero distribui-o junto com o RAD Studio Windows. Extrair de `C:\Program Files (x86)\Embarcadero\Studio\23.0\PAServer\`.

### 2.2 Iniciar o PAServer

```bash
# Porta padrão: 64211
./paserver -p 64211

# Com senha (recomendado em ambientes não-isolados)
./paserver -p 64211 -password=MinhaSenha123

# Em background (para testes — preferir systemd para produção)
nohup ./paserver -p 64211 -password=MinhaSenha123 &> ~/paserver.log &
```

### 2.3 Configurar Connection Profile no RAD Studio

1. **Tools > Options > IDE > Connection Profile Manager**
2. Clicar **Add**
3. Preencher:
   - **Name:** `LinuxDev` (nome livre)
   - **Platform:** `Linux 64-bit`
   - **Host:** IP ou hostname do servidor Linux
   - **Port:** `64211`
   - **Password:** (a mesma usada no `-password=` acima)
4. Clicar **Test Connection** — deve mostrar "Connection Successful"

### 2.4 Seleccionar a plataforma no projeto

```
Project Manager → Target Platforms → botão direito → Add Platform → Linux 64-bit
```

Depois seleccionar o **Connection Profile** criado.

### 2.5 PAServer como daemon systemd

Ver `templates/TEMPLATE_paserver.service` para o unit file completo.

```bash
# Instalação rápida
sudo cp TEMPLATE_paserver.service /etc/systemd/system/paserver.service
# Editar /etc/systemd/system/paserver.service com caminho e password
sudo systemctl daemon-reload
sudo systemctl enable paserver
sudo systemctl start paserver
sudo systemctl status paserver
```

---

## 3. Compilar com dcclinux64

### 3.1 Cross-compile via IDE (recomendado)

1. No **Project Manager**, seleccionar **Linux 64-bit** como plataforma activa
2. Seleccionar o **Connection Profile** do servidor Linux
3. **Run > Run** (F9) ou **Project > Build**
4. O IDE transfere o binário para o servidor via PAServer e pode fazer debugging remoto

### 3.2 Cross-compile via MSBuild (CLI — Windows)

```bash
# Release build para Linux 64-bit
msbuild MeuPrograma.dproj /p:Platform=Linux64 /p:Config=Release

# Debug build
msbuild MeuPrograma.dproj /p:Platform=Linux64 /p:Config=Debug

# Especificar Connection Profile
msbuild MeuPrograma.dproj /p:Platform=Linux64 /p:Config=Release \
  /p:ConnectionProfile=LinuxDev
```

Output: ficheiro ELF64 **sem extensão** na pasta de output do projeto.

### 3.3 Compilação directa via dcclinux64 (avançado)

```bash
# No Windows, via linha de comandos
# (assumindo RAD Studio no PATH ou caminho completo)
dcclinux64.exe -B -O2 \
  -NSSystem;System.SysUtils;System.Classes;Posix.Unistd;Posix.Signal \
  -U"C:\Program Files (x86)\Embarcadero\Studio\23.0\lib\Linux64\release" \
  -I"C:\Program Files (x86)\Embarcadero\Studio\23.0\include" \
  MeuPrograma.dpr

# Output: MeuPrograma (ELF64, sem extensão)
```

Ver `consultas_rapidas/dcclinux64_options.md` para referência completa de flags.

### 3.4 Deploy manual via SCP

```bash
# Copiar o binário para o servidor
scp MeuPrograma user@linuxhost:/opt/meuprograma/

# Tornar executável
ssh user@linuxhost "chmod +x /opt/meuprograma/MeuPrograma"

# Verificar dependências
ssh user@linuxhost "ldd /opt/meuprograma/MeuPrograma"
```

---


## 8. Runtime Dependencies no Linux

### 8.1 Verificar dependências do binário

```bash
# Listar todas as bibliotecas necessárias
ldd /opt/meudaemon/MeuDaemon

# Output típico (Delphi):
#   linux-vdso.so.1 => (0x00007ffea...)
#   libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0
#   libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6
#   librtl.so => not found   ← precisa de deploy!
#   libssl.so.1.1 => /usr/lib/x86_64-linux-gnu/libssl.so.1.1

# Verificar se alguma lib está em falta
ldd /opt/meudaemon/MeuDaemon | grep "not found"
```

### 8.2 RTL Delphi para Linux 64-bit

Os seguintes ficheiros `.so` fazem parte da RTL Delphi e **devem ser incluídos no deploy** via Deployment Manager:

| Ficheiro | Obrigatório | Descrição |
|---------|------------|-----------|
| `librtl.so` | Sim | RTL Delphi base (System.SysUtils, etc.) |
| `libpthread.so.0` | Sim (do OS) | Threading POSIX — instalado no sistema |
| `libc.so.6` | Sim (do OS) | libc — instalado no sistema |
| `libssl.so` / `libssl.so.1.1` | Condicional | SSL/TLS (se usar Indy, TLS, HTTPS) |
| `libcurl.so` | Condicional | HTTP client (TNetHTTPClient, REST) |
| `libz.so.1` | Condicional | Compressão (ZLib) |
| `libdbtg.so` | Debug only | DataBase Table Grid (apenas debug) |

### 8.3 Configurar Deployment Manager no RAD Studio

```
Project > Deployment
```

1. Seleccionar plataforma **Linux 64-bit**
2. Clicar **Add Used Unit** para incluir automaticamente os `.so` da RTL
3. Verificar que todos os ficheiros em `Required` estão marcados para deploy
4. Configurar **Remote Path** (ex.: `/opt/meudaemon/`)

### 8.4 Instalar libs no servidor

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install libcurl4 libssl-dev libz-dev

# RHEL/Rocky/AlmaLinux
sudo dnf install libcurl openssl-libs zlib

# Verificar após instalação
ldconfig -p | grep libcurl
ldconfig -p | grep libssl
```

---



## Métricas de sucesso

- PAServer responde ao Connection Profile no RAD Studio sem erros.
- Binário compilado por `dcclinux64` executa no servidor sem erros de `.so not found` (`ldd` limpo).
- Deploy completo via Deployment Manager ou SCP em < 5 minutos.

## Changelog (este arquivo)

- 1.0.0 (24/04/2026): Extraído de `developer-delphi-to-fpc-linux-servers_V1.0.0` (707L) — seções §1 Pré-requisitos, §2 PAServer, §3 dcclinux64, §8 Runtime Dependencies. Skill original deprecada em favor das 2 skills filhas: `-setup` e `-daemon`.
