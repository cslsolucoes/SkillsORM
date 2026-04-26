# Comparação: BPL vs DLL vs .so

## Tabela de Características

| Característica | `.dll` (Windows) | `.so` (Linux) | `.bpl` (BorlandPackage) |
|----------------|-----------------|---------------|------------------------|
| **Linguagem host** | Qualquer | Qualquer | Apenas Delphi/C++Builder |
| **Memory manager** | Separado por módulo — requer ShareMem ou POD | Idem | Partilhado (RTL única via BPL runtime) |
| **Fronteira de memória** | Problema — ver guia | Idem | Transparente |
| **Deploy** | DLL + (BORLNDMM.DLL se ShareMem) | .so | App + todos os BPLs de runtime |
| **Tamanho do binário** | Maior (RTL linkada estaticamente) | Idem | Menor (RTL no BPL runtime) |
| **Versioning** | Manual (`GetVersion`) | Idem | Automático (Package Version) |
| **Hot reload** | Sim (descarregar/carregar) | Idem | Limitado (requer reinício geralmente) |
| **Plugin system** | Sim | Sim | Sim (apenas Delphi) |
| **Debug symbols** | `.map`, `.dbg`, MadExcept | `.dbg` | Integrado no IDE |
| **COM/ActiveX** | Sim (regsvr32) | N/A | Não directamente |
| **Compatibilidade entre versões Delphi** | Via POD ou COM interfaces | Idem | Recompilação obrigatória |
| **Thread safety** | Responsabilidade do desenvolvedor | Idem | Idem |

---

## Quando Usar `.dll` / `.so`

**Use quando:**
- O consumidor pode **não ser Delphi** (C, Python via ctypes, Java via JNI, Node.js via node-ffi)
- A biblioteca é **distribuída externamente** (como SDK para terceiros)
- Necessita **suporte a Linux** (`.so` via PAServer ou FPC)
- A integração com **COM/ActiveX** é requerida
- Quer **versioning independente** da aplicação host
- O sistema de plugins precisa aceitar **plugins de terceiros** (qualquer linguagem)

**Problemas comuns:**
- Esquecer a fronteira de memória → crashes aleatórios
- Mixing de calling conventions → stack corruption
- Dependências circulares entre DLLs → DLL Hell
- Path da DLL não no PATH do sistema → `LoadLibrary` retorna 0

---

## Quando Usar `.bpl`

**Use quando:**
- Todos os módulos são **Delphi/C++Builder**, mesma versão
- O package faz parte de um **IDE plugin** ou componente VCL/FMX
- Quer reduzir o **tamanho total do deploy** (RTL partilhada)
- O package é um **design-time package** (instalado no IDE)

**Problemas comuns:**
- BPL runtime não instalado na máquina do utilizador → erro ao carregar
- Versão do BPL incompatível com a da aplicação → crash na inicialização
- Múltiplas versões Delphi instaladas → conflito de packages
- `package ... requires` circulares → difícil de manter

**Requisitos de runtime packages:**
```
Delphi 12.x runtime packages (exemplos):
  rtl280.bpl       — RTL base
  vcl280.bpl       — VCL (se usar formulários)
  vclactnband280.bpl — VCL Action Bands
  dbrtl280.bpl     — Database RTL
  ... (muitos outros dependendo do que a app usa)
```

---

## Quando Usar Linking Estático (sem DLL/BPL)

Considere **não usar DLL** quando:
- O código será usado **apenas dentro do mesmo projecto**
- Não há necessidade de actualização independente do módulo
- O overhead de IPC entre módulos é proibitivo (dados críticos de performance)
- A DLL teria apenas 1-2 funções — a complexidade não compensa

---

## Problemas Comuns por Abordagem

### `.dll` — problemas frequentes

| Problema | Causa | Solução |
|----------|-------|---------|
| `LoadLibrary` retorna 0 | DLL não encontrada, dependência ausente | Verificar PATH; usar `dumpbin /dependents` |
| `GetProcAddress` retorna nil | Função não exportada, nome errado, calling conv errada | Verificar cláusula `exports`; usar `dumpbin /exports` |
| Crash no `Free` | Fronteira de memória — heap errado | ShareMem, POD, ou interface approach |
| Stack corruption | Calling convention errada | Alinhar `stdcall`/`cdecl` entre DLL e host |
| DLL carregada duas vezes | Paths diferentes para o mesmo ficheiro | Usar path absoluto; `SetDllDirectory` |

### `.bpl` — problemas frequentes

| Problema | Causa | Solução |
|----------|-------|---------|
| `EPackageError` ao carregar | BPL runtime ausente | Incluir BPLs no installer |
| Crash imediato | Versão do BPL incompatível | Recompilar com a versão correcta |
| Componente não aparece | Package não instalado no IDE | Instalar via Component > Install Packages |
| `abstract error` | Versão da interface mudou sem recompilar o BPL dependente | Recompilar toda a árvore de dependências |

---

## Exemplo de Decisão

```
Preciso de um módulo de processamento de dados para GestorERP:

Q: Será chamado por Python (scripts de automação)?
→ SIM → .dll com API POD (cdecl)

Q: Apenas Delphi, mesmo projeto, sem distribuição externa?
→ SIM → considere unit normal ou .bpl

Q: Plugin de terceiros com contrato de interface estável?
→ SIM → .dll com interface approach (IPlugin)

Q: Componente visual VCL instalado no IDE?
→ SIM → .bpl obrigatório
```
