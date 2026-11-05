pipeline {
    agent any

    environment {
        APP_NAME         = 'cicd-assignment-app'
        DOCKER_REGISTRY  = 'docker.io'
        DOCKER_IMAGE     = "${APP_NAME}:${BUILD_NUMBER}"
        AWS_DEFAULT_REGION = 'ap-south-1'
    }

    stages {
        stage('Checkout Source') {
            steps {
                echo 'Pulling latest commit from primary branch...'
                checkout scm
            }
        }

        stage('Run Tests') {
            steps {
                dir('app') {
                    sh '''
                        python3 -m venv venv
                        . venv/bin/activate
                        pip install --upgrade pip
                        pip install -r requirements.txt
                        pytest test_app.py -v --junitxml=test-reports/results.xml
                    '''
                }
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'app/test-reports/results.xml'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('app') {
                    sh '''
                        docker build -t ${DOCKER_IMAGE} .
                    '''
                }
            }
        }

        stage('Provision Infrastructure') {
            steps {
                dir('terraform') {
                    // With AWS Credentials configured in Jenkins Global Credentials Store as 'aws-credentials'
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_KEY'
                    ]]) {
                        sh '''
                            terraform init -input=false
                            terraform plan -out=tfplan -input=false
                            terraform apply -input=false -auto-approve tfplan
                        '''
                    }
                }
            }
        }

        stage('Deploy Application') {
            steps {
                sh '''
                    # Stop any running container from earlier builds
                    docker stop ${APP_NAME} || true
                    docker rm ${APP_NAME} || true

                    # Deploy locally or to the instance target
                    docker run -d --name ${APP_NAME} -p 5000:5000 ${DOCKER_IMAGE}
                '''
            }
        }

        stage('Verify Health') {
            steps {
                sh '''
                    sleep 3
                    curl --retry 5 --retry-delay 2 --fail http://localhost:5000/health || exit 1
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully for Build #${BUILD_NUMBER}."
        }
        failure {
            echo "Pipeline failed during execution. Check console output for debug traces."
        }
    }
}
