pipeline {
    agent any

    environment {
        SONARQUBE_SERVER = 'SonarQubeServer'
        GIT_CREDENTIALS_ID = 'github_token'

        NEXUS_URL = '164.92.169.9:5000'
        NEXUS_REPO = 'docker-local'
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

        // Quality Gate (attend le résultat Sonar)
        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        // === Dependency scan (OWASP Dependency-Check) ===
        // stage('Dependency Scan - OWASP (SCA)') {
        //     steps {
        //         // Variante Maven (recommandée pour projet Java)
        //         // - failBuildOnCVSS=7 -> échoue si CVSS >= 7 (ajuste à ton besoin)
        //         // - Dodc.outputDirectory ou -DoutputDirectory peut être utilisé selon version du plugin
        //         sh '''
        //             mvn org.owasp:dependency-check-maven:check \
        //               -Dformat=ALL \
        //               -Dodc.outputDirectory=dependency-check-report \
        //               -DfailBuildOnCVSS=7 || true
        //         '''
        //     }
        //     post {
        //         always {
        //             archiveArtifacts artifacts: 'dependency-check-report/**', fingerprint: true
        //         }
        //     }
        // }

        stage('Security Scan - Trivy') {
            steps {
                sh 'trivy fs --exit-code 1 --severity HIGH,CRITICAL . || true'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${IMAGE_NAME}:latest .
                    docker tag ${IMAGE_NAME}:latest ${NEXUS_URL}/${NEXUS_REPO}/${IMAGE_NAME}:latest
                """
            }
        }

        stage('Security Scan image - Trivy') {
            steps {
                sh "trivy image --exit-code 1 --severity HIGH,CRITICAL ${NEXUS_URL}/${NEXUS_REPO}/${IMAGE_NAME}:latest || true"
            }
        }

        stage('Push to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus_credentials_id', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh '''
                        echo "$NEXUS_PASS" | docker login 164.92.169.9:5000 --username "$NEXUS_USER" --password-stdin
                        docker push 164.92.169.9:5000/docker-local/myapp:latest
                    '''
                }
            }
        }
        stage('Deploy with Ansible') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus_credentials_id', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh """
                        /usr/bin/ansible-playbook -i ansible/inventory.ini ansible/site.yml -u root \
                        --extra-vars "NEXUS_USER=$NEXUS_USER NEXUS_PASS=$NEXUS_PASS"
                    """
                }
            }
        }
    }
}
