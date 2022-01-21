pipeline {
    agent any
    environment {
        DOCKER_REGISTRY = 'trickynickel.jfrog.io'
        DOCKER_REPOSITORY = 'default-docker-virtual'
        DOCKER_REPOSITORY_CREDENTIALS = 'deployer-artifactory'
        IMAGE_NAME = 'petclinic'
        IMAGE_VERSION = 'latest'
    }
    tools {
        maven "maven-3.8.4"
    } 
   
    stages {
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
                    docker.build(DOCKER_REPOSITORY+'/'+IMAGE_NAME+':'+IMAGE_VERSION, '--build-arg JAR_FILE=target/*.jar .')
                }
                //Docker image creation could be also made using the spring-boot plugin, build-image goal. No Dockerfile would be required
                //Look below the corresponding command
                //sh 'mvn spring-boot:build-image -DskipTests -Dspring-boot.build-image.imageName=${DOCKER_REPOSITORY}/${IMAGE_NAME}:${IMAGE_VERSION}'
            }
        }
        stage('Deploy') { 
            steps {
                echo 'Deploy the image in Artifactory'
                script {
                    def myImg = docker.image(DOCKER_REPOSITORY+'/'+IMAGE_NAME+':'+IMAGE_VERSION)

                    docker.withRegistry('https://'+DOCKER_REGISTRY, DOCKER_REPOSITORY_CREDENTIALS){
                            myImg.push()
                        }
                }
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
