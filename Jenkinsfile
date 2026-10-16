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

                stage('Build IOS') {
                    steps {
                        // Aloca um workspace temporário específico para o build iOS
                        ws("${env.WORKSPACE}_ios") {
                            checkout scm
                            echo 'Gerando IOS Flutter...'
                            sh 'flutter pub get'
                            sh 'flutter build ios --debug --no-tree-shake-icons --no-codesign'
                        }
                    }
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