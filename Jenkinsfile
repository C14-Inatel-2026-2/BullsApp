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

        stage('Executar Testes'){
            steps {
                echo 'Rodando testes...'
                sh 'flutter test -v'
            }
        }

        // Build só depois dos testes: se algum teste falhar, não perde tempo gerando APK
        stage('Build') {
            steps {
                echo 'Gerando APK Flutter...'
                sh 'flutter build apk --debug --no-tree-shake-icons'
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
// (credencial do tipo "Secret text" com o ID 'discord-webhook')
def notificarDiscord(String status) {
    withCredentials([string(credentialsId: 'discord-webhook', variable: 'DISCORD_WEBHOOK')]) {
        withEnv(["STATUS=${status}"]) {
            sh '''
            curl -s -H "Content-Type: application/json" \
                 -d "{\\"content\\": \\"$STATUS — $JOB_NAME #$BUILD_NUMBER\\n$BUILD_URL\\"}" \
                 "$DISCORD_WEBHOOK"
            '''
        }
    }
}
