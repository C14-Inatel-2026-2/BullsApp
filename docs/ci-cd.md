# CI/CD com Jenkins + Docker

O projeto usa Jenkins rodando em container Docker para executar a pipeline (testes automatizados a cada push). A pipeline roda o Flutter dentro de outro container (`ghcr.io/cirruslabs/flutter:stable`), então **não é necessário instalar o Flutter na máquina do Jenkins** — só o Docker.

> **Nota:** os passos abaixo sobem um Jenkins **local**, na sua própria máquina (`localhost:8080`). Cada pessoa do time que seguir este guia terá seu próprio Jenkins, isolado — não é um painel compartilhado. Se/quando o time tiver um Jenkins hospedado em servidor/nuvem, a URL será divulgada separadamente.

## Pré-requisitos

- Docker Desktop instalado e rodando (modo **Linux containers**).

## Subir o Jenkins

O Jenkins precisa de uma imagem customizada, com o Docker CLI instalado, para conseguir rodar o container do Flutter durante os builds. Esse setup já está pronto no arquivo [`Dockerfile.jenkins`](../Dockerfile.jenkins), na raiz do repositório.

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

## Configurar a pipeline

1. No Jenkins, crie uma nova tarefa do tipo **Pipeline**.
2. Em **Pipeline → Definition**, selecione **Pipeline script from SCM**.
3. **SCM:** Git — informe a URL deste repositório e a branch (`main`).
4. **Script Path:** `Jenkinsfile` (já está na raiz do projeto).
5. Instale o plugin **Docker Pipeline** em *Manage Jenkins → Plugins*, caso ainda não esteja instalado — é necessário para o `Jenkinsfile` conseguir rodar o container do Flutter.
6. Salve e rode **Build Now**.

A cada build, o Jenkins baixa o código, sobe um container com o Flutter e executa os estágios:

1. **Obter Dependências** — `flutter clean` e `flutter pub get`;
2. **Verificar Formatação** — `dart format --set-exit-if-changed`;
3. **Análise Estática** — `flutter analyze`;
4. **Executar Testes** — `flutter test --coverage` e geração do relatório;
5. **Builds em Paralelo** — APK (`flutter build apk --release`) e Web (`flutter build web --release`);
6. **Deploy** — só quando o parâmetro `DEPLOY` é marcado (veja [Deploy](#deploy)).

Se qualquer estágio falhar, os seguintes não rodam — ou seja, código que não passa nos testes nunca é publicado.

## Relatório de testes e cobertura

O estágio "Executar Testes" gera o mesmo relatório do `make report` (veja [Testes](testes.md)) e o publica de duas formas:

- **Test Result**, na página do build: resultado de cada teste, lido do `reports/test-results.xml` (JUnit);
- **Build Artifacts → `reports/relatorio.html`**: resumo dos testes e cobertura de cada arquivo do `lib/`, com o código colorido linha a linha.

O relatório também vai anexado na notificação do Discord. Se algum teste falhar, o relatório é gerado mesmo assim e o estágio termina com falha.

## Notificações no Discord

Para o Jenkins avisar no Discord, coloque a URL do webhook em:

**Manage Jenkins → Credentials → System → Global credentials → Add Credentials**

- **Kind:** `Secret text`
- **Secret:** a URL do webhook do Discord
- **ID:** `discord-webhook`

## Deploy

O deploy publica o app em dois lugares, ambos no próprio GitHub:

| Plataforma | Onde | Link |
|---|---|---|
| **Web** | GitHub Pages (branch `gh-pages`) | <https://c14-inatel-2026-2.github.io/BullsApp/> |
| **Android** | GitHub Releases (APK anexado) | <https://github.com/C14-Inatel-2026-2/BullsApp/releases> |

O deploy **não é automático**: ele só acontece quando alguém roda o build marcando a opção `DEPLOY`. Como o Jenkins roda localmente, não há um servidor ligado o tempo todo para disparar builds sozinho.

### Configuração (uma vez só)

**1. Token do GitHub**

Gere um token com permissão de escrita no repositório:

1. No GitHub, clique na sua foto → **Settings** → **Developer settings** (último item do menu à esquerda) → **Personal access tokens** → **Tokens (classic)**;
2. **Generate new token (classic)**, marque o escopo **`public_repo`** e gere;
3. Copie o token (começa com `ghp_` e só aparece uma vez).

> Se a organização bloquear tokens classic, use um *Fine-grained token* com **Resource owner** `C14-Inatel-2026-2`, acesso só ao repositório `BullsApp` e permissão **Contents: Read and write**.

> ⚠️ O token dá acesso de escrita ao repositório: **não compartilhe** (chat, commit, print). Ele deve existir só no Jenkins. Se vazar, revogue em *Settings → Developer settings → Personal access tokens*.

**2. Credencial no Jenkins**

Em **Manage Jenkins → Credentials → System → Global credentials → Add Credentials**:

- **Kind:** `Secret text` (não confundir com *GitHub App*)
- **Secret:** o token
- **ID:** `github-token`

**3. GitHub Pages** (depois do primeiro deploy, quando a branch `gh-pages` já existir)

No repositório: **Settings → Pages → Source: Deploy from a branch → Branch: `gh-pages` / `(root)` → Save**. Requer acesso de admin no repositório. Em 1–2 minutos o site fica disponível no link acima.

### Como fazer o deploy

1. No Jenkins, abra o job e clique em **Build with Parameters**;
2. Marque **DEPLOY** e clique em **Build**.

> Na primeira execução após o parâmetro ser adicionado ao `Jenkinsfile`, o Jenkins mostra só **Build Now** — esse primeiro build serve para ele registrar o parâmetro. A partir do seguinte aparece **Build with Parameters**.

O estágio **Deploy** só roda se `DEPLOY` estiver marcado e se todos os estágios anteriores (formatação, análise, testes e builds) passarem. Ele é dividido em dois estágios que rodam em paralelo e são independentes (se um falhar, o outro publica mesmo assim):

- **Deploy Web:** envia o conteúdo de `build/web` para a branch `gh-pages`, substituindo a versão anterior. O build usa `--base-href /BullsApp/`, que é o caminho em que o GitHub Pages serve o site;
- **Deploy APK:** instala o [`gh`](https://cli.github.com/) (CLI do GitHub) e cria a release `build-<número do build>`, apontando para o commit testado, com o APK (`app-release.apk`) anexado.

### Instalar o APK no celular

1. Abra a página de [Releases](https://github.com/C14-Inatel-2026-2/BullsApp/releases) no celular;
2. Na release mais recente, em **Assets**, baixe o `app-release.apk`;
3. Abra o arquivo e permita a instalação de **fontes desconhecidas** quando o Android pedir.

> O APK é gerado em modo release, mas assinado com a chave de debug (configuração padrão do projeto em `android/app/build.gradle.kts`). Serve para instalar e testar, mas não para publicar na Play Store.

> A versão web usa Bluetooth via Web Bluetooth, que só funciona no **Chrome** e no **Edge**.
