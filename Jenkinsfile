pipeline {
    agent any

    environment {
        SONARQUBE_SERVER = 'SonarQubeServer'  // Name from Manage Jenkins → Configure System → SonarQube Servers
        GIT_CREDENTIALS_ID = 'github_token'
        JFROG_URL = 'http://164.92.169.9:8081/artifactory'
        JFROG_REPO = 'docker-local'
        JFROG_USER = credentials('jfrog_user')
        JFROG_PASS = credentials('jfrog_pass')
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
                sh '''
                    docker build -t $IMAGE_NAME:latest .
                    docker tag $IMAGE_NAME:latest $JFROG_URL/$JFROG_REPO/$IMAGE_NAME:latest
                '''
            }
        }

        stage('Push to JFrog Artifactory') {
            steps {
                sh '''
                    echo "$JFROG_PASS" | docker login $JFROG_URL --username "$JFROG_USER" --password-stdin
                    docker push $JFROG_URL/$JFROG_REPO/$IMAGE_NAME:latest
                '''
            }
        }
    }
}
