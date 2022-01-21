# My Petclinic

This project has been created from the [Spring pet-clinic project](https://github.com/spring-projects/spring-petclinic).

Two things have been added:
- A Jenkinsfile with a Jenkins pipeline script
- A Dockerfile with the configuration to build a Docker image from where running the application Petclinic

## Jenkins

To run the Jenkinsfile pipeline we need a Jenkins server configured with the [Docker](https://plugins.jenkins.io/docker-plugin/) and [Docker Pipeline](https://plugins.jenkins.io/docker-workflow/) plugins. 
Additionally, if running this pipeline in a Jenkins Agent, the agent requires to have a distribution of Maven (could be installed automatically by Jenkins when running the pipeline) and a Docker engine.

The pipeline implements 4 stages:
- Compile --> Uses the Maven test-compile goal, as we also want to compile the test classes in this stage
- Test --> Uses the Maven surefire:test goal, to avoid recompiling again
- Package --> First, it creates the executable .jar file using the Maven package spring-boot:repackage goals, skipping tests. Second, it builds the Docker image
- Deploy --> Uses the Docker pipeline plugin to push the image to a protected (credentials should be used) Artifactory Docker registry

NOTE: There is no stage cloning the source code repository as this pipeline has been conceived to be used from a Multibranch pipeline project. 

4 environments variables are providing the specific context to the pipeline:
- DOCKER_REGISTRY = The URI of the Docker registry we want to deploy the docker image in *(trickynickel.jfrog.io)*
- DOCKER_REPOSITORY = The name of the concrete repository in the registry *(default-docker-virtual)*
- DOCKER_REPOSITORY_CREDENTIALS = The id of the Credentials object that we would need to authenticate agains the repository *(deployer-artifactory)*
- IMAGE_NAME = The name we want to give to the image *(petclinic)*
- IMAGE_VERSION = The concrete version of the image *(latest)*

## How to run the application with a Docker container

Since the Docker image is created, tagged and pushed to a protected Docker registry, before pulling the image, we need to login into the repository

```
$ docker login https://trickynickel.jfrog.io
Username:
Password:

Login Succeeded
```
We can now pulling the image
```
$ docker pull trickynickel.jfrog.io/default-docker-virtual/petclinic:latest
latest: Pulling from default-docker-virtual/petclinic
e7c96db7181b: Already exists 
f910a506b6cb: Already exists 
c2274a1a0e27: Already exists 
cc35fd68946e: Pull complete 
Digest: sha256:dc2992ee6c0fbc3b79f8ae40a68f743e6e70925d7079020614a8a7a8d2314379
Status: Downloaded newer image for trickynickel.jfrog.io/default-docker-virtual/petclinic:latest
trickynickel.jfrog.io/default-docker-virtual/petclinic:latest
```
Finally, we run the container like this:
```
$ docker run -p 8080:8080 trickynickel.jfrog.io/default-docker-virtual/petclinic:latest
```
