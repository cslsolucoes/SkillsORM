padrão · RN-M01-001 — Autenticação via LDAPS/AD | v1.3 · Atualizado: Hierarquia de Acesso (M01-013)
Página 1 de 3
⚠ DOCUMENTO ATUALIZADO — v1.3 · Março 2026 · Impacto: Hierarquia Computador→Setor→Grupos→Usuários (RN-M01-013)
padrão · Regra de Negócio
Escritório de Contabilidade · Brasília-DF

**ID da Regra**  
RN-M01-001

**Módulo**  
M01 — Autenticação e Segurança  
**Fase**: Fase 1 (MVP)  
**Prioridade**: Alta  
**Status**: ✅ Documentada

**Título**  
Autenticação via LDAPS/AD

**Ref. Arquitetura**  
Cap. 2 §Auth; Cap. 16 §LDAPS

## PRÉ-CONDIÇÕES — O que deve ser verdadeiro antes desta regra ser aplicada

1. Servidor Active Directory Windows Server 2025 acessível na porta 636 (LDAPS).
2. Certificado TLS do AD importado no truststore da API Central.
3. Service account de leitura LDAP configurado no `config.db` (`padrão.Parameters`).
4. Tabelas `public.users` e `public.user_roles` existem no PostgreSQL.
5. Plugin FMX: `Form.Login.fmx` compilado para a plataforma alvo (Windows/macOS/Linux).
6. **[v1.3]** Tabelas `public.computadores`, `public.setores` e `public.usuario_setor` existem e estão populadas (RN-M01-013 / migration 004).
7. **[v1.3]** Computador do usuário registrado em `public.computadores` com `setor_id` correto.

## FLUXO PRINCIPAL — Sequência feliz (passo a passo quando tudo funciona)

1. Usuário informa login (`username`) e senha na tela `Form.Login.fmx` do Plugin.
2. Plugin envia `POST /v1/auth/login { username, password, hostname }` com `Content-Type: application/json`.
   → **[v1.3]** campo `hostname` é obrigatório; obtido via `TIdStack.LocalHostName` (cross-platform).
3. **[v1.3]** API verifica vínculo computador↔setor (RN-M01-013):
   a. Consulta `public.computadores WHERE hostname = :h AND ativo = TRUE`.
   b. Consulta `public.usuario_setor WHERE user_id` corresponde ao username.
   c. Se setores incompatíveis → `HTTP 403 { "error": "setor_mismatch" }`.
4. API Central conecta ao AD via LDAPS (porta 636) e valida as credenciais.
5. AD responde com grupos do usuário (`memberOf`); API mapeia grupos → *roles* padrão.
6. Se usuário não possui *role* `operador` ou `contador`: `HTTP 403 { "error": "plugin_access_denied" }`.
7. Se credenciais válidas e *role* permitido: API gera `JWT` + `refresh_token` (RN-M01-002).
   → **[v1.3]** JWT inclui `computador_id`, `setor_id`, `grupo_ids` no payload.
8. Plugin armazena JWT em memória (`TPluginSession.Current.Token`) — **NUNCA** em arquivo ou registry.
9. Plugin exibe tela principal (`Form.Principal.fmx`); token usado em toda requisição subsequente.
10. Evento de login registrado em `public.audit_log` (RN-M01-012).

## FLUXOS DE EXCEÇÃO — O que acontece quando algo dá errado

- **E1. Credenciais incorretas**  
  - `HTTP 401 { "error": "invalid_credentials" }`  
  - Plugin exibe mensagem; incrementa contador de tentativas (RN-M01-005).

- **E2. AD inacessível**  
  - Timeout 5s  
  - `HTTP 503 { "error": "ldap_unavailable" }`  
  - Plugin exibe: "Serviço de autenticação indisponível. Tente em instantes."

- **E3. Usuário sem role permitida para Plugin**  
  - `HTTP 403 { "error": "plugin_access_denied" }`  
  - Plugin exibe: "Seu perfil não tem acesso ao Plugin padrão".

- **E4. Conta bloqueada (RN-M01-005)**
  - `HTTP 423 { "error": "account_locked", "unlocks_at": "..." }`
  - Plugin exibe tempo restante do bloqueio.

- **E5. Falha de rede no Plugin**
  - Plugin exibe: "Não foi possível conectar à API. Verifique a rede."
  - Não tenta novamente automaticamente.

- **E6. [v1.3] Computador não cadastrado**
  - `HTTP 403 { "error": "computer_not_registered" }`
  - Plugin exibe: "Este computador não está autorizado. Contate o administrador."

- **E7. [v1.3] Setor do computador diverge do setor do usuário**
  - `HTTP 403 { "error": "setor_mismatch" }`
  - Plugin exibe: "Acesso negado neste computador. Utilize sua estação de trabalho habitual."

- **E8. [v1.3] `hostname` ausente no body**
  - `HTTP 400 { "error": "hostname_required" }`
  - Verificado antes de qualquer outra validação.

## VALIDAÇÕES

