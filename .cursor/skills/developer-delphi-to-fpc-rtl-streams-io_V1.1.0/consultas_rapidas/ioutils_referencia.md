# TPath / TFile / TDirectory — Referência Rápida

## TPath — manipulação de caminhos (sem I/O)

```pascal
uses System.IOUtils;

// Decompor
TPath.GetDirectoryName('C:\dir\sub\arq.ext')  // 'C:\dir\sub'
TPath.GetFileName('C:\dir\sub\arq.ext')        // 'arq.ext'
TPath.GetFileNameWithoutExtension('arq.ext')   // 'arq'
TPath.GetExtension('arq.ext')                  // '.ext'

// Combinar (cross-platform — usa \ no Windows, / no macOS/Linux)
TPath.Combine('C:\dir', 'sub', 'arq.txt')      // 'C:\dir\sub\arq.txt'

// Alterar extensão
TPath.ChangeExtension('arq.pas', '.dcu')        // 'arq.dcu'

// Verificar
TPath.IsPathRooted('C:\dir')                    // True (absoluto)
TPath.IsPathRooted('relative\dir')              // False

// Caminhos especiais do SO
TPath.GetTempPath        // pasta temporária (%TEMP%)
TPath.GetTempFileName    // arquivo temporário único (cria o arquivo vazio)
TPath.GetHomePath        // pasta do usuário (%USERPROFILE%)
TPath.GetDocumentsPath   // Documents
TPath.GetPublicPath      // C:\Users\Public
TPath.GetLibraryPath     // AppData\Local (mobile: data dir)

// Chars inválidos
TPath.GetInvalidFileNameChars  // TArray<Char>
TPath.GetInvalidPathChars
TPath.HasValidPathChars('arq.txt', False)  // valida nome de arquivo
```

---

## TFile — operações em arquivo

```pascal
// Verificar existência
TFile.Exists('arq.txt')                    // Boolean

// Leitura completa
TFile.ReadAllText('arq.txt')               // string (detects BOM)
TFile.ReadAllText('arq.txt', TEncoding.UTF8)
TFile.ReadAllLines('arq.txt')              // TStringDynArray
TFile.ReadAllBytes('arq.bin')              // TBytes

// Escrita (cria ou sobrescreve)
TFile.WriteAllText('arq.txt', 'conteúdo', TEncoding.UTF8)
TFile.WriteAllLines('arq.txt', ['L1','L2'], TEncoding.UTF8)
TFile.WriteAllBytes('arq.bin', Bytes)

// Append
TFile.AppendAllText('log.txt', 'nova linha'#13#10, TEncoding.UTF8)
TFile.AppendAllLines('log.txt', ['L1','L2'], TEncoding.UTF8)

// Copiar / Mover / Deletar
TFile.Copy('src.txt', 'dst.txt')           // EIOException se dst existe
TFile.Copy('src.txt', 'dst.txt', True)     // overwrite=True
TFile.Move('old.txt', 'new.txt')
TFile.Delete('arq.txt')                    // sem raise se não existe

// Tamanho
TFile.GetSize('arq.txt')                   // Int64

// Timestamps
TFile.GetCreationTime('arq.txt')           // TDateTime
TFile.GetLastWriteTime('arq.txt')
TFile.GetLastAccessTime('arq.txt')
TFile.SetLastWriteTime('arq.txt', Now)

// Atributos
TFile.GetAttributes('arq.txt')             // TFileAttributes set
TFile.SetAttributes('arq.txt', [TFileAttribute.faHidden])
// TFileAttribute: faReadOnly, faHidden, faSystem, faArchive, faNormal
```

---

## TDirectory — operações em diretório

```pascal
// Verificar / Criar
TDirectory.Exists('C:\dir')
TDirectory.CreateDirectory('C:\dir\sub')  // cria toda a hierarquia

// Listar arquivos
TDirectory.GetFiles('C:\dir')                        // todos os arquivos
TDirectory.GetFiles('C:\dir', '*.pas')               // com filtro
TDirectory.GetFiles('C:\dir', '*.pas', TSearchOption.soAllDirectories)  // recursivo

// Listar subdiretórios
TDirectory.GetDirectories('C:\dir')
TDirectory.GetDirectories('C:\dir', 'Proj*')         // com filtro

// Listar tudo (arquivos + dirs)
TDirectory.GetFileSystemEntries('C:\dir')
TDirectory.GetFileSystemEntries('C:\dir', '*.txt', TSearchOption.soAllDirectories)

// Copiar / Mover / Deletar
TDirectory.Move('C:\src', 'C:\dst')
TDirectory.Delete('C:\dir')               // vazio apenas
TDirectory.Delete('C:\dir', True)         // recursivo com conteúdo

// Timestamps
TDirectory.GetCreationTime('C:\dir')
TDirectory.GetLastWriteTime('C:\dir')

// IsEmpty
TDirectory.IsEmpty('C:\dir')              // True se sem arquivos/subdirs
```

---

## TSearchOption

```pascal
TSearchOption.soTopDirectoryOnly    // só o diretório especificado (padrão)
TSearchOption.soAllDirectories      // recursivo em toda a árvore
```

---

## Padrões comuns

```pascal
// Garantir que pasta existe antes de criar arquivo
TDirectory.CreateDirectory(TPath.GetDirectoryName(Caminho));
TFile.WriteAllText(Caminho, Conteudo);

// Listar todos os .pas recursivamente
var Arquivos := TDirectory.GetFiles(RaizProjeto, '*.pas',
  TSearchOption.soAllDirectories);
for var F in Arquivos do
  ProcessarArquivo(F);

// Caminho relativo → absoluto
var Abs := TPath.Combine(TDirectory.GetCurrentDirectory, 'relativo\arq.txt');

// Verificar e criar diretório temporário único
var TempDir := TPath.Combine(TPath.GetTempPath, 'MeuApp_' + TGUID.NewGuid.ToString);
TDirectory.CreateDirectory(TempDir);
try
  // usar TempDir
finally
  TDirectory.Delete(TempDir, True);
end;
```

---

## Diferenças de plataforma

| Operação | Windows | macOS/iOS | Android |
|----------|---------|-----------|---------|
| Separador | `\` | `/` | `/` |
| GetHomePath | `%USERPROFILE%` | `~/` | `/data/user/0/...` |
| GetTempPath | `%TEMP%` | `/tmp` | cache dir |
| Case sensitive | Não | Sim | Sim |

`TPath.Combine` usa o separador correto para cada plataforma.
