// Pipeline de qualidade da camada de controllers.
//
// Roda depois do pipeline principal (`bullsapp`) e responde a uma pergunta
// diferente da dele: não "o app funciona?", mas "a camada de controle
// continua bem testada?". Por isso não builda nada: analisa o código da
// camada, mede a cobertura e barra queda de cobertura.
pipeline {

    agent {
        docker {
            // Mesma imagem do pipeline principal: ambiente idêntico.
            image 'ghcr.io/cirruslabs/flutter:stable'
            args '-u root'
        }
    }

    // Dispara sozinho quando o pipeline principal termina com sucesso.
    // O Jenkins só registra o gatilho depois da primeira execução deste job.
    triggers {
        upstream(upstreamProjects: 'bullsapp', threshold: hudson.model.Result.SUCCESS)
    }

    options {
        timeout(time: 20, unit: 'MINUTES')
    }

    environment {
        COVERAGE_MIN = '60'

        // Arquivos da camada com código executável: entram na cobertura.
        LAYER_LIB = 'lib/presentation/controllers/auto_controller.dart lib/presentation/controllers/test_controller.dart lib/data/models/lado.dart lib/data/models/sensor_status.dart lib/core/constants/robot_protocol.dart lib/data/repositories/robot_command_exception.dart lib/data/repositories/fake_robot_command_port.dart'

        // Arquivos só de declaração (enum, interface): analisados, mas sem
        // linhas executáveis para cobrir.
        LAYER_DECL = 'lib/presentation/controllers/auto_status.dart lib/data/repositories/robot_command_port.dart'

        LAYER_TESTS = 'test/presentation/controller test/data/models/lado_test.dart test/core/constants/robot_protocol_test.dart'
    }

    stages {

        stage('Preparar Ambiente') {
            steps {
                sh 'git config --global --add safe.directory "*"'
            }
        }

        stage('Dependências') {
            steps {
                sh 'flutter pub get'
            }
        }

        // Antes dos testes: é mais rápido e pega outra classe de problema.
        // Só os arquivos da camada, para avisos de outras partes do projeto
        // não derrubarem este job.
        stage('Análise Estática') {
            steps {
                sh 'flutter analyze $LAYER_LIB $LAYER_DECL $LAYER_TESTS'
            }
        }

        stage('Testes com Cobertura') {
            steps {
                sh 'flutter test --coverage $LAYER_TESTS'
            }
        }

        stage('Gate de Cobertura') {
            steps {
                sh 'bash jenkins/coverage_gate.sh coverage/lcov.info "$COVERAGE_MIN" $LAYER_LIB'
            }
        }
    }

    post {
        always {
            // Relatório disponível para download no painel do build,
            // inclusive quando o gate falha.
            archiveArtifacts artifacts: 'coverage/lcov.info', allowEmptyArchive: true
        }
    }
}
