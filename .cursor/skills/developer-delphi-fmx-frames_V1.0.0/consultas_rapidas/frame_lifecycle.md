# Frame Lifecycle — Eventos e Ordem de Execução (FMX)

## Ordem de eventos ao criar um frame

```
1. constructor Create(AOwner)   ← alocar recursos, criar filhos
2. [atribuir Parent]            ← frame entra na cena visual
3. [atribuir Align]             ← layout calculado
4. OnResize                     ← disparado ao entrar na cena com tamanho
5. [exibição na tela]
```

## Destruição

```
1. [remover do Parent ou chamar Free]
2. destructor Destroy           ← liberar recursos alocados
   (Owner libera automaticamente se criado com Create(Self))
```

## Não existe OnShow/OnHide em TFrame FMX

TFrame herda de `TCustomForm`, mas em FMX os eventos `OnShow`/`OnHide` não
são disparados ao mudar `Visible`. Use:

| Quero detectar... | Use |
|-------------------|-----|
| Frame ficou visível | `OnResize` (primeiro resize = entrada na cena) |
| Visibilidade mudou | override de `procedure SetVisible(Value: Boolean)` |
| Frame sendo destruído | `destructor Destroy` |
| Foco recebido | `OnEnter` do TFrame |

## Padrão GestorERP: inicialização em dois passos

```pascal
// Passo 1: criar (sem dados)
Frame := TFrameClientes.Create(Self);
Frame.Parent := RecConteiner;
Frame.Align  := TAlignLayout.Client;

// Passo 2: carregar dados (depois que Parent está definido)
Frame.Carregar(CodigoCliente);
```

## Quando usar BeginUpdate / EndUpdate

```pascal
Frame.BeginUpdate;
try
  // Múltiplas mudanças visuais sem repintar a cada uma
  Frame.LblNome.Text := 'Novo nome';
  Frame.LblEmail.Text := 'novo@email.com';
  Frame.RecFundo.Fill.Color := $FFFFFFFF;
finally
  Frame.EndUpdate;
end;
```

## Checklist do ciclo de vida

- [ ] constructor: criar subcomponentes, inicializar variáveis, NÃO acessar dados externos
- [ ] Após `Parent :=`: frame está na tela, pode animar
- [ ] `Carregar(params)`: acessar banco, serviços, rede
- [ ] destructor: liberar objetos que não têm Owner (ex.: criados com `Create(nil)`)
- [ ] NUNCA chamar Free em componentes criados com `Create(Self)` — Owner faz isso
