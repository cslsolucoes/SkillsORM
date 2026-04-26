# Linux Runtime Dependencies — RTL Delphi para Linux 64-bit

Programas Delphi compilados para Linux 64-bit requerem ficheiros `.so` da RTL Delphi que **não estão disponíveis por padrão** no sistema operativo. Estes ficheiros devem ser incluídos no deploy.

---

## 1. Localização no Windows (fonte dos .so)

```
C:\Program Files (x86)\Embarcadero\Studio\23.0\lib\Linux64\release\
```

Conteúdo relevante:
```
librtl.so          ← RTL base (obrigatório)
libcrtl.so         ← C RTL wrapper
libdbtg.so         ← Database Table Grid (só debug)
libfmx.so          ← FMX framework (se usar FireMonkey)
libfmxdae.so       ← DAE model loading
libSQLiteImport.so ← SQLite embed (se usar)
```

---

## 2. Tabela de Dependências

### 2.1 RTL Delphi (fornecidas pela Embarcadero — deploy obrigatório)

| Ficheiro | Obrigatório | Descrição |
|---------|------------|-----------|
| `librtl.so` | **Sim** | RTL Delphi base: System, SysUtils, Classes, etc. |
| `libcrtl.so` | **Sim** | Wrapper para funções da libc usadas pela RTL |
| `libnet.so` | Condicional | Networking: Indy, TIdHTTP, sockets raw |
| `libfmx.so` | Condicional | FireMonkey (apenas se usar componentes FMX em console — raro) |
| `libdbtg.so` | **Não** (debug) | Apenas em builds debug — não fazer deploy em produção |

### 2.2 Dependências do Sistema Operativo (instaladas via apt/dnf)

| Biblioteca | Pacote (Ubuntu) | Pacote (RHEL) | Quando necessária |
|-----------|----------------|--------------|------------------|
| `libpthread.so.0` | `libpthread-stubs0-dev` | `glibc` | Sempre (TThread, synchronisation) |
| `libc.so.6` | `libc6` | `glibc` | Sempre (stdlib, stdio) |
| `libssl.so.1.1` | `libssl-dev` | `openssl-libs` | TLS/SSL, HTTPS, Indy SSL |
| `libcrypto.so.1.1` | `libssl-dev` | `openssl-libs` | Criptografia, depende de libssl |
| `libcurl.so.4` | `libcurl4` | `libcurl` | TNetHTTPClient, REST client |
| `libz.so.1` | `zlib1g` | `zlib` | Compressão ZLib, GZip |
| `libdl.so.2` | `libc6` | `glibc` | Dynamic loading (dlopen) |
| `libm.so.6` | `libc6` | `glibc` | Funções matemáticas |
| `libstdc++.so.6` | `libstdc++6` | `libstdc++` | C++ runtime (algumas libs de terceiros) |

---

## 3. Verificar Dependências com ldd

```bash
# Listar todas as dependências do binário
ldd /opt/meudaemon/MeuDaemon

# Exemplo de output completo (Delphi Release build):
#         linux-vdso.so.1 (0x00007ffea5c45000)
#         librtl.so => /opt/meudaemon/lib/librtl.so (0x00007f8a12345000)
#         libcrtl.so => /opt/meudaemon/lib/libcrtl.so (0x00007f8a11234000)
#         libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0
#         libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6
#         /lib64/ld-linux-x86-64.so.2

# Verificar APENAS as dependências em falta (output vazio = tudo ok)
ldd /opt/meudaemon/MeuDaemon | grep "not found"

# Ver versões das libs carregadas
ldd -v /opt/meudaemon/MeuDaemon 2>/dev/null | grep "Version symbols"
```

---

## 4. Deployment Manager (Método Recomendado)

O Deployment Manager do RAD Studio facilita a gestão automática dos `.so`:

### 4.1 Abrir o Deployment Manager

```
Project > Deployment
```

### 4.2 Configurar para Linux 64-bit

1. Seleccionar plataforma: **Linux 64-bit**
2. Clicar **Add Used Unit** (ícone +) — adiciona automaticamente as `.so` da RTL
3. Verificar que os ficheiros `librtl.so` e `libcrtl.so` estão listados com:
   - **Local Name:** caminho no Windows
   - **Remote Path:** destino no servidor (ex.: `./`)
