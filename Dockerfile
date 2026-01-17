# -------- Build Stage --------
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# -------- Runtime Stage --------
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app
COPY --from=build /app/target/petclinic.jar app.jar

EXPOSE 8070

ENTRYPOINT ["java","-XX:MaxRAMPercentage=75","-jar","app.jar"]
