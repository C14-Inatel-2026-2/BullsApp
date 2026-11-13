# Uso de IA: contribuição de João Pedro Torrano Dias

| | |
|---|---|
| **Autor** | João Pedro Torrano Dias (`JoaoDTorrano`) |
| **Área** | Camada de controllers (`lib/presentation/controllers/`), testes de unidade e pipeline Jenkins |
| **Ferramenta** | Claude Code |
| **Modelos** | Claude Opus 5 e Claude Opus 5.5 |
| **Período** | 11/09/2026 a 13/11/2026 |
| **PRs** | #6, #7, #10, #13, #16, #17, #20, #21, #23, #24, #25, #35, mais 2 commits direto na `main` |

> Este documento foi redigido com auxílio do Claude e revisado pelo autor.

---

## 1. Resumo

| Indicador | Valor |
|---|---|
| PRs | 12 (11 mergeados, 1 fechado) |
| Commits | 94 |
| Cobertura dos controllers | 100% nos 4 arquivos de `lib/presentation/controllers` |
| Defeitos de produção corrigidos | 3, todos com o teste escrito antes da correção |
| Suíte do projeto | de 24 para 256 testes, contando também testes de outros integrantes |

O trabalho foi feito em duas fases:

- **Fase 1 (11/09 a 17/10):**
  - implementação da camada de controllers;
  - primeiros testes de unidade;
  - primeira medição de cobertura na pipeline.
- **Fase 2 (28/10 a 13/11):**
  - recuperação de testes perdidos numa resolução de conflito;
  - cobertura completa dos controllers;
  - relatório de testes e cobertura no Jenkins;
  - melhorias FIRST nos testes da US03;
  - remoção dos comentários do código.

O autor definiu o escopo, a arquitetura, os nomes e os critérios de aceite de cada PR. A IA escreveu ou revisou o código, rodou as verificações e propôs alternativas. Todos os PRs mergeados foram revisados por outro integrante do time.

---

## 2. Como a IA foi usada

### Participação da IA

| Nível | Definição |
|---|---|
| **Gerado** | Código escrito pela IA. O autor definiu o escopo, revisou o diff, acompanhou as verificações e abriu o PR. |
| **Assistido** | Código escrito pelo autor. A IA explicou a técnica, revisou e apontou erros antes do commit. |
| **Misto** | O PR tem as duas situações. O detalhamento está na seção do PR. |

### Forma de uso

- **Fase 1:** a IA foi autora do código em alguns PRs (Gerado) e revisora e tutora em outros (Assistido).
- **Fase 2:** a IA trabalhou como agente, com acesso ao terminal, ao Git, ao GitHub CLI, ao Flutter e ao Docker. Antes de qualquer refactor, de mexer em código de outro integrante ou de fazer push direto na `main`, ela pedia a aprovação do autor.

### Principais solicitações e decisões

