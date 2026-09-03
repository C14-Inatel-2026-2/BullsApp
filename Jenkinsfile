pipeline {

    agent {
        docker {
            // Imagem já vem com Flutter + Dart instalados e configurados
            image 'ghcr.io/cirruslabs/flutter:stable'
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

    }

    post {
        success {
            echo '✅ Pipeline concluído com sucesso!'
        }
        failure {
            echo '❌ Pipeline falhou!'
        }
    }
}