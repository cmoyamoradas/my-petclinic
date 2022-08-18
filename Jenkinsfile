pipeline {
    agent any
    environment {
        RT_URL = 'http://10.186.0.25/artifactory'
        TOKEN = 'eyJ2ZXIiOiIyIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJoMWQ5eV91V2tfVGFrY1ZlZ3c5ZG5sM2xFSWZObFI3cDdGckN5aHRHS3kwIn0.eyJleHQiOiJ7XCJyZXZvY2FibGVcIjpcInRydWVcIn0iLCJzdWIiOiJqZmFjQDAxZzdwcjAzaG5xbWN0MXoxeG4xYWgxYjR6XC91c2Vyc1wvYWRtaW4iLCJzY3AiOiJhcHBsaWVkLXBlcm1pc3Npb25zXC9hZG1pbiIsImF1ZCI6IipAKiIsImlzcyI6ImpmZmVAMDAwIiwiZXhwIjoxNjg5NTQ2ODE5LCJpYXQiOjE2NTgwMTA4MTksImp0aSI6ImY2ZmE0ZDE5LTg1NzMtNDU0Zi05OGM1LWVkOWI5NWIxODZlYyJ9.J6SxPbF6KB-ocyuFmqrcKmsrcrdm8yCuKzTsI0c5vMHd7u0ju_gSpY3MHXz1fJreS9wQEVI0MIoR3fSoOLZyMTYAFiDV3RboQ9AdsVb2MQfOiPIv32MwqUw3TCO3zAwZv7TteGhj3amfKn96rJTtFw2PrXVLZh3mtWQoSanvsrc1O4wcmF0pm5169GlXd0LRldcZnv6ItrsLbxXMO6Tpy7apOIdNBlg3VBWE-AUQMzneRlm2f9Uxo42ldBNXNKDzmidE1-PT37rfaYpHj698ja7OWCtzK6kV5V8AsF2TPxOym1bRh0oNWDu4lP-pY4fRSIgfNFPzn43M693r02jwwA'
        ARTIFACTORY_DOCKER_REGISTRY = '10.186.0.21/docker-local'
        DOCKER_REPOSITORY = 'docker-local'
        CREDENTIALS = 'Artifactoryk8s'
        SERVER_ID = 'k8s'
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
                    docker.build(ARTIFACTORY_DOCKER_REGISTRY+'/'+IMAGE_NAME+':'+IMAGE_VERSION, '--build-arg JAR_FILE=target/*.jar .')
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
                sh 'jf rt docker-push ${ARTIFACTORY_DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_VERSION} ${DOCKER_REPOSITORY} --build-name=${JOB_NAME} --build-number=${BUILD_ID} --url ${RT_URL} --access-token ${TOKEN}'
            }
        }
        stage ('Publish build info') {
            steps {
                sh 'jf rt bce ${JOB_NAME} ${BUILD_ID}'
                sh 'jf rt bp ${JOB_NAME} ${BUILD_ID} --build-url ${BUILD_URL} --url ${RT_URL} --access-token ${TOKEN}'
            }
        }
        stage('Scan') {
            steps {
                xrayScan (
                    serverId: SERVER_ID,
                    buildName: JOB_NAME,
                    buildNumber: BUILD_ID,
                    failBuild: true
                )
            }
        }
    }
}
