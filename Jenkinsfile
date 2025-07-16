pipeline {
    agent any

    environment {
        IMAGE_NAME = 'nbn-app'
        DOCKER_HUB_REPO = 'tharun33/nbn-app'
        SLACK_WEBHOOK = credentials('slack_webhook_url') // Add this credential in Jenkins
    }

    stages {
        stage('Clone Repo') {
            steps {
                git credentialsId: 'git-creds', url: 'https://github.com/tharunsd/nbnapp.git', branch: 'main'
            }
        }

        stage('Trivy Scan') {
            steps {
                sh 'trivy fs --exit-code 0 --severity MEDIUM,HIGH .'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t $IMAGE_NAME ."
            }
        }

        stage('Run Container (Local Test)') {
            steps {
                sh "docker stop nbn-container || true"
                sh "docker rm nbn-container || true"
                sh "docker run -d -p 5002:5002 --name nbn-container $IMAGE_NAME"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker tag $IMAGE_NAME $DOCKER_HUB_REPO"
                    sh "docker push $DOCKER_HUB_REPO"
                }
            }
        }
    }

    post {
        success {
            sh '''
            curl -X POST -H 'Content-type: application/json' \
            --data '{"text":"✅ *Build SUCCESS* for `'"$JOB_NAME"'` (#'"$BUILD_NUMBER"')"}' $SLACK_WEBHOOK
            '''
        }
        failure {
            sh '''
            curl -X POST -H 'Content-type: application/json' \
            --data '{"text":"❌ *Build FAILED* for `'"$JOB_NAME"'` (#'"$BUILD_NUMBER"')"}' $SLACK_WEBHOOK
            '''
        }
    }
}
