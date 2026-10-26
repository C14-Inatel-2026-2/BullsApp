pipeline {

    agent {
        docker {
            // Imagem já vem com Flutter + Dart instalados e configurados
            image 'ghcr.io/cirruslabs/flutter:stable'
            args '-u root'
        }
    }

    stages {

        stage('Test Flutter') {
            steps {
                sh '''
                git config --global --add safe.directory '*'
                flutter --version
                dart --version
                '''
            }
        }

        stage('Obter Dependências'){
            steps {
                echo 'Instalando dependências...'
                sh 'flutter clean'
                sh 'flutter pub get'
            }
        }

        stage('Verificar Formatação') {
            steps {
                echo 'Verificando formatação...'
                sh 'dart format --output=none --set-exit-if-changed lib test'
            }
        }

        stage('Análise Estática') {
            steps {
                echo 'Verificando análise estática...'
                sh 'flutter analyze'
            }
        }

        stage('Executar Testes'){
            steps {
                echo 'Rodando testes...'
                sh 'flutter test -v'
        }
        }

        stage('Cobertura dos Controllers') {
            steps {
                echo 'Medindo a cobertura dos testes da camada de controllers...'
                sh 'flutter test --coverage test/presentation/controller'
                archiveArtifacts artifacts: 'coverage/lcov.info', allowEmptyArchive: true
            }
        }

        stage('Builds em Paralelo') {
            parallel {
                stage('Build APK') {
                    steps {
                        // Aloca um workspace temporário específico para o build Android
                        ws("${env.WORKSPACE}_android") {
                            // Garante que o código atualizado esteja nesta pasta alternativa
                            checkout scm
                            echo 'Gerando APK Flutter...'
                            sh 'flutter pub get'
                            sh 'flutter build apk --debug --no-tree-shake-icons'
                        }
                    }
                }

                stage('Build Web') {
                    steps {
                        // Aloca um workspace temporário específico para o build Web
                        ws("${env.WORKSPACE}_web") {
                            checkout scm
                            echo 'Gerando Web Flutter...'
                            sh 'flutter pub get'
                            sh 'flutter build web --debug --no-tree-shake-icons'
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline concluído com sucesso!'
            notificarDiscord('✅ Pipeline OK')
        }
        failure {
            echo '❌ Pipeline falhou!'
            notificarDiscord('❌ Pipeline FALHOU')
        }
    }
}

// Manda uma mensagem no Discord usando o webhook salvo no Jenkins
// (credencial do tipo "Secret text" com o ID 'discord-webhook').
// Se o relatório de testes existir, vai junto como anexo e o resumo entra no texto.
def notificarDiscord(String status) {
    withCredentials([string(credentialsId: 'discord-webhook', variable: 'DISCORD_WEBHOOK')]) {
        withEnv(["STATUS=${status}"]) {
            sh '''
            RESUMO=""
            [ -f reports/resumo.txt ] && RESUMO="\\n $(cat reports/resumo.txt)"
            ANEXO=""
            [ -f reports/relatorio.html ] && ANEXO="-F file1=@reports/relatorio.html"

            curl -s $ANEXO \
                 --form-string "payload_json={\\"content\\": \\"$STATUS — $JOB_NAME #$BUILD_NUMBER$RESUMO\\n$BUILD_URL\\"}" \
                 "$DISCORD_WEBHOOK"
            '''
        }
    }
}
