# Guia de Build para Linux 64-bit com dcclinux64

## Pré-requisitos

- RAD Studio 12 Athens (ou superior) com licença **Enterprise** ou **Architect**
- PAServer instalado e em execução no servidor Linux (ver `paserver_linux_setup.md`)
- Connection Profile configurado no RAD Studio

---

## 1. Setup do Connection Profile

### 1.1 Criar o perfil de conexão

1. Abrir **Tools > Options**
2. Navegar para **IDE > Connection Profile Manager**
3. Clicar **Add**
4. Preencher os campos:

   | Campo | Valor |
   |-------|-------|
   | Name | `LinuxDev` (nome livre) |
   | Platform | `Linux 64-bit` |
   | Host | IP ou hostname do servidor (ex.: `192.168.1.100`) |
   | Port | `64211` (padrão do PAServer) |
   | Password | Senha definida no PAServer (`-password=`) |

5. Clicar **Test Connection**
   - Resultado esperado: `"Connection to LinuxDev was successful."`
6. Clicar **OK** para salvar

### 1.2 Adicionar plataforma ao projeto

No **Project Manager** (View > Project Manager):

```
Target Platforms → botão direito → Add Platform → Linux 64-bit
```

Ao adicionar, seleccionar o Connection Profile criado (`LinuxDev`).

---

## 2. Compilar via IDE (F9)

### 2.1 Seleccionar plataforma

No Project Manager, expandir **Target Platforms** e clicar em **Linux 64-bit** para torná-la activa (fica em negrito).

### 2.2 Build e Run

| Ação | Tecla | Descrição |
|------|-------|-----------|
| Build | Shift+F9 | Compila sem executar |
| Run | F9 | Compila e executa no servidor via PAServer |
| Run Without Debugging | Ctrl+Shift+F9 | Executa sem debugger remoto |

### 2.3 Output esperado

O IDE:
1. Cross-compila o código no Windows com `dcclinux64.exe`
2. Transfere o binário ELF64 para o servidor Linux via PAServer
3. (Se F9) Abre sessão de debugging remoto

O binário fica no servidor no caminho configurado no Deployment Manager (padrão: `~/PAServer/scratch-dir/NomeProjeto/`).

---

## 3. Compilar via MSBuild CLI (Windows)

### 3.1 Garantir que MSBuild está no PATH

```powershell
# Verificar
msbuild --version

# Se não estiver no PATH, adicionar (RAD Studio 12):
$env:PATH += ";C:\Program Files (x86)\Embarcadero\Studio\23.0\bin"
```

### 3.2 Comandos de build

```bash
# Release build — Linux 64-bit
msbuild MeuPrograma.dproj /p:Platform=Linux64 /p:Config=Release

# Debug build — Linux 64-bit
msbuild MeuPrograma.dproj /p:Platform=Linux64 /p:Config=Debug

# Especificar Connection Profile
msbuild MeuPrograma.dproj /p:Platform=Linux64 /p:Config=Release \
  /p:ConnectionProfile=LinuxDev

# Build + Deploy (transferir para o servidor)
msbuild MeuPrograma.dproj /p:Platform=Linux64 /p:Config=Release \
  /t:Build,Deploy

# Verbose output (debugging de problemas de build)
msbuild MeuPrograma.dproj /p:Platform=Linux64 /p:Config=Release /v:detailed
```

### 3.3 Output

O ficheiro ELF64 é gerado em:
```
.\Linux64\Release\MeuPrograma          ← sem extensão
.\Linux64\Release\MeuPrograma.dSYM\   ← debug symbols (só em Debug config)
```

---

## 4. Compilação directa com dcclinux64 (avançado)

Para casos onde o MSBuild não é prático (CI/CD sem RAD Studio instalado completo, scripts avançados):

```bash
# Windows — caminho padrão do dcclinux64
SET DELPHI=C:\Program Files (x86)\Embarcadero\Studio\23.0
SET RTL=%DELPHI%\lib\Linux64\release
SET INC=%DELPHI%\include\Linux64\rtl

dcclinux64.exe ^
  -B ^
  -O2 ^
  -NSSystem;System.SysUtils;System.Classes;Posix.Unistd;Posix.Signal ^
  -U"%RTL%" ^
  -I"%INC%" ^
  -LE"%RTL%" ^
  -LN"%RTL%" ^
  MeuPrograma.dpr
```

