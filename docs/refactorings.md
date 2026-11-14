# Refactorings

| Commit / PR | O que mudou | Por quê |
|---|---|---|
| `9bdc8a3` | Simplificou a ordenação e o tratamento de erros na camada BLE | Código duplicado e erros tratados de formas diferentes |
| `7e421d7` | Centralizou a montagem dos comandos no `RobotProtocol` | As strings estavam espalhadas pelas telas |
| `685e5fa` | Adicionou o modo teste no comando de jogada (`TD08`) | Evitar criar outro comando só para os testes |
| `6c8866d` | Separou formatação e análise estática em estágios próprios no Jenkins | Saber exatamente qual verificação falhou |
| `c68912d` | Removeu o estágio de build de iOS | Não roda em container Linux |
| PR #6 | Reaplicou os controllers depois do revert do PR #4 | Corrigir a quebra da `main` |
| PR #22 | Juntou os refactorings acima, o relatório de testes e a documentação | Limpeza geral antes da entrega |
| `aaf1d4a` | Limpou o código de comentários nos controllers, no protocolo, nos modelos, no canal de comandos e na tela do terminal | Comentários ficam desatualizados e repetem o que nomes claros e testes já dizem |
| PR #35 | Testes da US03 no `TestController`: limpeza com `addTearDown` e verificação da inscrição antes do `dispose` | Análise FIRST: testes isolados e que não passam sem o comportamento que verificam |
| `<hash>` | `SensorPage`: separou o `Provider` em `_SensorView` e extraiu o estado de carregamento para `_buildSensorContent` | O `Builder` aninhado escondia a estrutura da tela |
| `<hash>` | `MotorPage`: separou o `Provider` em `_MotorView`, renomeou `_esq`/`_dir` para `_leftPower`/`_rightPower` e extraiu `_buildMotorBar` | A mesma barra estava escrita duas vezes |
| `<hash>` | `VerticalBar`: constantes para espaçamentos e `assert(min < max)`; passou a aceitar `divisions` e `valueFormatter` | Valores soltos e nenhuma proteção contra faixa inválida |