| Campo / Dado | Condição / Regra | Mensagem de Erro | HTTP |
|---|---|---|---|
| username | Não vazio, mín. 3 chars | "Usuário inválido" | 400 |
| password | Não vazio, mín. 6 chars | "Senha inválida" | 400 |
| hostname | **[v1.3]** Presente no body | "hostname_required" | 400 |

### Validações adicionais

| Campo / Dado | Condição / Regra | Mensagem de Erro | HTTP |
|---|---|---|---|
| LDAPS TLS | Certificado válido e não expirado | "Erro de segurança na conexão" | 502 |
| role check | Role = `operador` ou `contador` | "Perfil sem acesso ao Plugin" | 403 |
| account status | `is_active = TRUE` no PostgreSQL | "Conta desativada" | 403 |
| **[v1.3]** computador | Existe em `public.computadores` e `ativo=TRUE` | `computer_not_registered` / `computer_inactive` | 403 |
| **[v1.3]** setor match | `computadores.setor_id = usuario_setor.setor_id` | `setor_mismatch` | 403 |

## TABELAS / CAMPOS DO BANCO DE DADOS

| Tabela             | Op. | Campos Relevantes                            |
|--------------------|-----|----------------------------------------------|
| `public.users`     | R   | `user_id`, `username`, `is_active`, `role_id` |
| `public.user_roles`| R   | `user_id`, `role_id`, `valido_ate`          |
| `public.roles`     | R   | `role_id`, `role_name`                      |
| `public.audit_log` | W   | `action=LOGIN`, `user_id`, `ip`, `timestamp`|
| `public.auth_attempts` | W | `user_id`, `ip`, `success`, `timestamp`   |

## IMPACTO EM OUTRAS RNs

- **RN-M01-002** — JWT gerado aqui é renovado automaticamente pelo worker do Plugin.
- **RN-M01-003** — MFA TOTP é o segundo passo após login bem-sucedido.
- **RN-M01-005** — Contador de tentativas falhas alimentado neste fluxo.
- **RN-M01-012** — Todo login registrado no `audit_log`; novos eventos `COMPUTER_NOT_REGISTERED`, `SETOR_MISMATCH`.
- **RN-M01-013** — **[v1.3]** Verificação de vínculo computador↔setor realizada aqui antes do LDAPS.
- **RN-M19-001** — Plugin usa `System.Net.HttpClient` (cross-platform, sem WinAPI).
- **RN-M19-010** — URL da API lida do `config.db` via `padrão.Parameters`.

## LGPD — Dados pessoais envolvidos, base legal e prazo de retenção

- **Dados tratados**: `username`, IP do cliente, timestamp de acesso.  
- **Base legal**: legítimo interesse em segurança — Art. 7°, inciso IX, LGPD.  
- **Retenção**: tentativas de login retidas 90 dias; logins bem-sucedidos 5 anos no `audit_log`.

## ESBOÇO DE IMPLEMENTAÇÃO — Delphi FMX

Trecho de código ilustrativo para o Plugin FMX utilizando `System.Net.HttpClient` (cross-platform, sem WinAPI):

```pascal
function TPluginAuth.Login(const AUser, APass: string): Boolean;
var
  oHTTP: THTTPClient;
  oBody, oResp: TJSONObject;
  sResp: string;
begin
  Result := False;
  oHTTP := THTTPClient.Create;
  try
    oBody := TJSONObject.Create;
    oBody.AddPair('username', AUser);
    oBody.AddPair('password', APass);

    sResp := oHTTP.Post(
      GetParam('HTTP', 'PluginURL', '') + '/v1/auth/login',
      oBody.ToJSON
    );

    oResp := TJSONObject.ParseJSONValue(sResp) as TJSONObject;
    if Assigned(oResp) then
    begin
      TPluginSession.Current.Token   := oResp.GetValue<string>('token');
      TPluginSession.Current.UserId  := oResp.GetValue<string>('user_id');
      TPluginSession.Current.Role    := oResp.GetValue<string>('role');
      TPluginSession.Current.Refresh := oResp.GetValue<string>('refresh_token');
      Result := True;
    end;
  finally
    oHTTP.Free;
    oBody.Free;
  end;
end;
```

## NOTAS / OBSERVAÇÕES

- **ATUALIZAÇÃO v1.2**: Plugin FMX adicionado como cliente do M01.
- **ATUALIZAÇÃO v1.3**: Verificação de vínculo computador↔setor inserida como etapa pré-LDAPS (RN-M01-013). Campo `hostname` obrigatório no body do login.
- Plugin suporta Windows, macOS e Linux — zero WinAPI. Hostname obtido via `TIdStack.LocalHostName` (cross-platform).
- Somente *roles* `operador` e `contador` podem usar o Plugin.
- JWT armazenado exclusivamente em memória (`TPluginSession`) — nunca em arquivo, registry ou `NSUserDefaults`.
- O hostname enviado é verificado contra `public.computadores` — computadores não cadastrados são bloqueados antes de qualquer consulta LDAP.

## Assinaturas

- **Elaborado por**: Edgard F. C. Junior — 13/03/2026  
- **Revisado por**: ___________________ — ___/___/______  
- **Aprovado por**: ___________________ — ___/___/______

