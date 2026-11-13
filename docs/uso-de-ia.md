# Uso de IA

O grupo usou IA como apoio no desenvolvimento. Todo código gerado foi lido, testado e revisado por PR antes do merge.

## Modelos utilizados

| Ferramenta | Modelo | Quem usou |
|---|---|---|
| Claude Code | Claude Sonnet 5.5 | Silas |
| Google Gemini | Gemini 1.5 Pro | Kaynan |
| Claude Code | Claude Opus 5 e Claude Opus 5.5 | João ([detalhamento](uso-de-ia-joao.md)) |
| Claude Code | Claude Sonnet 5.5 | Luiz |

## Para que foi usada

- **Revisão de código:** encontrar problemas e sugerir melhorias, por exemplo no `robot_protocol.dart`.
- **CI/CD:** ajuda na implementação da notificação do Discord na pipeline e diagnóstico de erros no Jenkins.
- **Documentação:** seções deste README.
- **Planejamento:** comparar o projeto com os requisitos da NP2 e dividir as tarefas do Jira.

## Exemplos de prompts

**1. Revisão do protocolo do robô: parte aceita, parte descartada**
> "me mostre algumas melhorias para esse código e também me fale implementações que melhorariam esse código, mas não implemente nada"

A IA apontou que o `pid` podia gerar notação científica (`1e-7`), que a jogada não validava números negativos e que a regex de sensor falhava com `\r` no fim da linha. Os problemas foram **aceitos** e viraram tarefas no Jira. A sugestão de reescrever os comandos como `sealed class` foi **descartada**: era mais complexidade do que o projeto precisa.

**2. Documentação do webhook do Discord: ajustada**
> "consegue documentar a parte de colocar a notificação do Discord via webhook, só explicando cada etapa no README, de maneira simplória"

A primeira resposta explicava o código e a solução de problemas. O texto foi **simplificado duas vezes**, até ficar só o caminho da credencial no Jenkins.

**3. Enviar o APK pelo Discord: descartado**
> "tem como também mandar a build do APK pelo Discord?"

A IA verificou que o APK tem cerca de 156 MB, e o limite do webhook é de 10 MB. A ideia foi **descartada**. Ficaram como alternativas o GitHub Releases ou o teste interno da Play Store.

**4. Falha no build de iOS: aceito**

Ao rodar o pipeline, a IA identificou que o `flutter build ios` só funciona no macOS e por isso nunca passaria no container Linux. O grupo **removeu** o estágio (commit `c68912d`).

**5. Armazenamento de MAC Address (Bluetooth LE): aceito**
> "Como posso implementar o armazenamento persistente de endereços MAC no Flutter usando flutter_blue_plus para priorizar os robôs conhecidos na hora do scan?"

A IA sugeriu o uso do pacote `shared_preferences` para salvar os MACs localmente. A estratégia foi **aceita** e integrada ao controlador para agilizar a reconexão automática com os robôs da equipe.

## Uso de IA – Luiz

**Para que foi usada**
- Guiar a criação da tela de sensores (`SensorPage`, `RobotSensorView`, `SensorController`), sem entregar o código pronto.
- Resolver conflitos de merge e diagnosticar erros do `flutter analyze` e do Jenkins.
- Montar os stages de formatação e análise estática no `Jenkinsfile`.
- Apoio na escrita dos testes unitários.

**Exemplos de prompts**

**1. Tela de sensores: aceito**
> "me ajude a fazer isso [sensor_page.dart] ... me ensine a fazer não me de o codigo pronto"

A IA explicou o modelo, o enum com `extension` de cor e o `Stack` com `Align`, e revisou cada tentativa. Eu escrevi o código e ela apontou os erros (nome de classe, tipo do campo, import).

**2. Testes dos componentes e da MotorPage: gerado pela IA, revisado por mim**
> "faça os códigos de teste para essas 3 páginas ..."

A IA gerou os testes de `VerticalBar`, `RobotSensorView` e `MotorPage`. Eu criei os arquivos, corrigi um erro de digitação, rodei com `flutter test` e confirmei que passam. A IA errou o nome da pasta de testes (`widgets` em vez de `widget`), e o erro foi corrigido ao rodar.

**3. Stage do Jenkins: aceito com adaptação**
> "me ajude a fazer esse job 'Verificar Formatação + Análise Estática'"

A resposta inicial era para GitHub Actions. Eu informei que o grupo usa Jenkins, e ela foi refeita como stage do `Jenkinsfile`. Separei a formatação e a análise em dois stages.

**4. Formatação bloqueando o pipeline: aceito**
> "não seria melhor ela não ser um requisito para o pipeline continuar a rodar?"

A IA apresentou os dois lados (formatação é cosmética, mas um stage vermelho esconde o resultado dos testes) e sugeriu o `catchError`. Eu adotei no `Jenkinsfile`: o stage de formatação fica instável (amarelo) sem derrubar o build, e o `flutter analyze` continua bloqueando.[Testei desformatando um arquivo de propósito.]

## Dinâmica de uso

- A IA foi usada **individualmente**, como par de programação: o integrante pede, lê a resposta e decide se aceita.
- Tudo o que foi gerado passou pelo mesmo fluxo do resto do código: branch, PR, revisão de outro membro e pipeline verde no Jenkins.
- As histórias de usuário e os textos do README foram **reescritos pelo grupo** a partir do rascunho da IA.

## O que não foi feito por IA

Por exemplo: a arquitetura em camadas, o protocolo de comandos combinado com o firmware, o design das telas, as jogadas do `JOGADAS.json` e toda a ideia do projeto foram criados pelos membros da RobotBulls.

Os testes da camada de controllers tiveram participação da IA. O detalhamento PR a PR (código gerado, assistido ou misto) está em [uso-de-ia-joao.md](uso-de-ia-joao.md).
