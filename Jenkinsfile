pipeline {
    agent any

    environment {
        SONARQUBE_SERVER = 'SonarQubeServer'
        GIT_CREDENTIALS_ID = 'github_token'
        NEXUS_URL = '164.92.169.9:5000'
        NEXUS_REPO = 'docker-local'
        NEXUS_CREDENTIALS = credentials('nexus_credentials_id')
        IMAGE_NAME = 'myapp'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    credentialsId: "${GIT_CREDENTIALS_ID}", 
                    url: 'https://github.com/YassineDev32/Java_21.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('SonarQube analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Security Scan') {
            steps {
                sh 'trivy fs --exit-code 1 --severity HIGH,CRITICAL .'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t $IMAGE_NAME:latest .
                    docker tag $IMAGE_NAME:latest $NEXUS_URL/$NEXUS_REPO/$IMAGE_NAME:latest
                """
            }
        }

        stage('Push to Nexus') {
            steps {
                sh """
                    echo "${NEXUS_CREDENTIALS_PSW}" | docker login $NEXUS_URL --username "${NEXUS_CREDENTIALS_USR}" --password-stdin
                    docker push $NEXUS_URL/$NEXUS_REPO/$IMAGE_NAME:latest
                """
            }
        }
    }
}
