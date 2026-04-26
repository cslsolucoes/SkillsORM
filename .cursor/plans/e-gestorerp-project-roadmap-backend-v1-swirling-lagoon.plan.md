# Plano — Alinhar roadmap backend + Consolidar `Documentation/Roteiro/`

**Ficheiros alvo:**
1. [project-roadmap-backend_V1.0.1.md](e:\GestorERP\project-roadmap-backend_V1.0.1.md) — alinhar a M01 (estado real) e replicar modelo estrutural a M02–M26.
2. [Documentation/Roteiro/](e:\GestorERP\Documentation\Roteiro\) — consolidar 5 ficheiros em 1 único actualizado, arquivar os antigos em `Documentation/Backup/`.

**Data:** 17/04/2026

---

## Parte I — Roadmap backend (`project-roadmap-backend_V1.0.1.md`)

**Escopo:** M01 (estado real implementado) + replicação do mesmo modelo estrutural a todos os demais módulos M02–M26 e às secções globais que os emolduram (§1, §3, §5).

---

## Contexto

O roadmap backend foi escrito numa fase anterior em que o código alvo seguia Clean Architecture clássica em `app/backend-delphi/src/{Host,Presentation,Application,Domain,Infrastructure,CrossCutting,Contracts}/`. Desde então a estrutura real do projecto migrou:

- A raiz passou a ser [projects/](e:\GestorERP\projects\) (DPRs sem prefixo de módulo) + [projects/backend/MXX-Name/](e:\GestorERP\projects\backend\) (código de cada módulo).
- Cada módulo segue o padrão `Core/` (única saída pública, bootstrap + DI) + `Commons/` (interno: domínio, serviços de negócio, utilitários) + `Modulos/Services/` (interno: acesso a dados) + `Modulos/Controllers/{RDW,Horse}/` (HTTP).
- Naming Pascal segue [`.cursor/rules/backend-pascal-unit-naming_V1.3.0.mdc`](e:\GestorERP\.cursor\rules\backend-pascal-unit-naming_V1.3.0.mdc) com conceitos em inglês (`Security`, `Access`, `Reference`, `Customer`, `Company`, `Finance`, `Fiscal`, `Nfe`, `Document`, `Notification`, `Audit`, `Privacy` …) e prefixo `Commons.` para ficheiros em `Commons/`.
- Framework HTTP passou a ser **seleccionável em compile-time** via `-DUSE_HORSE` (padrão) ou `-DUSE_RESTDATAWARE` em [projects/dcc32.cfg](e:\GestorERP\projects\dcc32.cfg) §6 — não é mais decisão fixa por REST-DataWare.
- Apenas **M01** tem código real hoje em [projects/backend/M01-Seguranca_Acesso/](e:\GestorERP\projects\backend\M01-Seguranca_Acesso\); M02–M26 são **planos/checklists** que devem usar a mesma convenção actual para orientar o scaffold futuro.

O utilizador pediu: "ajustar para a realidade actual somente M01" e em seguida "replicar o entendimento de M01 para os demais M*". O plano integra ambas as solicitações: M01 reflecte o código real, M02–M26 reflectem o mesmo padrão estrutural aplicado ao seu domínio.

---

## Princípio de substituição (padrão aplicável a TODOS os módulos MXX)

### Mapa de conceitos (da rule `backend-pascal-unit-naming_V1.3.0`)

| Módulo | Pasta alvo | Conceito(s) em Pascal |
| --- | --- | --- |
| M01 | `projects/backend/M01-Seguranca_Acesso/` | `Security`, `Access` (composto) |
| M02 | `projects/backend/M02-Cadastros_Base/` | `Reference` |
| M03 | `projects/backend/M03-Clientes/` | `Customer` |
| M04 | `projects/backend/M04-Empresas/` | `Company` |
| M05 | `projects/backend/M05-Financeiro/` | `Finance` |
| M06 | `projects/backend/M06-Fiscal_NFe/` | `Fiscal`, `Nfe` (composto) |
| M07 | `projects/backend/M07-Documentos_Comunicacao/` | `Document`, `Notification` (composto) |
| M08 | `projects/backend/M08-LGPD_Auditoria/` | `Audit`, `Privacy` (composto) |
| M09 | `projects/backend/M09-Estoque_Produtos/` | `Inventory`, `Product` (composto — **proposta**: rule ainda não formaliza M09+; adicionar ao manifesto da rule em passo separado) |
| M10 | `projects/backend/M10-Ordens_Servico/` | `ServiceOrder` (**proposta**) |
| M11 | `projects/backend/M11-Orcamentos/` | `Quote` (**proposta**) |
| M12 | `projects/backend/M12-Veiculos/` | `Vehicle` (**proposta**) |
| M13 | `projects/backend/M13-Vendas/` | `Sale` (**proposta**) |
| M14 | `projects/backend/M14-Propostas/` | `Proposal` (**proposta**) |
| M15 | `projects/backend/M15-Comissoes/` | `Commission` (**proposta**) |
| M16 | `projects/backend/M16-Servicos_Apontamento/` | `ServiceExecution`, `Timesheet` (**proposta**) |
| M17 | `projects/backend/M17-Frota/` | `Fleet` (**proposta**) |
| M18 | `projects/backend/M18-Roteiros/` | `Route` (**proposta**) |
| M19 | `projects/backend/M19-Caixa/` | `Cash` (**proposta**) |
| M20 | `projects/backend/M20-Bancos/` | `Bank` (**proposta**) |
| M21 | `projects/backend/M21-Boletos_Remessa/` | `PaymentSlip` (**proposta**) |
| M22 | `projects/backend/M22-Compras_Fornecedores/` | `Purchase`, `Supplier` (**proposta**) |
| M23 | `projects/backend/M23-PDV/` | `Pos` (**proposta**) |
| M24 | `projects/backend/M24-<...>/` | a definir no roadmap real |
| M25 | `projects/backend/M25-<...>/` | a definir |
| M26 | `projects/backend/M26-<...>/` | a definir |

> **Nota:** Os conceitos marcados **(proposta)** são coerentes com o padrão da rule mas ainda não aparecem no seu mapa explícito (§1 linha 34). O plano **não altera a rule**; apenas aplica o padrão ao roadmap. Actualizar o mapa da rule é tarefa separada (área protegida `.cursor/rules/`).

