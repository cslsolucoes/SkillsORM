# Blueprint Delphi/FPC

Estrutura reutilizável para novos projetos compatíveis Delphi + FPC.

## Estrutura
- `src/Main`: facades/APIs públicas.
- `src/Modulos`: implementação por domínio.
- `src/Commons`: utilitários e base compartilhada.
- `src/Views`: interface (quando aplicável), sem regra de negócio.
- `tests`: testes unitários/integração.
- `Documentation`: documentação canônica.
- `build`: scripts/cfg/opts de build.
- `.cursor`: regras, skills e planos locais.

## Regras mínimas
- Contratos por interface (`I*`) e implementações (`T*`).
- Factory `New` e estilo fluente quando aplicável.
- Compatibilidade Delphi+FPC obrigatória.
- Changelog obrigatório em artefatos de governança.

---

Changelog (este arquivo):
- 1.0.0 (30/03/2026): Criação do blueprint reutilizável do projeto.
