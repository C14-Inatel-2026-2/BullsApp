# BullsApp

Projeto Flutter para controle e conexão com dispositivos.

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