| Solicitação | Resposta da IA | Decisão |
|---|---|---|
| Analisar os testes da camada de controllers | Mediu a cobertura por arquivo, apontou o que faltava testar e descobriu testes apagados numa resolução de conflito | **Aceita.** A análise virou o escopo do #23. |
| Levar a cobertura acima de 90%, aplicando princípios de engenharia de software, sem refactor sem aprovação | Propôs três refactors e pediu aprovação para cada um antes de mudar o código | **Aceita, com ajuste:** o código deveria sair sem comentários. |
| Publicar o relatório de cobertura no Jenkins com uma ferramenta nativa | Sugeriu o plugin Coverage (#24) | **Revertida no #25.** O plugin não estava instalado em todos os Jenkins do time, e foi trocado pela solução que o revisor sugeriu. |
| Rodar os testes automaticamente a cada PR aberto | Propôs GitHub Actions ou um job novo no Jenkins | **Descartada.** GitHub Actions é proibido no projeto e um Jenkins local não recebe eventos do GitHub, então o relatório ficou no estágio de testes que já existia. |

As solicitações acima são resumos, não citações literais.

---

## 3. Visão geral dos PRs

| PR | Tipo | Título resumido | Linhas | Commits | IA | Situação |
|---|---|---|---|---|---|---|
| [#6](https://github.com/C14-Inatel-2026-2/BullsApp/pull/6) | feat | TestController e AutoController | +481 / −90 | 1 | Gerado | Mergeado 21/09 |
| [#7](https://github.com/C14-Inatel-2026-2/BullsApp/pull/7) | test | Testes do AutoController | +86 / −8 | 5 | Misto | Mergeado 02/10 |
| [#10](https://github.com/C14-Inatel-2026-2/BullsApp/pull/10) | test | AutoController, Lado e RobotProtocol | +222 / −3 | 8 | Misto | Mergeado 11/10 |
| [#13](https://github.com/C14-Inatel-2026-2/BullsApp/pull/13) | test | TestController: envio e log | +137 / −1 | 10 | Assistido | Mergeado 17/10 |
| [#16](https://github.com/C14-Inatel-2026-2/BullsApp/pull/16) | test | TestController: respostas e sensores | +61 / −0 | 4 | Gerado | Mergeado 17/10 |
| [#17](https://github.com/C14-Inatel-2026-2/BullsApp/pull/17) | test | Ciclo de vida, erros e atalhos | +121 / −0 | 10 | Gerado | Mergeado 17/10 |
| [#20](https://github.com/C14-Inatel-2026-2/BullsApp/pull/20) | ci | Job de qualidade com gate de cobertura | +150 / −0 | 3 | Gerado | Fechado 17/10 |
| [#21](https://github.com/C14-Inatel-2026-2/BullsApp/pull/21) | ci | Estágio de cobertura na pipeline | +9 / −0 | 1 | Gerado | Mergeado 17/10 |
| [#23](https://github.com/C14-Inatel-2026-2/BullsApp/pull/23) | test | Cobertura dos controllers em 100% | +567 / −6 | 38 | Gerado | Mergeado 28/10 |
| [#24](https://github.com/C14-Inatel-2026-2/BullsApp/pull/24) | ci | Relatório de cobertura no Jenkins | +16 / −12 | 3 | Gerado | Mergeado 28/10 |
| [#25](https://github.com/C14-Inatel-2026-2/BullsApp/pull/25) | fix | Relatório sem o plugin Coverage | +18 / −9 | 2 | Gerado¹ | Mergeado 30/10 |
| [#35](https://github.com/C14-Inatel-2026-2/BullsApp/pull/35) | refactor | Testes da US03 (FIRST) | +55 / −5 | 7 | Gerado | Mergeado 13/11 |
| `main` | refactor | Limpeza de comentários | +12 / −106 | 2 | Gerado | Na `main` 13/11 |

¹ A solução foi sugerida pelo revisor. A IA aplicou e validou.

Totais:
- **Fase 1, PRs mergeados:** +1.117 / −102 linhas.
- **Fase 2:** +668 / −138 linhas.

---

## 4. Detalhamento por PR

### Fase 1

**#6: feat: add TestController and AutoController (Gerado)**
- **Objetivo:** criar a camada de controllers, com o estado das telas de combate (AUTO/RC) e de teste (terminal, PID, motores e sensores).
- **Alterações:**
  - `AutoController`: jogada (`D22`/`E11`), modo RC (`DRC`/`ERC`) e `STOP`.
  - `TestController`: comandos, log e respostas de sensor.
  - `RobotCommandPort` (`send`/`responses`) e `RobotProtocol`.
  - Modelos `Lado`, `SensorStatus` e `AutoStatus`.
  - `RobotCommandException` e `FakeRobotCommandPort`.
  - Integração com `ModPage` e `TerminalPage`.
- **Verificação:** `flutter analyze` sem issues e 24 testes passando.
- **Observação:** este PR reaplica o #4, que tinha sido revertido. A reversão não aconteceu por falha técnica.

**#7: test: add unit tests for AutoController (Misto)**
- **Alterações:**
  - Testes do `D22`, do `E22` e da rejeição de lado desconhecido, com `mocktail` injetado no construtor.
  - **Correção de defeito:** `Lado.fromSide` agora devolve `null` para valor desconhecido.
- **IA:** o autor escreveu os testes, com assistência da IA. A IA gerou a correção.
- **Verificação:** o teste do defeito foi escrito antes da correção e falhava até ela entrar.

**#10: test: cover AutoController, Lado and RobotProtocol (Misto)**
- **Alterações:**
  - `AutoController`: lado vazio, jogada sem número, `startRC` e `stop()`.
  - Testes puros de `Lado` e `RobotProtocol`.
  - **Correção de defeito:** o `stop()` era descartado quando havia outro envio em andamento. Foi adicionado o parâmetro `force` em `_send`.
- **IA:** o autor escreveu os testes do `AutoController`, incluindo o que reproduziu o defeito, com assistência da IA. A IA gerou a correção e os testes puros.
- **Verificação:** o teste do defeito foi escrito antes da correção. 55 testes passando.

**#13: test: cover TestController command sending and log handling (Assistido)**
- **Alterações:**
  - envio e registro no log;
  - comando vazio e comando só com espaços;
  - erro de envio;
  - `clearLog`.
- **Verificação:** teste de mutação. Sem o `trim()`, só o teste de "comando só com espaços" falha.
- **Observação:** o #16 foi mergeado nesta branch, por isso o diff do #13 inclui o conteúdo do #16.

**#16: test: cover TestController robot responses and sensor states (Gerado)**
- **Alterações:**
  - a resposta de sensor atualiza o log e o mapa `sensores`;
  - uma resposta que não é de sensor não altera o mapa;
  - o id é normalizado para maiúsculas;
  - a resposta mais recente prevalece.
- **Verificação:** teste de mutação. Sem o `toUpperCase()`, só o teste de normalização falha.

**#17: test: cover controllers lifecycle, unexpected errors and command shortcuts (Gerado)**
- **Alterações:**
  - `dispose()` dos dois controllers;
  - erro inesperado do canal;
  - `lastResponse`;
  - atalhos do `TestController`.
- **Verificação:** teste de mutação. Sem o `cancel()` do `dispose`, os testes falham. 141 testes passando.

**#20: ci: add controllers quality job (Gerado, fechado)**
- **Alterações:** um job dedicado à camada, com análise estática, cobertura e gate de cobertura mínima.
- **Verificação:** build verde no Jenkins local, com cobertura de 66,7% (o mínimo era 60%).
- **Situação:** fechado em favor de uma solução mais simples, o #21.

**#21: ci: add controllers coverage stage to the main pipeline (Gerado)**
- **Alterações:** o estágio "Cobertura dos Controllers" no `Jenkinsfile`, que publica o `lcov.info` como artefato.

### Fase 2

**#23: test: bring controllers layer coverage to 100% (Gerado)**
- **Objetivo:** recuperar os testes perdidos numa resolução de conflito e cobrir os 4 controllers.
- **Alterações:**
  - 36 testes novos: AutoController 13, TestController 8, SensorController 2 e BleController 13. O BleController antes não tinha nenhum teste.
  - 2 refactors, só nos testes: centralizar um mock que estava duplicado e trocar o stream de um teste por broadcast, porque o `tearDown` travava a suíte.
  - Correção do `isBusy` do `TestController` (defeito 3, na seção 5).
  - Um commit por teste.
- **Verificação:** o teste do defeito foi escrito antes da correção. 170 testes passando, `flutter analyze` sem issues e 100% de cobertura nos 4 controllers.

**#24: ci: publish test coverage report in the Jenkins test stage (Gerado)**
- **Alterações:**
  - O estágio "Executar Testes" passou a publicar a cobertura com o plugin Coverage.
  - O estágio redundante "Cobertura dos Controllers" saiu. Isso atendeu à revisão, que pedia um único estágio de testes.
- **Verificação:** comandos validados na imagem Docker do pipeline.
- **Observação:** quebrou nos Jenkins que não tinham o plugin. A correção veio no #25.

**#25: fix: generate the test report in the pipeline without the Coverage plugin (Gerado¹)**
- **Alterações:**
  - o relatório é gerado pelo script do próprio projeto (`scripts/gerar_relatorio.py`);
  - o resultado dos testes é publicado com `junit`;
  - o `relatorio.html` fica como artefato do build.
- **Verificação:** o estágio foi executado com `sh -xe` na imagem do pipeline, em dois cenários:

  | Cenário | Saída | Relatório |
  |---|---|---|
  | Suíte normal | exit 0 | 170 testes no JUnit |
  | Com um teste falhando | exit 1 | Gerado mesmo assim |

**#35: refactor: improve US03 sensor tests in TestController (Gerado)**
- **Objetivo:** aplicar as melhorias de uma análise FIRST nos testes da US03 (Jira Scrum-21).
- **Alterações:**
  - Teste do critério 5: os sensores mantêm o último estado quando o envio falha.
  - Teste do critério 1: `testSensors` envia `SENSORES`.
  - O teste de `dispose` agora confere a inscrição no stream antes.
  - `addTearDown` para isolar os testes.
  - Rastreabilidade da US03 atualizada.
- **Verificação:**
  - teste de mutação: com um `sensores.clear()` no `catch`, o teste do critério 5 falha;
  - o diff não altera nenhum teste de outros autores;
  - 20 testes passando nos dois arquivos.

**Limpeza de comentários, direto na `main` (Gerado)**
- **Alterações:**
  - remoção dos comentários do autor: 48 trechos em 11 arquivos do `lib/`, 106 linhas a menos;
  - remoção de um import que ficou sem uso;
  - registro em `docs/refactorings.md`.
- **Verificação:** `flutter analyze` sem issues, `dart format` sem alterações e 254 testes passando.

---

## 5. Defeitos de produção corrigidos

| # | Defeito | Impacto | Detectado por | Corrigido em |
|---|---|---|---|---|
| 1 | Lado desconhecido tratado como "direito" | O robô executaria a jogada para o lado errado, sem aviso | Teste de unidade com falso positivo investigado | #7, #10 |
| 2 | `stop()` descartado com envio em andamento | A parada não chegava ao robô, e a tela mostrava "parado" | Teste com `Completer` | #10 |
| 3 | `isBusy` liberado com envio ainda pendente | Depois de um STOP forçado, outro comando passava pela trava | Análise do código e teste com dois `Completer` | #23 |

Nos três casos, o teste que reproduz o defeito foi escrito antes da correção.

---

## 6. Métricas

| Métrica | Início | 17/10 | 28/10 | 13/11 |
|---|---|---|---|---|
| Suíte do projeto (testes) | 24 | 141 | 134 | 256 |
| Testes da camada (base A) | 0 | 49 | — | — |
| Testes em `test/presentation/controller` | — | — | 12 | 50 |
| Cobertura da camada (base A) | 0% | 83,8% | — | — |
| Cobertura dos 4 controllers (base B) | — | — | 54,1% | **100%** |

- **Base A:** `auto_controller`, `test_controller`, `lado`, `sensor_status`, `robot_protocol`, `robot_command_exception` e `fake_robot_command_port`. Os 49 testes incluem os de `Lado` e de `RobotProtocol`.
- **Base B:** os 4 arquivos de `lib/presentation/controllers` (auto, test, sensor e ble).
- As duas bases são diferentes, então os percentuais de uma não se comparam diretamente com os da outra.
- A queda de 141 para 134 testes veio da resolução de conflito citada no #23. Os 256 testes de 13/11 incluem testes de outros integrantes.

---

## 7. Verificação e limitações

### Como o código gerado foi verificado

- **Teste antes da correção:** os três defeitos foram reproduzidos por testes que falhavam antes da correção.
- **Teste de mutação manual:** em cada caso, uma linha do código foi quebrada de propósito para confirmar que o teste falha:
  - `trim()` no #13;
  - `toUpperCase()` no #16;
  - `cancel()` no #17;
  - `sensores.clear()` no #35.
- **Testes isolados:**
  - dublês com `mocktail` injetados pelo construtor;
  - testes feitos pela interface pública, no padrão Arrange/Act/Assert;
  - `addTearDown` para liberar recursos;
  - verificação das notificações do `ChangeNotifier`.
- **Refactoring em passos pequenos:** um commit por refactor, com a suíte verde antes e depois de cada um. Tudo registrado em `docs/refactorings.md`.
- **Validação do CI:**
  - fase 1: os estágios rodaram no Jenkins local;
  - fase 2: os estágios rodaram na mesma imagem Docker do pipeline, nos cenários de sucesso e de falha.

### Limitações observadas

| Situação | Impacto | Tratamento |
|---|---|---|
| A IA recomendou o plugin Coverage sem confirmar que ele estava instalado em todos os Jenkins do time | A pipeline quebrou para outro integrante depois do merge do #24 | Corrigido no #25. **Lição:** só adotar ferramenta ou plugin novo depois de confirmar com o time. |
| Um `tearDown` antigo esperava o fim de um stream que nunca tinha listener | Um teste novo travava a suíte | A IA diagnosticou rodando os arquivos de teste um a um e corrigiu com um refactor aprovado pelo autor |
| Na fase 2, a pipeline não foi validada num build do Jenkins | A validação foi indireta | Os estágios rodaram na mesma imagem Docker do pipeline |

---

## 8. Transparência e conclusão

### Transparência
- Todos os commits estão no nome do autor. Este documento é o registro do uso da IA.
- A seção 3 informa, PR a PR, se o código foi gerado pela IA, escrito com assistência ou misto.
- Todos os PRs mergeados foram revisados por outro integrante (`silasjunior360`) e passaram pela pipeline.

### Conclusão

A IA participou de toda a camada de controllers, da implementação inicial (#6) à cobertura completa (#23), e da primeira medição na pipeline (#21) ao relatório de testes no Jenkins (#25).

O maior ganho foi na verificação: testes escritos antes das correções, testes de mutação e validação do CI num ambiente equivalente ao da pipeline. Isso revelou 3 defeitos de produção e permitiu recuperar testes perdidos numa integração.

O principal ponto de atenção foi a adoção de uma dependência de ambiente sem consultar o time. Isso reforça que decisões que afetam outros integrantes precisam de validação humana antes do merge.
