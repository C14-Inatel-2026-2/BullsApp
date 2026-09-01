pipeline {

    agent any

    environment {
        PATH = "${env.PATH};C:\\src\\flutter\\bin"
    }

    stages {

        stage("Verificação Inicial"){
            steps{
                echo 'Iniciando pipeline de testes BullsApp...'
                bat 'flutter --version'
                bat 'dart --version'
            }
        }
    
        stage('Obter Dependências'){
            steps {
                echo 'Instalando dependências...'
                bat 'flutter clean'
                bat 'flutter pub get'
            }
        }

        stage('Executar Testes'){
            steps {
                echo 'Rodando testes...'
                bat 'flutter test -v'
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
