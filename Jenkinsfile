pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build') {
            steps {
                sh './mvnw clean package' // or 'mvn clean package' if mvnw is absent
            }
        }
        stage('Test') {
            steps {
                sh './mvnw test' 
            }
        }
    }
}
