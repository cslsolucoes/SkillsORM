# Modos de Abertura de TFileStream — Flags fmXxx e fmShareXxx

## Constantes de modo

```pascal
// Abertura
fmCreate       = $FF00  // Cria novo ou sobrescreve existente
fmOpenRead     = $0000  // Abre só para leitura
fmOpenWrite    = $0001  // Abre só para escrita (posição=0)
fmOpenReadWrite= $0002  // Abre para leitura e escrita

// Compartilhamento (OR com modo)
fmShareCompat    = $0000  // Compatibilidade (Windows)
fmShareExclusive = $0010  // Acesso exclusivo — nenhum outro processo abre
fmShareDenyWrite = $0020  // Outros podem ler, não escrever
fmShareDenyRead  = $0030  // Outros podem escrever, não ler
fmShareDenyNone  = $0040  // Acesso compartilhado total
```

---

## Combinações mais usadas

| Intenção | Flags |
|----------|-------|
| Criar/sobrescrever | `fmCreate` |
| Criar, compartilhável para leitura | `fmCreate or fmShareDenyWrite` |
| Leitura somente | `fmOpenRead or fmShareDenyNone` |
| Leitura exclusiva | `fmOpenRead or fmShareExclusive` |
| Escrita para append | `fmOpenWrite or fmShareDenyWrite` |
| Leitura + escrita | `fmOpenReadWrite or fmShareDenyWrite` |
| Leitura de log compartilhado | `fmOpenRead or fmShareDenyNone` |

---

## Exemplos

```pascal
// Criar arquivo
FS := TFileStream.Create('arq.dat', fmCreate);

// Leitura compartilhada (outros processos podem ler simultaneamente)
FS := TFileStream.Create('arq.dat', fmOpenRead or fmShareDenyNone);

// Append: abre para escrita e posiciona no final
FS := TFileStream.Create('log.txt', fmOpenWrite or fmShareDenyWrite);
FS.Seek(0, soEnd);  // ir para o fim

// Leitura + escrita (ex.: atualizar campo específico)
FS := TFileStream.Create('dados.bin', fmOpenReadWrite or fmShareExclusive);
```

---

## Seek — origens

```pascal
soBeginning = 0  // Absoluto desde o início
soCurrent   = 1  // Relativo à posição atual
soEnd       = 2  // Relativo ao final (use valor negativo para voltar)

// Exemplos:
FS.Seek(0, soBeginning);   // início
FS.Seek(0, soEnd);         // fim (append position)
FS.Seek(-10, soEnd);       // 10 bytes antes do fim
FS.Seek(5, soCurrent);     // avança 5 bytes
FS.Position := 100;        // atalho para Seek(100, soBeginning)
```

---

## TFileStream vs TFile

| Situação | Preferir |
|----------|----------|
| Leitura/escrita contínua, grande arquivo | `TFileStream` |
| Leitura de tudo de uma vez (pequeno arquivo) | `TFile.ReadAllText/ReadAllBytes` |
| Append de linha | `TFile.AppendAllText` |
| Streaming com encoding (linha a linha) | `TStreamReader` / `TStreamWriter` |
| Operações de alto nível (Copy/Move/Delete/Exists) | `TFile` |

---

## Erros comuns

| Erro | Causa | Solução |
|------|-------|---------|
| `EFOpenError` | Arquivo não existe com `fmOpenRead` | Verificar `TFile.Exists` antes |
| `EFCreateError` | Sem permissão para criar | Verificar permissões de pasta |
| Arquivo travado | Outro processo com `fmShareExclusive` | Usar `fmShareDenyNone` ou tentar novamente |
| Append no início | Esqueceu de `Seek(0, soEnd)` após `fmOpenWrite` | Sempre chamar Seek antes de escrever para append |
| Stream leak | Exceção antes do `finally FS.Free` | Sempre encapsular em try/finally |

---

## Padrão seguro de abertura

```pascal
if not TFile.Exists(Caminho) then
  raise EFileNotFoundException.Create('Arquivo não encontrado: ' + Caminho);

FS := TFileStream.Create(Caminho, fmOpenRead or fmShareDenyNone);
try
  // ...usar FS...
finally
  FS.Free;
end;
```
