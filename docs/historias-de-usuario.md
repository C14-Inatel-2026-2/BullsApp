# Histórias de Usuário

## US01 — Executar jogadas e entrar no modo RC durante o combate

**Como** piloto da RobotBulls no Sumô Mini ou 3 kg,
**eu quero** escolher numero da jogada e lado que ela vai, ou ativar o modo RC pelo celular,
**para que** eu consiga mudar a estratégia do robô rapidamente entre os rounds.

**Prioridade:** Alta · **Status:** Parcial (a tela de RC ainda não está pronta)

### Critérios de aceite

1. **Enviar jogada pelo lado direito**
   - **Dado** que o robô está conectado e estou na tela Auto
   - **Quando** escolho o lado **DIREITA** e a jogada 22 e toco em enviar
   - **Então** o app envia o comando `D22` ao robô

2. **Jogada em modo teste**
   - **Dado** que ativei o botão **TESTE**
   - **Quando** envio a jogada 8 pelo lado **ESQUERDA**
   - **Então** o app envia `TE08`, e o robô executa a jogada sem iniciar uma luta

3. **Lado inválido**
   - **Dado** que nenhum lado válido foi escolhido
   - **Quando** tento enviar uma jogada
   - **Então** nenhum comando é enviado e o app mostra uma mensagem de erro

4. **Modo RC**
   - **Dado** que o robô está conectado
   - **Quando** escolho um lado e toco em **RC**
   - **Então** o app envia `DRC` (direita) ou `ERC` (esquerda)

5. **Parar sempre funciona**
   - **Dado** que um comando ainda está sendo enviado
   - **Quando** toco em parar
   - **Então** o comando `STOP` é enviado na hora, sem esperar o anterior

**Rastreabilidade:** Jira Scrum-7 → PR #22 → `test/presentation/controller/auto_controller_test.dart`, `test/core/constants/robot_protocol_test.dart`


## US02 — Usar o terminal e calibrar o PID do robô

**Como** responsável pela calibração do robô nas competições,
**eu quero** ajustar os valores de Kp, Ki e Kd e mandar comandos manuais por um terminal no app,
**para que** eu consiga alinhar as jogadas com suas determinadas estrategias do robô nos treinos, sem precisar conectar um computador.

**Prioridade:** Alta · **Status:** Entregue

### Critérios de aceite

1. **Enviar o PID**
   - **Dado** que o robô está conectado e estou na tela Calibrar PID
   - **Quando** defino Kp = 1, Ki = 0 e Kd = 0.5 e toco em salvar
   - **Então** o app envia `PID 1.0 0.0 0.5` e mostra "PID enviado ao robô."

2. **Valor fora da faixa**
   - **Dado** que estou ajustando um dos valores do PID
   - **Quando** digito um número menor que 0 ou maior que 100
   - **Então** o valor não é aceito e o PID atual continua o mesmo

3. **Comando pelo terminal**
   - **Dado** que estou na tela Terminal
   - **Quando** digito um comando e toco em enviar
   - **Então** o comando é enviado ao robô e aparece no histórico, junto com a resposta

4. **Comando vazio**
   - **Dado** que o campo do terminal está vazio
   - **Quando** toco em enviar
   - **Então** nada é enviado

5. **Erro de conexão**
   - **Dado** que a conexão com o robô falha durante um envio
   - **Quando** o envio dá erro
   - **Então** a mensagem de erro aparece no terminal e na tela

**Rastreabilidade:** Jira Scrum-32 → PR #22 → `test/presentation/controller/test_controller_test.dart`
