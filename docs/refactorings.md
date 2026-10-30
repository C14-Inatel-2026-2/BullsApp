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
