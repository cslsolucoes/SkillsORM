# Quando usar cada skill — developer-delphi

> Tabela de cenarios comuns com skill recomendada e justificativa.
> Atualizado em: 11/04/2026 — FileVersion 1.1.0

---

## Familia A — FMX Layout

| Cenario | Skill recomendada | Por que |
| ------- | ----------------- | ------- |
| Criar tela FMX do zero com multiplos componentes | `fmx-layout` | Orquestradora: define estrutura, alinhamento e responsividade antes de detalhar |
| Organizar componentes em grade ou fluxo | `fmx-containers` | TGridLayout e TFlowLayout sao responsabilidade desta skill |
| Adicionar animacao de fade ou movimento | `fmx-animations` | TFloatAnimation, triggers e interpolacao ficam aqui |
| Aplicar sombra ou efeito visual em controle | `fmx-effects` | TShadowEffect, TGlowEffect, TBlurEffect — todos em fmx-effects |
| Implementar TListView com itens customizados | `fmx-components` | Componentes de entrada, exibicao e navegacao estao nesta skill |
| Criar frame reutilizavel para card de produto | `fmx-frames` | Composicao e uso de TFrame como unidade reutilizavel |
| Montar padrao CRUD completo com modal de edicao | `fmx-patterns` | Padroes de tela prontos (CRUD, master-detail, modal) |

---

## Familia B — Linguagem Core

| Cenario | Skill recomendada | Por que |
| ------- | ----------------- | ------- |
| Definir record com campos opcionais e variante | `language-types` | Tipos estruturados, variant records e type aliases |
| Implementar hierarquia de classes com interface | `language-oop` | Heranca, interfaces, visibilidade, construtores e destrutores |
| Criar lista generica com constraint de interface | `language-generics` | TList\<T\>, constraints, generic methods e wildcards |
| Inspecionar propriedades de objeto em runtime | `language-rtti` | TRttiContext, atributos, GetPropValue, SetPropValue |
| Usar anonymous method como callback de evento | `language-advanced` | Closures, anonymous methods, reference to procedure/function |
| Duvida sobre sintaxe cross-compiler Delphi+FPC | `language-core` | Orquestradora: compatibilidade, diretivas, estrutura de units |

---

## Familia C — Patterns

| Cenario | Skill recomendada | Por que |
| ------- | ----------------- | ------- |
| Criar fabrica de conexoes com multiplos engines | `patterns-creational` | Factory Method ou Abstract Factory para criacao variavel |
| Adicionar log transparente sem alterar classe original | `patterns-structural` | Decorator envolve a classe original sem modificar |
| Implementar notificacao entre modulos desacoplados | `patterns-behavioral` | Observer conecta produtor e consumidores sem dependencia direta |
| Nao sabe qual padrao usar para o problema | `patterns-composition` | Orquestradora: mapeia o problema ao padrao correto + DI |

---

## Familia D — RTL

| Cenario | Skill recomendada | Por que |
| ------- | ----------------- | ------- |
| Gerenciar lista de objetos com busca por chave | `rtl-collections` | TObjectList + TDictionary — colecoes tipadas e eficientes |
| Ler/gravar arquivo JSON de configuracao | `rtl-streams-io` | TJSONObject, TFileStream, TStreamReader sao desta skill |
| Validar email com regex e formatar CPF | `rtl-strings` | TRegEx e TStringHelper cobrem validacao e formatacao |
| Calcular diferenca entre datas em dias uteis | `rtl-and-units` | DateUtils e SysUtils — orquestradora da RTL geral |

---

## Familia E — Concorrencia e Performance

| Cenario | Skill recomendada | Por que |
| ------- | ----------------- | ------- |
| Executar download em segundo plano sem travar UI | `threading-basics` | TThread com Synchronize para atualizar UI com seguranca |
| Processar lista de 10.000 itens em paralelo | `threading-advanced` | TParallel.For distribui a carga entre nucleos automaticamente |
| Identificar funcao que consome 80% do CPU | `performance-profiling` | Sampling profiler e instrumentacao revelam gargalos reais |
| Detectar e corrigir memory leak em producao | `performance-and-memory` | FastMM e ReportMemoryLeaksOnShutdown sao o ponto de partida |
| Redesenhar arquitetura para suportar alta carga | `performance-and-architecture` | Cache, pooling e I/O async sao estrategias desta skill |

---

## Familia F — Qualidade e Testes

