unit ioutils;
{
  TPath, TFile, TDirectory — sistema de arquivos cross-platform
  Compilavel: dcc32 / dcc64
  Requer: System.IOUtils
}

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Types;

procedure DemoTPath;
procedure DemoTFile;
procedure DemoTDirectory;
procedure DemoTempFiles;
procedure DemoFileWatch;

implementation

// ---------------------------------------------------------------------------
// DemoTPath — manipulação de caminhos
// ---------------------------------------------------------------------------

procedure DemoTPath;
var Caminho: string;
begin
  Caminho := 'C:\Projetos\MeuApp\src\Main\Unit1.pas';

  // Componentes
  Writeln('GetDirectoryName: ', TPath.GetDirectoryName(Caminho));
  // C:\Projetos\MeuApp\src\Main

  Writeln('GetFileName: ',      TPath.GetFileName(Caminho));
  // Unit1.pas

  Writeln('GetFileNameWithoutExtension: ',
    TPath.GetFileNameWithoutExtension(Caminho));
  // Unit1

  Writeln('GetExtension: ', TPath.GetExtension(Caminho));
  // .pas

  // Combinar caminhos (cross-platform)
  var Base := 'C:\Projetos';
  Writeln('Combine: ', TPath.Combine(Base, 'MeuApp', 'src', 'main.pas'));

  // Caminhos especiais do SO
  Writeln('GetTempPath: ',     TPath.GetTempPath);
  Writeln('GetDocumentsPath: ',TPath.GetDocumentsPath);
  Writeln('GetHomePath: ',     TPath.GetHomePath);
  Writeln('GetPublicPath: ',   TPath.GetPublicPath);

  // Caracteres inválidos
  var Invalidos := TPath.GetInvalidFileNameChars;
  Writeln('Chars inválidos no nome: ', Length(Invalidos));

  // Mudar extensão
  Writeln('ChangeExtension: ', TPath.ChangeExtension(Caminho, '.dcu'));

  // IsPathRooted
  Writeln('IsPathRooted (absoluto): ', TPath.IsPathRooted(Caminho));
  Writeln('IsPathRooted (relativo): ', TPath.IsPathRooted('relative\path'));
end;

// ---------------------------------------------------------------------------
// DemoTFile — leitura, escrita e manipulação de arquivos
// ---------------------------------------------------------------------------

procedure DemoTFile;
const ARQ = 'tfile_demo.txt';
var Linhas: TStringDynArray;
    L:      string;
