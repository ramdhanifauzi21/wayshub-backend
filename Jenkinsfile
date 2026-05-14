pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USERNAME = 'ramdhanifauzi'
        IMAGE_NAME = 'wayshub-backend'
        APP_SERVER = '10.194.61.3'
        DISCORD_WEBHOOK = credentials('discord-webhook')
        JWT_PRIVATE_KEY = credentials('jwt-private-key')
        CLOUD_NAME = credentials('cloud-name')
        API_KEY = credentials('api-key')
        API_SECRET = credentials('api-secret')
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
                            cd ~/be-production &&
                            cat > .env << EOF
JWT_PRIVATE_KEY=${JWT_PRIVATE_KEY}
CLOUD_NAME=${CLOUD_NAME}
API_KEY=${API_KEY}
API_SECRET=${API_SECRET}
DB_HOST=10.194.61.4
DB_USER=fauzi
DB_PASSWORD=Fauzi123!
DB_NAME=wayshub
EOF
                            docker compose pull &&
                            docker compose up -d
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
