FROM openjdk:8-jdk-alpine
ARG JAR_FILE
COPY ${JAR_FILE} petclinic.jar
ENTRYPOINT ["java","-jar","/petclinic.jar"]
