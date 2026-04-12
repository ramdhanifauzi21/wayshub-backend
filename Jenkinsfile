pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USERNAME = 'ramdhanifauzi'
        IMAGE_NAME = 'wayshub-backend'
        SERVER1_IP = '103.55.37.38'
	DISCORD_WEBHOOK = credentials('discord-webhook')
    }

    stages {

        stage('Pull from GitHub') {
            steps {
                echo 'Pulling latest code...'
                git branch: 'main', url: 'https://github.com/kelompok1-dumbways/wayshub-backend'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh """
                    docker build -t ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest .
                """
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing to Docker Hub...'
                sh """
                    echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                    docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest
                """
            }
        }

        stage('Deploy to Server 1') {
            steps {
                echo 'Deploying to Server 1...'
                sshagent(['server1-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no kelompok-1@${SERVER1_IP} '
                            docker pull ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest &&
                            docker stop kelompok1-backend-production || true &&
                            docker rm kelompok1-backend-production || true &&
                            docker run -d --name kelompok1-backend-production --network team1-network -p 5000:5000 \
                                -e JWT_PRIVATE_KEY=951836 \
                                -e CLOUD_NAME=dlumdgloz \
                                -e API_KEY=958682469343893 \
                                -e API_SECRET=ujMVhZydB8NHd0z2w13HFwm4EEA \
                                -v ~/wayshub-docker/wayshub-backend/config/config.json:/app/config/config.json \
                                ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest
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
                description: "Build #${env.BUILD_NUMBER} berhasil deploy wayshub-frontend!",
                result: currentBuild.currentResult
            )
        }
        failure {
            discordSend(
                webhookURL: "${DISCORD_WEBHOOK}",
                title: "❌ Build FAILED - ${env.JOB_NAME}",
                description: "Build #${env.BUILD_NUMBER} gagal!",
                result: currentBuild.currentResult
            )
        }
    }

}
