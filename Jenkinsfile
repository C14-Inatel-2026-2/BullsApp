pipeline {

    agent any

    stages {

        stage("Verificação Inicial"){
            steps{
                echo 'Iniciando pipeline de testes BullsApp...'
                sh 'flutter --version'
                sh 'dart --version'
            }
        }
    
        stage('Obter Dependências'){

            steps {
                echo 'Instalando dependências do projeto...'
                sh '''
                   flutter clean
                   flutter pub get
                   echo "Dependências instaladas com sucesso!"
                '''

            }
        }

        stage('Executar Testes'){

            steps {
                echo 'Rodando testes unitários...'
                sh '''
                   flutter test -v
                   echo "Testes executados!"
                '''
                
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
