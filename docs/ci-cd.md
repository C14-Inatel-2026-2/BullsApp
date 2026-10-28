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
5. Instale os plugins abaixo em *Manage Jenkins → Plugins*, caso ainda não estejam instalados:
   - **Docker Pipeline**: necessário para o `Jenkinsfile` conseguir rodar o container do Flutter;
   - **Coverage**: necessário para o passo `recordCoverage` do estágio "Executar Testes".
6. Salve e rode **Build Now**.

A cada build, o Jenkins baixa o código, sobe um container com o Flutter, roda `flutter pub get` e `flutter test --coverage`, e reporta o resultado.

## Relatório de cobertura

O estágio "Executar Testes" publica a cobertura com o plugin **Coverage**, a partir do `coverage/lcov.info`. Na página de cada build aparece o item **Cobertura de Testes**, com a cobertura por pasta e por arquivo, o código-fonte colorido linha a linha e a evolução entre builds.

## Notificações no Discord

Para o Jenkins avisar no Discord, coloque a URL do webhook em:

**Manage Jenkins → Credentials → System → Global credentials → Add Credentials**

- **Kind:** `Secret text`
- **Secret:** a URL do webhook do Discord
- **ID:** `discord-webhook`