### Mapa de pastas (Clean Architecture legado → estrutura actual)

| Clean Architecture (roadmap actual) | Estrutura actual por módulo (`projects/backend/MXX-Name/`) |
| --- | --- |
| `src/Host/Bootstrap.pas` + `src/Host/DIContainer.pas` | `Core/MainService.pas` + `Core/MainService.Interfaces.pas` (+ `Core/MainService.Connection.pas`) |
| `src/Domain/MXX/Entities/` | `Commons/Commons.<Concept>.Domain.Entities.pas` (tipos/records; sem `.Interfaces.pas` companion) |
| `src/Domain/MXX/Events/` | `Commons/Commons.<Concept>.Domain.Events.pas` |
| `src/Domain/MXX/Validators/` | `Commons/Commons.<Concept>.Domain.Validators.pas` (ou inline em `Commons.<Concept>.Service.*`) |
| `src/Contracts/Interfaces/MXX/I…Repository.pas` | **Par** `Modulos/Services/<Concept>.Services.<Feature>.Interfaces.pas` (companion de implementação) |
| `src/Contracts/Interfaces/MXX/I…Service.pas` (business) | `Commons/Commons.<Concept>.Service.<Feature>.Interfaces.pas` |
| `src/Contracts/DTOs/MXX/` | `Commons/Commons.<Concept>.Dtos.pas` (ou tipos em `Commons.Message.Response.pas`) |
| `src/Application/MXX/*UseCase.pas` | `Commons/Commons.<Concept>.Service.<Acao>.pas` (camada de domínio/negócio) **ou** inline no controller para use-cases triviais |
| `src/Infrastructure/Repositories/MXX/` | `Modulos/Services/<Concept>.Services.<Feature>.pas` (acesso a dados via `ProvidersORM` — `IQueryBuilder` + `ITable`) |
| `src/Infrastructure/Integrations/…` | `Commons/Commons.<Concept>.Integration.<Sistema>.pas` |
| `src/Presentation/Controllers/<Nome>Controller.pas` | `Modulos/Controllers/<Concept>.Controller.<Feature>.pas` + `.Interfaces.pas` companion (vivem em `Controllers/RDW/` e são partilhados; só `ServerMain` difere entre RDW e Horse) |
| `src/CrossCutting/Middleware.JWT.pas` | `Commons/Commons.Access.Auth.Jwt.pas` **(pertence a M01)** — outros módulos consomem via DI/RequestContext, não re-implementam |
| `src/CrossCutting/Middleware.OBAC.pas` | `Commons/Commons.Security.Service.Obac.pas` **(M01)** |
| `src/CrossCutting/Middleware.Audit.pas` | `Commons/Commons.Audit.pas` + `Commons.Audit.Writer.pas` + `Commons.Audit.Reader.pas` **(M08 Audit)** |
| `src/CrossCutting/Middleware.CORS.pas` / `ExceptionHandler` / `Logger.Bridge` / `Parameters.Bridge` | Responsabilidades do `Core/MainService.pas` + integração com `ProvidersORM` (Loggers) e `ParamentersORM` (Parameters); não são camada separada por módulo |
| `tests/MXX/` | `projects/backend/MXX-Name/tests/` (estrutura interna ao módulo) |
| `GestorERP.Backend.dpr` (raiz `app/backend-delphi/`) | `projects/<Concept>.Backend.dpr` (um DPR por módulo, sem prefixo MXX — ex.: `Seguranca.Backend.dpr`, `Cadastros.Backend.dpr`, `Clientes.Backend.dpr`, `Empresas.Backend.dpr`, `Financeiro.Backend.dpr`, `Fiscal.Backend.dpr` etc.) |
| `dcc32.cfg` / `dcc64.cfg` em `app/backend-delphi/` ou `build/` | `projects/dcc32.cfg` + `projects/dcc64.cfg` (partilhados entre módulos; search paths em §1.2; defines em §6) |
| Framework HTTP fixo (REST-DataWare) | **Seleccionável em compile-time** — `-DUSE_HORSE` (padrão) em `projects/dcc32.cfg §6` ou `-DUSE_RESTDATAWARE` (alternativa). Cada módulo tem `Modulos/Controllers/Horse/<Concept>.Controller.ServerMain.Horse.pas` + `Modulos/Controllers/RDW/<Concept>.Controller.ServerMain.pas` |

### Regra arquitectural reforçada (encapsulamento `Core/`)

- **Só `Core/` é publicamente consumível.** `Commons/` e `Modulos/` são privados do módulo.
- O `.dpr` do módulo referencia apenas units de `Core/`.
- Outros módulos consomem MXX **via HTTP REST** — nunca via units partilhadas em Pascal.
- `IIntegrationEventBus` continua válido para eventos inter-módulo; implementação vai em `Core/` ou `Commons/` do módulo que o origina.

---

## Secções a alterar no roadmap

### A. Secções globais (emolduram todos os módulos)

| # | Secção | Linhas | Natureza |
| --- | --- | --- | --- |
| A.1 | Cabeçalho — `Raiz:` | 11 | `app/backend-delphi/` → `projects/` + explicar estrutura por módulo |
| A.2 | "Frontend `app/web-vue` — Estado de integração M01" | 15–35 | Banner "⚠️ planeado — [projects/frontend/web/](e:\GestorERP\projects\frontend\web\) placeholder vazio"; manter tabela como contrato |
| A.3 | §0 "Estado da Collection" | 66–86 | Actualizar data; conferir contagem M01 (20 endpoints reais) |
| A.4 | §1 "Arquitectura de camadas" | 92–110 | Reescrever diagrama e tabela para `Core/ + Commons/ + Modulos/{Services,Controllers/{RDW,Horse}}` por módulo; explicitar encapsulamento `Core/` |
| A.5 | §1.1 "Regras arquiteturais obrigatórias" | 112–125 | Substituir "Domain nunca importa Infrastructure" por "Core é única fachada pública; Commons/Modulos são privados; comunicação inter-módulo é HTTP"; manter regra 7 sobre `ProvidersORM` (`IQueryBuilder`/`ITable`/`ExecuteQuery`) — essa continua válida |
| A.6 | §1.2 "Entry point do projecto Delphi" | 126–131 | `GestorERP.Backend.dpr` → 1 DPR por módulo em `projects/<Concept>.Backend.dpr`; `dcc32.cfg` / `dcc64.cfg` em `projects/` (partilhados); mencionar `-DUSE_HORSE` (padrão) vs `-DUSE_RESTDATAWARE` |
| A.7 | §2 "Contratos Core (Commons → Backend)" | 134–150 | Nome da secção sugere já o padrão actual; ajustar a coluna "Definida em"/"Implementada em" — `Contracts` deixa de existir como camada; substituir por `Commons/` ou `Modulos/Services/` consoante o caso |
| A.8 | §3 "Padrões de API REST" | 154–178 | "Framework: REST-DataWare" → "Framework: Horse (padrão `-DUSE_HORSE`) ou REST-DataWare (`-DUSE_RESTDATAWARE`), seleccionado em compile-time por módulo"; restante conteúdo (prefixo, auth, paginação, envelope) mantém |
| A.9 | §5 "Onda B0 — Bootstrap" entregáveis | 203–235 | Todos os ficheiros listados (`src/Host/…`, `src/CrossCutting/…`, `src/Contracts/…`) têm de apontar para as unidades equivalentes na estrutura actual; confirmar quais são **infraestrutura partilhada** (no projecto ProvidersORM / ParamentersORM / ActiveDirectoryORM) vs **por módulo** (em `Core/` / `Commons/`) |

