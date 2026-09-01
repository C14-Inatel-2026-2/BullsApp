pipeline {

    agent any

    environment {
        PATH = "${env.PATH};C:\\src\\flutter\\bin"
    }

    stages {

        stage("Verificação Inicial"){
            steps{
                echo 'Iniciando pipeline de testes BullsApp...'
                batch 'flutter --version'
                batch 'dart --version'
            }
        }
    
        stage('Obter Dependências'){
            steps {
                echo 'Instalando dependências...'
                batch 'flutter clean'
                batch 'flutter pub get'
            }
        }

        stage('Executar Testes'){
            steps {
                echo 'Rodando testes...'
                batch 'flutter test -v'
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
