# -------- Build Stage --------
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app

COPY pom.xml .

COPY src ./src

RUN mvn clean package -DskipTests

# -------- Runtime Stage --------
FROM openjdk:17-jdk-slim

WORKDIR /app

COPY --from=build /app/target/petclinic.jar petclinic.jar

EXPOSE 8070

ENTRYPOINT ["java","-jar","/petclinic.jar"]