### B. Secções por módulo — ordenadas por dependência técnica (execução)

Para cada módulo, aplicar as substituições da tabela "Mapa de pastas" aos caminhos do checklist. Conteúdo **funcional** (entidades, endpoints, RNs, deps, critérios de aceite) fica intacto — só paths e nomes de units mudam.

A coluna **`#`** dá a ordem topológica de execução (0 → 26): cada módulo só é editado depois dos seus pré-requisitos directos. Isto garante coerência nas referências cruzadas (ex.: M03 já menciona M04, então editar M04 antes de M03 evita voltar atrás).

| # | Módulo | Onda | Deps directas | Conceito(s) Pascal | DPR sugerido | §roadmap · Linhas |
| --- | --- | --- | --- | --- | --- | --- |
| 00 | **M01** Segurança e Acesso | B1 | — | `Security`, `Access` | `Seguranca.Backend.dpr` ✅ (existe) | §6.1 · 246–330 + §8 Admin 831–852 |
| 01 | **M02** Cadastros Base | B1 | M01 | `Reference` | `Cadastros.Backend.dpr` | §6.2 · 333–367 |
| 02 | **M08f** Auditoria (fundação) | B1 | M01 | `Audit` | `Auditoria.Backend.dpr` | §6.3 · 370–399 |
| 03 | **M04** Empresas | B2 | M01, M02 | `Company` | `Empresas.Backend.dpr` | §7.1 · 423–460 |
| 04 | **M03** Clientes | B2 | M01, M02, M04 | `Customer` | `Clientes.Backend.dpr` | §7.2 · 463–507 |
| 05 | **M05** Financeiro | B2 | M01, M02, M03, M04 | `Finance` | `Financeiro.Backend.dpr` | §7.3 · 511–563 |
| 06 | **M06** Fiscal e NF-e | B2 | M02, M04, M05 | `Fiscal`, `Nfe` (composto) | `Fiscal.Backend.dpr` | §7.4 · 567–617 |
| 07 | **M07** Documentos, Comunicação, Agenda, Chamados | B3 | M01, M02, M03 | `Document`, `Notification` (composto) | `Documentos.Backend.dpr` | §8.1 · 645–677 |
| 08 | **M09** Estoque e Produtos | B3 | M02, M04 | `Inventory`, `Product` (composto) | `Estoque.Backend.dpr` | §8.2 · 683–706 |
| 09 | **M12** Veículos | B3 | M03 | `Vehicle` | `Veiculos.Backend.dpr` | §8.6 · 775–784 |
| 10 | **M16** Execução de Serviços e Apontamento de Horas | B3 | M03, M04, M05 | `ServiceExecution`, `Timesheet` (composto) | `Servicos.Backend.dpr` | §8.3 · 712–736 |
| 11 | **M10** Ordens de Serviço | B3 | M02, M03, M04, M09 | `ServiceOrder` | `OrdensServico.Backend.dpr` | §8.4 · 742–757 |
| 12 | **M11** Orçamentos | B3 | M03, M09, M10 | `Quote` | `Orcamentos.Backend.dpr` | §8.5 · 762–772 |
| 13 | **M13** Vendas | B3 | M03, M04, M05, M09 | `Sale` | `Vendas.Backend.dpr` | §8.7 · 788–798 |
| 14 | **M14** Propostas | B3 | M03, M13 | `Proposal` | `Propostas.Backend.dpr` | §8.8 · 802–812 |
| 15 | **M15** Comissões | B3 | M01, M13 | `Commission` | `Comissoes.Backend.dpr` | §8.9 · 816–826 |
| 16 | **M17** Frota | B4 | M03, M12 | `Fleet` | `Frota.Backend.dpr` | §9.1 · 874–884 |
| 17 | **M18** Roteiros | B4 | M03, M17 | `Route` | `Roteiros.Backend.dpr` | §9.2 · 887–897 |
| 18 | **M19** Caixa | B4 | M01, M05 | `Cash` | `Caixa.Backend.dpr` | §9.3 · 900–911 |
| 19 | **M20** Bancos | B4 | M02, M05 | `Bank` | `Bancos.Backend.dpr` | §9.4 · 915–927 |
| 20 | **M21** Boletos e Remessa | B4 | M05, M20 | `PaymentSlip` | `Boletos.Backend.dpr` | §9.5 · 930–941 |
| 21 | **M08h** LGPD Hardening | B5 | M01, M03 | `Privacy` | `Lgpd.Backend.dpr` | §10.1 · 965–975 |
| 22 | **M24** RH e Funcionários | B5 | M01, M02 | `Hr` | `RH.Backend.dpr` | §10.4 · 1010–1020 |
| 23 | **M22** Compras e Fornecedores | B5 | M02, M05, M09 | `Purchase`, `Supplier` (composto) | `Compras.Backend.dpr` | §10.2 · 978–990 |
| 24 | **M25** Mala Direta e Marketing | B5 | M03, M07 | `Marketing` | `Marketing.Backend.dpr` | §10.5 · 1024–1034 |
| 25 | **M26** Aluguéis e Locação | B5 | M03, M05, M09 | `Rental` | `Locacao.Backend.dpr` | §10.6 · 1038–1049 |
| 26 | **M23** PDV | B5 | M06, M09, M19 | `Pos` | `PDV.Backend.dpr` | §10.3 · 992–1006 |