begin
  // WriteAllText — cria ou sobrescreve
  TFile.WriteAllText(ARQ, 'Linha 1'#13#10'Linha 2'#13#10'Linha 3', TEncoding.UTF8);
  Writeln('Arquivo criado, Size: ', TFile.GetSize(ARQ));

  // ReadAllText
  var Conteudo := TFile.ReadAllText(ARQ, TEncoding.UTF8);
  Writeln('ReadAllText: ', Length(Conteudo), ' chars');

  // ReadAllLines — retorna TArray<string>
  Linhas := TFile.ReadAllLines(ARQ, TEncoding.UTF8);
  Writeln('Linhas: ', Length(Linhas));
  for L in Linhas do Writeln('  > ', L);

  // AppendAllText — acrescenta sem abrir/fechar explicitamente
  TFile.AppendAllText(ARQ, 'Linha 4'#13#10, TEncoding.UTF8);
  Writeln('Após Append: ', TFile.GetSize(ARQ), ' bytes');

  // WriteAllLines
  TFile.WriteAllLines(ARQ, ['Alpha', 'Beta', 'Gamma'], TEncoding.UTF8);
  Linhas := TFile.ReadAllLines(ARQ);
  Writeln('WriteAllLines — Count: ', Length(Linhas));

  // Atributos
  Writeln('Exists: ',         TFile.Exists(ARQ));
  Writeln('GetCreationTime: ',TFile.GetCreationTime(ARQ).ToString('dd/MM/yyyy HH:mm'));
  Writeln('GetLastWriteTime:',TFile.GetLastWriteTime(ARQ).ToString('HH:mm:ss'));

  // ReadAllBytes / WriteAllBytes
  var Bytes := TFile.ReadAllBytes(ARQ);
  Writeln('ReadAllBytes: ', Length(Bytes), ' bytes');

  // Copy / Move
  TFile.Copy(ARQ, ARQ + '.bak');
  Writeln('Copy OK — .bak Exists: ', TFile.Exists(ARQ + '.bak'));

  TFile.Move(ARQ + '.bak', ARQ + '.bak2');
  Writeln('Move OK — .bak2 Exists: ', TFile.Exists(ARQ + '.bak2'));

  // Delete
  TFile.Delete(ARQ);
  TFile.Delete(ARQ + '.bak2');
  Writeln('Após Delete, Exists: ', TFile.Exists(ARQ));
end;

// ---------------------------------------------------------------------------
// DemoTDirectory — criação, listagem e remoção de diretórios
// ---------------------------------------------------------------------------

procedure DemoTDirectory;
const DIR_BASE = 'demo_dir';
var Arquivos, Dirs: TStringDynArray;
    F: string;
begin
  // Criar estrutura
  TDirectory.CreateDirectory(DIR_BASE);
  TDirectory.CreateDirectory(TPath.Combine(DIR_BASE, 'sub1'));
  TDirectory.CreateDirectory(TPath.Combine(DIR_BASE, 'sub2'));

  // Criar alguns arquivos
  TFile.WriteAllText(TPath.Combine(DIR_BASE, 'a.txt'), 'conteudo a');
  TFile.WriteAllText(TPath.Combine(DIR_BASE, 'b.txt'), 'conteudo b');
  TFile.WriteAllText(TPath.Combine(DIR_BASE, 'c.pas'), 'unit c;');
  TFile.WriteAllText(TPath.Combine(DIR_BASE, 'sub1', 'd.txt'), 'sub');

  // Exists
  Writeln('Exists: ', TDirectory.Exists(DIR_BASE));

  // GetFiles — apenas no diretório
  Arquivos := TDirectory.GetFiles(DIR_BASE, '*.txt');
  Writeln('*.txt no dir: ', Length(Arquivos));
  for F in Arquivos do Writeln('  ', TPath.GetFileName(F));

  // GetFiles recursivo
  Arquivos := TDirectory.GetFiles(DIR_BASE, '*.txt', TSearchOption.soAllDirectories);
  Writeln('*.txt recursivo: ', Length(Arquivos));

  // GetDirectories
  Dirs := TDirectory.GetDirectories(DIR_BASE);
  Writeln('Subdiretórios: ', Length(Dirs));
  for F in Dirs do Writeln('  ', TPath.GetFileName(F));

  // GetFileSystemEntries — mistura arquivos e diretórios
  var All := TDirectory.GetFileSystemEntries(DIR_BASE);
  Writeln('Entradas totais: ', Length(All));

  // Mover diretório
  TDirectory.Move(DIR_BASE, DIR_BASE + '_moved');
  Writeln('Move OK: ', TDirectory.Exists(DIR_BASE + '_moved'));

  // Deletar recursivamente
  TDirectory.Delete(DIR_BASE + '_moved', True {recursive});
  Writeln('Delete recursivo OK: ', not TDirectory.Exists(DIR_BASE + '_moved'));
end;

// ---------------------------------------------------------------------------
// DemoTempFiles — arquivos e diretórios temporários
// ---------------------------------------------------------------------------

procedure DemoTempFiles;
var TempDir:  string;
    TempFile: string;
begin
  // Diretório temporário do SO
  TempDir := TPath.GetTempPath;
  Writeln('TempPath: ', TempDir);

  // Nome de arquivo temporário único
  TempFile := TPath.GetTempFileName;
  Writeln('TempFile: ', TempFile);
  Writeln('TempFile Exists: ', TFile.Exists(TempFile));  // criado vazio

  // Usar e deletar
  TFile.WriteAllText(TempFile, 'dados temporários', TEncoding.UTF8);
  var Dados := TFile.ReadAllText(TempFile);
  Writeln('Lido de temp: ', Dados);
  TFile.Delete(TempFile);

  // Criar subdir temporário
  var TempSubDir := TPath.Combine(TempDir, 'DemoDelphiStreams_' + FormatDateTime('yyyymmddhhnnss', Now));
  TDirectory.CreateDirectory(TempSubDir);
  Writeln('Temp subdir criado: ', TDirectory.Exists(TempSubDir));
  TDirectory.Delete(TempSubDir);
end;

// ---------------------------------------------------------------------------
// DemoFileWatch — informações de atributos e timestamps
// ---------------------------------------------------------------------------

procedure DemoFileWatch;
const ARQ = 'watch_demo.txt';
var T1, T2: TDateTime;
begin
  TFile.WriteAllText(ARQ, 'inicial', TEncoding.UTF8);
  T1 := TFile.GetLastWriteTime(ARQ);
  Writeln('LastWrite após criação: ', FormatDateTime('HH:mm:ss.zzz', T1));

  // Modificar
  Sleep(100);
  TFile.AppendAllText(ARQ, ' modificado', TEncoding.UTF8);
  T2 := TFile.GetLastWriteTime(ARQ);
  Writeln('LastWrite após modificação: ', FormatDateTime('HH:mm:ss.zzz', T2));
  Writeln('Arquivo foi modificado: ', T2 > T1);

  // Atributos
  TFile.SetAttributes(ARQ, [TFileAttribute.faReadOnly]);
  var Attrs := TFile.GetAttributes(ARQ);
  Writeln('ReadOnly: ', TFileAttribute.faReadOnly in Attrs);

  // Remover ReadOnly antes de deletar
  TFile.SetAttributes(ARQ, []);
  TFile.Delete(ARQ);
  Writeln('Deletado após remover ReadOnly: ', not TFile.Exists(ARQ));
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoTPath;
//   DemoTFile;
//   DemoTDirectory;
//   DemoTempFiles;
//   DemoFileWatch;
// ---------------------------------------------------------------------------

end.