Flags essenciais:
- `-B` — build completo (não incremental)
- `-O2` — optimização nível 2
- `-NS` — namespaces de units (substitui prefixos explícitos)
- `-U` — caminho de units compiladas (`.dcu`)
- `-I` — caminho de includes

---

## 5. Deploy Manual via SCP

Quando não usar o Deployment Manager integrado:

```bash
# 1. Copiar o binário
scp Linux64/Release/MeuPrograma user@linuxhost:/opt/meuprograma/

# 2. Copiar bibliotecas RTL (se não instaladas globalmente)
scp Linux64/Release/*.so user@linuxhost:/opt/meuprograma/lib/

# 3. Tornar executável
ssh user@linuxhost "chmod 750 /opt/meuprograma/MeuPrograma"

# 4. Definir LD_LIBRARY_PATH se as .so não estiverem em /usr/lib
ssh user@linuxhost "echo 'export LD_LIBRARY_PATH=/opt/meuprograma/lib:$LD_LIBRARY_PATH' >> ~/.bashrc"

# 5. Ou adicionar ao ldconfig (root necessário)
ssh user@linuxhost "echo '/opt/meuprograma/lib' | sudo tee /etc/ld.so.conf.d/meuprograma.conf && sudo ldconfig"
```

### 5.1 Script de deploy completo

```bash
#!/bin/bash
# deploy_linux.sh — Deploy de daemon Delphi para servidor Linux

PROJETO="MeuDaemon"
SERVIDOR="user@192.168.1.100"
DEST="/opt/meudaemon"
SERVICE="meudaemon"

echo "=== Deploy $PROJETO para $SERVIDOR ==="

# Build
msbuild "$PROJETO.dproj" /p:Platform=Linux64 /p:Config=Release /q
if [ $? -ne 0 ]; then echo "ERRO: Build falhou"; exit 1; fi

# Parar serviço
ssh "$SERVIDOR" "sudo systemctl stop $SERVICE 2>/dev/null; true"

# Copiar ficheiros
scp "Linux64/Release/$PROJETO" "$SERVIDOR:$DEST/"
scp Linux64/Release/*.so "$SERVIDOR:$DEST/lib/" 2>/dev/null; true

# Ajustar permissões
ssh "$SERVIDOR" "chmod 750 $DEST/$PROJETO && chown -R meudaemon:meudaemon $DEST"

# Reiniciar serviço
ssh "$SERVIDOR" "sudo systemctl start $SERVICE && sudo systemctl status $SERVICE"

echo "=== Deploy concluído ==="
```

---

## 6. Verificar Dependências com ldd

```bash
# No servidor Linux, após deploy:
ldd /opt/meudaemon/MeuDaemon

# Output típico (Delphi Linux):
#         linux-vdso.so.1 (0x00007ffea5c45000)
#         libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0
#         libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6
#         librtl.so => /opt/meudaemon/lib/librtl.so     ← da RTL Delphi
#         /lib64/ld-linux-x86-64.so.2

# Verificar se há dependências em falta
ldd /opt/meudaemon/MeuDaemon | grep "not found"
# (output vazio = tudo ok)

# Instalar dependências em falta (Ubuntu)
sudo apt install libcurl4 libssl-dev libz-dev

# Instalar dependências em falta (RHEL/Rocky)
sudo dnf install libcurl openssl-libs zlib
```

---

## 7. Debugging Remoto

### 7.1 Via IDE (F9)

Com o PAServer activo e o Connection Profile configurado, pressionar **F9** no IDE lança o processo no servidor e conecta o debugger remoto. Breakpoints, watches e call stack funcionam normalmente.

### 7.2 Verificar que o PAServer suporta debugging

O PAServer deve ser iniciado **sem** o flag `-nodebug`:

```bash
# Correcto (suporta debugging)
./paserver -p 64211 -password=MinhaS3nha

# Incorrecto para debugging
./paserver -p 64211 -nodebug -password=MinhaS3nha
```

### 7.3 Via GDB (debugging nativo no Linux)

```bash
# Compilar com símbolos de debug
msbuild MeuPrograma.dproj /p:Platform=Linux64 /p:Config=Debug

# Copiar o binário com dwarf info
scp Linux64/Debug/MeuPrograma user@linuxhost:~/

# No servidor:
gdb ~/MeuPrograma
(gdb) run --daemon
(gdb) bt          # backtrace após crash
(gdb) info threads
```
