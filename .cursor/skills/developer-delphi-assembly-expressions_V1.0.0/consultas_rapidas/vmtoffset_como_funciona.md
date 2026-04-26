# VMTOFFSET — Como Funciona — Consulta Rapida

## Estrutura da VMT (Virtual Method Table) no Delphi

```
Objeto em memoria:
  [Obj + 0] = ponteiro para VMT   ← primeiro campo de qualquer objeto Delphi

VMT em memoria (tabela de ponteiros de funcao):
  VMT[-12] = endereco de Destroy
  VMT[-8]  = endereco de FreeInstance
  VMT[-4]  = endereco de SafeCallException
  VMT[0]   = ... campos internos do Delphi ...
  VMT[VMTOFFSET TClasse.Metodo1] = ponteiro para Metodo1
  VMT[VMTOFFSET TClasse.Metodo2] = ponteiro para Metodo2
  ...
```

## Chamada virtual normal (gerada pelo compilador):

```pascal
// Pascal: Obj.MetodoVirtual;
// Gera assembly:
// MOV EAX, [Obj]           // EAX = ponteiro para VMT
// CALL DWORD PTR [EAX + N] // N = offset do metodo na VMT
```

## Chamada via VMTOFFSET (explicita no asm):

```pascal
procedure ChamarVirtual(Obj: TMinhaClasse);
asm
  // EAX = Obj (convencao register)
  MOV ECX, [EAX]            // ECX = ponteiro para VMT
  CALL DWORD PTR [ECX + VMTOFFSET TMinhaClasse.MeuMetodoVirtual]
  // Equivale a: Obj.MeuMetodoVirtual;
end;
```

## Por que usar VMTOFFSET?

1. **Verificacao em tempo de compilacao:** Se o metodo nao existir ou nao for virtual, o compilador erra. Pascal normal com o metodo tambem faria isso, mas VMTOFFSET explicita a intencao.

2. **Acesso a metodo de classe base:** Pode forcar a chamada ao metodo da classe base especificada:
```pascal
CALL DWORD PTR [ECX + VMTOFFSET TBase.MetodoVirtual]
// Chama SEMPRE a versao de TBase, mesmo em objeto de TDerivada
```

3. **Tabela de dispatch manual:** Em hot paths, pode-se montar uma tabela de funcoes usando os offsets:
```pascal
var
  OffSet: Integer;
begin
  Offset := VMTOFFSET TMinhaClasse.Processar;
  // Usar offset para chamar sem verificacao em loop interno
end;
```

## Limitacoes

- Apenas para metodos `virtual` (nao `dynamic`, nao `message`)
- Apenas em Win32/Win64 (nao iOS/Android)
- O offset pode mudar entre compilacoes se a hierarquia de heranca muda