**Notas de ordenação:**

- Dentro da mesma onda, a ordem respeita dependências intra-onda (ex.: B2 executa M04 antes de M03 antes de M05 antes de M06; B3 executa M09 e M12 antes de M10/M11/M13 que dependem deles).
- **M23 (PDV)** fica por último dentro da B5 pelo risco regulatório (requer validação PAF-ECF antes da implementação) e por ter a maior cadeia de dependências (M06 + M09 + M19).
- **M01** ordinal `00` e as suas Admin 20-endpoints já estão implementadas — a "edição" nesse caso é apenas ajustar paths do roadmap à realidade, não executar scaffold.
- Para **M02–M26** a edição é prospectiva: ajustar checklists de forma que, quando o scaffold for executado, já aponte para os caminhos correctos.

**Conceitos novos adoptados** (fora do mapa explícito da rule V1.3.0, conforme decisão 1 do utilizador): `Inventory`, `Product`, `Vehicle`, `ServiceExecution`, `Timesheet`, `ServiceOrder`, `Quote`, `Sale`, `Proposal`, `Commission`, `Fleet`, `Route`, `Cash`, `Bank`, `PaymentSlip`, `Privacy`, `Hr`, `Purchase`, `Supplier`, `Marketing`, `Rental`, `Pos`. Propagação para a rule V1.4.0 fica como tarefa separada (área protegida `.cursor/rules/`).

### C. Critérios de aceite por onda (B0–B5)

Cada "Critérios de aceite Onda Bx" tem itens que citam paths legados (ex.: "conformidade arquitectural `Application`/`Presentation`/`CrossCutting`/`Host` sem SQL directo"). Substituir esses itens para:

> "Conformidade arquitectural validada: `Core/` é a única fachada pública, `Commons/` concentra utilitários/domínio/serviços, `Modulos/Services/*` é a única camada com acesso a banco (ProvidersORM — `IQueryBuilder`/`ITable`), `Modulos/Controllers/*` não contém SQL directo; `ExecuteQuery` (raw SQL) restrito a excepções documentadas."

Aplicar em:
- §5 Critérios de aceite Onda B0 (linha 229)
- §6 Critérios de aceite Onda B1 (linha 401, 410)
- §7 Critérios de aceite Onda B2 (linha 619+)
- §8 Critérios de aceite Onda B3 (linha 829 em diante — também corrigir tabela M01 Admin com rotas portuguesas)
- §9 Critérios de aceite Onda B4
- §10 Critérios de aceite Onda B5

### D. Secções NÃO tocadas

- §0 linhas 39–65 (workflow Postman) — mecanismo funcional, não paths de código.
- Tabelas de **entidades** e **endpoints** funcionais de cada módulo — conteúdo de negócio, não path de implementação.
- Tabelas de **domain events** — conceitos, não paths.
- §4 "Visão geral Ondas" — tabela de progresso funcional.
- ADRs citados — nomes dos ADRs permanecem; só actualizar se tiver versão nova (ex.: M01 já detectado `V1_0_2`).
- Links para `Documentation/RegrasNegocio/RN-*` — preservar; só actualizar versões se necessário (M01 já detectado `V1_1_0`).

---

## Anexo 1 — Detalhe M01 (baseado em código real existente)

### A1.1 Metadados M01 (§6.1 linhas 249–254)

Trocar ADR/RNs/DDL para versões actuais confirmadas por `ls`:
- ADR: `GestorERP_ADR_OBAC_V1_0_2.md` + `GestorERP_ADR_JWT_Lifecycle_V1_0_0.md`.
- RNs: `GestorERP_RN-M01-001_M01_V1_1_0.md`, `GestorERP_RN-M01-002_OBAC_V1_1_0.md`, `GestorERP_RN-M01-003_Machines_V1_0_0.md`.
- DDL: SQL Server **+ PostgreSQL** (ambos em [Documentation/BancoDados/](e:\GestorERP\Documentation\BancoDados\)).

### A1.2 Checklist M01 (§6.1 linhas 306–330)

Substituições item-a-item confirmadas por `ls` em [projects/backend/M01-Seguranca_Acesso/](e:\GestorERP\projects\backend\M01-Seguranca_Acesso\):

| De (roadmap) | Para (realidade) |
| --- | --- |
| `src/Domain/Seguranca/Entities/` | `Commons/Commons.Security.Domain.Entities.pas` + `Commons.Security.Domain.Types.pas` |
| `src/Domain/Seguranca/Events/` | `Commons/Commons.Security.Domain.Events.pas` (fase B5) |
| `src/Contracts/Interfaces/Seguranca/` | Pares `Security.Services.*.Interfaces.pas` em `Modulos/Services/` + `Commons.Access.Integration.Ldap.pas` |
| `src/Application/Seguranca/AuthActions.pas` | `Modulos/Services/Security.Services.User.pas` + `Commons/Commons.Security.Service.Auth.pas` |
| `src/Application/Seguranca/OBACService.pas` | `Commons/Commons.Security.Service.Obac.pas` |
| `src/Application/Seguranca/SegurancaAdminActions.pas` | Distribuído em `Security.Services.{User,Group,Machine,OU,Policy}` |
| `src/Infrastructure/Repositories/Seguranca/Segurança*Repository.pas` | Sem camada Repositories separada — queries via `ProvidersORM` dentro de `Security.Services.*.pas` |
| `src/Presentation/Controllers/AuthController.pas` | `Modulos/Controllers/Access.Controller.Auth.pas` + `.Interfaces.pas` |
| `src/Presentation/Controllers/UsuariosController.pas` | `Modulos/Controllers/Access.Controller.Users.pas` + `.Interfaces.pas` |
| `src/Presentation/Controllers/UnidadesOrgController.pas` | `Modulos/Controllers/Access.Controller.OU.pas` + `.Interfaces.pas` |
| `src/Presentation/Controllers/GruposController.pas` | `Modulos/Controllers/Access.Controller.Groups.pas` + `.Interfaces.pas` |
| `src/Presentation/Controllers/MaquinasController.pas` | `Modulos/Controllers/Access.Controller.Machines.pas` + `.Interfaces.pas` |
| `src/Presentation/Controllers/PoliticasController.pas` | `Modulos/Controllers/Access.Controller.Policies.pas` + `.Interfaces.pas` |
| (faltava) | `Modulos/Controllers/Access.Controller.AD.pas` + `.Interfaces.pas` |
| (faltava) | `Modulos/Controllers/Access.Controller.AuditLog.pas` + `.Interfaces.pas` |
| (faltava) | `Modulos/Controllers/RDW/Access.Controller.ServerMain.pas` **e** `Modulos/Controllers/Horse/Access.Controller.ServerMain.Horse.pas` |
| `src/CrossCutting/Middleware.JWT.pas` | `Commons/Commons.Access.Auth.Jwt.pas` |
| `src/CrossCutting/Middleware.OBAC.pas` | `Commons/Commons.Security.Service.Obac.pas` |
| `src/Infrastructure/Integrations/ActiveDirectory/` | `Commons/Commons.Access.Integration.Ldap.pas` + módulo externo [projects/modules/ActiveDirectoryORM/](e:\GestorERP\projects\modules\ActiveDirectoryORM\) |

