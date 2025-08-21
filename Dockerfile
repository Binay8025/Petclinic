FROM openjdk:17-jdk-slim
EXPOSE 8070
ADD target/petclinic.jar petclinic.jar
ENTRYPOINT ["java","-jar","/petclinic.jar"]
