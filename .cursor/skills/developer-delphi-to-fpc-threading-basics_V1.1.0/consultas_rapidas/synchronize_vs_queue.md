# Synchronize vs Queue — Quando usar

## Resumo rápido

| Característica | `Synchronize(proc)` | `Queue(proc)` |
|---|---|---|
| Comportamento | **Bloqueante** — pausa a thread secundária até `proc` terminar na main thread | **Não bloqueante** — enfileira `proc` e continua imediatamente |
| Retorno de dados | Sim — pode ler variáveis após Synchronize retornar | Não — proc roda depois; thread secundária já avançou |
| Risco de deadlock | **Alto** — se main thread estiver bloqueada (ex.: WaitFor) | Baixo |
| Performance | Menor — há sincronização full | Maior — não há espera |
| Ordem garantida | Sim — executa na ordem chamada | Sim — fila FIFO |

---

## Quando usar Synchronize

Use `Synchronize` quando precisar do resultado da operação de UI **antes de continuar** o processamento:

```pascal
procedure TWorker.Execute;
var
  EntradaUsuario: string;
begin
  // Precisamos da entrada antes de continuar — usar Synchronize
  Synchronize(procedure
  begin
    EntradaUsuario := InputBox('Dados', 'Informe o valor:', '');
  end);
  // Só chega aqui após o usuário confirmar o InputBox
  ProcessarEntrada(EntradaUsuario);
end;
```

### Armadilha: Synchronize + WaitFor = Deadlock

```pascal
// NUNCA FAZER ISSO:
var W: TWorkerThread;
W := TWorkerThread.Create;
W.WaitFor;  // main thread bloqueia aqui esperando worker terminar
            // worker chama Synchronize → espera main thread processar
            // main thread não processa porque está em WaitFor
            // → DEADLOCK

// SOLUCAO: aguardar em thread separada, ou usar Queue
```

---

## Quando usar Queue

Use `Queue` quando a UI precisa ser atualizada mas o resultado não importa para a thread:

```pascal
procedure TWorker.Execute;
var
  I: Integer;
begin
  for I := 1 to 100 do
  begin
    ProcessarItem(I);
    // Atualizar progresso — não precisamos esperar a UI confirmar
    var Pos := I;
    Queue(procedure
    begin
      ProgressBar1.Position := Pos;
      Label1.Caption := Format('Item %d/100', [Pos]);
    end);
  end;

  // Notificação final
  Queue(procedure
  begin
    ShowMessage('Processamento concluído!');
  end);
end;
```

---

## Uso de `TThread.Queue(nil, proc)` fora de instância TThread

```pascal
// Pode ser chamado de qualquer contexto sem referência a TThread
TThread.Queue(nil, procedure
begin
  // Executa na main thread
  AtualizarUI;
end);

// Equivalente: TThread.Synchronize(nil, proc) — bloqueante mesmo sem instância
TThread.Synchronize(nil, procedure
begin
  ValorCapturado := EditBox.Text;
end);
```

---

## Fluxograma de decisão

```
Preciso atualizar a UI de uma thread secundária?
│
├─ Preciso do resultado (valor de volta) antes de continuar?
│   ├─ SIM → Synchronize
│   │         (cuidado: a main thread não pode estar bloqueada)
│   └─ NÃO → Queue (preferido na maioria dos casos)
│
└─ Estou chamando de contexto sem instância TThread?
    → TThread.Queue(nil, proc) ou TThread.Synchronize(nil, proc)
```

---

## Referências cruzadas

- `exemplos/tthread_basico.pas` — uso de Synchronize e Queue em TWorkerThread
- `thread_safety_regras.md` — regras gerais de acesso seguro à UI
- `developer-delphi-to-fpc-threading-advanced_V1.1.0` — TTask com continuação na main thread