Entradas novas para adicionar ao checklist (existem e não estavam documentadas):
- [X] `Modulos/Views/ufrm.Seguranca.Server.pas` — form host VCL (referenciado por [Seguranca.Backend.dpr](e:\GestorERP\projects\Seguranca.Backend.dpr)).
- [X] `Core/MainService.pas` + `Core/MainService.Interfaces.pas` + `Core/MainService.Connection.{pas,Interfaces.pas}` — DI + bootstrap + selecção Horse/RDW apenas na cláusula `uses`.
- [X] `config/database.ini` e `config/parameters.db`.
- [X] `projects/dcc32.cfg` e `projects/dcc64.cfg` — `-DUSE_HORSE` activo §6, search paths para 3 ORMs §1.2.
- [X] Dependência ActiveDirectoryORM (LDAP real).

### A1.3 Tabela M01 Admin em §8 (linhas 831–852)

Os caminhos curtos (`/ou`, `/users`, `/groups`, `/machines`, `/policies`, `/ad/sync`, `/auth/me/permissions/:modulo`) são incoerentes com §6.1 e com a Postman collection (rotas portuguesas reais). Reescrever:
- `/ou` → `/unidades-organizacionais`
- `/users` → `/usuarios`
- `/users/:id/move-ou` → `/usuarios/:id/mover-unidade`
- `/groups` → `/grupos`
- `/groups/:id/members` → `/grupos/:id/membros`
- `/machines` → `/maquinas`
- `/policies` → `/politicas`
- `/ad/sync` → `/admin/sincronizar-ad`
- `/auth/me/permissions/:modulo` → `/auth/me/permissoes/:modulo`

Total sobe de "18" para **20** (alinhando com §6.1 e com o código real em `Modulos/Controllers/`).

---

## Estratégia de execução

Todas as mudanças são **substituições locais** delimitadas por cabeçalhos de secção. Nenhuma `replace_all` global — cada `Edit` é cirúrgico num bloco delimitado para evitar contaminar secções não pretendidas. A ordem segue o índice topológico da tabela B (dependência técnica), com as secções globais a abrir e os critérios/frontend a fechar:

| Passo | Acção |
| --- | --- |
| P1 | Secções globais **A.1 → A.9** (cabeçalho, §1 arquitectura, §1.1 regras, §1.2 entry point, §2 contratos, §3 padrões REST, §5 Onda B0). |
| P2 | Módulos pela **ordem 00 → 26** da tabela B (M01 → M02 → M08f → M04 → M03 → M05 → M06 → M07 → M09 → M12 → M16 → M10 → M11 → M13 → M14 → M15 → M17 → M18 → M19 → M20 → M21 → M08h → M24 → M22 → M25 → M26 → M23). M01 usa o detalhe do **Anexo 1**. |
| P3 | **Critérios de aceite** de cada onda (B0 → B5) — ajustes do ponto C. |
| P4 | **Nova §11** "Roadmap de Frontend Vue (planeado)" e remoção do bloco original das linhas 15–35, substituído por ponteiro curto em §0. |
| P5 | **Datas** — aplicar carimbo "Revisto 17/04/2026 — alinhamento estrutural" em cada ocorrência tocada (decisão 4). |
| P6 | Leitura final top-down + grep positivos/negativos (verificação). |

---

## Ficheiros críticos envolvidos

**A modificar:**
- [project-roadmap-backend_V1.0.1.md](e:\GestorERP\project-roadmap-backend_V1.0.1.md) — único ficheiro editado pelo plano.

**Consultados (read-only) — autoridade canónica:**
- [CLAUDE.md](e:\GestorERP\CLAUDE.md) — estrutura actual do workspace.
- [.cursor/rules/backend-pascal-unit-naming_V1.3.0.mdc](e:\GestorERP\.cursor\rules\backend-pascal-unit-naming_V1.3.0.mdc) — convenções de naming (alwaysApply=true).
- [projects/Seguranca.Backend.dpr](e:\GestorERP\projects\Seguranca.Backend.dpr) — entry point M01 real.
- [projects/dcc32.cfg](e:\GestorERP\projects\dcc32.cfg) — search paths + defines actuais.
- [projects/backend/M01-Seguranca_Acesso/](e:\GestorERP\projects\backend\M01-Seguranca_Acesso\) — único módulo com código real; padrão a replicar no roadmap para M02–M26.
- [Documentation/RegrasNegocio/RN-M01 - Segurança e Acesso/](e:\GestorERP\Documentation\RegrasNegocio\) — RNs canónicos M01.
- [.cursor/skills/developer-delphi-modular-backend-scaffold_V1.0.0/](e:\GestorERP\.cursor\skills\developer-delphi-modular-backend-scaffold_V1.0.0\) — skill de scaffold de módulos (fonte do padrão replicado).

---

## Verificação (pós-edição)