| Cenario | Skill recomendada | Por que |
| ------- | ----------------- | ------- |
| Escrever teste unitario para uma classe de calculo | `testing-dunitx` | DUnitX com TestFixture, Assert e mock de dependencias |
| Testar endpoint REST com banco de dados real | `testing-integration` | Fixture de banco + cliente HTTP em teste de integracao |
| Definir estrategia de testes para novo modulo | `testing-and-quality` | Orquestradora: decide o mix unitario/integracao/CI adequado |

---

## Familia G — Build e Entrega

| Cenario | Skill recomendada | Por que |
| ------- | ----------------- | ------- |
| Compilar para Win32 e Win64 via linha de comando | `build-cross-compiler` | dcc32/dcc64/fpc com opcoes e defines corretas |
| Gerar instalador InnoSetup com versionamento | `packaging-delivery` | Empacotamento, assinatura digital e script de instalador |

---

## Familia H — Diagnostico e Debug

| Cenario | Skill recomendada | Por que |
| ------- | ----------------- | ------- |
| Tratar excecao de acesso a banco com log estruturado | `error-handling-and-diagnostics` | Hierarquia de excecoes + logger multi-destino |
| Depurar valor incorreto em loop complexo | `debugging-techniques` | Breakpoint condicional + watch expression no IDE |

---

## Familia I — Arquitetura

| Cenario | Skill recomendada | Por que |
| ------- | ----------------- | ------- |
| Migrar monolito para arquitetura em camadas | `architecture-and-design` | DDD, Clean Architecture e estrategia de migracao gradual |
| Separar modulo em package BPL independente | `architecture-modules` | Packages runtime/designtime, dependencias e carregamento |

---

## Familia J — Assembly

| Cenario | Skill recomendada | Por que |
| ------- | ----------------- | ------- |
| Nao sei como comecar com assembly no Delphi | `assembly-orchestrator` | Orquestradora: orienta pelo nivel de conhecimento e objetivo |
| Entender como funciona o modelo de memoria x86 | `assembly-x86-fundamentals` | Modos real/protegido, segmentos e endereçamento base |
| Saber o que cada registrador armazena | `assembly-registers` | EAX..R15, segmentos, flags — referencia completa |
| Encontrar instrucao correta para operacao bitwise | `assembly-instructions` | Conjunto completo: AND, OR, XOR, SHL, SHR e afins |
| Entender por que a pilha corrompeu o retorno | `assembly-stack-call` | Stack frame, ESP/EBP, prologue e epilogue de funcoes |
| Integrar funcao C com codigo Delphi via DLL | `assembly-calling-conventions` | cdecl vs stdcall vs register — evita corrupcao de pilha |
| Otimizar rotina critica com asm inline no Delphi | `assembly-delphi-inline` | Bloco asm...end, restricoes do compilador, boas praticas |
| Escrever funcao standalone em assembly puro | `assembly-delphi-functions` | Funcoes externas, linkagem e exports para Delphi |
| Vetorizar loop de soma de arrays com SSE/AVX | `assembly-simd-avx` | Registradores XMM/YMM e instrucoes SIMD para throughput |
| Calcular offset de campo de struct em assembly | `assembly-expressions` | Operadores de enderecamento, TYPE, SIZEOF, OFFSET |
| Ver codigo assembly gerado pelo compilador | `assembly-debugging` | CPU view do IDE, disassembly e breakpoint em instrucao |

---

## Familia K — Mobile

| Cenario | Skill recomendada | Por que |
| ------- | ----------------- | ------- |
| Nao sei por qual plataforma comecar o app mobile | `mobile-orchestrator` | Orquestradora: avalia plataforma-alvo e configura o ambiente |
| Configurar PAServer e certificado para iOS | `ios-setup` | Provisioning profile, entitlements e PAServer sao desta skill |
| Configurar Android SDK e rodar no device real | `android-setup` | ADB, NDK, permissoes de manifesto e debugger |
| Submeter app para App Store via TestFlight | `ios-publishing` | App Store Connect, ipa assinado e fluxo de revisao |
| Publicar AAB assinado na trilha de testes do Play | `android-publishing` | Google Play Console, keystore, trilha interna/aberta |

---

## Regra de prioridade

1. Tarefa de **dominio unico** → ir direto a skill especializada da familia.
2. Tarefa que **cruza familias** → iniciar pela `developer-delphi-master-orchestrator`.
3. **Duvida sobre qual skill usar** → consultar `arvore_decisao.md` nesta pasta.