4. Clicar **Deploy All** ou usar F9 para deploy automático

### 4.3 Estrutura de deploy típica

```
/opt/meudaemon/
├── MeuDaemon          ← binário principal (ELF64)
├── librtl.so          ← RTL Delphi
├── libcrtl.so         ← C RTL wrapper
└── lib/               ← pasta alternativa para .so (requer LD_LIBRARY_PATH)
```

### 4.4 Configurar LD_LIBRARY_PATH

Se os `.so` da RTL não estiverem em `/usr/lib` ou `/usr/local/lib`:

```bash
# Opção 1: LD_LIBRARY_PATH no mesmo directório do executável (script wrapper)
#!/bin/bash
# /opt/meudaemon/run_meudaemon.sh
export LD_LIBRARY_PATH=/opt/meudaemon:$LD_LIBRARY_PATH
exec /opt/meudaemon/MeuDaemon "$@"

# Opção 2: ldconfig (permanente, requer root)
echo '/opt/meudaemon' | sudo tee /etc/ld.so.conf.d/meudaemon.conf
sudo ldconfig

# Verificar que ldconfig encontrou as libs
ldconfig -p | grep librtl

# Opção 3: No unit systemd (via Environment=)
[Service]
Environment="LD_LIBRARY_PATH=/opt/meudaemon"
ExecStart=/opt/meudaemon/MeuDaemon
```

---

## 5. Instalar Dependências do Sistema

### Ubuntu 20.04 / 22.04

```bash
# Dependências básicas (quase sempre necessárias)
sudo apt update
sudo apt install -y \
  libssl-dev \
  libcurl4 \
  libz-dev \
  libpthread-stubs0-dev

# Para aplicações com acesso a base de dados
sudo apt install -y \
  libpq-dev \       # PostgreSQL
  libmysqlclient-dev \  # MySQL/MariaDB
  libsqlite3-dev    # SQLite

# Verificar versão de SSL instalada
openssl version
dpkg -l | grep libssl
```

### RHEL 8 / Rocky Linux 8 / AlmaLinux 8

```bash
# Habilitar repositório PowerTools/CRB se necessário
sudo dnf config-manager --enable powertools  # RHEL 8
sudo dnf config-manager --enable crb         # Rocky/Alma 9

# Instalar dependências
sudo dnf install -y \
  openssl-libs \
  libcurl \
  zlib \
  glibc \
  libstdc++

# PostgreSQL (se necessário)
sudo dnf install -y postgresql-libs

# Verificar
ldconfig -p | grep -E "libssl|libcurl|libz"
```

---

## 6. Diagnóstico de Problemas

### "error while loading shared libraries: librtl.so: cannot open shared object file"

```bash
# 1. Verificar se o ficheiro existe
find /opt/meudaemon -name "librtl.so"
find /usr/lib -name "librtl.so*"

# 2. Verificar LD_LIBRARY_PATH
echo $LD_LIBRARY_PATH

# 3. Verificar ldconfig
sudo ldconfig
ldconfig -p | grep librtl

# 4. Solução temporária (para diagnóstico)
LD_LIBRARY_PATH=/opt/meudaemon ./MeuDaemon
```

### "SIGILL" ou "Illegal instruction" no arranque

Causa provável: mismatch entre versão do compilador e da RTL.

```bash
# Verificar versão da librtl.so deployada
readelf -d /opt/meudaemon/librtl.so | grep SONAME
strings /opt/meudaemon/librtl.so | grep -i version | head -5

# A versão da librtl.so deve corresponder à versão do dcclinux64 usado
```

### Verificação rápida de todas as dependências

```bash
#!/bin/bash
# check_deps.sh — Verificar todas as dependências de um binário Delphi Linux

BINARY=${1:-"./MeuDaemon"}
echo "=== Dependências de $BINARY ==="
ldd "$BINARY"
echo ""
echo "=== Dependências em falta ==="
MISSING=$(ldd "$BINARY" | grep "not found")
if [ -z "$MISSING" ]; then
  echo "Nenhuma dependência em falta!"
else
  echo "$MISSING"
  exit 1
fi
```