1. **Grep negativos** — no ficheiro final **não deve existir nenhuma ocorrência** de:
   - `app/backend-delphi/` (excepto dentro do banner de aviso do §15–35)
   - `src/Host/`, `src/Presentation/`, `src/Application/`, `src/Domain/`, `src/Infrastructure/`, `src/CrossCutting/`, `src/Contracts/` (em qualquer checklist de qualquer MXX)
   - `Framework.*REST-DataWare` como decisão fixa (deve sempre co-citar Horse via define)
   - `GestorERP.Backend.dpr` (substituído por DPRs nominais por módulo)
2. **Grep positivos** — devem aparecer:
   - `projects/backend/MXX-` (para todos os módulos referenciados)
   - `Core/MainService` (secção B0 e §2)
   - `Modulos/Services/`, `Modulos/Controllers/RDW/`, `Modulos/Controllers/Horse/`
   - `-DUSE_HORSE` e `-DUSE_RESTDATAWARE` (em §1.2 e §3)
3. **Coerência interna M01** — endpoints em §6.1 = endpoints em §8 tabela Admin (total 20, mesmas grafias portuguesas).
4. **Preservação** — diff antes/depois mostra apenas alterações nas secções listadas em A+B+C; entidades/endpoints/RNs funcionais inalterados.
5. **Encadeamento de links** — todos os links `Documentation/…/RN-MXX-….md` resolvem (checagem com Glob/ls no directório alvo).
6. **Consistência com skills/rules canónicas** — nenhum texto entra em conflito com `.cursor/rules/backend-pascal-unit-naming_V1.3.0.mdc` (naming) ou `.cursor/skills/developer-delphi-modular-backend-scaffold_V1.0.0/` (scaffold).

---

## Decisões confirmadas (17/04/2026)

1. **Conceitos M09–M26**: ✅ **Adoptar propostas** (`Inventory`, `Product`, `ServiceOrder`, `Quote`, `Vehicle`, `Sale`, `Proposal`, `Commission`, `ServiceExecution`, `Timesheet`, `Fleet`, `Route`, `Cash`, `Bank`, `PaymentSlip`, `Purchase`, `Supplier`, `Pos`, `Privacy`) directamente no roadmap. Propagar à rule `backend-pascal-unit-naming` V1.4.0 fica como tarefa separada (área protegida — plano próprio).
2. **Nomes de DPR por módulo**: ✅ **Incluir sugestões** nominais em cada §MXX — `Cadastros.Backend.dpr`, `Clientes.Backend.dpr`, `Empresas.Backend.dpr`, `Financeiro.Backend.dpr`, `Fiscal.Backend.dpr`, `Documentos.Backend.dpr`, `Auditoria.Backend.dpr`, `Estoque.Backend.dpr`, `OrdensServico.Backend.dpr`, `Orcamentos.Backend.dpr`, `Veiculos.Backend.dpr`, `Vendas.Backend.dpr`, `Propostas.Backend.dpr`, `Comissoes.Backend.dpr`, `Servicos.Backend.dpr`, `Frota.Backend.dpr`, `Roteiros.Backend.dpr`, `Caixa.Backend.dpr`, `Bancos.Backend.dpr`, `Boletos.Backend.dpr`, `Lgpd.Backend.dpr`, `Compras.Backend.dpr`, `PDV.Backend.dpr`.
3. **Bloco "Estado de integração M01" (frontend Vue, linhas 15–35)**: ✅ **Mover para nova secção "Roadmap de Frontend" no final do roadmap**. Remover de §0 e recriar como **§11 — Roadmap de Frontend Vue (planeado)** depois de §10 (Onda B5). Adicionar banner "⚠️ [projects/frontend/web/](e:\GestorERP\projects\frontend\web\) é placeholder vazio — contrato a cumprir quando o frontend for iniciado."
4. **Datas revistas**: ✅ **Adicionar carimbo** "Revisto 17/04/2026 — alinhamento estrutural" junto a cada "07/04/2026" / "02/04/2026" / "03/04/2026" / "01/04/2026" afectado. Preservar data original.

### Ajustes ao plano derivados destas decisões

- **A.2 (linhas 15–35) reconfigura** de "banner + manter" para "remover daqui + criar §11". A referência ao bloco original é preservada por um ponteiro curto em §0 indicando "Integração frontend: ver §11".
- **Nova secção §11** incluída na lista de alterações: título "Roadmap de Frontend Vue (planeado)", conteúdo = tabela original + banner + endpoints preservados como contrato. Posicionada após §10.
- **Datas** aplicadas em massa nas secções tocadas (§0 linha 66, §6.1 linhas 10 e 27 e 32, §8 linhas 831+, §11 ao migrar). Sempre "07/04/2026 — Revisto 17/04/2026 — alinhamento estrutural" (ou data equivalente).
- **Conceitos M09–M26** e **DPRs** aplicados literalmente nos pontos B do mapa ("Secções por módulo").

---

## Parte II — Consolidação de `Documentation/Roteiro/`

**Área protegida** ([CLAUDE.md](e:\GestorERP\CLAUDE.md) lista `Documentation/` como "área protegida — plan mode obrigatório"). Esta parte cumpre o requisito: plano completo, inventário, antes/depois, backup.

### II.1 Resumo da operação

Consolidar os 5 ficheiros actuais de [Documentation/Roteiro/](e:\GestorERP\Documentation\Roteiro\) num **único ficheiro actualizado**, arquivando os antigos em `Documentation/Backup/Roteiro_V2_pre_consolidacao_17_04_2026/` (conforme política [`governance-artifact-inventory`](e:\GestorERP\.cursor\skills\governance-artifact-inventory_V1.0.0\) / skill `documentation-migration-backup`).

### II.2 Inventário de ficheiros afectados

| # | Ficheiro actual | Linhas | Versão | Papel | Destino |
| --- | --- | --- | --- | --- | --- |
| 1 | `GestorERP_ROADMAP_Index_V1_0_0.md` | 37 | 1.0.0 | Índice único (ponto de entrada) | Fundido → §1 Visão geral do consolidado |
| 2 | `GestorERP_Roteiro_PROJETO_V1_0_2.md` | 44 | 1.0.2 | Roteiro de refactoring (4 fases) | Fundido → §2 Fases de refactoring |
| 3 | `GestorERP_Commons_Roteiro_V1_5_1.md` | 75 | 1.5.1 | Roteiro de evolução do Commons | Fundido → §3 Evolução técnica (Commons/ORM) |
| 4 | `GestorERP_Pacote_Execucao_Tecnica_Ondas_V1_0_0.md` | 40 | 1.0.0 | Pacote técnico por ondas (ORM) | Fundido → §4 Pacote técnico de ondas |
| 5 | `GestorERP_Caderno_Execucao_Ondas_V2_0_0.md` | 338 | 2.0.0 | Diário histórico de decisões por onda | Fundido → §5 Caderno de execução (histórico preservado) |

