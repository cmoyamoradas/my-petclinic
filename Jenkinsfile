pipeline {
    agent any
    environment {
        RT_URL = 'http://10.186.0.6:8082/artifactory'
        TOKEN = 'eyJ2ZXIiOiIyIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJXTE56ZHVLbldrYlR3M05zZjAyX2E3Q0xvZGgyaHNSaDNEWENpRjlHYXI4In0.eyJleHQiOiJ7XCJyZXZvY2FibGVcIjpcInRydWVcIn0iLCJzdWIiOiJqZmFjQDAxZzQyNHcxZzF6YnNlMGN2eWE5a3oxeGVlXC91c2Vyc1wvZGVwbG95ZXIiLCJzY3AiOiJhcHBsaWVkLXBlcm1pc3Npb25zXC91c2VyIiwiYXVkIjoiKkAqIiwiaXNzIjoiamZmZUAwMDAiLCJleHAiOjE2ODYzMDg5MjAsImlhdCI6MTY1NDc3MjkyMCwianRpIjoiMWYwMGVkMjctMDhkYy00NGQwLWFhMGMtN2Y4M2E4NGRkYzNhIn0.gBj5AqIAGAjw0err9kOddweVO2E5Nzj4v1NME5IuO0oNnkw2fIqSsJkJ3WVvIZofmYE9Xki0M03Ex0jNc0ZFP6BLll6ZaVrAqVdzSdAhVLhhtte3w3l3I1rD-pe4vxKzXnViLCNe_qvMPmsXKfMqwvbreolX-lGK9DOVL-ZQfArBIu7-gXknJ-tJW-fxdId5hchfpJ4D0_cbFjo-BG7YCJvrelPDI2eTGXIlc_3wxehB-8Ol3tqOgZXfwt_KMPjWeLOWwEo12UPq_3r0z2V50_UOrDL1oD5EFuGxtvcNGECVPRZHLkS1GdffaCCYg9K1OWgwCEdl4n64oRGD2oMCMQ'
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
