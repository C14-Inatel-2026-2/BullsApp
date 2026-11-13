pipeline {

    agent {
        docker {
            // Imagem já vem com Flutter + Dart instalados e configurados
            image 'ghcr.io/cirruslabs/flutter:stable'
            args '-u root'
        }
    }

    parameters {
        booleanParam(name: 'DEPLOY', defaultValue: true, description: 'Publica a web no GitHub Pages e o APK no GitHub Releases')
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
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    sh 'dart format --output=none --set-exit-if-changed lib test'
                }
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
                sh '''
                command -v python3 || (apt-get update && apt-get install -y python3)
                mkdir -p reports
                flutter test --machine --coverage > reports/test-results.json || FALHOU=1
                python3 scripts/gerar_relatorio.py
                exit ${FALHOU:-0}
                '''
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'reports/test-results.xml'
                    archiveArtifacts artifacts: 'reports/relatorio.html', allowEmptyArchive: true
                }
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
                            sh 'flutter build apk --release --no-tree-shake-icons'
                            stash name: 'apk', includes: 'build/app/outputs/flutter-apk/app-release.apk'
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
                            // O GitHub Pages serve o site em /BullsApp/
                            sh 'flutter build web --release --base-href /BullsApp/ --no-tree-shake-icons'
                            stash name: 'web', includes: 'build/web/**'
                            //guarda
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            when { expression { params.DEPLOY } }
            parallel {
                // Publica build/web na branch gh-pages (GitHub Pages)
                stage('Deploy Web') {  
                    steps {
                        sh 'rm -rf deploy-web'
                        //puxa
                        dir('deploy-web') { unstash 'web' }
                        withCredentials([string(credentialsId: 'github-token', variable: 'GH_TOKEN')]) {
                            sh '''
                            cd deploy-web/build/web && git init -q -b gh-pages && git add -A
                            git -c user.name=Jenkins -c user.email=ci@jenkins commit -qm "Build #$BUILD_NUMBER"
                            git push -qf https://x-access-token:$GH_TOKEN@github.com/C14-Inatel-2026-2/BullsApp.git gh-pages
                            '''
                        }
                    }
                }

                // Cria a release build-N no GitHub com o APK anexado
                stage('Deploy APK') {
                    steps {
                        sh 'rm -rf deploy-apk'
                        dir('deploy-apk') { unstash 'apk' }
                        withCredentials([string(credentialsId: 'github-token', variable: 'GH_TOKEN')]) {
                            sh '''
                            apt-get update -qq && apt-get install -y -qq gh
                            gh release create build-$BUILD_NUMBER deploy-apk/build/app/outputs/flutter-apk/app-release.apk -R C14-Inatel-2026-2/BullsApp --target $GIT_COMMIT --notes ""
                            '''
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


def notificarDiscord(String status) {
    
    def build = currentBuild.getBuildCauses('hudson.model.Cause$UserIdCause')
    def user = build ? build[0].userName : 'automático'

    withCredentials([string(credentialsId: 'discord-webhook', variable: 'DISCORD_WEBHOOK')]) {
        withEnv(["STATUS=${status}", "QUEM=${user}"]) {
            sh '''
            RESUMO=""
            [ -f reports/resumo.txt ] && RESUMO="\\n $(cat reports/resumo.txt)"
            ANEXO=""
            [ -f reports/relatorio.html ] && ANEXO="-F file1=@reports/relatorio.html"

            curl -s $ANEXO \
                 --form-string "payload_json={\\"content\\": \\"$STATUS — $JOB_NAME #$BUILD_NUMBER\\n Iniciado por: $QUEM$RESUMO\\n$BUILD_URL\\"}" \
                 "$DISCORD_WEBHOOK"
            '''
        }
    }
}