Total: **534 linhas** em 5 ficheiros → **1 ficheiro consolidado** (meta: ~500–600 linhas após desduplicação).

### II.3 Ficheiro de destino

**Nome proposto:** `GestorERP_Roadmap_project_V3_0_0.md`
**Caminho:** [Documentation/Roteiro/GestorERP_Roadmap_project_V3_0_0.md](e:\GestorERP\Documentation\Roteiro\GestorERP_Roadmap_project_V3_0_0.md)

**Justificação do nome**:

- Prefixo `GestorERP_` segue o padrão de todos os artefactos em `Documentation/`.
- `Roadmap_project` consolida os papéis de índice (`ROADMAP_Index`), roteiro de projecto (`Roteiro_PROJETO`), roteiro Commons (`Commons_Roteiro`), pacote técnico (`Pacote_Execucao_Tecnica`) e caderno histórico (`Caderno_Execucao`) num único artefacto "roadmap do projecto".
- `V3_0_0` é o bump MAJOR (3.0.0) — maior que 2.0.0 (Caderno) + 1.5.1 (Commons Roteiro), sinaliza fusão estrutural.

### II.4 Estrutura do ficheiro consolidado

```markdown
# GestorERP — Roteiro Consolidado de Execução

| Campo | Valor |
|---|---|
| Versão | 3.0.0 |
| Data | 17/04/2026 |
| Status | Publicado |
| Substitui | ROADMAP_Index V1.0.0 · Roteiro_PROJETO V1.0.2 · Commons_Roteiro V1.5.1 · Pacote_Execucao_Tecnica V1.0.0 · Caderno_Execucao V2.0.0 |
| Arquivados em | Documentation/Backup/Roteiro_V2_pre_consolidacao_17_04_2026/ |

## 1. Visão geral e ponto de entrada
- Leitura recomendada (ordem actualizada)
- Mapa rápido Onda × artefacto (actualizado com realidade actual: M01 completo, B3 em andamento)
- Links canónicos para documentos externos (Planejamento/, Arquitetura/, Mapeamento/, Contratos/)

## 2. Fases de refactoring (visão macro)
- Fase 1 — Consolidação Commons (✅ completo — ProvidersORM/ParamentersORM/ActiveDirectoryORM)
- Fase 2 — Integração dos Models (em curso via M01–M26; M01 ✅ completo)
- Fase 3 — Dados e rastreabilidade (ETL HabilFinanceiro em Onda B5)
- Fase 4 — Operação e governança (Go-Live hardening B5)

## 3. Evolução técnica Commons / ORM (BL-011..BL-014)
- Onda 0: Preparação — stack confirmada (USE_FIREDAC padrão; flags condicionais USE_*)
- Onda 1: Fundação Commons — IConnection/FromConfig, Loggers, Exceptions (✅ ProvidersORM)
- Onda 2: Núcleo comum — IField/ITable/TTables, parâmetros (✅ ParamentersORM)
- Onda 3: Transacional — UnitOfWork, M05/M06 (🔄 Onda B2 do backend)
- Checklist de pronto por sprint (preservado)

## 4. Pacote técnico por ondas (0–5 ORM) + mapeamento para ondas backend (B0–B5)
- Tabela unificada: Onda ORM ↔ Onda Backend ↔ BL ↔ Módulos
- Skill do workspace: .cursor/skills/gestorerp-orm-consolidacao-ondas/ (referência)
- Critérios de aceite agregados

## 5. Caderno de execução (histórico + actuais)
- Registros 001–007 (preservados do V2.0.0)
- Registro 008 (novo — 17/04/2026): alinhamento estrutural roadmap + consolidação Roteiro
- Política: próximos registos continuam aqui, 1 por semana ou por evento relevante

## 6. Referências cruzadas
- Links canónicos para: Planejamento/, Arquitetura/, Mapeamento/, Contratos/, RegrasNegocio/
- project-roadmap-backend_V1.0.1.md (roadmap backend actualizado)
- CLAUDE.md (instruções do workspace)
- .cursor/rules/backend-pascal-unit-naming_V1.3.0.mdc (naming)

## 7. Changelog consolidado
- 3.0.0 (17/04/2026): fusão dos 5 ficheiros; preservação íntegra do Caderno (registros 001–007 + novo 008); actualização de paths para estrutura actual (projects/backend/, Core/Commons/Modulos); alinhamento com project-roadmap-backend V1.0.1
- Histórico dos 5 ficheiros preservado (ver Apêndice A)

## Apêndice A — Changelog histórico dos ficheiros consolidados
- ROADMAP_Index V1.0.0 (30/03/2026)
- Roteiro_PROJETO V1.0.2 (27/03/2026) / 1.0.1 / 1.0.0
- Commons_Roteiro V1.5.1 / 1.5.0 / 1.4.0 / 1.3.1 / 1.3.0 / 1.2.0 / 1.1.0
- Pacote_Execucao_Tecnica V1.0.0 (26/03/2026)
- Caderno_Execucao V2.0.0 (05/04/2026) — registros 001–007 preservados
```

### II.5 Operação antes / depois

**Antes** (5 ficheiros):

```
Documentation/Roteiro/
├── GestorERP_Caderno_Execucao_Ondas_V2_0_0.md       (338 linhas)
├── GestorERP_Commons_Roteiro_V1_5_1.md              (75 linhas)
├── GestorERP_Pacote_Execucao_Tecnica_Ondas_V1_0_0.md (40 linhas)
├── GestorERP_ROADMAP_Index_V1_0_0.md                (37 linhas)
└── GestorERP_Roteiro_PROJETO_V1_0_2.md              (44 linhas)
```

**Depois** (1 ficheiro + backup):

