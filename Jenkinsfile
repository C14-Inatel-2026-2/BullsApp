pipeline {

    agent any

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
                echo 'Instalando dependências do projeto...'
                bat '''
                   flutter clean
                   flutter pub get
                   echo Dependencias instaladas com sucesso!
                '''

            }
        }

        stage('Executar Testes'){

            steps {
                echo 'Rodando testes unitários...'
                bat '''
                   flutter test -v
                   echo Testes executados!
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
}
