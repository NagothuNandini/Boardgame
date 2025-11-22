pipeline {
    agent any
    
    tools {
        maven 'maven3'
    }
    
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {
        stage('Git Checkout') {
            steps {
               git branch: 'main', url: 'https://github.com/NagothuNandini/Boardgame.git'
            }
        }

        stage('Compile') {
            steps {
                sh "mvn compile"
            }
        }

        stage('Test') {
            steps {
                sh "mvn test"
            }
        }

        stage('File System Scan') {
            steps {
                sh "trivy fs --format table -o trivy-fs-report.html ."
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=BoardGame-Test -Dsonar.projectKey=BoardGame-Test \
                            -Dsonar.java.binaries=. '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-cred'
                }
            }
        }

        stage('Build') {
            steps {
               sh "mvn package"
            }
        }

        stage('Publish To Nexus') {
            steps {
               withMaven(globalMavenSettingsConfig: 'nexus-config', maven: 'maven3') {
                    sh "mvn deploy"
                }
            }
        }

        stage('Build & Tag Docker Image') {
            steps {
               script {
                   withDockerRegistry(credentialsId: 'docker-cred') {
                        sh "docker build -t nandini951/boardgame:latest ."
                    }
               }
            }
        }

        stage('Docker Image Scan') {
            steps {
                sh "trivy image --format table -o trivy-image-report.html nandini951/boardgame:latest"
            }
        }

        stage('Push Docker Image') {
            steps {
               script {
                   withDockerRegistry(credentialsId: 'docker-cred') {
                        sh "docker push nandini951/boardgame:latest"
                    }
               }
            }
        }

        /* 🚀 ASK USER ONLY HERE — RIGHT BEFORE DEPLOYING */
        stage('Deploy To Kubernetes') {
            steps {
                script {

                    // 🔥 Ask user here only once, right before deploy
                    env.SELECTED_ENV = input(
                        id: 'EnvSelect',
                        message: "Choose the environment to deploy the application:",
                        parameters: [
                            choice(
                                name: 'DEPLOY_ENV',
                                choices: ['development', 'staging', 'production'],
                                description: 'Select environment'
                            )
                        ]
                    )

                    def namespace = env.SELECTED_ENV
                    echo "Deploying to Kubernetes namespace: ${namespace}"

                    withKubeConfig(
                        caCertificate: '',
                        clusterName: 'kubernetes',
                        contextName: '',
                        credentialsId: 'k8s-multi-stage',
                        namespace: '',
                        restrictKubeConfigAccess: false,
                        serverUrl: 'https://10.0.1.62:6443'
                    ) {
                        sh "kubectl apply -f k8s/${namespace}/deployment-service.yaml -n ${namespace} --validate=false"
                    }
                }
            }
        }

    }
}

