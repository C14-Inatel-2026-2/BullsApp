# BullsApp

Aplicativo mobile (Android e iOS), feito em Flutter, para controlar e testar os robôs de sumô da **RobotBulls** por Bluetooth Low Energy (BLE).

## Por que o projeto existe

O BullsApp foi criado para ajudar os membros da RobotBulls nas categorias **Sumô Mini** e **Sumô 3 kg**. A ideia é ter tudo num lugar só, direto no celular:

- **na hora do combate:** escolher e visualizar as jogadas do robô;
- **nos treinos:** testar motores e sensores e calibrar o PID, sem precisar regravar o firmware.

## Funcionalidades

| Tela | O que faz |
|---|---|
| **Conexão** | Procura robôs por BLE, conecta e lembra os dispositivos já usados. O cabeçalho mostra se o robô está conectado. |
| **Combate (Auto)** | Escolhe o lado de saída (esquerda/direita) e a jogada. Antes de enviar, mostra uma simulação da jogada no dohyo. |
| **Modo teste** | Envia a jogada com o prefixo `T`, para treinar sem iniciar uma luta de verdade. |
| **RC** | Coloca o robô no modo rádio-controlado. |
| **Testar motores** | Envia valores para os motores esquerdo e direito, com marcha à ré. |
| **Testar sensores** | Mostra em tempo real quais sensores estão vendo o oponente. |
| **Calibrar PID** | Ajusta Kp, Ki e Kd (de 0 a 100) e envia para o robô. |
| **Terminal** | Mostra as mensagens trocadas com o robô, para depuração. |

## Tecnologias

| Tecnologia | Uso no projeto |
|---|---|
| Flutter + Dart | Aplicativo mobile |
| FlutterBluePlus | Comunicação BLE com o robô |
| Provider | Gerenciamento de estado |
| flutter_test + mocktail | Testes automatizados |
| Pub | Gerenciamento de dependências |
| Jenkins + Docker | Pipeline de CI/CD |

## Instalação e execução

Pré-requisitos: Flutter SDK, Android Studio (Android SDK) e Git.

```powershell
flutter pub get
flutter run          # com o robô real, por Bluetooth
make run-fake        # sem o robô, com um robô simulado
make test            # roda os testes
make report          # gera reports/relatorio.html (testes + cobertura)
```

Passo a passo completo em [docs/instalacao.md](docs/instalacao.md).

## Como usar

1. Ligue o robô e ative o Bluetooth do celular.
2. Abra o app, procure o robô e conecte.
3. Na tela inicial, escolha:
   - **Combate**: para escolher o lado e a jogada e enviar ao robô;
   - **Testar**: para testar motores e sensores, calibrar o PID ou abrir o terminal.

## Requisitos

### Funcionais

| ID | Requisito |
|---|---|
| RF01 | Procurar e conectar a robôs por BLE, lembrando os dispositivos já usados. |
| RF02 | Enviar jogadas escolhendo o lado e o número (`D22`, `E08`), com opção de modo teste (`TD08`). |
| RF03 | Entrar no modo rádio-controlado (`DRC` / `ERC`). |
| RF04 | Testar os motores esquerdo e direito, inclusive em marcha à ré. |
| RF05 | Mostrar em tempo real quais sensores estão vendo o oponente. |
| RF06 | Ajustar e enviar Kp, Ki e Kd, aceitando apenas valores de 0 a 100. |
| RF07 | Enviar comandos manuais e ver as respostas num terminal. |
| RF08 | Parar o robô (`STOP`) a qualquer momento, mesmo com outro comando em andamento. |
| RF09 | Mostrar o status da conexão com o robô no cabeçalho. |

### Não funcionais

| ID | Requisito |
|---|---|
| RNF01 | Rodar em Android (o build de iOS precisa de macOS e está fora do pipeline). |
| RNF02 | Comunicar só por BLE, sem precisar de internet. |
| RNF03 | Montar todos os comandos do robô num único lugar (`robot_protocol.dart`). |
| RNF04 | Ter o código organizado em camadas (`presentation`, `data`, `core`). |
| RNF05 | Passar por pipeline no Jenkins (formatação, análise estática, testes e build) a cada merge. |
| RNF06 | Ter dependências gerenciadas pelo Pub, com o `pubspec.lock` versionado. |
| RNF07 | Funcionar sem o robô (`make run-fake`), para desenvolvimento e testes. |

## Uso de IA

O grupo usou IA como apoio no desenvolvimento. Todo código gerado foi lido, testado e revisado por PR antes do merge.

| Ferramenta | Modelo | Quem usou |
|---|---|---|
| Claude Code | Claude Sonnet 5.5 | Silas |
| _preencher_ | _preencher_ | _Luiz / Kaynan / João_ |

- **Revisão de código:** encontrar problemas e sugerir melhorias, por exemplo no `robot_protocol.dart`.
- **CI/CD:** ajuda na implementação da notificação do Discord na pipeline e diagnóstico de erros no Jenkins.
- **Documentação:** seções deste README.
- **Planejamento:** comparar o projeto com os requisitos da NP2 e dividir as tarefas do Jira.

Prompts usados, respostas aceitas ou descartadas, dinâmica de uso e o que foi feito sem IA: [docs/uso-de-ia.md](docs/uso-de-ia.md).

## Integrantes

| Integrante | Papel | GitHub |
|---|---|---|
| Silas Rodrigues de Oliveira Junior | Manager / FullStack | [@silasjunior360](https://github.com/silasjunior360) |
| Luiz Filipe Peçanha de Melo | Frontend / Integração | [@Luizfilipe99](https://github.com/Luizfilipe99) |
| Kaynan Herique Dias de Melo | Backend / Comunicação BLE | [@KaynanMelo06](https://github.com/KaynanMelo06) |
| João Pedro Torrano Dias | Backend / Controllers | [@JoaoDTorrano](https://github.com/JoaoDTorrano) |

## Documentação

| Documento | Conteúdo |
|---|---|
| [Instalação e execução](docs/instalacao.md) | Ferramentas, instalar o Flutter, comandos e Makefile |
| [Arquitetura](docs/arquitetura.md) | Camadas do código, protocolo de comandos e jogadas |
| [Testes](docs/testes.md) | Como rodar os testes e gerar o relatório HTML com cobertura |
| [CI/CD](docs/ci-cd.md) | Jenkins + Docker e notificação no Discord |
| [Histórias de usuário](docs/historias-de-usuario.md) | Histórias com critérios de aceite, prioridade, status e rastreabilidade |
| [Metodologia](docs/metodologia.md) | Scrum, papéis, sprints, definição de pronto e métricas |
| [Dinâmica de desenvolvimento](docs/dinamica.md) | Branches, commits, code review, bloqueios e lições aprendidas |
| [Refactorings](docs/refactorings.md) | Refactorings aplicados, com commits e PRs |
| [Uso de IA](docs/uso-de-ia.md) | Modelos, prompts e dinâmica de uso |
