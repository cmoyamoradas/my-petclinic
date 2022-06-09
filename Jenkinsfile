pipeline {
    agent any
    environment {
        RT_URL = 'http://10.186.0.6:8082/artifactory'
        TOKEN = 'eyJ2ZXIiOiIyIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJXTE56ZHVLbldrYlR3M05zZjAyX2E3Q0xvZGgyaHNSaDNEWENpRjlHYXI4In0.eyJleHQiOiJ7XCJyZXZvY2FibGVcIjpcInRydWVcIn0iLCJzdWIiOiJqZmFjQDAxZzQyNHcxZzF6YnNlMGN2eWE5a3oxeGVlXC91c2Vyc1wvZGVwbG95ZXIiLCJzY3AiOiJhcHBsaWVkLXBlcm1pc3Npb25zXC91c2VyIiwiYXVkIjoiKkAqIiwiaXNzIjoiamZmZUAwMDAiLCJleHAiOjE2ODYzMDI4MDEsImlhdCI6MTY1NDc2NjgwMSwianRpIjoiNWY0Y2M0OGEtYjlhZi00N2U5LWEyYTktYmE2OTZlMzE5NTEzIn0.aVon1tHqyWdg20RrME9DDP7-NU8iTEQudwfxhuF1PtQ4h0n8LJirEcMVv3_2m5cdDcb7HYLsPGnRnEVWRtF2ZuQbrEZPUNZ00G-xg3tZIX-1fCUppOoXslNTsNix6SeQJ5O-4mf5gr52NaS-lGMXMRfyL8e7TITDASmSGYttk2Hrxp0Nuixx0bPnuXHCIo0g2Byp9Zp6zz9ACFvsiFY0otoPmJYypw5P66cMu2wILqAyEx0sFD4fdRyTBSFKDtkOQSNLwa9PIRlmp3tmAVhjTrcmj_hO22jdo2YKwXpxlFMnketyCOKrpxX-B-u-1qL32VV5y7xjNVo5dVQgmXt5_g'
        ARTIFACTORY_DOCKER_REGISTRY = '10.186.0.6:8082/docker-virtual'
        DOCKER_REPOSITORY = 'docker-virtual'
        CREDENTIALS = 'Artifactory'
        SERVER_ID = 'onboarding'
        IMAGE_NAME = 'my-pet-clinic'
        IMAGE_VERSION = 'latest'
    }
    tools {
        maven "maven-3.6.3"
    } 
   
    stages {
        stage ('Artifactory configuration') {
            steps {
                rtServer (
                    id: SERVER_ID,
                    url: RT_URL,
                    credentialsId: CREDENTIALS
                )
            }
        }
        stage('Compile') { 
            steps {
                echo 'Compiling'     
                sh 'mvn clean test-compile -Dcheckstyle.skip -DskipTests'
            }
        }
        stage('Package') { 
            steps {
                //Before creating the docker image, we need to create the .jar file
                sh 'mvn package spring-boot:repackage -DskipTests -Dcheckstyle.skip'
                echo 'Create the Docker image'
                script {
                    docker.build(DOCKER_REPOSITORY+'/'+IMAGE_NAME+':'+IMAGE_VERSION, '--build-arg JAR_FILE=target/*.jar .')
                }
            }
        }
        stage ('Ping to Artifactory') {
            steps {
                sh 'jf rt ping --url ${RT_URL} --access-token ${TOKEN}'
            }
        }
        stage ('Push image to Artifactory') {
            steps {
                ws('/var/lib/jenkins/workspace/jfrog-cli'){
                    sh 'jf rt docker-push ${ARTIFACTORY_DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_VERSION} ${DOCKER_REPOSITORY} --build-name=${JOB_NAME} --build-number=${BUILD_ID} --url ${RT_URL} --access-token ${TOKEN}'
                }
            }
        }
        stage ('Publish build info') {
            steps {
                ws('/var/lib/jenkins/workspace/jfrog-cli'){
                    sh 'jf rt bp ${JOB_NAME} ${BUILD_ID} --url ${RT_URL} --access-token ${TOKEN}'
                }
            }
        }
        stage('Scan') {
            steps {
                xrayScan (
                    serverId: SERVER_ID,
                    failBuild: 'false'
                )
            }
        }
    }
}
