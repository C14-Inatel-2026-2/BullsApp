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

As jogadas ficam em `lib/assets/json/JOGADAS.json` e estão divididas em 5 categorias: **busca**, **ofensiva**, **defensiva**, **fake** e **desempate**. Os parâmetros físicos usados na simulação (tamanho do robô, dohyo, velocidade) ficam em `lib/assets/json/PHYSICS.json`.

## Como usar

1. Ligue o robô e ative o Bluetooth do celular.
2. Abra o app, procure o robô e conecte.
3. Na tela inicial, escolha:
   - **Combate**: para escolher o lado e a jogada e enviar ao robô;
   - **Testar**: para testar motores e sensores, calibrar o PID ou abrir o terminal.

## Como funciona por dentro

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


## Bibliotecas e ferramentas necessárias

Antes de rodar o projeto, instale as seguintes ferramentas e dependências:

### Ferramentas do sistema

- Flutter SDK
- Git
- Android Studio
- Android SDK / Android command-line tools
- Java JDK (necessário para compilar Android)
- VS Code ou outro editor

### Bibliotecas do projeto

Ao executar `flutter pub get`, o Flutter baixa automaticamente as dependências do projeto. As bibliotecas usadas no app são:

- `cupertino_icons`
- `google_fonts`
- `flutter_blue_plus`
- `iconsax`
- `provider`

Para desenvolvimento/testes também estão configuradas:

- `flutter_lints`
- `mocktail`

## Instalar o Flutter no Windows

1. Baixe o Flutter: https://docs.flutter.dev/get-started/install/windows
2. Extraia a pasta, por exemplo, em:

```text
C:\src\flutter
```

3. Adicione este caminho ao `Path` do Windows:

```text
C:\src\flutter\bin
```

4. Instale o Android Studio e o Android SDK.
5. Abra um novo terminal e verifique a instalação:

```powershell
flutter doctor
```

## Rodar o projeto

Na pasta do projeto:

```powershell
flutter pub get
flutter run
```

Ou usando o Makefile:

```powershell
make get
make run
```

## Comandos úteis

```powershell
flutter clean       # Limpa os arquivos gerados
flutter test        # Executa os testes
flutter analyze     # Analisa o código
flutter build apk   # Gera o APK Android
flutter build web   # Gera a versão Web
```

Com Makefile:

```powershell
make clean
make test
make build-apk
make build-web
```

## Relatório de testes

Gera dois relatórios em HTML na pasta `reports/`:

- `reports/testes.html`: quais testes passaram e quais falharam;
- `reports/cobertura.html`: quanto do código os testes cobrem.

Para gerar, é preciso ter Python (com `pip`) instalado. Depois rode:

```powershell
make report-setup   # só na primeira vez
make report
```

Para ver o resultado, abra os arquivos no navegador.

## CI/CD com Jenkins + Docker

O projeto usa Jenkins rodando em container Docker para executar a pipeline (testes automatizados a cada push). A pipeline roda o Flutter dentro de outro container (`ghcr.io/cirruslabs/flutter:stable`), então **não é necessário instalar o Flutter na máquina do Jenkins** — só o Docker.

> **Nota:** os passos abaixo sobem um Jenkins **local**, na sua própria máquina (`localhost:8080`). Cada pessoa do time que seguir este guia terá seu próprio Jenkins, isolado — não é um painel compartilhado. Se/quando o time tiver um Jenkins hospedado em servidor/nuvem, a URL será divulgada separadamente.

### Pré-requisitos

- Docker Desktop instalado e rodando (modo **Linux containers**).

### Subir o Jenkins

O Jenkins precisa de uma imagem customizada, com o Docker CLI instalado, para conseguir rodar o container do Flutter durante os builds. Esse setup já está pronto no arquivo [`Dockerfile.jenkins`](./Dockerfile.jenkins), na raiz do repositório.

**1. Construa a imagem:**

```powershell
docker build --platform linux/amd64 -f Dockerfile.jenkins -t jenkins-with-docker .
```

**2. Suba o container:**

```powershell
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v //var/run/docker.sock:/var/run/docker.sock jenkins-with-docker
```

**3. Dê permissão ao usuário `jenkins` para usar o socket do Docker** (necessário apenas uma vez, após o primeiro `docker run`):

```powershell
docker exec -u root -it jenkins usermod -aG root jenkins
docker restart jenkins
```

**4. Acesse o painel:** `http://localhost:8080`

A senha inicial de admin (primeiro acesso) fica disponível em:

```powershell
docker logs jenkins
```

### Configurar a pipeline

1. No Jenkins, crie uma nova tarefa do tipo **Pipeline**.
2. Em **Pipeline → Definition**, selecione **Pipeline script from SCM**.
3. **SCM:** Git — informe a URL deste repositório e a branch (`main`).
4. **Script Path:** `Jenkinsfile` (já está na raiz do projeto).
5. Instale o plugin **Docker Pipeline** em *Manage Jenkins → Plugins*, caso ainda não esteja instalado — é necessário para o `Jenkinsfile` conseguir rodar o container do Flutter.
6. Salve e rode **Build Now**.

A cada build, o Jenkins baixa o código, sobe um container com o Flutter, roda `flutter pub get` e `flutter test`, e reporta o resultado.

### Notificações no Discord

Para o Jenkins avisar no Discord, coloque a URL do webhook em:

**Manage Jenkins → Credentials → System → Global credentials → Add Credentials**

- **Kind:** `Secret text`
- **Secret:** a URL do webhook do Discord
- **ID:** `discord-webhook`
