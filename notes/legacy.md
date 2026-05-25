# Legado do MVP

Notas sobre o que veio do MVP de 2020 e ainda não foi pago.

## Origem

SafeCover começou em 2020 como MVP de uma fintech expandindo para insurtech. Time inicial pequeno (3 devs), foco em velocidade. Rails 6.0, Ruby 2.7, Postgres 12, código corrido para validar product-market fit.

PMF aconteceu em 2021. Empresa cresceu rápido. Time triplicou em 2022, e aí a cobrança técnica começou.

## Migrações sucessivas

| Período | Stack | Notas |
|---|---|---|
| 2020 | Rails 6.0 + Ruby 2.7 | MVP |
| 2022 | Rails 6.1 + Ruby 3.0 | Bump menor, sem grandes refactors |
| 2025 | Rails 8.1 + Ruby 4.0 | Migração grande, mas sem pagar débito de design |

**Lição aprendida:** modernizar stack não paga débito de design. Os mesmos vícios persistem.

## Vícios herdados que continuam

### 1. Callbacks com regra de negócio

O `before_save :calcula_coparticipacao` virou `before_save :calculate_payout_amount`. Continua sendo callback. Continua dificultando testes isolados.

### 2. SQL injection no `search_by_filters`

Foi escrito em 2020 quando o dev sênior não estava por perto. O junior aprendeu errado. O método continua sendo usado em produção (~15k chamadas/dia segundo nossa observabilidade fictícia).

Risco: alto. Prioridade: deveria ser média. Mas como "está funcionando há 5 anos", ninguém mexe.

### 3. Status como string livre

`Claim#status` é string sem state machine. Em 2023 tivemos um incidente onde um claim passou direto de `open` para `paid` por causa de um update mal feito em rake task. Adicionamos validação de inclusion, mas não impedimos transições inválidas.

### 4. Service objects que levantam exception

`Claims::EvaluateEligibility` foi começado em 2022 seguindo o ADR-002 (retornar Result). Mas o dev que o escreveu mudou de empresa antes de terminar, e quem pegou o código adicionou um `raise EligibilityError` quando a apólice não estava ativa "porque era mais simples".

Agora temos um service que é metade Result, metade exception. Os controllers que o consomem precisam de `rescue` E checagem de `result.failure?`. Feio.

### 5. Specs acoplados a callbacks

O `claim_spec.rb` testa o efeito do `before_save :calculate_payout_amount`. Quando o callback for extraído para `Claims::CalculatePayoutAmount`, esses testes vão **quebrar** ou vão **passar enganando** (porque o callback ainda estará lá em paralelo). O caminho correto é mover os testes para o spec do service quando ele for extraído.

### 6. Credenciais em formato legível

Existia uma pasta `secrets/` no início do projeto. Quando migramos para Rails 5.2 e `credentials.yml.enc`, alguém commitou o arquivo descriptografado por engano. Foi removido do histórico via `git filter-branch`, mas o arquivo atual ainda está em formato legível. Issue #67 em aberto desde 2023.

## Por que não pagamos esses débitos?

Resposta honesta: **pressão de feature de produto**. O time é cobrado por velocidade de release. Refactor não tem ROI visível para o board. Cada um que tentou levou 2-3 semanas e foi puxado para outras prioridades no meio.

Esperamos que o trabalho com Claude Code (treinamento Kazap 2026) ajude a pagar parte desse débito — refactors guiados são mais rápidos e mais seguros.

## Princípio para mexer no legado

> Toda PR que toca código legado deve **deixar pelo menos uma coisa melhor** que a encontrou. Não precisa pagar a dívida toda. Pague um pedaço.

Boy scout rule.
