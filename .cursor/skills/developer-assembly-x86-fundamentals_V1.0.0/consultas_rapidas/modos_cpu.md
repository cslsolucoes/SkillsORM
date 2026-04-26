# Modos de operação x86 — Referência para Delphi

## Comparação dos modos

| Característica | Real Mode | Protected Mode | Long Mode (x64) |
|----------------|-----------|----------------|-----------------|
| Largura de dados | 16-bit | 32-bit | 64-bit |
| Espaço de endereço | 1 MB (20 bits) | 4 GB (32 bits) | 2^48 bytes (efetivo) |
| Proteção de memória | Nenhuma | Segmentação + paginação | Paginação (4 ou 5 níveis) |
| Registradores gerais | AX, BX... (16-bit) | EAX, EBX... (32-bit) | RAX, RBX... (64-bit) |
| Registradores adicionais | — | — | R8-R15 |
| Stack padrão | 16-bit (SP) | 32-bit (ESP) | 64-bit (RSP) |
| Compilador Delphi | — | dcc32 | dcc64 |
| Windows correspondente | DOS/BIOS | Windows 32-bit | Windows 64-bit |

## Real Mode (Modo Real)

- CPU inicia sempre em Real Mode ao ligar
- Segmentação simples: endereço físico = Segmento × 16 + Offset
- Sem proteção: um programa pode sobrescrever qualquer endereço
- Usado em: BIOS, bootloaders, DOS
- **Não relevante para Delphi moderno**

```
Endereço físico = CS × 16 + IP   (para código)
Endereço físico = DS × 16 + SI   (para dados)
```

## Protected Mode (Modo Protegido — 32-bit)

- Ativado pelo Windows para todos os processos de usuário 32-bit
- Segmentação via GDT/LDT, mas no modelo flat todos os segmentos cobrem 0–4GB
- Paginação habilitada: endereços virtuais → físicos via page tables
- **dcc32 gera código para este modo**
- Registradores: EAX, EBX, ECX, EDX, ESI, EDI, ESP, EBP

```
Endereços em flat model 32-bit:
  CS base = 0, limite = 4 GB → código acessa qualquer endereço diretamente
  DS base = 0, limite = 4 GB → dados idem
  SS base = 0, limite = 4 GB → stack idem
```

## Long Mode / IA-32e (64-bit)

- Submode padrão do Windows 64-bit
- Segmentação essencialmente desativada (bases 0, limites ignorados, exceto FS/GS)
- Paginação de 4 níveis: PML4 → PDPT → PD → PT → página de 4 KB
- **dcc64 gera código para este modo**
- Registradores: RAX-RSP + R8-R15 + XMM/YMM/ZMM

```
Endereçamento canonico x64:
  Bits [63:48] devem ser cópias do bit 47
  Espaço de usuário:  0x0000000000000000 – 0x00007FFFFFFFFFFF
  Espaço de kernel:   0xFFFF800000000000 – 0xFFFFFFFFFFFFFFFF
```

## Impacto prático no Delphi

```pascal
// dcc32 (32-bit, Protected Mode):
// - Ponteiros têm 4 bytes
// - NativeInt = Integer (32-bit)
// - Registradores asm: EAX, EDX, ECX, EBX, ESI, EDI, ESP, EBP
// - Convenção "register": EAX=1°param, EDX=2°, ECX=3°

// dcc64 (64-bit, Long Mode):
// - Ponteiros têm 8 bytes
// - NativeInt = Int64 (64-bit)
// - Registradores asm: RAX, RDX, RCX, RBX, RSI, RDI, RSP, RBP, R8-R15
// - Windows x64 ABI: RCX=1°param, RDX=2°, R8=3°, R9=4°

{$IF SizeOf(Pointer) = 4}
  // Rodando em 32-bit
{$ELSE}
  // Rodando em 64-bit
{$ENDIF}
```
