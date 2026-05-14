pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USERNAME = 'ramdhanifauzi'
        IMAGE_NAME = 'wayshub-backend'
        APP_SERVER = '103.23.199.139'
        DISCORD_WEBHOOK = credentials('discord-webhook')
    }
    stages {
        stage('Pull from GitHub') {
            steps {
                echo 'Pulling latest code...'
                git branch: 'production', url: 'https://github.com/ramdhanifauzi21/wayshub-backend'
            }
        }
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh """
                    docker build -t ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:production .
                """
            }
        }
        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing to Docker Hub...'
                sh """
                    echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                    docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:production
                """
            }
        }
        stage('Deploy to App Server') {
            steps {
                echo 'Deploying to App Server...'
                sshagent(['app-server-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no fauzi@${APP_SERVER} '
                            docker pull ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:production &&
                            docker stop wayshub-backend-production || true &&
                            docker rm wayshub-backend-production || true &&
                            docker run -d \
                                --name wayshub-backend-production \
                                --restart always \
                                -p 5000:5000 \
                                ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:production
                        '
                    """
                }
            }
        }
    }
    post {
        success {
            discordSend(
                webhookURL: "${DISCORD_WEBHOOK}",
                title: "✅ Build SUCCESS - ${env.JOB_NAME}",
                description: "Build #${env.BUILD_NUMBER} berhasil deploy wayshub-backend production!",
                result: currentBuild.currentResult
            )
        }
        failure {
            discordSend(
                webhookURL: "${DISCORD_WEBHOOK}",
                title: "❌ Build FAILED - ${env.JOB_NAME}",
                description: "Build #${env.BUILD_NUMBER} gagal deploy wayshub-backend production!",
                result: currentBuild.currentResult
            )
        }
    }
}
