pipeline {
    agent any
    environment {
        ARTIFACTORY_DOCKER_REGISTRY = 'http://10.186.0.6:8082/docker-virtual'
        DOCKER_REPOSITORY = 'docker-virtual'
        SERVER_ID = 'onboarding'
        HOST_NAME = ''
        CREDENTIALS = 'deployer'
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
                    credentialsId: CREDENTIALS
                )
            }
        }
        stage('Compile') { 
            steps {
                echo 'Compiling'     
                sh 'mvn clean test-compile'
            }
        }
        stage('Test') { 
            steps {
                echo 'Running the tests'
                sh 'mvn surefire:test'
            }
        }
        stage('Package') { 
            steps {
                //Before creating the docker image, we need to create the .jar file
                sh 'mvn package spring-boot:repackage -DskipTests'
                echo 'Create the Docker image'
                script {
                    docker.build(ARTIFACTORY_DOCKER_REGISTRY+'/'+IMAGE_NAME+':'+IMAGE_VERSION, '--build-arg JAR_FILE=target/*.jar .')
                }
            }
        }
        stage('Deploy') { 
            steps {
                echo 'Deploy the image in Artifactory'
                rtDockerPush(
                    serverId: SERVER_ID,
                    image: ARTIFACTORY_DOCKER_REGISTRY + '/$IMAGE_NAME:$IMAGE_VERSION',
                    // Host:
                    // On OSX: "tcp://127.0.0.1:1234"
                    // On Linux can be omitted or null
                    host: HOST_NAME,
                    targetRepo: 'docker-local',
                    // Attach custom properties to the published artifacts:
                    properties: 'project-name=$JOB_NAME;status=stable'
                )
            }
        }
    }
    post {
        success { 
            echo 'Removing local images'
            sh 'docker rmi ${DOCKER_REPOSITORY}/${IMAGE_NAME}:${IMAGE_VERSION} ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/${IMAGE_NAME}:${IMAGE_VERSION}'
        }
        cleanup {
            echo 'Removing dangling images'
            sh 'docker images prune'
        }
    }
}
