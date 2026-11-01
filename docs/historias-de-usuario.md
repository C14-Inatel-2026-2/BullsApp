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

## US03 — Ver o estado real dos sensores do robô

**Como** piloto da RobotBulls,
**eu quero** pedir a leitura dos sensores pelo celular e ver o que cada um está detectando,
**para que** eu confirme antes do round que todos os sensores do robô estão funcionando.

**Prioridade:** Média · **Status:** Parcial (o controller já interpreta as respostas, mas a tela de sensores ainda mostra dados simulados)

### Critérios de aceite

1. **Pedir a leitura**
   - **Dado** que o robô está conectado e estou na tela de sensores
   - **Quando** peço a leitura dos sensores
   - **Então** o app envia `SENSORES` ao robô

2. **Mostrar a resposta do robô**
   - **Dado** que pedi a leitura dos sensores
   - **Quando** o robô responde `sensorD2 vendo`
   - **Então** o sensor D2 aparece como **vendo**

3. **A leitura mais nova vale**
   - **Dado** que o sensor D2 está como **vendo**
   - **Quando** chega a resposta `sensorD2 cego`
   - **Então** o D2 passa a aparecer como **cego**

4. **Resposta que não é de sensor**
   - **Dado** que estou na tela de sensores
   - **Quando** o robô responde algo como `OK SENSORES`
   - **Então** nenhum sensor muda de estado

5. **Erro de conexão**
   - **Dado** que a conexão com o robô falha durante o pedido
   - **Quando** o envio dá erro
   - **Então** o app mostra a mensagem de erro e os sensores continuam com o último estado conhecido

**Rastreabilidade:** Jira Scrum-XX → `test/presentation/controller/test_controller_test.dart`

## US04 — Conectar ao robô por BLE

*Como* piloto da RobotBulls,
*eu quero* procurar o robô por Bluetooth e conectar a ele pelo celular,
*para que* eu possa enviar jogadas, calibrar o PID e usar o terminal sem precisar de cabos ou de um computador.

*Prioridade:* Alta · *Status:* Entregue

### Critérios de aceite

1. *Encontrar o robô*
   - *Dado* que o Bluetooth está ligado e as permissões foram concedidas
   - *Quando* abro a tela de busca e toco em escanear
   - *Então* o app lista os dispositivos com nome encontrados, do sinal mais forte para o mais fraco

2. *Robô conhecido primeiro*
   - *Dado* que já me conectei a um robô antes
   - *Quando* a lista de dispositivos é exibida
   - *Então* o robô já conhecido aparece no topo, antes dos demais

3. *Conectar ao robô*
   - *Dado* que o robô aparece na lista
   - *Quando* toco nele
   - *Então* o app conecta, retorna sucesso e salva o endereço MAC para as próximas vezes

4. *Sem duplicar o MAC salvo*
   - *Dado* que já me conectei a este robô antes
   - *Quando* conecto a ele novamente
   - *Então* o MAC continua salvo uma única vez

5. *Falha na conexão*
   - *Dado* que o robô está fora de alcance ou a conexão expira
   - *Quando* a conexão falha
   - *Então* o app mostra "Falha ao conectar" e o MAC não é salvo

6. *Bluetooth desligado*
   - *Dado* que o Bluetooth do celular está desligado
   - *Quando* toco em escanear
   - *Então* nenhum scan é iniciado e o app mostra "Bluetooth está desligado."

7. *Permissões negadas*
   - *Dado* que neguei as permissões de Bluetooth ou localização
   - *Quando* toco em escanear
   - *Então* nenhum scan é iniciado e o app orienta a habilitar as permissões nas configurações

8. *Desconectar*
   - *Dado* que o robô está conectado
   - *Quando* toco em desconectar
   - *Então* a conexão com o robô é encerrada

*Rastreabilidade:* `test/presentation/controller/ble_controller_test.dart`, `test/data/repositories/ble_repository_test.dart`, `test/data/services/ble_service_test.dart` (100% de cobertura em ble_service.dart e ble_repository.dart)

## US05 — Testar sensores e motores

**Como** piloto da RobotBulls,
**eu quero** ver um componente visual do robô na tela indicando a posição e o estado de cada sensor,
**para que** eu diagnostique rapidamente o hardware visualizando as cores antes ou durante os testes na arena.

**Prioridade:** Média · **Status:** A Fazer

### Critérios de aceite

1. **Renderizar o componente do robô**
   - **Dado** que abri a `sensor_page`
   - **Quando** a tela termina de carregar
   - **Então** vejo o componente visual do robô com todos os sensores posicionados corretamente

2. **Sensor detectando oponente ou linha**
   - **Dado** que a leitura do sensor acusa detecção
   - **Quando** a interface recebe essa atualização
   - **Então** a cor do sensor no componente muda para o status "vendo"

3. **Sensor sem detecção**
   - **Dado** que o sensor não está detectando nada
   - **Quando** a interface recebe essa atualização
   - **Então** a cor do sensor no componente muda para o status "cego"

4. **Sensor inativo ou falhando**
   - **Dado** que não há resposta do sensor ou ocorreu falha
   - **Quando** o sistema acusa erro
   - **Então** a cor do sensor muda para o status "sem resposta"

**Rastreabilidade:** Jira Scrum-5 → `presentation/pages/sensor_page.dart`

## US06 — Ajustar a potência dos motores e acionar a parada

**Como** membro da equipe técnica da RobotBulls,
**eu quero** ajustar a potência do motor direito e esquerdo usando duas barras verticais e ter um botão de parada,
**para que** eu consiga testar a tração e o funcionamento independente de cada motor na bancada.

**Prioridade:** Alta · **Status:** A Fazer

### Critérios de aceite

1. **Visualizar interface de motores**
   - **Dado** que abri a `motor_page`
   - **Quando** a tela carrega
   - **Então** visualizo as duas barras verticais (esquerda e direita) e um botão de "Parar"

2. **Ajustar potência da barra**
   - **Dado** que estou na tela de motores
   - **Quando** arrasto a barra vertical de um dos motores
   - **Então** o valor correspondente atualiza na interface e envia o novo parâmetro de velocidade ao robô

3. **Botão de parada de emergência**
   - **Dado** que modifiquei a potência dos motores
   - **Quando** toco no botão de "Parar"
   - **Então** as barras verticais retornam imediatamente a zero e o comando de parar os motores é enviado

**Rastreabilidade:** Jira Scrum-6 → `presentation/pages/motor_page.dart`

## US07 — Enviar comandos e acompanhar respostas no terminal

**Como** desenvolvedor ou responsável pela calibração do robô,
**eu quero** interagir com um terminal direto na tela, contendo campo de texto e histórico de requisições,
**para que** eu possa enviar comandos arbitrários e monitorar as respostas do robô sem conectar ao monitor serial.

**Prioridade:** Média · **Status:** A Fazer

### Critérios de aceite

1. **Visualizar os elementos do terminal**
   - **Dado** que acessei a `rc_page`
   - **Quando** a interface é carregada
   - **Então** vejo a lista de histórico de comandos, um campo para digitação e um botão de envio

2. **Enviar comando via interface**
   - **Dado** que digitei um comando válido no campo de texto
   - **Quando** toco no botão de enviar
   - **Então** o comando é disparado para o robô e o campo de texto é esvaziado

3. **Atualizar lista de histórico na tela**
   - **Dado** que um comando foi enviado ou recebido
   - **Quando** ocorre a atualização de dados no sistema
   - **Então** o novo item (enviado ou recebido) aparece visível no final da lista do terminal

**Rastreabilidade:** Jira Scrum-7 → `presentation/pages/rc_page.dart`