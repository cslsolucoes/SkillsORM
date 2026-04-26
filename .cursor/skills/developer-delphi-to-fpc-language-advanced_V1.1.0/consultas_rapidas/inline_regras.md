# Funções Inline em Delphi

## O que é `inline`

A diretiva `inline` solicita ao compilador que substitua a chamada da função pelo corpo da função no ponto de chamada — eliminando o overhead de call/ret e permitindo otimizações adicionais.

```pascal
function Dobrar(N: Integer): Integer; inline;
begin
  Result := N * 2;
end;

// Compilador pode transformar:
var X := Dobrar(5);    // chamada com overhead
// em:
var X := 5 * 2;        // inlining — sem overhead de chamada
```

## Quando inline é expandido (condições para o compilador aceitar)

- Função pequena e simples (corpo curto)
- Chamada em código de alta frequência (loops apertados)
- Compilação em modo Release (`{$O+}` otimizações ligadas)
- Compilador decide: `inline` é uma **sugestão**, não uma garantia

## Limitações — quando inline NÃO funciona

```pascal
// 1. Função recursiva — NÃO pode ser inline
function Fatorial(N: Integer): Integer; inline;  // AVISO do compilador
begin
  if N <= 1 then Result := 1
  else Result := N * Fatorial(N - 1);  // recursão → impossível inlining
end;

// 2. Função com bloco asm..end
function SomarSSE(A, B: Integer): Integer; inline;  // AVISO
begin
  asm
    // code
  end;
end;

// 3. Função com procedimentos locais
function Processar(N: Integer): Integer; inline;  // AVISO
  procedure AuxiliarLocal;  // sub-procedure → impede inline
  begin ...
  end;
begin ...
end;

// 4. Função com variáveis de pilha abertas (open arrays com size desconhecido)
function SomarArray(const A: array of Integer): Integer; inline;  // AVISO
begin ...
end;

// 5. Funções de unidade diferente sem {$O+} na unit de origem
// O compilador inline só atravessa fronteiras de unit com otimização ativa
```

## Modo Debug vs Release

```pascal
{$IFOPT O+}  // Otimização ligada?
  // Inline expandido normalmente
{$ELSE}
  // Em Debug ({$O-}): inline pode ser ignorado pelo compilador
  // Funções inline ainda são compiladas como chamadas normais
{$ENDIF}
```

## Candidatos ideais para inline

```pascal
// Getters simples de propriedade
function GetId: Integer; inline;
begin Result := FId; end;

// Conversões triviais
function CentavosParaReais(N: Int64): Double; inline;
begin Result := N / 100.0; end;

// Predicados pequenos em loops
function EhPar(N: Integer): Boolean; inline;
begin Result := N mod 2 = 0; end;

// Clamp / Min / Max customizados
function Clamp(V, Min, Max: Integer): Integer; inline;
begin
  if V < Min then Result := Min
  else if V > Max then Result := Max
  else Result := V;
end;
```

## Incompatibilidade com FPC

```pascal
// FPC suporta inline, mas comportamento pode divergir:
// - FPC pode ignorar inline em situações que Delphi expande
// - Em código cross-compiler, inline é SEGURO (compiladores escolhem)
// - Não usar inline em métodos virtuais — não faz sentido semântico
{$IF DEFINED(FPC)}
  {$INLINE ON}  // garantir que inline está habilitado no FPC
{$ENDIF}
```

## Regra de ouro

```
Use inline quando:
  1. Função é trivialmente simples (1-5 linhas)
  2. Chamada em hot loop (>100.000x por segundo)
  3. Sem recursão, sem asm, sem procedimentos locais

Não use inline quando:
  - Função tem lógica complexa (não melhora nada, aumenta binário)
  - Método virtual (inlining não é possível por definição)
  - Depurar frequentemente (inline dificulta step-through no debugger)
```