```
Documentation/Roteiro/
└── GestorERP_Roadmap_project_V3_0_0.md          (~500–600 linhas)

Documentation/Backup/Roteiro_V2_pre_consolidacao_17_04_2026/
├── GestorERP_Caderno_Execucao_Ondas_V2_0_0.md       (movido)
├── GestorERP_Commons_Roteiro_V1_5_1.md              (movido)
├── GestorERP_Pacote_Execucao_Tecnica_Ondas_V1_0_0.md (movido)
├── GestorERP_ROADMAP_Index_V1_0_0.md                (movido)
└── GestorERP_Roteiro_PROJETO_V1_0_2.md              (movido)
```

### II.6 Actualizações de conteúdo durante a fusão

Não é transcrição literal. Pontos que mudam ao consolidar:

1. **Stack confirmada**: `USE_ZEOS` → `USE_FIREDAC` (padrão real confirmado em [projects/dcc32.cfg](e:\GestorERP\projects\dcc32.cfg)).
2. **Paths de código**: actualizar toda referência a estrutura Clean Architecture legada para `projects/backend/MXX-Name/{Core,Commons,Modulos}/`.
3. **Módulos externos**: incluir [projects/modules/ActiveDirectoryORM/](e:\GestorERP\projects\modules\ActiveDirectoryORM\) além de ProvidersORM/ParamentersORM.
4. **Estado actual por onda**: B0 ✅ / B1 ✅ / B2 ✅ / B3 🔄 (M01 Admin ✅; M07, M09, M10–M16 pendentes) / B4 ⬜ / B5 ⬜ — alinhado com a tabela mestra do [project-roadmap-backend_V1.0.1.md](e:\GestorERP\project-roadmap-backend_V1.0.1.md) §4.
5. **Registos do Caderno**: preservar 001–007 íntegros (valor histórico); acrescentar Registro 008 (17/04/2026) a documentar a própria consolidação + o alinhamento do roadmap.
6. **Hiperligações**: corrigir paths quebrados/desactualizados (ex.: `Analise/Docs/…` → `Documentation/…`) detectados ao consolidar.

### II.7 Dependências e riscos

| Item | Risco | Mitigação |
| --- | --- | --- |
| Ficheiros referenciados externamente | `Documentation/README.md` ou outros podem ter links para os 5 antigos | Antes de eliminar: `Grep -r` em `Documentation/` e `.cursor/` para detectar e actualizar referências ao novo ficheiro |
| Backup pré-existente | Pasta `Documentation/Backup/` já existe (per skill `documentation-migration-backup`) | Criar subpasta datada `Roteiro_V2_pre_consolidacao_17_04_2026/` para isolar este lote |
| Hub README | [Documentation/README.md](e:\GestorERP\Documentation\README.md) pode listar os 5 ficheiros | Actualizar índice para apontar só ao consolidado |
| Conteúdo perdido | Fusão mal feita apaga Registos do Caderno | Apêndice A reproduz changelogs completos; Registos 001–007 do Caderno preservados na §5 byte-a-byte (ou em anexo se ficar extenso) |
| Política de eliminação | CLAUDE.md exige plan mode — **cumprido aqui** | — |
| Skill de backup | Respeitar `documentation-migration-backup` e `documentation-constitution-policies` (superseded-definition) | Aplicar nomenclatura e índice de Backup conforme as skills |

### II.8 Passos de execução (Parte II)

| Passo | Acção |
| --- | --- |
| P1 | `Grep` em `Documentation/` e `.cursor/` para mapear referências externas aos 5 ficheiros |
| P2 | Criar `Documentation/Backup/Roteiro_V2_pre_consolidacao_17_04_2026/` e **copiar** (não mover ainda) os 5 ficheiros |
| P3 | `Write` do [Documentation/Roteiro/GestorERP_Roadmap_project_V3_0_0.md](e:\GestorERP\Documentation\Roteiro\GestorERP_Roadmap_project_V3_0_0.md) |
| P4 | Actualizar referências externas encontradas em P1 (substituir 5 nomes antigos pelo consolidado) |
| P5 | Actualizar [Documentation/README.md](e:\GestorERP\Documentation\README.md) (hub) se listar a pasta Roteiro/ |
| P6 | Eliminar os 5 ficheiros originais de `Documentation/Roteiro/` (as cópias estão em Backup) |
| P7 | Registrar o evento no Registro 008 do §5 do consolidado (auto-documentação da operação) |
| P8 | Verificação: ler o consolidado top-down, conferir que nenhuma informação útil foi perdida |

### II.9 Verificação (pós-execução)

1. `ls "e:/GestorERP/Documentation/Roteiro/"` → **apenas** `GestorERP_Roadmap_project_V3_0_0.md`.
2. `ls "e:/GestorERP/Documentation/Backup/Roteiro_V2_pre_consolidacao_17_04_2026/"` → 5 ficheiros originais intactos.
3. `Grep "GestorERP_ROADMAP_Index_V1_0_0"` → nenhum hit em `Documentation/` (excepto o próprio Backup).
4. `Grep "GestorERP_Caderno_Execucao_Ondas_V2_0_0"` → idem.
5. `Grep "GestorERP_Commons_Roteiro_V1_5_1"` → idem.
6. `Grep "GestorERP_Pacote_Execucao_Tecnica_Ondas_V1_0_0"` → idem.
7. `Grep "GestorERP_Roteiro_PROJETO_V1_0_2"` → idem.
8. `Grep "GestorERP_Roteiro_Consolidado_V3_0_0"` → aparece em hub `README.md` e onde havia refs aos antigos.
9. Registro 008 do caderno descreve a operação.
10. Todas as informações-chave (stack, ondas, BL, fases, changelogs) foram **preservadas** no consolidado — validação manual top-down.

---

## Ordem combinada de execução (Parte I + Parte II)

Executar **Parte I (roadmap)** antes de **Parte II (Roteiro)**: a Parte I define o estado alvo da arquitectura (Core/Commons/Modulos, Horse/RDW, conceitos Inglês); a Parte II consome esse estado para alimentar a §3 e §4 do consolidado.

| Fase | Alvo | Gate |
| --- | --- | --- |
| Fase A | Parte I — Roadmap backend (passos P1–P6 da estratégia Parte I) | Diff limpo; grep verde |
| Fase B | Parte II — Consolidação Roteiro (passos P1–P8 acima) | `ls` verde; registo 008 escrito |
| Fase C | Actualização cruzada — se Parte I citar Roteiro, usar o novo nome consolidado | Links coerentes |
