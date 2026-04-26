# overload vs override — Diferença Semântica

## Definições

| | `overload` | `override` |
|---|-----------|-----------|
| **O que faz** | Cria **nova assinatura** com o mesmo nome | **Substitui** a implementação herdada |
| **Tipo** | Resolução em **tempo de compilação** (estático) | Resolução em **tempo de execução** (polimórfico) |
| **Requer** | Assinaturas diferentes (parâmetros distintos) | Mesmo nome + mesma assinatura que o virtual da base |
| **Herança necessária?** | Não | Sim (requer `virtual` ou `dynamic` na base) |

## overload — múltiplas assinaturas

```pascal
type
  TCalc = class
    function Somar(A, B: Integer): Integer; overload;
    function Somar(A, B: Double): Double; overload;
    function Somar(const A: TArray<Integer>): Integer; overload;
  end;

// Compilador escolhe qual chamar PELO TIPO DOS ARGUMENTOS
var Calc := TCalc.Create;
Calc.Somar(1, 2);           // chama (Integer, Integer)
Calc.Somar(1.5, 2.5);       // chama (Double, Double)
Calc.Somar([1, 2, 3, 4]);   // chama (TArray<Integer>)
```

## override — polimorfismo

```pascal
type
  TAnimal = class
    procedure FazerSom; virtual;
  end;

  TCao = class(TAnimal)
    procedure FazerSom; override;  // substitui a implementação
  end;

// Compilador NÃO escolhe — a VMT decide em runtime
var A: TAnimal := TCao.Create;
A.FazerSom; // chama TCao.FazerSom, mesmo que A seja TAnimal
```

## Combinando overload + override

```pascal
type
  TBase = class
    procedure Log(const AMensagem: string); virtual; overload;
    procedure Log(ACodigoErro: Integer);   virtual; overload;
  end;

  TFilho = class(TBase)
    // Sobrescrever uma das sobrecargas
    procedure Log(const AMensagem: string); override; overload;
    // A outra sobrecarga (ACodigoErro: Integer) é herdada sem modificação
  end;
```

## reintroduce — esconder sem polimorfismo

```pascal
type
  TBase = class
    procedure Processar(A: Integer); virtual;
  end;

  TFilho = class(TBase)
    // reintroduce: esconde a versão da base — NÃO é polimórfico
    procedure Processar(A: Integer); reintroduce; overload;
    procedure Processar(A: string);  overload;
  end;

// Consequência:
var B: TBase := TFilho.Create;
B.Processar(42); // chama TBase.Processar — NÃO TCao.Processar!

var F: TFilho := TFilho.Create;
F.Processar(42);     // chama TFilho.Processar(Integer)
F.Processar('ola');  // chama TFilho.Processar(string)
```

## Erros comuns

```pascal
// ERRO: override sem virtual na base → EAccessViolation potencial
type
  TBase = class
    procedure Metodo;  // sem virtual
  end;
  TFilho = class(TBase)
    procedure Metodo; override;  // AVISO do compilador: "Method overrides virtual method"
  end;

// ERRO: assinar diferente e chamar de override
type
  TBase = class
    procedure Gravar(AId: Integer); virtual;
  end;
  TFilho = class(TBase)
    procedure Gravar(AId: Integer; AForcar: Boolean); override; // ERRO: assinatura diferente
    // Correto seria: overload (nova sobrecarga) ou override COM mesma assinatura
  end;
```

## Regra de ouro

```
override  → substituir comportamento herdado (polimorfismo)
overload  → oferecer conveniência com tipos/parâmetros diferentes
reintroduce → esconder (raramente necessário, geralmente um code smell)
```
