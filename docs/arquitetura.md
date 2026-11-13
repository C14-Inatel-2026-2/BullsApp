# Arquitetura

O app se comunica com o robô por **comandos de texto curtos** enviados via BLE, como estes:

| Comando | Significado |
|---|---|
| `D22` | Executar a jogada 22 saindo pela direita |
| `TE08` | Executar a jogada 8 pela esquerda, em modo teste |
| `DRC` | Entrar no modo RC pelo lado direito |
| `MOTOR 1000 -1000` | Testar os motores |
| `PID 1.0 0.0 0.5` | Enviar os valores do PID |

Todos os comandos são montados num lugar só: `lib/core/constants/robot_protocol.dart`.

O código está organizado em camadas:

- `lib/presentation/`: telas, widgets e controllers;
- `lib/data/`: serviços BLE, repositórios e modelos;
- `lib/core/`: protocolo, constantes e tema;
- `test/`: testes automatizados.

## Jogadas e simulação

As jogadas ficam em `lib/assets/json/JOGADAS.json` e estão divididas em 5 categorias: **busca**, **ofensiva**, **defensiva**, **fake** e **desempate**. Os parâmetros físicos usados na simulação (tamanho do robô, dohyo, velocidade) ficam em `lib/assets/json/PHYSICS.json`.
