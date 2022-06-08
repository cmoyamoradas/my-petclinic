pipeline {
    agent any
    environment {
        ARTIFACTORY_DOCKER_REGISTRY = '10.186.0.6:8082/docker-virtual'
        DOCKER_REPOSITORY = 'docker-virtual'
        CREDENTIALS = 'Artifactory'
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
                    id: 'onboarding',
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
        stage('Deploy') { 
            steps {
                echo 'Deploy the image in Artifactory'
                /*
                script {
                    def myImg = docker.image(DOCKER_REPOSITORY+'/'+IMAGE_NAME+':'+IMAGE_VERSION)

                    docker.withRegistry('http://' + ARTIFACTORY_DOCKER_REGISTRY, CREDENTIALS){
                            myImg.push()
                        }
                }
                */
                rtDockerPush(
                    serverId: 'onboarding',
                    image: DOCKER_REPOSITORY+'/'+IMAGE_NAME+':'+IMAGE_VERSION,
                    // Host:
                    // On OSX: "tcp://127.0.0.1:1234"
                    // On Linux can be omitted or null
                    targetRepo: 'docker-local',
                    // Attach custom properties to the published artifacts:
                    properties: 'project-name=${JOB_NAME};status=stable'
                )
            }
        }
    }
    post {
        success { 
            echo 'Removing local images'
            sh 'docker rmi ${DOCKER_REPOSITORY}/${IMAGE_NAME}:${IMAGE_VERSION} ${ARTIFACTORY_DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_VERSION}'
        }
        cleanup {
            echo 'Removing dangling images'
            sh 'docker images prune'
        }
    }
}
