# Uso de IA

O grupo usou IA como apoio no desenvolvimento. Todo código gerado foi lido, testado e revisado por PR antes do merge.

## Modelos utilizados

| Ferramenta | Modelo | Quem usou |
|---|---|---|
| Claude Code | Claude Sonnet 5.5 | Silas |
| Google Gemini | Gemini 1.5 Pro | Kaynan |
| _preencher_ | _preencher_ | _Luiz / João_ |

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

## Dinâmica de uso

- A IA foi usada **individualmente**, como par de programação: o integrante pede, lê a resposta e decide se aceita.
- Tudo o que foi gerado passou pelo mesmo fluxo do resto do código: branch, PR, revisão de outro membro e pipeline verde no Jenkins.
- As histórias de usuário e os textos do README foram **reescritos pelo grupo** a partir do rascunho da IA.

## O que não foi feito por IA

Por exemplo: a arquitetura em camadas, o protocolo de comandos combinado com o firmware, o design das telas, as jogadas do `JOGADAS.json`, a parte de testes unitarios e toda a ideia do projeto foi criada pelos membros da RobotBulls.
