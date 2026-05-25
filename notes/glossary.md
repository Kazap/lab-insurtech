# Glossário SafeCover

Termos do domínio de seguros (insurtech) usados no codebase, com tradução PT-BR ↔ inglês.

## Modelos centrais

| Inglês (código) | PT-BR | Definição |
|---|---|---|
| `Policyholder` | Segurado | Pessoa física que contrata o seguro |
| `Policy` | Apólice | Contrato de seguro entre policyholder e SafeCover |
| `PolicyCoverage` | Cobertura | Garantia específica dentro da apólice |
| `Claim` | Sinistro | Evento que dispara a cobertura |
| `PremiumPayment` | Pagamento de prêmio | Pagamento mensal devido pela apólice |

## Atributos

| Inglês | PT-BR | Observação |
|---|---|---|
| `effective_date` | Data de vigência inicial | Quando a apólice começa a valer |
| `expiration_date` | Data de vigência final | Quando a apólice expira |
| `coverage_amount` | Valor segurado | Limite máximo da apólice |
| `monthly_premium` | Prêmio mensal | Quanto o policyholder paga por mês |
| `requested_amount` | Valor solicitado | Quanto o policyholder pede no sinistro |
| `payout_amount` | Valor pago | Quanto a seguradora efetivamente paga |
| `deductible` | Franquia | Valor descontado antes da cobertura |
| `coverage_percentage` | Percentual de cobertura | % do valor após franquia que é coberto |
| `risk_profile` | Perfil de risco | low / medium / high |

## Status de Policy

| Inglês | PT-BR | Significado |
|---|---|---|
| `active` | Ativa | Apólice vigente, pagamentos em dia |
| `suspended` | Suspensa | Pagamento atrasado, mas ainda recuperável |
| `canceled` | Cancelada | Encerrada definitivamente |

## Status de Claim

| Inglês | PT-BR | Significado |
|---|---|---|
| `open` | Aberto | Sinistro recém-aberto, aguardando análise |
| `under_review` | Em análise | Sob avaliação dos peritos |
| `approved` | Aprovado | Aprovado mas ainda não pago |
| `paid` | Pago | Indenização paga ao policyholder |
| `rejected` | Rejeitado | Não atende cobertura ou foi fraudulento |

## Tipos de coverage por policy

- **auto:** `collision`, `theft`, `third_party`
- **home:** `fire`, `theft`, `flood`
- **life:** `natural_death`, `accidental_death`, `disability`

## Cálculo de indenização (payout)

A regra atual está em `Claim#calculate_payout_amount` (com FIXME para extrair):

```
payout = min(
  (requested_amount - deductible) * coverage_percentage / 100,
  coverage.max_coverage_amount,
  policy.coverage_amount
)
```

Se `requested_amount < deductible`, payout = 0.

## Regulação SUSEP

SafeCover é uma insurtech fictícia. Em cenário real, seria regulada pela SUSEP (Superintendência de Seguros Privados). O lab não modela essa regulação, mas o cenário pedagógico assume conformidade.
